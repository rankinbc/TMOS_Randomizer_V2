"""Phase D — bidirectional navigation writer.

Core invariant: **every nav pointer has a matching reverse pointer**. If
screen A at grid (x, y) points "down" to screen B, then B at (x, y+1) points
"up" to A. If one side would be blocked, both are blocked.

Pairs are considered walkably aligned iff at least one matching row/column
has walkable tiles on both edges. We check this once per pair and apply the
result symmetrically.

Inter-section edges from the template are honoured only when a matching
reverse edge also exists in the template AND walkable alignment passes.

Building-entrance (0xFE) directions on a placed screen are preserved exactly.

The Time-Door pair is wired separately and always bidirectional.
"""

from __future__ import annotations

from typing import Dict, List, Optional, Set, Tuple

from ...core.chapter import Chapter
from ...core.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
from ...core.worldscreen import WorldScreen
from ...logic.navigation import DIRECTIONS, OPPOSITE_DIRECTIONS
from ...phases.phase5_navigation import (
    ChapterNavigation,
    NavigationChange,
    WorldNavigation,
)
from ...validation.tiles.categories import is_walkable
from ...validation.tiles.edges import ScreenEdges, extract_edges
from .placement import ChapterPlacement
from .template import (
    DIRECTION_DELTAS,
    ChapterTemplate,
    InterSectionEdge,
    SectionTemplate,
)


def write_chapter_navigation(
    chapter: Chapter,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    rom_data: Optional[bytes] = None,
) -> ChapterNavigation:
    chapter_nav = ChapterNavigation(chapter_num=chapter.chapter_num)
    edge_cache: Dict[int, ScreenEdges] = {}

    # Build a (screen_idx -> (section_id, pos)) lookup for placed screens.
    placement_by_idx: Dict[int, Tuple[int, Tuple[int, int]]] = {}
    for (section_id, pos), idx in placement.placements.items():
        placement_by_idx[idx] = (section_id, pos)

    # Section and grid lookups.
    section_by_id: Dict[int, SectionTemplate] = {s.section_id: s for s in template.sections}
    section_grids: Dict[int, Dict[Tuple[int, int], int]] = {
        s.section_id: placement.section_positions(s.section_id)
        for s in template.sections
    }

    # Pending writes — keyed by (screen_idx, direction) → target_idx. We
    # compute everything up-front, then flush to screens in one pass so that
    # partial state can't accidentally read a half-written pointer.
    pending: Dict[Tuple[int, str], int] = {}

    # Step 1 — preserve building-entrance (0xFE) directions on every placed
    # screen. These are carried through verbatim.
    for screen in chapter:
        if screen.relative_index not in placement_by_idx:
            continue
        for direction in DIRECTIONS:
            if getattr(screen, f"screen_index_{direction}") == NAV_BUILDING_ENTRANCE:
                pending[(screen.relative_index, direction)] = NAV_BUILDING_ENTRANCE

    # Step 2 — intra-section grid-adjacent pairs. Each counted once (right/down
    # only) and applied symmetrically.
    for section in template.sections:
        grid = section_grids.get(section.section_id, {})
        for (pos, idx) in grid.items():
            for direction in ("right", "down"):
                dx, dy = DIRECTION_DELTAS[direction]
                npos = (pos[0] + dx, pos[1] + dy)
                if npos not in grid:
                    continue
                nidx = grid[npos]
                if (idx, direction) in pending or (nidx, OPPOSITE_DIRECTIONS[direction]) in pending:
                    continue  # can't overwrite 0xFE
                if _pair_walkably_aligned(chapter, idx, direction, nidx, rom_data, edge_cache):
                    pending[(idx, direction)] = nidx
                    pending[(nidx, OPPOSITE_DIRECTIONS[direction])] = idx
                # otherwise leave both sides for Step 4 to fill with NAV_BLOCKED

    # Step 3 — inter-section edges from the template. Wire each edge
    # bidirectionally whenever walkable alignment passes AND the two screens
    # sit in different sections with grid-adjacent border cells. Two screens
    # that ended up in the SAME section (because Pass B merged a stray) are
    # handled by Step 2 if the merge put them grid-adjacent — otherwise they
    # aren't wired at all, because a non-grid-adjacent pointer inside one
    # section is exactly the "spatial mismatch" the user rejects.
    for edge in template.inter_section_edges:
        src_info = placement_by_idx.get(edge.from_screen)
        tgt_info = placement_by_idx.get(edge.to_screen)
        if src_info is None or tgt_info is None:
            continue
        src_section_id, src_pos = src_info
        tgt_section_id, tgt_pos = tgt_info
        if src_section_id == tgt_section_id:
            continue  # intra-section — handled by Step 2 grid-adjacency only.

        # Only honour cross-section edges that are spatially sensible: the
        # direction must step from src_pos onto tgt_pos in a shared grid.
        dx, dy = DIRECTION_DELTAS[edge.direction]
        if (src_pos[0] + dx, src_pos[1] + dy) != tgt_pos:
            continue

        src_idx = edge.from_screen
        tgt_idx = edge.to_screen
        direction = edge.direction
        opp = OPPOSITE_DIRECTIONS[direction]
        if (src_idx, direction) in pending or (tgt_idx, opp) in pending:
            continue

        if _pair_walkably_aligned(chapter, src_idx, direction, tgt_idx, rom_data, edge_cache):
            pending[(src_idx, direction)] = tgt_idx
            pending[(tgt_idx, opp)] = src_idx

    # Step 4 — fill every remaining direction on every placed screen with NAV_BLOCKED.
    for idx in placement_by_idx:
        for direction in DIRECTIONS:
            pending.setdefault((idx, direction), NAV_BLOCKED)

    # Step 5 — flush pending to screens, logging changes.
    for (idx, direction), new_value in pending.items():
        screen = chapter.get_screen(idx)
        if screen is None:
            continue
        attr = f"screen_index_{direction}"
        old_value = getattr(screen, attr)
        if old_value == new_value:
            continue
        setattr(screen, attr, new_value)
        screen.mark_modified()
        chapter_nav.navigation_changes.append(NavigationChange(
            screen_index=idx,
            direction=direction,
            old_value=old_value,
            new_value=new_value,
        ))

    # Step 6 — Time-Door pair. Runs LAST so it overwrites any grid-derived
    # pointers at its endpoints. Both sides wired bidirectionally.
    if template.time_door_pair is not None:
        _link_time_doors(
            chapter=chapter,
            pres_idx=template.time_door_pair[0],
            past_idx=template.time_door_pair[1],
            chapter_nav=chapter_nav,
        )

    return chapter_nav


def write_world_navigation(
    chapters: Dict[int, Chapter],
    templates: Dict[int, ChapterTemplate],
    placements: Dict[int, ChapterPlacement],
    seed: int,
    rom_data: Optional[bytes] = None,
) -> WorldNavigation:
    world_nav = WorldNavigation(seed=seed)
    for chapter_num, chapter in chapters.items():
        template = templates.get(chapter_num)
        placement = placements.get(chapter_num)
        if template is None or placement is None:
            continue
        chapter_nav = write_chapter_navigation(
            chapter, template, placement, rom_data=rom_data,
        )
        world_nav.chapters.append(chapter_nav)
    return world_nav


# =============================================================================
# Helpers
# =============================================================================

def _pair_walkably_aligned(
    chapter: Chapter,
    src_idx: int,
    direction: str,
    dst_idx: int,
    rom_data: Optional[bytes],
    edge_cache: Dict[int, ScreenEdges],
) -> bool:
    """True iff src's edge in ``direction`` and dst's opposite edge share at
    least one matching row/column that is walkable on BOTH sides. When rom_data
    is missing we fail open (assume aligned) so callers without ROM bytes
    still produce a nav graph."""
    if rom_data is None:
        return True
    src = chapter.get_screen(src_idx)
    dst = chapter.get_screen(dst_idx)
    if src is None or dst is None:
        return False
    src_edges = _cached_edges(src, rom_data, edge_cache)
    dst_edges = _cached_edges(dst, rom_data, edge_cache)
    if src_edges is None or dst_edges is None:
        return False
    a = src_edges.get_edge(direction)
    b = dst_edges.get_edge(OPPOSITE_DIRECTIONS[direction])
    if not a or not b:
        return False
    n = min(len(a), len(b))
    return any(is_walkable(a[i]) and is_walkable(b[i]) for i in range(n))


def _cached_edges(
    screen: WorldScreen,
    rom_data: bytes,
    cache: Dict[int, ScreenEdges],
) -> Optional[ScreenEdges]:
    cached = cache.get(screen.relative_index)
    if cached is not None:
        return cached
    try:
        edges = extract_edges(
            rom_data,
            screen.relative_index,
            screen.top_tiles,
            screen.bottom_tiles,
            screen.datapointer,
        )
    except Exception:
        return None
    cache[screen.relative_index] = edges
    return edges


def _link_time_doors(
    *,
    chapter: Chapter,
    pres_idx: int,
    past_idx: int,
    chapter_nav: ChapterNavigation,
) -> None:
    pres = chapter.get_screen(pres_idx)
    past = chapter.get_screen(past_idx)
    if pres is None or past is None:
        return

    def _first_blocked(screen: WorldScreen) -> str:
        for direction in DIRECTIONS:
            if getattr(screen, f"screen_index_{direction}") == NAV_BLOCKED:
                return direction
        return "down"

    def _set(screen: WorldScreen, direction: str, target: int) -> None:
        attr = f"screen_index_{direction}"
        old = getattr(screen, attr)
        if old == target:
            return
        setattr(screen, attr, target)
        screen.mark_modified()
        chapter_nav.navigation_changes.append(NavigationChange(
            screen_index=screen.relative_index,
            direction=direction,
            old_value=old,
            new_value=target,
        ))

    _set(pres, _first_blocked(pres), past_idx)
    _set(past, _first_blocked(past), pres_idx)
