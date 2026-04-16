"""Post-processing fallback passes — v4.1 organic strategy.

Spatial-only philosophy: every placed screen must sit at a grid position
that walkably connects to its neighbours. Reachability is achieved by
MOVING screens and CHANGING tilesets — never by wiring non-spatial nav
pointers. No screen is ever dropped; the grid is extended as needed until
every screen has an edge to stick to.

Cascade order invoked by the strategy:
    1. apply_section_consolidation  (Pass B — merge stray templates into flow sections)
    2. aggressive_blob_merge        (Pass A — relocate + TS-swap until each section
                                     is one walkable blob)
    3. (strict-spatial nav write)
"""

from __future__ import annotations

import random
import time
from collections import deque
from typing import Dict, List, Optional, Set, Tuple

from ...core.chapter import Chapter
from ...core.enums import SectionType, is_past_screen_index
from ...core.worldscreen import WorldScreen
from ...logic.navigation import DIRECTIONS, OPPOSITE_DIRECTIONS
from ...plan import RandomizationPlan
from ...validation.tiles.categories import is_walkable
from ...validation.tiles.edges import ScreenEdges, extract_edges
from .detect import _walkable_components
from .placement import ChapterPlacement
from .repair import _edges_aligned, run_chapter_repair
from .template import (
    DIRECTION_DELTAS,
    ChapterTemplate,
    SectionTemplate,
)


# =============================================================================
# Pass B — consolidate stray template sections into flow-represented ones
# =============================================================================

def apply_section_consolidation(
    *,
    chapters: Dict[int, Chapter],
    templates: Dict[int, ChapterTemplate],
    placements: Dict[int, ChapterPlacement],
    plan: RandomizationPlan,
) -> Dict[str, int]:
    """Merge stray templates (same (type, era) exceeding flow quota) into the
    largest same-bucket template so the UI section count matches the plan."""
    totals = {"sections_merged": 0, "screens_relocated": 0}
    for chapter_num, template in templates.items():
        placement = placements.get(chapter_num)
        if placement is None:
            continue

        from .detect import _find_stray_templates
        stray_ids = _find_stray_templates(template, plan)
        if not stray_ids:
            continue

        section_by_id = {s.section_id: s for s in template.sections}
        targets_by_key: Dict[Tuple[SectionType, bool], SectionTemplate] = {}
        for sec in template.sections:
            if sec.section_id in stray_ids:
                continue
            if sec.size <= 1:
                continue
            key = (sec.section_type, sec.is_past)
            curr = targets_by_key.get(key)
            if curr is None or sec.size > curr.size:
                targets_by_key[key] = sec

        for stray_id in stray_ids:
            stray = section_by_id.get(stray_id)
            if stray is None:
                continue
            target = targets_by_key.get((stray.section_type, stray.is_past))
            if target is None:
                continue
            moved = _merge_section_into(stray, target, placement)
            if moved > 0:
                totals["sections_merged"] += 1
                totals["screens_relocated"] += moved

        template.sections = [s for s in template.sections if s.positions]
    return totals


def _merge_section_into(
    stray: SectionTemplate,
    target: SectionTemplate,
    placement: ChapterPlacement,
) -> int:
    """Move every screen in ``stray`` to a free cell on ``target``'s edge."""
    if not stray.positions:
        return 0

    target_occupied: Set[Tuple[int, int]] = {
        pos for (sid, pos) in placement.placements if sid == target.section_id
    }
    if not target_occupied:
        target_occupied = {(0, 0)}

    moved = 0
    for orphan_idx, orphan_pos in list(stray.positions.items()):
        placement.placements.pop((stray.section_id, orphan_pos), None)
        stray.positions.pop(orphan_idx, None)

        target_pos = _find_free_adjacent(target_occupied, target_occupied, max_radius=16)
        if target_pos is None:
            # Force-extend by snapping onto the nearest occupied cell.
            any_occupied = next(iter(target_occupied))
            target_pos = (any_occupied[0] + 1, any_occupied[1])

        placement.placements[(target.section_id, target_pos)] = orphan_idx
        target.positions[orphan_idx] = target_pos
        target.original_exit_mask[target_pos] = frozenset(DIRECTIONS)
        target_occupied.add(target_pos)
        moved += 1

    return moved


# =============================================================================
# Pass A — aggressive blob merge
# =============================================================================

def aggressive_blob_merge(
    *,
    chapters: Dict[int, Chapter],
    templates: Dict[int, ChapterTemplate],
    placements: Dict[int, ChapterPlacement],
    rom_data: bytes,
    time_ms_per_chapter: int = 30_000,
    max_passes: int = 12,
    seed: int = 0,
) -> Dict[str, int]:
    """Until every section is a single walkable blob (or the budget runs out):
    relocate orphan-blob screens to edge cells of the main blob, then TS-swap
    them (and if needed their neighbour) until the new edge walkably aligns.

    No screen is ever dropped. If edges can't be aligned, the screen still
    stays placed at the edge — later passes may improve it.
    """
    totals = {
        "passes": 0,
        "relocations": 0,
        "ts_swaps_on_orphan": 0,
        "ts_swaps_on_neighbor": 0,
        "still_disconnected_sections": 0,
        "trunk_ts_swaps": 0,
        "trunk_unreached": 0,
    }
    master_rng = random.Random(seed or 19260817)
    for chapter_num, chapter in chapters.items():
        template = templates.get(chapter_num)
        placement = placements.get(chapter_num)
        if template is None or placement is None:
            continue
        chapter_rng = random.Random(master_rng.randrange(2**31))
        edge_cache: Dict[int, ScreenEdges] = {}
        _merge_chapter_sections(
            chapter=chapter,
            template=template,
            placement=placement,
            rom_data=rom_data,
            edge_cache=edge_cache,
            rng=chapter_rng,
            totals=totals,
            time_ms=time_ms_per_chapter,
            max_passes=max_passes,
        )
        # Final repair pass — let the normal repair loop clean up any edges
        # that still don't score well after relocations.
        run_chapter_repair(
            chapter=chapter,
            template=template,
            placement=placement,
            rom_data=rom_data,
            max_iterations=1500,
            time_ms=10_000,
            rng=random.Random(master_rng.randrange(2**31)),
        )
        # Trunk-grow pass — walk outward from screen 0 through grid neighbours,
        # rewriting tilesets as we go so every walkable edge aligns. Anything
        # we can't align gets logged in totals["trunk_unreached"].
        trunk_rng = random.Random(master_rng.randrange(2**31))
        grow_walkable_trunk(
            chapter=chapter,
            template=template,
            placement=placement,
            rom_data=rom_data,
            edge_cache=edge_cache,
            rng=trunk_rng,
            totals=totals,
        )
    return totals


def grow_walkable_trunk(
    *,
    chapter: Chapter,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
    totals: Dict[str, int],
) -> None:
    """BFS from screen 0 through grid-adjacent neighbours and cross-section
    edges, rewriting tilesets as we go so every traversed edge walkably
    aligns. Guarantees screen 0 is the growth anchor — anything unreachable
    after this pass is genuinely isolated (logged, not wired around)."""

    # (screen_idx -> (section_id, grid_pos)) and per-section grids.
    placement_by_idx: Dict[int, Tuple[int, Tuple[int, int]]] = {}
    for (sid, pos), idx in placement.placements.items():
        placement_by_idx[idx] = (sid, pos)
    if 0 not in placement_by_idx:
        return  # screen 0 wasn't placed — nothing to anchor on.

    section_grids: Dict[int, Dict[Tuple[int, int], int]] = {
        sec.section_id: placement.section_positions(sec.section_id)
        for sec in template.sections
    }
    section_by_id: Dict[int, SectionTemplate] = {
        s.section_id: s for s in template.sections
    }

    # Inter-section edges indexed by current (source screen idx → list of
    # (direction, target screen idx)). Accepts one-way originals — the
    # bidirectional nav writer will mirror them.
    inter_from: Dict[int, List[Tuple[str, int]]] = {}
    for edge in template.inter_section_edges:
        inter_from.setdefault(edge.from_screen, []).append(
            (edge.direction, edge.to_screen)
        )

    trunk: Set[int] = {0}
    frontier: deque = deque([0])

    while frontier:
        src_idx = frontier.popleft()
        src_info = placement_by_idx.get(src_idx)
        if src_info is None:
            continue
        src_section_id, src_pos = src_info
        grid = section_grids.get(src_section_id, {})

        # Grid neighbours in the same section.
        for direction, (dx, dy) in DIRECTION_DELTAS.items():
            npos = (src_pos[0] + dx, src_pos[1] + dy)
            nbr_idx = grid.get(npos)
            if nbr_idx is None or nbr_idx in trunk:
                continue
            if _ensure_edge_walkable(
                src_idx=src_idx,
                direction=direction,
                dst_idx=nbr_idx,
                chapter=chapter,
                rom_data=rom_data,
                edge_cache=edge_cache,
                rng=rng,
                totals=totals,
            ):
                trunk.add(nbr_idx)
                frontier.append(nbr_idx)

        # Inter-section edges originating at this screen.
        for direction, tgt_idx in inter_from.get(src_idx, []):
            if tgt_idx in trunk:
                continue
            if tgt_idx not in placement_by_idx:
                continue
            if _ensure_edge_walkable(
                src_idx=src_idx,
                direction=direction,
                dst_idx=tgt_idx,
                chapter=chapter,
                rom_data=rom_data,
                edge_cache=edge_cache,
                rng=rng,
                totals=totals,
            ):
                trunk.add(tgt_idx)
                frontier.append(tgt_idx)

        # Inter-section edges arriving at this screen (reverse direction) —
        # the bidirectional nav writer will mirror them, so the inbound target
        # is also trunk-reachable once its forward edge walkably aligns.
        for edge in template.inter_section_edges:
            if edge.to_screen != src_idx:
                continue
            other_idx = edge.from_screen
            if other_idx in trunk or other_idx not in placement_by_idx:
                continue
            opp = OPPOSITE_DIRECTIONS[edge.direction]
            if _ensure_edge_walkable(
                src_idx=src_idx,
                direction=opp,
                dst_idx=other_idx,
                chapter=chapter,
                rom_data=rom_data,
                edge_cache=edge_cache,
                rng=rng,
                totals=totals,
            ):
                trunk.add(other_idx)
                frontier.append(other_idx)

    totals["trunk_unreached"] += max(0, len(placement_by_idx) - len(trunk))


def _ensure_edge_walkable(
    *,
    src_idx: int,
    direction: str,
    dst_idx: int,
    chapter: Chapter,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
    totals: Dict[str, int],
) -> bool:
    """Return True iff the src→dst edge walkably aligns. If the current state
    doesn't align, try TS-swapping the destination screen (then the source,
    as a last resort) until it does. Commits any swap that produces alignment."""
    if _edges_aligned(
        chapter=chapter,
        src_idx=src_idx,
        direction=direction,
        dst_idx=dst_idx,
        rom_data=rom_data,
        edge_cache=edge_cache,
    ):
        return True

    # Prefer swapping the destination — the source is already part of the
    # established trunk, changing it could de-align existing members.
    dst_screen = chapter.get_screen(dst_idx)
    if dst_screen is not None and _ts_swap_until_aligned(
        screen=dst_screen,
        nbrs=[(OPPOSITE_DIRECTIONS[direction], src_idx)],
        chapter=chapter,
        rom_data=rom_data,
        edge_cache=edge_cache,
        rng=rng,
        max_candidates=80,
    ):
        totals["trunk_ts_swaps"] += 1
        return True

    # Last resort: swap the source. Accepts mild de-alignment with other
    # trunk members in exchange for reaching the destination.
    src_screen = chapter.get_screen(src_idx)
    if src_screen is not None and _ts_swap_until_aligned(
        screen=src_screen,
        nbrs=[(direction, dst_idx)],
        chapter=chapter,
        rom_data=rom_data,
        edge_cache=edge_cache,
        rng=rng,
        max_candidates=80,
    ):
        totals["trunk_ts_swaps"] += 1
        return True

    return False


def _merge_chapter_sections(
    *,
    chapter: Chapter,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
    totals: Dict[str, int],
    time_ms: int,
    max_passes: int,
) -> None:
    start = time.monotonic()

    # Which section currently owns screen 0 (chapter entry)? That section's
    # main blob MUST be the blob containing screen 0 — otherwise screen 0
    # gets treated as an orphan and relocated into a blob it can't align to,
    # stranding the player at game start.
    screen_zero_section_id: Optional[int] = None
    for (sid, _pos), idx in placement.placements.items():
        if idx == 0:
            screen_zero_section_id = sid
            break

    for pass_idx in range(max_passes):
        if (time.monotonic() - start) * 1000 > time_ms:
            break
        any_progress = False
        any_disc = False
        for section in template.sections:
            if section.size < 2:
                continue
            placed = placement.section_positions(section.section_id)
            if len(placed) < 2:
                continue
            blobs = _walkable_components(chapter, placed, rom_data, edge_cache)
            if len(blobs) <= 1:
                continue
            any_disc = True
            blobs.sort(key=len, reverse=True)
            main = set(blobs[0])
            # Override: if screen 0 lives in this section, it anchors the main
            # blob regardless of size.
            if section.section_id == screen_zero_section_id:
                zero_pos: Optional[Tuple[int, int]] = None
                for pos, idx in placed.items():
                    if idx == 0:
                        zero_pos = pos
                        break
                if zero_pos is not None:
                    for blob in blobs:
                        if zero_pos in blob:
                            main = set(blob)
                            break
            orphan_blobs = [b for b in blobs if b is not None and set(b) != main]
            for orphan_blob in orphan_blobs:
                for orphan_pos in sorted(orphan_blob):
                    integrated = _integrate_orphan(
                        section=section,
                        chapter=chapter,
                        placement=placement,
                        main=main,
                        orphan_pos=orphan_pos,
                        rom_data=rom_data,
                        edge_cache=edge_cache,
                        rng=rng,
                        totals=totals,
                    )
                    if integrated:
                        any_progress = True
        totals["passes"] += 1
        if not any_disc:
            break
        if not any_progress:
            break

    # Tally residuals.
    for section in template.sections:
        placed = placement.section_positions(section.section_id)
        if len(placed) < 2:
            continue
        blobs = _walkable_components(chapter, placed, rom_data, edge_cache)
        if len(blobs) > 1:
            totals["still_disconnected_sections"] += 1


def _integrate_orphan(
    *,
    section: SectionTemplate,
    chapter: Chapter,
    placement: ChapterPlacement,
    main: Set[Tuple[int, int]],
    orphan_pos: Tuple[int, int],
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
    totals: Dict[str, int],
    ts_candidates: int = 80,
) -> bool:
    """Relocate the orphan to a cell on the main blob's edge and try to
    align edges through TS swaps on the orphan (and if needed its neighbour).

    Returns True iff the orphan now walkably connects to main.
    """
    key = (section.section_id, orphan_pos)
    orphan_idx = placement.placements.get(key)
    if orphan_idx is None or orphan_idx in section.fixed_screens:
        return False
    orphan_screen = chapter.get_screen(orphan_idx)
    if orphan_screen is None:
        return False

    # Snapshot for rollback.
    orig_exit = section.original_exit_mask.get(orphan_pos)
    orig_triplet = (orphan_screen.top_tiles, orphan_screen.bottom_tiles, orphan_screen.datapointer)

    # Remove from current position.
    del placement.placements[key]
    if section.positions.get(orphan_idx) == orphan_pos:
        section.positions.pop(orphan_idx, None)

    occupied_ids: Set[Tuple[int, int]] = {
        pos for (sid, pos) in placement.placements if sid == section.section_id
    }

    candidates = _candidate_target_cells(main, occupied_ids, max_cells=20)
    if not candidates:
        # Nothing empty anywhere nearby — force-extend far from main.
        far = next(iter(main))
        candidates = [(far[0] + 1, far[1] + 1)]

    for target_pos in candidates:
        # Neighbours of the candidate cell that are in the main blob (we
        # must walkably match at least one).
        main_nbrs = _main_neighbours_of(target_pos, main, placement, section.section_id)
        if not main_nbrs:
            continue

        # Tentatively place.
        placement.placements[(section.section_id, target_pos)] = orphan_idx
        section.positions[orphan_idx] = target_pos
        section.original_exit_mask[target_pos] = frozenset(DIRECTIONS)

        if _any_aligned(
            orphan_idx=orphan_idx,
            main_nbrs=main_nbrs,
            chapter=chapter,
            rom_data=rom_data,
            edge_cache=edge_cache,
        ):
            totals["relocations"] += 1
            main.add(target_pos)
            return True

        # Try TS swap on the orphan.
        if _ts_swap_until_aligned(
            screen=orphan_screen,
            nbrs=main_nbrs,
            chapter=chapter,
            rom_data=rom_data,
            edge_cache=edge_cache,
            rng=rng,
            max_candidates=ts_candidates,
        ):
            totals["relocations"] += 1
            totals["ts_swaps_on_orphan"] += 1
            main.add(target_pos)
            return True

        # Try TS swap on ONE neighbour — if one aligns, done.
        # (Keep this bounded: the first neighbour that can be swapped wins.)
        success = False
        for direction_from_orphan, nbr_idx in main_nbrs:
            nbr_screen = chapter.get_screen(nbr_idx)
            if nbr_screen is None or nbr_idx in section.fixed_screens:
                continue
            if _ts_swap_until_aligned(
                screen=nbr_screen,
                nbrs=[(OPPOSITE_DIRECTIONS[direction_from_orphan], orphan_idx)],
                chapter=chapter,
                rom_data=rom_data,
                edge_cache=edge_cache,
                rng=rng,
                max_candidates=ts_candidates,
            ):
                totals["relocations"] += 1
                totals["ts_swaps_on_neighbor"] += 1
                main.add(target_pos)
                success = True
                break
        if success:
            return True

        # Rollback: this candidate doesn't work. Remove placement; try next.
        del placement.placements[(section.section_id, target_pos)]
        section.positions.pop(orphan_idx, None)

    # Nothing worked. Still place it on the first candidate so the grid
    # stays dense — walkability remains broken but the screen has an edge
    # to sit on, and subsequent passes may improve it.
    fallback = candidates[0]
    placement.placements[(section.section_id, fallback)] = orphan_idx
    section.positions[orphan_idx] = fallback
    section.original_exit_mask[fallback] = frozenset(DIRECTIONS)
    main.add(fallback)
    totals["relocations"] += 1
    return False


# =============================================================================
# Helpers
# =============================================================================

def _candidate_target_cells(
    main: Set[Tuple[int, int]],
    occupied: Set[Tuple[int, int]],
    max_cells: int,
) -> List[Tuple[int, int]]:
    """BFS outward from the main blob to find up to ``max_cells`` unoccupied
    grid positions adjacent to it, in depth-first order."""
    out: List[Tuple[int, int]] = []
    visited: Set[Tuple[int, int]] = set(main)
    frontier: deque = deque((pos, 0) for pos in main)
    max_depth = 8
    while frontier and len(out) < max_cells:
        pos, depth = frontier.popleft()
        if depth >= max_depth:
            continue
        for dx, dy in DIRECTION_DELTAS.values():
            cand = (pos[0] + dx, pos[1] + dy)
            if cand in visited:
                continue
            visited.add(cand)
            if cand in occupied:
                frontier.append((cand, depth + 1))
                continue
            out.append(cand)
            if len(out) >= max_cells:
                break
    return out


def _main_neighbours_of(
    target: Tuple[int, int],
    main: Set[Tuple[int, int]],
    placement: ChapterPlacement,
    section_id: int,
) -> List[Tuple[str, int]]:
    """Directions from ``target`` that land on main-blob cells, with the
    placed screen index at each neighbour."""
    out: List[Tuple[str, int]] = []
    for direction, (dx, dy) in DIRECTION_DELTAS.items():
        nbr = (target[0] + dx, target[1] + dy)
        if nbr not in main:
            continue
        idx = placement.placements.get((section_id, nbr))
        if idx is None:
            continue
        out.append((direction, idx))
    return out


def _any_aligned(
    *,
    orphan_idx: int,
    main_nbrs: List[Tuple[str, int]],
    chapter: Chapter,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> bool:
    for direction, nbr_idx in main_nbrs:
        if _edges_aligned(
            chapter=chapter,
            src_idx=orphan_idx,
            direction=direction,
            dst_idx=nbr_idx,
            rom_data=rom_data,
            edge_cache=edge_cache,
        ):
            return True
    return False


def _all_aligned(
    *,
    orphan_idx: int,
    constraints: List[Tuple[str, int]],
    chapter: Chapter,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> bool:
    """True iff EVERY (direction, neighbour_idx) pair walkably aligns."""
    for direction, nbr_idx in constraints:
        if not _edges_aligned(
            chapter=chapter,
            src_idx=orphan_idx,
            direction=direction,
            dst_idx=nbr_idx,
            rom_data=rom_data,
            edge_cache=edge_cache,
        ):
            return False
    return True


def _ts_swap_until_aligned(
    *,
    screen: WorldScreen,
    nbrs: List[Tuple[str, int]],
    chapter: Chapter,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
    max_candidates: int,
) -> bool:
    """Mutate ``screen``'s (top_tiles, bottom_tiles, datapointer) until at
    least one of its edges in ``nbrs`` walkably aligns. Commits the mutation
    on success; reverts on failure."""
    triplets = _candidate_triplets(
        chapter,
        parent_world=screen.parent_world,
        is_past=is_past_screen_index(chapter.chapter_num, screen.relative_index),
        exclude_self_idx=screen.relative_index,
    )
    if not triplets:
        return False
    rng.shuffle(triplets)
    triplets = triplets[:max_candidates]

    original = (screen.top_tiles, screen.bottom_tiles, screen.datapointer)
    for top, bot, dp in triplets:
        screen.top_tiles = top
        screen.bottom_tiles = bot
        screen.datapointer = dp
        edge_cache.pop(screen.relative_index, None)
        if _any_aligned(
            orphan_idx=screen.relative_index,
            main_nbrs=nbrs,
            chapter=chapter,
            rom_data=rom_data,
            edge_cache=edge_cache,
        ):
            screen.mark_modified()
            return True

    screen.top_tiles, screen.bottom_tiles, screen.datapointer = original
    edge_cache.pop(screen.relative_index, None)
    return False


def _candidate_triplets(
    chapter: Chapter,
    parent_world: int,
    is_past: bool,
    exclude_self_idx: int,
) -> List[Tuple[int, int, int]]:
    """Unique (top_tiles, bottom_tiles, datapointer) triplets for this chapter.

    Prefer same parent_world (visual consistency) but widen to any era-matching
    screen when that isn't enough. Strictly same era (is_past) — we never mix
    past/present tilesets.
    """
    seen: Set[Tuple[int, int, int]] = set()
    primary: List[Tuple[int, int, int]] = []
    secondary: List[Tuple[int, int, int]] = []
    for scr in chapter:
        if scr.relative_index == exclude_self_idx:
            continue
        if is_past_screen_index(chapter.chapter_num, scr.relative_index) != is_past:
            continue
        triplet = (scr.top_tiles, scr.bottom_tiles, scr.datapointer)
        if triplet in seen:
            continue
        seen.add(triplet)
        if scr.parent_world == parent_world:
            primary.append(triplet)
        else:
            secondary.append(triplet)
    return primary + secondary


def _find_free_adjacent(
    main: Set[Tuple[int, int]],
    occupied: Set[Tuple[int, int]],
    max_radius: int = 3,
) -> Optional[Tuple[int, int]]:
    """Legacy helper (used by apply_section_consolidation): BFS for first
    free cell within ``max_radius`` hops of the main blob."""
    visited: Set[Tuple[int, int]] = set()
    queue: deque = deque()
    for pos in main:
        queue.append((pos, 0))
        visited.add(pos)
    while queue:
        pos, depth = queue.popleft()
        if depth >= max_radius:
            continue
        for dx, dy in DIRECTION_DELTAS.values():
            cand = (pos[0] + dx, pos[1] + dy)
            if cand in visited:
                continue
            visited.add(cand)
            if cand not in occupied:
                return cand
            queue.append((cand, depth + 1))
    return None


# =============================================================================
# Backwards-compat shim so an import of drop_unmergeable_orphans doesn't raise.
# Per the user: screens are never dropped. This stub exists only because the
# orchestrator briefly referenced it in a WIP state.
# =============================================================================

def drop_unmergeable_orphans(*args, **kwargs) -> Dict[str, int]:
    """No-op. Spatial-only philosophy: every screen stays placed."""
    return {"dropped": 0}
