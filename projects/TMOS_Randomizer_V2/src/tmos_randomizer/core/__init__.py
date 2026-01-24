"""Core data models and ROM constants."""

from .constants import (
    CHAPTER_OFFSETS,
    CHAPTER_BASES,
    OBJECTSET_PTR_TABLES,
    OBJECTSET_COMPATIBILITY,
    relative_to_global,
    global_to_relative,
    get_worldscreen_address,
    get_chr_index,
    get_compatible_objectsets,
    validate_objectset_compatibility,
)
from .worldscreen import WorldScreen
from .chapter import Chapter, GameWorld
from .enums import (
    SectionType,
    ContentType,
    EventType,
    ParentWorld,
    SAFE_EVENTS,
    DANGEROUS_EVENTS,
    DO_NOT_RANDOMIZE,
    BOSS_SCREENS,
    VICTORY_SCREENS,
    WIZARD_SCREENS,
    ENEMY_DOOR_PAIRS,
    get_section_type,
    is_enemy_door_screen,
    is_safe_event,
    is_stairway_event,
)
from .enemy_difficulty import (
    DifficultyTier,
    ObjectSetInfo,
    ENEMY_DIFFICULTY_SCORES,
    DIFFICULTY_PRESETS,
    DEFAULT_DISTRIBUTION,
    calculate_threat_score,
    classify_difficulty,
    create_objectset_info,
)
from .objectset_registry import (
    ObjectSetRegistry,
    build_registry_from_data,
)

__all__ = [
    # Constants
    "CHAPTER_OFFSETS",
    "CHAPTER_BASES",
    "OBJECTSET_PTR_TABLES",
    "OBJECTSET_COMPATIBILITY",
    "relative_to_global",
    "global_to_relative",
    "get_worldscreen_address",
    "get_chr_index",
    "get_compatible_objectsets",
    "validate_objectset_compatibility",
    # Data models
    "WorldScreen",
    "Chapter",
    "GameWorld",
    # Enums
    "SectionType",
    "ContentType",
    "EventType",
    "ParentWorld",
    "SAFE_EVENTS",
    "DANGEROUS_EVENTS",
    "DO_NOT_RANDOMIZE",
    "BOSS_SCREENS",
    "VICTORY_SCREENS",
    "WIZARD_SCREENS",
    "ENEMY_DOOR_PAIRS",
    "get_section_type",
    "is_enemy_door_screen",
    "is_safe_event",
    "is_stairway_event",
    # Enemy difficulty
    "DifficultyTier",
    "ObjectSetInfo",
    "ENEMY_DIFFICULTY_SCORES",
    "DIFFICULTY_PRESETS",
    "DEFAULT_DISTRIBUTION",
    "calculate_threat_score",
    "classify_difficulty",
    "create_objectset_info",
    # ObjectSet registry
    "ObjectSetRegistry",
    "build_registry_from_data",
]
