"""V1 randomizer ported as a V2 strategy. See
docs/superpowers/specs/2026-06-24-tmos-randomizer-v1-strategy-design.md.
"""
from __future__ import annotations

import hashlib
import logging
from pathlib import Path
from typing import TYPE_CHECKING, Optional

from ..base import RandomizationStrategy
from ..registry import register_strategy
from ...io.rom_reader import load_rom
from ...io.rom_writer import patch_rom
from ...phases.phase1_planning import plan_randomization
from ...phases.phase2_shaping import shape_world
from ...phases.phase3_connection import connect_world
from ...phases.phase6_validation import analyze_reachability
from ...plan import RandomizationPlan, RandomizationResult
from .core import run_v1, V1Outcome
from .tweaks import apply_tweaks

if TYPE_CHECKING:
    from ...core.chapter import GameWorld

logger = logging.getLogger(__name__)


@register_strategy
class TmosRandomizerV1(RandomizationStrategy):
    name = "tmos_randomizer_v1"
    description = (
        "Original V1 randomizer: content / object-set / encounter shuffle with "
        "brute-force validity gates. Reliable playable baseline."
    )

    def create_plan(self, seed: int) -> RandomizationPlan:
        # Build the required plan shell via phases 1-3 (lab-adapter pattern).
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

    def preview_plan(self, plan, game_world, rom_data) -> None:
        max_retries = int(self.config.get("v1.max_retries", 1000))
        outcome = run_v1(game_world, rom_data or b"", plan.seed, max_retries)
        self._last_outcome: V1Outcome = outcome

        if not outcome.success:
            msg = "V1 gates failed after %d attempts: %s" % (
                outcome.attempts, "; ".join(outcome.failures[:5]) or "unknown")
            plan.validation_errors.append(msg)
            raise RuntimeError(msg)

        # V2 navigability oracle (informational: V1 never edits nav bytes).
        for chapter in game_world:
            if chapter.screen_count == 0:
                continue
            res = analyze_reachability(chapter, starting_screen=0)
            if res.unreachable_screens:
                plan.validation_warnings.append(
                    f"chapter {chapter.chapter_num}: "
                    f"{len(res.unreachable_screens)} screen(s) unreachable from start"
                )
        plan.validation_warnings.append(
            f"v1: solved on seed {outcome.winning_seed} in {outcome.attempts} attempt(s)"
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
            outcome: V1Outcome = self._last_outcome

            # 1) Write mutated screens.
            patch_rom(input_rom, output_rom, game_world)

            # 2) Apply encounter + tweak byte-patches to the output file.
            with open(output_rom, "rb") as f:
                data = bytearray(f.read())
            for offset, value in outcome.lineup_patches:
                data[offset] = value
            for offset, value in outcome.group_patches:
                data[offset] = value
            if self.config.get("v1.apply_tweaks", True):
                apply_tweaks(data, outcome.winning_seed)
            with open(output_rom, "wb") as f:
                f.write(data)

            result.output_rom_path = output_rom
            result.rom_sha256 = hashlib.sha256(bytes(data)).hexdigest()
            result.stats = {
                "strategy": self.name,
                "winning_seed": outcome.winning_seed,
                "attempts": outcome.attempts,
                "lineup_patches": len(outcome.lineup_patches),
                "group_patches": len(outcome.group_patches),
                "tweaks_applied": bool(self.config.get("v1.apply_tweaks", True)),
            }
            result.warnings = list(plan.validation_warnings)
            result.success = True
        except Exception as e:  # noqa: BLE001 - surface to caller as result.errors
            result.errors.append(str(e))
        return result
