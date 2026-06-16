"""Tests for the canonical selectable-enemy-IDs source."""
from tmos_randomizer.core.enemy_selection import selectable_enemy_ids
from tmos_randomizer.core.enums import CONSERVATIVE_DANGER_ENEMY_IDS


def test_selectable_excludes_all_danger_ids():
    entries = selectable_enemy_ids()
    ids = {e["enemy_id"] for e in entries}
    assert ids.isdisjoint(CONSERVATIVE_DANGER_ENEMY_IDS)
    assert ids  # non-empty
    assert all(e.get("name") for e in entries)
    assert all(e.get("enemy_id_hex") for e in entries)
