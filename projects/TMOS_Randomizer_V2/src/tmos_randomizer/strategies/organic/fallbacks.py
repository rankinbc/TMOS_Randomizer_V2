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
    """Map every template section to a Flow section and merge N:1.

    The Flow plan (plan.world_plan) declares a small set of sections
    (1-2 OW, 2-4 TW, 1 DG, etc.). Template extraction produces many more
    (30+ per chapter). This function consolidates templates onto Flow
    sections so the UI pill count matches the Flow graph.

    Mapping rule: match by (section_type, is_past) first, fallback to
    type-only. Within a shared bucket, distribute template sections across
    flow sections with the fewest templates assigned so far.
    """
    from collections import defaultdict
    totals = {"sections_merged": 0, "screens_relocated": 0}

    if plan.world_plan is None:
        return totals

    for chapter_num, template in templates.items():
        placement = placements.get(chapter_num)
        if placement is None:
            continue
        flow_ch = plan.world_plan.get_chapter(chapter_num)
        if flow_ch is None or not flow_ch.sections:
            continue

        # Build (type, era) → [flow_section_id] index.
        flow_buckets: Dict[Tuple[str, bool], List[int]] = defaultdict(list)
        flow_section_meta: Dict[int, Tuple[SectionType, bool]] = {}
        for fs in flow_ch.sections:
            name = fs.section_type.name if hasattr(fs.section_type, "name") else str(fs.section_type)
            flow_buckets[(name, fs.is_past)].append(fs.section_id)
            flow_section_meta[fs.section_id] = (fs.section_type, fs.is_past)

        # Map each template section → flow section.
        template_to_flow: Dict[int, int] = {}
        flow_assigned: Dict[int, int] = defaultdict(int)
        for sec in template.sections:
            name = sec.section_type.name
            key = (name, sec.is_past)
            candidates = flow_buckets.get(key, [])
            if not candidates:
                # Fallback: same type, any era.
                candidates = [fid for (t, _p), fids in flow_buckets.items() for fid in fids if t == name]
            if not candidates:
                # Last resort: any flow section.
                candidates = list(flow_section_meta.keys())
            if candidates:
                best = min(candidates, key=lambda fid: flow_assigned[fid])
                template_to_flow[sec.section_id] = best
                flow_assigned[best] += 1

        # Group template sections by their target flow section.
        groups: Dict[int, List[SectionTemplate]] = defaultdict(list)
        for sec in template.sections:
            fid = template_to_flow.get(sec.section_id)
            if fid is not None:
                groups[fid].append(sec)

        # Merge each group into a single SectionTemplate with the flow section_id.
        merged_sections: List[SectionTemplate] = []
        for flow_id in sorted(groups):
            grp = groups[flow_id]
            # Anchor = largest template section in the group.
            grp.sort(key=lambda s: s.size, reverse=True)
            anchor = grp[0]

            # Rewrite placement keys for anchor (template_id → flow_id).
            _rekey_placement(placement, anchor.section_id, flow_id)
            anchor_meta = flow_section_meta.get(flow_id)
            if anchor_meta:
                anchor.section_type = anchor_meta[0]
                anchor.is_past = anchor_meta[1]
            anchor.section_id = flow_id

            # Merge remaining template sections INTO anchor.
            for other in grp[1:]:
                moved = _merge_section_into(other, anchor, placement)
                if moved > 0:
                    totals["sections_merged"] += 1
                    totals["screens_relocated"] += moved
                # Rekey any stragglers still keyed under old section_id.
                _rekey_placement(placement, other.section_id, flow_id)

            merged_sections.append(anchor)

        template.sections = merged_sections
        # Rebuild inter-section edges with flow section IDs (InterSectionEdge
        # is frozen so we create new instances).
        from .template import InterSectionEdge
        new_edges: List[InterSectionEdge] = []
        for edge in template.inter_section_edges:
            new_from = template_to_flow.get(edge.from_section_id, edge.from_section_id)
            new_to = template_to_flow.get(edge.to_section_id, edge.to_section_id)
            if new_from == new_to:
                continue  # became intra-section after merge
            new_edges.append(InterSectionEdge(
                from_section_id=new_from,
                from_screen=edge.from_screen,
                direction=edge.direction,
                to_section_id=new_to,
                to_screen=edge.to_screen,
            ))
        template.inter_section_edges = new_edges

    return totals


def _rekey_placement(
    placement: ChapterPlacement,
    old_section_id: int,
    new_section_id: int,
) -> None:
    """Rewrite all placement keys from old_section_id to new_section_id."""
    if old_section_id == new_section_id:
        return
    entries = [
        (pos, idx) for (sid, pos), idx in placement.placements.items()
        if sid == old_section_id
    ]
    for pos, idx in entries:
        del placement.placements[(old_section_id, pos)]
        placement.placements[(new_section_id, pos)] = idx


def _merge_section_into(
    stray: SectionTemplate,
    target: SectionTemplate,
    placement: ChapterPlacement,
) -> int:
    """Move every PLACED screen in ``stray`` to a free cell on ``target``'s edge.

    Critical: we iterate the actual placement keys, not ``stray.positions``,
    because the randomized placement rarely matches the template's original
    screen-per-position mapping. Using ``stray.positions`` here would duplicate
    every displaced screen (template.pos → `orphan_idx`, but
    `placement[(stray.id, pos)]` is usually a different screen).
    """
    # Collect what's actually placed in the stray section RIGHT NOW.
    stray_entries: List[Tuple[Tuple[int, int], int]] = [
        (pos, idx) for (sid, pos), idx in placement.placements.items()
        if sid == stray.section_id
    ]
    if not stray_entries:
        stray.positions.clear()
        return 0

    target_occupied: Set[Tuple[int, int]] = {
        pos for (sid, pos) in placement.placements if sid == target.section_id
    }
    if not target_occupied:
        target_occupied = {(0, 0)}

    # Which screen indices are already placed in target (so we never duplicate)?
    target_placed_idx: Set[int] = {
        idx for (sid, _pos), idx in placement.placements.items()
        if sid == target.section_id
    }

    moved = 0
    for stray_pos, placed_idx in stray_entries:
        # Remove from stray.
        placement.placements.pop((stray.section_id, stray_pos), None)

        if placed_idx in target_placed_idx:
            # Already lives in target — dropping the stray entry is enough.
            continue

        target_pos = _find_free_adjacent(target_occupied, target_occupied, max_radius=16)
        if target_pos is None:
            any_occupied = next(iter(target_occupied))
            target_pos = (any_occupied[0] + 1, any_occupied[1])

        placement.placements[(target.section_id, target_pos)] = placed_idx
        target.positions[placed_idx] = target_pos
        target.original_exit_mask[target_pos] = frozenset(DIRECTIONS)
        target_occupied.add(target_pos)
        target_placed_idx.add(placed_idx)
        moved += 1

    # Clear stray template state — nothing lives there any more.
    stray.positions.clear()
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
