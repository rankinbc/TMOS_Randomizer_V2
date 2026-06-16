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

Increment 1 (this file, so far): the targeting metric `compute_reachable`.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field
from typing import Any, Callable, List, Optional, Set

from ..core.enums import (
    EventType, ContentType, NAV_BLOCKED, NAV_BUILDING_ENTRANCE,
    is_past_screen_index,
)
from ..validation.tiles.categories import is_walkable
from ..validation.tiles.edges import OPPOSITE_DIRECTIONS

_DIRECTIONS = ("right", "left", "down", "up")


@dataclass(frozen=True)
class RepairRecord:
    """A single first-class repair edit (visible, never silent)."""

    action: str           # e.g. "open_in_place"
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

        # Walk edges.
        for direction in _DIRECTIONS:
            t = getattr(screen, f"screen_index_{direction}")
            if t in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if 0 <= t < total and t not in reachable:
                queue.append(t)

        # Stairway warp.
        if screen.event == EventType.STAIRWAY:
            dest = screen.content
            if 0 <= dest < total and dest not in reachable:
                queue.append(dest)

        # Time-door warp: reaching one door lets you step through to its partner(s).
        if screen.content == ContentType.TIME_DOOR:
            for td in time_doors:
                if td != idx and td not in reachable:
                    queue.append(td)

    return reachable


def _is_free_port(screen: Any, direction: str) -> bool:
    """A port is FREE to wire iff it is the blocked sentinel (0xFF). 0xFE building
    entrances and existing screen-index links are NOT free (never overwritten)."""
    return getattr(screen, f"screen_index_{direction}") == NAV_BLOCKED


def repair_chapter(
    chapter: Any,
    edges_provider: Callable[[int], Any],
    *,
    era_of: Callable[[int, int], bool] = is_past_screen_index,
) -> ChapterRepairReport:
    """Make every screen reachable from screen 0 by least-damage edits.

    v1 lever: OPEN IN PLACE -- for each unreachable screen, find a reachable screen
    with a free port whose edge aligns (walkable) with a free port on the unreachable
    screen, same-era, and wire them two-way. Preserves all 0xFE; adds no broken edges;
    never crosses eras by walk. Deterministic (sorted iteration). Screens it cannot
    open are reported in ``unrepaired`` (no silent failure).

    ``edges_provider(idx)`` returns an object with ``get_edge(direction) -> list[int]``.
    """
    report = ChapterRepairReport(chapter_num=chapter.chapter_num)
    report.reachable_before = compute_reachable(chapter)

    reachable = set(report.reachable_before)
    total = chapter.screen_count
    progress = True
    while progress:
        progress = False
        unreachable = sorted(set(range(total)) - reachable)
        for u in unreachable:
            if _try_open_in_place(chapter, u, reachable, edges_provider, era_of, report):
                # u (and anything it newly connects) just became reachable.
                reachable = compute_reachable(chapter)
                progress = True
                break

    report.reachable_after = reachable
    report.unrepaired = set(range(total)) - reachable
    return report


def _try_open_in_place(
    chapter: Any,
    u: int,
    reachable: Set[int],
    edges_provider: Callable[[int], Any],
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
        if r_scr is None:
            continue
        if era_of(ch_num, r) != u_past:  # same-era walk links only
            continue
        for direction in _DIRECTIONS:
            opp = OPPOSITE_DIRECTIONS[direction]
            if not _is_free_port(r_scr, direction) or not _is_free_port(u_scr, opp):
                continue
            if not _edges_aligned(
                edges_provider(r).get_edge(direction),
                edges_provider(u).get_edge(opp),
            ):
                continue
            # Wire two-way.
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
