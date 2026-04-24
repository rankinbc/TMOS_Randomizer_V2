"""Mutation operators + local-invariant check for ``graph_mutate``.

Three operators, each produced by a ``propose_*`` function that returns an
undoable ``Mutation`` (or ``None`` if nothing applies this iteration):

- ``propose_swap``     — swap two same-section-type screens connected by a
                         real edge, rewriting chapter-wide nav references.
- ``propose_reroute``  — change one outgoing edge to a new same-section-type
                         target; preserve bidirectionality by cleaning up
                         the stale reverse edge.
- ``propose_prune``    — add the return edge on a one-way leaf (all four
                         outgoing bytes are ``NAV_BLOCKED``).

The ``check_local_invariants`` function runs after each apply and verifies
valid indices, bidirectionality (with baseline tolerance), and tile-level
edge walkability on the affected neighborhood. Walkability grids are cached
across the entire ``generate()`` call since no operator touches
``top_tiles``/``bottom_tiles``/``datapointer``.

See ``SPEC.md`` and ``PRPs/archive/<date>_graph_mutate.md`` for the full
rationale and the gotchas that shaped this code.
"""
from __future__ import annotations

import random
from collections.abc import Callable
from dataclasses import dataclass, field

from ..._v2_compat.parsers import (
    DO_NOT_RANDOMIZE,
    NAV_BLOCKED,
    NAV_BUILDING_ENTRANCE,
    relative_to_global,
)
from ..._v2_compat.pathfinding import (
    build_walkability_grid,
    get_walkable_edge_positions,
)

OPPOSITE: dict[str, str] = {"up": "down", "down": "up", "left": "right", "right": "left"}
DIRECTIONS: tuple[str, ...] = ("down", "left", "right", "up")  # sorted alphabetically for stable iteration


# =============================================================================
# Graph-edge predicates
# =============================================================================

def is_real_edge(screen, direction: str) -> bool:
    """True when ``screen_index_{direction}`` is a real graph edge.

    Sentinels ``NAV_BLOCKED`` (0xFF, wall) and ``NAV_BUILDING_ENTRANCE`` (0xFE,
    stairway/Content trigger) both count as "no graph edge here". Never hardcode
    those byte values — the sentinels come in via ``_v2_compat.parsers``.
    """
    v = getattr(screen, f"screen_index_{direction}")
    return v not in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE)


def is_real_leaf(screen) -> bool:
    """True when every outgoing direction is ``NAV_BLOCKED`` strictly.

    A screen whose only non-wall exit is ``NAV_BUILDING_ENTRANCE`` is NOT a
    leaf in graph terms — it exits via V2's Content behavior (stairway). The
    strict 0xFF check keeps ``prune_deadend`` out of stairway territory.
    """
    return all(
        getattr(screen, f"screen_index_{d}") == NAV_BLOCKED
        for d in DIRECTIONS
    )


def build_baseline_asymmetry(world) -> set[tuple[int, int, str]]:
    """Snapshot the set of pre-existing asymmetric real edges in the stock graph.

    Returned set contains ``(chapter_num, source_relative_index, direction)``
    tuples for every real edge whose reverse either is not a real edge or
    does not point back at the source. Used during invariant checks to
    tolerate stock one-way edges (rivers, cliffs, story gates) while
    rejecting *mutation-introduced* asymmetry.

    Also includes real edges whose target index is out of range — the stock
    ROM shouldn't have any, but capturing them as "pre-existing" means we
    never flag them as new damage.
    """
    baseline: set[tuple[int, int, str]] = set()
    for ch_num in sorted(world.chapters.keys()):
        chapter = world.chapters[ch_num]
        n = len(chapter.screens)
        for s in chapter.screens:
            for d in DIRECTIONS:
                if not is_real_edge(s, d):
                    continue
                t_rel = getattr(s, f"screen_index_{d}")
                if not (0 <= t_rel < n):
                    baseline.add((ch_num, s.relative_index, d))
                    continue
                t = chapter.screens[t_rel]
                inv_d = OPPOSITE[d]
                if not is_real_edge(t, inv_d):
                    baseline.add((ch_num, s.relative_index, d))
                elif getattr(t, f"screen_index_{inv_d}") != s.relative_index:
                    baseline.add((ch_num, s.relative_index, d))
    return baseline


# =============================================================================
# Walkability helpers
# =============================================================================

def get_grid(rom_bytes: bytes, screen, cache: dict[tuple[int, int, int], list[list[bool]]]) -> list[list[bool]]:
    """Return the walkability grid for a screen; cache by screen content.

    Mutations never touch ``top_tiles``/``bottom_tiles``/``datapointer``, so
    a grid built once stays valid for the entire ``generate()`` call. Without
    this cache the 200-iteration loop blows the <5s budget.

    Key shape mirrors ``metrics/edge_compatibility.py``'s ``grid_for()``.
    """
    key = (screen.top_tiles, screen.bottom_tiles, screen.datapointer & 0xFF)
    grid = cache.get(key)
    if grid is None:
        grid = build_walkability_grid(
            rom_bytes, screen.top_tiles, screen.bottom_tiles, screen.datapointer
        )
        cache[key] = grid
    return grid


def edge_walkable(src, dst, direction: str, rom_bytes: bytes, cache: dict) -> bool:
    """True when both sides of the shared edge have ≥1 walkable tile.

    Column alignment is NOT required — the NES engine lets the player step
    off any walkable tile in the source edge row onto any walkable tile in
    the destination edge row (same rule as the Lab's ``edge_compatibility``
    metric). ``is_walkable(tile_id)`` inside ``build_walkability_grid``
    encodes trees, walls, water, cliffs, bridges, and every other collision
    tile — so this single check catches all of them.
    """
    src_walk = get_walkable_edge_positions(get_grid(rom_bytes, src, cache), direction)
    dst_walk = get_walkable_edge_positions(get_grid(rom_bytes, dst, cache), OPPOSITE[direction])
    return len(src_walk) >= 1 and len(dst_walk) >= 1


# =============================================================================
# Local invariant check
# =============================================================================

def check_local_invariants(
    world,
    ch_num: int,
    affected: set[int],
    baseline_asymmetry: set[tuple[int, int, str]],
    rom_bytes: bytes,
    cache: dict,
) -> bool:
    """Return True iff all local invariants hold on ``affected`` screens.

    Checks per affected screen's outgoing edges:
      - valid index (in-range OR one of the two sentinels)
      - bidirectionality (with baseline tolerance for pre-existing asymmetry)
      - tile-level walkability on every real edge

    (Sentinel preservation — 0xFE never overwritten — is enforced
    structurally by the operators. Test #4 is the end-to-end safety net.)
    """
    chapter = world.chapters[ch_num]
    n = len(chapter.screens)
    for rel in sorted(affected):
        if not (0 <= rel < n):
            return False
        s = chapter.screens[rel]
        for d in DIRECTIONS:
            v = getattr(s, f"screen_index_{d}")
            if v in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if not (0 <= v < n):
                return False
            t = chapter.screens[v]
            inv_d = OPPOSITE[d]
            back_real = is_real_edge(t, inv_d)
            back_matches = back_real and getattr(t, f"screen_index_{inv_d}") == rel
            if not back_matches and (ch_num, rel, d) not in baseline_asymmetry:
                return False
            if not edge_walkable(s, t, d, rom_bytes, cache):
                return False
    return True


# =============================================================================
# Mutation shape
# =============================================================================

@dataclass
class Mutation:
    """One undoable proposal.

    ``apply``/``undo`` are zero-arg closures over operator-specific state
    (captured *int* byte snapshots — never references, per GOTCHA 13).
    ``affected`` is the set of chapter-local relative_index values whose
    invariants must be rechecked after apply.
    """
    op_name: str
    apply: Callable[[], None]
    undo: Callable[[], None]
    ch_num: int
    affected: set[int] = field(default_factory=set)


# =============================================================================
# propose_swap — swap two adjacent same-section-type screens
# =============================================================================

def _compute_protected_targets(chapter, ch_num: int) -> set[int]:
    """Relative indices referenced by any DO_NOT_RANDOMIZE screen in the chapter.

    A swap that moves A or B would require rewriting the bytes of every screen
    pointing at them. If any pointer originates from a DO_NOT_RANDOMIZE screen,
    that rewrite would modify a protected screen's bytes — violating
    DO_NOT_RANDOMIZE. Excluding such A/B from the swap candidate pool keeps
    protected screens byte-identical.
    """
    protected: set[int] = set()
    n = len(chapter.screens)
    for s in chapter.screens:
        if relative_to_global(ch_num, s.relative_index) not in DO_NOT_RANDOMIZE:
            continue
        for d in DIRECTIONS:
            v = getattr(s, f"screen_index_{d}")
            if 0 <= v < n:
                protected.add(v)
    return protected


def propose_swap(world, rng: random.Random) -> Mutation | None:
    """Swap two screens connected by a real edge and sharing section_type.

    The apply exchanges the two screen objects in the chapter's screen list
    AND rewrites every ``screen_index_*`` byte in the chapter so references
    to ``idx(A)`` become ``idx(B)`` and vice versa. Sentinel bytes (0xFE /
    0xFF) are NEVER rewritten — other indices only.

    RNG consumption: one ``rng.choice`` on the sorted candidate-edge pool.
    """
    candidates: list[tuple[int, int, str]] = []
    for ch_num in sorted(world.chapters.keys()):
        chapter = world.chapters[ch_num]
        n = len(chapter.screens)
        protected = _compute_protected_targets(chapter, ch_num)
        for a in chapter.screens:
            gidx_a = relative_to_global(ch_num, a.relative_index)
            if gidx_a in DO_NOT_RANDOMIZE:
                continue
            if a.relative_index in protected:
                continue  # a DO_NOT_RANDOMIZE screen points at A; A can't move
            for d in DIRECTIONS:
                if not is_real_edge(a, d):
                    continue
                b_rel = getattr(a, f"screen_index_{d}")
                if not (0 <= b_rel < n):
                    continue
                if b_rel in protected:
                    continue  # a DO_NOT_RANDOMIZE screen points at B; B can't move
                b = chapter.screens[b_rel]
                if relative_to_global(ch_num, b.relative_index) in DO_NOT_RANDOMIZE:
                    continue
                if a.section_type != b.section_type:
                    continue
                candidates.append((ch_num, a.relative_index, d))
    if not candidates:
        return None
    candidates.sort()
    ch_num, a_rel, d = rng.choice(candidates)
    chapter = world.chapters[ch_num]
    b_rel = getattr(chapter.screens[a_rel], f"screen_index_{d}")

    screens = chapter.screens
    # Snapshot every screen's four nav bytes BEFORE apply — GOTCHA 13.
    prior_bytes: list[tuple[int, int, int, int]] = [
        (s.screen_index_down, s.screen_index_left,
         s.screen_index_right, s.screen_index_up)
        for s in screens
    ]

    # Affected set: A, B, plus every screen whose nav bytes contain A_rel or
    # B_rel before apply (those are the screens whose bytes will be rewritten).
    affected: set[int] = {a_rel, b_rel}
    for i, s in enumerate(screens):
        if i in affected:
            continue
        for dd in DIRECTIONS:
            v = getattr(s, f"screen_index_{dd}")
            if v == a_rel or v == b_rel:
                affected.add(i)
                break

    def apply() -> None:
        # Rewrite chapter-wide nav bytes. Leave sentinels alone — GOTCHA 8.
        for s in screens:
            for field_name in ("screen_index_down", "screen_index_left",
                               "screen_index_right", "screen_index_up"):
                v = getattr(s, field_name)
                if v == a_rel:
                    setattr(s, field_name, b_rel)
                elif v == b_rel:
                    setattr(s, field_name, a_rel)
        # Physically swap the two screen objects in the list.
        screens[a_rel], screens[b_rel] = screens[b_rel], screens[a_rel]
        # Re-bind relative_index to list position so downstream code that
        # reads screens[i].relative_index sees `i`.
        screens[a_rel].relative_index = a_rel
        screens[b_rel].relative_index = b_rel

    def undo() -> None:
        # Reverse order: swap back, then restore bytes from the snapshot.
        screens[a_rel], screens[b_rel] = screens[b_rel], screens[a_rel]
        screens[a_rel].relative_index = a_rel
        screens[b_rel].relative_index = b_rel
        for s, (dn, lf, rt, up) in zip(screens, prior_bytes, strict=True):
            s.screen_index_down = dn
            s.screen_index_left = lf
            s.screen_index_right = rt
            s.screen_index_up = up

    return Mutation("swap_adjacent_screens", apply, undo, ch_num, affected)


# =============================================================================
# propose_reroute — rewire one outgoing edge to a different same-section-type target
# =============================================================================

def propose_reroute(world, rng: random.Random) -> Mutation | None:
    """Change one real outgoing edge to a new target of the same section_type.

    Preserves bidirectionality when the original edge was bidirectional:
    sets the new target's reverse edge to point at the source, and clears
    the old target's stale reverse edge with ``NAV_BLOCKED`` (GOTCHA 14).

    RNG consumption: one ``rng.choice`` over sorted source edges, then one
    ``rng.choice`` over sorted same-section targets.
    """
    source_candidates: list[tuple[int, int, str]] = []
    for ch_num in sorted(world.chapters.keys()):
        chapter = world.chapters[ch_num]
        for a in chapter.screens:
            if relative_to_global(ch_num, a.relative_index) in DO_NOT_RANDOMIZE:
                continue
            for d in DIRECTIONS:
                if not is_real_edge(a, d):
                    continue
                source_candidates.append((ch_num, a.relative_index, d))
    if not source_candidates:
        return None
    source_candidates.sort()
    ch_num, a_rel, d = rng.choice(source_candidates)
    chapter = world.chapters[ch_num]
    a = chapter.screens[a_rel]
    old_b_rel = getattr(a, f"screen_index_{d}")
    if not (0 <= old_b_rel < len(chapter.screens)):
        return None  # out-of-range byte; skip rather than invent a target
    old_b = chapter.screens[old_b_rel]

    targets = sorted(
        s.relative_index
        for s in chapter.screens
        if s.section_type == old_b.section_type
        and relative_to_global(ch_num, s.relative_index) not in DO_NOT_RANDOMIZE
        and s.relative_index != a_rel
        and s.relative_index != old_b_rel
    )
    if not targets:
        return None
    c_rel = rng.choice(targets)
    c = chapter.screens[c_rel]

    inv_d = OPPOSITE[d]
    original_bidirectional = (
        is_real_edge(old_b, inv_d)
        and getattr(old_b, f"screen_index_{inv_d}") == a_rel
    )
    if original_bidirectional:
        # Clearing old_b's reverse edge (to NAV_BLOCKED) modifies old_b's bytes —
        # that's only legal if old_b isn't DO_NOT_RANDOMIZE.
        if relative_to_global(ch_num, old_b_rel) in DO_NOT_RANDOMIZE:
            return None
        # Writing c's reverse edge (to a_rel) must land on an empty slot.
        # A non-NAV_BLOCKED slot means we'd destroy either an existing edge to
        # another screen (orphan asymmetry) or a stairway entrance (0xFE).
        if getattr(c, f"screen_index_{inv_d}") != NAV_BLOCKED:
            return None

    prior_a_d = getattr(a, f"screen_index_{d}")
    prior_old_b_inv = getattr(old_b, f"screen_index_{inv_d}")
    prior_c_inv = getattr(c, f"screen_index_{inv_d}")

    def apply() -> None:
        setattr(a, f"screen_index_{d}", c_rel)
        if original_bidirectional:
            setattr(c, f"screen_index_{inv_d}", a_rel)
            setattr(old_b, f"screen_index_{inv_d}", NAV_BLOCKED)

    def undo() -> None:
        setattr(a, f"screen_index_{d}", prior_a_d)
        if original_bidirectional:
            setattr(c, f"screen_index_{inv_d}", prior_c_inv)
            setattr(old_b, f"screen_index_{inv_d}", prior_old_b_inv)

    affected: set[int] = {a_rel, old_b_rel, c_rel}
    return Mutation("reroute_edge", apply, undo, ch_num, affected)


# =============================================================================
# propose_prune — add the return edge to a one-way leaf
# =============================================================================

def propose_prune(world, rng: random.Random) -> Mutation | None:
    """Find a one-way leaf L (all four outgoing = NAV_BLOCKED, in-degree 1)
    and add the reverse edge so L becomes bidirectional with its parent.

    Respects ``DO_NOT_RANDOMIZE`` for both L and its parent. Only parents
    reached via a real edge (not a stairway 0xFE) qualify — the parent's
    direction D must satisfy ``is_real_edge(P, D)``.

    RNG consumption: one ``rng.choice`` over the sorted candidate pool.
    """
    candidates: list[tuple[int, int, int, str]] = []
    for ch_num in sorted(world.chapters.keys()):
        chapter = world.chapters[ch_num]
        n = len(chapter.screens)
        # Per-chapter incoming-edge index.
        in_edges: list[list[tuple[int, str]]] = [[] for _ in range(n)]
        for s in chapter.screens:
            for d in DIRECTIONS:
                if not is_real_edge(s, d):
                    continue
                t_rel = getattr(s, f"screen_index_{d}")
                if 0 <= t_rel < n:
                    in_edges[t_rel].append((s.relative_index, d))
        for leaf in chapter.screens:
            if relative_to_global(ch_num, leaf.relative_index) in DO_NOT_RANDOMIZE:
                continue
            if not is_real_leaf(leaf):
                continue
            incoming = in_edges[leaf.relative_index]
            if len(incoming) != 1:
                continue
            parent_rel, d_from_parent = incoming[0]
            if relative_to_global(ch_num, parent_rel) in DO_NOT_RANDOMIZE:
                continue
            candidates.append((ch_num, leaf.relative_index, parent_rel, d_from_parent))
    if not candidates:
        return None
    candidates.sort()
    ch_num, l_rel, p_rel, d_from_p = rng.choice(candidates)
    chapter = world.chapters[ch_num]
    leaf = chapter.screens[l_rel]
    inv_d = OPPOSITE[d_from_p]
    prior_l_inv = getattr(leaf, f"screen_index_{inv_d}")  # must be NAV_BLOCKED

    def apply() -> None:
        setattr(leaf, f"screen_index_{inv_d}", p_rel)

    def undo() -> None:
        setattr(leaf, f"screen_index_{inv_d}", prior_l_inv)

    return Mutation("prune_deadend", apply, undo, ch_num, {l_rel, p_rel})


# =============================================================================
# Operator registry — sorted by name for stable RNG consumption
# =============================================================================

OPERATORS: tuple[tuple[str, Callable[..., Mutation | None]], ...] = (
    ("prune_deadend", propose_prune),
    ("reroute_edge", propose_reroute),
    ("swap_adjacent_screens", propose_swap),
)


__all__ = [
    "DIRECTIONS",
    "Mutation",
    "OPERATORS",
    "OPPOSITE",
    "build_baseline_asymmetry",
    "check_local_invariants",
    "edge_walkable",
    "get_grid",
    "is_real_edge",
    "is_real_leaf",
    "propose_prune",
    "propose_reroute",
    "propose_swap",
]
