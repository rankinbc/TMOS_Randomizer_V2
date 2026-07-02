"""ExitPosition walkability repair.

ExitPosition (WorldScreen byte 9) is the spawn point read on stairway
arrival, warp arrival, Content $01-$1F entry, and grid-position-0 fallback
(bank 4 $826B; hi nibble = X on the 16px grid 0-15, lo nibble = Y 0-13,
engine adds +8px centering). Organic's repair passes TS-swap arbitrary
screens' tilesets without re-checking ExitPosition, so an arrival point can
end up inside a wall in the new tileset. This pass fixes every arrival
screen after the pipeline settles.

Spec: knowledge/systems/screen-relocation-constraints.md (ExitPosition
Semantics).
"""

from __future__ import annotations

import logging
from collections import deque
from typing import Dict, Iterable, Set

from ...core.chapter import Chapter
from ...core.constants import CHAPTER_RESPAWN_SCREENS
from ...validation.tiles.categories import is_walkable
from ...validation.tiles.edges import build_tile_grid

logger = logging.getLogger(__name__)

# Screen = 8 x 6 tiles of 32px (256x192). ExitPosition is on a 16px grid
# (16 cols x 12 rows), so one tile = 2 x 2 exit-grid cells.
_TILE_COLS = 8
_TILE_ROWS = 6


def _exit_to_tile(exit_position: int) -> tuple:
    x16 = (exit_position >> 4) & 0x0F
    y16 = exit_position & 0x0F
    return (min(x16 // 2, _TILE_COLS - 1), min(y16 // 2, _TILE_ROWS - 1))


def _tile_to_exit(col: int, row: int) -> int:
    # Center of the 32px tile on the 16px grid.
    return ((col * 2 + 1) << 4) | min(row * 2 + 1, 0x0D)


def _arrival_screens(chapter: Chapter) -> Set[int]:
    """Screens whose ExitPosition the engine actually reads: stairway
    destinations, warp destinations (any screen is a potential $98C0 target,
    but only time-door-reachable ones matter — we conservatively include all
    stairway destinations + the chapter respawn screen + Content $01-$1F
    screens)."""
    out: Set[int] = set()
    respawn = CHAPTER_RESPAWN_SCREENS[chapter.chapter_num - 1]
    if respawn < chapter.screen_count:
        out.add(respawn)
    for screen in chapter:
        if screen.is_stairway:
            dest = screen.content
            if 0 <= dest < chapter.screen_count:
                out.add(dest)
        if 0x01 <= screen.content <= 0x1F:
            out.add(screen.relative_index)
    return out


def repair_exit_positions(
    chapters: Dict[int, Chapter],
    rom_data: bytes,
    extra_targets: Dict[int, Iterable[int]] | None = None,
) -> int:
    """Ensure every arrival screen's ExitPosition lands on a walkable tile.

    Moves ExitPosition to the nearest walkable tile (BFS on the 8x6 tile
    grid) when the current one is blocked. Returns count of screens fixed.
    ``extra_targets`` adds per-chapter screen indices (e.g. $98C0 warp
    destinations) to the repair set.
    """
    fixed = 0
    for chapter_num, chapter in chapters.items():
        targets = _arrival_screens(chapter)
        for idx in (extra_targets or {}).get(chapter_num, ()):  # type: ignore[union-attr]
            if 0 <= idx < chapter.screen_count:
                targets.add(idx)
        for idx in sorted(targets):
            screen = chapter.get_screen(idx)
            if screen is None:
                continue
            try:
                grid = build_tile_grid(
                    rom_data, screen.top_tiles, screen.bottom_tiles, screen.datapointer
                )
            except Exception:
                logger.warning(
                    "exitpos: tile grid failed for ch%s screen 0x%02X — skipped",
                    chapter_num, idx, exc_info=True,
                )
                continue
            col, row = _exit_to_tile(screen.exit_position)
            if is_walkable(grid[row][col]):
                continue
            new_tile = _nearest_walkable(grid, col, row)
            if new_tile is None:
                logger.warning(
                    "exitpos: ch%s screen 0x%02X has NO walkable tile — cannot fix",
                    chapter_num, idx,
                )
                continue
            screen.exit_position = _tile_to_exit(*new_tile)
            screen.mark_modified()
            fixed += 1
            logger.debug(
                "exitpos: ch%s screen 0x%02X moved to tile %s", chapter_num, idx, new_tile
            )
    return fixed


def _nearest_walkable(grid, col: int, row: int):
    seen = {(col, row)}
    queue: deque = deque([(col, row)])
    while queue:
        c, r = queue.popleft()
        if is_walkable(grid[r][c]):
            return (c, r)
        for dc, dr in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nc, nr = c + dc, r + dr
            if 0 <= nc < _TILE_COLS and 0 <= nr < _TILE_ROWS and (nc, nr) not in seen:
                seen.add((nc, nr))
                queue.append((nc, nr))
    return None
