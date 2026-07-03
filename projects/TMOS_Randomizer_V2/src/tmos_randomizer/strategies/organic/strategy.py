"""Organic strategy orchestrator.

Pipeline:
- A: extract per-section spatial templates from the original ROM.
- B+C: assign screen content to each grid position, edge-scored.
- D: write navigation pointers.
- E: patch ROM and build spoiler log.

The strategy defers everything ROM-dependent to ``apply_plan`` — ``create_plan``
only returns enough of a plan to keep the UI contract happy. That keeps us
decoupled from a ROM-path-in-config requirement.
"""

from __future__ import annotations

import copy
import hashlib
import logging
import random
from pathlib import Path
from typing import Dict, List, Optional, Tuple

logger = logging.getLogger(__name__)

from ...core.chapter import GameWorld
from ...io.rom_reader import load_rom
from ...io.rom_writer import patch_rom
from ...output.spoiler_log import SpoilerLogBuilder, write_spoiler_log
from ...phases.phase1_planning import (
    ChapterPlan,
    SectionPlan,
    WorldPlan,
    plan_randomization,
)
from ...phases.phase2_shaping import ChapterShape, WorldShape, shape_world
from ...phases.phase3_connection import (
    ChapterConnections,
    SectionConnection,
    WorldConnections,
    connect_world,
)
from ...phases.phase4_population import (
    ChapterPopulation,
    ScreenAssignment,
    WorldPopulation,
)
from ...plan import RandomizationPlan, RandomizationResult
from ..base import RandomizationStrategy
from ..registry import register_strategy
from .detect import (
    FailureReport,
    _warp_row,
    compute_pristine_reachable,
    detect_world_failures,
)
from .exitpos import repair_exit_positions
from .stitch import (
    grow_screen0_component,
    nav_component,
    stitch_chapter_connectivity,
)
from .fallbacks import (
    aggressive_blob_merge,
    apply_section_consolidation,
    drop_unmergeable_orphans,
)
from .navigation import write_world_navigation
from .palette_cluster import improve_palette_clustering
from .placement import ChapterPlacement, plan_placement
from .repair import RepairReport, run_world_repair
from .template import ChapterTemplate, extract_world_templates


@register_strategy
class OrganicStrategy(RandomizationStrategy):
    """Template-based randomizer — original shape, shuffled content."""

    name = "organic"
    description = (
        "Extracts section shapes from the original ROM and shuffles content "
        "within each shape with edge-aware placement."
    )

    def create_plan(self, seed: int) -> RandomizationPlan:
        """Return a stub plan. All real work happens in ``apply_plan``.

        The ROM isn't available here, so we can't compute templates yet. We
        still produce an empty-but-valid ``WorldPlan/Shape/Connections`` so
        ``RandomizationPlan`` invariants hold and the UI can preview the seed.
        """
        return RandomizationPlan(
            seed=seed,
            config=self.config,
            world_plan=WorldPlan(seed=seed, chapters=[]),
            world_shape=WorldShape(seed=seed, chapters=[]),
            world_connections=WorldConnections(seed=seed, chapters=[]),
            strategy_name=self.name,
        )

    def preview_plan(
        self,
        plan: RandomizationPlan,
        game_world,
        rom_data: bytes,
        progress=None,
    ) -> Dict[int, ChapterTemplate]:
        """v4 pipeline: placement → repair → detect → post-fix → optional retry
        → strict-spatial nav-write → forced-warp fallback.

        Returns the final templates so ``apply_plan`` can reuse them for
        spoiler generation without re-extracting.

        ``progress``, if given, is called with a short phase name as the
        pipeline advances (surfaced live in the UI's randomize progress).
        """
        _phase = progress if callable(progress) else (lambda _msg: None)
        # Abstract flow plan — needed by detect() to know what's "stray".
        abstract_plan = plan_randomization(self.config, seed=plan.seed)
        abstract_shape = shape_world(abstract_plan)
        abstract_conn = connect_world(
            abstract_plan,
            abstract_shape,
            topology=self.config.connectivity.topology,
            dungeon_last=self.config.connectivity.dungeon_last,
            randomize_order=self.config.connectivity.order_randomization,
        )
        plan.world_plan = abstract_plan
        plan.world_shape = abstract_shape
        plan.world_connections = abstract_conn

        # Pristine snapshot for retry — save WorldScreen field values per
        # chapter so we can restore in-place between attempts without
        # reassigning ``game_world`` (which would sever the caller's reference
        # and leave Pass C/D operating on an orphan copy).
        pristine_snapshots = _snapshot_worldscreens(game_world)
        # Per-chapter nav reachability in the pristine ROM. Every screen in
        # this set MUST remain reachable post-randomization — anything else
        # is a regression.
        pristine_reachable = compute_pristine_reachable(
            {c.chapter_num: c for c in game_world}, rom_data
        )
        # Kept for the post-pipeline component gate: "no regressions vs
        # pristine" is the validity bar; screens vanilla itself never
        # reaches (battle/sub-world interiors) are not gate failures.
        self._last_pristine_reachable = pristine_reachable
        # Vanilla size of screen 0's nav-only component per chapter — the
        # reachability oracle's bar. game_world is still pristine here.
        pristine_nav0_sizes = {
            c.chapter_num: len(nav_component(c, 0)) for c in game_world
        }

        # Pristine grid-clustering proxy per chapter — the pre-nav stand-in
        # for the oracle's same-biome nav-edge ratio. Attempts are compared
        # against this so retries can rescue clustering, not just criticals.
        pristine_grid_cluster = _grid_clustering(
            {c.chapter_num: c for c in game_world},
            extract_world_templates(game_world),
            placements=None,
        )

        max_retries = self.config.repair.max_retries
        best_state: Optional[Tuple[Dict[int, ChapterTemplate], Dict[int, ChapterPlacement], Dict[int, RepairReport], Dict[int, FailureReport], int]] = None
        # Lexicographic attempt objective:
        #   (criticals, trunk-unreached screens, summed clustering deficit).
        # Criticals always dominate; the rest only break ties among equally
        # broken attempts, so connectivity can never trade away for biome
        # coherence.
        best_score: Tuple[float, float, float] = (float("inf"),) * 3

        for attempt in range(max_retries + 1):
            if attempt > 0:
                # Restore pristine screen state in-place.
                _restore_worldscreens(game_world, pristine_snapshots)

            attempt_seed = plan.seed if attempt == 0 else plan.seed + 1337 * attempt

            attempt_tag = f" (retry {attempt})" if attempt > 0 else ""
            _phase(f"Placing screens{attempt_tag}")
            templates = extract_world_templates(game_world)
            rng = random.Random(attempt_seed)
            placements: Dict[int, ChapterPlacement] = {}
            for chapter_num, template in templates.items():
                chapter = game_world.chapters[chapter_num]
                chapter_rng = random.Random(rng.randrange(2**31))
                placements[chapter_num] = plan_placement(
                    chapter=chapter,
                    template=template,
                    rom_data=rom_data,
                    rng=chapter_rng,
                )

            chapters_map = {c.chapter_num: c for c in game_world}

            repair_reports: Dict[int, RepairReport] = {}
            _phase(f"Repairing edges{attempt_tag}")
            if self.config.repair.enabled:
                repair_reports = run_world_repair(
                    chapters=chapters_map,
                    templates=templates,
                    placements=placements,
                    rom_data=rom_data,
                    max_iterations=self.config.repair.max_iterations,
                    time_ms_per_chapter=self.config.repair.time_ms_per_chapter,
                    seed=attempt_seed,
                )

            # Pass B — consolidate stray templates first; downstream passes
            # (including blob merging) will then see the merged grids.
            apply_section_consolidation(
                chapters=chapters_map,
                templates=templates,
                placements=placements,
                plan=plan,
            )

            # Pass A — aggressive relocate + TS-swap loop. Every disconnected
            # blob's screens are moved to the edge of the main blob and given
            # whatever tileset they need to walkably connect. Nothing gets
            # dropped; edges get *made* to match.
            _phase(f"Merging map blobs{attempt_tag}")
            aggressive_stats = aggressive_blob_merge(
                chapters=chapters_map,
                templates=templates,
                placements=placements,
                rom_data=rom_data,
                time_ms_per_chapter=self.config.repair.time_ms_per_chapter,
                seed=attempt_seed,
            )
            self._last_aggressive_stats = aggressive_stats

            # Biome coherence — reorder equal-alignment layouts inside mixed
            # sections into contiguous palette runs (oracle clustering
            # channel). Score weighting guarantees connectivity never trades
            # away for coherence.
            self._last_palette_stats = improve_palette_clustering(
                chapters=chapters_map,
                templates=templates,
                placements=placements,
                rom_data=rom_data,
                seed=attempt_seed,
            )

            post_reports = detect_world_failures(
                chapters=chapters_map,
                templates=templates,
                placements=placements,
                plan=plan,
                rom_data=rom_data,
                pristine_reachable_by_chapter=pristine_reachable,
            )

            critical = sum(
                len(r.unreachable_screens) + len(r.disconnected_sections)
                for r in post_reports.values()
            )
            # Secondary objectives — cheap grid-level proxies (nav isn't
            # written yet at this point in the attempt loop):
            #  - trunk_unreached: screens the trunk-grow pass couldn't
            #    walkably align (each one is future stitch load, and
            #    unaligned stitches are exactly the oracle-visible warts);
            #  - clustering deficit vs the pristine grid ratio (biome
            #    coherence channel).
            trunk_unreached = aggressive_stats.get("trunk_unreached", 0)
            grid_cluster = _grid_clustering(chapters_map, templates, placements)
            deficits = {
                ch: max(0.0, pristine_grid_cluster.get(ch, 0.0) - ratio)
                for ch, ratio in grid_cluster.items()
            }
            worst_deficit = max(deficits.values(), default=0.0)
            attempt_score = (critical, trunk_unreached, round(sum(deficits.values()), 4))

            if best_state is None or attempt_score < best_score:
                best_score = attempt_score
                best_state = (templates, placements, repair_reports, post_reports, attempt)
                # Snapshot the WORLD as this attempt left it. Repair,
                # consolidation and blob-merge mutate WorldScreen tilesets
                # in-place; finalizing a best attempt's templates/placements
                # against a LATER attempt's world state silently misaligns
                # every repaired edge (walls everywhere).
                best_world_snapshot = _snapshot_worldscreens(game_world)

            # Accept immediately only when the attempt is clean on BOTH
            # channels; a critical-free attempt with fragmented biomes now
            # spends the remaining retry budget looking for a better draw
            # (best-so-far is kept either way).
            if critical == 0 and worst_deficit <= 0.05:
                break

        assert best_state is not None
        templates, placements, repair_reports, post_reports, retries_used = best_state
        if retries_used != attempt:
            # Best attempt was not the last one executed — restore its
            # world state so nav write + validators see matching data.
            _restore_worldscreens(game_world, best_world_snapshot)
        chapters_map = {c.chapter_num: c for c in game_world}
        self._last_repair_reports = repair_reports

        # Rebuild the Flow plan from the CONSOLIDATED templates + actual
        # placements so the UI section pills exactly match the population.
        plan.world_plan = _plan_from_templates(plan.seed, templates, placements)
        plan.world_connections = _connections_from_templates(plan.seed, templates)

        _phase("Writing navigation")
        world_nav = write_world_navigation(
            chapters=chapters_map,
            templates=templates,
            placements=placements,
            seed=plan.seed,
            rom_data=rom_data,
        )

        # Final connectivity stitch — closing guarantee on the REAL nav
        # graph: every pristine-reachable screen must be reachable from the
        # chapter's respawn root, or get wired in (with TS-swap alignment).
        _phase("Stitching connectivity")
        stitch_totals: Dict[str, int] = {}
        for ch_num, chapter in chapters_map.items():
            required = pristine_reachable.get(ch_num, set())
            if not required:
                continue
            stitch_chapter_connectivity(
                chapter=chapter,
                template=templates[ch_num],
                placement=placements[ch_num],
                required=required,
                rom_data=rom_data,
                seed=plan.seed,
                totals=stitch_totals,
            )
        # Grow screen 0's nav-only component to at least vanilla size —
        # the differential oracle measures reachability as exactly that
        # component's share of the chapter (BFS from screen 0, nav only).
        for ch_num, chapter in chapters_map.items():
            grow_screen0_component(
                chapter=chapter,
                placement=placements[ch_num],
                target_size=pristine_nav0_sizes.get(ch_num, 0),
                rom_data=rom_data,
                seed=plan.seed,
                totals=stitch_totals,
            )
        self._last_stitch_stats = stitch_totals

        _phase("Validating world")
        # Repair ExitPosition on arrival screens (stairway/warp/respawn/
        # battle-entry): TS-swaps above (and in the stitch) may have put the
        # spawn tile inside a wall. $98C0 warp destinations included.
        warp_targets = {
            ch_num: _warp_row(ch_num, rom_data)
            for ch_num in chapters_map
        }
        self._last_exitpos_fixed = repair_exit_positions(
            chapters_map, rom_data, extra_targets=warp_targets
        )

        final_reports = detect_world_failures(
            chapters=chapters_map,
            templates=templates,
            placements=placements,
            plan=plan,
            rom_data=rom_data,
            pristine_reachable_by_chapter=pristine_reachable,
        )
        self._last_failure_reports = final_reports
        self._last_retries_used = retries_used

        plan.world_population = _population_from_placements(
            templates=templates,
            placements=placements,
            seed=plan.seed,
        )
        plan.world_navigation = world_nav

        self._run_validators(plan, game_world, rom_data)

        return templates

    def apply_plan(
        self,
        input_rom: Path,
        output_rom: Path,
        plan: RandomizationPlan,
        generate_spoiler: bool,
    ) -> RandomizationResult:
        result = RandomizationResult(success=False, seed=plan.seed)

        try:
            game_world = load_rom(input_rom)
            with open(input_rom, "rb") as f:
                rom_data = f.read()

            templates = self.preview_plan(plan, game_world, rom_data)

            # Evaluate the hard gate BEFORE writing anything to disk — an
            # invalid randomization must not leave a broken ROM behind.
            # Gate = engine-real reachability only: zero regressions vs the
            # pristine baseline and one root component per chapter.
            # Intra-section blob cohesion (disconnected_sections) is a
            # quality metric, surfaced as a warning, not a validity gate —
            # screens in a split section are still reachable via the
            # stitched graph.
            final_reports = getattr(self, "_last_failure_reports", {}) or {}
            unreachable_total = sum(len(r.unreachable_screens) for r in final_reports.values())
            disconnected_total = sum(len(r.disconnected_sections) for r in final_reports.values())
            components_ok = self._verify_single_component_per_chapter(game_world, rom_data)
            gate_passed = unreachable_total == 0 and components_ok

            if gate_passed:
                patch_rom(input_rom, output_rom, game_world)
                result.output_rom_path = output_rom
                with open(output_rom, "rb") as f:
                    result.rom_sha256 = hashlib.sha256(f.read()).hexdigest()

            if gate_passed and generate_spoiler and self.config.output.spoiler_log_enabled:
                spoiler = self._build_spoiler(plan, templates, result.rom_sha256)
                result.spoiler_log = spoiler
                written = write_spoiler_log(
                    spoiler,
                    output_rom.parent,
                    text_filename=self.config.output.spoiler_text_filename,
                    json_filename=self.config.output.spoiler_json_filename,
                )
                result.spoiler_text_path = written.get("text")
                result.spoiler_json_path = written.get("json")

            modified_screens = sum(
                len(cn.navigation_changes)
                for cn in (plan.world_navigation.chapters if plan.world_navigation else [])
            )
            repair_summary: Dict[str, int] = {}
            reports = getattr(self, "_last_repair_reports", {}) or {}
            if reports:
                repair_summary = {
                    "iterations_total": sum(r.iterations_used for r in reports.values()),
                    "broken_edges_before": sum(r.broken_edges_before for r in reports.values()),
                    "broken_edges_after": sum(r.broken_edges_after for r in reports.values()),
                    "orphans_before": sum(r.orphans_before for r in reports.values()),
                    "orphans_after": sum(r.orphans_after for r in reports.values()),
                    "screen_swaps": sum(r.actions_applied.get("screen_swap", 0) for r in reports.values()),
                    "pool_pulls": sum(r.actions_applied.get("pool_pull", 0) for r in reports.values()),
                    "accepted_problems": sum(len(r.accepted_problems) for r in reports.values()),
                }
            failure_summary: Dict[str, int] = {}
            final_reports = getattr(self, "_last_failure_reports", {}) or {}
            aggressive = getattr(self, "_last_aggressive_stats", {}) or {}
            if final_reports:
                failure_summary = {
                    "unreachable_screens_total": sum(len(r.unreachable_screens) for r in final_reports.values()),
                    "disconnected_sections_total": sum(len(r.disconnected_sections) for r in final_reports.values()),
                    "stray_templates_total": sum(len(r.stray_template_ids) for r in final_reports.values()),
                    "spatial_mismatches_total": sum(len(r.spatial_nav_mismatches) for r in final_reports.values()),
                    "relocations": aggressive.get("relocations", 0),
                    "ts_swaps_on_orphan": aggressive.get("ts_swaps_on_orphan", 0),
                    "ts_swaps_on_neighbor": aggressive.get("ts_swaps_on_neighbor", 0),
                    "retries_used": getattr(self, "_last_retries_used", 0),
                }
            merge_summary = getattr(self, "_last_merge_stats", {}) or {}
            result.stats = {
                "nav_writes": modified_screens,
                "chapters_randomized": len(templates),
                "strategy": self.name,
                **({"repair": repair_summary} if repair_summary else {}),
                **({"failures": failure_summary} if failure_summary else {}),
                **({"component_merge": merge_summary} if merge_summary else {}),
            }
            result.errors = list(plan.validation_errors)
            result.warnings = list(plan.validation_warnings)

            # Hard gate (evaluated above, before the ROM write): only report
            # success when every chapter is a single connected component with
            # zero unreachable screens.
            result.success = gate_passed
            if not gate_passed:
                result.errors.append(
                    f"Randomization gate failed — no ROM written: "
                    f"unreachable={unreachable_total}, "
                    f"single_component={components_ok}"
                )
            if disconnected_total:
                result.warnings.append(
                    f"{disconnected_total} section(s) placed as multiple "
                    f"walkable blobs (reachable via stitched links; cosmetic)"
                )

        except Exception as exc:
            logger.exception("organic apply_plan crashed (seed %s)", plan.seed)
            result.errors.append(f"{type(exc).__name__}: {exc}")

        return result

    # ------------------------------------------------------------------
    # Internals
    # ------------------------------------------------------------------

    def _verify_single_component_per_chapter(
        self, game_world: GameWorld, rom_data: Optional[bytes] = None
    ) -> bool:
        """Final navigability check: every PRISTINE-REACHABLE screen must be
        reachable from the chapter's real start/respawn screen via the
        engine's actual mechanisms (nav pointers + stairways + $98C0 warps —
        the same traversal as detect).

        Scoped to the pristine baseline: screens vanilla itself never
        reaches (battle-only / sub-world interiors) are not failures. When
        no baseline is available (called outside preview_plan) it falls back
        to all non-building-entrance screens."""
        from .detect import _nav_reachable

        baseline = getattr(self, "_last_pristine_reachable", {}) or {}
        for chapter in game_world:
            total = chapter.screen_count
            if total == 0:
                continue
            reached = _nav_reachable(chapter, rom_data)
            required = baseline.get(chapter.chapter_num)
            if required is not None:
                if required - reached:
                    return False
                continue
            if len(reached) < total:
                unreached_blocking = sum(
                    1 for s in chapter
                    if s.relative_index not in reached
                    and not s.has_building_entrance
                )
                if unreached_blocking:
                    return False
        return True

    def _run_validators(
        self,
        plan: RandomizationPlan,
        game_world: GameWorld,
        rom_data: bytes,
    ) -> None:
        from ...validation import ValidationPhase

        context = {
            "rom_data": rom_data,
            "world_plan": plan.world_plan,
            "world_shape": plan.world_shape,
            "world_connections": plan.world_connections,
            "world_population": plan.world_population,
            "world_navigation": plan.world_navigation,
        }

        if self.validation_config.run_final:
            final_result = self.validation_runner.validate_final(game_world, context)
            for issue in final_result.errors:
                plan.validation_errors.append(str(issue))
            for issue in final_result.warnings:
                plan.validation_warnings.append(str(issue))

    def _build_spoiler(
        self,
        plan: RandomizationPlan,
        templates: Dict[int, ChapterTemplate],
        rom_sha256: str,
    ):
        builder = SpoilerLogBuilder(
            seed=plan.seed,
            preset=plan.config.difficulty.preset,
        )
        builder.set_rom_hash(rom_sha256)
        builder.set_settings({
            "strategy": self.name,
            "mode": plan.config.general.mode,
            "chapters": plan.config.general.chapters,
        })

        for chapter_num in sorted(templates):
            template = templates[chapter_num]
            total = sum(sec.size for sec in template.sections)
            builder.add_chapter_map(
                chapter_num=chapter_num,
                screen_count=total,
                topology="organic",
            )
            for sec in template.sections:
                builder.add_section_to_chapter(
                    chapter_num=chapter_num,
                    section_type=sec.section_type.name.lower(),
                    screen_count=sec.size,
                    shape="organic",
                )

        builder.add_interesting(
            f"Seed {plan.seed} generated with the organic strategy — "
            "shapes preserved from the original ROM, content shuffled."
        )
        return builder.build()


def _grid_clustering(
    chapters: Dict[int, "Chapter"],
    templates: Dict[int, ChapterTemplate],
    placements: Optional[Dict[int, ChapterPlacement]],
) -> Dict[int, float]:
    """Same-biome ratio over grid-adjacent placed pairs, per chapter.

    Pre-nav proxy for validation.coherence.same_biome_adjacency_ratio: the
    nav writer turns exactly these grid adjacencies into nav edges (stitch
    adds a handful more). ``placements=None`` scores the pristine layout
    (every original screen at its own template cell).
    """
    from ...validation.coherence import biome_key

    scores: Dict[int, float] = {}
    for ch_num, template in templates.items():
        chapter = chapters.get(ch_num)
        if chapter is None:
            continue
        same = 0
        total = 0
        for sec in template.sections:
            if placements is not None:
                placed = placements[ch_num].section_positions(sec.section_id)
            else:
                placed = {pos: idx for idx, pos in sec.positions.items()}
            for (x, y), idx_a in placed.items():
                for npos in ((x + 1, y), (x, y + 1)):
                    idx_b = placed.get(npos)
                    if idx_b is None:
                        continue
                    scr_a = chapter.get_screen(idx_a)
                    scr_b = chapter.get_screen(idx_b)
                    if scr_a is None or scr_b is None:
                        continue
                    total += 1
                    if biome_key(scr_a) == biome_key(scr_b):
                        same += 1
        scores[ch_num] = 1.0 if total == 0 else same / total
    return scores


_SNAPSHOT_FIELDS = (
    "parent_world", "ambient_sound", "content", "objectset",
    "screen_index_right", "screen_index_left",
    "screen_index_down", "screen_index_up",
    "datapointer", "exit_position",
    "top_tiles", "bottom_tiles",
    "worldscreen_color", "sprites_color", "unknown", "event",
)


def _snapshot_worldscreens(game_world) -> Dict[int, List[Dict[str, int]]]:
    """Capture every WorldScreen's mutable fields, keyed by chapter number.

    Used as the "pristine" state for in-place restore between retry attempts.
    """
    snap: Dict[int, List[Dict[str, int]]] = {}
    for chapter in game_world:
        rows: List[Dict[str, int]] = []
        for screen in chapter:
            rows.append({f: getattr(screen, f) for f in _SNAPSHOT_FIELDS})
        snap[chapter.chapter_num] = rows
    return snap


def _restore_worldscreens(game_world, snap: Dict[int, List[Dict[str, int]]]) -> None:
    """Write snapshotted field values back onto each WorldScreen in-place."""
    for chapter in game_world:
        rows = snap.get(chapter.chapter_num)
        if rows is None:
            continue
        for screen, row in zip(chapter, rows):
            for f, v in row.items():
                setattr(screen, f, v)
            screen._modified = False


# =============================================================================
# Adapter helpers — emit UI-facing plan objects from template+placement.
# =============================================================================

def _plan_from_templates(
    seed: int,
    templates: Dict[int, ChapterTemplate],
    placements: Optional[Dict[int, ChapterPlacement]] = None,
) -> WorldPlan:
    """Build a WorldPlan that mirrors the templates, so the UI and spoiler
    have per-section section_type/screen_count information.

    When ``placements`` is provided, only include sections that have actual
    placed screens (avoids phantom sections left over from consolidation).
    """
    world_plan = WorldPlan(seed=seed)
    for chapter_num in sorted(templates):
        template = templates[chapter_num]
        placement = placements.get(chapter_num) if placements else None

        sections: List[SectionPlan] = []
        for sec in template.sections:
            if placement is not None:
                placed_count = len(placement.section_positions(sec.section_id))
                if placed_count == 0:
                    continue
                screen_count = placed_count
            else:
                if sec.size == 0:
                    continue
                screen_count = sec.size

            sections.append(SectionPlan(
                section_type=sec.section_type,
                section_id=sec.section_id,
                target_screen_count=screen_count,
                shape="organic",
                is_past=sec.is_past,
            ))
        world_plan.chapters.append(ChapterPlan(
            chapter_num=chapter_num,
            total_screens=sum(s.target_screen_count for s in sections),
            sections=sections,
        ))
    return world_plan


def _connections_from_templates(
    seed: int,
    templates: Dict[int, ChapterTemplate],
) -> WorldConnections:
    """Build a WorldConnections so the Flow view has edges to draw.

    Only includes connections whose BOTH endpoints are non-empty sections
    (sections with placed screens). This prevents the d3 force graph from
    crashing on dangling node references.
    """
    world = WorldConnections(seed=seed)
    for chapter_num in sorted(templates):
        template = templates[chapter_num]
        ch_conn = ChapterConnections(chapter_num=chapter_num)

        valid_sids = {s.section_id for s in template.sections if s.size > 0}

        seen_pairs: set = set()
        for edge in template.inter_section_edges:
            if edge.from_section_id not in valid_sids or edge.to_section_id not in valid_sids:
                continue
            pair = (edge.from_section_id, edge.to_section_id)
            if pair in seen_pairs:
                continue
            seen_pairs.add(pair)
            ch_conn.connections.append(SectionConnection(
                from_section_id=edge.from_section_id,
                to_section_id=edge.to_section_id,
                from_screen_id=edge.from_screen,
                to_screen_id=edge.to_screen,
                method="edge",
                bidirectional=True,
            ))

        # Time-door bridge between the two TD-owning sections.
        if template.time_door_pair is not None:
            pres_idx, past_idx = template.time_door_pair
            pres_sec = template.section_of(pres_idx)
            past_sec = template.section_of(past_idx)
            if pres_sec and past_sec:
                ch_conn.connections.append(SectionConnection(
                    from_section_id=pres_sec.section_id,
                    to_section_id=past_sec.section_id,
                    from_screen_id=pres_idx,
                    to_screen_id=past_idx,
                    method="time_door",
                    bidirectional=True,
                ))

        if ch_conn.connections:
            ch_conn.section_order = [s.section_id for s in template.sections]
            ch_conn.start_section_id = template.sections[0].section_id if template.sections else 1
            ch_conn.end_section_id = template.sections[-1].section_id if template.sections else 0

        world.chapters.append(ch_conn)
    return world


def _population_from_placements(
    *,
    templates: Dict[int, ChapterTemplate],
    placements: Dict[int, ChapterPlacement],
    seed: int,
) -> WorldPopulation:
    """Mirror the placement into a WorldPopulation so the UI sees the layout."""
    world_pop = WorldPopulation(seed=seed)
    for chapter_num in sorted(templates):
        template = templates[chapter_num]
        placement = placements[chapter_num]
        ch_pop = ChapterPopulation(chapter_num=chapter_num)

        for sec in template.sections:
            section_grid: Dict = {}
            screen_list: List[int] = []
            for orig_idx, pos in sec.positions.items():
                placed_idx = placement.get(sec.section_id, pos)
                if placed_idx is None:
                    continue
                section_grid[pos] = placed_idx
                screen_list.append(placed_idx)
                ch_pop.screen_to_position[placed_idx] = pos
                ch_pop.assignments.append(ScreenAssignment(
                    real_screen_index=placed_idx,
                    section_id=sec.section_id,
                    local_id=orig_idx,
                    original_section_type=sec.section_type,
                    grid_position=pos,
                ))
            ch_pop.section_grid_positions[sec.section_id] = section_grid
            ch_pop.screen_assignments[sec.section_id] = screen_list

        world_pop.chapters.append(ch_pop)
    return world_pop
