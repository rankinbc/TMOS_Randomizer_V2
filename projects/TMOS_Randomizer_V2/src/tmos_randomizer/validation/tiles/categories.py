"""Tile categorization for collision and edge compatibility.

This module provides the tile category system used for validation:
- DEADLY: Tiles that kill the player (water, lava) - treated as collidable for navigation
- HAZARDOUS: Tiles that damage but don't kill (quicksand) - can be walked through
- COLLIDABLE: Tiles that block movement (walls, trees, structures)
- WALKABLE: Tiles the player can safely walk on

Edge Compatibility Rule:
- Walkable/hazardous tiles must connect to walkable/hazardous tiles
- Non-walkable tiles (deadly OR collidable) can connect to each other
- A walkable→non-walkable transition at a screen edge is INCOMPATIBLE
"""

from enum import Enum, auto
from typing import FrozenSet


class TileCategory(Enum):
    """Categories of tiles for walkability analysis."""

    WALKABLE = auto()     # Player can walk on safely
    COLLIDABLE = auto()   # Player cannot walk through (walls, trees)
    DEADLY = auto()       # Kills player instantly (water, lava) - blocks movement
    HAZARDOUS = auto()    # Damages but doesn't kill (quicksand) - can walk through


# =============================================================================
# Tile Category Sets
# =============================================================================

# Deadly tiles - kill the player instantly, treated as collidable for navigation
# Player cannot use these to travel between screens
DEADLY_TILES: FrozenSet[int] = frozenset({
    0x2F,  # Lava/fire
    0x30,  # Lava/fire variant
    0x3F,  # Water (deep)
    0x40,  # Water variant
    0x41,  # Water
    0x42,  # Water variant
    0x6F,  # Water hazard
    0xE9,  # Lake entry - underwater section entrance
    0xEC,  # Special deadly
})

# Hazardous tiles - damage the player but don't kill
# Player CAN walk through these (taking damage)
HAZARDOUS_TILES: FrozenSet[int] = frozenset({
    # Quicksand and similar tiles that hurt but don't kill
    # Add specific tile IDs here as they are discovered
})

# Collidable tiles - block movement (~100 tiles)
# Player cannot enter these tiles at all
COLLIDABLE_TILES: FrozenSet[int] = frozenset({
    # Maze walls (0x00-0x19 range)
    0x00, 0x01, 0x02, 0x07, 0x08, 0x09, 0x0A, 0x0D, 0x0E, 0x0F,
    0x10, 0x11, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,

    # Trees and nature obstacles
    0x22, 0x23, 0x47,

    # Dark world walls
    0x4C, 0x4F, 0x50, 0x51, 0x52,

    # Dungeon walls (0x53-0x6B range)
    # Note: 0x5F is walkable (dungeon floor in Chapter 1)
    0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E,
    0x60, 0x61, 0x62, 0x63, 0x64, 0x67, 0x68, 0x6B,

    # Elevated terrain / cliffs
    0x73,
    0x77, 0x78, 0x7A, 0x7B, 0x7C, 0x7D, 0x7F,
    0x80, 0x81, 0x82, 0x83, 0x84,

    # Building walls
    0x86, 0x87, 0x88, 0x89, 0x8A, 0x8F,
    0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
    0x98, 0x99, 0x9A, 0x9B, 0x9C,

    # Town walls and structures
    0xA1, 0xA2, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAF,
    0xB2, 0xB3, 0xB5, 0xB8, 0xB9, 0xBC, 0xBD, 0xBE, 0xBF,
    0xC0, 0xC1, 0xCB, 0xCC, 0xCF,
    0xD5, 0xD6, 0xDE,
    0xE2, 0xE6, 0xE7, 0xEA, 0xEB, 0xEF,
    0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE,
})


# =============================================================================
# Tile Category Functions
# =============================================================================

def get_tile_category(tile_id: int) -> TileCategory:
    """Determine the category of a tile.

    Args:
        tile_id: Tile ID (0-255)

    Returns:
        TileCategory for this tile
    """
    if tile_id in DEADLY_TILES:
        return TileCategory.DEADLY
    if tile_id in HAZARDOUS_TILES:
        return TileCategory.HAZARDOUS
    if tile_id in COLLIDABLE_TILES:
        return TileCategory.COLLIDABLE
    return TileCategory.WALKABLE


def is_walkable(tile_id: int) -> bool:
    """Check if a tile can be walked on for navigation purposes.

    For edge compatibility checking:
    - WALKABLE and HAZARDOUS tiles are considered walkable (player can traverse)
    - DEADLY and COLLIDABLE tiles block movement

    Args:
        tile_id: Tile ID (0-255)

    Returns:
        True if player can walk on this tile
    """
    category = get_tile_category(tile_id)
    # Walkable and hazardous (damaging but not deadly) are traversable
    return category in (TileCategory.WALKABLE, TileCategory.HAZARDOUS)


def is_blocking(tile_id: int) -> bool:
    """Check if a tile blocks movement (collidable or deadly).

    Args:
        tile_id: Tile ID (0-255)

    Returns:
        True if tile blocks movement
    """
    category = get_tile_category(tile_id)
    return category in (TileCategory.COLLIDABLE, TileCategory.DEADLY)


def is_collidable(tile_id: int) -> bool:
    """Check if a tile is a collision tile (walls, trees, etc).

    Args:
        tile_id: Tile ID (0-255)

    Returns:
        True if tile is collidable
    """
    return tile_id in COLLIDABLE_TILES


def is_deadly(tile_id: int) -> bool:
    """Check if a tile is deadly (water, lava - kills instantly).

    Args:
        tile_id: Tile ID (0-255)

    Returns:
        True if tile is deadly
    """
    return tile_id in DEADLY_TILES


def is_hazardous(tile_id: int) -> bool:
    """Check if a tile is hazardous (damages but doesn't kill).

    Args:
        tile_id: Tile ID (0-255)

    Returns:
        True if tile is hazardous
    """
    return tile_id in HAZARDOUS_TILES


def is_compatible(tile_a: int, tile_b: int) -> bool:
    """Check if two adjacent tiles are compatible for edge matching.

    Edge Compatibility Rule:
    - Walkable/hazardous must connect to walkable/hazardous
    - Blocking (collidable OR deadly) can connect to each other
    - Walkable→blocking is INCOMPATIBLE (player would die or get stuck)

    Args:
        tile_a: First tile ID
        tile_b: Second tile ID

    Returns:
        True if tiles are compatible at an edge
    """
    walkable_a = is_walkable(tile_a)
    walkable_b = is_walkable(tile_b)

    # Both walkable or both blocking = compatible
    return walkable_a == walkable_b


def get_walkability_signature(tiles: list) -> str:
    """Get a walkability signature for a list of tiles.

    Creates a string representation where:
    - '1' = walkable (includes hazardous tiles that damage but don't block)
    - '0' = blocking (collidable or deadly)

    This can be used to quickly compare edge patterns.

    Args:
        tiles: List of tile IDs

    Returns:
        String like "10110100" representing walkability pattern
    """
    return "".join("1" if is_walkable(t) else "0" for t in tiles)


def count_walkable(tiles: list) -> int:
    """Count walkable tiles in a list.

    Args:
        tiles: List of tile IDs

    Returns:
        Number of walkable tiles (includes hazardous, excludes deadly/collidable)
    """
    return sum(1 for t in tiles if is_walkable(t))


def edges_match(edge_a: list, edge_b: list) -> tuple:
    """Check if two edges match and count mismatches.

    Args:
        edge_a: List of tile IDs for edge A
        edge_b: List of tile IDs for edge B (should be same length)

    Returns:
        Tuple of (is_compatible, mismatch_count, mismatch_positions)
    """
    if len(edge_a) != len(edge_b):
        return (False, len(edge_a), list(range(len(edge_a))))

    mismatches = []
    for i, (ta, tb) in enumerate(zip(edge_a, edge_b)):
        if not is_compatible(ta, tb):
            mismatches.append(i)

    return (len(mismatches) == 0, len(mismatches), mismatches)
