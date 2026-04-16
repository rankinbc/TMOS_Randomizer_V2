"""Iterative repair loop — v3 organic strategy.

After initial placement fills every grid cell, this module walks each section
looking for **broken edges** (two placed screens grid-adjacent whose edges
have zero aligned walkable tiles) and **orphans** (placed screens unreachable
from the section entry via walkable grid adjacency) and fixes them with a
cascade of repair actions:

    1. screen_swap — swap two placed cells in the same section.
    2. pool_pull   — replace a cell's screen with an unassigned pool member.
    3. accept      — mark the problem as a permanent caveat and move on.

Actions that don't improve the section's local score are reverted. The loop
runs with a wall-clock + iteration budget per chapter so the whole pipeline
stays under ~10 minutes even in the worst case.
"""

from __future__ import annotations

import random
import time
from collections import defaultdict, deque
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set, Tuple

from ...core.chapter import Chapter
from ...core.enums import PARENTWORLD_TO_SECTION, SectionType, is_past_screen_index
from ...core.worldscreen import WorldScreen
from ...logic.exclusions import is_excluded
from ...validation.tiles.categories import is_walkable
from ...validation.tiles.edges import (
    OPPOSITE_DIRECTIONS,
    ScreenEdges,
    extract_edges,
)
from .placement import ChapterPlacement
from .template import (
    DIRECTION_DELTAS,
    ChapterTemplate,
    SectionTemplate,
)


# =============================================================================
# Data types
# =============================================================================

@dataclass(frozen=True)
class Problem:
    """A fixable (or not) issue in a section's placement."""
    kind: str  # "broken_edge" | "orphan"
    section_id: int
    position: Tuple[int, int]
    neighbor_position: Optional[Tuple[int, int]] = None
    direction: Optional[str] = None

    @property
    def severity(self) -> int:
        return {"orphan": 50, "broken_edge": 20}.get(self.kind, 1)

    def key(self) -> Tuple:
        return (self.kind, self.section_id, self.position, self.neighbor_position, self.direction)


@dataclass
class RepairBudget:
    max_iterations: int = 5000
    time_ms: int = 30_000
    iterations_used: int = 0
    started: float = field(default_factory=time.monotonic)

    def alive(self) -> bool:
        if self.iterations_used >= self.max_iterations:
            return False
        if (time.monotonic() - self.started) * 1000 >= self.time_ms:
            return False
        return True

    def tick(self) -> None:
        self.iterations_used += 1

    def reset_clock(self) -> None:
        self.started = time.monotonic()
        self.iterations_used = 0


@dataclass
class RepairReport:
    chapter_num: int
    iterations_used: int = 0
    actions_applied: Dict[str, int] = field(default_factory=lambda: defaultdict(int))
    accepted_problems: List[Problem] = field(default_factory=list)
    broken_edges_before: int = 0
    broken_edges_after: int = 0
    orphans_before: int = 0
    orphans_after: int = 0
    final_score: int = 0


# =============================================================================
# Public entry points
# =============================================================================

def run_chapter_repair(
    *,
    chapter: Chapter,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    max_iterations: int = 5000,
    time_ms: int = 30_000,
    rng: Optional[random.Random] = None,
) -> RepairReport:
    """Repair every section in a chapter. Mutates ``placement`` in place."""
    report = RepairReport(chapter_num=chapter.chapter_num)
    rng = rng or random.Random(chapter.chapter_num)
    edge_cache: Dict[int, ScreenEdges] = {}

    report.broken_edges_before = sum(
        _count_broken_edges(chapter, sec, placement, rom_data, edge_cache)
        for sec in template.sections
    )
    report.orphans_before = sum(
        len(_find_orphans(chapter, sec, placement, rom_data, edge_cache))
        for sec in template.sections
    )

    # Sections sharing (type, is_past) can swap screens across their boundaries
    # — the pool is conceptually shared. Index it once per chapter.
    compat_index = _build_compat_index(template)

    for section in template.sections:
        if len(section.positions) <= 1:
            continue
        budget = RepairBudget(max_iterations=max_iterations, time_ms=time_ms)
        _repair_section(
            chapter=chapter,
            section=section,
            template=template,
            placement=placement,
            rom_data=rom_data,
            edge_cache=edge_cache,
            compat_index=compat_index,
            report=report,
            budget=budget,
            rng=rng,
        )
        report.iterations_used += budget.iterations_used

    report.broken_edges_after = sum(
        _count_broken_edges(chapter, sec, placement, rom_data, edge_cache)
        for sec in template.sections
    )
    report.orphans_after = sum(
        len(_find_orphans(chapter, sec, placement, rom_data, edge_cache))
        for sec in template.sections
    )
    report.final_score = sum(
        _score_section(chapter, sec, placement, rom_data, edge_cache)
        for sec in template.sections
    )
    return report


def run_world_repair(
    *,
    chapters: Dict[int, Chapter],
    templates: Dict[int, ChapterTemplate],
    placements: Dict[int, ChapterPlacement],
    rom_data: bytes,
    max_iterations: int = 5000,
    time_ms_per_chapter: int = 30_000,
    seed: int = 0,
) -> Dict[int, RepairReport]:
    """Run ``run_chapter_repair`` on every chapter. Returns per-chapter reports."""
    reports: Dict[int, RepairReport] = {}
    master_rng = random.Random(seed)
    for chapter_num in sorted(chapters):
        chapter = chapters[chapter_num]
        template = templates.get(chapter_num)
        placement = placements.get(chapter_num)
        if template is None or placement is None:
            continue
        # Per-chapter RNG so runs stay deterministic but chapters are uncorrelated.
        chapter_rng = random.Random(master_rng.randrange(2**31))
        reports[chapter_num] = run_chapter_repair(
            chapter=chapter,
            template=template,
            placement=placement,
            rom_data=rom_data,
            max_iterations=max_iterations,
            time_ms=time_ms_per_chapter,
            rng=chapter_rng,
        )
    return reports


# =============================================================================
# Section repair loop
# =============================================================================

def _repair_section(
    *,
    chapter: Chapter,
    section: SectionTemplate,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    compat_index: Dict[Tuple[SectionType, bool], List[int]],
    report: RepairReport,
    budget: RepairBudget,
    rng: random.Random,
) -> None:
    accepted: Set[Tuple] = set()
    pool = _build_available_pool(chapter, section, placement)
    no_progress_sweeps = 0

    while budget.alive() and no_progress_sweeps < 4:
        problems = [
            p for p in _diagnose_section(
                chapter, section, placement, rom_data, edge_cache,
            )
            if p.key() not in accepted
        ]
        if not problems:
            break

        progress = False
        for problem in problems:
            if not budget.alive():
                break

            if _try_screen_swap(
                problem=problem,
                chapter=chapter,
                section=section,
                placement=placement,
                rom_data=rom_data,
                edge_cache=edge_cache,
                rng=rng,
            ):
                report.actions_applied["screen_swap"] += 1
                budget.tick()
                progress = True
                # A successful swap in this section may unlock problems we
                # previously gave up on — clear accepted so they get retried.
                accepted.clear()
                break  # re-diagnose from scratch

            if _try_cross_section_swap(
                problem=problem,
                chapter=chapter,
                section=section,
                template=template,
                placement=placement,
                rom_data=rom_data,
                edge_cache=edge_cache,
                compat_index=compat_index,
                rng=rng,
            ):
                report.actions_applied["cross_section_swap"] += 1
                budget.tick()
                progress = True
                accepted.clear()
                break

            if _try_pool_pull(
                problem=problem,
                chapter=chapter,
                section=section,
                placement=placement,
                pool=pool,
                rom_data=rom_data,
                edge_cache=edge_cache,
                rng=rng,
            ):
                report.actions_applied["pool_pull"] += 1
                budget.tick()
                progress = True
                accepted.clear()
                break

            if _try_tilesection_swap(
                problem=problem,
                chapter=chapter,
                section=section,
                placement=placement,
                rom_data=rom_data,
                edge_cache=edge_cache,
                rng=rng,
            ):
                report.actions_applied["tilesection_swap"] += 1
                budget.tick()
                progress = True
                accepted.clear()
                break

            # None of the actions improved things for this problem — accept it.
            accepted.add(problem.key())
            report.accepted_problems.append(problem)
            report.actions_applied["accept"] += 1

        if not progress:
            no_progress_sweeps += 1
        else:
            no_progress_sweeps = 0


# =============================================================================
# Diagnosis
# =============================================================================

def _diagnose_section(
    chapter: Chapter,
    section: SectionTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> List[Problem]:
    """Return problems in this section, sorted by severity (high first)."""
    problems: List[Problem] = []
    placed = placement.section_positions(section.section_id)

    # Broken edges — each grid-adjacent pair counted once (right/down only).
    seen: Set[Tuple[Tuple[int, int], Tuple[int, int]]] = set()
    for pos, idx in placed.items():
        for direction in ("right", "down"):
            dx, dy = DIRECTION_DELTAS[direction]
            npos = (pos[0] + dx, pos[1] + dy)
            if npos not in placed:
                continue
            pair = tuple(sorted((pos, npos)))
            if pair in seen:
                continue
            seen.add(pair)
            if not _edges_aligned(
                chapter=chapter,
                src_idx=idx,
                direction=direction,
                dst_idx=placed[npos],
                rom_data=rom_data,
                edge_cache=edge_cache,
            ):
                problems.append(Problem(
                    kind="broken_edge",
                    section_id=section.section_id,
                    position=pos,
                    neighbor_position=npos,
                    direction=direction,
                ))

    # Orphans — placed screens unreachable from section entry.
    orphans = _find_orphans(chapter, section, placement, rom_data, edge_cache)
    for pos in orphans:
        problems.append(Problem(
            kind="orphan",
            section_id=section.section_id,
            position=pos,
        ))

    problems.sort(key=lambda p: -p.severity)
    return problems


def _find_orphans(
    chapter: Chapter,
    section: SectionTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> List[Tuple[int, int]]:
    """Positions unreachable from section entry via walkable grid adjacency."""
    placed = placement.section_positions(section.section_id)
    if not placed:
        return []
    entry = min(placed.keys())  # deterministic entry

    reachable: Set[Tuple[int, int]] = {entry}
    queue: deque = deque([entry])
    while queue:
        pos = queue.popleft()
        idx = placed[pos]
        for direction, (dx, dy) in DIRECTION_DELTAS.items():
            npos = (pos[0] + dx, pos[1] + dy)
            if npos not in placed or npos in reachable:
                continue
            if _edges_aligned(
                chapter=chapter,
                src_idx=idx,
                direction=direction,
                dst_idx=placed[npos],
                rom_data=rom_data,
                edge_cache=edge_cache,
            ):
                reachable.add(npos)
                queue.append(npos)

    return [pos for pos in placed if pos not in reachable]


def _count_broken_edges(
    chapter: Chapter,
    section: SectionTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> int:
    placed = placement.section_positions(section.section_id)
    n = 0
    seen: Set[Tuple[Tuple[int, int], Tuple[int, int]]] = set()
    for pos, idx in placed.items():
        for direction in ("right", "down"):
            dx, dy = DIRECTION_DELTAS[direction]
            npos = (pos[0] + dx, pos[1] + dy)
            if npos not in placed:
                continue
            pair = tuple(sorted((pos, npos)))
            if pair in seen:
                continue
            seen.add(pair)
            if not _edges_aligned(
                chapter=chapter,
                src_idx=idx,
                direction=direction,
                dst_idx=placed[npos],
                rom_data=rom_data,
                edge_cache=edge_cache,
            ):
                n += 1
    return n


# =============================================================================
# Scoring
# =============================================================================

def _score_section(
    chapter: Chapter,
    section: SectionTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> int:
    placed = placement.section_positions(section.section_id)
    score = 0
    seen: Set[Tuple[Tuple[int, int], Tuple[int, int]]] = set()
    for pos, idx in placed.items():
        for direction in ("right", "down"):
            dx, dy = DIRECTION_DELTAS[direction]
            npos = (pos[0] + dx, pos[1] + dy)
            if npos not in placed:
                continue
            pair = tuple(sorted((pos, npos)))
            if pair in seen:
                continue
            seen.add(pair)
            if _edges_aligned(
                chapter=chapter,
                src_idx=idx,
                direction=direction,
                dst_idx=placed[npos],
                rom_data=rom_data,
                edge_cache=edge_cache,
            ):
                score += 2
            else:
                score -= 20
    # Orphan penalty.
    score -= 50 * len(_find_orphans(chapter, section, placement, rom_data, edge_cache))
    return score


# =============================================================================
# Actions
# =============================================================================

def _try_screen_swap(
    *,
    problem: Problem,
    chapter: Chapter,
    section: SectionTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
    max_candidates: int = 12,
) -> bool:
    """Swap the problem cell with another non-fixed cell if it raises the score."""
    key_a = (section.section_id, problem.position)
    idx_a = placement.placements.get(key_a)
    if idx_a is None or idx_a in section.fixed_screens:
        return False

    placed = placement.section_positions(section.section_id)
    candidates: List[Tuple[int, int]] = [
        pos for pos, idx in placed.items()
        if pos != problem.position and idx not in section.fixed_screens
    ]
    if not candidates:
        return False

    rng.shuffle(candidates)
    candidates = candidates[:max_candidates]

    current_score = _score_section(chapter, section, placement, rom_data, edge_cache)

    for other_pos in candidates:
        key_b = (section.section_id, other_pos)
        idx_b = placement.placements[key_b]

        # Swap.
        placement.placements[key_a] = idx_b
        placement.placements[key_b] = idx_a
        new_score = _score_section(chapter, section, placement, rom_data, edge_cache)
        if new_score > current_score:
            return True
        # Revert.
        placement.placements[key_a] = idx_a
        placement.placements[key_b] = idx_b

    return False


def _try_cross_section_swap(
    *,
    problem: Problem,
    chapter: Chapter,
    section: SectionTemplate,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    compat_index: Dict[Tuple[SectionType, bool], List[int]],
    rng: random.Random,
    max_candidates: int = 24,
) -> bool:
    """Swap with a non-fixed cell in a different section sharing (type, era).

    Cross-section swaps keep section membership intact — the two cells involved
    always belong to same-(type, past) sections, so the screen is still valid
    in its new home. We require the swap to *globally* improve the sum of both
    sections' scores (otherwise we'd fix one while breaking the other).
    """
    key_a = (section.section_id, problem.position)
    idx_a = placement.placements.get(key_a)
    if idx_a is None or idx_a in section.fixed_screens:
        return False

    compat_sections = compat_index.get((section.section_type, section.is_past), [])
    other_section_ids = [sid for sid in compat_sections if sid != section.section_id]
    if not other_section_ids:
        return False

    # Collect candidate swap targets across compatible sections.
    section_by_id = {s.section_id: s for s in template.sections}
    candidate_keys: List[Tuple[int, Tuple[int, int]]] = []
    for sid in other_section_ids:
        osec = section_by_id.get(sid)
        if osec is None:
            continue
        for pos, idx in placement.section_positions(sid).items():
            if idx in osec.fixed_screens:
                continue
            candidate_keys.append((sid, pos))

    if not candidate_keys:
        return False

    rng.shuffle(candidate_keys)
    candidate_keys = candidate_keys[:max_candidates]

    baseline_a = _score_section(chapter, section, placement, rom_data, edge_cache)

    for other_sid, other_pos in candidate_keys:
        osec = section_by_id[other_sid]
        key_b = (other_sid, other_pos)
        idx_b = placement.placements[key_b]

        baseline_b = _score_section(chapter, osec, placement, rom_data, edge_cache)

        placement.placements[key_a] = idx_b
        placement.placements[key_b] = idx_a

        new_a = _score_section(chapter, section, placement, rom_data, edge_cache)
        new_b = _score_section(chapter, osec, placement, rom_data, edge_cache)

        if (new_a + new_b) > (baseline_a + baseline_b):
            return True

        placement.placements[key_a] = idx_a
        placement.placements[key_b] = idx_b

    return False


def _try_tilesection_swap(
    *,
    problem: Problem,
    chapter: Chapter,
    section: SectionTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
    max_candidates: int = 24,
) -> bool:
    """Change the screen's (top_tiles, bottom_tiles, datapointer) to another
    triplet from the chapter that yields better edge walkability.

    This is the last-resort repair when screen-level moves can't fix an edge —
    we rewrite the visual tileset of the screen (its enemies/events stay put).
    Candidate triplets are drawn from other screens in the same chapter with
    matching ``(parent_world, is_past)`` to minimise CHR-bank mismatches.
    """
    key = (section.section_id, problem.position)
    idx = placement.placements.get(key)
    if idx is None or idx in section.fixed_screens:
        return False

    screen = chapter.get_screen(idx)
    if screen is None:
        return False

    current_score = _score_section(chapter, section, placement, rom_data, edge_cache)

    # Gather candidate triplets from same-era same-parent_world screens.
    target_past = section.is_past
    target_world = screen.parent_world
    candidates: List[Tuple[int, int, int]] = []
    seen: Set[Tuple[int, int, int]] = {(screen.top_tiles, screen.bottom_tiles, screen.datapointer)}
    for other in chapter:
        if other.relative_index == idx:
            continue
        if is_excluded(other):
            continue
        if other.parent_world != target_world:
            continue
        if is_past_screen_index(chapter.chapter_num, other.relative_index) != target_past:
            continue
        triplet = (other.top_tiles, other.bottom_tiles, other.datapointer)
        if triplet in seen:
            continue
        seen.add(triplet)
        candidates.append(triplet)

    if not candidates:
        return False

    rng.shuffle(candidates)
    candidates = candidates[:max_candidates]

    original = (screen.top_tiles, screen.bottom_tiles, screen.datapointer)

    for top, bot, dp in candidates:
        screen.top_tiles = top
        screen.bottom_tiles = bot
        screen.datapointer = dp
        edge_cache.pop(idx, None)  # invalidate — tileset changed.

        new_score = _score_section(chapter, section, placement, rom_data, edge_cache)
        if new_score > current_score:
            screen.mark_modified()
            return True

    # Revert.
    screen.top_tiles, screen.bottom_tiles, screen.datapointer = original
    edge_cache.pop(idx, None)
    return False


def _build_compat_index(
    template: ChapterTemplate,
) -> Dict[Tuple[SectionType, bool], List[int]]:
    """(section_type, is_past) → list of section_ids sharing that pool."""
    index: Dict[Tuple[SectionType, bool], List[int]] = defaultdict(list)
    for sec in template.sections:
        index[(sec.section_type, sec.is_past)].append(sec.section_id)
    return index


def _try_pool_pull(
    *,
    problem: Problem,
    chapter: Chapter,
    section: SectionTemplate,
    placement: ChapterPlacement,
    pool: List[int],
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: random.Random,
    max_candidates: int = 12,
) -> bool:
    """Replace the problem cell's screen with an unused pool member if it
    raises the score. The displaced screen goes back into the pool."""
    key = (section.section_id, problem.position)
    idx_current = placement.placements.get(key)
    if idx_current is None or idx_current in section.fixed_screens:
        return False
    if not pool:
        return False

    sample_size = min(max_candidates, len(pool))
    sample = rng.sample(pool, sample_size)

    current_score = _score_section(chapter, section, placement, rom_data, edge_cache)

    for cand in sample:
        placement.placements[key] = cand
        new_score = _score_section(chapter, section, placement, rom_data, edge_cache)
        if new_score > current_score:
            # Commit: current goes back into the pool, candidate leaves.
            pool.remove(cand)
            pool.append(idx_current)
            return True

    # No improvement — revert.
    placement.placements[key] = idx_current
    return False


# =============================================================================
# Pool building
# =============================================================================

def _build_available_pool(
    chapter: Chapter,
    section: SectionTemplate,
    placement: ChapterPlacement,
) -> List[int]:
    """Screens that match this section's (type, era) and aren't placed anywhere."""
    all_assigned: Set[int] = set(placement.placements.values())
    pool: List[int] = []
    for screen in chapter:
        idx = screen.relative_index
        if idx in all_assigned:
            continue
        if is_excluded(screen):
            continue
        if screen.content in {0xC0, 0xC7, 0xD7}:
            continue  # Time doors are always fixed.
        scr_type = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)
        if scr_type != section.section_type:
            continue
        if is_past_screen_index(chapter.chapter_num, idx) != section.is_past:
            continue
        pool.append(idx)
    return pool


# =============================================================================
# Edge helpers
# =============================================================================

def _edges_aligned(
    *,
    chapter: Chapter,
    src_idx: int,
    direction: str,
    dst_idx: int,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> bool:
    """True iff src→direction→dst has at least one aligned walkable pair."""
    src_screen = chapter.get_screen(src_idx)
    dst_screen = chapter.get_screen(dst_idx)
    if src_screen is None or dst_screen is None:
        return False

    src_edges = _cached_edges(src_screen, rom_data, edge_cache)
    dst_edges = _cached_edges(dst_screen, rom_data, edge_cache)
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
