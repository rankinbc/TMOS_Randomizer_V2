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
    BANK_1_FILE_OFFSET,
    BANK_3_FILE_OFFSET,
    BANK_6_FILE_OFFSET,
    BANK_1_FREE_SPACE_START,
    BANK_1_FREE_SPACE_END,
    CHAPTER_START_SCREENS,
    GOLD_MAX,
    MAGIC_SHOP_BASE_PRICES,
    MAGIC_SHOP_BASE_PRICE_COUNT,
    SECRET_EVENT_SCREEN,
    SECRET_EVENT_SCREEN_IMM,
    SHOP_CODE_LEGAL_HI4,
    SHOP_CODES_UNVERIFIED,
    SHOP_CODES_VERIFIED,
    SHOP_COUNT,
    SHOP_DATA_TABLE,
    SHOP_POINTER_COUNT,
    SHOP_POINTER_TABLE,
    SHOP_SLOT_SIZE,
    SHOP_SLOTS_PER_SHOP,
    WARP_DEST_GROUPS,
    WARP_DEST_TABLE,
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


# =============================================================================
# Bank 1 shop tables (resolved 2026-07-02, RETMOS "Shop Tables WRITE Spec")
# Authoritative doc: knowledge/systems/shops-and-economy.md
# =============================================================================

def test_bank_1_file_offset_matches_spec():
    assert BANK_1_FILE_OFFSET == INES_HEADER_SIZE + 1 * PRG_BANK_SIZE


def test_shop_table_offset_math():
    assert SHOP_POINTER_TABLE == BANK_1_FILE_OFFSET + (0x94ED - 0x8000)
    assert SHOP_DATA_TABLE == BANK_1_FILE_OFFSET + (0x94FD - 0x8000)
    assert MAGIC_SHOP_BASE_PRICES == BANK_1_FILE_OFFSET + (0x8AAC - 0x8000)


def test_shop_pointer_table_shape(rom):
    """8 little-endian CPU pointers, all inside the $8000-$BFFF bank window.

    Vanilla pointers are contiguous 8-byte strides starting at $94FD."""
    ptrs = [
        int.from_bytes(rom[SHOP_POINTER_TABLE + i * 2 : SHOP_POINTER_TABLE + i * 2 + 2], "little")
        for i in range(SHOP_POINTER_COUNT)
    ]
    assert all(0x8000 <= p <= 0xBFFF for p in ptrs), ptrs
    assert ptrs == [0x94FD + i * 8 for i in range(SHOP_POINTER_COUNT)]


def test_shop_data_codes_all_legal(rom):
    """Every vanilla slot code has hi-nibble in {1,3,5} and is a known code."""
    data = rom[SHOP_DATA_TABLE : SHOP_DATA_TABLE + SHOP_COUNT * SHOP_SLOTS_PER_SHOP * SHOP_SLOT_SIZE]
    codes = data[0::2]
    known = SHOP_CODES_VERIFIED | SHOP_CODES_UNVERIFIED
    for c in codes:
        assert (c >> 4) in SHOP_CODE_LEGAL_HI4, f"illegal hi4 in vanilla code 0x{c:02X}"
        assert c in known, f"vanilla shop code 0x{c:02X} missing from known-code sets"


def test_shop_data_first_shop_vanilla_bytes(rom):
    """Shop 0 vanilla slots: BREAD, MASHROOB, $10, HORN."""
    shop0 = rom[SHOP_DATA_TABLE : SHOP_DATA_TABLE + 8]
    assert list(shop0[0::2]) == [0x33, 0x34, 0x10, 0x53], list(shop0[0::2])


def test_magic_shop_base_prices_vanilla(rom):
    """$8AAC base price table, charged as base * (chapter+1)."""
    prices = list(rom[MAGIC_SHOP_BASE_PRICES : MAGIC_SHOP_BASE_PRICES + MAGIC_SHOP_BASE_PRICE_COUNT])
    assert prices == [20, 30, 40, 20, 40, 30, 20, 40, 30, 40, 50], prices


def test_magic_shop_max_price_fits_bcd_gold():
    """Highest vanilla base (50) x max chapter multiplier (6) must stay <= 999."""
    assert 50 * 6 <= GOLD_MAX


def test_bank_1_free_space_is_zero_filled(rom):
    free = rom[BANK_1_FREE_SPACE_START:BANK_1_FREE_SPACE_END]
    assert len(free) == 463
    assert not any(free), "bank 1 free-space block is no longer zero-filled"


# =============================================================================
# Bank 6 warp/time-door destination table + hardcoded screens
# Authoritative doc: knowledge/systems/screen-relocation-constraints.md
# =============================================================================

def test_bank_6_file_offset_matches_spec():
    assert BANK_6_FILE_OFFSET == INES_HEADER_SIZE + 6 * PRG_BANK_SIZE


def test_warp_dest_table_offset_math():
    assert WARP_DEST_TABLE == BANK_6_FILE_OFFSET + (0x98C0 - 0x8000)


def test_warp_dest_table_vanilla_bytes(rom):
    """5 chapter-groups x 8 destination screen indices ($98C0)."""
    expected = [
        [0x00, 0x17, 0x20, 0x7E, 0x3D, 0x42, 0x00, 0x00],
        [0x09, 0x34, 0x26, 0x00, 0x4E, 0x00, 0x00, 0x00],
        [0x01, 0x2B, 0x2D, 0x00, 0x35, 0x33, 0x00, 0x00],
        [0x26, 0x28, 0x08, 0x00, 0x38, 0x60, 0x00, 0x00],
        [0x20, 0x1C, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00],
    ]
    for g in range(WARP_DEST_GROUPS):
        row = list(rom[WARP_DEST_TABLE + g * 8 : WARP_DEST_TABLE + (g + 1) * 8])
        assert row == expected[g], f"warp group {g}: {row}"


def test_secret_event_screen_immediate(rom):
    """Bank 6 $90D1 CMP #$1A — the byte before the operand must be the CMP
    immediate opcode (0xC9), proving the offset points at the operand and not
    at coincidental data."""
    assert rom[SECRET_EVENT_SCREEN_IMM] == SECRET_EVENT_SCREEN
    assert rom[SECRET_EVENT_SCREEN_IMM - 1] == 0xC9


def test_chapter_start_screens_spec():
    """One start screen per chapter, chapter-relative index 4 + 5*(n-1) pattern."""
    assert CHAPTER_START_SCREENS == (4, 9, 14, 19, 24)


def test_chapter_respawn_table_vanilla_bytes(rom):
    """Bank 4 $8136 — respawn screen per chapter, read at every level start."""
    from tmos_randomizer.core.constants import CHAPTER_RESPAWN_TABLE, CHAPTER_RESPAWN_SCREENS
    assert tuple(rom[CHAPTER_RESPAWN_TABLE : CHAPTER_RESPAWN_TABLE + 5]) == CHAPTER_RESPAWN_SCREENS


def test_intro_screen_table_vanilla_bytes(rom):
    """Bank 1 $8E92 — two 5-screen intro display sets."""
    from tmos_randomizer.core.constants import INTRO_SCREEN_TABLE, INTRO_SCREEN_COUNT
    expected = bytes([0x40, 0x4F, 0x4B, 0x38, 0x68, 0x1A, 0x01, 0x32, 0x02, 0x34])
    assert rom[INTRO_SCREEN_TABLE : INTRO_SCREEN_TABLE + INTRO_SCREEN_COUNT] == expected
