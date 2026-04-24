"""Simplified world-layout data model for TMOS World Editor.

Strictly matches the spec §12 surface: WorldScreen, TileSection, Section, Chapter,
World. No enemy/item/boss-stat fields — this project is world-layout only.
"""
from __future__ import annotations

from dataclasses import dataclass, field


# WorldScreen field names in ROM byte order (0..15).
WORLDSCREEN_FIELD_NAMES: tuple[str, ...] = (
    "parent_world",
    "ambient_sound",
    "content",
    "objectset",
    "nav_right",
    "nav_left",
    "nav_down",
    "nav_up",
    "datapointer",
    "exit_position",
    "top_tiles",
    "bottom_tiles",
    "worldscreen_color",
    "sprites_color",
    "unknown",
    "event",
)


@dataclass
class WorldScreen:
    parent_world: int
    ambient_sound: int
    content: int
    objectset: int
    nav_right: int
    nav_left: int
    nav_down: int
    nav_up: int
    datapointer: int
    exit_position: int
    top_tiles: int
    bottom_tiles: int
    worldscreen_color: int
    sprites_color: int
    unknown: int
    event: int

    @classmethod
    def from_bytes(cls, data: bytes) -> "WorldScreen":
        if len(data) != 16:
            raise ValueError(f"WorldScreen requires 16 bytes, got {len(data)}")
        return cls(*data)

    def to_bytes(self) -> bytes:
        return bytes(getattr(self, name) for name in WORLDSCREEN_FIELD_NAMES)


@dataclass
class TileSection:
    """32-byte TileSection (8 cols × 4 rows of tile IDs). Referenced by global index."""

    index: int  # global index 0..473 (bank * 256 + raw_index)
    data: bytes  # exactly 32 bytes


@dataclass
class Section:
    """Editor-declared grouping of screens within a chapter."""

    id: int
    type: str  # "overworld" | "town" | "dungeon" | "maze" | "boss" | "victory"
    is_past: bool
    members: dict[int, tuple[int, int]] = field(default_factory=dict)
    # screen_index -> (grid_x, grid_y)


@dataclass
class Chapter:
    number: int  # 1..5
    base_rom_addr: int
    screen_count: int
    screens: list[WorldScreen]
    past_indices: set[int] = field(default_factory=set)
    sections: list[Section] = field(default_factory=list)


@dataclass
class World:
    chapters: list[Chapter]
    # Raw ROM bytes kept so TileSection/CHR lookups for rendering stay cheap.
    rom_bytes: bytes = b""
