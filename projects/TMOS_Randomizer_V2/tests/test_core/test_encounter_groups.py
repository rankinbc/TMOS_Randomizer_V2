"""Tests for core/encounter_groups.py — read/write per-chapter encounter group tables."""

from pathlib import Path

import pytest

from tmos_randomizer.core import encounter_groups as eg


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


class TestRead:
    def test_entry_counts_per_chapter(self):
        assert eg.GROUP_COUNT == {1: 15, 2: 16, 3: 17, 4: 22, 5: 19}

    def test_chapter_1_entry_0_matches_known_vanilla(self, vanilla_rom):
        # From screen_exp_mapping.md: Ch1 entry 0 = screen 27 (0x1B), monster_grp 0x01, flag 0x00
        ch = eg.read_chapter_groups(vanilla_rom, 1)
        e0 = ch["entries"][0]
        assert e0["screen"] == 0x1B
        assert e0["monster_group"] == 0x01
        assert e0["flag"] == 0x00

    def test_high_bit_decoded_in_ch3(self, vanilla_rom):
        # Ch3 entry 7 has monster_group = 0x88 (high bit + 8)
        ch = eg.read_chapter_groups(vanilla_rom, 3)
        e7 = ch["entries"][7]
        assert e7["monster_group"] == 0x88
        assert e7["monster_group_low"] == 0x08
        assert e7["monster_group_hi_bit"] == 1

    def test_invalid_chapter(self, vanilla_rom):
        with pytest.raises(ValueError, match="chapter must be 1..5"):
            eg.read_chapter_groups(vanilla_rom, 7)

    def test_read_all_groups_returns_5(self, vanilla_rom):
        all_ch = eg.read_all_groups(vanilla_rom)
        assert len(all_ch) == 5
        # Total entry count across chapters
        assert sum(c["entry_count"] for c in all_ch) == 15 + 16 + 17 + 22 + 19


class TestWrite:
    def test_write_flag_only_preserves_other_bytes(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        before = eg.read_chapter_groups(vanilla_rom, 1)["entries"][0]
        result = eg.write_group_entry(rom, 1, 0, flag=3)
        assert result["flag"] == 3
        assert result["screen"] == before["screen"]
        assert result["monster_group"] == before["monster_group"]

    def test_write_monster_group_only(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        result = eg.write_group_entry(rom, 1, 0, monster_group=0x86)
        assert result["monster_group"] == 0x86
        assert result["monster_group_hi_bit"] == 1
        assert result["monster_group_low"] == 0x06

    def test_write_screen_only(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        result = eg.write_group_entry(rom, 1, 0, screen=0x55)
        assert result["screen"] == 0x55
        assert result["screen_hex"] == "0x55"

    @pytest.mark.parametrize("field,value", [
        ("screen", -1), ("screen", 256),
        ("monster_group", -1), ("monster_group", 256),
        ("flag", -1), ("flag", 256),
    ])
    def test_bounds_validation(self, vanilla_rom, field, value):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError):
            eg.write_group_entry(rom, 1, 0, **{field: value})

    def test_invalid_entry_index(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError, match="entry_index"):
            eg.write_group_entry(rom, 1, 99, flag=1)
