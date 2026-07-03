"""Final connectivity stitch — the closing guarantee of the organic pipeline.

Every earlier pass (placement, repair, consolidation, blob merge, trunk
grow, nav write) tries to build a connected world but none of them can
PROVE it: each operates on its own abstraction (grid cells, sections,
templates) rather than the graph the engine actually walks. This pass runs
after navigation bytes are written and closes the gap on the real thing:

    while a pristine-reachable screen is unreachable from the chapter's
    respawn root (following nav pointers + stairways + $98C0 warps):
        pick a reached/unreached pair with a free direction slot,
        TS-swap until the shared edge walkably aligns,
        write the two nav pointers,
    until nothing is left (or no legal stitch exists — logged loudly).

Pair preference keeps the spatial philosophy where possible: grid-adjacent
placement neighbours first, then same-section pairs, then anything.
"""

from __future__ import annotations

import logging
import random
from collections import deque
from typing import Dict, List, Optional, Set, Tuple

from ...core.chapter import Chapter
from ...core.constants import NAV_BLOCKED
from ...logic.navigation import DIRECTIONS, OPPOSITE_DIRECTIONS
from ...validation.tiles.edges import ScreenEdges
from .detect import _nav_reachable
from .fallbacks import _ensure_edge_walkable
from .placement import ChapterPlacement
from .template import DIRECTION_DELTAS, ChapterTemplate

logger = logging.getLogger(__name__)


def stitch_chapter_connectivity(
    *,
    chapter: Chapter,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    required: Set[int],
    rom_data: bytes,
    seed: int,
    totals: Optional[Dict[str, int]] = None,
) -> int:
    """Wire every required-but-unreached screen into the root component.

    Returns the number of edges stitched. Mutates nav pointers and (via
    TS-swap) tilesets in place.
    """
    totals = totals if totals is not None else {}
    # _ensure_edge_walkable increments these without setdefault.
    totals.setdefault("trunk_ts_swaps", 0)
    totals.setdefault("trunk_unreached", 0)
    rng = random.Random(seed ^ 0x57C4)
    edge_cache: Dict[int, ScreenEdges] = {}

    placement_by_idx: Dict[int, Tuple[int, Tuple[int, int]]] = {}
    for (sid, pos), idx in placement.placements.items():
        placement_by_idx[idx] = (sid, pos)

    stitched = 0
    # Hard bound: each round bridges one screen, but tier-4 sacrifices can
    # transiently re-orphan island members, so allow generous headroom.
    for _ in range(2 * len(required) + 16):
        reached = _nav_reachable(chapter, rom_data)
        missing = sorted(required - reached)
        if not missing:
            break
        pair = _pick_stitch_pair(
            chapter, placement_by_idx, reached, missing
        )
        if pair is None:
            logger.warning(
                "stitch: ch%s has %d required screens with no legal stitch "
                "(no free direction slots): %s",
                chapter.chapter_num,
                len(missing),
                [f"0x{m:02X}" for m in missing[:10]],
            )
            break
        src_idx, direction, dst_idx = pair
        # Force the tile edge walkable (TS-swaps if needed), then wire both
        # pointers. If alignment can't be made, wire anyway — a nav pointer
        # with a rough edge beats an unreachable screen — but log it.
        aligned = _ensure_edge_walkable(
            src_idx=src_idx,
            direction=direction,
            dst_idx=dst_idx,
            chapter=chapter,
            rom_data=rom_data,
            edge_cache=edge_cache,
            rng=rng,
            totals=totals,
        )
        if not aligned:
            logger.warning(
                "stitch: ch%s edge 0x%02X -%s-> 0x%02X wired without tile "
                "alignment (no TS-swap produced a walkable pair)",
                chapter.chapter_num, src_idx, direction, dst_idx,
            )
        src = chapter.get_screen(src_idx)
        dst = chapter.get_screen(dst_idx)
        setattr(src, f"screen_index_{direction}", dst_idx)
        setattr(dst, f"screen_index_{OPPOSITE_DIRECTIONS[direction]}", src_idx)
        src.mark_modified()
        dst.mark_modified()
        stitched += 1
        totals["stitched_edges"] = totals.get("stitched_edges", 0) + 1
    return stitched


def nav_component(chapter: Chapter, root: int) -> Set[int]:
    """Nav-pointer-only connected component of ``root`` (no stairs/warps).

    This is the graph the reachability oracle walks from screen 0, and what
    a player can browse without taking a stairway.
    """
    total = chapter.screen_count
    comp: Set[int] = {root}
    queue: deque = deque([root])
    while queue:
        idx = queue.popleft()
        scr = chapter.get_screen(idx)
        if scr is None:
            continue
        for d in DIRECTIONS:
            tgt = getattr(scr, f"screen_index_{d}")
            if not (0 <= tgt < total) or tgt in comp:
                continue
            comp.add(tgt)
            queue.append(tgt)
    return comp


def grow_screen0_component(
    *,
    chapter: Chapter,
    placement: ChapterPlacement,
    target_size: int,
    rom_data: bytes,
    seed: int,
    totals: Optional[Dict[str, int]] = None,
) -> int:
    """Wire screens into screen 0's nav-only component until it is at least
    as large as vanilla's (the oracle's reachability bar is exactly that
    component's relative size).

    Runs after the respawn-root stitch, reusing its pair picker — so pairs
    keep the same tier preferences (reciprocate, grid-adjacent, same
    section, same palette). Returns edges wired.
    """
    totals = totals if totals is not None else {}
    totals.setdefault("trunk_ts_swaps", 0)
    totals.setdefault("trunk_unreached", 0)
    rng = random.Random(seed ^ 0x0C0117)
    edge_cache: Dict[int, ScreenEdges] = {}

    placement_by_idx: Dict[int, Tuple[int, Tuple[int, int]]] = {}
    for (sid, pos), idx in placement.placements.items():
        placement_by_idx[idx] = (sid, pos)

    wired = 0
    for _ in range(32):
        comp = nav_component(chapter, 0)
        if len(comp) >= target_size:
            break
        missing = sorted(i for i in range(chapter.screen_count) if i not in comp)
        pair = _pick_stitch_pair(chapter, placement_by_idx, comp, missing)
        if pair is None:
            logger.warning(
                "grow0: ch%s screen-0 component stuck at %d/%d (no legal pair)",
                chapter.chapter_num, len(comp), target_size,
            )
            break
        src_idx, direction, dst_idx = pair
        _ensure_edge_walkable(
            src_idx=src_idx,
            direction=direction,
            dst_idx=dst_idx,
            chapter=chapter,
            rom_data=rom_data,
            edge_cache=edge_cache,
            rng=rng,
            totals=totals,
        )
        src = chapter.get_screen(src_idx)
        dst = chapter.get_screen(dst_idx)
        setattr(src, f"screen_index_{direction}", dst_idx)
        setattr(dst, f"screen_index_{OPPOSITE_DIRECTIONS[direction]}", src_idx)
        src.mark_modified()
        dst.mark_modified()
        wired += 1
        totals["grow0_edges"] = totals.get("grow0_edges", 0) + 1
    return wired


def _free_dirs(chapter: Chapter, idx: int) -> List[str]:
    scr = chapter.get_screen(idx)
    if scr is None:
        return []
    return [
        d for d in DIRECTIONS
        if getattr(scr, f"screen_index_{d}") == NAV_BLOCKED
    ]


def _pick_stitch_pair(
    chapter: Chapter,
    placement_by_idx: Dict[int, Tuple[int, Tuple[int, int]]],
    reached: Set[int],
    missing: List[int],
) -> Optional[Tuple[int, str, int]]:
    """Choose (reached_idx, direction, missing_idx) to wire.

    Tier 0: missing screen already points one-way at a reached screen whose
            reciprocal slot is free — add the reverse pointer (cheapest,
            restores a vanilla-style link).
    Tier 1: grid-adjacent placement neighbours (true spatial edge).
    Tier 2: same section, any free direction pair.
    Tier 3: any reached/missing pair with complementary free directions.
    Tier 4: missing screen has NO free slot (island loop) — sacrifice one of
            its pointers that targets another missing screen; the overwritten
            neighbour stays coverable by later rounds.
    """
    tier2: Optional[Tuple[int, str, int]] = None
    tier3: Optional[Tuple[int, str, int]] = None
    tier4: Optional[Tuple[int, str, int]] = None
    missing_set = set(missing)

    def _same_palette(a: int, b: int) -> bool:
        sa, sb = chapter.get_screen(a), chapter.get_screen(b)
        return (
            sa is not None
            and sb is not None
            and sa.worldscreen_color == sb.worldscreen_color
        )

    for m in missing:
        m_scr = chapter.get_screen(m)
        if m_scr is None:
            continue
        # Tier 0 — reciprocate an existing one-way pointer into the reached set.
        for d in DIRECTIONS:
            tgt = getattr(m_scr, f"screen_index_{d}")
            if tgt in reached:
                r_dir = OPPOSITE_DIRECTIONS[d]
                if r_dir in _free_dirs(chapter, tgt):
                    return (tgt, r_dir, m)
        m_free = _free_dirs(chapter, m)
        # Directions on the missing screen we may claim: free ones first;
        # otherwise (island loop) ones currently pointing at another missing
        # screen — that link is intra-island and expendable.
        m_sacrifice = [
            d for d in DIRECTIONS
            if d not in m_free
            and getattr(m_scr, f"screen_index_{d}") in missing_set
        ]
        if not m_free and not m_sacrifice:
            continue
        m_info = placement_by_idx.get(m)
        for r in reached:
            r_free = _free_dirs(chapter, r)
            if not r_free:
                continue
            usable = [d for d in r_free if OPPOSITE_DIRECTIONS[d] in m_free]
            if usable:
                r_info = placement_by_idx.get(r)
                if m_info and r_info and m_info[0] == r_info[0]:
                    # Same section: check true grid adjacency for tier 1.
                    (mx, my), (rx, ry) = m_info[1], r_info[1]
                    for d in usable:
                        dx, dy = DIRECTION_DELTAS[d]
                        if (rx + dx, ry + dy) == (mx, my):
                            return (r, d, m)  # tier 1 — take immediately
                    # Prefer same-palette pairs within the tier (biome
                    # clustering); a plain pair still fills the slot if no
                    # palette match ever shows up.
                    if tier2 is None or (
                        _same_palette(r, m)
                        and not _same_palette(tier2[0], tier2[2])
                    ):
                        tier2 = (r, usable[0], m)
                elif tier3 is None or (
                    _same_palette(r, m)
                    and not _same_palette(tier3[0], tier3[2])
                ):
                    tier3 = (r, usable[0], m)
            elif tier4 is None and m_sacrifice:
                sacrificial = [
                    d for d in r_free if OPPOSITE_DIRECTIONS[d] in m_sacrifice
                ]
                if sacrificial:
                    tier4 = (r, sacrificial[0], m)
    return tier2 or tier3 or tier4
