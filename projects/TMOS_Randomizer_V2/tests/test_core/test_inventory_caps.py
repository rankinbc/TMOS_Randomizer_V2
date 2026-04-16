"""Tests for core/inventory_caps.py."""

from pathlib import Path

import pytest

from tmos_randomizer.core import inventory_caps as ic
from tmos_randomizer.core.constants import INV_CAP_TABLE


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def test_read_caps_returns_8_slots(vanilla_rom):
    caps = ic.read_caps(vanilla_rom)
    assert len(caps) == 8


def test_known_vanilla_pointers_resolve_to_documented_labels(vanilla_rom):
    caps = ic.read_caps(vanilla_rom)
    by_addr = {c["ram_addr"]: c for c in caps}
    # From RE answer doc: $0306 = BREAD cap 10, $0307 = MASHROOB cap 10,
    # $0311 = STARDUST cap 15.
    assert by_addr[0x0306]["label"] == "BREAD"
    assert by_addr[0x0306]["max_cap"] == 10
    assert by_addr[0x0307]["label"] == "MASHROOB"
    assert by_addr[0x0307]["max_cap"] == 10
    assert by_addr[0x0311]["label"] == "STARDUST charges"
    assert by_addr[0x0311]["max_cap"] == 15


def test_high_byte_is_03_in_vanilla(vanilla_rom):
    caps = ic.read_caps(vanilla_rom)
    for c in caps:
        assert c["high_byte_warning"] is False
        assert (c["ram_addr"] >> 8) == 0x03


def test_write_cap_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    result = ic.write_cap(rom, slot_idx=6, max_cap=99)  # slot 6 = $0306 BREAD
    assert result["max_cap"] == 99
    assert result["ram_addr"] == 0x0306
    # Confirm only byte 2 changed
    off = INV_CAP_TABLE + 6 * 4
    assert rom[off] == vanilla_rom[off]          # ram_addr_lo unchanged
    assert rom[off + 1] == 0x03                  # high byte unchanged
    assert rom[off + 2] == 99                    # cap updated
    assert rom[off + 3] == vanilla_rom[off + 3]  # slot_idx unchanged


@pytest.mark.parametrize("bad", [-1, 256, 1000])
def test_write_cap_bounds(vanilla_rom, bad):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="max_cap must be 0..255"):
        ic.write_cap(rom, 0, bad)


def test_write_ram_addr_refuses_non_03xx(vanilla_rom):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="must be in"):
        ic.write_ram_addr(rom, 0, 0x0500)


def test_write_ram_addr_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    result = ic.write_ram_addr(rom, 0, 0x0306)  # retarget slot 0 to BREAD
    assert result["ram_addr"] == 0x0306
    assert result["label"] == "BREAD"
