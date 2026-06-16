"""Generic reachability repair — make every screen reachable from screen 0.

A strategy-agnostic post-generation pass (works on grow, organic, anything). It
drives a warp-aware directed-reachability metric to 100% by least-damage edits,
under four hard invariants:

  * Preserve building entrances (never overwrite a 0xFE byte).
  * Edge-aligned walk links only (>=1 aligned walkable tile pair; no broken edges).
  * Same-era walk links only (PRESENT<->PAST solely through the existing time door).
  * Deterministic (seeded order; same seed -> identical repairs).

Goal is absolute: "100% reachable assuming full movement (all-items)" -- a clean,
soft-lock-proof floor, not a differential against the (progression-gated) vanilla
map. Note this is still a STATIC proxy: it guarantees no walled-off screens given
free movement, not item-gated playability (that confirmation is the P4 emulator).

Repair levers, cheapest first:
  1. open_in_place   -- wire an existing free, aligned, same-era port two-way.
  2. ts_swap_then_open -- change the stranded screen's TileSection (to a CHR-valid pair
     already used by same-datapointer screens) so an edge becomes alignable, then wire.
Future: warp-link (islanded components), relocate (last resort).
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field
from typing import Any, Callable, List, Optional, Set, Tuple

from ..core.enums import (
    EventType, ContentType, NAV_BLOCKED, NAV_BUILDING_ENTRANCE,
    is_past_screen_index,
)
from ..validation.tiles.categories import is_walkable
from ..validation.tiles.edges import OPPOSITE_DIRECTIONS, extract_edges

_DIRECTIONS = ("right", "left", "down", "up")


@dataclass(frozen=True)
class RepairRecord:
    """A single first-class repair edit (visible, never silent)."""

    action: str           # "open_in_place" | "ts_swap_then_open"
    screens: tuple        # screen indices involved
    direction: str        # direction wired on the first screen
    reason: str
    rule: str = "reachability"


@dataclass
class ChapterRepairReport:
    chapter_num: int
    reachable_before: Set[int] = field(default_factory=set)
    reachable_after: Set[int] = field(default_factory=set)
    records: List[RepairRecord] = field(default_factory=list)
    unrepaired: Set[int] = field(default_factory=set)


@dataclass
class WorldRepairReport:
    chapters: dict = field(default_factory=dict)  # chapter_num -> ChapterRepairReport

    @property
    def total_records(self) -> int:
        return sum(len(r.records) for r in self.chapters.values())

    @property
    def total_unrepaired(self) -> int:
        return sum(len(r.unrepaired) for r in self.chapters.values())


def _edges_aligned(edge_a: List[int], edge_b: List[int]) -> bool:
    """True if >=1 position is walkable on both edges (grow's R-015 contract)."""
    for a, b in zip(edge_a, edge_b):
        if is_walkable(a) and is_walkable(b):
            return True
    return False


def compute_reachable(chapter: Any) -> Set[int]:
    """Warp-aware directed reachability from screen 0.

    Follows: walkable nav bytes (excluding 0xFE building entrances and 0xFF blocked),
    stairways (Event 0x40 -> Content destination), and the chapter's time-door pair
    (Content 0xC0 screens are mutually traversable -- the present<->past bridge).

    Warps only fire from a screen that is itself reached -- you can't step through a
    door you can't get to.
    """
    total = chapter.screen_count
    if total == 0:
        return set()

    time_doors = [
        s.relative_index for s in chapter if s.content == ContentType.TIME_DOOR
    ]

    reachable: Set[int] = set()
    queue: deque[int] = deque([0])

    while queue:
        idx = queue.popleft()
        if idx in reachable:
            continue
        screen = chapter.get_screen(idx)
        if screen is None:
            continue
        reachable.add(idx)

        for direction in _DIRECTIONS:
            t = getattr(screen, f"screen_index_{direction}")
            if t in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if 0 <= t < total and t not in reachable:
                queue.append(t)

        if screen.event == EventType.STAIRWAY:
            dest = screen.content
            if 0 <= dest < total and dest not in reachable:
                queue.append(dest)

        if screen.content == ContentType.TIME_DOOR:
            for td in time_doors:
                if td != idx and td not in reachable:
                    queue.append(td)

    return reachable


def _is_free_port(screen: Any, direction: str) -> bool:
    """A port is FREE to wire iff it is the blocked sentinel (0xFF). 0xFE building
    entrances and existing screen-index links are NOT free (never overwritten)."""
    return getattr(screen, f"screen_index_{direction}") == NAV_BLOCKED


def _existing_walk_links(chapter: Any, screen: Any) -> List[Tuple[str, Any]]:
    """(direction, neighbor_screen) for each real walk link out of ``screen``."""
    out: List[Tuple[str, Any]] = []
    for d in _DIRECTIONS:
        t = getattr(screen, f"screen_index_{d}")
        if t in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
            continue
        n = chapter.get_screen(t)
        if n is not None:
            out.append((d, n))
    return out


def repair_chapter(
    chapter: Any,
    edges_of: Callable[[int, int, int], Any],
    *,
    candidate_tiles_of: Optional[Callable[[int], List[Tuple[int, int]]]] = None,
    era_of: Callable[[int, int], bool] = is_past_screen_index,
    allow_warp_links: bool = True,
) -> ChapterRepairReport:
    """Make every screen reachable from screen 0 by least-damage edits.

    Two phases. **Phase 1 (walk levers):** open-in-place, then -- if ``candidate_tiles_of``
    is given -- ts-swap-then-open, applied until no progress. **Phase 2 (warp-link, last
    resort):** for components still stranded (e.g. behind an unreachable time door, or with
    no free/alignable port), add a same-era stairway (Event 0x40 -> Content destination)
    from an expendable reachable screen. Preserves all 0xFE; adds no broken walk edges;
    never crosses eras; deterministic. Leftovers are reported (no silent failure).
    """
    report = ChapterRepairReport(chapter_num=chapter.chapter_num)
    report.reachable_before = compute_reachable(chapter)

    reachable = set(report.reachable_before)
    total = chapter.screen_count

    # Phase 1 — walk levers.
    progress = True
    while progress:
        progress = False
        for u in sorted(set(range(total)) - reachable):
            if _try_open_in_place(chapter, u, reachable, edges_of, era_of, report) or (
                candidate_tiles_of is not None
                and _try_ts_swap_then_open(
                    chapter, u, reachable, edges_of, candidate_tiles_of, era_of, report
                )
            ):
                reachable = compute_reachable(chapter)
                progress = True
                break

    # Phase 2 — warp-link the genuinely-stranded remainder.
    if allow_warp_links:
        progress = True
        while progress:
            progress = False
            for u in sorted(set(range(total)) - reachable):
                if _try_warp_link(chapter, u, reachable, era_of, report):
                    reachable = compute_reachable(chapter)
                    progress = True
                    break

    report.reachable_after = reachable
    report.unrepaired = set(range(total)) - reachable
    return report


def _is_expendable(screen: Any) -> bool:
    """A screen with no content/event role -- safe to repurpose as a stairway endpoint
    (its Content byte is free to hold a destination; nothing is clobbered)."""
    return screen.content == 0 and screen.event == 0


def _try_warp_link(
    chapter: Any,
    u: int,
    reachable: Set[int],
    era_of: Callable[[int, int], bool],
    report: ChapterRepairReport,
) -> bool:
    """Connect stranded screen ``u`` via a same-era stairway from an expendable reachable
    screen (Event 0x40, Content = u). Bidirectional when ``u`` is itself expendable (avoids
    a one-way soft-lock); one-way otherwise (e.g. a time door, which provides its own return).
    """
    ch_num = chapter.chapter_num
    u_past = era_of(ch_num, u)
    u_scr = chapter.get_screen(u)
    if u_scr is None:
        return False

    for r in sorted(reachable):
        if r == 0:
            continue  # never repurpose the start screen
        r_scr = chapter.get_screen(r)
        if r_scr is None or era_of(ch_num, r) != u_past or not _is_expendable(r_scr):
            continue
        r_scr.event = EventType.STAIRWAY
        r_scr.content = u
        r_scr.mark_modified()
        bidirectional = _is_expendable(u_scr)
        if bidirectional:
            u_scr.event = EventType.STAIRWAY
            u_scr.content = r
            u_scr.mark_modified()
        report.records.append(RepairRecord(
            action="warp_link",
            screens=(r, u),
            direction="",
            reason=(
                f"screen {u} was stranded (no walk route); added a "
                f"{'bidirectional' if bidirectional else 'one-way'} stairway from "
                f"expendable reachable screen {r}"
            ),
        ))
        return True
    return False


def _try_open_in_place(
    chapter: Any,
    u: int,
    reachable: Set[int],
    edges_of: Callable[[int, int, int], Any],
    era_of: Callable[[int, int], bool],
    report: ChapterRepairReport,
) -> bool:
    u_scr = chapter.get_screen(u)
    if u_scr is None:
        return False
    ch_num = chapter.chapter_num
    u_past = era_of(ch_num, u)

    for r in sorted(reachable):
        r_scr = chapter.get_screen(r)
        if r_scr is None or era_of(ch_num, r) != u_past:
            continue
        for direction in _DIRECTIONS:
            opp = OPPOSITE_DIRECTIONS[direction]
            if not _is_free_port(r_scr, direction) or not _is_free_port(u_scr, opp):
                continue
            if not _edges_aligned(
                edges_of(r, r_scr.top_tiles, r_scr.bottom_tiles).get_edge(direction),
                edges_of(u, u_scr.top_tiles, u_scr.bottom_tiles).get_edge(opp),
            ):
                continue
            setattr(r_scr, f"screen_index_{direction}", u)
            setattr(u_scr, f"screen_index_{opp}", r)
            r_scr.mark_modified()
            u_scr.mark_modified()
            report.records.append(RepairRecord(
                action="open_in_place",
                screens=(r, u),
                direction=direction,
                reason=f"screen {u} was unreachable; opened a two-way walk link "
                       f"from reachable screen {r} ({direction})",
            ))
            return True
    return False


def _try_ts_swap_then_open(
    chapter: Any,
    u: int,
    reachable: Set[int],
    edges_of: Callable[[int, int, int], Any],
    candidate_tiles_of: Callable[[int], List[Tuple[int, int]]],
    era_of: Callable[[int, int], bool],
    report: ChapterRepairReport,
) -> bool:
    u_scr = chapter.get_screen(u)
    if u_scr is None:
        return False
    candidates = candidate_tiles_of(u)
    if not candidates:
        return False
    ch_num = chapter.chapter_num
    u_past = era_of(ch_num, u)
    existing = _existing_walk_links(chapter, u_scr)

    for r in sorted(reachable):
        r_scr = chapter.get_screen(r)
        if r_scr is None or era_of(ch_num, r) != u_past:
            continue
        for direction in _DIRECTIONS:
            opp = OPPOSITE_DIRECTIONS[direction]
            if not _is_free_port(r_scr, direction) or not _is_free_port(u_scr, opp):
                continue
            r_edge = edges_of(r, r_scr.top_tiles, r_scr.bottom_tiles).get_edge(direction)
            for (top, bot) in candidates:
                cand = edges_of(u, top, bot)
                if not _edges_aligned(r_edge, cand.get_edge(opp)):
                    continue
                # A swap changes ALL of u's edges -- it must not break an existing link.
                if any(
                    not _edges_aligned(
                        cand.get_edge(d),
                        edges_of(n.relative_index, n.top_tiles, n.bottom_tiles)
                        .get_edge(OPPOSITE_DIRECTIONS[d]),
                    )
                    for d, n in existing
                ):
                    continue
                u_scr.top_tiles, u_scr.bottom_tiles = top, bot
                setattr(r_scr, f"screen_index_{direction}", u)
                setattr(u_scr, f"screen_index_{opp}", r)
                r_scr.mark_modified()
                u_scr.mark_modified()
                report.records.append(RepairRecord(
                    action="ts_swap_then_open",
                    screens=(r, u),
                    direction=direction,
                    reason=f"screen {u} had no alignable port; swapped its TileSection "
                           f"to ({top},{bot}) to align with reachable screen {r} ({direction})",
                ))
                return True
    return False


def _rom_edges_provider(chapter: Any, rom_data: bytes) -> Callable[[int, int, int], Any]:
    """Real edges provider: extract_edges from ROM, cached per (idx, top, bot)."""
    cache: dict = {}

    def edges_of(idx: int, top: int, bot: int) -> Any:
        key = (idx, top, bot)
        if key not in cache:
            scr = chapter.get_screen(idx)
            cache[key] = extract_edges(rom_data, idx, top, bot, scr.datapointer)
        return cache[key]

    return edges_of


def _rom_candidate_tiles(chapter: Any) -> Callable[[int], List[Tuple[int, int]]]:
    """CHR-valid TileSection candidates for a screen: the (top, bot) pairs already used
    by same-datapointer screens in this chapter (guaranteed to render correctly)."""
    by_dp: dict = {}
    for s in chapter.screens:
        by_dp.setdefault(s.datapointer, set()).add((s.top_tiles, s.bottom_tiles))

    def candidates(idx: int) -> List[Tuple[int, int]]:
        scr = chapter.get_screen(idx)
        cur = (scr.top_tiles, scr.bottom_tiles)
        return sorted(p for p in by_dp.get(scr.datapointer, set()) if p != cur)

    return candidates


def repair_reachability(
    game_world: Any,
    rom_data: bytes,
    *,
    era_of: Callable[[int, int], bool] = is_past_screen_index,
    edges_provider_for: Optional[Callable[[Any], Callable[[int, int, int], Any]]] = None,
    candidate_tiles_for: Optional[Callable[[Any], Callable[[int], List[Tuple[int, int]]]]] = None,
) -> WorldRepairReport:
    """Run reachability repair over every chapter of a finished GameWorld.

    Strategy-agnostic: call after any generator, before the oracle. The provider hooks
    are injectable for testing; production uses ROM-backed extract_edges + same-CHR tiles.
    """
    report = WorldRepairReport()
    for chapter in game_world:
        edges_of = (
            edges_provider_for(chapter) if edges_provider_for is not None
            else _rom_edges_provider(chapter, rom_data)
        )
        cand = (
            candidate_tiles_for(chapter) if candidate_tiles_for is not None
            else _rom_candidate_tiles(chapter)
        )
        report.chapters[chapter.chapter_num] = repair_chapter(
            chapter, edges_of, candidate_tiles_of=cand, era_of=era_of
        )
    return report
