"""Screen-internal walkability and edge-row analysis (spec §3.3, §3.6)."""
from __future__ import annotations

from collections import deque

from src.tmos_world.analysis.tiles import (
    Direction,
    category,
    screen_edge_tiles,
    screen_tile_grid,
)
from src.tmos_world.model import World, WorldScreen


def walkable_edge_rows(world: World, screen: WorldScreen, direction: Direction) -> int:
    """Count how many tiles on the given edge are walkable."""
    return sum(1 for t in screen_edge_tiles(world, screen, direction) if category(t) == "walkable")


def walkable_flood_fill(
    world: World, screen: WorldScreen, start: tuple[int, int] | None = None
) -> set[tuple[int, int]]:
    """Flood-fill over walkable tiles (4-connected) starting at ``start``.

    If ``start`` is None, picks the first walkable cell on any edge. Returns
    the set of reached (col, row) positions (empty if no walkable tiles).
    """
    grid = screen_tile_grid(world, screen)
    rows = len(grid)
    cols = len(grid[0]) if rows else 0

    if start is None:
        for r in range(rows):
            for c in (0, cols - 1):
                if category(grid[r][c]) == "walkable":
                    start = (c, r)
                    break
            if start is not None:
                break
        if start is None:
            for c in range(cols):
                for r in (0, rows - 1):
                    if category(grid[r][c]) == "walkable":
                        start = (c, r)
                        break
                if start is not None:
                    break
        if start is None:
            return set()

    visited: set[tuple[int, int]] = set()
    q: deque[tuple[int, int]] = deque([start])
    while q:
        c, r = q.popleft()
        if (c, r) in visited:
            continue
        if not (0 <= c < cols and 0 <= r < rows):
            continue
        if category(grid[r][c]) != "walkable":
            continue
        visited.add((c, r))
        q.extend([(c + 1, r), (c - 1, r), (c, r + 1), (c, r - 1)])
    return visited
