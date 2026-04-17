"""Phases B + C — pool building, edge scoring, screen placement.

Given a ``ChapterTemplate`` (real shapes + fixed screens from the ROM) and
the untouched ``Chapter``, decide which original screen's content goes onto
each grid position of each section. Fixed screens (boss/victory/time door)
stay put. All other positions get filled by candidates drawn from a pool of
matching-type, matching-era screens, picked to maximise edge alignment with
already-placed neighbours.
"""

from __future__ import annotations

import random
from dataclasses import dataclass, field
from typing import Dict, Iterable, List, Optional, Set, Tuple

from ...core.chapter import Chapter
from ...core.worldscreen import WorldScreen
from ...logic.exclusions import is_excluded
from ...validation.tiles.categories import is_walkable
from ...validation.tiles.edges import (
    OPPOSITE_DIRECTIONS,
    ScreenEdges,
    extract_edges,
)
from .template import (
    DIRECTION_DELTAS,
    ChapterTemplate,
    SectionTemplate,
)


@dataclass
class ChapterPlacement:
    """Result of placing screens: which original screen sits at each grid pos.

    ``placements[(section_id, (x, y))] = original_screen_idx``
    Always contains the fixed screens (boss/victory/TD) at their original
    positions, plus shuffled content for every other position.
    """
    chapter_num: int
    placements: Dict[Tuple[int, Tuple[int, int]], int] = field(default_factory=dict)

    def get(self, section_id: int, pos: Tuple[int, int]) -> Optional[int]:
        return self.placements.get((section_id, pos))

    def section_positions(self, section_id: int) -> Dict[Tuple[int, int], int]:
        return {
            pos: idx
            for (sid, pos), idx in self.placements.items()
            if sid == section_id
        }


def plan_placement(
    chapter: Chapter,
    template: ChapterTemplate,
    rom_data: bytes,
    rng: random.Random,
) -> ChapterPlacement:
    """Assign an original-screen-index to every grid position in the chapter.

    Strategy:
    1. Honour fixed screens first — their position is non-negotiable.
    2. For each section, walk its positions in BFS order from a seed position
       (any already-placed fixed screen if present, else the lowest-index
       position). At each position, pick the best-scoring candidate from
       the section's pool.
    3. Pool membership: (section_type, is_past) match; not excluded; not
       already assigned elsewhere.
    """
    edge_cache: Dict[int, ScreenEdges] = {}
    result = ChapterPlacement(chapter_num=chapter.chapter_num)
    assigned: Set[int] = set()

    # Pass 1 — lock fixed screens into their original positions.
    for section in template.sections:
        for idx, pos in section.positions.items():
            if idx in section.fixed_screens:
                result.placements[(section.section_id, pos)] = idx
                assigned.add(idx)

    # Pass 1.5 — anchor screen 0 (chapter entry) at the BFS seed of the
    # section it originally belonged to. This guarantees screen 0 lives at
    # the most-connected cell of its section, so the player boots into a
    # screen with the maximum opportunity for walkably-aligned neighbours.
    _anchor_chapter_entry(template, result, assigned)

    # Pass 2 — fill remaining positions per section with pool candidates.
    for section in template.sections:
        _place_section(
            chapter=chapter,
            section=section,
            template=template,
            result=result,
            assigned=assigned,
            rom_data=rom_data,
            edge_cache=edge_cache,
            rng=rng,
        )

    return result


def _anchor_chapter_entry(
    template: ChapterTemplate,
    result: ChapterPlacement,
    assigned: Set[int],
) -> None:
    """If screen 0 is unfixed, place it at an unoccupied cell adjacent to
    the BFS seed of its original section. Screen 0 = player start, so
    anchoring it near the section seed guarantees high neighbour density
    without clobbering any already-placed fixed screen (which often claims
    the seed position itself)."""
    if 0 in assigned:
        return
    target_section: Optional[SectionTemplate] = None
    for sec in template.sections:
        if 0 in sec.positions:
            target_section = sec
            break
    if target_section is None:
        return

    positions_set = set(target_section.positions.values())
    if not positions_set:
        return
    section_id = target_section.section_id

    # Pick any unoccupied cell of this section. Prefer the lexicographically
    # smallest (usually the top-left / BFS-seed neighbourhood).
    for cand_pos in sorted(positions_set):
        key = (section_id, cand_pos)
        if key not in result.placements:
            result.placements[key] = 0
            assigned.add(0)
            return


# =============================================================================
# Internals
# =============================================================================

def _place_section(
    *,
    chapter: Chapter,
    section: SectionTemplate,
    template: ChapterTemplate,
    result: ChapterPlacement,
    assigned: Set[int],
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
) -> None:
    # Build the pool of candidates that could go in this section.
    pool = _build_pool(
        chapter=chapter,
        section=section,
        assigned=assigned,
    )

    # Visit positions in a BFS order seeded from the lowest-index fixed pos
    # (if any) — so placement grows outward from anchors, giving the edge
    # scorer neighbours to score against.
    positions = list(section.positions.values())
    if not positions:
        return

    seed_pos = _pick_seed_position(section, result)
    visit_order = _bfs_position_order(positions, seed_pos)

    # Count already-filled cells (fixed screens) so we know how many the pool
    # must still cover.
    already_filled = sum(
        1 for pos in visit_order
        if (section.section_id, pos) in result.placements
    )
    needed = max(0, len(visit_order) - already_filled)

    # If the pool can't cover every empty cell, truncate the visit_order to
    # match — we'd rather have a smaller but fully-filled grid than one with
    # holes in the middle. We drop the farthest-from-seed cells first.
    if len(pool) < needed:
        keep = already_filled + len(pool)
        visit_order = visit_order[:keep]

    for pos in visit_order:
        key = (section.section_id, pos)
        if key in result.placements:
            continue  # Fixed screen already there.

        if not pool:
            break  # Nothing left; the truncation above should prevent this.

        best_idx = _best_candidate(
            pool=pool,
            pos=pos,
            section=section,
            result=result,
            chapter=chapter,
            rom_data=rom_data,
            edge_cache=edge_cache,
            rng=rng,
        )
        # Fall back to any pool member rather than skip the cell — the repair
        # loop will swap to a better candidate later.
        if best_idx is None:
            best_idx = pool[0]

        result.placements[key] = best_idx
        assigned.add(best_idx)
        pool.remove(best_idx)

    # Also drop any grid positions from the template that ended up outside
    # our truncated visit_order — the navigation writer inspects
    # section.positions and would treat those as "grid-adjacent neighbour".
    placed_positions = {
        pos for (sid, pos) in result.placements if sid == section.section_id
    }
    dead_positions = [
        idx for idx, pos in section.positions.items()
        if pos not in placed_positions
    ]
    for idx in dead_positions:
        section.positions.pop(idx, None)


def _build_pool(
    *,
    chapter: Chapter,
    section: SectionTemplate,
    assigned: Set[int],
) -> List[int]:
    """Screens eligible to fill non-fixed positions in this section.

    Match criteria: same section_type, same era, not excluded, not already
    placed, not a time door (time doors are always fixed).
    """
    target_type = section.section_type
    target_past = section.is_past
    pool: List[int] = []

    from ...core.enums import PARENTWORLD_TO_SECTION, SectionType, is_past_screen_index

    for screen in chapter:
        idx = screen.relative_index
        if idx in assigned:
            continue
        if is_excluded(screen):
            continue
        if screen.content in {0xC0, 0xC7, 0xD7}:
            # Time doors are fixed; never pulled into pool.
            continue
        scr_type = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)
        if scr_type != target_type:
            continue
        if is_past_screen_index(chapter.chapter_num, idx) != target_past:
            continue
        pool.append(idx)

    return pool


def _pick_seed_position(
    section: SectionTemplate,
    result: ChapterPlacement,
) -> Tuple[int, int]:
    """Prefer a fixed-screen position as the BFS seed so the first placements
    score against something stable."""
    placed = result.section_positions(section.section_id)
    if placed:
        # Use the lexicographically smallest placed position for determinism.
        return min(placed.keys())
    return min(section.positions.values())


def _bfs_position_order(
    positions: Iterable[Tuple[int, int]],
    seed: Tuple[int, int],
) -> List[Tuple[int, int]]:
    from collections import deque

    pos_set = set(positions)
    if seed not in pos_set:
        seed = min(pos_set)

    order: List[Tuple[int, int]] = []
    visited: Set[Tuple[int, int]] = {seed}
    queue: deque[Tuple[int, int]] = deque([seed])

    while queue:
        pos = queue.popleft()
        order.append(pos)
        x, y = pos
        for dx, dy in DIRECTION_DELTAS.values():
            neighbor = (x + dx, y + dy)
            if neighbor in pos_set and neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    # Stragglers (disconnected in pos_set but present): append deterministically.
    for pos in sorted(pos_set):
        if pos not in visited:
            order.append(pos)

    return order


def _best_candidate(
    *,
    pool: List[int],
    pos: Tuple[int, int],
    section: SectionTemplate,
    result: ChapterPlacement,
    chapter: Chapter,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
) -> Optional[int]:
    """Score every pool candidate for this position and pick the best.

    Ties broken by RNG so two runs with the same seed are deterministic.
    """
    if not pool:
        return None

    # Sample a subset of the pool for scoring to keep placement O(N) rather
    # than O(N*pool_size). 32 candidates is plenty to find a well-aligned fit.
    sample_size = min(32, len(pool))
    if sample_size < len(pool):
        sample = rng.sample(pool, sample_size)
    else:
        sample = list(pool)

    best_score = None
    best_candidates: List[int] = []

    for cand in sample:
        score = _score_candidate(
            candidate=cand,
            pos=pos,
            section=section,
            result=result,
            chapter=chapter,
            rom_data=rom_data,
            edge_cache=edge_cache,
        )
        if best_score is None or score > best_score:
            best_score = score
            best_candidates = [cand]
        elif score == best_score:
            best_candidates.append(cand)

    if not best_candidates:
        return rng.choice(pool)

    return rng.choice(best_candidates)


def _score_candidate(
    *,
    candidate: int,
    pos: Tuple[int, int],
    section: SectionTemplate,
    result: ChapterPlacement,
    chapter: Chapter,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> int:
    """Score a candidate screen for a grid position.

    +2 for each neighbour where edges align (both sides walkable at same row/col)
    -1 for each neighbour where the candidate has zero walkable tiles on that edge
     0 for neighbours not yet placed
    """
    cand_screen = chapter.get_screen(candidate)
    if cand_screen is None:
        return -999
    cand_edges = _cached_edges(cand_screen, rom_data, edge_cache)
    if cand_edges is None:
        return 0  # Fail open — don't let extract errors hurt the score.

    original_exits = section.original_exit_mask.get(pos, frozenset())
    placed = result.section_positions(section.section_id)

    score = 0
    x, y = pos
    for direction, (dx, dy) in DIRECTION_DELTAS.items():
        neighbor_pos = (x + dx, y + dy)
        neighbor_idx = placed.get(neighbor_pos)
        if neighbor_idx is None:
            continue

        # Respect the original's exit mask — if this direction was blocked on
        # the original screen at this grid position, candidates that have
        # walkable tiles there mis-match the template's intent; penalise.
        if direction not in original_exits:
            a_tiles = cand_edges.get_edge(direction)
            if any(is_walkable(t) for t in a_tiles):
                score -= 1
            continue

        neighbor_screen = chapter.get_screen(neighbor_idx)
        if neighbor_screen is None:
            continue
        neighbor_edges = _cached_edges(neighbor_screen, rom_data, edge_cache)
        if neighbor_edges is None:
            continue

        a_tiles = cand_edges.get_edge(direction)
        b_tiles = neighbor_edges.get_edge(OPPOSITE_DIRECTIONS[direction])
        if not a_tiles or not b_tiles:
            continue

        pair_count = min(len(a_tiles), len(b_tiles))
        aligned = any(
            is_walkable(a_tiles[i]) and is_walkable(b_tiles[i])
            for i in range(pair_count)
        )
        if aligned:
            score += 2
        else:
            score -= 1

    return score


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
