"""
Tests for the screen rendering module.

Verifies:
- Bank selection logic (DataPointer bits 7-6)
- TileSection address calculation
- Screen grid composition (8x7)
"""

import pytest
from tmos_randomizer.rendering.screen_renderer import (
    get_bank_offset,
    get_tilesection_grid,
    build_screen_tile_grid,
    read_tilesection,
    TILESECTION_BASE,
    TILESECTION_OFFSET,
    SCREEN_WIDTH_TILES,
    SCREEN_HEIGHT_TILES,
)


class TestBankOffset:
    """Tests for bank selection from DataPointer bits."""

    def test_both_bank1_range_00_to_3f(self):
        """DataPointer 0x00-0x3F (00xxxxxx): both banks are Bank 1."""
        # Bit 7=0, Bit 6=0
        assert get_bank_offset(0x00) == (0, 0)
        assert get_bank_offset(0x01) == (0, 0)
        assert get_bank_offset(0x0F) == (0, 0)  # Common overworld value
        assert get_bank_offset(0x3F) == (0, 0)

    def test_top_bank1_bottom_bank2_range_40_to_7f(self):
        """DataPointer 0x40-0x7F (01xxxxxx): top Bank 1, bottom Bank 2."""
        # Bit 7=0, Bit 6=1
        assert get_bank_offset(0x40) == (0, 256)
        assert get_bank_offset(0x4F) == (0, 256)
        assert get_bank_offset(0x7F) == (0, 256)

    def test_top_bank2_bottom_bank1_range_80_to_bf(self):
        """DataPointer 0x80-0xBF (10xxxxxx): top Bank 2, bottom Bank 1."""
        # Bit 7=1, Bit 6=0
        assert get_bank_offset(0x80) == (256, 0)
        assert get_bank_offset(0x91) == (256, 0)  # Town variant
        assert get_bank_offset(0xBF) == (256, 0)

    def test_both_bank2_range_c0_to_ff(self):
        """DataPointer 0xC0-0xFF (11xxxxxx): both banks are Bank 2."""
        # Bit 7=1, Bit 6=1
        assert get_bank_offset(0xC0) == (256, 256)
        assert get_bank_offset(0xD1) == (256, 256)  # Title/special
        assert get_bank_offset(0xD3) == (256, 256)  # Town interiors
        assert get_bank_offset(0xFF) == (256, 256)

    def test_bit_extraction_accuracy(self):
        """Verify bit extraction is correct for edge cases."""
        # Test specific bit patterns
        # 0b01000000 = 0x40: bit 7=0, bit 6=1
        assert get_bank_offset(0b01000000) == (0, 256)

        # 0b10000000 = 0x80: bit 7=1, bit 6=0
        assert get_bank_offset(0b10000000) == (256, 0)

        # 0b11000000 = 0xC0: bit 7=1, bit 6=1
        assert get_bank_offset(0b11000000) == (256, 256)

        # 0b00111111 = 0x3F: bit 7=0, bit 6=0 (bits 0-5 = 0x3F)
        assert get_bank_offset(0b00111111) == (0, 0)


class TestTileSectionGrid:
    """Tests for converting TileSection bytes to grid."""

    def test_basic_grid_conversion(self):
        """TileSection should convert to 8x4 grid."""
        # Create 32-byte test data (sequential values)
        data = bytes(range(32))
        grid = get_tilesection_grid(data)

        # Should be 4 rows
        assert len(grid) == 4

        # Each row should have 8 tiles
        for row in grid:
            assert len(row) == 8

        # Verify values match expected layout
        assert grid[0] == [0, 1, 2, 3, 4, 5, 6, 7]
        assert grid[1] == [8, 9, 10, 11, 12, 13, 14, 15]
        assert grid[2] == [16, 17, 18, 19, 20, 21, 22, 23]
        assert grid[3] == [24, 25, 26, 27, 28, 29, 30, 31]

    def test_grid_handles_short_data(self):
        """Grid should handle data shorter than 32 bytes."""
        data = bytes([1, 2, 3, 4, 5, 6, 7, 8])  # Only 8 bytes
        grid = get_tilesection_grid(data)

        assert len(grid) == 4
        assert grid[0] == [1, 2, 3, 4, 5, 6, 7, 8]
        # Remaining rows should be filled with 0
        assert grid[1] == [0, 0, 0, 0, 0, 0, 0, 0]


class TestScreenGrid:
    """Tests for full screen grid composition."""

    def test_screen_dimensions(self):
        """Screen should be 8 tiles wide x 6 tiles tall."""
        assert SCREEN_WIDTH_TILES == 8
        assert SCREEN_HEIGHT_TILES == 6

    def test_screen_grid_composition(self):
        """Screen grid should combine top (4 rows) + bottom (2 rows)."""
        # Create mock ROM data with recognizable patterns
        # Use indices 0 and 100 to avoid TileSection overlap (each section is 32 bytes
        # but stored with 8-byte offsets, so adjacent indices share 24 bytes)
        top_idx = 0
        bottom_idx = 100  # Far enough apart to not overlap

        rom_size = TILESECTION_BASE + (bottom_idx + 5) * TILESECTION_OFFSET + 32
        rom_data = bytearray(rom_size)

        # Fill TileSection at index 0 with 0x10-0x2F (top tiles for test)
        ts0_addr = TILESECTION_BASE + (top_idx * TILESECTION_OFFSET)
        for i in range(32):
            rom_data[ts0_addr + i] = 0x10 + i

        # Fill TileSection at index 100 with 0x50-0x6F (bottom tiles for test)
        ts100_addr = TILESECTION_BASE + (bottom_idx * TILESECTION_OFFSET)
        for i in range(32):
            rom_data[ts100_addr + i] = 0x50 + i

        # Build screen grid with DataPointer=0x00 (both banks at 0)
        grid = build_screen_tile_grid(
            bytes(rom_data),
            top_tiles=top_idx,
            bottom_tiles=bottom_idx,
            datapointer=0x00
        )

        # Should be 6 rows (4 top + 2 bottom)
        assert len(grid) == 6

        # Each row should have 8 tiles
        for row in grid:
            assert len(row) == 8

        # First 4 rows from top TileSection
        assert grid[0][0] == 0x10  # First tile of top section
        assert grid[3][7] == 0x10 + 31  # Last tile of top section row 3

        # Last 2 rows from bottom TileSection (rows 0-1, rows 2-3 excluded)
        assert grid[4][0] == 0x50  # First tile of bottom section
        assert grid[5][7] == 0x50 + 15  # Last tile of bottom section row 1

    def test_bank_offset_applied(self):
        """Verify bank offset is correctly applied to tile indices."""
        rom_size = TILESECTION_BASE + 512 * TILESECTION_OFFSET + 32
        rom_data = bytearray(rom_size)

        # Fill TileSection 256 (Bank 2) with pattern 0xAA
        ts256_addr = TILESECTION_BASE + (256 * TILESECTION_OFFSET)
        for i in range(32):
            rom_data[ts256_addr + i] = 0xAA

        # Fill TileSection 257 with pattern 0xBB
        ts257_addr = TILESECTION_BASE + (257 * TILESECTION_OFFSET)
        for i in range(32):
            rom_data[ts257_addr + i] = 0xBB

        # DataPointer 0xC0 = both Bank 2 (offset 256)
        # So top_tiles=0 becomes 0+256=256, bottom_tiles=1 becomes 1+256=257
        grid = build_screen_tile_grid(
            bytes(rom_data),
            top_tiles=0,
            bottom_tiles=1,
            datapointer=0xC0
        )

        # Top rows should have 0xAA pattern
        assert grid[0][0] == 0xAA

        # Bottom rows should have 0xBB pattern
        assert grid[4][0] == 0xBB


class TestTileSectionAddressing:
    """Tests for TileSection ROM address calculation."""

    def test_tilesection_base_address(self):
        """Verify correct base address for TileSection data."""
        assert TILESECTION_BASE == 0x03C4C7

    def test_tilesection_offset(self):
        """Verify TileSection offset is 8 bytes (overlapping storage)."""
        assert TILESECTION_OFFSET == 8

    def test_address_calculation(self):
        """Verify address calculation for various indices."""
        # Index 0 should be at base
        assert TILESECTION_BASE + (0 * TILESECTION_OFFSET) == 0x03C4C7

        # Index 1 should be 8 bytes later
        assert TILESECTION_BASE + (1 * TILESECTION_OFFSET) == 0x03C4C7 + 8

        # Index 256 (Bank 2 start) should be 2048 bytes later
        assert TILESECTION_BASE + (256 * TILESECTION_OFFSET) == 0x03C4C7 + 2048


class TestCommonDataPointerValues:
    """Tests for common DataPointer values found in the game."""

    def test_overworld_dungeon_0x0f(self):
        """DataPointer 0x0F (overworld/dungeon): both Bank 1, CHR 0x0F."""
        top, bottom = get_bank_offset(0x0F)
        assert top == 0
        assert bottom == 0

    def test_town_0x91(self):
        """DataPointer 0x91 (some towns): top Bank 2, bottom Bank 1."""
        top, bottom = get_bank_offset(0x91)
        assert top == 256
        assert bottom == 0

    def test_title_special_0xd1(self):
        """DataPointer 0xD1 (title/special): both Bank 2."""
        top, bottom = get_bank_offset(0xD1)
        assert top == 256
        assert bottom == 256

    def test_town_interiors_0xd3(self):
        """DataPointer 0xD3 (town interiors): both Bank 2."""
        top, bottom = get_bank_offset(0xD3)
        assert top == 256
        assert bottom == 256


# Integration tests (require actual ROM data)
class TestScreenRendererIntegration:
    """Integration tests requiring actual tile images."""

    @pytest.mark.skip(reason="Requires actual tile images")
    def test_render_screen_produces_correct_size(self):
        """Rendered image should be correct pixel dimensions."""
        pass

    @pytest.mark.skip(reason="Requires actual tile images")
    def test_render_screen_scaling(self):
        """Scaled images should be correct dimensions."""
        pass
