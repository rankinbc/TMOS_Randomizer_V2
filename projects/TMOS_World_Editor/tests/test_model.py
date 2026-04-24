"""Model invariants: WorldScreen round-trip, simplified ceiling."""
from __future__ import annotations

from src.tmos_world.model import WORLDSCREEN_FIELD_NAMES, WorldScreen


def test_worldscreen_field_list_matches_spec():
    # Spec §12 surface. If this changes, /knowledge/reference/world-editor-spec.md §12 changes too.
    assert WORLDSCREEN_FIELD_NAMES == (
        "parent_world",
        "ambient_sound",
        "content",
        "objectset",
        "nav_right",
        "nav_left",
        "nav_down",
        "nav_up",
        "datapointer",
        "exit_position",
        "top_tiles",
        "bottom_tiles",
        "worldscreen_color",
        "sprites_color",
        "unknown",
        "event",
    )


def test_from_bytes_to_bytes_round_trip():
    raw = bytes(range(16))
    ws = WorldScreen.from_bytes(raw)
    assert ws.to_bytes() == raw


def test_no_enemy_or_boss_fields():
    # Guard against model creep.
    forbidden = {"enemy", "item", "boss", "hp", "stat", "exp"}
    names = set(WORLDSCREEN_FIELD_NAMES)
    for tag in forbidden:
        assert not any(tag in name for name in names), f"model creep: {tag} field present"
