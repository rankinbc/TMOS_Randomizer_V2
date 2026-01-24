"""Game logic and constraints."""

from .compatibility import (
    get_chr_index,
    get_tile_banks,
    get_all_valid_datapointers,
    get_compatible_objectsets,
    is_objectset_compatible,
    can_swap_screens,
    validate_screen_compatibility,
    OBJECTSET_COMPATIBILITY,
)
from .exclusions import (
    is_excluded,
    get_exclusion_reason,
    get_excluded_screens,
    get_randomizable_screens,
    ExclusionConfig,
    build_exclusion_set,
)
from .navigation import (
    StairwayPair,
    get_stairway_pairs,
    set_stairway_pair,
    validate_stairway_pair,
    build_navigation_graph,
    find_connected_components,
    find_asymmetric_connections,
)

__all__ = [
    # Compatibility
    "get_chr_index",
    "get_tile_banks",
    "get_all_valid_datapointers",
    "get_compatible_objectsets",
    "is_objectset_compatible",
    "can_swap_screens",
    "validate_screen_compatibility",
    "OBJECTSET_COMPATIBILITY",
    # Exclusions
    "is_excluded",
    "get_exclusion_reason",
    "get_excluded_screens",
    "get_randomizable_screens",
    "ExclusionConfig",
    "build_exclusion_set",
    # Navigation
    "StairwayPair",
    "get_stairway_pairs",
    "set_stairway_pair",
    "validate_stairway_pair",
    "build_navigation_graph",
    "find_connected_components",
    "find_asymmetric_connections",
]
