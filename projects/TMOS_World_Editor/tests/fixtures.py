"""Synthetic World builders used by multiple test modules."""
from __future__ import annotations

from src.tmos_world.model import Chapter, World, WorldScreen
from src.tmos_world.rom.constants import (
    EVENT_STAIRWAY,
    NAV_BLOCKED,
    TILESECTION_BASE,
    TILESECTION_BANK1_OFFSET,
    TILESECTION_STRIDE,
)


def _rom_with_tilesection(index: int, bank: int, tile_ids: list[int]) -> bytearray:
    """Return a bytearray ROM buffer containing one TileSection at the given (index, bank)."""
    # Oversize so addressing never falls off the end.
    buf = bytearray(0x50000)
    off = (
        TILESECTION_BASE
        + (TILESECTION_BANK1_OFFSET if bank else 0)
        + index * TILESECTION_STRIDE
    )
    assert len(tile_ids) == 32
    for i, t in enumerate(tile_ids):
        buf[off + i] = t
    return buf


def make_screen(
    *,
    nav_right: int = NAV_BLOCKED,
    nav_left: int = NAV_BLOCKED,
    nav_down: int = NAV_BLOCKED,
    nav_up: int = NAV_BLOCKED,
    content: int = 0x00,
    event: int = 0x00,
    top_tiles: int = 0,
    bottom_tiles: int = 0,
    datapointer: int = 0x00,
    **kwargs,
) -> WorldScreen:
    """Build a synthetic WorldScreen with sensible defaults."""
    defaults = {
        "parent_world": 0,
        "ambient_sound": 0,
        "objectset": 0,
        "exit_position": 0,
        "worldscreen_color": 0,
        "sprites_color": 0,
        "unknown": 0,
    }
    defaults.update(kwargs)
    return WorldScreen(
        parent_world=defaults["parent_world"],
        ambient_sound=defaults["ambient_sound"],
        content=content,
        objectset=defaults["objectset"],
        nav_right=nav_right,
        nav_left=nav_left,
        nav_down=nav_down,
        nav_up=nav_up,
        datapointer=datapointer,
        exit_position=defaults["exit_position"],
        top_tiles=top_tiles,
        bottom_tiles=bottom_tiles,
        worldscreen_color=defaults["worldscreen_color"],
        sprites_color=defaults["sprites_color"],
        unknown=defaults["unknown"],
        event=event,
    )


def make_world(
    chapter_screens: list[list[WorldScreen]],
    *,
    rom_bytes: bytes | None = None,
    past_indices_by_chapter: dict[int, set[int]] | None = None,
) -> World:
    """Build a synthetic World from explicit chapter screen lists."""
    if rom_bytes is None:
        # All-walkable grass (tile 0x46) — zero R-017 issues by default.
        buf = bytearray(0x50000)
        # Fill the two referenced TileSection slots with grass.
        for idx in (0,):
            for bank in (0, 1):
                off = (
                    TILESECTION_BASE
                    + (TILESECTION_BANK1_OFFSET if bank else 0)
                    + idx * TILESECTION_STRIDE
                )
                for i in range(32):
                    buf[off + i] = 0x46
        rom_bytes = bytes(buf)

    past_indices_by_chapter = past_indices_by_chapter or {}
    chapters = []
    for i, screens in enumerate(chapter_screens):
        num = i + 1
        chapters.append(
            Chapter(
                number=num,
                base_rom_addr=0x00,
                screen_count=len(screens),
                screens=list(screens),
                past_indices=set(past_indices_by_chapter.get(num, set())),
                sections=[],
            )
        )
    return World(chapters=chapters, rom_bytes=rom_bytes)


def make_single_chapter_world(
    screens: list[WorldScreen],
    *,
    past_indices: set[int] | None = None,
    rom_bytes: bytes | None = None,
) -> World:
    return make_world(
        [screens],
        past_indices_by_chapter={1: past_indices or set()},
        rom_bytes=rom_bytes,
    )


def collidable_rom_bytes(tile_section_index: int = 0) -> bytes:
    """ROM buffer whose referenced TileSection is all collidable (tree 0x47)."""
    buf = bytearray(0x50000)
    for bank in (0, 1):
        off = (
            TILESECTION_BASE
            + (TILESECTION_BANK1_OFFSET if bank else 0)
            + tile_section_index * TILESECTION_STRIDE
        )
        for i in range(32):
            buf[off + i] = 0x47
    return bytes(buf)


__all__ = [
    "collidable_rom_bytes",
    "make_screen",
    "make_single_chapter_world",
    "make_world",
    "EVENT_STAIRWAY",
    "NAV_BLOCKED",
]
