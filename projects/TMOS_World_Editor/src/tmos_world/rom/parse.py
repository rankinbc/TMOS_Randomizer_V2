"""Parse a TMOS NES ROM into the simplified World model."""
from __future__ import annotations

import hashlib
from pathlib import Path

from src.tmos_world.model import Chapter, World, WorldScreen
from src.tmos_world.rom.constants import (
    CHAPTER_BASES,
    PAST_INDICES_BY_CHAPTER,
    ROM_MD5,
    SCREEN_COUNTS,
    WORLDSCREEN_SIZE,
)


class InvalidROMError(ValueError):
    """Raised when a file does not match the expected TMOS ROM signature."""


def _md5(data: bytes) -> str:
    return hashlib.md5(data).hexdigest()


def parse_rom(path: str | Path, *, verify_md5: bool = True) -> World:
    """Load a TMOS ROM file and return a populated World.

    Args:
        path: filesystem path to the ROM.
        verify_md5: when True (default), enforce the expected MD5. Disable only
            for editor-produced mutated ROMs that no longer match the original.
    """
    rom_path = Path(path)
    if not rom_path.exists():
        raise FileNotFoundError(f"ROM not found: {rom_path}")

    data = rom_path.read_bytes()
    if verify_md5:
        actual = _md5(data)
        if actual != ROM_MD5:
            raise InvalidROMError(
                f"ROM MD5 mismatch at {rom_path}: expected {ROM_MD5}, got {actual}"
            )

    chapters: list[Chapter] = []
    for chapter_num in sorted(CHAPTER_BASES):
        base = CHAPTER_BASES[chapter_num]
        count = SCREEN_COUNTS[chapter_num]
        screens: list[WorldScreen] = []
        for i in range(count):
            off = base + i * WORLDSCREEN_SIZE
            screens.append(WorldScreen.from_bytes(data[off : off + WORLDSCREEN_SIZE]))
        chapters.append(
            Chapter(
                number=chapter_num,
                base_rom_addr=base,
                screen_count=count,
                screens=screens,
                past_indices=set(PAST_INDICES_BY_CHAPTER.get(chapter_num, set())),
                sections=[],
            )
        )

    return World(chapters=chapters, rom_bytes=data)
