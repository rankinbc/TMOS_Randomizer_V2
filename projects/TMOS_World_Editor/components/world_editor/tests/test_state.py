"""world_editor.state tests — exercised with a plain dict as session_state."""
from __future__ import annotations

import pytest

from components.world_editor import state
from tests.fixtures import make_screen, make_single_chapter_world


def test_get_selected_screen_none_when_unset():
    assert state.get_selected_screen({}) is None


def test_set_and_get_selected_screen():
    store: dict = {}
    state.set_selected_screen(store, 2, 17)
    assert state.get_selected_screen(store) == (2, 17)


def test_update_screen_field_mutates_world_and_marks_dirty():
    world = make_single_chapter_world([make_screen(nav_right=5)])
    store = {"world": world, "dirty": False}
    state.update_screen_field(store, 0, 0, "nav_right", 7)
    assert world.chapters[0].screens[0].nav_right == 7
    assert store["dirty"] is True


def test_update_screen_field_validates_range():
    world = make_single_chapter_world([make_screen()])
    store = {"world": world}
    with pytest.raises(ValueError):
        state.update_screen_field(store, 0, 0, "nav_right", 300)
    with pytest.raises(KeyError):
        state.update_screen_field(store, 0, 0, "no_such_field", 0)
