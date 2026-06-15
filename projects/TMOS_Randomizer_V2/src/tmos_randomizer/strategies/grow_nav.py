"""Turn a grow grid layout into WorldScreen navigation bytes.

Grow (TMOS_Strategy_Lab) produces, per section, a grid ``{(x, y): screen_index}``
where every grid-adjacency is edge-valid by construction (aligned walkable tiles).
This module realizes that layout as navigation: grid-adjacent cells are wired
bidirectionally, and edges with no grid neighbor are blocked (0xFF) — except
building entrances (0xFE), which are preserved.

Pure function over screen objects: no ROM I/O, no grow import. The caller supplies
the grid and a ``{relative_index: screen}`` lookup, so this is trivially testable
and reusable regardless of where grow itself is invoked.
"""

from __future__ import annotations

from typing import Any, Dict, Tuple

NAV_BLOCKED = 0xFF
NAV_BUILDING_ENTRANCE = 0xFE

# (dx, dy) per nav direction, matching grow's DIRECTION_DELTAS.
_DIRECTION_DELTAS: Dict[str, Tuple[int, int]] = {
    "right": (1, 0),
    "left": (-1, 0),
    "down": (0, 1),
    "up": (0, -1),
}


def apply_grid_navigation(
    screens_by_index: Dict[int, Any],
    grid: Dict[Tuple[int, int], int],
    *,
    block_non_neighbors: bool = True,
    preserve_building_entrances: bool = True,
) -> int:
    """Wire navigation for one grown section's grid.

    Args:
        screens_by_index: Lookup ``{relative_index: screen}``. Each screen must
            expose settable ``screen_index_{right,left,up,down}`` attributes.
        grid: ``{(x, y): screen_index}`` placement from a grown section.
        block_non_neighbors: If True, edges with no grid neighbor are set to
            0xFF (blocked). If False, such edges are left untouched.
        preserve_building_entrances: If True, an edge currently set to 0xFE
            (building entrance) is never overwritten.

    Returns:
        Number of screens whose navigation was touched.
    """
    touched = 0
    for (x, y), idx in grid.items():
        scr = screens_by_index.get(idx)
        if scr is None:
            continue
        changed = False
        for direction, (dx, dy) in _DIRECTION_DELTAS.items():
            attr = f"screen_index_{direction}"
            neighbor_pos = (x + dx, y + dy)
            if neighbor_pos in grid:
                setattr(scr, attr, grid[neighbor_pos])
                changed = True
            elif block_non_neighbors:
                current = getattr(scr, attr)
                if preserve_building_entrances and current == NAV_BUILDING_ENTRANCE:
                    continue
                setattr(scr, attr, NAV_BLOCKED)
                changed = True
        if changed:
            touched += 1
    return touched
