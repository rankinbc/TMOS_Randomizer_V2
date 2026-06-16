"""Adapter that wraps TMOS Strategy Lab strategies as V2 RandomizationStrategies.

The Lab's ``LabStrategy`` protocol (``generate(ctx, seed) -> Candidate``) is
intentionally thinner than V2's full ``RandomizationStrategy``. This module
bridges the two so Lab strategies become selectable from the web UI and CLI
without modifying the Lab project.

Scope: Lab strategies that produce fully-populated ``WorldScreen`` dicts
(tileshuffle, identity). Layout-rewriting Lab strategies that expect V2's
nav-rewrite to run after them would need additional plumbing in
``preview_plan`` and are out of scope here.
"""

from __future__ import annotations

import hashlib
import logging
from pathlib import Path
from typing import TYPE_CHECKING, Optional

from ..io.rom_reader import load_rom
from ..io.rom_writer import patch_rom
from ..phases.phase1_planning import plan_randomization
from ..phases.phase2_shaping import shape_world
from ..phases.phase3_connection import connect_world
from ..plan import RandomizationPlan, RandomizationResult
from ..repair.reachability_repair import WorldRepairReport, repair_reachability
from .base import RandomizationStrategy
from .registry import register_strategy

if TYPE_CHECKING:
    from ..core.chapter import GameWorld
    from ..core.worldscreen import WorldScreen

logger = logging.getLogger(__name__)


class LabAdapterStrategy(RandomizationStrategy):
    """Base adapter. Subclass and set ``lab_strategy_name`` to register."""

    lab_strategy_name: str = ""
    # Layout-rewriting strategies (e.g. grow) produce under-reaching worlds that the
    # generic reachability-repair pass connects to 100%. Nav-preserving strategies
    # (identity, tileshuffle) must NOT repair: they'd "fix" vanilla's progression-gated
    # reachability up to 100%, corrupting their pass-through/graph-preserving semantics.
    repairs_reachability: bool = False

    def create_plan(self, seed: int) -> RandomizationPlan:
        world_plan = plan_randomization(self.config, seed=seed)
        world_shape = shape_world(world_plan)
        world_connections = connect_world(
            world_plan,
            world_shape,
            topology=self.config.connectivity.topology,
            dungeon_last=self.config.connectivity.dungeon_last,
            randomize_order=self.config.connectivity.order_randomization,
        )
        return RandomizationPlan(
            seed=seed,
            config=self.config,
            world_plan=world_plan,
            world_shape=world_shape,
            world_connections=world_connections,
            strategy_name=self.name,
        )

    def preview_plan(
        self,
        plan: RandomizationPlan,
        game_world: "GameWorld",
        rom_data: bytes,
    ) -> None:
        from tmos_strategy_lab.context import LabContext
        from tmos_strategy_lab.registry import get_strategy as get_lab_strategy

        # Import the Lab strategy package so its @register_strategy runs.
        self._ensure_lab_strategy_imported()

        lab_cls = get_lab_strategy(self.lab_strategy_name)
        lab_strategy = lab_cls()

        rom_md5 = hashlib.md5(rom_data).hexdigest() if rom_data else None
        ctx = LabContext(
            game_world=game_world,
            rom_bytes=rom_data or None,
            source=f"live-preview:{self.lab_strategy_name}",
            rom_md5=rom_md5,
        )

        candidate = lab_strategy.generate(ctx, plan.seed)
        _stamp_candidate_onto_world(candidate, game_world)

        # Reachability guarantee. For layout-rewriting strategies (grow), run the generic
        # reachability-repair pass: it drives every chapter to 100% reachable (warp-aware)
        # by least-damage, 0xFE-preserving edits — an absolute floor that supersedes the
        # old "no worse than vanilla" reseed gate (a differential one). Needs the ROM bytes
        # for edge extraction; a ROM-less preview simply skips repair.
        self._last_repair_report: Optional[WorldRepairReport] = None
        if self.repairs_reachability and rom_data:
            report = repair_reachability(game_world, rom_data)
            self._last_repair_report = report
            if report.total_unrepaired:
                raise RuntimeError(
                    f"Reachability repair could not fully connect "
                    f"'{self.lab_strategy_name}' output: {report.total_unrepaired} "
                    f"screen(s) remain unreachable across "
                    f"{len(report.chapters)} chapter(s)."
                )
            logger.info(
                "Lab adapter '%s': repair connected all chapters to 100%% "
                "(%d repairs).", self.lab_strategy_name, report.total_records,
            )

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

            self.preview_plan(plan, game_world, rom_data)

            patch_rom(input_rom, output_rom, game_world)
            result.output_rom_path = output_rom

            with open(output_rom, "rb") as f:
                result.rom_sha256 = hashlib.sha256(f.read()).hexdigest()

            modified = sum(
                1
                for chapter in game_world
                for screen in chapter.screens
                if screen.is_modified
            )
            result.stats = {
                "screens_modified": modified,
                "chapters_randomized": len(game_world.chapters),
                "strategy": self.name,
                "lab_strategy": self.lab_strategy_name,
            }
            report = getattr(self, "_last_repair_report", None)
            if report is not None:
                result.stats["repair_records"] = report.total_records
                result.stats["repair_unrepaired"] = report.total_unrepaired
            result.success = True
        except Exception as e:
            result.errors.append(str(e))
        return result

    # ------------------------------------------------------------------

    def _ensure_lab_strategy_imported(self) -> None:
        """Force-import the Lab strategy subpackage so @register_strategy runs.

        The Lab uses side-effect registration; importing the leaf module is
        what binds the name into its registry.
        """
        import importlib
        importlib.import_module(
            f"tmos_strategy_lab.strategies.{self.lab_strategy_name}"
        )


# =============================================================================
# Helpers
# =============================================================================

_ROM_FIELDS = (
    "parent_world", "ambient_sound", "content", "objectset",
    "screen_index_right", "screen_index_left",
    "screen_index_down", "screen_index_up",
    "datapointer", "exit_position",
    "top_tiles", "bottom_tiles",
    "worldscreen_color", "sprites_color", "unknown", "event",
)


def _stamp_candidate_onto_world(candidate, game_world: "GameWorld") -> None:
    """Copy each Candidate screen dict into the matching live WorldScreen."""
    for ch_num, screen_dicts in candidate.chapters.items():
        chapter = game_world.chapters.get(int(ch_num))
        if chapter is None:
            continue
        by_rel: dict[int, "WorldScreen"] = {
            s.relative_index: s for s in chapter.screens
        }
        for d in screen_dicts:
            scr = by_rel.get(d["relative_index"])
            if scr is None:
                continue
            changed = False
            for field_name in _ROM_FIELDS:
                new_val = d.get(field_name, getattr(scr, field_name))
                if getattr(scr, field_name) != new_val:
                    setattr(scr, field_name, new_val)
                    changed = True
            if changed:
                scr.mark_modified()


def _reach_counts(game_world: "GameWorld") -> dict[int, int]:
    """Per-chapter count of screens reachable from screen 0.

    Single source of truth: delegates to the oracle's ``analyze_reachability`` so the
    shippability GATE and the oracle VERDICT agree on what "reachable" means. That
    function follows directed nav (excluding the 0xFE building-entrance and 0xFF
    blocked sentinels) AND stairway warps (Event 0x40 -> Content destination), which
    the real game uses. Previously this gate was a warp-blind directed BFS — strictly
    stricter than the oracle it feeds — which rejected era-safe Lab output the oracle
    would have accepted (see test_lab_adapter_reach). We still don't claim this equals
    "playable world"; we only require post-mutation reachability to be no smaller than
    before, judged by the same yardstick the oracle uses.
    """
    from ..phases.phase6_validation import analyze_reachability

    counts: dict[int, int] = {}
    for chapter in game_world:
        if chapter.screen_count == 0:
            counts[chapter.chapter_num] = 0
            continue
        result = analyze_reachability(chapter, starting_screen=0)
        counts[chapter.chapter_num] = len(result.reachable_screens)
    return counts


# =============================================================================
# Registered adapters
# =============================================================================


@register_strategy
class TileShuffleAdapter(LabAdapterStrategy):
    """Lab 'tileshuffle' — graph-preserving (top_tiles, bottom_tiles) shuffle."""

    name = "lab_tileshuffle"
    description = (
        "Lab tileshuffle: graph-preserving shuffle of tile pairs within "
        "(chapter, section_type, datapointer) buckets. Navigation unchanged."
    )
    lab_strategy_name = "tileshuffle"


@register_strategy
class IdentityAdapter(LabAdapterStrategy):
    """Lab 'identity' — pass-through (validation baseline / smoke test)."""

    name = "lab_identity"
    description = "Lab identity: returns the ROM unchanged. Useful as a baseline."
    lab_strategy_name = "identity"


@register_strategy
class GrowAdapter(LabAdapterStrategy):
    """Lab 'grow' (v0.2.0+) — satisfiability-driven growth with navigable output.

    Grows each section from a seed screen, only placing candidates whose edges
    align with all placed grid-neighbors (0 broken edges by construction), then
    writes the grown layout into navigation + inter-section links. The base
    adapter's reachability gate enforces 'no worse than vanilla'.
    """

    name = "lab_grow"
    description = (
        "Lab grow: zero-broken-edge section growth, written to navigation with "
        "inter-section linking, then the reachability-repair pass connects every "
        "chapter to 100% reachable (0xFE-preserving)."
    )
    lab_strategy_name = "grow"
    repairs_reachability = True


__all__ = [
    "LabAdapterStrategy",
    "TileShuffleAdapter",
    "IdentityAdapter",
    "GrowAdapter",
]
