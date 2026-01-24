"""ROM reader - loads WorldScreen data from NES ROM files.

Supports loading individual chapters or the entire game world.
"""

from __future__ import annotations

from pathlib import Path
from typing import BinaryIO, Optional, Union

from ..core.constants import (
    CHAPTER_BASES,
    CHAPTER_OFFSETS,
    WORLDSCREEN_SIZE,
    TOTAL_SCREENS,
    relative_to_global,
)
from ..core.worldscreen import WorldScreen
from ..core.chapter import Chapter, GameWorld


class ROMReader:
    """Reads TMOS ROM data into Python objects.

    The ROM format is iNES with a 16-byte header.
    All addresses in constants are file offsets (including header).
    """

    INES_HEADER_SIZE = 16
    EXPECTED_ROM_SIZE = 262160  # 256KB + 16-byte header

    def __init__(self, rom_path: Union[str, Path]) -> None:
        """Initialize with path to ROM file.

        Args:
            rom_path: Path to the NES ROM file (.nes)
        """
        self.rom_path = Path(rom_path)
        self._data: Optional[bytes] = None

    @property
    def data(self) -> bytes:
        """Lazy-load ROM data."""
        if self._data is None:
            self._load_rom()
        return self._data  # type: ignore

    def _load_rom(self) -> None:
        """Load ROM file into memory."""
        if not self.rom_path.exists():
            raise FileNotFoundError(f"ROM not found: {self.rom_path}")

        with open(self.rom_path, "rb") as f:
            self._data = f.read()

        # Validate ROM
        self._validate_rom()

    def _validate_rom(self) -> None:
        """Validate ROM format and size."""
        if self._data is None:
            raise RuntimeError("ROM not loaded")

        # Check iNES header magic
        if self._data[:4] != b"NES\x1a":
            raise ValueError("Invalid NES ROM: missing iNES header")

        # Check size (allow some variance for different header configs)
        if len(self._data) < self.EXPECTED_ROM_SIZE - 1000:
            raise ValueError(
                f"ROM too small: {len(self._data)} bytes, "
                f"expected ~{self.EXPECTED_ROM_SIZE}"
            )

    def read_bytes(self, address: int, length: int) -> bytes:
        """Read raw bytes from ROM at given file offset.

        Args:
            address: File offset (including iNES header)
            length: Number of bytes to read

        Returns:
            Raw bytes from ROM
        """
        if address < 0 or address + length > len(self.data):
            raise ValueError(
                f"Address 0x{address:X} + {length} out of ROM bounds"
            )
        return self.data[address : address + length]

    def read_worldscreen(
        self,
        chapter: int,
        relative_index: int,
    ) -> WorldScreen:
        """Read a single WorldScreen from ROM.

        Args:
            chapter: Chapter number (1-5)
            relative_index: Screen index within chapter

        Returns:
            WorldScreen object with data from ROM
        """
        if chapter not in CHAPTER_BASES:
            raise ValueError(f"Invalid chapter {chapter}, must be 1-5")

        _, count = CHAPTER_OFFSETS[chapter]
        if relative_index < 0 or relative_index >= count:
            raise ValueError(
                f"Index {relative_index} out of range for chapter {chapter} "
                f"(0-{count - 1})"
            )

        address = CHAPTER_BASES[chapter] + (relative_index * WORLDSCREEN_SIZE)
        data = self.read_bytes(address, WORLDSCREEN_SIZE)
        global_index = relative_to_global(chapter, relative_index)

        return WorldScreen.from_bytes(
            data,
            global_index=global_index,
            chapter=chapter,
            relative_index=relative_index,
        )

    def read_chapter(self, chapter_num: int) -> Chapter:
        """Read all screens for a chapter.

        Args:
            chapter_num: Chapter number (1-5)

        Returns:
            Chapter object with all screens loaded
        """
        if chapter_num not in CHAPTER_OFFSETS:
            raise ValueError(f"Invalid chapter {chapter_num}, must be 1-5")

        _, count = CHAPTER_OFFSETS[chapter_num]
        chapter = Chapter(chapter_num=chapter_num)

        for relative_index in range(count):
            screen = self.read_worldscreen(chapter_num, relative_index)
            chapter.add_screen(screen)

        return chapter

    def read_all_chapters(self) -> GameWorld:
        """Read all chapters from ROM.

        Returns:
            GameWorld object with all 5 chapters loaded
        """
        world = GameWorld()
        for chapter_num in range(1, 6):
            chapter = self.read_chapter(chapter_num)
            world.add_chapter(chapter)
        return world

    def get_rom_hash(self) -> str:
        """Calculate SHA256 hash of ROM for verification."""
        import hashlib
        return hashlib.sha256(self.data).hexdigest()

    def get_rom_info(self) -> dict:
        """Get ROM metadata from iNES header."""
        header = self.data[:16]
        return {
            "prg_rom_size": header[4] * 16384,  # 16KB units
            "chr_rom_size": header[5] * 8192,   # 8KB units
            "mapper": (header[6] >> 4) | (header[7] & 0xF0),
            "mirroring": "vertical" if header[6] & 1 else "horizontal",
            "battery": bool(header[6] & 2),
            "trainer": bool(header[6] & 4),
            "total_size": len(self.data),
            "sha256": self.get_rom_hash()[:16] + "...",
        }


def load_rom(rom_path: Union[str, Path]) -> GameWorld:
    """Convenience function to load entire game world from ROM.

    Args:
        rom_path: Path to NES ROM file

    Returns:
        GameWorld with all chapters loaded
    """
    reader = ROMReader(rom_path)
    return reader.read_all_chapters()


def load_chapter(rom_path: Union[str, Path], chapter_num: int) -> Chapter:
    """Convenience function to load a single chapter from ROM.

    Args:
        rom_path: Path to NES ROM file
        chapter_num: Chapter number (1-5)

    Returns:
        Chapter with all screens loaded
    """
    reader = ROMReader(rom_path)
    return reader.read_chapter(chapter_num)
