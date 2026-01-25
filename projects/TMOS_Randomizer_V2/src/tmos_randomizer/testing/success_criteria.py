"""Success criteria definitions for randomization testing."""

from dataclasses import dataclass, field
from typing import Set


@dataclass
class SuccessCriteria:
    """Configurable success criteria for randomization tests.

    Controls what conditions must be met for a test to pass.
    """

    # Reachability thresholds
    min_reachability_percent: float = 95.0  # At least 95% of screens reachable

    # Section validation
    require_single_component_sections: bool = True  # No fragmented sections
    allow_empty_preserved_sections: bool = True  # Preserved sections can be empty

    # Navigation validation
    require_bidirectional_links: bool = True  # All links must be reciprocal
    max_one_way_links: int = 0  # Maximum allowed one-way links

    # Chapter validation
    require_all_chapters_valid: bool = True  # All chapters must pass
    required_section_types: Set[str] = field(
        default_factory=lambda: {"OVERWORLD", "TOWN", "DUNGEON"}
    )

    # Error tolerance
    max_errors: int = 0  # Maximum allowed errors (0 = strict)
    max_warnings: int = 50  # Maximum allowed warnings


# Default criteria - strict validation
DEFAULT_CRITERIA = SuccessCriteria()

# Lenient criteria - for debugging/development
LENIENT_CRITERIA = SuccessCriteria(
    min_reachability_percent=80.0,
    require_single_component_sections=False,
    max_one_way_links=5,
    max_errors=0,
    max_warnings=100,
)
