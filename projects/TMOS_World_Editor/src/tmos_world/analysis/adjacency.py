"""Inter-screen adjacency & compatibility queries (spec §3.3, §4.1)."""
from __future__ import annotations

from src.tmos_world.analysis.tiles import Direction, edges_compatible, screen_edge_tiles
from src.tmos_world.model import Chapter, World


_OPPOSITE: dict[Direction, Direction] = {
    "right": "left",
    "left": "right",
    "up": "down",
    "down": "up",
}


def compatible_neighbors(
    world: World,
    chapter_num: int,
    screen_index: int,
    direction: Direction,
) -> list[int]:
    """Return the chapter-relative indices of screens whose opposing edge is
    edge-compatible with ``screen.<direction>``.

    Does NOT consider nav_* byte values — purely tile-compatibility.
    """
    chapter = _chapter(world, chapter_num)
    if not (0 <= screen_index < chapter.screen_count):
        raise IndexError(f"Screen {screen_index} out of range for chapter {chapter_num}")

    src_edge = screen_edge_tiles(world, chapter.screens[screen_index], direction)
    opp = _OPPOSITE[direction]
    out: list[int] = []
    for i, candidate in enumerate(chapter.screens):
        if i == screen_index:
            continue
        if edges_compatible(src_edge, screen_edge_tiles(world, candidate, opp)):
            out.append(i)
    return out


def _chapter(world: World, chapter_num: int) -> Chapter:
    for ch in world.chapters:
        if ch.number == chapter_num:
            return ch
    raise ValueError(f"Chapter {chapter_num} not found in world")
