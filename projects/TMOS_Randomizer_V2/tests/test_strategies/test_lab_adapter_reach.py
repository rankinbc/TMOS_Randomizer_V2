"""The Lab-adapter shippability gate must use ONE reachability definition.

Bug found 2026-06-15: the adapter's gate (`_reach_counts`) was a warp-blind directed
BFS that ignored stairways, while the oracle's own `analyze_reachability` follows them.
The gate was therefore STRICTER than the oracle it feeds, rejecting era-safe grow output
before the oracle could judge it. Unify on the stairway-aware definition (single source
of truth) so the gate credits the same warp traversal the real game uses.
"""

from __future__ import annotations

from tmos_randomizer.core.chapter import Chapter, GameWorld
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.core.enums import EventType, NAV_BLOCKED
from tmos_randomizer.strategies.lab_adapter import _reach_counts


def _screen(rel: int, **nav: int) -> WorldScreen:
    return WorldScreen(
        global_index=rel, chapter=1, relative_index=rel,
        screen_index_right=nav.get("right", NAV_BLOCKED),
        screen_index_left=nav.get("left", NAV_BLOCKED),
        screen_index_down=nav.get("down", NAV_BLOCKED),
        screen_index_up=nav.get("up", NAV_BLOCKED),
        event=nav.get("event", 0),
        content=nav.get("content", 0),
    )


def _world(*screens: WorldScreen) -> GameWorld:
    ch = Chapter(chapter_num=1)
    for s in screens:
        ch.add_screen(s)
    gw = GameWorld()
    gw.add_chapter(ch)
    return gw


def test_gate_counts_stairway_reachable_screens():
    """Screen 2 is reachable ONLY via a stairway from screen 1. The gate must count
    it (matching the oracle), not treat it as unreachable."""
    world = _world(
        _screen(0, right=1),                                  # walk 0->1
        _screen(1, event=EventType.STAIRWAY, content=2),       # stairway 1->2, no walk
        _screen(2),                                            # isolated by walking
    )
    counts = _reach_counts(world)
    assert counts[1] == 3, f"stairway dest must be counted reachable, got {counts}"


def test_gate_still_counts_plain_walkable_screens():
    """Sanity: ordinary directed walk reachability is unchanged."""
    world = _world(
        _screen(0, right=1),
        _screen(1, left=0),
    )
    assert _reach_counts(world)[1] == 2
