"""Turn a grown chapter layout into navigable WorldScreen nav bytes (v0.3.0).

``grow`` produces, per section, a grid ``{(x, y): relative_index}`` where every
grid-adjacency is edge-valid by construction (aligned walkable tiles). This module
realizes that layout as navigation, in three passes over the deepcopied world's
``WorldScreen`` objects:

1. **Tile-swap application** — apply each section's ``overrides`` to the screen's
   ``top_tiles``/``bottom_tiles`` so the screen's *effective* edges match what grow
   computed. A placement is only valid with its swap applied.
2. **Intra-section nav** (port of V2 ``strategies/grow_nav.apply_grid_navigation``)
   — grid-adjacent cells wired bidirectionally; non-neighbor edges blocked (0xFF),
   except building entrances (0xFE) which are preserved.
3. **Inter-section linking** — join the per-section blobs into one component per
   chapter via edge-verified **same-era** walk-across links, plus preserved stairway
   (Event 0x40) and time-door (Content 0xC0) warps seeded into the union-find; sections
   that can't be joined to the component containing chapter-relative screen 0 are
   reported, never hidden.

PORT, not import: V2's ``grow_nav`` is a *strategy*; the Lab reuses only V2
``core``/``io``/``validation`` (here via ``_v2_compat`` and the same direct
``tmos_randomizer.validation`` imports ``impl.py`` already uses). Sentinel byte
values come from ``_v2_compat`` — never hardcoded.
"""

from __future__ import annotations

import random
from typing import Any

# V2 edge math — same direct imports impl.py uses (validation layer, not strategies).
from tmos_randomizer.validation.tiles.categories import is_walkable  # type: ignore[import-untyped]
from tmos_randomizer.validation.tiles.edges import (  # type: ignore[import-untyped]
    OPPOSITE_DIRECTIONS,
    ScreenEdges,
    extract_edges,
)

from ..._v2_compat.parsers import (  # sentinels + content enum — never hardcode 0xFF/0xFE/0xC0
    NAV_BLOCKED,
    NAV_BUILDING_ENTRANCE,
    ContentType,
)

# Identical to impl.DIRECTION_DELTAS — kept local to avoid an impl <-> navwrite import
# cycle (impl imports navwrite lazily inside generate()). Order is load-bearing for
# determinism: right, left, down, up.
DIRECTION_DELTAS: dict[str, tuple[int, int]] = {
    "right": (1, 0),
    "left": (-1, 0),
    "down": (0, 1),
    "up": (0, -1),
}
_DIR_RANK: dict[str, int] = {"right": 0, "left": 1, "down": 2, "up": 3}


# =============================================================================
# Pass 1 — tile-swap application
# =============================================================================

def apply_tile_swaps(chapter: Any, section: Any) -> int:
    """Apply a section's ``overrides`` to the chapter's WorldScreen objects.

    ``overrides`` maps ``relative_index -> (new_top_tiles, new_bottom_tiles)``.
    Native (non-swapped) placements keep their original bytes. A swap whose target
    index is out of range is a hard ``ValueError`` — never silently skipped
    (REQUIREMENTS.md §6 N-2: no silent failures).

    Returns the number of swaps applied.
    """
    for rel_idx, (new_top, new_bot) in sorted(section.overrides.items()):
        if not (0 <= rel_idx < len(chapter.screens)):
            raise ValueError(
                f"grow_nav: swap target relative_index {rel_idx} out of range "
                f"for chapter {getattr(chapter, 'chapter_num', '?')} "
                f"({len(chapter.screens)} screens)."
            )
        scr = chapter.screens[rel_idx]
        scr.top_tiles = new_top
        scr.bottom_tiles = new_bot
    return len(section.overrides)


# =============================================================================
# Pass 2 — intra-section navigation (port of V2 apply_grid_navigation)
# =============================================================================

def apply_grid_navigation(
    screens_by_index: dict[int, Any],
    grid: dict[tuple[int, int], int],
    *,
    block_non_neighbors: bool = True,
    preserve_building_entrances: bool = True,
) -> int:
    """Wire navigation for one grown section's grid (port of V2 grow_nav).

    Grid-adjacent cells are wired bidirectionally (both cells are processed, so the
    reverse pointer falls out). Edges with no grid neighbor are set to ``NAV_BLOCKED``
    (0xFF).

    Diverges from the literal V2 port in one way, mandated by the PRP/spec ("preserve
    all NAV_BUILDING_ENTRANCE bytes everywhere"): when ``preserve_building_entrances``,
    a byte already set to ``NAV_BUILDING_ENTRANCE`` (0xFE) is *never* overwritten —
    not even by a grid-neighbor wire. grow plans by tile edges and is blind to nav
    bytes, so a placed grid neighbor can land on an edge the stock data marks as a
    building entrance; the entrance wins. The neighbor still points back (its opposite
    edge is a normal index), so the adjacency is one-way, never a metric failure.

    ``grid`` is iterated in sorted order so the pass is deterministic regardless of
    dict insertion order (this pass uses no RNG, but determinism is load-bearing).

    Returns the number of screens whose navigation was touched.
    """
    touched = 0
    for _pos, idx in sorted(grid.items()):
        scr = screens_by_index.get(idx)
        if scr is None:
            continue
        x, y = _pos
        changed = False
        for direction, (dx, dy) in DIRECTION_DELTAS.items():
            attr = f"screen_index_{direction}"
            if preserve_building_entrances and getattr(scr, attr) == NAV_BUILDING_ENTRANCE:
                continue  # building entrance is preserved over neighbor-wire AND block
            neighbor_pos = (x + dx, y + dy)
            if neighbor_pos in grid:
                setattr(scr, attr, grid[neighbor_pos])
                changed = True
            elif block_non_neighbors:
                setattr(scr, attr, NAV_BLOCKED)
                changed = True
        if changed:
            touched += 1
    return touched


# =============================================================================
# Pass 3 — inter-section linking
# =============================================================================

def _section_edges(chapter: Any, rel_idx: int, rom_data: bytes) -> ScreenEdges:
    """Effective edges of a placed screen. Call AFTER swaps are applied, so the
    screen's current ``top_tiles``/``bottom_tiles`` already reflect any override."""
    scr = chapter.screens[rel_idx]
    return extract_edges(rom_data, rel_idx, scr.top_tiles, scr.bottom_tiles, scr.datapointer)


def _edges_aligned(edge_a: list[int], edge_b: list[int], min_walkable: int = 1) -> bool:
    """True if the two edges share >= ``min_walkable`` aligned walkable positions.

    Local copy of ``impl._edges_aligned`` (V2 validator rule R-015) — the same
    contract grow uses internally, so a link that passes here is edge-valid by
    construction. Kept local to avoid an impl <-> navwrite import cycle.
    """
    n = min(len(edge_a), len(edge_b))
    aligned = 0
    for i in range(n):
        if is_walkable(edge_a[i]) and is_walkable(edge_b[i]):
            aligned += 1
            if aligned >= min_walkable:
                return True
    return False


def _placed_cell_section(growth: Any) -> dict[int, int]:
    """Map every placed ``relative_index`` to its ``section_id`` (deterministic)."""
    rel2sec: dict[int, int] = {}
    for s in sorted(growth.sections, key=lambda s: s.section_id):
        for idx in sorted(set(s.grid.values())):
            rel2sec[idx] = s.section_id
    return rel2sec


def _detect_warps(chapter: Any) -> tuple[list[int], list[int]]:
    """Return ``(stairway_rel_indices, time_door_rel_indices)``, each sorted.

    Stairways are Event byte == 0x40 (via the V2 ``WorldScreen.is_stairway``
    property); time doors are Content byte == 0xC0 (``ContentType.TIME_DOOR``).
    Detection uses V2 semantics — sentinel/marker bytes are never hardcoded here.
    """
    stairways = sorted(s.relative_index for s in chapter.screens if s.is_stairway)
    time_doors = sorted(
        s.relative_index for s in chapter.screens if s.content == ContentType.TIME_DOOR
    )
    return stairways, time_doors


def _bridged_section(chapter: Any, warp_rel_idx: int | None, rel2sec: dict[int, int]) -> int | None:
    """Section a warp screen reaches through its (stock, unrewritten) directional nav.

    Returns the ``section_id`` of the first in-range directional exit that lands on
    a placed cell, in fixed ``DIRECTION_DELTAS`` order; ``None`` if the screen
    reaches no placed cell. Warps teleport, so no edge alignment is required.
    """
    if warp_rel_idx is None or not (0 <= warp_rel_idx < len(chapter.screens)):
        return None
    if warp_rel_idx in rel2sec:  # the warp screen IS itself a placed cell (e.g. a stairway)
        return rel2sec[warp_rel_idx]
    scr = chapter.screens[warp_rel_idx]
    for d in DIRECTION_DELTAS:
        v = getattr(scr, f"screen_index_{d}")
        if v in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
            continue
        if v in rel2sec:
            return rel2sec[v]
    return None


def link_sections(
    chapter: Any,
    ch_num: int,
    growth: Any,
    rom_data: bytes,
    rng: random.Random,
) -> dict[str, Any]:
    """Join a chapter's grown sections into one reachable component (era-safe, warp-aware).

    Two connector mechanisms, matching how the ROM navigates:

    * **Walk-across** — a *free edge* (post-intra ``NAV_BLOCKED``, i.e. no grid
      neighbor and not a preserved 0xFE) on a boundary cell of section S paired with
      the opposite free edge on a boundary cell of section T, requiring
      ``_edges_aligned``. Only formed between **same-era** sections
      (``section.spec.is_past``) — ordinary directional nav never bridges
      PRESENT↔PAST (grow hard-rule #2, enforced here at link time).
    * **Warp** — preserved stairway pairs (Event 0x40; may be placed cells, in which
      case the cell's own section anchors the bridge) and the chapter's time-door pair
      (Content 0xC0; pool-excluded orphans, anchored via their stock directional exit)
      seed the union-find as fixed edges (no alignment — warps teleport). The time door
      is the ONLY legal PRESENT↔PAST bridge, so it is the only way a PAST section joins
      the PRESENT component.

    Determinism: sections sorted by ``section_id``; cells by ``(rel_idx, dir_rank)``;
    viable lists ``sorted(...)``; pairs over ``sorted(viable.keys())``; warp seeding
    is RNG-free and iterates sorted warp indices. The only RNG draw is selecting which
    still-free walk-across candidate to use per unconnected same-era pair, over a
    pre-sorted, port-filtered list.

    Returns ``{walkacross_links, warp_links, stairways_preserved, time_doors_preserved,
    unlinked_sections, blocked_edges_written}``. ``unlinked_sections`` lists section_ids
    not joined to screen-0's component.
    """
    sections = sorted(growth.sections, key=lambda s: s.section_id)
    stairways, time_doors = _detect_warps(chapter)
    rel2sec = _placed_cell_section(growth)

    # Time-door screens are pool-excluded (by content in _build_pool) → must never be
    # placed. Stairways are NOT pool-excluded and legitimately CAN be placed cells;
    # their content/event bytes are preserved regardless (navwrite only writes
    # screen_index_* and tiles).
    placed_time_doors = sorted(set(time_doors) & set(rel2sec))
    if placed_time_doors:
        raise ValueError(
            f"grow_nav: time-door screen(s) {placed_time_doors} were placed in a "
            f"section (chapter {ch_num}) — pool exclusion violated."
        )

    base_stats: dict[str, Any] = {
        "walkacross_links": 0,
        "warp_links": 0,
        "stairways_preserved": len(stairways),
        "time_doors_preserved": len(time_doors),
        "unlinked_sections": [],
        "blocked_edges_written": 0,
    }
    if len(sections) <= 1:
        return base_stats

    era = {s.section_id: bool(s.spec.is_past) for s in sections}

    # Effective edges for every placed cell (swaps already applied to chapter.screens).
    edges: dict[int, dict[int, ScreenEdges]] = {}
    for s in sections:
        edges[s.section_id] = {
            idx: _section_edges(chapter, idx, rom_data)
            for idx in sorted(set(s.grid.values()))
        }

    # Free edges per section: placed cell + direction with no grid neighbor and a
    # current byte that is not a preserved building entrance (0xFE).
    free: dict[int, list[tuple[int, str]]] = {}
    for s in sections:
        fl: list[tuple[int, str]] = []
        for (x, y), idx in s.grid.items():
            scr = chapter.screens[idx]
            for d, (dx, dy) in DIRECTION_DELTAS.items():
                if (x + dx, y + dy) in s.grid:
                    continue  # has an intra neighbor — not free
                if getattr(scr, f"screen_index_{d}") == NAV_BUILDING_ENTRANCE:
                    continue  # preserve 0xFE; never repurpose as a link port
                fl.append((idx, d))
        free[s.section_id] = sorted(fl, key=lambda t: (t[0], _DIR_RANK[t[1]]))

    # Viable links per ordered-unique section pair (sid_a < sid_b).
    sids = [s.section_id for s in sections]
    viable: dict[tuple[int, int], list[tuple[int, str, int]]] = {}
    for i in range(len(sids)):
        for j in range(i + 1, len(sids)):
            a, b = sids[i], sids[j]
            if era[a] != era[b]:
                continue  # ERA GUARD — walk-across never bridges PRESENT↔PAST
            cands: list[tuple[int, str, int]] = []
            for (a_idx, d) in free[a]:
                od = OPPOSITE_DIRECTIONS[d]
                a_edge = edges[a][a_idx].get_edge(d)
                for (b_idx, bd) in free[b]:
                    if bd != od:
                        continue
                    if _edges_aligned(a_edge, edges[b][b_idx].get_edge(od)):
                        cands.append((a_idx, d, b_idx))
            if cands:
                viable[(a, b)] = sorted(cands)

    # Union-find spanning.
    parent = {sid: sid for sid in sids}

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        parent[find(x)] = find(y)

    # --- Warp seeding (deterministic, RNG-free, no edge alignment required) ---
    # Stairway pairs and the chapter's time-door pair bridge the sections their
    # (stock) directional exits land on. Seed BEFORE walk-across so already-warped
    # components aren't redundantly walk-across-linked.
    warp_links = 0
    for w in stairways:
        dest = chapter.screens[w].stairway_destination
        s_w = _bridged_section(chapter, w, rel2sec)
        s_d = _bridged_section(chapter, dest, rel2sec)
        if s_w is not None and s_d is not None and find(s_w) != find(s_d):
            union(s_w, s_d)
            warp_links += 1
    if len(time_doors) == 2:  # the only legal PRESENT↔PAST bridge (exactly 2/chapter)
        s0 = _bridged_section(chapter, time_doors[0], rel2sec)
        s1 = _bridged_section(chapter, time_doors[1], rel2sec)
        if s0 is not None and s1 is not None and find(s0) != find(s1):
            union(s0, s1)
            warp_links += 1

    def _port_free(c: tuple[int, str, int]) -> bool:
        a_idx, d, b_idx = c
        od = OPPOSITE_DIRECTIONS[d]
        return (
            getattr(chapter.screens[a_idx], f"screen_index_{d}") == NAV_BLOCKED
            and getattr(chapter.screens[b_idx], f"screen_index_{od}") == NAV_BLOCKED
        )

    walkacross_links = 0
    pair_keys = sorted(viable.keys())
    progress = True
    while progress:
        progress = False
        for (a, b) in pair_keys:
            if find(a) == find(b):
                continue
            # Only consider candidates whose ports are still free (a port may have
            # been consumed by an earlier link). Filtering a sorted list keeps order.
            cands = [c for c in viable[(a, b)] if _port_free(c)]
            if not cands:
                continue
            a_idx, d, b_idx = cands[rng.randrange(len(cands))]
            od = OPPOSITE_DIRECTIONS[d]
            setattr(chapter.screens[a_idx], f"screen_index_{d}", b_idx)
            setattr(chapter.screens[b_idx], f"screen_index_{od}", a_idx)
            union(a, b)
            walkacross_links += 1
            progress = True

    # Report sections not joined to chapter-relative screen 0's component.
    root_of_zero: int | None = None
    for s in sections:
        if 0 in s.grid.values():
            root_of_zero = find(s.section_id)
            break
    if root_of_zero is None:  # screen 0 unplaced — root on the smallest component id
        root_of_zero = min(find(sid) for sid in sids)
    unlinked = sorted(s.section_id for s in sections if find(s.section_id) != root_of_zero)
    return {
        "walkacross_links": walkacross_links,
        "warp_links": warp_links,
        "stairways_preserved": len(stairways),
        "time_doors_preserved": len(time_doors),
        "unlinked_sections": unlinked,
        "blocked_edges_written": 0,  # filled by write_navigation's intra pass
    }


# =============================================================================
# Orchestrator
# =============================================================================

def write_navigation(
    chapter: Any,
    ch_num: int,
    growth: Any,
    rom_data: bytes,
    rng: random.Random,
) -> dict[str, Any]:
    """Run all three passes for one chapter, mutating ``chapter.screens`` in place.

    Returns per-chapter stats: ``swaps_applied``, ``walkacross_links``,
    ``warp_links``, ``stairways_preserved``, ``time_doors_preserved``,
    ``unlinked_sections`` (section_ids), ``blocked_edges_written``.
    """
    ordered = sorted(growth.sections, key=lambda s: s.section_id)

    # Pass 1: tile-swaps (must precede edge extraction in pass 3).
    swaps_applied = sum(apply_tile_swaps(chapter, s) for s in ordered)

    # Pass 2: intra-section nav. Count edges we set to NAV_BLOCKED for the breadcrumb.
    blocked = 0
    for s in ordered:
        screens_by_index = {idx: chapter.screens[idx] for idx in s.grid.values()}
        apply_grid_navigation(screens_by_index, s.grid)
        for (x, y), idx in s.grid.items():
            scr = chapter.screens[idx]
            for d, (dx, dy) in DIRECTION_DELTAS.items():
                if (x + dx, y + dy) not in s.grid and getattr(scr, f"screen_index_{d}") == NAV_BLOCKED:
                    blocked += 1

    # Pass 3: inter-section linking (consumes some blocked edges → real links).
    link_stats = link_sections(chapter, ch_num, growth, rom_data, rng)

    return {
        "swaps_applied": swaps_applied,
        "walkacross_links": link_stats["walkacross_links"],
        "warp_links": link_stats["warp_links"],
        "stairways_preserved": link_stats["stairways_preserved"],
        "time_doors_preserved": link_stats["time_doors_preserved"],
        "unlinked_sections": link_stats["unlinked_sections"],
        "blocked_edges_written": blocked,
    }


__all__ = [
    "apply_tile_swaps",
    "apply_grid_navigation",
    "link_sections",
    "write_navigation",
    "DIRECTION_DELTAS",
]
