"""V2 tile pathfinding re-exports.

Used by reachability / edge_compatibility / softlock metrics when V2 is
available. Falls back to a ``None`` sentinel when V2 is unreachable — callers
check for that and degrade gracefully.
"""
from __future__ import annotations

from . import V2_AVAILABLE

if V2_AVAILABLE:
    try:
        from tmos_randomizer.validation.tiles.pathfinding import (  # type: ignore[import-untyped]
            TraversabilityResult,
            bfs_reachable,
            build_walkability_grid,
            check_entry_to_exit,
            check_full_traversability,
            get_edge_positions,
            get_screen_navigation_dict,
            get_walkable_edge_positions,
        )

        PATHFINDING_AVAILABLE = True
    except Exception:  # noqa: BLE001
        PATHFINDING_AVAILABLE = False
        TraversabilityResult = None  # type: ignore[assignment]
        build_walkability_grid = None  # type: ignore[assignment]
        check_full_traversability = None  # type: ignore[assignment]
        check_entry_to_exit = None  # type: ignore[assignment]
        bfs_reachable = None  # type: ignore[assignment]
        get_edge_positions = None  # type: ignore[assignment]
        get_walkable_edge_positions = None  # type: ignore[assignment]
        get_screen_navigation_dict = None  # type: ignore[assignment]
else:  # pragma: no cover
    PATHFINDING_AVAILABLE = False
    TraversabilityResult = None  # type: ignore[assignment]
    build_walkability_grid = None  # type: ignore[assignment]
    check_full_traversability = None  # type: ignore[assignment]
    check_entry_to_exit = None  # type: ignore[assignment]
    bfs_reachable = None  # type: ignore[assignment]
    get_edge_positions = None  # type: ignore[assignment]
    get_walkable_edge_positions = None  # type: ignore[assignment]
    get_screen_navigation_dict = None  # type: ignore[assignment]


__all__ = [
    "PATHFINDING_AVAILABLE",
    "TraversabilityResult",
    "bfs_reachable",
    "build_walkability_grid",
    "check_entry_to_exit",
    "check_full_traversability",
    "get_edge_positions",
    "get_screen_navigation_dict",
    "get_walkable_edge_positions",
]
