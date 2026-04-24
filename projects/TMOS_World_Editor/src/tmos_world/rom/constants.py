"""ROM numeric constants for TMOS (see world-editor-spec §1, §4.3.1).

This document is authoritative over any older values in knowledge/systems/.
"""
from __future__ import annotations


ROM_MD5 = "b3236db14c87f375e5f24a5b9b79f071"

# Per-chapter WorldScreen table bases (spec §1.1). chapter 1 -> index 0.
CHAPTER_BASES: dict[int, int] = {
    1: 0x039695,
    2: 0x039EC5,
    3: 0x03A755,
    4: 0x03B0E5,
    5: 0x03BB25,
}

SCREEN_COUNTS: dict[int, int] = {
    1: 131,
    2: 137,
    3: 153,
    4: 164,
    5: 154,
}

WORLDSCREEN_SIZE = 16  # bytes per screen record

# TileSection table (spec §1.2).
TILESECTION_BASE = 0x03C4C7
TILESECTION_BANK1_OFFSET = 0x2000  # bank 1 is bank 0 + 0x2000
TILESECTION_STRIDE = 32  # bytes per section (authoritative — spec §0)
ACCESSIBLE_SECTION_COUNT = 474  # total globally accessible sections across both banks

# Screen geometry (spec §3.1)
SCREEN_WIDTH_TILES = 8
SCREEN_HEIGHT_TILES = 6  # 4 top rows + first 2 bottom rows


def _ranges(*ranges: tuple[int, int]) -> set[int]:
    out: set[int] = set()
    for lo, hi in ranges:
        out.update(range(lo, hi + 1))
    return out


# PAST screen indices in the original ROM, chapter-relative (spec §4.3.1).
PAST_INDICES_BY_CHAPTER: dict[int, set[int]] = {
    1: _ranges((0x25, 0x4A), (0x69, 0x71)),
    2: _ranges((0x38, 0x5D), (0x70, 0x70), (0x78, 0x7C)),
    3: _ranges((0x33, 0x5A), (0x8C, 0x93)),
    4: _ranges((0x1F, 0x1F), (0x35, 0x5D), (0x68, 0x8A), (0x8C, 0x8C), (0x8E, 0x8E), (0x99, 0x9E)),
    5: _ranges((0x68, 0x82),),
}


# Walkability categories (spec §3.3). Tile IDs outside both sets default to walkable.
HAZARD_TILES: frozenset[int] = frozenset({0x2F, 0x30, 0x3F, 0x40, 0x41, 0x42, 0x6F, 0xEC})

COLLIDABLE_TILES: frozenset[int] = frozenset(
    # Maze walls
    {0x00, 0x01, 0x02, 0x07, 0x08, 0x09, 0x0A, 0x0D, 0x0E, 0x0F,
     0x10, 0x11, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19}
    # Trees/nature
    | {0x22, 0x23, 0x47}
    # Dark world
    | {0x4C, 0x4F, 0x50, 0x51, 0x52}
    # Dungeon walls
    | set(range(0x53, 0x60)) | set(range(0x60, 0x65)) | {0x67, 0x68, 0x6B}
    # Elevated terrain
    | {0x77, 0x78} | set(range(0x7A, 0x7E)) | {0x7F} | set(range(0x80, 0x85))
    # Building walls
    | set(range(0x86, 0x8B)) | {0x8F} | set(range(0x92, 0x9D))
    # Town walls
    | {0xA1, 0xA2} | set(range(0xA9, 0xAE)) | {0xAF}
    | {0xB2, 0xB3, 0xB5, 0xB8, 0xB9} | set(range(0xBC, 0xC0))
    | {0xC0, 0xC1, 0xCB, 0xCC, 0xCF}
    | {0xD5, 0xD6, 0xDE, 0xE2}
    | {0xF4} | set(range(0xF6, 0xFA)) | {0xFB, 0xFC, 0xFE}
)


# Stairway event byte (spec §4.2).
EVENT_STAIRWAY = 0x40

# Time-door content byte values (spec §4.3).
TIME_DOOR_CONTENTS: frozenset[int] = frozenset({0xC0, 0xC7, 0xD7})

# Building-entrance nav byte sentinel (spec §4.4).
NAV_BUILDING_ENTRANCE = 0xFE
# Blocked-edge nav byte sentinel (spec §4.1).
NAV_BLOCKED = 0xFF

# Town detection (spec §6.1).
TOWN_SPRITES_COLOR = 0x12
