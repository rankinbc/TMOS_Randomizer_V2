"""Read/write for the per-chapter encounter group tables.

Each chapter has a list of 3-byte entries describing which screens trigger
random encounters and how:

  byte 0: screen_index (relative to chapter)
  byte 1: monster_group / lineup selector
            For Ch1-2: low 7 bits = lineup index (0-6); high bit = behavior flag
            For Ch3-5: low 7 bits can exceed lineup count — semantic differs;
                       high bit still present
  byte 2: encounter rate / difficulty flag (0=low, 1=med, 2=high, 3=very high)

ROM addresses (ROM_VERIFIED, source: encounter_tables.json):
  Ch1: $C02A, 15 entries
  Ch2: $C058, 16 entries
  Ch3: $C089, 17 entries
  Ch4: $C0BD, 22 entries
  Ch5: $C100, 19 entries

Source: GameAnalysis2 raw_research/screen_exp_mapping.md (ROM_VERIFIED).
"""

from __future__ import annotations

from typing import TypedDict


GROUP_BASE: dict[int, int] = {
    1: 0xC02A,
    2: 0xC058,
    3: 0xC089,
    4: 0xC0BD,
    5: 0xC100,
}

GROUP_COUNT: dict[int, int] = {
    1: 15,
    2: 16,
    3: 17,
    4: 22,
    5: 19,
}

ENTRY_SIZE = 3


class EncounterGroupEntryDTO(TypedDict):
    chapter: int
    entry_index: int
    rom_offset: str
    screen_hex: str             # "0x1B"
    screen: int                 # raw byte
    monster_group: int          # full byte 1 (high bit + low 7)
    monster_group_low: int      # low 7 bits
    monster_group_hi_bit: int   # 1 if high bit set, 0 otherwise
    flag: int                   # byte 2: 0..3 expected; encounter rate/intensity


class ChapterGroupsDTO(TypedDict):
    chapter: int
    rom_offset: str
    entry_count: int
    entries: list[EncounterGroupEntryDTO]


# ---------------------------------------------------------------------------
# Read
# ---------------------------------------------------------------------------

def _entry_dto(rom: bytes, chapter: int, idx: int) -> EncounterGroupEntryDTO:
    base = GROUP_BASE[chapter] + idx * ENTRY_SIZE
    screen = rom[base]
    monster_group = rom[base + 1]
    flag = rom[base + 2]
    return {
        "chapter": chapter,
        "entry_index": idx,
        "rom_offset": f"0x{base:05X}",
        "screen_hex": f"0x{screen:02X}",
        "screen": screen,
        "monster_group": monster_group,
        "monster_group_low": monster_group & 0x7F,
        "monster_group_hi_bit": 1 if monster_group & 0x80 else 0,
        "flag": flag,
    }


def read_chapter_groups(rom: bytes, chapter: int) -> ChapterGroupsDTO:
    if chapter not in GROUP_BASE:
        raise ValueError(f"chapter must be 1..5, got {chapter}")
    return {
        "chapter": chapter,
        "rom_offset": f"0x{GROUP_BASE[chapter]:05X}",
        "entry_count": GROUP_COUNT[chapter],
        "entries": [_entry_dto(rom, chapter, i) for i in range(GROUP_COUNT[chapter])],
    }


def read_all_groups(rom: bytes) -> list[ChapterGroupsDTO]:
    return [read_chapter_groups(rom, ch) for ch in sorted(GROUP_BASE.keys())]


# ---------------------------------------------------------------------------
# Write — partial updates allowed (any field can be left None)
# ---------------------------------------------------------------------------

def write_group_entry(
    rom: bytearray,
    chapter: int,
    entry_index: int,
    *,
    screen: int | None = None,
    monster_group: int | None = None,
    flag: int | None = None,
) -> EncounterGroupEntryDTO:
    if chapter not in GROUP_BASE:
        raise ValueError(f"chapter must be 1..5, got {chapter}")
    if not 0 <= entry_index < GROUP_COUNT[chapter]:
        raise ValueError(
            f"entry_index must be 0..{GROUP_COUNT[chapter]-1} for ch{chapter}, "
            f"got {entry_index}"
        )

    if screen is not None and not 0 <= screen <= 0xFF:
        raise ValueError(f"screen must be 0..255, got {screen}")
    if monster_group is not None and not 0 <= monster_group <= 0xFF:
        raise ValueError(f"monster_group must be 0..255, got {monster_group}")
    if flag is not None and not 0 <= flag <= 0xFF:
        raise ValueError(f"flag must be 0..255, got {flag}")

    base = GROUP_BASE[chapter] + entry_index * ENTRY_SIZE
    if screen is not None:
        rom[base] = screen
    if monster_group is not None:
        rom[base + 1] = monster_group
    if flag is not None:
        rom[base + 2] = flag

    return _entry_dto(bytes(rom), chapter, entry_index)
