"""Tests for tile-section byte/bank/DataPointer math.

The authoritative bank model is the renderer's value-range get_bank_offset:
  < 0x40 -> (0,0); 0x40-0x8E -> (0,1); 0x8F-0x9F -> (1,0); >= 0xC0 -> (1,1)
"""
import pytest
from tmos_randomizer.rendering.screen_renderer import get_bank_offset
from tmos_randomizer.logic.tilesection_bank import (
    decompose_section_index,
    compute_datapointer,
    resolve_tile_update,
)


class TestDecompose:
    def test_bank0_section(self):
        assert decompose_section_index(0) == (0, 0)
        assert decompose_section_index(189) == (189, 0)
        assert decompose_section_index(255) == (255, 0)

    def test_bank1_section(self):
        assert decompose_section_index(256) == (0, 1)
        assert decompose_section_index(300) == (44, 1)
        assert decompose_section_index(470) == (214, 1)

    def test_out_of_range_raises(self):
        with pytest.raises(ValueError):
            decompose_section_index(-1)
        with pytest.raises(ValueError):
            decompose_section_index(471)


class TestComputeDatapointer:
    def test_combo_0_0_preserves_chr(self):
        dp, chr_used = compute_datapointer(0, 0, 0x0F)
        assert chr_used == 0x0F
        assert get_bank_offset(dp) == (0, 0)
        assert dp & 0x3F == 0x0F

    def test_combo_0_1_preserves_chr(self):
        dp, chr_used = compute_datapointer(0, 1, 0x0F)
        assert chr_used == 0x0F
        assert get_bank_offset(dp) == (0, 256)
        assert dp & 0x3F == 0x0F

    def test_combo_1_1_preserves_chr(self):
        dp, chr_used = compute_datapointer(1, 1, 0x3F)
        assert chr_used == 0x3F
        assert get_bank_offset(dp) == (256, 256)
        assert dp & 0x3F == 0x3F

    def test_combo_1_0_clamps_chr_into_window(self):
        # (1,0) only exists for dp 0x8F-0x9F => chr 0x0F-0x1F
        dp, chr_used = compute_datapointer(1, 0, 0x00)
        assert get_bank_offset(dp) == (256, 0)
        assert 0x0F <= chr_used <= 0x1F

    def test_combo_1_0_keeps_chr_already_in_window(self):
        dp, chr_used = compute_datapointer(1, 0, 0x12)
        assert chr_used == 0x12
        assert get_bank_offset(dp) == (256, 0)


class TestResolveTileUpdate:
    def test_top_within_same_bank_no_dp_change(self):
        # current dp 0x0F => (top0, bottom0), chr 0x0F. New top section 100 (bank 0).
        r = resolve_tile_update(current_datapointer=0x0F, top_index=100, bottom_index=None)
        assert r["top_tiles"] == 100
        assert r["bottom_tiles"] is None
        assert r["datapointer"] == 0x0F
        assert r["datapointer_changed"] is False
        assert r["chr_changed"] is False

    def test_top_cross_bank_changes_dp(self):
        # current dp 0x0F => banks (0,0). New top section 300 => bank 1, byte 44.
        # Need (top1, bottom0) => combo (1,0) => chr clamps to 0x0F-0x1F.
        r = resolve_tile_update(current_datapointer=0x0F, top_index=300, bottom_index=None)
        assert r["top_tiles"] == 44
        assert get_bank_offset(r["datapointer"]) == (256, 0)
        assert r["datapointer_changed"] is True

    def test_both_halves(self):
        # New top 256 (bank1), new bottom 257 (bank1) => combo (1,1).
        r = resolve_tile_update(current_datapointer=0x0F, top_index=256, bottom_index=257)
        assert r["top_tiles"] == 0
        assert r["bottom_tiles"] == 1
        assert get_bank_offset(r["datapointer"]) == (256, 256)
