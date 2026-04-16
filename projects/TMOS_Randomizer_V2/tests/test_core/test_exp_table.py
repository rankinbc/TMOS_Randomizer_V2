"""Tests for core/exp_table.py — direct ROM read/write for the action-mode EXP tier table."""

from pathlib import Path

import pytest

from tmos_randomizer.core import exp_table
from tmos_randomizer.core.constants import EXP_TABLE_OFFSET


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


# Vanilla values from GameAnalysis2 raw_research/screen_exp_mapping.md (ROM_VERIFIED).
VANILLA_EXP_VALUES = [2, 5, 10, 20, 30, 40, 50, 4, 12, 1]


class TestReadExp:
    def test_table_size(self):
        assert exp_table.EXP_TABLE_COUNT == 10

    def test_offset_constant(self):
        assert EXP_TABLE_OFFSET == 0x174AA

    def test_full_table_matches_known_vanilla(self, vanilla_rom):
        entries = exp_table.read_exp_table(vanilla_rom)
        values = [e["value"] for e in entries]
        assert values == VANILLA_EXP_VALUES

    def test_entry_offsets_use_stride_2(self, vanilla_rom):
        for i, e in enumerate(exp_table.read_exp_table(vanilla_rom)):
            assert e["rom_offset"] == f"0x{EXP_TABLE_OFFSET + i * 2:05X}"

    def test_invalid_index_raises(self, vanilla_rom):
        with pytest.raises(ValueError, match="index must be 0..9"):
            exp_table.read_exp_entry(vanilla_rom, 10)
        with pytest.raises(ValueError, match="index must be 0..9"):
            exp_table.read_exp_entry(vanilla_rom, -1)


class TestWriteExp:
    def test_write_then_read_round_trip(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        exp_table.write_exp_entry(rom, 3, 99)
        assert exp_table.read_exp_entry(bytes(rom), 3)["value"] == 99
        # Other entries unchanged
        assert exp_table.read_exp_entry(bytes(rom), 0)["value"] == 2
        assert exp_table.read_exp_entry(bytes(rom), 6)["value"] == 50

    def test_only_writes_one_byte_at_stride_offset(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        exp_table.write_exp_entry(rom, 4, 0x77)
        # Byte at offset+4*2 = 0x77, intervening byte unchanged
        assert rom[EXP_TABLE_OFFSET + 4 * 2] == 0x77
        # Intervening byte at offset+4*2+1 should equal vanilla
        assert rom[EXP_TABLE_OFFSET + 4 * 2 + 1] == vanilla_rom[EXP_TABLE_OFFSET + 4 * 2 + 1]

    @pytest.mark.parametrize("value", [-1, 256, 1000])
    def test_value_bounds(self, vanilla_rom, value):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError, match="value must be 0..255"):
            exp_table.write_exp_entry(rom, 0, value)


class TestUsageMap:
    def test_all_indices_have_entries(self):
        for idx in range(10):
            assert idx in exp_table.EXP_USAGE
            assert isinstance(exp_table.EXP_USAGE[idx], list)

    def test_chapter_5_screen_0x13_uses_tier_9(self):
        # From screen_exp_mapping.md: Ch5 screen 0x13 has byte_1 low_bits=9 → 1 EXP
        idx_9 = exp_table.EXP_USAGE[9]
        assert any(u["chapter"] == 5 and u["screen_hex"] == "0x13" for u in idx_9)

    def test_labels_cover_all_indices(self):
        for idx in range(10):
            assert idx in exp_table.EXP_TIER_LABELS
            assert exp_table.EXP_TIER_LABELS[idx]
