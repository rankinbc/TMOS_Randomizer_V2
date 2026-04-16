"""The classic randomization strategy — six-phase pipeline.

Pipeline:
1. Planning     — section counts and sizes
2. Shaping      — section shapes
3. Connection   — connect sections
4. Population   — assign TileSections/ObjectSets
5. Navigation   — rewrite screen navigation
6. Validation   — legacy + new-framework checks
"""

from __future__ import annotations

import hashlib
from pathlib import Path
from typing import Any, Dict, Optional

from ..core.chapter import GameWorld
from ..io.rom_reader import load_rom
from ..io.rom_writer import patch_rom
from ..output.spoiler_log import SpoilerLog, SpoilerLogBuilder, write_spoiler_log
from ..phases.phase1_planning import plan_randomization, validate_plan
from ..phases.phase2_shaping import shape_world
from ..phases.phase3_connection import connect_world, validate_connections
from ..phases.phase4_population import populate_world, validate_population
from ..phases.phase5_navigation import rewrite_world_navigation, validate_navigation
from ..phases.phase6_validation import validate_randomization as validate_full_randomization
from ..plan import RandomizationPlan, RandomizationResult
from ..validation import ValidationPhase
from .base import RandomizationStrategy
from .registry import register_strategy


@register_strategy
class ClassicStrategy(RandomizationStrategy):
    """Classic six-phase randomizer (the original pipeline)."""

    name = "classic"
    description = "Six-phase pipeline: plan, shape, connect, populate, navigate, validate."

    def create_plan(self, seed: int) -> RandomizationPlan:
        # Phase 1: Planning
        world_plan = plan_randomization(self.config, seed=seed)

        # Phase 2: Shaping
        world_shape = shape_world(world_plan)

        # Phase 3: Connection
        world_connections = connect_world(
            world_plan,
            world_shape,
            topology=self.config.connectivity.topology,
            dungeon_last=self.config.connectivity.dungeon_last,
            randomize_order=self.config.connectivity.order_randomization,
        )

        plan = RandomizationPlan(
            seed=seed,
            config=self.config,
            world_plan=world_plan,
            world_shape=world_shape,
            world_connections=world_connections,
            strategy_name=self.name,
        )

        self._validate_plan(plan)
        return plan

    def preview_plan(self, plan, game_world, rom_data):
        """Apply the classic pipeline to an already-loaded game_world."""
        self._apply_plan_to_world(game_world, plan, rom_data)

    def apply_plan(
        self,
        input_rom: Path,
        output_rom: Path,
        plan: RandomizationPlan,
        generate_spoiler: bool,
    ) -> RandomizationResult:
        result = RandomizationResult(success=False, seed=plan.seed)

        if not plan.is_valid:
            result.errors = list(plan.validation_errors)
            return result

        try:
            game_world = load_rom(input_rom)

            with open(input_rom, "rb") as f:
                rom_data = f.read()

            modified_count = self._apply_plan_to_world(game_world, plan, rom_data)

            patch_rom(input_rom, output_rom, game_world)
            result.output_rom_path = output_rom

            with open(output_rom, "rb") as f:
                result.rom_sha256 = hashlib.sha256(f.read()).hexdigest()

            if generate_spoiler and self.config.output.spoiler_log_enabled:
                spoiler = self._generate_spoiler_log(plan, result.rom_sha256)
                result.spoiler_log = spoiler

                written_files = write_spoiler_log(
                    spoiler,
                    output_rom.parent,
                    text_filename=self.config.output.spoiler_text_filename,
                    json_filename=self.config.output.spoiler_json_filename,
                )
                result.spoiler_text_path = written_files.get("text")
                result.spoiler_json_path = written_files.get("json")

            result.stats = {
                "screens_modified": modified_count,
                "chapters_randomized": len(plan.world_plan.chapters),
                "strategy": self.name,
            }

            result.success = True
            result.warnings = list(plan.validation_warnings)

        except Exception as e:
            result.errors.append(str(e))

        return result

    # ------------------------------------------------------------------
    # Internals
    # ------------------------------------------------------------------

    def _validate_plan(self, plan: RandomizationPlan) -> None:
        errors = validate_plan(plan.world_plan)
        plan.validation_errors.extend(errors)

        for chapter_conn in plan.world_connections.chapters:
            chapter_plan = plan.world_plan.get_chapter(chapter_conn.chapter_num)
            if chapter_plan:
                errors = validate_connections(chapter_conn, chapter_plan)
                plan.validation_errors.extend(errors)

    def _apply_plan_to_world(
        self,
        game_world: GameWorld,
        plan: RandomizationPlan,
        rom_data: Optional[bytes] = None,
    ) -> int:
        modified_count = 0

        validation_context: Dict[str, Any] = {
            "world_plan": plan.world_plan,
            "world_shape": plan.world_shape,
            "world_connections": plan.world_connections,
        }
        if rom_data is not None:
            validation_context["rom_data"] = rom_data

        # Phase 4: Population
        world_population = populate_world(
            game_world=game_world,
            world_plan=plan.world_plan,
            world_shape=plan.world_shape,
            seed=plan.seed,
        )
        plan.world_population = world_population
        validation_context["world_population"] = world_population

        for chapter in game_world:
            chapter_population = world_population.get_chapter(chapter.chapter_num)
            if chapter_population:
                errors = validate_population(chapter, chapter_population)
                plan.validation_warnings.extend(errors)

        if self.validation_config.run_incremental:
            population_result = self.validation_runner.validate_incrementally(
                ValidationPhase.DURING_POPULATION,
                game_world,
                validation_context,
            )
            for issue in population_result.errors:
                plan.validation_errors.append(str(issue))
            for issue in population_result.warnings:
                plan.validation_warnings.append(str(issue))

        # Phase 5: Navigation
        world_navigation = rewrite_world_navigation(
            game_world=game_world,
            world_shape=plan.world_shape,
            world_connections=plan.world_connections,
            world_population=world_population,
            seed=plan.seed,
            preserve_buildings=True,
            rom_data=rom_data,
        )
        plan.world_navigation = world_navigation
        validation_context["world_navigation"] = world_navigation

        for chapter in game_world:
            chapter_nav = world_navigation.get_chapter(chapter.chapter_num)
            if chapter_nav:
                errors = validate_navigation(chapter, chapter_nav)
                plan.validation_warnings.extend(errors)

        if self.validation_config.run_incremental:
            navigation_result = self.validation_runner.validate_incrementally(
                ValidationPhase.DURING_NAVIGATION,
                game_world,
                validation_context,
            )
            for issue in navigation_result.errors:
                plan.validation_errors.append(str(issue))
            for issue in navigation_result.warnings:
                plan.validation_warnings.append(str(issue))

        # Phase 6: legacy final validation
        world_validation = validate_full_randomization(
            game_world=game_world,
            world_plan=plan.world_plan,
            world_shape=plan.world_shape,
            world_connections=plan.world_connections,
            world_population=world_population,
            world_navigation=world_navigation,
        )

        for issue in world_validation.get_all_errors():
            plan.validation_errors.append(issue.message)
        for issue in world_validation.get_all_warnings():
            plan.validation_warnings.append(issue.message)

        if self.validation_config.run_final:
            final_result = self.validation_runner.validate_final(
                game_world,
                validation_context,
            )
            for issue in final_result.errors:
                plan.validation_errors.append(str(issue))
            for issue in final_result.warnings:
                plan.validation_warnings.append(str(issue))

        for chapter_nav in world_navigation.chapters:
            modified_screens = set()
            for change in chapter_nav.navigation_changes:
                modified_screens.add(change.screen_index)
            for stairway in chapter_nav.stairway_changes:
                modified_screens.add(stairway.screen_a)
                modified_screens.add(stairway.screen_b)
            modified_count += len(modified_screens)

        return modified_count

    def _generate_spoiler_log(self, plan: RandomizationPlan, rom_sha256: str) -> SpoilerLog:
        builder = SpoilerLogBuilder(
            seed=plan.seed,
            preset=plan.config.difficulty.preset,
        )

        builder.set_rom_hash(rom_sha256)

        settings = {
            "strategy": self.name,
            "mode": plan.config.general.mode,
            "chapters": plan.config.general.chapters,
            "topology": plan.config.connectivity.topology,
            "dungeon_last": plan.config.connectivity.dungeon_last,
        }
        builder.set_settings(settings)

        for chapter_plan in plan.world_plan.chapters:
            builder.add_chapter_map(
                chapter_num=chapter_plan.chapter_num,
                screen_count=chapter_plan.total_screens,
                topology=plan.config.connectivity.topology,
            )

            for section in chapter_plan.sections:
                builder.add_section_to_chapter(
                    chapter_num=chapter_plan.chapter_num,
                    section_type=section.section_type.name.lower(),
                    screen_count=section.target_screen_count,
                    shape=section.shape,
                )

        for chapter_conn in plan.world_connections.chapters:
            for conn in chapter_conn.connections:
                builder.add_connection_to_chapter(
                    chapter_num=chapter_conn.chapter_num,
                    from_section=f"Section {conn.from_section_id}",
                    to_section=f"Section {conn.to_section_id}",
                    method=conn.method,
                    screen=conn.from_screen_id,
                )

        builder.add_interesting(
            f"Seed {plan.seed} generated with {self.name} strategy, "
            f"{plan.config.connectivity.topology} topology"
        )

        return builder.build()
