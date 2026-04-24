"""Tile category and screen-edge helpers (spec §3.3, §3.4)."""
from __future__ import annotations

from typing import Literal

from src.tmos_world.model import World, WorldScreen
from src.tmos_world.rom.constants import (
    COLLIDABLE_TILES,
    HAZARD_TILES,
    TILESECTION_BANK1_OFFSET,
    TILESECTION_BASE,
    TILESECTION_STRIDE,
)

Category = Literal["hazard", "collidable", "walkable"]
Direction = Literal["left", "right", "up", "down"]


def category(tile_id: int) -> Category:
    """Classify a tile as hazard, collidable, or walkable (spec §3.3)."""
    if tile_id in HAZARD_TILES:
        return "hazard"
    if tile_id in COLLIDABLE_TILES:
        return "collidable"
    return "walkable"


def _bank_offsets(datapointer: int) -> tuple[int, int]:
    """Return (top_bank_byte_offset, bottom_bank_byte_offset) per spec §5.1."""
    top = TILESECTION_BANK1_OFFSET if datapointer & 0x80 else 0
    bottom = TILESECTION_BANK1_OFFSET if datapointer & 0x40 else 0
    return top, bottom


def _tilesection_bytes(rom_bytes: bytes, index: int, bank_offset: int) -> bytes:
    addr = TILESECTION_BASE + bank_offset + index * TILESECTION_STRIDE
    return bytes(rom_bytes[addr : addr + TILESECTION_STRIDE])


def screen_tile_grid(world: World, screen: WorldScreen) -> list[list[int]]:
    """Return the full 8×6 tile grid (rows 0..5, cols 0..7) for a screen.

    Rows 0..3 come from top_tiles; rows 4..5 come from the first 2 rows of
    bottom_tiles (rows 2..3 of bottom are not rendered — spec §3.1).
    """
    top_off, bot_off = _bank_offsets(screen.datapointer)
    top = _tilesection_bytes(world.rom_bytes, screen.top_tiles, top_off)
    bot = _tilesection_bytes(world.rom_bytes, screen.bottom_tiles, bot_off)

    grid: list[list[int]] = []
    for row in range(4):
        grid.append(list(top[row * 8 : row * 8 + 8]))
    for row in range(2):
        grid.append(list(bot[row * 8 : row * 8 + 8]))
    return grid


def screen_edge_tiles(world: World, screen: WorldScreen, direction: Direction) -> list[int]:
    """Return the tile IDs along the given screen edge in consistent order.

    Per spec §3.4 composite edges (the edges the engine compares between
    adjacent screens) are built from the visible 8×6 area.
    """
    grid = screen_tile_grid(world, screen)
    if direction == "left":
        return [row[0] for row in grid]
    if direction == "right":
        return [row[7] for row in grid]
    if direction == "up":
        return list(grid[0])
    if direction == "down":
        return list(grid[5])
    raise ValueError(f"Unknown direction: {direction}")


def edges_compatible(edge_a: list[int], edge_b: list[int]) -> bool:
    """Walkable meets walkable; non-walkable meets non-walkable (spec §3.3)."""
    if len(edge_a) != len(edge_b):
        return False
    return all(
        (category(a) == "walkable") == (category(b) == "walkable")
        for a, b in zip(edge_a, edge_b)
    )
