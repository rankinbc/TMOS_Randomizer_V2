"""Proves write_cap / write_ram_addr stay inside the 32-byte cap-table window.

Guards against a future regression where someone widens the writer to 16
bytes per slot (the old shop-format assumption) and starts trampling
`inv_pickup_handler` code that sits immediately after the 32-byte table
at bank 3 $9564+.

The inventory cap table lives at file offset 0xD544..0xD564 (8 slots x 4B).
Any byte written outside that range is a bug.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core import inventory_caps as ic
from tmos_randomizer.core.constants import INV_CAP_TABLE, INV_CAP_SLOT_COUNT, INV_CAP_SLOT_SIZE


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

TABLE_END = INV_CAP_TABLE + INV_CAP_SLOT_COUNT * INV_CAP_SLOT_SIZE  # exclusive


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def _diff_offsets(a: bytes, b: bytes) -> list[int]:
    """Return sorted list of file offsets where a[i] != b[i]."""
    return [i for i in range(len(a)) if a[i] != b[i]]


def test_table_window_is_32_bytes(vanilla_rom):
    """Sanity: 8 slots x 4 bytes = 32 bytes. Window is [0xD544, 0xD564)."""
    assert INV_CAP_SLOT_COUNT * INV_CAP_SLOT_SIZE == 32
    assert TABLE_END == INV_CAP_TABLE + 32
    assert TABLE_END == 0xD564


def test_write_cap_touches_only_one_byte(vanilla_rom):
    """Each write_cap call must change exactly one byte: byte 2 of the slot."""
    for slot_idx in range(INV_CAP_SLOT_COUNT):
        rom = bytearray(vanilla_rom)
        ic.write_cap(rom, slot_idx, max_cap=255)
        diffs = _diff_offsets(vanilla_rom, bytes(rom))
        expected = INV_CAP_TABLE + slot_idx * INV_CAP_SLOT_SIZE + 2
        assert diffs == [expected], (
            f"slot {slot_idx}: expected exactly byte 0x{expected:05X} to change, "
            f"got diffs at {[f'0x{d:05X}' for d in diffs]}"
        )


def test_write_ram_addr_touches_only_two_bytes(vanilla_rom):
    """Each write_ram_addr changes exactly bytes 0 (addr_lo) and 1 (high=$03)."""
    for slot_idx in range(INV_CAP_SLOT_COUNT):
        rom = bytearray(vanilla_rom)
        # Retarget to a different valid $03xx address.
        ic.write_ram_addr(rom, slot_idx, 0x0306)
        diffs = _diff_offsets(vanilla_rom, bytes(rom))
        base = INV_CAP_TABLE + slot_idx * INV_CAP_SLOT_SIZE
        allowed = {base, base + 1}
        assert set(diffs).issubset(allowed), (
            f"slot {slot_idx}: write_ram_addr changed bytes outside "
            f"[0x{base:05X}, 0x{base+2:05X}): {[f'0x{d:05X}' for d in diffs]}"
        )


def test_writing_every_slot_stays_in_32_byte_window(vanilla_rom):
    """Writing all 8 slots must keep every change inside [INV_CAP_TABLE, TABLE_END)."""
    rom = bytearray(vanilla_rom)
    for slot_idx in range(INV_CAP_SLOT_COUNT):
        ic.write_cap(rom, slot_idx, max_cap=42)
    diffs = _diff_offsets(vanilla_rom, bytes(rom))
    for off in diffs:
        assert INV_CAP_TABLE <= off < TABLE_END, (
            f"Byte at 0x{off:05X} changed — outside the 32-byte cap table window "
            f"[0x{INV_CAP_TABLE:05X}, 0x{TABLE_END:05X}). This would corrupt "
            f"adjacent bank-3 code or other tables."
        )


def test_no_regression_to_16_bytes_per_slot(vanilla_rom):
    """Guard against a future change that writes 16 bytes per slot (old shop fmt).

    The old (incorrect) ShopInventory.to_rom_bytes format was 4 slots * 4 bytes
    per shop, written with 16-byte stride per shop_index. If anyone reintroduces
    that pattern against INV_CAP_TABLE, bytes past 0xD564 would get trampled.
    This test codifies the invariant.
    """
    rom = bytearray(vanilla_rom)
    for slot_idx in range(INV_CAP_SLOT_COUNT):
        ic.write_cap(rom, slot_idx, max_cap=99)
    # Bytes immediately after the table must be untouched. The code at
    # bank 3 $9564 is `AD CD 05 0A A8 B9 D0 95` (see REVERSE.md inv_pickup_handler).
    untouched_start = TABLE_END
    untouched_end = TABLE_END + 32  # 32 bytes of adjacent code
    assert rom[untouched_start:untouched_end] == vanilla_rom[untouched_start:untouched_end], (
        "Bytes immediately after the cap table changed — the 32-byte window "
        "was exceeded, likely by a write_cap that incorrectly computed its offset."
    )
