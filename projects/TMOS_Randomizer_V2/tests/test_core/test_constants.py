"""Tests for core/constants.py"""

import pytest

from tmos_randomizer.core.constants import (
    CHAPTER_OFFSETS,
    CHAPTER_BASES,
    WORLDSCREEN_SIZE,
    TOTAL_SCREENS,
    relative_to_global,
    global_to_relative,
    get_worldscreen_address,
    get_chr_index,
    get_all_valid_datapointers,
)


class TestChapterOffsets:
    """Test chapter offset constants and functions."""

    def test_total_screens_count(self):
        """Total screens should be 739."""
        assert TOTAL_SCREENS == 739

    def test_chapter_counts_sum_to_total(self):
        """Sum of all chapter counts should equal total."""
        total = sum(count for _, count in CHAPTER_OFFSETS.values())
        assert total == TOTAL_SCREENS

    def test_chapter_offsets_are_contiguous(self):
        """Chapter offsets should be contiguous (no gaps)."""
        expected_start = 0
        for chapter in range(1, 6):
            start, count = CHAPTER_OFFSETS[chapter]
            assert start == expected_start, f"Chapter {chapter} should start at {expected_start}"
            expected_start = start + count


class TestRelativeToGlobal:
    """Test relative_to_global conversion."""

    def test_chapter1_start(self):
        """Chapter 1 screen 0 should be global 0."""
        assert relative_to_global(1, 0) == 0

    def test_chapter1_last(self):
        """Chapter 1 last screen should be global 130."""
        assert relative_to_global(1, 130) == 130

    def test_chapter2_start(self):
        """Chapter 2 screen 0 should be global 131."""
        assert relative_to_global(2, 0) == 131

    def test_chapter5_last(self):
        """Chapter 5 last screen should be global 738."""
        assert relative_to_global(5, 153) == 738

    def test_invalid_chapter(self):
        """Invalid chapter should raise ValueError."""
        with pytest.raises(ValueError, match="Invalid chapter"):
            relative_to_global(0, 0)
        with pytest.raises(ValueError, match="Invalid chapter"):
            relative_to_global(6, 0)

    def test_index_out_of_range(self):
        """Index beyond chapter count should raise ValueError."""
        with pytest.raises(ValueError, match="out of range"):
            relative_to_global(1, 131)  # Chapter 1 only has 131 screens (0-130)


class TestGlobalToRelative:
    """Test global_to_relative conversion."""

    def test_global_0(self):
        """Global 0 should be chapter 1, relative 0."""
        assert global_to_relative(0) == (1, 0)

    def test_global_130(self):
        """Global 130 should be chapter 1, relative 130."""
        assert global_to_relative(130) == (1, 130)

    def test_global_131(self):
        """Global 131 should be chapter 2, relative 0."""
        assert global_to_relative(131) == (2, 0)

    def test_global_738(self):
        """Global 738 should be chapter 5, relative 153."""
        assert global_to_relative(738) == (5, 153)

    def test_invalid_global(self):
        """Invalid global index should raise ValueError."""
        with pytest.raises(ValueError, match="Invalid global index"):
            global_to_relative(739)
        with pytest.raises(ValueError, match="Invalid global index"):
            global_to_relative(-1)

    def test_roundtrip(self):
        """Converting global→relative→global should return same value."""
        for global_idx in [0, 50, 131, 300, 500, 738]:
            chapter, relative = global_to_relative(global_idx)
            assert relative_to_global(chapter, relative) == global_idx


class TestGetWorldscreenAddress:
    """Test ROM address calculation."""

    def test_chapter1_screen0(self):
        """Chapter 1 screen 0 should be at base address."""
        assert get_worldscreen_address(1, 0) == CHAPTER_BASES[1]

    def test_chapter1_screen1(self):
        """Chapter 1 screen 1 should be 16 bytes after screen 0."""
        addr0 = get_worldscreen_address(1, 0)
        addr1 = get_worldscreen_address(1, 1)
        assert addr1 == addr0 + WORLDSCREEN_SIZE

    def test_chapter2_screen0(self):
        """Chapter 2 screen 0 should be at chapter 2 base."""
        assert get_worldscreen_address(2, 0) == CHAPTER_BASES[2]

    def test_invalid_chapter(self):
        """Invalid chapter should raise ValueError."""
        with pytest.raises(ValueError):
            get_worldscreen_address(0, 0)

    def test_index_out_of_range(self):
        """Index beyond chapter should raise ValueError."""
        with pytest.raises(ValueError, match="out of range"):
            get_worldscreen_address(1, 200)


class TestChrFunctions:
    """Test CHR bank helper functions."""

    def test_get_chr_index_low_bits(self):
        """CHR index should be lower 6 bits only."""
        assert get_chr_index(0x0F) == 0x0F
        assert get_chr_index(0x4F) == 0x0F
        assert get_chr_index(0x8F) == 0x0F
        assert get_chr_index(0xCF) == 0x0F

    def test_get_chr_index_various(self):
        """Test various CHR index extractions."""
        assert get_chr_index(0x13) == 0x13
        assert get_chr_index(0x16) == 0x16
        assert get_chr_index(0x00) == 0x00
        assert get_chr_index(0x3F) == 0x3F

    def test_get_all_valid_datapointers(self):
        """Should return 4 valid DataPointers for any CHR index."""
        result = get_all_valid_datapointers(0x0F)
        assert result == [0x0F, 0x4F, 0x8F, 0xCF]

    def test_get_all_valid_datapointers_zero(self):
        """CHR index 0 should give [0x00, 0x40, 0x80, 0xC0]."""
        result = get_all_valid_datapointers(0x00)
        assert result == [0x00, 0x40, 0x80, 0xC0]

    def test_datapointers_share_chr_index(self):
        """All returned DataPointers should have same CHR index."""
        for chr_idx in [0x0F, 0x13, 0x16, 0x17]:
            datapointers = get_all_valid_datapointers(chr_idx)
            for dp in datapointers:
                assert get_chr_index(dp) == chr_idx
