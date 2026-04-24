"""Write a mutated World back to a ROM file.

Only WorldScreen bytes are rewritten — TileSection, CHR, and ObjectSet data are
left untouched. This keeps the editor strictly within the scope declared in
CLAUDE.md ("world-layout only").
"""
from __future__ import annotations

from pathlib import Path

from src.tmos_world.model import World
from src.tmos_world.rom.constants import WORLDSCREEN_SIZE


def write_rom(world: World, path: str | Path) -> None:
    """Serialize world.chapters into a fresh copy of world.rom_bytes at path."""
    if not world.rom_bytes:
        raise ValueError("World has no rom_bytes to write — parse_rom must precede write_rom")

    buf = bytearray(world.rom_bytes)
    for chapter in world.chapters:
        if len(chapter.screens) != chapter.screen_count:
            raise ValueError(
                f"Chapter {chapter.number} expected {chapter.screen_count} screens, "
                f"got {len(chapter.screens)}"
            )
        for i, screen in enumerate(chapter.screens):
            off = chapter.base_rom_addr + i * WORLDSCREEN_SIZE
            buf[off : off + WORLDSCREEN_SIZE] = screen.to_bytes()

    Path(path).write_bytes(bytes(buf))
