"""Tests for core/mp_table.py — MaxMP-per-level table at 0x1F68E (Bank 6 $F67E).

Vanilla values + layout from GameAnalysis2
game_specs/systems/progression/stat_growth.md [ROM_VERIFIED 2026-03-31].
"""

from pathlib import Path

import pytest

from tmos_randomizer.core import mp_table as mp


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


# Full ROM_VERIFIED vanilla sequence (levels 1..25), from stat_growth.md.
VANILLA_MP_VALUES = [
    16, 20, 52, 68, 78, 84, 94, 100, 108, 115, 148, 155, 165,
    180, 185, 190, 200, 204, 208, 218, 220, 228, 236, 245, 255,
]


class TestReadMp:
    def test_table_size_and_offset(self):
        assert mp.LEVEL_COUNT == 25
        assert mp.MP_TABLE_OFFSET == 0x1F68E
        assert mp.MP_TABLE_STRIDE == 1

    def test_read_all_returns_25_levels(self, vanilla_rom):
        entries = mp.read_mp_table(vanilla_rom)
        assert len(entries) == 25
        assert entries[0]["level"] == 1
        assert entries[-1]["level"] == 25

    def test_full_table_matches_known_vanilla(self, vanilla_rom):
        values = [e["value"] for e in mp.read_mp_table(vanilla_rom)]
        assert values == VANILLA_MP_VALUES

    def test_confirmed_anchor_values(self, vanilla_rom):
        # ROM_VERIFIED anchors: L1=16 (start), L2=20, L25=255 (byte cap).
        assert mp.read_mp_entry(vanilla_rom, 1)["value"] == 16
        assert mp.read_mp_entry(vanilla_rom, 2)["value"] == 20
        assert mp.read_mp_entry(vanilla_rom, 25)["value"] == 255

    def test_entry_offsets_use_stride_1(self, vanilla_rom):
        for i, e in enumerate(mp.read_mp_table(vanilla_rom)):
            assert e["rom_offset"] == f"0x{mp.MP_TABLE_OFFSET + i:05X}"

    @pytest.mark.parametrize("bad_level", [0, 26, -1, 100])
    def test_invalid_level_raises(self, vanilla_rom, bad_level):
        with pytest.raises(ValueError, match="level must be 1..25"):
            mp.read_mp_entry(vanilla_rom, bad_level)


class TestWriteMp:
    def test_write_then_read_round_trip(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        mp.write_mp_entry(rom, 5, 99)
        assert mp.read_mp_entry(bytes(rom), 5)["value"] == 99
        # Neighbors unchanged
        assert mp.read_mp_entry(bytes(rom), 4)["value"] == 68
        assert mp.read_mp_entry(bytes(rom), 6)["value"] == 84

    def test_only_writes_one_byte(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        mp.write_mp_entry(rom, 10, 0x77)
        assert rom[mp.MP_TABLE_OFFSET + 9] == 0x77
        # Adjacent bytes equal vanilla
        assert rom[mp.MP_TABLE_OFFSET + 8] == vanilla_rom[mp.MP_TABLE_OFFSET + 8]
        assert rom[mp.MP_TABLE_OFFSET + 10] == vanilla_rom[mp.MP_TABLE_OFFSET + 10]

    @pytest.mark.parametrize("bad_level", [0, 26, -1])
    def test_invalid_level_raises(self, vanilla_rom, bad_level):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError, match="level must be 1..25"):
            mp.write_mp_entry(rom, bad_level, 50)

    @pytest.mark.parametrize("value", [-1, 256, 1000])
    def test_value_bounds(self, vanilla_rom, value):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError, match="value must be 0..255"):
            mp.write_mp_entry(rom, 1, value)
