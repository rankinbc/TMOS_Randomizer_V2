"""Reachability repair — generic post-generation pass that guarantees every screen
is reachable from screen 0 (warp-aware), repairing by least-damage edits.

Increment 1: the warp-aware reachability foundation `compute_reachable` -- the
targeting metric the repair loop drives to 100%. It follows walk edges, stairways
(Event 0x40 -> Content destination), and the chapter's time-door pair (Content 0xC0,
present<->past) -- all derived from the world, matching the ROM_VERIFIED structure.
"""

from __future__ import annotations

from tmos_randomizer.core.chapter import Chapter, GameWorld
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.core.enums import (
    EventType, ContentType, NAV_BLOCKED, NAV_BUILDING_ENTRANCE,
)
from tmos_randomizer.validation.tiles.categories import is_walkable
from tmos_randomizer.repair.reachability_repair import (
    compute_reachable, repair_chapter, repair_reachability,
)

# Real walkable / non-walkable tile ids (alignment uses the real is_walkable predicate).
WALK = next(i for i in range(256) if is_walkable(i))
BLOCK = next(i for i in range(256) if not is_walkable(i))


class _FakeEdges:
    """Stand-in for ScreenEdges: maps direction -> list of tile ids."""

    def __init__(self, by_dir: dict[str, list[int]]):
        self._by_dir = by_dir

    def get_edge(self, direction: str) -> list[int]:
        return self._by_dir.get(direction, [])


def _edges_provider(table: dict[int, dict[str, list[int]]]):
    return lambda idx: _FakeEdges(table.get(idx, {}))


_ALL_PRESENT = lambda chapter_num, idx: False  # noqa: E731  (test era stub)


def _scr(rel: int, content: int = 0, event: int = 0, **nav: int) -> WorldScreen:
    return WorldScreen(
        global_index=rel, chapter=1, relative_index=rel, content=content, event=event,
        screen_index_right=nav.get("right", NAV_BLOCKED),
        screen_index_left=nav.get("left", NAV_BLOCKED),
        screen_index_down=nav.get("down", NAV_BLOCKED),
        screen_index_up=nav.get("up", NAV_BLOCKED),
    )


def _chapter(*screens: WorldScreen) -> Chapter:
    ch = Chapter(chapter_num=1)
    for s in screens:
        ch.add_screen(s)
    return ch


def test_follows_walk_edges():
    chapter = _chapter(_scr(0, right=1), _scr(1, left=0), _scr(2))
    assert compute_reachable(chapter) == {0, 1}  # screen 2 isolated


def test_follows_stairways():
    chapter = _chapter(
        _scr(0, right=1),
        _scr(1, event=EventType.STAIRWAY, content=2),  # stairway -> 2
        _scr(2),
    )
    assert compute_reachable(chapter) == {0, 1, 2}


def test_follows_time_door_pair():
    chapter = _chapter(
        _scr(0, right=1),
        _scr(1, content=ContentType.TIME_DOOR, left=0),  # reachable time door
        _scr(2, content=ContentType.TIME_DOOR),          # its partner, walk-isolated
    )
    assert compute_reachable(chapter) == {0, 1, 2}


def test_unreached_warp_does_not_teleport():
    chapter = _chapter(
        _scr(0),                                          # isolated start
        _scr(1, content=ContentType.TIME_DOOR),           # unreachable
        _scr(2, content=ContentType.TIME_DOOR),           # unreachable partner
    )
    assert compute_reachable(chapter) == {0}


# --- Increment 2: open-in-place repair --------------------------------------

def test_open_in_place_links_unreachable_screen():
    """Screen 1 is unreachable but has a free port whose edge aligns with a free
    port on reachable screen 0 -> repair wires them two-way. Nothing relocated."""
    s0, s1 = _scr(0), _scr(1)  # all ports blocked (0xFF = free) initially
    chapter = _chapter(s0, s1)
    table = {
        0: {"right": [WALK, WALK]},
        1: {"left": [WALK, WALK]},   # 0.right aligns with 1.left
    }
    report = repair_chapter(chapter, _edges_provider(table), era_of=_ALL_PRESENT)

    assert 1 in report.reachable_after
    assert s0.screen_index_right == 1
    assert s1.screen_index_left == 0
    assert report.records and report.records[0].action == "open_in_place"
    assert not report.unrepaired


def test_repair_never_overwrites_a_building_entrance():
    """If the only facing port on the unreachable screen is a 0xFE building entrance,
    repair must NOT use/overwrite it -> screen stays unrepaired, 0xFE preserved."""
    s0 = _scr(0)
    s1 = _scr(1, left=NAV_BUILDING_ENTRANCE)  # its left (facing 0) is a building
    chapter = _chapter(s0, s1)
    table = {0: {"right": [WALK, WALK]}, 1: {"left": [WALK, WALK]}}
    report = repair_chapter(chapter, _edges_provider(table), era_of=_ALL_PRESENT)

    assert s1.screen_index_left == NAV_BUILDING_ENTRANCE  # untouched
    assert 1 in report.unrepaired
    assert 1 not in report.reachable_after


def test_repair_requires_edge_alignment():
    """No aligned walkable tiles across the seam -> open-in-place cannot wire it."""
    s0, s1 = _scr(0), _scr(1)
    chapter = _chapter(s0, s1)
    table = {0: {"right": [BLOCK, BLOCK]}, 1: {"left": [BLOCK, BLOCK]}}  # no walkable
    report = repair_chapter(chapter, _edges_provider(table), era_of=_ALL_PRESENT)

    assert s0.screen_index_right == NAV_BLOCKED  # not wired
    assert 1 in report.unrepaired


def test_repair_refuses_cross_era_walk_links():
    """A walk link may never join PRESENT to PAST (only the time door may)."""
    s0, s1 = _scr(0), _scr(1)
    chapter = _chapter(s0, s1)
    table = {0: {"right": [WALK, WALK]}, 1: {"left": [WALK, WALK]}}
    era = lambda c, i: (i == 1)  # screen 1 is PAST, screen 0 PRESENT  # noqa: E731
    report = repair_chapter(chapter, _edges_provider(table), era_of=era)

    assert s0.screen_index_right == NAV_BLOCKED
    assert 1 in report.unrepaired


# --- Increment 3: world-level wrapper ---------------------------------------

def test_world_wrapper_repairs_each_chapter():
    """`repair_reachability` runs the chapter pass over every chapter and aggregates."""
    s0, s1 = _scr(0), _scr(1)
    ch = Chapter(chapter_num=1)
    ch.add_screen(s0)
    ch.add_screen(s1)
    gw = GameWorld()
    gw.add_chapter(ch)
    table = {0: {"right": [WALK, WALK]}, 1: {"left": [WALK, WALK]}}

    report = repair_reachability(
        gw, rom_data=b"", era_of=_ALL_PRESENT,
        edges_provider_for=lambda chapter: _edges_provider(table),
    )

    assert report.chapters[1].reachable_after == {0, 1}
    assert s0.screen_index_right == 1
    assert report.total_records == 1
    assert report.total_unrepaired == 0
