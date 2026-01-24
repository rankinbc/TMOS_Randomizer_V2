"""Tile categorization for collision and edge compatibility.

This module provides the tile category system used for validation:
- HAZARD: Tiles that damage the player (lava, spikes, water)
- COLLIDABLE: Tiles that block movement (walls, trees, structures)
- WALKABLE: Tiles the player can safely walk on

Edge Compatibility Rule:
- Walkable tiles must connect to walkable tiles
- Non-walkable tiles (hazard OR collidable) can connect to each other
- A walkable→non-walkable transition at a screen edge is INCOMPATIBLE
"""

from enum import Enum, auto
from typing import FrozenSet


class TileCategory(Enum):
    """Categories of tiles for walkability analysis."""

    WALKABLE = auto()     # Player can walk on safely
    COLLIDABLE = auto()   # Player cannot walk through (walls, trees)
    HAZARD = auto()       # Damages player (lava, spikes, water)


# =============================================================================
# Tile Category Sets
# =============================================================================

# Hazard tiles - damage the player but can be entered
# (player will take damage or die)
HAZARD_TILES: FrozenSet[int] = frozenset({
    0x2F,  # Lava/fire
    0x30,  # Lava/fire variant
    0x3F,  # Spikes
    0x40,  # Spikes variant
    0x41,  # Damage floor
    0x42,  # Damage floor variant
    0x6F,  # Water hazard
    0xEC,  # Special hazard
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
    0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
    0x60, 0x61, 0x62, 0x63, 0x64, 0x67, 0x68, 0x6B,

    # Elevated terrain / cliffs
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
    0xE2,
    0xF4, 0xF6, 0xF7, 0xF8, 0xF9, 0xFB, 0xFC, 0xFE,
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
    if tile_id in HAZARD_TILES:
        return TileCategory.HAZARD
    if tile_id in COLLIDABLE_TILES:
        return TileCategory.COLLIDABLE
    return TileCategory.WALKABLE


def is_walkable(tile_id: int, treat_hazards_as_blocking: bool = False) -> bool:
    """Check if a tile can be walked on.

    Args:
        tile_id: Tile ID (0-255)
        treat_hazards_as_blocking: If True, hazards block movement

    Returns:
        True if player can walk on this tile
    """
    category = get_tile_category(tile_id)

    if category == TileCategory.WALKABLE:
        return True
    if category == TileCategory.HAZARD:
        return not treat_hazards_as_blocking
    return False


def is_collidable(tile_id: int) -> bool:
    """Check if a tile blocks movement.

    Args:
        tile_id: Tile ID (0-255)

    Returns:
        True if tile blocks movement
    """
    return tile_id in COLLIDABLE_TILES


def is_hazard(tile_id: int) -> bool:
    """Check if a tile is a hazard.

    Args:
        tile_id: Tile ID (0-255)

    Returns:
        True if tile is a hazard
    """
    return tile_id in HAZARD_TILES


def is_compatible(tile_a: int, tile_b: int) -> bool:
    """Check if two adjacent tiles are compatible for edge matching.

    Edge Compatibility Rule:
    - Walkable must connect to walkable
    - Non-walkable (collidable OR hazard) can connect to each other
    - Walkable→non-walkable is INCOMPATIBLE (player would die or get stuck)

    Args:
        tile_a: First tile ID
        tile_b: Second tile ID

    Returns:
        True if tiles are compatible at an edge
    """
    cat_a = get_tile_category(tile_a)
    cat_b = get_tile_category(tile_b)

    # Walkable must match walkable
    if cat_a == TileCategory.WALKABLE:
        return cat_b == TileCategory.WALKABLE

    # Non-walkable (collidable or hazard) can match any non-walkable
    return cat_b != TileCategory.WALKABLE


def get_walkability_signature(tiles: list) -> str:
    """Get a walkability signature for a list of tiles.

    Creates a string representation where:
    - '1' = walkable
    - '0' = non-walkable (collidable or hazard)

    This can be used to quickly compare edge patterns.

    Args:
        tiles: List of tile IDs

    Returns:
        String like "10110100" representing walkability pattern
    """
    return "".join("1" if is_walkable(t) else "0" for t in tiles)


def count_walkable(tiles: list, treat_hazards_as_blocking: bool = False) -> int:
    """Count walkable tiles in a list.

    Args:
        tiles: List of tile IDs
        treat_hazards_as_blocking: If True, hazards count as blocking

    Returns:
        Number of walkable tiles
    """
    return sum(1 for t in tiles if is_walkable(t, treat_hazards_as_blocking))


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
