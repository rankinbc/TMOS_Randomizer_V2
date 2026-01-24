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
    MAZE = auto()
    SPECIAL = auto()
    BOSS = auto()
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
    # Boss/Transition
    0xC0: SectionType.BOSS,
    0xC4: SectionType.BOSS,
    0xC7: SectionType.BOSS,
    0xC9: SectionType.BOSS,
    0xAC: SectionType.BOSS,
    0x9F: SectionType.BOSS,
    0xA0: SectionType.BOSS,
}


def get_section_type(parent_world: int) -> SectionType:
    """Get the section type for a ParentWorld value."""
    return PARENTWORLD_TO_SECTION.get(parent_world, SectionType.UNKNOWN)


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

# Boss screens - trigger boss encounters
BOSS_SCREENS: Set[int] = {118, 127, 128, 264, 265, 401, 402, 560, 561, 632, 640, 650, 737, 738}

# Victory screens - shown after boss defeat
VICTORY_SCREENS: Set[int] = {129, 266, 403, 562}

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
    591, 613, 617, 650, 685, 717
}

# Combined exclusion set - all screens that should not be randomized
DO_NOT_RANDOMIZE: Set[int] = (
    BOSS_SCREENS | VICTORY_SCREENS | WIZARD_SCREENS | SPECIAL_EVENT_SCREENS
)
