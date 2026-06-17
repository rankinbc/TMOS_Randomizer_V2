"""Era-aware physical reachability for the item-gating checker.

This reuses the *exact* physical-edge semantics the rest of the randomizer uses
(``WorldScreen.get_neighbor`` for directional pointers, stairway ``Event 0x40``
Content-as-destination jumps, ``DIRECTIONS``) and layers a single logical join on
top: **Time Doors** (Content 0xC0 / 0xC7 / 0xD7) unlock the opposite time period.

The traversal is a fixed-point BFS:

1. Start in the entry screen's era (the era set is initially ``{era(entry)}``).
2. BFS from the entry, but only *enter* a screen whose era is currently unlocked.
3. When a Time Door screen is reached, unlock the opposite era and re-run the BFS.
4. Repeat to a fixed point.

This matches the user's resolved rule — "Time Doors join PRESENT<->PAST freely;
no scarce-item gate on any time door" — without pretending the static directional
graph models the engine's warp targets (it doesn't). Era unlock is the load
bearing logical edge; everything else is the real physical graph.

The result records exactly which era regions were reached, which is what the
checker turns into obtainable progression tokens (an acquirable is obtainable iff
its era region is reachable).
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field
from typing import Set

from ...core.chapter import Chapter
from ...core.enums import is_past_screen_index
from ...logic.navigation import DIRECTIONS
from .model import Era


# Content byte values that act as Time Doors (PRESENT<->PAST joins).
_TIME_DOOR_CONTENT = {0xC0, 0xC7, 0xD7}


def _era_of(chapter_num: int, screen_index: int) -> Era:
    return Era.PAST if is_past_screen_index(chapter_num, screen_index) else Era.PRESENT


@dataclass
class EraReachability:
    """Result of an era-aware reachability sweep over one chapter.

    Attributes:
        chapter: Chapter number.
        reachable: Set of relative screen indices reachable from the entry,
            honouring era unlocking.
        unlocked_eras: The set of Eras the player can stand in.
        time_doors_reached: Relative indices of Time Door screens actually reached
            (these are what justify the era unlock; empty means no era crossing
            was possible).
    """

    chapter: int
    reachable: Set[int] = field(default_factory=set)
    unlocked_eras: Set[Era] = field(default_factory=set)
    time_doors_reached: Set[int] = field(default_factory=set)

    def era_reachable(self, era: Era) -> bool:
        """Is any screen of this era reachable?"""
        return era in self.unlocked_eras and any(
            era == _era_of(self.chapter, i) for i in self.reachable
        )


def compute_era_reachability(chapter: Chapter, entry_screen: int = 0) -> EraReachability:
    """Fixed-point era-aware BFS over the chapter's physical graph.

    Args:
        chapter: Chapter whose (possibly randomized) screens to traverse.
        entry_screen: Relative index of the chapter entry (default 0).

    Returns:
        EraReachability with reachable screens, unlocked eras and reached doors.
    """
    chapter_num = chapter.chapter_num
    screen_count = chapter.screen_count

    if screen_count == 0:
        return EraReachability(chapter=chapter_num)

    if entry_screen < 0 or entry_screen >= screen_count:
        entry_screen = 0

    unlocked: Set[Era] = {_era_of(chapter_num, entry_screen)}
    reachable: Set[int] = set()
    doors_reached: Set[int] = set()

    changed = True
    while changed:
        changed = False
        # Full BFS from the entry under the *current* unlocked-era set. Re-running
        # the whole sweep each time an era unlocks keeps the logic obviously
        # correct (a fresh frontier can now enter newly-unlocked screens that may
        # themselves be adjacent to more doors / goals).
        seen: Set[int] = set()
        queue: deque[int] = deque([entry_screen])

        while queue:
            current = queue.popleft()
            if current in seen:
                continue
            if _era_of(chapter_num, current) not in unlocked:
                continue  # can't stand here yet — needs an era unlock

            screen = chapter.get_screen(current)
            if screen is None:
                continue

            seen.add(current)

            # Time Door: unlock the opposite era.
            if screen.content in _TIME_DOOR_CONTENT:
                doors_reached.add(current)
                opposite = Era.PRESENT if _era_of(chapter_num, current) == Era.PAST else Era.PAST
                if opposite not in unlocked:
                    unlocked.add(opposite)
                    changed = True

            # Directional physical edges (reuses WorldScreen.get_neighbor, which
            # already filters 0xFE building-entrance and 0xFF blocked).
            for direction in DIRECTIONS:
                neighbor = screen.get_neighbor(direction)
                if neighbor is not None and neighbor < screen_count and neighbor not in seen:
                    queue.append(neighbor)

            # Stairway physical edge (Event 0x40, Content = destination).
            if screen.is_stairway:
                dest = screen.content
                if dest < screen_count and dest not in seen:
                    queue.append(dest)

        reachable = seen

    return EraReachability(
        chapter=chapter_num,
        reachable=reachable,
        unlocked_eras=unlocked,
        time_doors_reached=doors_reached,
    )
