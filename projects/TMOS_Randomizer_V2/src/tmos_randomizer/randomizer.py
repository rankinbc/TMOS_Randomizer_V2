"""Main randomizer orchestrator.

Coordinates all phases of randomization:
1. Planning - Determine section counts and sizes
2. Shaping - Generate section shapes
3. Connection - Connect sections together
4. Population - Assign TileSections and ObjectSets
5. Content - Place items, allies, shops
6. Validation - Verify randomization is valid
"""

from __future__ import annotations

import hashlib
import random
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Union

from .core.chapter import GameWorld
from .core.enums import SectionType
from .io.config_loader import RandomizerConfig, get_default_config, load_config
from .io.rom_reader import load_rom
from .io.rom_writer import patch_rom
from .output.spoiler_log import SpoilerLog, SpoilerLogBuilder, write_spoiler_log
from .phases.phase1_planning import WorldPlan, plan_randomization, validate_plan
from .phases.phase2_shaping import WorldShape, shape_world
from .phases.phase3_connection import WorldConnections, connect_world, validate_connections
from .phases.phase4_population import (
    WorldPopulation,
    populate_world,
    validate_population,
)
from .phases.phase5_navigation import (
    WorldNavigation,
    rewrite_world_navigation,
    validate_navigation,
)
from .phases.phase6_validation import (
    WorldValidation,
    validate_randomization as validate_full_randomization,
)

# Import new validation framework
from .validation import (
    ValidationRunner,
    ValidationConfig,
    ValidationPhase,
    ValidationResult,
    Severity,
)


# =============================================================================
# Randomization Plan (combined output of all phases)
# =============================================================================

@dataclass
class RandomizationPlan:
    """Complete randomization plan before applying to ROM.

    This is the primary data structure for UI visualization.
    Contains all information about what will be changed.
    """

    seed: int
    config: RandomizerConfig
    world_plan: WorldPlan
    world_shape: WorldShape
    world_connections: WorldConnections

    # Population data (phase 4)
    world_population: Optional[WorldPopulation] = None

    # Navigation data (phase 5)
    world_navigation: Optional[WorldNavigation] = None

    # Additional randomization data (populated in later phases)
    tilesection_assignments: Dict[int, Dict[int, int]] = field(default_factory=dict)
    objectset_assignments: Dict[int, Dict[int, int]] = field(default_factory=dict)
    item_placements: List[Dict[str, Any]] = field(default_factory=list)
    ally_placements: List[Dict[str, Any]] = field(default_factory=list)

    # Validation results
    validation_errors: List[str] = field(default_factory=list)
    validation_warnings: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary for JSON/UI."""
        return {
            "seed": self.seed,
            "world_plan": self.world_plan.to_dict(),
            "world_shape": self.world_shape.to_dict(),
            "world_connections": self.world_connections.to_dict(),
            "world_population": self.world_population.to_dict() if self.world_population else None,
            "world_navigation": self.world_navigation.to_dict() if self.world_navigation else None,
            "tilesection_assignments": self.tilesection_assignments,
            "objectset_assignments": self.objectset_assignments,
            "item_placements": self.item_placements,
            "ally_placements": self.ally_placements,
            "validation_errors": self.validation_errors,
            "validation_warnings": self.validation_warnings,
        }

    @property
    def is_valid(self) -> bool:
        """Check if the plan is valid (no errors)."""
        return len(self.validation_errors) == 0


@dataclass
class RandomizationResult:
    """Result of applying randomization to a ROM."""

    success: bool
    seed: int
    output_rom_path: Optional[Path] = None
    spoiler_log: Optional[SpoilerLog] = None
    spoiler_text_path: Optional[Path] = None
    spoiler_json_path: Optional[Path] = None
    rom_sha256: str = ""
    errors: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    stats: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "success": self.success,
            "seed": self.seed,
            "output_rom_path": str(self.output_rom_path) if self.output_rom_path else None,
            "spoiler_text_path": str(self.spoiler_text_path) if self.spoiler_text_path else None,
            "spoiler_json_path": str(self.spoiler_json_path) if self.spoiler_json_path else None,
            "rom_sha256": self.rom_sha256,
            "errors": self.errors,
            "warnings": self.warnings,
            "stats": self.stats,
        }


# =============================================================================
# Main Randomizer Class
# =============================================================================

class Randomizer:
    """Main randomizer orchestrator.

    Usage:
        randomizer = Randomizer(config)
        plan = randomizer.create_plan(seed=12345)

        # UI can display plan.to_dict() here

        if plan.is_valid:
            result = randomizer.apply(input_rom, output_rom, plan)
    """

    def __init__(
        self,
        config: Optional[RandomizerConfig] = None,
        validation_config: Optional[ValidationConfig] = None,
    ):
        """Initialize randomizer.

        Args:
            config: Randomization configuration (uses defaults if None)
            validation_config: Validation configuration (uses defaults if None)
        """
        self.config = config or get_default_config()
        self.validation_config = validation_config or ValidationConfig()
        self._rng: Optional[random.Random] = None
        self._validation_runner: Optional[ValidationRunner] = None

    @property
    def validation_runner(self) -> ValidationRunner:
        """Get the validation runner, creating it if needed."""
        if self._validation_runner is None:
            self._validation_runner = ValidationRunner(self.validation_config)
        return self._validation_runner

    @classmethod
    def from_config_file(cls, config_path: Union[str, Path]) -> "Randomizer":
        """Create randomizer from config file.

        Args:
            config_path: Path to YAML config file

        Returns:
            Configured Randomizer instance
        """
        config = load_config(config_path)
        return cls(config)

    def create_plan(self, seed: Optional[int] = None) -> RandomizationPlan:
        """Create a randomization plan without modifying any ROM.

        This is the main entry point for UI-driven randomization.
        The plan can be inspected/visualized before applying.

        Args:
            seed: Random seed (generates one if None or 0)

        Returns:
            RandomizationPlan ready for inspection or application
        """
        # Determine seed
        actual_seed = seed if seed and seed != 0 else random.randint(1, 2**31 - 1)
        self._rng = random.Random(actual_seed)

        # Phase 1: Planning
        world_plan = plan_randomization(self.config, seed=actual_seed)

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

        # Create plan
        plan = RandomizationPlan(
            seed=actual_seed,
            config=self.config,
            world_plan=world_plan,
            world_shape=world_shape,
            world_connections=world_connections,
        )

        # Validate
        self._validate_plan(plan)

        return plan

    def _validate_plan(self, plan: RandomizationPlan) -> None:
        """Validate the randomization plan.

        Args:
            plan: Plan to validate (modified in place)
        """
        # Validate phase 1
        errors = validate_plan(plan.world_plan)
        plan.validation_errors.extend(errors)

        # Validate phase 3 connections
        for chapter_conn in plan.world_connections.chapters:
            chapter_plan = plan.world_plan.get_chapter(chapter_conn.chapter_num)
            if chapter_plan:
                errors = validate_connections(chapter_conn, chapter_plan)
                plan.validation_errors.extend(errors)

    def apply(
        self,
        input_rom: Union[str, Path],
        output_rom: Union[str, Path],
        plan: RandomizationPlan,
        generate_spoiler: bool = True,
    ) -> RandomizationResult:
        """Apply a randomization plan to a ROM.

        Args:
            input_rom: Path to input ROM file
            output_rom: Path for output ROM file
            plan: RandomizationPlan to apply
            generate_spoiler: Whether to generate spoiler log

        Returns:
            RandomizationResult with paths and status
        """
        input_path = Path(input_rom)
        output_path = Path(output_rom)

        result = RandomizationResult(
            success=False,
            seed=plan.seed,
        )

        # Check plan validity
        if not plan.is_valid:
            result.errors = plan.validation_errors
            return result

        try:
            # Load ROM
            game_world = load_rom(input_path)

            # Read raw ROM bytes for tile validation
            with open(input_path, "rb") as f:
                rom_data = f.read()

            # Apply randomization
            modified_count = self._apply_plan_to_world(game_world, plan, rom_data)

            # Write output ROM
            written = patch_rom(input_path, output_path, game_world)
            result.output_rom_path = output_path

            # Calculate ROM hash
            with open(output_path, "rb") as f:
                result.rom_sha256 = hashlib.sha256(f.read()).hexdigest()

            # Generate spoiler log
            if generate_spoiler and self.config.output.spoiler_log_enabled:
                spoiler = self._generate_spoiler_log(plan, result.rom_sha256)
                result.spoiler_log = spoiler

                # Write spoiler files
                spoiler_dir = output_path.parent
                written_files = write_spoiler_log(
                    spoiler,
                    spoiler_dir,
                    text_filename=self.config.output.spoiler_text_filename,
                    json_filename=self.config.output.spoiler_json_filename,
                )
                result.spoiler_text_path = written_files.get("text")
                result.spoiler_json_path = written_files.get("json")

            # Collect stats
            result.stats = {
                "screens_modified": modified_count,
                "chapters_randomized": len(plan.world_plan.chapters),
            }

            result.success = True
            result.warnings = plan.validation_warnings

        except Exception as e:
            result.errors.append(str(e))

        return result

    def _apply_plan_to_world(
        self,
        game_world: GameWorld,
        plan: RandomizationPlan,
        rom_data: Optional[bytes] = None,
    ) -> int:
        """Apply randomization plan to game world.

        Args:
            game_world: GameWorld to modify
            plan: Plan to apply
            rom_data: Optional ROM bytes for tile validation

        Returns:
            Number of screens modified
        """
        modified_count = 0

        # Build validation context
        validation_context: Dict[str, Any] = {
            "world_plan": plan.world_plan,
            "world_shape": plan.world_shape,
            "world_connections": plan.world_connections,
        }
        if rom_data is not None:
            validation_context["rom_data"] = rom_data

        # Phase 4: Population - Assign screens to sections
        world_population = populate_world(
            game_world=game_world,
            world_plan=plan.world_plan,
            world_shape=plan.world_shape,
            seed=plan.seed,
        )
        plan.world_population = world_population
        validation_context["world_population"] = world_population

        # Legacy population validation
        for chapter in game_world:
            chapter_population = world_population.get_chapter(chapter.chapter_num)
            if chapter_population:
                errors = validate_population(chapter, chapter_population)
                plan.validation_warnings.extend(errors)

        # New framework: Incremental validation after population
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

        # Phase 5: Navigation - Rewrite screen navigation
        world_navigation = rewrite_world_navigation(
            game_world=game_world,
            world_shape=plan.world_shape,
            world_connections=plan.world_connections,
            world_population=world_population,
            seed=plan.seed,
            preserve_buildings=True,
        )
        plan.world_navigation = world_navigation
        validation_context["world_navigation"] = world_navigation

        # Legacy navigation validation
        for chapter in game_world:
            chapter_nav = world_navigation.get_chapter(chapter.chapter_num)
            if chapter_nav:
                errors = validate_navigation(chapter, chapter_nav)
                plan.validation_warnings.extend(errors)

        # New framework: Incremental validation after navigation
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

        # Phase 6: Legacy final validation
        world_validation = validate_full_randomization(
            game_world=game_world,
            world_plan=plan.world_plan,
            world_shape=plan.world_shape,
            world_connections=plan.world_connections,
            world_population=world_population,
            world_navigation=world_navigation,
        )

        # Collect legacy validation issues
        for issue in world_validation.get_all_errors():
            plan.validation_errors.append(issue.message)
        for issue in world_validation.get_all_warnings():
            plan.validation_warnings.append(issue.message)

        # New framework: Final validation pass
        if self.validation_config.run_final:
            final_result = self.validation_runner.validate_final(
                game_world,
                validation_context,
            )
            for issue in final_result.errors:
                plan.validation_errors.append(str(issue))
            for issue in final_result.warnings:
                plan.validation_warnings.append(str(issue))

        # Count modified screens
        for chapter_nav in world_navigation.chapters:
            # Count unique screens that had navigation changes
            modified_screens = set()
            for change in chapter_nav.navigation_changes:
                modified_screens.add(change.screen_index)
            for stairway in chapter_nav.stairway_changes:
                modified_screens.add(stairway.screen_a)
                modified_screens.add(stairway.screen_b)
            modified_count += len(modified_screens)

        return modified_count

    def _generate_spoiler_log(self, plan: RandomizationPlan, rom_sha256: str) -> SpoilerLog:
        """Generate spoiler log from plan.

        Args:
            plan: Randomization plan
            rom_sha256: SHA256 hash of output ROM

        Returns:
            SpoilerLog object
        """
        builder = SpoilerLogBuilder(
            seed=plan.seed,
            preset=plan.config.difficulty.preset,
        )

        builder.set_rom_hash(rom_sha256)

        # Add settings
        settings = {
            "mode": plan.config.general.mode,
            "chapters": plan.config.general.chapters,
            "topology": plan.config.connectivity.topology,
            "dungeon_last": plan.config.connectivity.dungeon_last,
        }
        builder.set_settings(settings)

        # Add map layout info
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

        # Add connections
        for chapter_conn in plan.world_connections.chapters:
            for conn in chapter_conn.connections:
                builder.add_connection_to_chapter(
                    chapter_num=chapter_conn.chapter_num,
                    from_section=f"Section {conn.from_section_id}",
                    to_section=f"Section {conn.to_section_id}",
                    method=conn.method,
                    screen=conn.from_screen_id,
                )

        # Add placeholder item/ally info (will be populated by later phases)
        # For now, just add some interesting notes
        builder.add_interesting(f"Seed {plan.seed} generated with {plan.config.connectivity.topology} topology")

        return builder.build()


# =============================================================================
# Convenience Functions
# =============================================================================

def randomize(
    input_rom: Union[str, Path],
    output_rom: Union[str, Path],
    config: Optional[Union[RandomizerConfig, str, Path]] = None,
    seed: Optional[int] = None,
) -> RandomizationResult:
    """Convenience function to randomize a ROM in one call.

    Args:
        input_rom: Path to input ROM
        output_rom: Path for output ROM
        config: Config object or path to config file (uses defaults if None)
        seed: Random seed (generates one if None)

    Returns:
        RandomizationResult with status and paths
    """
    # Load config
    if config is None:
        cfg = get_default_config()
    elif isinstance(config, (str, Path)):
        cfg = load_config(config)
    else:
        cfg = config

    # Create randomizer and run
    randomizer = Randomizer(cfg)
    plan = randomizer.create_plan(seed)
    return randomizer.apply(input_rom, output_rom, plan)


def preview_randomization(
    config: Optional[Union[RandomizerConfig, str, Path]] = None,
    seed: Optional[int] = None,
) -> RandomizationPlan:
    """Preview what randomization would do without modifying any ROM.

    Args:
        config: Config object or path to config file
        seed: Random seed

    Returns:
        RandomizationPlan that can be inspected
    """
    # Load config
    if config is None:
        cfg = get_default_config()
    elif isinstance(config, (str, Path)):
        cfg = load_config(config)
    else:
        cfg = config

    randomizer = Randomizer(cfg)
    return randomizer.create_plan(seed)
