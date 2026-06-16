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
    """Current-tile edges provider (ignores top/bot) for open-in-place tests."""
    return lambda idx, top=0, bot=0: _FakeEdges(table.get(idx, {}))


def _tiled_edges_provider(table: dict[tuple, dict[str, list[int]]]):
    """Edges depend on (idx, top, bot) -- used to simulate a TileSection swap."""
    return lambda idx, top, bot: _FakeEdges(table.get((idx, top, bot), {}))


_ALL_PRESENT = lambda chapter_num, idx: False  # noqa: E731  (test era stub)


def _scr(rel: int, content: int = 0, event: int = 0, top: int = 0, bot: int = 0,
         datapointer: int = 0, **nav: int) -> WorldScreen:
    return WorldScreen(
        global_index=rel, chapter=1, relative_index=rel, content=content, event=event,
        top_tiles=top, bottom_tiles=bot, datapointer=datapointer,
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


# --- Increment 4: TS-swap-then-open -----------------------------------------

def test_ts_swap_makes_an_edge_alignable_then_opens():
    """Screen 1 has no aligned port natively, but a CHR-valid tile swap makes its left
    edge walkable -> repair swaps tiles then wires it (when open-in-place can't)."""
    s0 = _scr(0)            # reachable start; right port free
    s1 = _scr(1)            # unreachable; left edge not walkable at current tiles
    chapter = _chapter(s0, s1)
    tiled = _tiled_edges_provider({
        (0, 0, 0): {"right": [WALK, WALK]},
        (1, 0, 0): {"left": [BLOCK, BLOCK]},   # current tiles -> open-in-place fails
        (1, 9, 9): {"left": [WALK, WALK]},     # swapped tiles -> aligns with s0.right
    })
    report = repair_chapter(
        chapter, tiled,
        candidate_tiles_of=lambda idx: [(9, 9)] if idx == 1 else [],
        era_of=_ALL_PRESENT,
    )

    assert (s1.top_tiles, s1.bottom_tiles) == (9, 9)  # swap applied
    assert s0.screen_index_right == 1 and s1.screen_index_left == 0
    assert 1 in report.reachable_after
    assert report.records[0].action == "ts_swap_then_open"


def test_ts_swap_rejected_if_it_breaks_an_existing_link():
    """A swap that would align a new edge but break screen 1's existing walk link to
    screen 2 must be rejected (no fragmenting the screen's own component)."""
    s0 = _scr(0)
    s1 = _scr(1, right=2)   # existing walk link 1->2
    s2 = _scr(2, left=1)
    chapter = _chapter(s0, s1, s2)
    tiled = _tiled_edges_provider({
        (0, 0, 0): {"right": [WALK, WALK]},
        (1, 0, 0): {"left": [BLOCK, BLOCK], "right": [WALK, WALK]},  # right aligns w/ s2
        (1, 9, 9): {"left": [WALK, WALK], "right": [BLOCK, BLOCK]},  # left aligns but breaks s2
        (2, 0, 0): {"left": [WALK, WALK]},
    })
    report = repair_chapter(
        chapter, tiled,
        candidate_tiles_of=lambda idx: [(9, 9)] if idx == 1 else [],
        era_of=_ALL_PRESENT,
    )

    assert (s1.top_tiles, s1.bottom_tiles) == (0, 0)  # swap NOT applied
    assert 1 in report.unrepaired
