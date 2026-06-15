"""Direct ROM read/write for the MaxMP-per-level growth table.

Wraps the MaxMP table at file offset 0x1F68E (Bank 6 $F67E). 25 contiguous
bytes, stride 1, one per character level 1..25. Each byte is the maximum MP
the player has at that level; the game reads it via `LDA $F67E,Y` (Y = level).

The table is mirrored in Bank 3 $8C10 (Byte1 of a HP/MP pair) for the RPG
battle engine, but this module only edits the canonical Bank 6 copy — the
randomizer's other tables behave the same way and only the action-mode copy
is authoritative for editing here.

Vanilla sequence (levels 1..25):
    10 14 34 44 4E 54 5E 64 6C 73 94 9B A5 B4 B9 BE C8 CC D0 DA DC E4 EC F5 FF
    (16, 20, 52, 68, ... 245, 255 — capped at the 255 byte ceiling at L25)

Source for ROM address, layout, range and vanilla values:
  GameAnalysis2 game_specs/systems/progression/stat_growth.md
    "MaxMP table at Bank7 $F67E (0x1F68E)" [ROM_VERIFIED 2026-03-31]
Tier: safe (confirmed ROM write target).
"""

from __future__ import annotations

from typing import TypedDict


# ROM layout
MP_TABLE_OFFSET = 0x1F68E   # Bank 6 $F67E — 25 contiguous bytes, one per level
MP_TABLE_STRIDE = 1
LEVEL_COUNT = 25            # levels 1..25 (same cap as the HP-per-level table)
BYTE_MAX = 0xFF


class MpEntryDTO(TypedDict):
    level: int              # 1..25
    value: int              # max MP at this level, 0..255
    rom_offset: str


def _entry_offset(level: int) -> int:
    return MP_TABLE_OFFSET + (level - 1) * MP_TABLE_STRIDE


def _check_level(level: int) -> None:
    if not 1 <= level <= LEVEL_COUNT:
        raise ValueError(f"level must be 1..{LEVEL_COUNT}, got {level}")


def read_mp_entry(rom: bytes, level: int) -> MpEntryDTO:
    _check_level(level)
    off = _entry_offset(level)
    return {"level": level, "value": rom[off], "rom_offset": f"0x{off:05X}"}


def read_mp_table(rom: bytes) -> list[MpEntryDTO]:
    return [read_mp_entry(rom, level) for level in range(1, LEVEL_COUNT + 1)]


def write_mp_entry(rom: bytearray, level: int, value: int) -> MpEntryDTO:
    """Set max MP for one level. Mutates rom in place; out-of-range raises."""
    _check_level(level)
    if not 0 <= value <= BYTE_MAX:
        raise ValueError(f"value must be 0..{BYTE_MAX}, got {value}")
    off = _entry_offset(level)
    rom[off] = value & 0xFF
    return {"level": level, "value": value, "rom_offset": f"0x{off:05X}"}
