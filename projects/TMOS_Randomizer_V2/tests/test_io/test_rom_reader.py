"""Tests for io/rom_reader.py

Note: Full integration tests require a real TMOS ROM file.
These tests verify error handling and basic functionality with mock data.
"""

import pytest
from pathlib import Path
from unittest.mock import patch, mock_open

from tmos_randomizer.io.rom_reader import ROMReader, load_rom, load_chapter


class TestROMReaderValidation:
    """Test ROM validation logic."""

    def test_file_not_found(self, tmp_path):
        """Non-existent file should raise FileNotFoundError."""
        reader = ROMReader(tmp_path / "nonexistent.nes")
        with pytest.raises(FileNotFoundError):
            _ = reader.data

    def test_invalid_ines_header(self, tmp_path):
        """Invalid iNES header should raise ValueError."""
        rom_path = tmp_path / "bad.nes"
        rom_path.write_bytes(b"BADHEADER" + bytes(300000))

        reader = ROMReader(rom_path)
        with pytest.raises(ValueError, match="Invalid NES ROM"):
            _ = reader.data

    def test_valid_ines_header(self, tmp_path):
        """Valid iNES header should pass validation."""
        # Minimal valid header + enough data
        header = b"NES\x1a" + bytes(12)  # iNES header
        data = header + bytes(262144)  # Pad to expected size

        rom_path = tmp_path / "valid.nes"
        rom_path.write_bytes(data)

        reader = ROMReader(rom_path)
        assert reader.data[:4] == b"NES\x1a"


class TestROMReaderReadBytes:
    """Test raw byte reading."""

    @pytest.fixture
    def mock_reader(self, tmp_path):
        """Create reader with mock ROM data."""
        header = b"NES\x1a" + bytes(12)
        # Create identifiable pattern in data
        data = header + bytes(range(256)) * 1024
        rom_path = tmp_path / "mock.nes"
        rom_path.write_bytes(data)
        return ROMReader(rom_path)

    def test_read_bytes_from_header(self, mock_reader):
        """Read bytes from header area."""
        header = mock_reader.read_bytes(0, 4)
        assert header == b"NES\x1a"

    def test_read_bytes_out_of_bounds(self, mock_reader):
        """Reading beyond ROM should raise ValueError."""
        with pytest.raises(ValueError, match="out of ROM bounds"):
            mock_reader.read_bytes(999999999, 16)


class TestROMReaderChapterValidation:
    """Test chapter-related parameter validation."""

    @pytest.fixture
    def mock_reader(self, tmp_path):
        """Create reader with large enough mock ROM."""
        header = b"NES\x1a" + bytes(12)
        data = header + bytes(300000)
        rom_path = tmp_path / "mock.nes"
        rom_path.write_bytes(data)
        return ROMReader(rom_path)

    def test_invalid_chapter_number(self, mock_reader):
        """Invalid chapter should raise ValueError."""
        with pytest.raises(ValueError, match="Invalid chapter"):
            mock_reader.read_worldscreen(0, 0)

        with pytest.raises(ValueError, match="Invalid chapter"):
            mock_reader.read_worldscreen(6, 0)

    def test_index_out_of_range(self, mock_reader):
        """Index beyond chapter count should raise ValueError."""
        with pytest.raises(ValueError, match="out of range"):
            mock_reader.read_worldscreen(1, 200)  # Chapter 1 only has 131 screens


class TestROMReaderInfo:
    """Test ROM info extraction."""

    @pytest.fixture
    def mock_reader(self, tmp_path):
        """Create reader with specific header values."""
        # iNES header with specific values
        header = bytes([
            0x4E, 0x45, 0x53, 0x1A,  # NES\x1a
            0x08,  # 8 x 16KB PRG ROM = 128KB
            0x10,  # 16 x 8KB CHR ROM = 128KB
            0x12,  # Mapper low nibble = 1, vertical mirroring, battery
            0x10,  # Mapper high nibble = 1
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ])
        data = header + bytes(300000)
        rom_path = tmp_path / "mock.nes"
        rom_path.write_bytes(data)
        return ROMReader(rom_path)

    def test_get_rom_info(self, mock_reader):
        """get_rom_info extracts header data correctly."""
        info = mock_reader.get_rom_info()

        assert info["prg_rom_size"] == 8 * 16384  # 128KB
        assert info["chr_rom_size"] == 16 * 8192  # 128KB
        assert info["mapper"] == 0x11  # (0x12 >> 4) | (0x10 & 0xF0) = 1 | 0x10 = 0x11
        assert info["mirroring"] == "horizontal"  # bit 0 of byte 6 is 0
        assert info["battery"] is True  # bit 1 of byte 6 is 1

    def test_get_rom_hash(self, mock_reader):
        """get_rom_hash returns SHA256 hash string."""
        hash_str = mock_reader.get_rom_hash()
        assert len(hash_str) == 64  # SHA256 hex string
        assert all(c in "0123456789abcdef" for c in hash_str)


class TestConvenienceFunctions:
    """Test module-level convenience functions."""

    def test_load_rom_file_not_found(self, tmp_path):
        """load_rom raises on missing file."""
        with pytest.raises(FileNotFoundError):
            load_rom(tmp_path / "missing.nes")

    def test_load_chapter_file_not_found(self, tmp_path):
        """load_chapter raises on missing file."""
        with pytest.raises(FileNotFoundError):
            load_chapter(tmp_path / "missing.nes", 1)


# =============================================================================
# Integration Tests (require real ROM)
# =============================================================================

class TestRealROMIntegration:
    """Integration tests using real ROM file.

    These tests are skipped if no ROM is available.
    To run: set TMOS_ROM_PATH environment variable to ROM location.
    """

    @pytest.fixture
    def real_rom_path(self):
        """Get path to real ROM or skip."""
        import os
        rom_path = os.environ.get("TMOS_ROM_PATH")
        if not rom_path or not Path(rom_path).exists():
            pytest.skip("Real ROM not available (set TMOS_ROM_PATH)")
        return Path(rom_path)

    def test_load_all_chapters(self, real_rom_path):
        """Load all 739 screens from real ROM."""
        world = load_rom(real_rom_path)

        assert world.is_complete
        assert world.total_screens == 739

        # Check each chapter has expected count
        assert world[1].screen_count == 131
        assert world[2].screen_count == 137
        assert world[3].screen_count == 153
        assert world[4].screen_count == 164
        assert world[5].screen_count == 154

    def test_screen_data_valid(self, real_rom_path):
        """Verify screen data looks reasonable."""
        chapter = load_chapter(real_rom_path, 1)

        # Screen 0 should be overworld (ParentWorld 0x40)
        screen0 = chapter[0]
        assert screen0.parent_world == 0x40

        # Should have some connected screens
        assert len(screen0.get_connected_screens()) > 0

    def test_rom_hash_consistent(self, real_rom_path):
        """ROM hash should be consistent across reads."""
        reader1 = ROMReader(real_rom_path)
        reader2 = ROMReader(real_rom_path)

        assert reader1.get_rom_hash() == reader2.get_rom_hash()
