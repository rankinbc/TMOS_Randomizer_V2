"""Shared data contracts for randomization strategies.

Defines the RandomizationPlan and RandomizationResult dataclasses — the
common input/output shape every strategy produces and consumes. Lives
outside randomizer.py so strategy modules can import these types without
causing a circular dependency with the Randomizer orchestrator.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional

from .io.config_loader import RandomizerConfig
from .output.spoiler_log import SpoilerLog
from .phases.phase1_planning import WorldPlan
from .phases.phase2_shaping import WorldShape
from .phases.phase3_connection import WorldConnections
from .phases.phase4_population import WorldPopulation
from .phases.phase5_navigation import WorldNavigation


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

    # Strategy that produced this plan (for spoiler log / debugging)
    strategy_name: str = "classic"

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
            "strategy": self.strategy_name,
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
