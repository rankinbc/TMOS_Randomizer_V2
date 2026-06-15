"""Tests for core/shop_economy.py.

Verifies the Bank 1 $94FD shop table (file 0x0550D) and the trooper
recruitment cost byte at file $4577 against ROM-confirmed vanilla values.

Vanilla shop data source: game_specs/systems/economy/README.md decoded table
(2026-06-15 disassembly); confirmed byte-for-byte against TMOS_ORIGINAL.nes.
Trooper cost $4577 = 0x64 = 100 [ROM_VERIFIED].
"""

from pathlib import Path

import pytest

from tmos_randomizer.core import shop_economy as se


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


# --- constants / offsets ---------------------------------------------------

def test_constants():
    assert se.SHOP_TABLE == 0x0550D
    assert se.SHOP_COUNT == 8
    assert se.SHOP_SLOTS == 4
    assert se.SHOP_SLOT_SIZE == 2
    assert se.SHOP_RECORD_SIZE == 8
    assert se.TROOPER_PRICE_OFFSET == 0x4577


# --- shop slots + prices ---------------------------------------------------

# (shop, slot) -> (item_code, base_price) from README decoded table.
_VANILLA_SHOPS = {
    (0, 0): (0x33, 20), (0, 1): (0x34, 20), (0, 2): (0x10, 40), (0, 3): (0x53, 40),
    (1, 0): (0x33, 20), (1, 1): (0x34, 20), (1, 2): (0x52, 20), (1, 3): (0x51, 100),
    (2, 0): (0x33, 60), (2, 1): (0x34, 60), (2, 2): (0x52, 60), (2, 3): (0x51, 100),
    (3, 0): (0x52, 20), (3, 1): (0x10, 40), (3, 2): (0x53, 40), (3, 3): (0x11, 40),
    (4, 0): (0x33, 20), (4, 1): (0x34, 20), (4, 2): (0x52, 20), (4, 3): (0x58, 40),
    (5, 0): (0x33, 20), (5, 1): (0x34, 20), (5, 2): (0x52, 20), (5, 3): (0x51, 100),
    (6, 0): (0x33, 60), (6, 1): (0x34, 60), (6, 2): (0x52, 60), (6, 3): (0x51, 100),
    (7, 0): (0x52, 20), (7, 1): (0x10, 40), (7, 2): (0x53, 40), (7, 3): (0x11, 40),
}


def test_known_vanilla_shop_slots(vanilla_rom):
    for (shop, slot), (code, price) in _VANILLA_SHOPS.items():
        dto = se.read_shop_slot(vanilla_rom, shop, slot)
        assert dto["item_code"] == code, (shop, slot)
        assert dto["base_price"] == price, (shop, slot)


def test_item_labels(vanilla_rom):
    # Shop 0 slot 0 is BREAD (0x33), slot 1 MASHROOB (0x34)
    assert se.read_shop_slot(vanilla_rom, 0, 0)["item_label"] == "BREAD"
    assert se.read_shop_slot(vanilla_rom, 0, 1)["item_label"] == "MASHROOB"
    assert se.read_shop_slot(vanilla_rom, 0, 3)["item_label"] == "HORN"  # 0x53


def test_read_shop_returns_four(vanilla_rom):
    slots = se.read_shop(vanilla_rom, 1)
    assert len(slots) == 4
    assert [s["base_price"] for s in slots] == [20, 20, 20, 100]


def test_read_all_shops_count(vanilla_rom):
    all_slots = se.read_all_shops(vanilla_rom)
    assert len(all_slots) == se.SHOP_COUNT * se.SHOP_SLOTS  # 32
    assert all_slots[0]["shop_index"] == 0 and all_slots[0]["slot_index"] == 0
    assert all_slots[-1]["shop_index"] == 7 and all_slots[-1]["slot_index"] == 3


def test_write_shop_slot_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    se.write_shop_slot(rom, 0, 0, base_price=99)
    dto = se.read_shop_slot(bytes(rom), 0, 0)
    assert dto["base_price"] == 99
    assert dto["item_code"] == 0x33  # unchanged


def test_write_shop_slot_item_code_independent(vanilla_rom):
    rom = bytearray(vanilla_rom)
    se.write_shop_slot(rom, 2, 3, item_code=0x10)
    dto = se.read_shop_slot(bytes(rom), 2, 3)
    assert dto["item_code"] == 0x10
    assert dto["base_price"] == 100  # unchanged


@pytest.mark.parametrize("bad_shop", [-1, 8, 99])
def test_invalid_shop_index(vanilla_rom, bad_shop):
    with pytest.raises(ValueError, match="shop_index must be"):
        se.read_shop_slot(vanilla_rom, bad_shop, 0)


@pytest.mark.parametrize("bad_slot", [-1, 4, 10])
def test_invalid_slot_index(vanilla_rom, bad_slot):
    with pytest.raises(ValueError, match="slot_index must be"):
        se.read_shop_slot(vanilla_rom, 0, bad_slot)


@pytest.mark.parametrize("field,bad", [
    ("item_code", -1), ("item_code", 256),
    ("base_price", -1), ("base_price", 256),
])
def test_shop_value_bounds(vanilla_rom, field, bad):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError):
        se.write_shop_slot(rom, 0, 0, **{field: bad})


# --- trooper recruitment cost ----------------------------------------------

def test_vanilla_trooper_cost(vanilla_rom):
    dto = se.read_trooper_cost(vanilla_rom)
    assert dto["cost"] == 100  # 0x64; 4 troopers for 100 rupias
    assert dto["rom_offset"] == "0x04577"


def test_write_trooper_cost_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    se.write_trooper_cost(rom, 200)
    assert se.read_trooper_cost(bytes(rom))["cost"] == 200


@pytest.mark.parametrize("bad", [-1, 256, 999])
def test_trooper_cost_bounds(vanilla_rom, bad):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="cost must be"):
        se.write_trooper_cost(rom, bad)
