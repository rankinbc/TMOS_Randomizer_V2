"""ROM truth anchors — byte-level invariants for every major table constant.

These tests would have caught the original `SHOP_ITEM_TABLE = 0xD544` bug on
the day it was written: the documented label claimed "shop slots" but the
bytes at that offset don't match that shape. Cheap insurance against the same
class of error for all future offset constants.

If any of these fail:
    1. Constants in core/constants.py drifted from the ROM layout.
    2. The ROM was swapped for a different revision (MD5 should be
       b3236db14c87f375e5f24a5b9b79f071 for TMOS_ORIGINAL.nes).
    3. Someone added a new constant with an offset that overlaps a known table.
All three warrant investigation before the test is "fixed".
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.constants import (
    CHAPTER_BASES,
    ENCOUNTER_GROUP_TABLES,
    ENCOUNTER_LINEUP_TABLES,
    EXP_TABLE_OFFSET,
    EXP_TABLE_STRIDE,
    INV_CAP_TABLE,
    INV_PICKUP_AUX_DATA,
    INV_PICKUP_INDEXER,
    TILESECTION_START,
    TILE_TABLE_ADDR,
    WORLD_ENEMY_SET_PTRS,
    BANK_3_FILE_OFFSET,
)


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

# iNES constants (spec, not ROM-dependent)
INES_HEADER_SIZE = 16
PRG_BANK_SIZE = 16 * 1024   # 16 KB — NOT 8 KB. This is the bug that started it.
PRG_BANKS = 8
CHR_BANK_SIZE = 8 * 1024
CHR_BANKS = 16
EXPECTED_ROM_SIZE = INES_HEADER_SIZE + PRG_BANKS * PRG_BANK_SIZE + CHR_BANKS * CHR_BANK_SIZE


@pytest.fixture(scope="module")
def rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


# =============================================================================
# iNES sanity
# =============================================================================

def test_rom_size_matches_spec(rom):
    assert len(rom) == EXPECTED_ROM_SIZE == 262160


def test_ines_header_magic(rom):
    assert rom[0:4] == b"NES\x1a"


def test_ines_header_prg_chr_bank_counts(rom):
    """iNES byte 4 = PRG 16KB banks, byte 5 = CHR 8KB banks."""
    assert rom[4] == PRG_BANKS, f"expected 8 PRG banks, header says {rom[4]}"
    assert rom[5] == CHR_BANKS, f"expected 16 CHR banks, header says {rom[5]}"


# =============================================================================
# Bank math — the test that would have caught the original bug
# =============================================================================

def test_bank_3_file_offset_matches_spec():
    """BANK_3_FILE_OFFSET must equal header + 3 * 16KB (not 3 * 8KB)."""
    expected = INES_HEADER_SIZE + 3 * PRG_BANK_SIZE
    assert BANK_3_FILE_OFFSET == expected == 0xC010, (
        f"BANK_3_FILE_OFFSET = 0x{BANK_3_FILE_OFFSET:05X} but spec says 0x{expected:05X}. "
        f"If this fails: check whether someone used 0x2000 (8KB) instead of 0x4000 (16KB) "
        f"for PRG_BANK_SIZE. See TMOS_AI/docs/human/items-economy-re-answers.md."
    )


def test_inv_cap_table_is_in_bank_3():
    """INV_CAP_TABLE at 0xD544 must be inside the Bank 3 range [0xC010, 0x10010)."""
    bank_3_start = INES_HEADER_SIZE + 3 * PRG_BANK_SIZE
    bank_3_end = bank_3_start + PRG_BANK_SIZE
    assert bank_3_start <= INV_CAP_TABLE < bank_3_end


# =============================================================================
# Table-content anchors
# =============================================================================

def test_inv_cap_table_slot_0_bytes(rom):
    """Slot 0 = STARDUST charges (RAM $0311, cap 15, slot_idx 0)."""
    assert rom[INV_CAP_TABLE:INV_CAP_TABLE + 4] == bytes([0x11, 0x03, 0x0F, 0x00]), (
        "Bytes at INV_CAP_TABLE don't match the documented STARDUST cap entry. "
        "Either the constant drifted or someone rewrote the table."
    )


def test_inv_cap_table_slot_6_is_bread(rom):
    """Slot 6 = BREAD (RAM $0306, cap 10, slot_idx 6). Regression anchor for the RE."""
    off = INV_CAP_TABLE + 6 * 4
    assert rom[off:off + 4] == bytes([0x06, 0x03, 0x0A, 0x06])


def test_inv_pickup_indexer_first_group(rom):
    """16-byte RNG indexer, 4 groups of 4 selectors. First group = {0,1,6,7}."""
    assert rom[INV_PICKUP_INDEXER:INV_PICKUP_INDEXER + 4] == bytes([0x00, 0x01, 0x06, 0x07])


def test_inv_pickup_aux_data_first_bytes(rom):
    """12-byte block of unknown purpose immediately after inv_pickup_handler RTS.

    Anchored to catch drift; if this fails, someone repurposed the location.
    """
    assert rom[INV_PICKUP_AUX_DATA:INV_PICKUP_AUX_DATA + 4] == bytes([0x01, 0x07, 0x07, 0x08])


# =============================================================================
# Other major tables — existence + ordering invariants
# =============================================================================

def test_tilesection_start_in_range(rom):
    """TILESECTION_START must be a valid ROM offset."""
    assert 0 <= TILESECTION_START < len(rom)


def test_tile_table_addr_in_range(rom):
    """TILE_TABLE_ADDR must be a valid ROM offset with at least one non-zero byte."""
    assert 0 <= TILE_TABLE_ADDR < len(rom)
    assert any(b != 0 for b in rom[TILE_TABLE_ADDR:TILE_TABLE_ADDR + 16]), (
        "TILE_TABLE_ADDR points at 16 bytes of zeros — likely the wrong offset"
    )


def test_exp_table_first_entry(rom):
    """EXP table index 0 is EP-1 for first tier; vanilla = 2 (two-byte LE)."""
    assert EXP_TABLE_STRIDE == 2
    # First entry (two bytes, little-endian)
    assert rom[EXP_TABLE_OFFSET] == 0x02
    assert rom[EXP_TABLE_OFFSET + 1] == 0x00


def test_chapter_1_first_screen_byte_nonzero(rom):
    """Chapter 1 base must land on a WorldScreen with at least some data."""
    assert 0 <= CHAPTER_BASES[1] < len(rom)
    # A WorldScreen is 16 bytes; first byte is parent_world. Vanilla value 0x40.
    assert rom[CHAPTER_BASES[1]] == 0x40, (
        f"Chapter 1 first screen parent_world = 0x{rom[CHAPTER_BASES[1]]:02X}, expected 0x40"
    )


def test_encounter_tables_ordered(rom):
    """Encounter groups must precede lineups in ROM layout."""
    max_group = max(ENCOUNTER_GROUP_TABLES.values())
    min_lineup = min(ENCOUNTER_LINEUP_TABLES.values())
    assert max_group < min_lineup, (
        "Encounter group tables overlap/follow lineup tables — "
        "this breaks the indexing assumption in encounter_groups/encounter_lineups modules"
    )


def test_world_enemy_set_ptrs_contiguous_2_bytes():
    """The 5 per-chapter pointers must be 2 bytes apart (stride-2 pointer table)."""
    for ch in range(2, 6):
        delta = WORLD_ENEMY_SET_PTRS[ch] - WORLD_ENEMY_SET_PTRS[ch - 1]
        assert delta == 2, (
            f"WORLD_ENEMY_SET_PTRS[{ch}] - [{ch-1}] = {delta}, expected 2"
        )


def test_chapter_bases_strictly_increasing():
    """Chapter base addresses must increase monotonically (chapter 1 < 2 < ... < 5)."""
    for ch in range(2, 6):
        assert CHAPTER_BASES[ch] > CHAPTER_BASES[ch - 1], (
            f"CHAPTER_BASES[{ch}] = 0x{CHAPTER_BASES[ch]:06X} is not > "
            f"CHAPTER_BASES[{ch-1}] = 0x{CHAPTER_BASES[ch-1]:06X}"
        )


# =============================================================================
# Overlap check — no two distinct constants may share the same offset
# =============================================================================

def test_no_constant_shares_offset_with_inv_cap_table():
    """If any constant equals INV_CAP_TABLE, it's the sign of a repurposed offset
    (the original bug was naming 0xD544 'SHOP_ITEM_TABLE' when it was the cap table)."""
    all_offsets = {
        "INV_PICKUP_INDEXER": INV_PICKUP_INDEXER,
        "INV_PICKUP_AUX_DATA": INV_PICKUP_AUX_DATA,
        "TILESECTION_START": TILESECTION_START,
        "TILE_TABLE_ADDR": TILE_TABLE_ADDR,
        "EXP_TABLE_OFFSET": EXP_TABLE_OFFSET,
        "BANK_3_FILE_OFFSET": BANK_3_FILE_OFFSET,
    }
    for name, off in all_offsets.items():
        assert off != INV_CAP_TABLE, (
            f"{name} has the same offset as INV_CAP_TABLE (0x{INV_CAP_TABLE:05X}). "
            f"Different names at the same offset is the exact smell that produced the "
            f"original 'SHOP_ITEM_TABLE vs INV_CAP_TABLE' bug."
        )
