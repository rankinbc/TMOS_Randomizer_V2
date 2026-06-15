"""Tests for the grow grid -> navigation writer (strategies/grow_nav.py).

Grow produces a per-section grid {(x,y): screen_index} where every grid-adjacency
is edge-valid by construction. This writer turns that grid into WorldScreen nav
bytes. Because grow guarantees aligned walkable edges between grid neighbors, the
nav it writes is physically valid by construction.
"""

from types import SimpleNamespace

from tmos_randomizer.strategies.grow_nav import apply_grid_navigation

NAV_BLOCKED = 0xFF
NAV_BUILDING_ENTRANCE = 0xFE


def _screen(idx):
    return SimpleNamespace(
        relative_index=idx,
        screen_index_right=0,
        screen_index_left=0,
        screen_index_up=0,
        screen_index_down=0,
    )


def test_horizontal_neighbors_wired_bidirectionally():
    """Two screens side by side connect to each other; their other edges block."""
    screens = {5: _screen(5), 8: _screen(8)}
    grid = {(0, 0): 5, (1, 0): 8}  # 5 is left of 8

    apply_grid_navigation(screens, grid)

    assert screens[5].screen_index_right == 8
    assert screens[8].screen_index_left == 5
    # No grid neighbor in the other directions -> blocked.
    assert screens[5].screen_index_left == NAV_BLOCKED
    assert screens[5].screen_index_up == NAV_BLOCKED
    assert screens[8].screen_index_right == NAV_BLOCKED


def test_isolated_cell_blocks_all_edges():
    """A single-cell section has no neighbors, so every edge is blocked."""
    screens = {3: _screen(3)}
    grid = {(0, 0): 3}

    apply_grid_navigation(screens, grid)

    s = screens[3]
    assert s.screen_index_right == NAV_BLOCKED
    assert s.screen_index_left == NAV_BLOCKED
    assert s.screen_index_up == NAV_BLOCKED
    assert s.screen_index_down == NAV_BLOCKED


def test_building_entrance_is_preserved():
    """An existing 0xFE building-entrance edge must not be overwritten with 0xFF."""
    s = _screen(7)
    s.screen_index_down = NAV_BUILDING_ENTRANCE
    screens = {7: s}
    grid = {(0, 0): 7}  # no down-neighbor

    apply_grid_navigation(screens, grid)

    assert screens[7].screen_index_down == NAV_BUILDING_ENTRANCE
