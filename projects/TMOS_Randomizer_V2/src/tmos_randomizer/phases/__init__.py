"""6-phase randomization algorithm."""

# Phase 1: Planning
from .phase1_planning import (
    SectionPlan,
    ChapterPlan,
    WorldPlan,
    create_chapter_plan,
    plan_randomization,
    validate_plan,
    SECTION_DEFAULTS,
    REQUIRED_SECTIONS,
)

# Phase 2: Shaping
from .phase2_shaping import (
    ShapeType,
    ScreenPosition,
    ScreenNode,
    SectionShape,
    ChapterShape,
    WorldShape,
    generate_section_shape,
    shape_chapter,
    shape_world,
    validate_shape,
)

# Phase 3: Connection
from .phase3_connection import (
    TopologyType,
    SectionConnection,
    ChapterConnections,
    WorldConnections,
    connect_chapter,
    connect_world,
    validate_connections,
)

# Phase 4: Population
from .phase4_population import (
    ScreenAssignment,
    ChapterPopulation,
    WorldPopulation,
    get_screen_pool,
    assign_screens_to_sections,
    assign_tilesections,
    assign_objectsets,
    populate_chapter,
    populate_world,
    validate_population,
)

# Phase 5: Navigation
from .phase5_navigation import (
    NavigationChange,
    StairwayChange,
    ChapterNavigation,
    WorldNavigation,
    rewrite_section_navigation,
    rewrite_section_connections,
    rewrite_chapter_navigation,
    rewrite_world_navigation,
    validate_navigation,
)

# ObjectSet randomization
from .objectset_randomization import (
    ScatterConfig,
    ObjectSetRandomizationConfig,
    RandomizationResult,
    get_eligible_screens,
    calculate_quotas,
    assign_with_scatter,
    randomize_chapter_objectsets,
    validate_randomization,
)

# TileSection Swapping
from .tilesection_swapping import (
    TileData,
    TileSwap,
    TileSwapResult,
    TilePool,
    build_tile_pools,
    swap_tiles_basic,
    swap_tiles_terrain_aware,
    swap_tiles_preserve_structure,
    preview_tile_swaps,
    get_chr_group_summary,
    validate_tile_swaps,
)

# Phase 6: Final Validation
from .phase6_validation import (
    ValidationIssue,
    ReachabilityResult,
    ChapterValidation,
    WorldValidation,
    analyze_reachability,
    validate_chapter,
    validate_world,
    validate_randomization as validate_full_randomization,
    quick_validate,
    is_playable,
)

__all__ = [
    # Phase 1: Planning
    "SectionPlan",
    "ChapterPlan",
    "WorldPlan",
    "create_chapter_plan",
    "plan_randomization",
    "validate_plan",
    "SECTION_DEFAULTS",
    "REQUIRED_SECTIONS",
    # Phase 2: Shaping
    "ShapeType",
    "ScreenPosition",
    "ScreenNode",
    "SectionShape",
    "ChapterShape",
    "WorldShape",
    "generate_section_shape",
    "shape_chapter",
    "shape_world",
    "validate_shape",
    # Phase 3: Connection
    "TopologyType",
    "SectionConnection",
    "ChapterConnections",
    "WorldConnections",
    "connect_chapter",
    "connect_world",
    "validate_connections",
    # Phase 4: Population
    "ScreenAssignment",
    "ChapterPopulation",
    "WorldPopulation",
    "get_screen_pool",
    "assign_screens_to_sections",
    "assign_tilesections",
    "assign_objectsets",
    "populate_chapter",
    "populate_world",
    "validate_population",
    # Phase 5: Navigation
    "NavigationChange",
    "StairwayChange",
    "ChapterNavigation",
    "WorldNavigation",
    "rewrite_section_navigation",
    "rewrite_section_connections",
    "rewrite_chapter_navigation",
    "rewrite_world_navigation",
    "validate_navigation",
    # ObjectSet randomization
    "ScatterConfig",
    "ObjectSetRandomizationConfig",
    "RandomizationResult",
    "get_eligible_screens",
    "calculate_quotas",
    "assign_with_scatter",
    "randomize_chapter_objectsets",
    "validate_randomization",
    # TileSection Swapping
    "TileData",
    "TileSwap",
    "TileSwapResult",
    "TilePool",
    "build_tile_pools",
    "swap_tiles_basic",
    "swap_tiles_terrain_aware",
    "swap_tiles_preserve_structure",
    "preview_tile_swaps",
    "get_chr_group_summary",
    "validate_tile_swaps",
    # Phase 6: Final Validation
    "ValidationIssue",
    "ReachabilityResult",
    "ChapterValidation",
    "WorldValidation",
    "analyze_reachability",
    "validate_chapter",
    "validate_world",
    "validate_full_randomization",
    "quick_validate",
    "is_playable",
]
