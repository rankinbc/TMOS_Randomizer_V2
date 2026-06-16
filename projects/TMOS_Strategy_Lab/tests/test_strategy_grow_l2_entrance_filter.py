"""L2 placement filter — forbid grid adjacencies across a stock building entrance.

Root cause (RESULTS.md): navwrite preserves stock 0xFE building-entrance bytes, so
when growth places a grid neighbor across a 0xFE edge the result is a ONE-WAY
adjacency (neighbor points back, the 0xFE cell can't step forward) that tanks directed
reachability. Safe-first fix (v0.4.0): never CREATE such an adjacency during growth —
treat a 0xFE-facing edge as non-growable. Building entrances are preserved untouched.

Unit-tests the placement predicate `_entrance_blocks_adjacency` in isolation with
duck-typed screens (no ROM needed).
"""

from __future__ import annotations

from types import SimpleNamespace

from tmos_strategy_lab.strategies.grow.impl import (
    _entrance_blocks_adjacency,
    NAV_BUILDING_ENTRANCE,
)

WALK = 0x05  # any ordinary screen-index nav byte (walkable link)


def _scr(right=WALK, left=WALK, down=WALK, up=WALK):
    return SimpleNamespace(
        screen_index_right=right, screen_index_left=left,
        screen_index_down=down, screen_index_up=up,
    )


def _chapter(*screens):
    return SimpleNamespace(screens=list(screens))


def test_blocked_when_candidate_edge_toward_neighbor_is_entrance():
    # neighbor (idx 1) placed at (0,0); candidate (idx 2) would go at (1,0) -> its
    # LEFT faces the neighbor. Candidate's left edge is a building entrance.
    neighbor = _scr()
    cand = _scr(left=NAV_BUILDING_ENTRANCE)
    chapter = _chapter(_scr(), neighbor, cand)
    assert _entrance_blocks_adjacency(2, (1, 0), {(0, 0): 1}, chapter) is True


def test_blocked_when_neighbor_edge_toward_candidate_is_entrance():
    # The neighbor's RIGHT (facing the candidate) is the building entrance.
    neighbor = _scr(right=NAV_BUILDING_ENTRANCE)
    cand = _scr()
    chapter = _chapter(_scr(), neighbor, cand)
    assert _entrance_blocks_adjacency(2, (1, 0), {(0, 0): 1}, chapter) is True


def test_not_blocked_when_neither_edge_is_entrance():
    chapter = _chapter(_scr(), _scr(), _scr())
    assert _entrance_blocks_adjacency(2, (1, 0), {(0, 0): 1}, chapter) is False


def test_not_blocked_when_no_placed_neighbor():
    chapter = _chapter(_scr(), _scr(), _scr())
    assert _entrance_blocks_adjacency(2, (5, 5), {(0, 0): 1}, chapter) is False
