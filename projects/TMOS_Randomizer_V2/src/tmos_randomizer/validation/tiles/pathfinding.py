"""Pathfinding utilities for screen traversability validation.

This module provides BFS-based pathfinding to check if a player
can walk from entry edges to exit edges within a screen.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Dict, List, Set, Tuple, Optional

from .categories import is_walkable
from .edges import build_tile_grid


@dataclass
class TraversabilityResult:
    """Result of a traversability check.

    Attributes:
        is_traversable: True if at least one entry→exit path exists
        reachable_tiles: Set of (row, col) positions reachable from entry
        entry_direction: Which direction the entry was from
        reachable_exits: Set of exit directions that are reachable
        unreachable_exits: Set of exit directions that are NOT reachable
    """

    is_traversable: bool
    reachable_tiles: Set[Tuple[int, int]]
    entry_direction: str
    reachable_exits: Set[str]
    unreachable_exits: Set[str]


def build_walkability_grid(
    rom_data: bytes,
    top_tiles: int,
    bottom_tiles: int,
    datapointer: int,
    treat_hazards_as_blocking: bool = False,
) -> List[List[bool]]:
    """Build 8x6 walkability grid from TileSection data.

    Args:
        rom_data: Full ROM data
        top_tiles: TileSection index for top
        bottom_tiles: TileSection index for bottom
        datapointer: DataPointer value
        treat_hazards_as_blocking: If True, hazards block movement

    Returns:
        8x6 grid of booleans (True = walkable)
    """
    tile_grid = build_tile_grid(rom_data, top_tiles, bottom_tiles, datapointer)

    return [
        [is_walkable(tile, treat_hazards_as_blocking) for tile in row]
        for row in tile_grid
    ]


def get_edge_positions(direction: str) -> List[Tuple[int, int]]:
    """Get (row, col) positions for an edge.

    Args:
        direction: Edge direction ("up", "down", "left", "right")

    Returns:
        List of (row, col) positions for that edge
    """
    if direction == "up":
        # Top row (row 0)
        return [(0, col) for col in range(8)]
    elif direction == "down":
        # Bottom row (row 5)
        return [(5, col) for col in range(8)]
    elif direction == "left":
        # Left column (col 0)
        return [(row, 0) for row in range(6)]
    elif direction == "right":
        # Right column (col 7)
        return [(row, 7) for row in range(6)]
    else:
        return []


def get_walkable_edge_positions(
    walkability_grid: List[List[bool]],
    direction: str,
) -> List[Tuple[int, int]]:
    """Get walkable positions on an edge.

    Args:
        walkability_grid: 8x6 grid of walkability
        direction: Edge direction

    Returns:
        List of walkable (row, col) positions on that edge
    """
    positions = get_edge_positions(direction)
    return [
        (row, col) for row, col in positions
        if walkability_grid[row][col]
    ]


def bfs_reachable(
    walkability_grid: List[List[bool]],
    start: Tuple[int, int],
) -> Set[Tuple[int, int]]:
    """Find all positions reachable from a starting position using BFS.

    Args:
        walkability_grid: 8x6 grid of walkability
        start: Starting (row, col) position

    Returns:
        Set of all reachable (row, col) positions
    """
    if not walkability_grid[start[0]][start[1]]:
        return set()

    reachable = {start}
    queue = deque([start])

    while queue:
        row, col = queue.popleft()

        # Check 4 neighbors
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nr, nc = row + dr, col + dc

            # Bounds check (8 cols, 6 rows)
            if 0 <= nr < 6 and 0 <= nc < 8:
                if (nr, nc) not in reachable and walkability_grid[nr][nc]:
                    reachable.add((nr, nc))
                    queue.append((nr, nc))

    return reachable


def check_entry_to_exit(
    walkability_grid: List[List[bool]],
    entry_direction: str,
    exit_directions: List[str],
) -> TraversabilityResult:
    """Check if any entry position can reach any exit position.

    Args:
        walkability_grid: 8x6 grid of walkability
        entry_direction: Direction player enters from
        exit_directions: Directions player can exit to

    Returns:
        TraversabilityResult with reachability info
    """
    # Get walkable entry positions
    entry_positions = get_walkable_edge_positions(walkability_grid, entry_direction)

    if not entry_positions:
        return TraversabilityResult(
            is_traversable=False,
            reachable_tiles=set(),
            entry_direction=entry_direction,
            reachable_exits=set(),
            unreachable_exits=set(exit_directions),
        )

    # Find all reachable tiles from any entry point
    all_reachable: Set[Tuple[int, int]] = set()
    for entry_pos in entry_positions:
        reachable = bfs_reachable(walkability_grid, entry_pos)
        all_reachable.update(reachable)

    # Check which exits are reachable
    reachable_exits: Set[str] = set()
    unreachable_exits: Set[str] = set()

    for exit_dir in exit_directions:
        exit_positions = get_edge_positions(exit_dir)
        # Check if any exit position is reachable
        if any(pos in all_reachable for pos in exit_positions):
            reachable_exits.add(exit_dir)
        else:
            unreachable_exits.add(exit_dir)

    return TraversabilityResult(
        is_traversable=len(reachable_exits) > 0,
        reachable_tiles=all_reachable,
        entry_direction=entry_direction,
        reachable_exits=reachable_exits,
        unreachable_exits=unreachable_exits,
    )


def check_full_traversability(
    walkability_grid: List[List[bool]],
    navigation: Dict[str, Optional[int]],
) -> Dict[str, TraversabilityResult]:
    """Check traversability from all entry directions to all exits.

    Args:
        walkability_grid: 8x6 grid of walkability
        navigation: Dict mapping direction to neighbor screen index
                   (None or 0xFF/0xFE means no connection)

    Returns:
        Dict mapping entry_direction to TraversabilityResult
    """
    # Determine active entry/exit directions
    active_directions: List[str] = []
    for direction in ["up", "down", "left", "right"]:
        nav_value = navigation.get(direction)
        # Active if connected (not None, not 0xFF blocked, not 0xFE building)
        if nav_value is not None and nav_value < 0xFE:
            active_directions.append(direction)

    results: Dict[str, TraversabilityResult] = {}

    for entry_dir in active_directions:
        # Entry from a direction means we came from that neighbor
        # So we want to exit to any OTHER active direction
        exit_dirs = [d for d in active_directions if d != entry_dir]

        if exit_dirs:
            result = check_entry_to_exit(walkability_grid, entry_dir, exit_dirs)
            results[entry_dir] = result

    return results


def get_screen_navigation_dict(
    nav_right: int,
    nav_left: int,
    nav_down: int,
    nav_up: int,
) -> Dict[str, Optional[int]]:
    """Convert screen navigation values to a dict.

    Args:
        nav_right: Screen index right (or 0xFF/0xFE)
        nav_left: Screen index left
        nav_down: Screen index down
        nav_up: Screen index up

    Returns:
        Dict mapping direction to value
    """
    return {
        "right": nav_right if nav_right < 0xFE else None,
        "left": nav_left if nav_left < 0xFE else None,
        "down": nav_down if nav_down < 0xFE else None,
        "up": nav_up if nav_up < 0xFE else None,
    }
