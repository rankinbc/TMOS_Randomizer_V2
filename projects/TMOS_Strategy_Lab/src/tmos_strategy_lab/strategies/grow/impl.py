"""grow — satisfiability-driven section growth.

See SPEC.md for the design. Core idea: every placement is edge-checked up
front against all already-placed grid neighbors, so broken edges cannot
enter the output by construction.
"""
from __future__ import annotations

import copy
import random
from dataclasses import dataclass, field
from typing import Any

from ..._v2_compat.parsers import (
    DO_NOT_RANDOMIZE,
    SectionType,
    relative_to_global,
)
from ...context import LabContext
from ...models import Candidate
from ...registry import register_strategy
from .ts_swap import (
    BiomeRegistry,
    SwapRecord,
    TileSectionCache,
    find_ts_swap,
)

# V2 imports for edge math
from tmos_randomizer.validation.tiles.categories import is_walkable  # type: ignore[import-untyped]
from tmos_randomizer.validation.tiles.edges import (  # type: ignore[import-untyped]
    OPPOSITE_DIRECTIONS,
    ScreenEdges,
    extract_edges,
)


# =============================================================================
# Config — per-chapter section plans
# =============================================================================

@dataclass(frozen=True)
class SectionSpec:
    section_type: SectionType
    is_past: bool
    target_size: int


# Modest generic plan — used as a last-resort fallback if a chapter has no
# tuned plan. Designed with low aspirations so unknown chapters still produce
# *something* rather than crashing.
DEFAULT_PLAN_PER_CHAPTER: list[SectionSpec] = [
    SectionSpec(SectionType.OVERWORLD, is_past=False, target_size=20),
    SectionSpec(SectionType.TOWN,      is_past=False, target_size=6),
    SectionSpec(SectionType.TOWN,      is_past=False, target_size=6),
    SectionSpec(SectionType.SPECIAL,   is_past=False, target_size=10),
    SectionSpec(SectionType.TOWN,      is_past=True,  target_size=5),
    SectionSpec(SectionType.DUNGEON,   is_past=True,  target_size=15),
]


# Per-chapter plans tuned to what the ROM actually contains. Bucket sizes
# (from `inspect_chapter_buckets`) on TMOS_ORIGINAL.nes:
#
#   Type/Era             Ch1  Ch2  Ch3  Ch4  Ch5
#   DUNGEON      PRES      5    0    0    0    0
#   DUNGEON      PAST     29   23   37    6   26
#   MAZE         PRES      0    0    0    0   20
#   MAZE         PAST      6   12    0    0    0
#   MINI_DUNGEON PRES      0    0    0    0    9
#   OVERWORLD    PRES     33   52   45   54   33
#   OVERWORLD    PAST      0    0    0   34    0
#   SPECIAL      PRES     20   18   22    7   39
#   SPECIAL      PAST      0    0    0   32    0
#   TOWN         PRES     12   13   11    9   11
#   TOWN         PAST      9    4    8    6    0
#
# Targets aim for ~70–85% of each bucket — leaves slack for frontier stalls
# where no candidate fits. Where multiple sections share a bucket (e.g. two
# TOWN PRESENT) the sum is ≤ bucket size.
CHAPTER_PLANS: dict[int, list[SectionSpec]] = {
    1: [
        SectionSpec(SectionType.OVERWORLD, is_past=False, target_size=25),
        SectionSpec(SectionType.TOWN,      is_past=False, target_size=6),
        SectionSpec(SectionType.TOWN,      is_past=False, target_size=6),
        SectionSpec(SectionType.DUNGEON,   is_past=False, target_size=5),
        SectionSpec(SectionType.SPECIAL,   is_past=False, target_size=15),
        SectionSpec(SectionType.TOWN,      is_past=True,  target_size=5),
        SectionSpec(SectionType.TOWN,      is_past=True,  target_size=4),
        SectionSpec(SectionType.MAZE,      is_past=True,  target_size=6),
        SectionSpec(SectionType.DUNGEON,   is_past=True,  target_size=20),
    ],
    2: [
        SectionSpec(SectionType.OVERWORLD, is_past=False, target_size=35),
        SectionSpec(SectionType.TOWN,      is_past=False, target_size=7),
        SectionSpec(SectionType.TOWN,      is_past=False, target_size=6),
        SectionSpec(SectionType.SPECIAL,   is_past=False, target_size=12),
        SectionSpec(SectionType.TOWN,      is_past=True,  target_size=4),
        SectionSpec(SectionType.MAZE,      is_past=True,  target_size=10),
        SectionSpec(SectionType.DUNGEON,   is_past=True,  target_size=18),
    ],
    3: [
        SectionSpec(SectionType.OVERWORLD, is_past=False, target_size=30),
        SectionSpec(SectionType.TOWN,      is_past=False, target_size=6),
        SectionSpec(SectionType.TOWN,      is_past=False, target_size=5),
        SectionSpec(SectionType.SPECIAL,   is_past=False, target_size=15),
        SectionSpec(SectionType.TOWN,      is_past=True,  target_size=4),
        SectionSpec(SectionType.TOWN,      is_past=True,  target_size=4),
        SectionSpec(SectionType.DUNGEON,   is_past=True,  target_size=28),
    ],
    4: [
        # Only chapter with OVERWORLD PAST and SPECIAL PAST.
        SectionSpec(SectionType.OVERWORLD, is_past=False, target_size=40),
        SectionSpec(SectionType.TOWN,      is_past=False, target_size=5),
        SectionSpec(SectionType.TOWN,      is_past=False, target_size=4),
        SectionSpec(SectionType.SPECIAL,   is_past=False, target_size=6),
        SectionSpec(SectionType.OVERWORLD, is_past=True,  target_size=25),
        SectionSpec(SectionType.TOWN,      is_past=True,  target_size=5),
        SectionSpec(SectionType.DUNGEON,   is_past=True,  target_size=5),
        SectionSpec(SectionType.SPECIAL,   is_past=True,  target_size=25),
    ],
    5: [
        # Unique: MAZE+MINI_DUNGEON in PRESENT; PAST is 100% DUNGEON.
        SectionSpec(SectionType.OVERWORLD,     is_past=False, target_size=25),
        SectionSpec(SectionType.TOWN,          is_past=False, target_size=6),
        SectionSpec(SectionType.TOWN,          is_past=False, target_size=5),
        SectionSpec(SectionType.SPECIAL,       is_past=False, target_size=30),
        SectionSpec(SectionType.MAZE,          is_past=False, target_size=15),
        SectionSpec(SectionType.MINI_DUNGEON,  is_past=False, target_size=8),
        SectionSpec(SectionType.DUNGEON,       is_past=True,  target_size=20),
    ],
}


def plan_for_chapter(ch_num: int) -> list[SectionSpec]:
    """Return the tuned plan for a chapter, or the generic default if none."""
    return CHAPTER_PLANS.get(ch_num, DEFAULT_PLAN_PER_CHAPTER)


# =============================================================================
# Result types
# =============================================================================

@dataclass
class GrownSection:
    section_id: int
    spec: SectionSpec
    grid: dict[tuple[int, int], int] = field(default_factory=dict)
    # screen_idx → (new_top_tiles, new_bottom_tiles) for swapped placements.
    # Native placements are NOT in this dict — their original tile bytes stand.
    overrides: dict[int, tuple[int, int]] = field(default_factory=dict)
    # Full swap records — survives past the growth loop for reporting.
    swaps: list[SwapRecord] = field(default_factory=list)
    @property
    def grown_size(self) -> int:
        return len(self.grid)


@dataclass
class ChapterGrowth:
    chapter_num: int
    sections: list[GrownSection]
    pool_start_size: int
    pool_remaining: int
    # Diagnostics
    frontier_exhausts: int = 0
    broken_edges: int = 0
    backtracks: int = 0
    time_period_violations: int = 0
    ts_swaps: int = 0
    # Orphan absorption (post-growth pass)
    absorbed_native: int = 0
    absorbed_swap: int = 0
    absorbed_spawned: int = 0    # orphans that seeded new sections
    spawned_sections: int = 0    # count of new sections created for orphans
    absorption_rounds: int = 0


# =============================================================================
# Edge helpers
# =============================================================================

DIRECTION_DELTAS: dict[str, tuple[int, int]] = {
    "right": (1, 0),
    "left":  (-1, 0),
    "down":  (0, 1),
    "up":    (0, -1),
}


def _edges_aligned(edge_a: list[int], edge_b: list[int], min_walkable: int = 1) -> bool:
    """True if the two edges have >= min_walkable aligned walkable positions.

    Matches V2's validator rule (R-015). A walkable position on edge_a[i]
    must be matched by a walkable position on edge_b[i].
    """
    n = min(len(edge_a), len(edge_b))
    aligned = 0
    for i in range(n):
        if is_walkable(edge_a[i]) and is_walkable(edge_b[i]):
            aligned += 1
            if aligned >= min_walkable:
                return True
    return False


def _resolve_edges(
    idx: int,
    overrides: dict[int, tuple[int, int]],
    native_cache: dict[int, ScreenEdges],
    chapter,
    rom_data: bytes,
) -> ScreenEdges:
    """Return the *effective* edges of a placed screen, accounting for any
    TileSection swap applied during growth."""
    if idx not in overrides:
        return native_cache[idx]
    new_top, new_bot = overrides[idx]
    scr = chapter.screens[idx]
    return extract_edges(rom_data, idx, new_top, new_bot, scr.datapointer)


def _candidate_fits(
    cand_edges: ScreenEdges,
    grid_pos: tuple[int, int],
    section_grid: dict[tuple[int, int], int],
    native_cache: dict[int, ScreenEdges],
    overrides: dict[int, tuple[int, int]],
    chapter,
    rom_data: bytes,
) -> bool:
    """Does ``cand`` satisfy edge-alignment with every placed grid-neighbor?

    Placed neighbors use their *effective* edges (post-swap if applicable).
    """
    x, y = grid_pos
    for direction, (dx, dy) in DIRECTION_DELTAS.items():
        npos = (x + dx, y + dy)
        neighbor_idx = section_grid.get(npos)
        if neighbor_idx is None:
            continue
        neighbor_edges = _resolve_edges(neighbor_idx, overrides, native_cache, chapter, rom_data)
        cand_edge = cand_edges.get_edge(direction)
        neigh_edge = neighbor_edges.get_edge(OPPOSITE_DIRECTIONS[direction])
        if not _edges_aligned(cand_edge, neigh_edge):
            return False
    return True


def _neighbor_constraints(
    grid_pos: tuple[int, int],
    section_grid: dict[tuple[int, int], int],
    native_cache: dict[int, ScreenEdges],
    overrides: dict[int, tuple[int, int]],
    chapter,
    rom_data: bytes,
) -> dict[str, list[int]]:
    """Return ``{direction: neighbor_opposite_edge_tiles}`` for every placed
    grid-neighbor of ``grid_pos``. Empty dict = leaf cell with no constraints."""
    x, y = grid_pos
    out: dict[str, list[int]] = {}
    for direction, (dx, dy) in DIRECTION_DELTAS.items():
        npos = (x + dx, y + dy)
        neighbor_idx = section_grid.get(npos)
        if neighbor_idx is None:
            continue
        nedges = _resolve_edges(neighbor_idx, overrides, native_cache, chapter, rom_data)
        out[direction] = nedges.get_edge(OPPOSITE_DIRECTIONS[direction])
    return out


# =============================================================================
# Growth core
# =============================================================================

def inspect_chapter_buckets(chapter, ch_num: int) -> dict[tuple[SectionType, bool], int]:
    """Return `{(section_type, is_past): bucket_size}` for the chapter.

    Uses the same filters as `_build_pool` — excludes DO_NOT_RANDOMIZE
    and time-door-content screens. Exported so the demo can print
    bucket tables without running the growth loop.
    """
    from tmos_randomizer.core.enums import is_past_screen_index  # type: ignore[import-untyped]
    pools = _build_pool(chapter, ch_num, is_past_screen_index)
    return {k: len(v) for k, v in pools.items()}


def _build_edges_cache(chapter, rom_data: bytes) -> dict[int, ScreenEdges]:
    cache: dict[int, ScreenEdges] = {}
    for scr in chapter.screens:
        cache[scr.relative_index] = extract_edges(
            rom_data,
            scr.relative_index,
            scr.top_tiles,
            scr.bottom_tiles,
            scr.datapointer,
        )
    return cache


# Time-door content-byte values. Screens with these content bytes are
# NOT in V2's DO_NOT_RANDOMIZE, but they must never be pulled into the
# growth pool: they are the ONLY legal PAST↔PRESENT bridge, and their
# content byte must remain intact at a preserved position.
TIME_DOOR_CONTENTS: frozenset[int] = frozenset({0xC0, 0xC7, 0xD7})


def _build_pool(
    chapter,
    ch_num: int,
    is_past_fn,
) -> dict[tuple[SectionType, bool], list[int]]:
    """Partition chapter screens into (section_type, is_past) buckets.

    Excludes:
      - screens in DO_NOT_RANDOMIZE (bosses, victory, wizard, special events)
      - time-door screens (content ∈ {0xC0, 0xC7, 0xD7}) — reserved for the
        dedicated PAST↔PRESENT bridge, never part of a growable section.
    """
    pools: dict[tuple[SectionType, bool], list[int]] = {}
    for scr in chapter.screens:
        gidx = relative_to_global(ch_num, scr.relative_index)
        if gidx in DO_NOT_RANDOMIZE:
            continue
        if scr.content in TIME_DOOR_CONTENTS:
            continue
        is_past = is_past_fn(ch_num, scr.relative_index)
        key = (scr.section_type, is_past)
        pools.setdefault(key, []).append(scr.relative_index)
    return pools


def _grow_one_section(
    section_id: int,
    spec: SectionSpec,
    pool: list[int],
    edges_cache: dict[int, ScreenEdges],
    chapter,
    rom_data: bytes,
    biome: BiomeRegistry,
    ts_cache: TileSectionCache,
    rng: random.Random,
    origin: tuple[int, int],
) -> tuple[GrownSection, int, int]:
    """Run the growth loop for one section.

    Placement order at each step:
      1. Native placement — candidate whose original tiles already fit.
      2. TS-swap placement — candidate whose tiles can be swapped (within
         the section's biome set) to produce fitting edges.
      3. Backtrack — pop the most recent placement, blacklist that
         (cell, screen) pair, retry growth.

    Budget: ``2 * target_size`` backtracks per section. Seed is never
    rewound. Returns (grown_section, frontier_exhausts, backtracks).
    Mutates ``pool`` in place.
    """
    result = GrownSection(section_id=section_id, spec=spec)
    exhausts = 0
    backtracks = 0

    if not pool:
        return result, exhausts, backtracks

    # Seed — non-rewindable anchor. No swap for the seed either (no
    # constraints yet, so native placement trivially works).
    seed_idx = rng.choice(pool)
    pool.remove(seed_idx)
    result.grid[origin] = seed_idx

    # Placement stack. Each entry: (cell, screen_idx, was_swapped).
    history: list[tuple[tuple[int, int], int, bool]] = []
    # Dead-end blacklist: (cell, screen) pairs that led to a stall.
    dead_ends: set[tuple[tuple[int, int], int]] = set()

    max_backtracks = 2 * max(spec.target_size, 1)

    while result.grown_size < spec.target_size and pool:
        # Frontier: unoccupied cells adjacent to any placed cell.
        frontier: set[tuple[int, int]] = set()
        for (x, y) in result.grid:
            for dx, dy in DIRECTION_DELTAS.values():
                npos = (x + dx, y + dy)
                if npos not in result.grid:
                    frontier.add(npos)

        if not frontier:
            exhausts += 1
            break

        frontier_list = list(frontier)
        rng.shuffle(frontier_list)

        placed_this_round = False

        # --- Phase 1: native placement ---
        for cell in frontier_list:
            candidates: list[int] = []
            for cand_idx in pool:
                if (cell, cand_idx) in dead_ends:
                    continue
                if _candidate_fits(
                    edges_cache[cand_idx], cell, result.grid,
                    edges_cache, result.overrides, chapter, rom_data,
                ):
                    candidates.append(cand_idx)
            if candidates:
                pick = rng.choice(candidates)
                pool.remove(pick)
                result.grid[cell] = pick
                history.append((cell, pick, False))
                placed_this_round = True
                break

        if placed_this_round:
            continue

        # --- Phase 2: TS-swap placement ---
        for cell in frontier_list:
            constraints = _neighbor_constraints(
                cell, result.grid, edges_cache, result.overrides, chapter, rom_data,
            )
            if not constraints:
                # Leaf cell with no constraints would have passed phase 1
                # for any candidate whose native edges don't contradict
                # themselves. Skip.
                continue

            # Try candidates in random order; first swap-viable one wins.
            pool_shuffled = list(pool)
            rng.shuffle(pool_shuffled)
            swapped_pick = None
            for cand_idx in pool_shuffled:
                if (cell, cand_idx) in dead_ends:
                    continue
                cand_scr = chapter.screens[cand_idx]
                swap = find_ts_swap(
                    datapointer=cand_scr.datapointer,
                    section_type=spec.section_type,
                    neighbor_edges=constraints,
                    biome=biome,
                    ts_cache=ts_cache,
                    rng=rng,
                )
                if swap is not None:
                    swapped_pick = (cand_idx, swap)
                    break

            if swapped_pick is not None:
                cand_idx, (new_top, new_bot) = swapped_pick
                cand_scr = chapter.screens[cand_idx]
                pool.remove(cand_idx)
                result.grid[cell] = cand_idx
                result.overrides[cand_idx] = (new_top, new_bot)
                result.swaps.append(SwapRecord(
                    section_id=section_id,
                    screen_idx=cand_idx,
                    grid_pos=cell,
                    original_top=cand_scr.top_tiles,
                    original_bottom=cand_scr.bottom_tiles,
                    new_top=new_top,
                    new_bottom=new_bot,
                ))
                history.append((cell, cand_idx, True))
                placed_this_round = True
                break

        if placed_this_round:
            continue

        # --- Phase 3: backtrack ---
        if backtracks < max_backtracks and history:
            undo_cell, undo_idx, was_swapped = history.pop()
            del result.grid[undo_cell]
            if was_swapped:
                result.overrides.pop(undo_idx, None)
                # Remove the matching SwapRecord (last one by this screen_idx).
                for i in range(len(result.swaps) - 1, -1, -1):
                    if result.swaps[i].screen_idx == undo_idx:
                        result.swaps.pop(i)
                        break
            pool.append(undo_idx)
            dead_ends.add((undo_cell, undo_idx))
            backtracks += 1
            continue

        exhausts += 1
        break

    return result, exhausts, backtracks


def _try_attach_orphan(
    orphan_idx: int,
    target_sections: list[GrownSection],
    edges_cache: dict[int, ScreenEdges],
    chapter,
    rom_data: bytes,
    biome: BiomeRegistry,
    ts_cache: TileSectionCache,
    rng: random.Random,
) -> tuple[bool, bool]:
    """Try to place a single orphan into any of the candidate sections.

    Returns ``(placed, via_swap)``. ``placed`` is True iff the orphan was
    attached; ``via_swap`` is True iff the placement required a TS swap.
    The orphan is NOT removed from the caller's pool — caller handles
    pool bookkeeping to keep this function side-effect-free on the pool.
    """
    orphan_scr = chapter.screens[orphan_idx]
    sec_order = list(target_sections)
    rng.shuffle(sec_order)

    for section in sec_order:
        if not section.grid:
            continue
        frontier: set[tuple[int, int]] = set()
        for (x, y) in section.grid:
            for dx, dy in DIRECTION_DELTAS.values():
                npos = (x + dx, y + dy)
                if npos not in section.grid:
                    frontier.add(npos)
        frontier_list = list(frontier)
        rng.shuffle(frontier_list)

        # Native attempt
        for cell in frontier_list:
            if _candidate_fits(
                edges_cache[orphan_idx], cell, section.grid,
                edges_cache, section.overrides, chapter, rom_data,
            ):
                section.grid[cell] = orphan_idx
                return True, False

        # TS-swap attempt
        for cell in frontier_list:
            constraints = _neighbor_constraints(
                cell, section.grid, edges_cache, section.overrides, chapter, rom_data,
            )
            if not constraints:
                continue
            swap = find_ts_swap(
                datapointer=orphan_scr.datapointer,
                section_type=section.spec.section_type,
                neighbor_edges=constraints,
                biome=biome,
                ts_cache=ts_cache,
                rng=rng,
            )
            if swap is not None:
                new_top, new_bot = swap
                section.grid[cell] = orphan_idx
                section.overrides[orphan_idx] = (new_top, new_bot)
                section.swaps.append(SwapRecord(
                    section_id=section.section_id,
                    screen_idx=orphan_idx,
                    grid_pos=cell,
                    original_top=orphan_scr.top_tiles,
                    original_bottom=orphan_scr.bottom_tiles,
                    new_top=new_top,
                    new_bottom=new_bot,
                ))
                return True, True

    return False, False


def _absorb_orphans(
    grown_sections: list[GrownSection],
    pools: dict[tuple[SectionType, bool], list[int]],
    edges_cache: dict[int, ScreenEdges],
    chapter,
    rom_data: bytes,
    biome: BiomeRegistry,
    ts_cache: TileSectionCache,
    rng: random.Random,
    max_attach_rounds: int = 4,
    max_outer_rounds: int = 500,
) -> tuple[int, int, int, int, int]:
    """Place every leftover pool screen somewhere in a compatible section.

    Two-phase approach:

    **Phase A — attach to existing.** For each orphan, walk every section
    that matches the orphan's (section_type, is_past) and try to append
    the orphan to that section's frontier (native, then TS swap). Repeat
    until no orphan can be placed.

    **Phase B — spawn new section.** If orphans remain after Phase A,
    pick one, seed a new section of its (type, era), and loop back to
    Phase A. Subsequent orphans of the same bucket can now attach to
    the new section.

    Invariants preserved throughout:
      - Orphans only go into sections with matching type + era.
      - Every placement is grid-adjacent to an already-placed cell of
        that section, so every placed screen is reachable from the
        section's seed by walking (nav writing uses grid adjacency).
      - Edge compatibility is verified before placement.

    Returns ``(absorbed_native, absorbed_swap, absorbed_spawned,
    spawned_sections, outer_rounds_used)``.
    """
    from collections import defaultdict

    absorbed_native = 0
    absorbed_swap = 0
    absorbed_spawned = 0
    spawned_sections = 0

    sections_by_key: dict[tuple[SectionType, bool], list[GrownSection]] = defaultdict(list)
    for sec in grown_sections:
        if sec.grid:
            sections_by_key[(sec.spec.section_type, sec.spec.is_past)].append(sec)

    next_section_id = max((s.section_id for s in grown_sections), default=0) + 1

    def _attach_round() -> tuple[int, int]:
        """One pass over every orphan. Returns (native_placed, swap_placed)
        so the caller can tell how much progress was made."""
        native_placed = 0
        swap_placed = 0
        pool_keys = sorted(pools.keys(), key=lambda k: (k[0].name, k[1]))
        for key in pool_keys:
            pool = pools[key]
            if not pool:
                continue
            target_sections = sections_by_key.get(key, [])
            if not target_sections:
                continue
            remaining = list(pool)
            rng.shuffle(remaining)
            for orphan_idx in remaining:
                if orphan_idx not in pool:
                    continue
                placed, via_swap = _try_attach_orphan(
                    orphan_idx, target_sections, edges_cache,
                    chapter, rom_data, biome, ts_cache, rng,
                )
                if placed:
                    pool.remove(orphan_idx)
                    if via_swap:
                        swap_placed += 1
                    else:
                        native_placed += 1
        return native_placed, swap_placed

    outer_rounds_used = 0
    prev_remaining = sum(len(p) for p in pools.values())
    for outer in range(max_outer_rounds):
        outer_rounds_used = outer + 1

        # Phase A — run attach rounds until they stop making progress.
        for _ in range(max_attach_rounds):
            n, s = _attach_round()
            absorbed_native += n
            absorbed_swap += s
            if n == 0 and s == 0:
                break

        # If no orphans remain, done.
        leftover_keys = [k for k, p in pools.items() if p]
        if not leftover_keys:
            break

        # Phase B — spawn a new section from one orphan. Pick a (type, era)
        # bucket with the largest leftover so subsequent attach rounds
        # have the best chance of pulling more orphans into the new section.
        leftover_keys.sort(key=lambda k: -len(pools[k]))
        key = leftover_keys[0]
        orphan = pools[key][0]
        pools[key].remove(orphan)

        new_section = GrownSection(
            section_id=next_section_id,
            spec=SectionSpec(
                section_type=key[0],
                is_past=key[1],
                target_size=len(pools[key]) + 1,
            ),
        )
        new_section.grid[(0, 0)] = orphan
        grown_sections.append(new_section)
        sections_by_key[key].append(new_section)
        spawned_sections += 1
        absorbed_spawned += 1
        next_section_id += 1

        # Early termination on no progress — if we spawned a section and
        # the subsequent attach round(s) placed nothing new, we're wasting
        # work. Measure remaining after the spawn + next attach pass.
        cur_remaining = sum(len(p) for p in pools.values())
        if cur_remaining >= prev_remaining:
            # Didn't improve THIS round. Allow one more attempt in case
            # next round's RNG shuffle finds a different placement; then
            # bail if still no progress.
            pass
        prev_remaining = cur_remaining

    return (
        absorbed_native, absorbed_swap, absorbed_spawned,
        spawned_sections, outer_rounds_used,
    )


def _verify_time_period_integrity(
    section: GrownSection,
    ch_num: int,
    is_past_fn,
) -> int:
    """Returns count of placed screens whose actual PAST/PRESENT status
    contradicts the section's spec.

    By construction this must be 0: the pool is bucketed on
    (section_type, is_past) and we only draw from the matching bucket.
    Non-zero indicates a pool-construction bug — worth checking because
    the PAST↔PRESENT rule is a hard game-logic invariant (the only legal
    cross-era link is the time-door screen, which is reserved outside
    the growth pool).
    """
    violations = 0
    for _pos, idx in section.grid.items():
        if is_past_fn(ch_num, idx) != section.spec.is_past:
            violations += 1
    return violations


def _verify_no_broken_edges(
    section: GrownSection,
    edges_cache: dict[int, ScreenEdges],
    chapter,
    rom_data: bytes,
) -> int:
    """Sanity pass: count any grid-adjacent pairs with misaligned edges.

    Must be 0 by construction. Non-zero indicates a bug in the fit check.
    """
    broken = 0
    seen_pairs: set[tuple[tuple[int, int], tuple[int, int]]] = set()
    for pos_a, idx_a in section.grid.items():
        for direction, (dx, dy) in DIRECTION_DELTAS.items():
            pos_b = (pos_a[0] + dx, pos_a[1] + dy)
            idx_b = section.grid.get(pos_b)
            if idx_b is None:
                continue
            pair = tuple(sorted([pos_a, pos_b]))
            if pair in seen_pairs:
                continue
            seen_pairs.add(pair)
            ea = _resolve_edges(idx_a, section.overrides, edges_cache, chapter, rom_data).get_edge(direction)
            eb = _resolve_edges(idx_b, section.overrides, edges_cache, chapter, rom_data).get_edge(OPPOSITE_DIRECTIONS[direction])
            if not _edges_aligned(ea, eb):
                broken += 1
    return broken


def grow_chapter(
    chapter,
    rom_data: bytes,
    plan: list[SectionSpec],
    rng: random.Random,
    biome: BiomeRegistry | None = None,
    ts_cache: TileSectionCache | None = None,
) -> ChapterGrowth:
    """Run the grow pipeline for a single chapter. Read-only — does not
    mutate the chapter's WorldScreen bytes.

    ``biome`` and ``ts_cache`` are optional — if not provided, they are
    built from this single chapter (which limits TS-swap search to THIS
    chapter's biome tags; pass pre-built world-wide instances for a
    richer swap space).
    """
    from tmos_randomizer.core.enums import is_past_screen_index  # type: ignore[import-untyped]

    edges_cache = _build_edges_cache(chapter, rom_data)
    pools = _build_pool(chapter, chapter.chapter_num, is_past_screen_index)

    if ts_cache is None:
        ts_cache = TileSectionCache.build(rom_data)
    if biome is None:
        # Build a single-chapter biome — narrow but functional fallback.
        class _SingleChWorld:
            chapters = {chapter.chapter_num: chapter}
        biome = BiomeRegistry.build_from_world(_SingleChWorld())

    pool_start = sum(len(v) for v in pools.values())

    grown_sections: list[GrownSection] = []
    frontier_exhausts = 0
    backtracks_total = 0
    ts_swaps_total = 0

    for i, spec in enumerate(plan, start=1):
        pool = pools.get((spec.section_type, spec.is_past), [])
        if not pool:
            grown_sections.append(GrownSection(section_id=i, spec=spec))
            continue
        grown, exhausts, backtracks = _grow_one_section(
            section_id=i,
            spec=spec,
            pool=pool,  # mutated in place
            edges_cache=edges_cache,
            chapter=chapter,
            rom_data=rom_data,
            biome=biome,
            ts_cache=ts_cache,
            rng=rng,
            origin=(0, 0),
        )
        frontier_exhausts += exhausts
        backtracks_total += backtracks
        ts_swaps_total += len(grown.swaps)
        grown_sections.append(grown)

    # Orphan absorption — place leftover pool screens into any compatible
    # existing section (same type + era) so no screen is left behind.
    # Spawns new sections for orphans that can't attach anywhere.
    (
        absorbed_native,
        absorbed_swap,
        absorbed_spawned,
        spawned_sections,
        absorption_rounds,
    ) = _absorb_orphans(
        grown_sections=grown_sections,
        pools=pools,
        edges_cache=edges_cache,
        chapter=chapter,
        rom_data=rom_data,
        biome=biome,
        ts_cache=ts_cache,
        rng=rng,
    )
    ts_swaps_total += absorbed_swap

    pool_remaining = sum(len(v) for v in pools.values())

    broken_total = sum(
        _verify_no_broken_edges(sec, edges_cache, chapter, rom_data)
        for sec in grown_sections
    )
    time_violations = sum(
        _verify_time_period_integrity(sec, chapter.chapter_num, is_past_screen_index)
        for sec in grown_sections
    )

    return ChapterGrowth(
        chapter_num=chapter.chapter_num,
        sections=grown_sections,
        pool_start_size=pool_start,
        pool_remaining=pool_remaining,
        frontier_exhausts=frontier_exhausts,
        broken_edges=broken_total,
        backtracks=backtracks_total,
        time_period_violations=time_violations,
        ts_swaps=ts_swaps_total,
        absorbed_native=absorbed_native,
        absorbed_swap=absorbed_swap,
        absorbed_spawned=absorbed_spawned,
        spawned_sections=spawned_sections,
        absorption_rounds=absorption_rounds,
    )


# =============================================================================
# Lab strategy wrapper
# =============================================================================

@register_strategy
class GrowStrategy:
    name = "grow"
    description = (
        "Satisfiability-driven section growth — grows each section from a "
        "seed screen, only placing candidates whose edges align with all "
        "already-placed grid neighbors. Broken edges by construction = 0."
    )
    strategy_version = "0.1.0"

    def generate(self, ctx: LabContext, seed: int) -> Candidate:
        # Deepcopy protection — same pattern as tileshuffle.
        world = copy.deepcopy(ctx.game_world)
        rng = random.Random(seed)

        # Build world-wide biome + TS cache ONCE (expensive-ish, shared
        # across chapters so TS swaps can draw on every chapter's data).
        rom_bytes = ctx.rom_bytes or b""
        biome = BiomeRegistry.build_from_world(world)
        ts_cache = TileSectionCache.build(rom_bytes)

        chapters_out: dict[int, list[dict[str, Any]]] = {}
        growth_summary: dict[str, Any] = {}

        for ch_num in sorted(world.chapters.keys()):
            chapter = world.chapters[ch_num]
            chapter_rng = random.Random(rng.randrange(2**31))
            growth = grow_chapter(
                chapter=chapter,
                rom_data=rom_bytes,
                plan=plan_for_chapter(ch_num),
                rng=chapter_rng,
                biome=biome,
                ts_cache=ts_cache,
            )
            growth_summary[str(ch_num)] = {
                "pool_start": growth.pool_start_size,
                "pool_remaining": growth.pool_remaining,
                "broken_edges": growth.broken_edges,
                "frontier_exhausts": growth.frontier_exhausts,
                "sections": [
                    {
                        "id": s.section_id,
                        "type": s.spec.section_type.name,
                        "is_past": s.spec.is_past,
                        "target": s.spec.target_size,
                        "grown": s.grown_size,
                    }
                    for s in growth.sections
                ],
            }
            # This prototype does not yet write the grown layout back into
            # WorldScreen nav bytes. Chapters are emitted unchanged; the
            # headline signal lives in ``breadcrumbs["growth"]``.
            chapters_out[ch_num] = [s.to_dict() for s in chapter.screens]

        return Candidate(
            strategy_id=f"{self.name}@local",
            strategy_version=self.strategy_version,
            seed=seed,
            chapters=chapters_out,
            repairs=[],
            breadcrumbs={
                "source": ctx.source,
                "rom_md5": ctx.rom_md5,
                "growth": growth_summary,
                "notice": (
                    "Prototype: nav bytes are NOT written from grown "
                    "layout. breadcrumbs.growth holds the grown plan."
                ),
            },
        )


__all__ = [
    "GrowStrategy",
    "grow_chapter",
    "inspect_chapter_buckets",
    "plan_for_chapter",
    "SectionSpec",
    "DEFAULT_PLAN_PER_CHAPTER",
    "CHAPTER_PLANS",
]
