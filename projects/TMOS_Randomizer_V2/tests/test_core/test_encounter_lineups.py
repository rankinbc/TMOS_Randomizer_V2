"""Tests for core/encounter_lineups.py — read/write per-chapter lineup tables."""

from pathlib import Path

import pytest

from tmos_randomizer.core import encounter_lineups as el
from tmos_randomizer.core.enemies import BATTLE_ENEMIES


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


class TestRead:
    def test_active_lineup_counts_per_chapter(self):
        assert el.LINEUP_COUNT == {1: 6, 2: 6, 3: 6, 4: 6, 5: 8}

    def test_chapter_1_lineup_0_matches_known_vanilla(self, vanilla_rom):
        # From encounter_tables.json: Ch1 lineup 0 has Pandarm + Corsa
        ch = el.read_chapter_lineups(vanilla_rom, 1)
        l0 = ch["lineups"][0]
        # The two non-empty slots
        non_empty = [s for s in l0["slots"] if not s["is_empty"]]
        ids = sorted(s["enemy_id"] for s in non_empty)
        assert ids == [0x0D, 0x1E]  # Pandarm, Corsa

    def test_chapter_5_has_8_lineups(self, vanilla_rom):
        ch = el.read_chapter_lineups(vanilla_rom, 5)
        assert ch["lineup_count"] == 8
        assert len(ch["lineups"]) == 8

    def test_total_hp_sums_known_enemies(self, vanilla_rom):
        # Ch1 lineup 0: Pandarm (HP 16) + Corsa (HP 16) = 32
        ch = el.read_chapter_lineups(vanilla_rom, 1)
        assert ch["lineups"][0]["total_hp"] == BATTLE_ENEMIES[0x0D]["hp"] + BATTLE_ENEMIES[0x1E]["hp"]

    def test_invalid_chapter_raises(self, vanilla_rom):
        with pytest.raises(ValueError, match="chapter must be 1..5"):
            el.read_chapter_lineups(vanilla_rom, 6)

    def test_read_all_lineups_returns_5_chapters(self, vanilla_rom):
        all_ch = el.read_all_lineups(vanilla_rom)
        assert len(all_ch) == 5
        assert [c["chapter"] for c in all_ch] == [1, 2, 3, 4, 5]


class TestWrite:
    def test_write_slot_round_trip(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        # Replace Ch1 lineup 0 slot 1 with Gigadan (0x13)
        result = el.write_lineup_slot(rom, 1, 0, 1, 0x13)
        assert result["enemy_id"] == 0x13
        assert result["enemy_name"] == "Gigadan"
        # Read back
        ch = el.read_chapter_lineups(bytes(rom), 1)
        assert ch["lineups"][0]["slots"][0]["enemy_id"] == 0x13

    def test_write_empty_slot(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        result = el.write_lineup_slot(rom, 1, 0, 1, 0xFF)
        assert result["is_empty"] is True

    def test_write_start_byte(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        el.write_lineup_start_byte(rom, 1, 0, 0x01)
        ch = el.read_chapter_lineups(bytes(rom), 1)
        assert ch["lineups"][0]["start_byte"] == 0x01

    def test_invalid_lineup_idx(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError, match="lineup_idx"):
            el.write_lineup_slot(rom, 1, 99, 1, 0x0D)

    def test_invalid_slot(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError, match="slot must be 1..7"):
            el.write_lineup_slot(rom, 1, 0, 0, 0x0D)
        with pytest.raises(ValueError, match="slot must be 1..7"):
            el.write_lineup_slot(rom, 1, 0, 8, 0x0D)

    def test_invalid_start_byte(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError, match="start_byte must be"):
            el.write_lineup_start_byte(rom, 1, 0, 0x05)

    def test_writing_one_slot_doesnt_affect_others(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        before = el.read_chapter_lineups(vanilla_rom, 1)["lineups"][0]
        el.write_lineup_slot(rom, 1, 0, 3, 0x13)
        after = el.read_chapter_lineups(bytes(rom), 1)["lineups"][0]
        # Slots 1, 2, 4-7 should be unchanged
        for s_idx in (0, 1, 3, 4, 5, 6):  # zero-indexed in slots list
            assert before["slots"][s_idx]["enemy_id"] == after["slots"][s_idx]["enemy_id"]
        # Slot 3 (1-indexed = slots[2]) should have changed
        assert after["slots"][2]["enemy_id"] == 0x13
