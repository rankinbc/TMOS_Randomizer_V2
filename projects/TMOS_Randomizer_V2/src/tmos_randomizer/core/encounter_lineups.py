"""Read/write for the per-chapter encounter lineup tables.

Each chapter has 6-8 active "lineups" — sets of enemies that appear together
in a turn-based battle. The screen-encounter system (see encounter_groups.py)
selects which lineup activates per screen.

ROM layout per chapter (from encounter_tables.json, ROM_VERIFIED):
  Chapter 1: $C211, 6 active lineups
  Chapter 2: $C241, 6 active lineups
  Chapter 3: $C271, 6 active lineups
  Chapter 4: $C2C1, 6 active lineups
  Chapter 5: $C301, 8 active lineups

Each lineup is 8 bytes:
  [start_byte, slot1, slot2, slot3, slot4, slot5, slot6, slot7]

  - start_byte: 0x00 normal, 0x01 = special behavior (e.g., harder formation)
  - slots 1-7: enemy_id (see core/enemies.py), 0xFF = empty, 0x00 = empty

Block allocation in ROM is larger than active count (40 lineups per chapter
allocated; only 6-8 used). We expose only the active range for editing.
"""

from __future__ import annotations

from typing import TypedDict

from .enemies import BATTLE_ENEMIES, is_special_slot

# ROM addresses (file offsets, since the ROM has no iNES header detection issue here)
LINEUP_BASE: dict[int, int] = {
    1: 0xC211,
    2: 0xC241,
    3: 0xC271,
    4: 0xC2C1,
    5: 0xC301,
}

# Active lineup count per chapter
LINEUP_COUNT: dict[int, int] = {
    1: 6,
    2: 6,
    3: 6,
    4: 6,
    5: 8,
}

LINEUP_SIZE = 8                # bytes per lineup
SLOTS_PER_LINEUP = 7           # slots 1..7 (slot 0 is the start_byte flag)


class LineupSlotDTO(TypedDict):
    slot: int                  # 1-7
    enemy_id: int              # 0..255; 0x00/0xFF = empty
    enemy_name: str | None     # resolved name if known
    is_empty: bool


class LineupDTO(TypedDict):
    chapter: int
    lineup_index: int
    rom_offset: str
    start_byte: int
    slots: list[LineupSlotDTO]
    total_hp: int              # sum of HP across non-empty slots (0 if any unknown)


class ChapterLineupsDTO(TypedDict):
    chapter: int
    rom_offset: str
    lineup_count: int
    lineups: list[LineupDTO]


# ---------------------------------------------------------------------------
# Read
# ---------------------------------------------------------------------------

def _slot_dto(byte: int, slot_index: int) -> LineupSlotDTO:
    if is_special_slot(byte):
        return {"slot": slot_index, "enemy_id": byte, "enemy_name": None, "is_empty": True}
    enemy = BATTLE_ENEMIES.get(byte)
    return {
        "slot": slot_index,
        "enemy_id": byte,
        "enemy_name": enemy["name"] if enemy else f"Unknown 0x{byte:02X}",
        "is_empty": False,
    }


def _lineup_dto(rom: bytes, chapter: int, lineup_idx: int) -> LineupDTO:
    base = LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE
    start_byte = rom[base]
    slots = [_slot_dto(rom[base + 1 + i], i + 1) for i in range(SLOTS_PER_LINEUP)]
    total_hp = 0
    for s in slots:
        if not s["is_empty"]:
            enemy = BATTLE_ENEMIES.get(s["enemy_id"])
            if enemy and enemy["hp"]:
                total_hp += enemy["hp"]
    return {
        "chapter": chapter,
        "lineup_index": lineup_idx,
        "rom_offset": f"0x{base:05X}",
        "start_byte": start_byte,
        "slots": slots,
        "total_hp": total_hp,
    }


def read_chapter_lineups(rom: bytes, chapter: int) -> ChapterLineupsDTO:
    if chapter not in LINEUP_BASE:
        raise ValueError(f"chapter must be 1..5, got {chapter}")
    return {
        "chapter": chapter,
        "rom_offset": f"0x{LINEUP_BASE[chapter]:05X}",
        "lineup_count": LINEUP_COUNT[chapter],
        "lineups": [_lineup_dto(rom, chapter, i) for i in range(LINEUP_COUNT[chapter])],
    }


def read_all_lineups(rom: bytes) -> list[ChapterLineupsDTO]:
    return [read_chapter_lineups(rom, ch) for ch in sorted(LINEUP_BASE.keys())]


# ---------------------------------------------------------------------------
# Write
# ---------------------------------------------------------------------------

def write_lineup_slot(
    rom: bytearray, chapter: int, lineup_idx: int, slot: int, enemy_id: int
) -> LineupSlotDTO:
    """Set a single slot of a single lineup. slot is 1..7 (matches the DTO)."""
    if chapter not in LINEUP_BASE:
        raise ValueError(f"chapter must be 1..5, got {chapter}")
    if not 0 <= lineup_idx < LINEUP_COUNT[chapter]:
        raise ValueError(f"lineup_idx must be 0..{LINEUP_COUNT[chapter]-1} for ch{chapter}, got {lineup_idx}")
    if not 1 <= slot <= SLOTS_PER_LINEUP:
        raise ValueError(f"slot must be 1..{SLOTS_PER_LINEUP}, got {slot}")
    if not 0 <= enemy_id <= 0xFF:
        raise ValueError(f"enemy_id must be 0..255, got {enemy_id}")
    base = LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE
    rom[base + slot] = enemy_id
    return _slot_dto(enemy_id, slot)


def write_lineup_start_byte(
    rom: bytearray, chapter: int, lineup_idx: int, value: int
) -> int:
    """Set the start_byte flag for a lineup (0x00 normal or 0x01 special)."""
    if chapter not in LINEUP_BASE:
        raise ValueError(f"chapter must be 1..5, got {chapter}")
    if not 0 <= lineup_idx < LINEUP_COUNT[chapter]:
        raise ValueError(f"lineup_idx out of range for ch{chapter}")
    if value not in (0x00, 0x01):
        raise ValueError(f"start_byte must be 0x00 or 0x01, got 0x{value:02X}")
    rom[LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE] = value
    return value
