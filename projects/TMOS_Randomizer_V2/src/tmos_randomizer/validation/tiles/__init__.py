"""Tile analysis utilities for validation.

This package provides utilities for analyzing tiles:
- Tile categorization (walkable, collidable, hazard)
- Edge extraction from TileSections
- Pathfinding for traversability checks
"""

from .categories import (
    TileCategory,
    HAZARDOUS_TILES,
    COLLIDABLE_TILES,
    get_tile_category,
    is_walkable,
    is_compatible,
)

__all__ = [
    "TileCategory",
    "HAZARDOUS_TILES",
    "COLLIDABLE_TILES",
    "get_tile_category",
    "is_walkable",
    "is_compatible",
]
