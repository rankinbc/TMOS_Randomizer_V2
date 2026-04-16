"""Validation configuration dataclasses.

This module defines the configuration schema for all validators.
Configuration can be loaded from YAML or set programmatically.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, Optional, Set

from .base import Severity


@dataclass
class EdgeCompatibilityConfig:
    """Configuration for edge compatibility validation.

    Edge compatibility ensures that connected screens have matching
    walkability patterns at their shared edges.

    Attributes:
        enabled: Whether to run this validator
        severity: Default severity for issues (error, warning, info)
        max_issues: Maximum issues to report (0=unlimited)
        min_walkable_tiles: Minimum walkable tiles required at edge
        check_horizontal: Validate left/right edges (6 tiles each)
        check_vertical: Validate top/bottom edges (8 tiles each)
        allow_hazard_to_hazard: Hazard tiles can connect to hazard tiles
        allow_collidable_to_collidable: Collidable can connect to collidable
    """

    enabled: bool = True
    severity: str = "error"
    max_issues: int = 100

    # Edge requirements
    min_walkable_tiles: int = 1
    check_horizontal: bool = True
    check_vertical: bool = True

    # Compatibility rules
    allow_hazard_to_hazard: bool = True
    allow_collidable_to_collidable: bool = True


@dataclass
class ScreenTraversabilityConfig:
    """Configuration for screen traversability validation.

    Screen traversability ensures the player can walk from entry
    points to exit points within each screen.

    Attributes:
        enabled: Whether to run this validator
        severity: Default severity for issues
        max_issues: Maximum issues to report (0=unlimited)
        algorithm: Pathfinding algorithm (bfs or astar)
        require_entry_to_exit: Require path from any entry to any exit
        allow_partial_exits: OK if some exits are unreachable

    Note: Tile walkability is now determined by category:
        - WALKABLE and HAZARDOUS (damages but doesn't kill) = traversable
        - DEADLY (water, lava) and COLLIDABLE = blocks movement
    """

    enabled: bool = True
    severity: str = "warning"
    max_issues: int = 100

    # Algorithm selection
    algorithm: str = "bfs"

    # What to validate
    require_entry_to_exit: bool = True
    allow_partial_exits: bool = True


@dataclass
class DataPointerObjectSetConfig:
    """Configuration for DataPointer-ObjectSet compatibility validation.

    Ensures ObjectSets are compatible with the screen's CHR bank
    to prevent sprite rendering corruption.

    Attributes:
        enabled: Whether to run this validator
        severity: Default severity for issues
        max_issues: Maximum issues to report (0=unlimited)
        strict_mode: Fail if ObjectSet not in known compatibility list
        allow_unknown_chr: Allow CHR indices not in our tables
    """

    enabled: bool = True
    severity: str = "error"
    max_issues: int = 100

    # Strictness
    strict_mode: bool = True
    allow_unknown_chr: bool = False


@dataclass
class NavigationConfig:
    """Configuration for navigation validation.

    Validates that navigation pointers are valid and bidirectional
    where expected.

    Attributes:
        enabled: Whether to run this validator
        severity: Default severity for issues
        require_bidirectional: Require A→B implies B→A
        allow_one_way_maze: Allow one-way paths in maze sections
    """

    enabled: bool = True
    severity: str = "error"

    require_bidirectional: bool = True
    allow_one_way_maze: bool = True


@dataclass
class ReachabilityConfig:
    """Configuration for reachability validation.

    Ensures all screens are reachable from the starting screen.

    Attributes:
        enabled: Whether to run this validator
        severity: Default severity for issues
        min_reachability_percent: Minimum % of screens that must be reachable
        check_critical_locations: Verify bosses/mosques are reachable
    """

    enabled: bool = True
    severity: str = "error"

    min_reachability_percent: float = 100.0
    check_critical_locations: bool = True


@dataclass
class TimePeriodIsolationConfig:
    """Configuration for time-period isolation validation.

    PAST and PRESENT are parallel worlds. The only sanctioned way for the
    player to cross between them is a Time Door. This validator flags any
    directional navigation pointer that crosses time periods from a non
    Time Door screen, and also verifies every populated section's screens
    all belong to one time period.

    Attributes:
        enabled: Whether to run this validator
        severity: Default severity for issues (error, warning, info)
        max_issues: Maximum issues to report (0=unlimited)
        check_section_membership: Also verify sections are time-period-pure
        allow_time_door_exceptions: Allow cross-time nav from Time Door screens
    """

    enabled: bool = True
    severity: str = "error"
    max_issues: int = 100

    check_section_membership: bool = True
    allow_time_door_exceptions: bool = True


@dataclass
class EdgeAlignmentConfig:
    """Configuration for edge-alignment validation.

    A navigation edge A→B is only truly walkable if at least one row/column
    index has a walkable tile on BOTH sides. The existing edge_compatibility
    validator only checks that each edge has *some* walkable tile — it can
    pass even when the walkable positions don't line up, trapping the player.

    Attributes:
        enabled: Whether to run this validator
        severity: Default severity for issues (error, warning, info)
        max_issues: Maximum issues to report (0=unlimited)
        min_aligned_walkable: Minimum aligned walkable positions required
        check_horizontal: Check left/right edges
        check_vertical: Check top/bottom edges
    """

    enabled: bool = True
    severity: str = "error"
    max_issues: int = 100

    min_aligned_walkable: int = 1
    check_horizontal: bool = True
    check_vertical: bool = True


@dataclass
class SectionFlowConfig:
    """Configuration for section flow validation.

    Ensures the actual navigation structure matches the planned section flow.
    This is critical for verifying the randomization actually works.

    Attributes:
        enabled: Whether to run this validator
        severity: Default severity for issues
        max_issues: Maximum issues to report (0=unlimited)
        max_fragments_per_section: Max fragments before ERROR (1=must be unified)
        require_inter_section_connections: Planned connections must exist
        auto_repair: Attempt to repair fragmented sections
        max_repair_attempts: Maximum repair iterations
    """

    enabled: bool = True
    severity: str = "error"
    max_issues: int = 100

    # Section unity requirements
    max_fragments_per_section: int = 1  # 1 = section must be one connected piece

    # Inter-section connection requirements
    require_inter_section_connections: bool = True

    # Repair settings
    auto_repair: bool = True
    max_repair_attempts: int = 10


@dataclass
class ValidationConfig:
    """Complete validation configuration.

    This is the top-level configuration for the validation framework.
    It contains global settings and per-validator configurations.

    Attributes:
        stop_on_first_error: Stop validation after first ERROR
        max_issues_per_validator: Limit issues per validator (0=unlimited)
        run_incremental: Run validators during generation phases
        run_final: Run complete validation at end
        enabled_validators: Only run these validators (None=all)
        disabled_validators: Never run these validators
        severity_overrides: Override severity by validator_id
    """

    # Global settings
    stop_on_first_error: bool = False
    max_issues_per_validator: int = 100
    run_incremental: bool = True
    run_final: bool = True

    # Per-validator configurations
    edge_compatibility: EdgeCompatibilityConfig = field(
        default_factory=EdgeCompatibilityConfig
    )
    screen_traversability: ScreenTraversabilityConfig = field(
        default_factory=ScreenTraversabilityConfig
    )
    datapointer_objectset: DataPointerObjectSetConfig = field(
        default_factory=DataPointerObjectSetConfig
    )
    navigation: NavigationConfig = field(
        default_factory=NavigationConfig
    )
    reachability: ReachabilityConfig = field(
        default_factory=ReachabilityConfig
    )
    section_flow: SectionFlowConfig = field(
        default_factory=SectionFlowConfig
    )
    time_period_isolation: TimePeriodIsolationConfig = field(
        default_factory=TimePeriodIsolationConfig
    )
    edge_alignment: EdgeAlignmentConfig = field(
        default_factory=EdgeAlignmentConfig
    )

    # Validator enable/disable overrides
    enabled_validators: Optional[Set[str]] = None  # None = all enabled
    disabled_validators: Set[str] = field(default_factory=set)

    # Severity overrides by validator_id
    severity_overrides: Dict[str, str] = field(default_factory=dict)

    def is_validator_enabled(self, validator_id: str) -> bool:
        """Check if a specific validator is enabled.

        Args:
            validator_id: The validator's unique ID

        Returns:
            True if the validator should run
        """
        # Check explicit disable list
        if validator_id in self.disabled_validators:
            return False

        # Check explicit enable list
        if self.enabled_validators is not None:
            return validator_id in self.enabled_validators

        # Check validator-specific config
        config_map = {
            "edge_compatibility": self.edge_compatibility,
            "screen_traversability": self.screen_traversability,
            "datapointer_objectset": self.datapointer_objectset,
            "navigation": self.navigation,
            "reachability": self.reachability,
            "section_flow": self.section_flow,
            "time_period_isolation": self.time_period_isolation,
            "edge_alignment": self.edge_alignment,
        }

        if validator_id in config_map:
            return config_map[validator_id].enabled

        # Unknown validators are enabled by default
        return True

    def get_severity_override(self, validator_id: str) -> Optional[Severity]:
        """Get severity override for a validator.

        Args:
            validator_id: The validator's unique ID

        Returns:
            Severity override if set, None otherwise
        """
        if validator_id in self.severity_overrides:
            return Severity(self.severity_overrides[validator_id])

        # Check validator-specific config
        config_map = {
            "edge_compatibility": self.edge_compatibility,
            "screen_traversability": self.screen_traversability,
            "datapointer_objectset": self.datapointer_objectset,
            "navigation": self.navigation,
            "reachability": self.reachability,
            "section_flow": self.section_flow,
            "time_period_isolation": self.time_period_isolation,
            "edge_alignment": self.edge_alignment,
        }

        if validator_id in config_map:
            specific = config_map[validator_id]
            if hasattr(specific, "severity"):
                return Severity(specific.severity)

        return None

    def get_validator_parameters(self, validator_id: str) -> Dict[str, Any]:
        """Get parameters for a specific validator.

        Args:
            validator_id: The validator's unique ID

        Returns:
            Dictionary of validator-specific parameters
        """
        config_map = {
            "edge_compatibility": self.edge_compatibility,
            "screen_traversability": self.screen_traversability,
            "datapointer_objectset": self.datapointer_objectset,
            "navigation": self.navigation,
            "reachability": self.reachability,
            "section_flow": self.section_flow,
            "time_period_isolation": self.time_period_isolation,
            "edge_alignment": self.edge_alignment,
        }

        if validator_id not in config_map:
            return {}

        specific = config_map[validator_id]
        params = {}

        for key, value in vars(specific).items():
            if key not in ("enabled", "severity"):
                params[key] = value

        return params

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "ValidationConfig":
        """Create ValidationConfig from a dictionary.

        Args:
            data: Dictionary with validation configuration

        Returns:
            New ValidationConfig instance
        """
        config = cls()

        # Global settings
        if "stop_on_first_error" in data:
            config.stop_on_first_error = data["stop_on_first_error"]
        if "max_issues_per_validator" in data:
            config.max_issues_per_validator = data["max_issues_per_validator"]
        if "run_incremental" in data:
            config.run_incremental = data["run_incremental"]
        if "run_final" in data:
            config.run_final = data["run_final"]
        if "disabled_validators" in data:
            config.disabled_validators = set(data["disabled_validators"])
        if "enabled_validators" in data:
            config.enabled_validators = set(data["enabled_validators"])
        if "severity_overrides" in data:
            config.severity_overrides = data["severity_overrides"]

        # Per-validator configs
        if "edge_compatibility" in data:
            config.edge_compatibility = EdgeCompatibilityConfig(
                **data["edge_compatibility"]
            )
        if "screen_traversability" in data:
            config.screen_traversability = ScreenTraversabilityConfig(
                **data["screen_traversability"]
            )
        if "datapointer_objectset" in data:
            config.datapointer_objectset = DataPointerObjectSetConfig(
                **data["datapointer_objectset"]
            )
        if "navigation" in data:
            config.navigation = NavigationConfig(**data["navigation"])
        if "reachability" in data:
            config.reachability = ReachabilityConfig(**data["reachability"])
        if "section_flow" in data:
            config.section_flow = SectionFlowConfig(**data["section_flow"])
        if "time_period_isolation" in data:
            config.time_period_isolation = TimePeriodIsolationConfig(
                **data["time_period_isolation"]
            )
        if "edge_alignment" in data:
            config.edge_alignment = EdgeAlignmentConfig(**data["edge_alignment"])

        return config

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization.

        Returns:
            Dictionary representation
        """
        return {
            "stop_on_first_error": self.stop_on_first_error,
            "max_issues_per_validator": self.max_issues_per_validator,
            "run_incremental": self.run_incremental,
            "run_final": self.run_final,
            "disabled_validators": list(self.disabled_validators),
            "enabled_validators": list(self.enabled_validators) if self.enabled_validators else None,
            "severity_overrides": self.severity_overrides,
            "edge_compatibility": vars(self.edge_compatibility),
            "screen_traversability": vars(self.screen_traversability),
            "datapointer_objectset": vars(self.datapointer_objectset),
            "navigation": vars(self.navigation),
            "reachability": vars(self.reachability),
            "section_flow": vars(self.section_flow),
            "time_period_isolation": vars(self.time_period_isolation),
            "edge_alignment": vars(self.edge_alignment),
        }
