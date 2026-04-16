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
import random
from pathlib import Path
from typing import Dict, List, Optional, Tuple

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
from .detect import FailureReport, compute_pristine_reachable, detect_world_failures
from .fallbacks import (
    aggressive_blob_merge,
    apply_section_consolidation,
    drop_unmergeable_orphans,
)
from .navigation import write_world_navigation
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
    ) -> Dict[int, ChapterTemplate]:
        """v4 pipeline: placement → repair → detect → post-fix → optional retry
        → strict-spatial nav-write → forced-warp fallback.

        Returns the final templates so ``apply_plan`` can reuse them for
        spoiler generation without re-extracting.
        """
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
            {c.chapter_num: c for c in game_world}
        )

        max_retries = self.config.repair.max_retries
        best_state: Optional[Tuple[Dict[int, ChapterTemplate], Dict[int, ChapterPlacement], Dict[int, RepairReport], Dict[int, FailureReport], int]] = None
        best_score: float = float("inf")

        for attempt in range(max_retries + 1):
            if attempt > 0:
                # Restore pristine screen state in-place.
                _restore_worldscreens(game_world, pristine_snapshots)

            attempt_seed = plan.seed if attempt == 0 else plan.seed + 1337 * attempt

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
            aggressive_stats = aggressive_blob_merge(
                chapters=chapters_map,
                templates=templates,
                placements=placements,
                rom_data=rom_data,
                time_ms_per_chapter=self.config.repair.time_ms_per_chapter,
                seed=attempt_seed,
            )
            self._last_aggressive_stats = aggressive_stats

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

            if best_state is None or critical < best_score:
                best_score = critical
                best_state = (templates, placements, repair_reports, post_reports, attempt)

            if critical == 0:
                break

        assert best_state is not None
        templates, placements, repair_reports, post_reports, retries_used = best_state
        chapters_map = {c.chapter_num: c for c in game_world}
        self._last_repair_reports = repair_reports

        world_nav = write_world_navigation(
            chapters=chapters_map,
            templates=templates,
            placements=placements,
            seed=plan.seed,
            rom_data=rom_data,
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

            patch_rom(input_rom, output_rom, game_world)
            result.output_rom_path = output_rom

            with open(output_rom, "rb") as f:
                result.rom_sha256 = hashlib.sha256(f.read()).hexdigest()

            if generate_spoiler and self.config.output.spoiler_log_enabled:
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

            # Hard gate: only report success when every chapter is a single
            # connected component with zero unreachable screens. Anything else
            # is a playable-map failure and must not be surfaced as success.
            unreachable_total = (failure_summary or {}).get("unreachable_screens_total", 0)
            disconnected_total = (failure_summary or {}).get("disconnected_sections_total", 0)
            components_ok = self._verify_single_component_per_chapter(game_world)
            if unreachable_total == 0 and disconnected_total == 0 and components_ok:
                result.success = True
            else:
                result.success = False
                if components_ok is False:
                    result.errors.append(
                        "Post-pipeline connectivity check failed: at least one "
                        "chapter has multiple connected components reachable from screen 0."
                    )

        except Exception as exc:
            result.errors.append(str(exc))

        return result

    # ------------------------------------------------------------------
    # Internals
    # ------------------------------------------------------------------

    def _verify_single_component_per_chapter(self, game_world: GameWorld) -> bool:
        """Final navigability check: every chapter must be a single connected
        component reachable from screen 0 (ignoring NAV_BLOCKED / 0xFE)."""
        from collections import deque
        from ...core.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
        from ...logic.navigation import DIRECTIONS

        for chapter in game_world:
            total = chapter.screen_count
            if total == 0:
                continue
            reached = {0}
            queue = deque([0])
            while queue:
                idx = queue.popleft()
                scr = chapter.get_screen(idx)
                if scr is None:
                    continue
                for direction in DIRECTIONS:
                    t = getattr(scr, f"screen_index_{direction}")
                    if t in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                        continue
                    if t < 0 or t >= total:
                        continue
                    if t in reached:
                        continue
                    reached.add(t)
                    queue.append(t)
            # Every screen in the chapter should be reachable from 0.
            if len(reached) < total:
                # Account for screens legitimately reached only via 0xFE/building
                # entrances or sub-world screens — these are not "unreachable" by
                # normal play. Allow up to 10% of unreached screens as sub-world.
                sub_count = sum(
                    1 for s in chapter
                    if s.relative_index not in reached
                    and getattr(s, "content", 0) in {0xC0, 0xC7, 0xD7}
                )
                if (len(reached) + sub_count) < total:
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
) -> WorldPlan:
    """Build a WorldPlan that mirrors the templates, so the UI and spoiler
    have per-section section_type/screen_count information."""
    world_plan = WorldPlan(seed=seed)
    for chapter_num in sorted(templates):
        template = templates[chapter_num]
        sections: List[SectionPlan] = []
        for sec in template.sections:
            sections.append(SectionPlan(
                section_type=sec.section_type,
                section_id=sec.section_id,
                target_screen_count=sec.size,
                shape="organic",
                is_past=sec.is_past,
            ))
        world_plan.chapters.append(ChapterPlan(
            chapter_num=chapter_num,
            total_screens=sum(sec.size for sec in template.sections),
            sections=sections,
        ))
    return world_plan


def _connections_from_templates(
    seed: int,
    templates: Dict[int, ChapterTemplate],
) -> WorldConnections:
    """Build a WorldConnections so the Flow view has edges to draw.

    Draws one connection per unique (from_section, to_section) pair — the
    template keeps every directional edge that crossed a section boundary
    in the original ROM, which over-counts for UI purposes. Time-door
    bridges show up explicitly with method="time_door".
    """
    world = WorldConnections(seed=seed)
    for chapter_num in sorted(templates):
        template = templates[chapter_num]
        ch_conn = ChapterConnections(chapter_num=chapter_num)

        seen_pairs: set = set()
        for edge in template.inter_section_edges:
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
