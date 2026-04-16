"""Enums and constants for TMOS game data.

Data sourced from knowledge base:
- docs/planning/section-analysis.md (ParentWorld values)
- docs/planning/exclusion-list.md (Content types, Event types)
- knowledge/structures/worldscreen.md (Screen detection rules)
"""

from enum import Enum, IntEnum, auto
from typing import Set


class SectionType(Enum):
    """Logical section types for randomizer organization."""

    OVERWORLD = auto()
    TOWN = auto()
    DUNGEON = auto()
    MINI_DUNGEON = auto()  # Smaller dungeons (e.g., Ch5 pre-boss area, item dungeons)
    MAZE = auto()
    SPECIAL = auto()
    BOSS = auto()
    VICTORY = auto()  # Post-boss victory/celebration screens
    UNKNOWN = auto()


class ParentWorld(IntEnum):
    """ParentWorld byte values (WorldScreen byte 0).

    Determines music and logical section membership.
    """

    # Towns
    TOWN_MAIN = 0x20
    TOWN_VARIANT = 0x10

    # Overworlds
    OVERWORLD_GREEN = 0x40  # Chapters 1, 3, 4
    OVERWORLD_DESERT = 0xE0  # Chapters 2, 4
    OVERWORLD_CH5 = 0x80  # Chapter 5
    OVERWORLD_CH4_ALT = 0x30  # Chapter 4 special

    # Dungeons
    DUNGEON_MAIN = 0xD0  # Chapters 1, 2, 4
    DUNGEON_CH3 = 0xF0  # Chapter 3
    DUNGEON_CH1_ALT = 0xB0  # Chapter 1 variant

    # Mazes
    MAZE_CH1 = 0x53
    MAZE_CH2 = 0x55
    MAZE_CH3 = 0x58
    MAZE_CH5 = 0x5D

    # Special Areas
    SPECIAL_CH1 = 0x61
    SPECIAL_CH2 = 0x64
    SPECIAL_CH3 = 0x67
    SPECIAL_CH4 = 0x69
    SPECIAL_CH4_ALT = 0x6A
    SPECIAL_CH5 = 0x6C
    SPECIAL_CH5_ALT = 0x6E
    SPECIAL_SINGLE = 0x60

    # Boss/Transition Areas
    BOSS_CH1 = 0xC0
    BOSS_CH2 = 0xC4
    BOSS_CH3 = 0xC7
    BOSS_CH4 = 0xC9
    BOSS_CH5 = 0xAC
    PRE_BOSS_CH5 = 0x9F
    FINAL_CH5 = 0xA0


class TimePeriod(Enum):
    """Time period classification for screens.

    Screens belong to either PRESENT or PAST/FUTURE time periods.
    Cross-time-period navigation is only possible via Time Doors.
    """

    PRESENT = auto()  # Present day screens
    PAST = auto()  # Past/Future screens (time-shifted areas)


# =============================================================================
# PAST Screen Indices by Chapter
# =============================================================================
# Source: TMOS_Romhack1 hardcoded lists
# These are CHAPTER-RELATIVE screen indices that are in the PAST time period.
# All other screens in the chapter are PRESENT.
#
# IMPORTANT: ParentWorld alone does NOT determine time period!
# Some ParentWorld values (0x10, 0x20, 0x30) contain screens from BOTH periods.
# The game uses these hardcoded screen index lists, not ParentWorld.

PAST_SCREEN_INDICES: dict[int, set[int]] = {
    1: {
        0x40, 0x44, 0x43, 0x3F, 0x3A, 0x39, 0x3E, 0x3D, 0x38, 0x35, 0x2F, 0x30,
        0x31, 0x32, 0x29, 0x2A, 0x2B, 0x2C, 0x25, 0x26, 0x27, 0x28, 0x2E, 0x2D,
        0x33, 0x34, 0x36, 0x37, 0x3B, 0x3C, 0x41, 0x42, 0x6B, 0x69, 0x6A, 0x6C,
        0x4A, 0x48, 0x46, 0x45, 0x47, 0x49, 0x6F, 0x6E, 0x6D, 0x70, 0x71,
    },
    2: {
        0x4F, 0x50, 0x51, 0x4B, 0x4C, 0x48, 0x47, 0x43, 0x44, 0x40, 0x3F, 0x3B,
        0x3A, 0x3E, 0x42, 0x46, 0x4A, 0x4E, 0x4D, 0x49, 0x45, 0x41, 0x3D,
        0x39, 0x38, 0x3C, 0x70, 0x78, 0x79, 0x7C, 0x7B, 0x7A, 0x57, 0x5B, 0x58,
        0x54, 0x5C, 0x5D, 0x5A, 0x56, 0x53, 0x52, 0x55, 0x59,
    },
    3: {
        0x4B, 0x4A, 0x4D, 0x4E, 0x52, 0x53, 0x57, 0x58, 0x59, 0x5A, 0x33, 0x56,
        0x55, 0x51, 0x50, 0x4F, 0x54, 0x4C, 0x49, 0x48, 0x47, 0x45, 0x44, 0x46,
        0x41, 0x3D, 0x3E, 0x3F, 0x42, 0x43, 0x40, 0x3C, 0x3B, 0x39, 0x38, 0x37,
        0x36, 0x3A, 0x34, 0x35, 0x8D, 0x8C, 0x8E, 0x8F, 0x91, 0x90, 0x92, 0x93,
    },
    4: {
        0x38, 0x9A, 0x99, 0x9B, 0x9C, 0x9E, 0x9D, 0x37, 0x36, 0x35, 0x39, 0x3A,
        0x3B, 0x3C, 0x3D, 0x40, 0x3F, 0x3E, 0x44, 0x43, 0x42, 0x41, 0x4A, 0x49,
        0x48, 0x47, 0x46, 0x45, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52,
        0x59, 0x58, 0x57, 0x56, 0x55, 0x54, 0x53, 0x5A, 0x5B, 0x5C, 0x5D, 0x68,
        0x69, 0x6A, 0x6C, 0x6D, 0x6B, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x7A,
        0x7B, 0x7C, 0x79, 0x78, 0x77, 0x74, 0x75, 0x76, 0x89, 0x8A, 0x86, 0x85,
        0x81, 0x7D, 0x7E, 0x82, 0x83, 0x87, 0x88, 0x7F, 0x80, 0x84,
        0x8C, 0x8E,  # Added: 128, 140 (boss), 142
    },
    5: {
        0x68, 0x6F, 0x76, 0x7D, 0x81, 0x7E, 0x77, 0x70, 0x69, 0x6A, 0x6B, 0x72,
        0x71, 0x78, 0x79, 0x80, 0x7F, 0x82, 0x7A, 0x73, 0x6C, 0x6D,
        0x6E, 0x75, 0x7C, 0x7B, 0x74,
    },
}


def get_time_period_for_screen(chapter_num: int, screen_index: int) -> TimePeriod:
    """Get the time period for a specific screen.

    Args:
        chapter_num: Chapter number (1-5)
        screen_index: Chapter-relative screen index

    Returns:
        TimePeriod.PAST if screen is in the past, TimePeriod.PRESENT otherwise
    """
    past_screens = PAST_SCREEN_INDICES.get(chapter_num, set())
    if screen_index in past_screens:
        return TimePeriod.PAST
    return TimePeriod.PRESENT


def is_past_screen_index(chapter_num: int, screen_index: int) -> bool:
    """Check if a screen index is in the PAST time period.

    Args:
        chapter_num: Chapter number (1-5)
        screen_index: Chapter-relative screen index

    Returns:
        True if screen is in PAST time period
    """
    return get_time_period_for_screen(chapter_num, screen_index) == TimePeriod.PAST


def is_present_screen_index(chapter_num: int, screen_index: int) -> bool:
    """Check if a screen index is in the PRESENT time period.

    Args:
        chapter_num: Chapter number (1-5)
        screen_index: Chapter-relative screen index

    Returns:
        True if screen is in PRESENT time period
    """
    return get_time_period_for_screen(chapter_num, screen_index) == TimePeriod.PRESENT


# =============================================================================
# DEPRECATED: ParentWorld-based time period detection
# =============================================================================
# These functions are kept for backwards compatibility but should NOT be used
# for time period validation. Use get_time_period_for_screen() instead.

def get_time_period(parent_world: int) -> TimePeriod:
    """DEPRECATED: Get time period from ParentWorld value.

    WARNING: This is inaccurate! ParentWorld does not reliably determine
    time period. Some values (0x10, 0x20, 0x30) contain screens from BOTH
    time periods. Use get_time_period_for_screen() instead.
    """
    # 100% PAST ParentWorld values
    if parent_world in (0x53, 0x55, 0x9F, 0xD0, 0xF0, 0x69):
        return TimePeriod.PAST
    return TimePeriod.PRESENT


def is_past_screen(parent_world: int) -> bool:
    """DEPRECATED: Use is_past_screen_index() instead."""
    return get_time_period(parent_world) == TimePeriod.PAST


def is_present_screen(parent_world: int) -> bool:
    """DEPRECATED: Use is_present_screen_index() instead."""
    return get_time_period(parent_world) == TimePeriod.PRESENT


# Map ParentWorld values to SectionType
PARENTWORLD_TO_SECTION: dict[int, SectionType] = {
    # Towns
    0x20: SectionType.TOWN,
    0x10: SectionType.TOWN,
    # Overworlds
    0x40: SectionType.OVERWORLD,
    0xE0: SectionType.OVERWORLD,
    0x80: SectionType.OVERWORLD,
    0x30: SectionType.OVERWORLD,
    # Dungeons
    0xD0: SectionType.DUNGEON,
    0xF0: SectionType.DUNGEON,
    0xB0: SectionType.DUNGEON,
    # Mazes
    0x53: SectionType.MAZE,
    0x55: SectionType.MAZE,
    0x58: SectionType.MAZE,
    0x5D: SectionType.MAZE,
    # Special Areas
    0x61: SectionType.SPECIAL,
    0x64: SectionType.SPECIAL,
    0x67: SectionType.SPECIAL,
    0x69: SectionType.SPECIAL,
    0x6A: SectionType.SPECIAL,
    0x6C: SectionType.SPECIAL,
    0x6E: SectionType.SPECIAL,
    0x60: SectionType.SPECIAL,
    # Chapter 5 specific areas
    0x9F: SectionType.DUNGEON,       # Chapter 5 pre-boss dungeon (main dungeon)
    0xA0: SectionType.MINI_DUNGEON,  # Chapter 5 pre-boss area (right before boss)
    # Boss/Transition
    0xC0: SectionType.BOSS,
    0xC4: SectionType.BOSS,
    0xC7: SectionType.BOSS,
    0xC9: SectionType.BOSS,
    0xAC: SectionType.BOSS,
}


def get_section_type(parent_world: int) -> SectionType:
    """Get the section type for a ParentWorld value."""
    return PARENTWORLD_TO_SECTION.get(parent_world, SectionType.UNKNOWN)


# Reverse mapping: SectionType -> canonical ParentWorld value
# Used when assigning screens to sections to update their parent_world
SECTION_TO_PARENTWORLD: dict[SectionType, int] = {
    SectionType.TOWN: 0x20,
    SectionType.OVERWORLD: 0x40,
    SectionType.DUNGEON: 0xD0,
    SectionType.MAZE: 0x53,
    SectionType.SPECIAL: 0x61,
    SectionType.BOSS: 0xC0,
    SectionType.VICTORY: 0xC0,      # Victory uses same as boss area
    SectionType.MINI_DUNGEON: 0xA0,
}


def get_parentworld_for_section(section_type: SectionType) -> int | None:
    """Get the canonical ParentWorld value for a SectionType.

    Returns None if section type has no defined parent_world mapping.
    """
    return SECTION_TO_PARENTWORLD.get(section_type)


class ContentType(IntEnum):
    """Content byte values (WorldScreen byte 2).

    Determines building type, boss stage, or special behavior.
    """

    # No content
    NONE = 0x00

    # Wizard battles
    WIZARD_BATTLE = 0x01

    # Boss stages (0x21-0x2A)
    BOSS_STAGE_1 = 0x21
    BOSS_STAGE_2 = 0x22
    BOSS_STAGE_3 = 0x23
    BOSS_STAGE_4 = 0x24
    BOSS_STAGE_5 = 0x25
    BOSS_STAGE_6 = 0x26
    BOSS_STAGE_7 = 0x27
    BOSS_STAGE_8 = 0x28
    BOSS_STAGE_9 = 0x29
    BOSS_STAGE_10 = 0x2A

    # Victory screen
    VICTORY = 0x2B

    # Shops (0x60-0x7D)
    SHOP_START = 0x60
    SHOP_END = 0x7D

    # Special buildings
    MOSQUE = 0x7E
    TROOPERS = 0x7F

    # Allies (0x80-0x8F range)
    ALLY_GUBIBI = 0x80
    ALLY_FARUK = 0x81

    # Hotels (0xA0-0xB0)
    HOTEL_START = 0xA0
    HOTEL_END = 0xB0

    # Casino
    CASINO = 0xBE

    # Time doors
    TIME_DOOR = 0xC0
    TIME_DOOR_C7 = 0xC7
    TIME_DOOR_D7 = 0xD7


# Content ranges for detection
BOSS_CONTENT_RANGE = range(0x21, 0x2B)  # 0x21-0x2A
SHOP_CONTENT_RANGE = range(0x60, 0x7E)  # 0x60-0x7D
NPC_CONTENT_RANGE = range(0x80, 0x90)  # 0x80-0x8F
HOTEL_CONTENT_RANGE = range(0xA0, 0xB1)  # 0xA0-0xB0


def is_boss_content(content: int) -> bool:
    """Check if Content indicates a boss screen."""
    return content in BOSS_CONTENT_RANGE


def is_shop_content(content: int) -> bool:
    """Check if Content indicates a shop."""
    return content in SHOP_CONTENT_RANGE


def is_building_content(content: int) -> bool:
    """Check if Content indicates any building type."""
    return (
        content in SHOP_CONTENT_RANGE
        or content == ContentType.MOSQUE
        or content == ContentType.TROOPERS
        or content in HOTEL_CONTENT_RANGE
        or content == ContentType.CASINO
    )


class EventType(IntEnum):
    """Event byte values (WorldScreen byte 15).

    Triggers dialogs, special behaviors, and stairways.
    """

    NONE = 0x00
    DIALOG_1 = 0x01
    DIALOG_3 = 0x03
    SAFE_8 = 0x08  # Appears safe for randomization
    PRE_BOSS = 0x09
    AREA_TRANSITION = 0x10
    NPC_DIALOG = 0x20
    OPRIN_DOOR = 0x22  # Reveals hidden door with Oprin spell
    STAIRWAY = 0x40  # Stairway - Content becomes destination
    SPECIAL_47 = 0x47
    BOSS_PREP = 0x48
    STORY_EVENT = 0x60
    SPECIAL_ENCOUNTER = 0x62
    MAZE_PUZZLE = 0x80
    MAZE_SPECIAL = 0xC0


# Events that are safe to randomize
SAFE_EVENTS: Set[int] = {0x00, 0x08, 0x22, 0x40}

# Events that should not be randomized
DANGEROUS_EVENTS: Set[int] = {0x01, 0x03, 0x09, 0x10, 0x20, 0x47, 0x48, 0x60, 0x62, 0x80, 0xC0}


def is_stairway_event(event: int) -> bool:
    """Check if Event indicates a stairway (Content = destination)."""
    return event == EventType.STAIRWAY


def is_safe_event(event: int) -> bool:
    """Check if Event is safe for randomization."""
    return event in SAFE_EVENTS


class SpritesColor(IntEnum):
    """SpritesColor byte values (WorldScreen byte 13).

    Used for screen type detection.
    """

    TOWN = 0x12  # Indicates town screen


# =============================================================================
# Screen Detection Values
# =============================================================================

# Navigation special values
NAV_BUILDING_ENTRANCE = 0xFE
NAV_BLOCKED = 0xFF

# Enemy door screen detection
# Matches (ParentWorld, ObjectSet) pairs
ENEMY_DOOR_PAIRS: Set[tuple[int, int]] = {
    (0x61, 0x10),
    (0x64, 0x0F),
    (0x67, 0x14),
    (0x67, 0x15),
    (0x69, 0x14),
    (0x69, 0x15),
    (0x6A, 0x14),
    (0x6A, 0x15),
    (0x6C, 0x0D),
    (0x6E, 0x0D),
    (0x9F, 0x0D),
}


def is_enemy_door_screen(parent_world: int, objectset: int) -> bool:
    """Check if screen is an enemy door screen."""
    return (parent_world, objectset) in ENEMY_DOOR_PAIRS


# =============================================================================
# Exclusion Lists (Global Screen Indices)
# =============================================================================

# Boss screens - trigger boss encounters (global indices)
# NOTE: 737 removed - it's pre-boss area (ParentWorld 0xA0), not actual boss
BOSS_SCREENS: Set[int] = {118, 127, 128, 264, 265, 401, 402, 560, 561, 632, 640, 650, 738}

# Victory screens - shown after boss defeat (global indices)
VICTORY_SCREENS: Set[int] = {129, 266, 403, 562}

# =============================================================================
# Per-Chapter Boss and Victory Screen Mappings (Relative Indices)
# These are used to create BOSS and VICTORY sections in the flow
# =============================================================================

# Boss screens by chapter (relative indices)
# Based on ParentWorld values 0xC0, 0xC4, 0xC7, 0xC9, 0xAC
# NOTE: Chapter 5 is complex - screen 152 is pre-boss area (0xA0), only 153 is final boss
BOSS_SCREENS_BY_CHAPTER: dict[int, Set[int]] = {
    1: {127, 128},        # ParentWorld 0xC0 - Chapter 1 boss arena
    2: {133, 134},        # ParentWorld 0xC4 - Chapter 2 boss arena
    3: {133, 134},        # ParentWorld 0xC7 - Chapter 3 boss arena
    4: {139, 140},        # ParentWorld 0xC9 - Chapter 4 boss arena
    5: {153},             # ParentWorld 0xAC - Final boss (Sabaron only)
}

# Victory screens by chapter (relative indices)
# These share ParentWorld with SPECIAL but have unique screen indices
VICTORY_SCREENS_BY_CHAPTER: dict[int, Set[int]] = {
    1: {129},             # ParentWorld 0x60 - Chapter 1 victory
    2: {135},             # ParentWorld 0x64 - Chapter 2 victory
    3: {135},             # ParentWorld 0x67 - Chapter 3 victory
    4: {141},             # ParentWorld 0x69 - Chapter 4 victory
    5: set(),             # Chapter 5 has no separate victory screen
}

# Wizard battle screens
WIZARD_SCREENS: Set[int] = {363, 382, 531, 548, 553, 652, 678, 683, 687}

# Special event screens with story triggers
SPECIAL_EVENT_SCREENS: Set[int] = {
    # Chapter 1
    23, 32, 36, 61, 66, 99, 101, 118, 123, 124, 125, 126,
    # Chapter 2
    140, 169, 183, 191, 209, 252, 253, 256, 257, 258,
    # Chapter 3
    269, 291, 296, 311, 313, 319, 321,
    384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398,
    404,
    # Chapter 4
    429, 459, 461, 515, 516, 563, 565, 580,
    # Chapter 5
    591, 613, 617, 650, 685, 717, 737  # 737 = relative 152 (pre-boss area, don't modify)
}

# Combined exclusion set - all screens that should not be randomized
DO_NOT_RANDOMIZE: Set[int] = (
    BOSS_SCREENS | VICTORY_SCREENS | WIZARD_SCREENS | SPECIAL_EVENT_SCREENS
)
