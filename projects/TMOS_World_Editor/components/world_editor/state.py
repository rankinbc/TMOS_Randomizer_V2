"""Session-state helpers for the world_editor dashboard.

All mutable world state lives in ``st.session_state``. Functions here accept
the session-state mapping directly so they can be unit-tested with a plain
dict stand-in (bypassing Streamlit's runtime).
"""
from __future__ import annotations

from pathlib import Path
from typing import MutableMapping

from src.tmos_world.model import World, WorldScreen
from src.tmos_world.rom import parse_rom


def load_world_if_needed(state: MutableMapping, rom_path: Path) -> World:
    """Return the cached World for this session, parsing the ROM on first call."""
    if state.get("world") is None:
        state["world"] = parse_rom(str(rom_path))
        state["rom_path"] = str(rom_path)
        state["dirty"] = False
    return state["world"]


def get_selected_screen(state: MutableMapping) -> tuple[int, int] | None:
    """Return (chapter_idx, screen_idx) or None if nothing is selected."""
    sel = state.get("selected_screen")
    if sel is None:
        return None
    return sel


def set_selected_screen(state: MutableMapping, chapter_idx: int, screen_idx: int) -> None:
    state["selected_screen"] = (chapter_idx, screen_idx)


def get_screen(state: MutableMapping, chapter_idx: int, screen_idx: int) -> WorldScreen:
    world: World = state["world"]
    return world.chapters[chapter_idx].screens[screen_idx]


def update_screen_field(
    state: MutableMapping, chapter_idx: int, screen_idx: int, field: str, value: int
) -> None:
    """Mutate a single byte field on the selected screen and mark state dirty."""
    screen = get_screen(state, chapter_idx, screen_idx)
    if not hasattr(screen, field):
        raise KeyError(f"Unknown WorldScreen field: {field}")
    if not (0 <= value <= 0xFF):
        raise ValueError(f"{field}={value} out of 0..255 range")
    setattr(screen, field, value)
    state["dirty"] = True


def mark_dirty(state: MutableMapping, dirty: bool = True) -> None:
    state["dirty"] = dirty
