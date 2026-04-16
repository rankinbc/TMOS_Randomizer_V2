"""Tripwires: shop writers must raise NotImplementedError and leave ROM untouched.

Guards against a future contributor "fixing" the disabled writers by replacing
the raise with code that writes into the 0xD544 inventory cap table — the
exact corruption mode this remediation was built to prevent.

Background: core/shop_inventory.py::to_rom_bytes() and ROMWriter.write_shop_*
methods were disabled in Phase 0 after RE showed the 0xD544 table is an
inventory cap table, not a shop slot table. Writing [item_id, qty, price_lo,
price_hi] records there corrupts both the caps and the adjacent inv_pickup_handler
code. See TMOS_AI/docs/human/items-economy-re-answers.md.
"""

from __future__ import annotations

import hashlib
from pathlib import Path

import pytest

from tmos_randomizer.core.shop_inventory import (
    ChapterShopData,
    ShopInventory,
    ShopSlot,
)
from tmos_randomizer.core.shop_items import ShopItem, ShopType, ItemCategory
from tmos_randomizer.io.rom_writer import ROMWriter


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def _dummy_shop_item() -> ShopItem:
    return ShopItem(
        item_id=1, name="Bread", base_price=20,
        category=ItemCategory.CONSUMABLE,
        shop_types=frozenset({ShopType.GENERAL}),
    )


def _dummy_shop_inventory() -> ShopInventory:
    item = _dummy_shop_item()
    return ShopInventory(
        content_value=0x60, chapter=1, screen_index=0,
        shop_type=ShopType.GENERAL,
        items=[ShopSlot(item=item, price=20, quantity=0, slot_index=0)],
    )


def _dummy_chapter_data() -> ChapterShopData:
    return ChapterShopData(
        chapter_num=1, inventories=[_dummy_shop_inventory()]
    )


def test_write_shop_inventory_raises(vanilla_rom):
    writer = ROMWriter(vanilla_rom)
    with pytest.raises(NotImplementedError):
        writer.write_shop_inventory(_dummy_shop_inventory(), shop_index=0)


def test_write_chapter_shops_raises(vanilla_rom):
    writer = ROMWriter(vanilla_rom)
    with pytest.raises(NotImplementedError):
        writer.write_chapter_shops(_dummy_chapter_data(), start_index=0)


def test_write_all_shops_raises(vanilla_rom):
    writer = ROMWriter(vanilla_rom)
    with pytest.raises(NotImplementedError):
        writer.write_all_shops({1: _dummy_chapter_data()})


def test_to_rom_bytes_raises():
    inv = _dummy_shop_inventory()
    with pytest.raises(NotImplementedError):
        inv.to_rom_bytes()


def test_rom_bytes_unchanged_after_failed_write(vanilla_rom):
    """Hash check: the ROM buffer must be bit-identical to vanilla after a raise."""
    writer = ROMWriter(vanilla_rom)
    before = hashlib.sha256(writer.data).hexdigest()
    for attempt in (
        lambda: writer.write_shop_inventory(_dummy_shop_inventory(), 0),
        lambda: writer.write_chapter_shops(_dummy_chapter_data()),
        lambda: writer.write_all_shops({1: _dummy_chapter_data()}),
    ):
        with pytest.raises(NotImplementedError):
            attempt()
    after = hashlib.sha256(writer.data).hexdigest()
    assert before == after, "Shop writer modified ROM bytes before raising"


def test_error_messages_point_to_re_doc(vanilla_rom):
    """Error messages must reference the RE doc so future maintainers find context."""
    writer = ROMWriter(vanilla_rom)

    with pytest.raises(NotImplementedError) as excinfo:
        writer.write_shop_inventory(_dummy_shop_inventory(), 0)
    assert "items-economy-re-answers.md" in str(excinfo.value)

    with pytest.raises(NotImplementedError) as excinfo:
        _dummy_shop_inventory().to_rom_bytes()
    assert "items-economy-re-answers.md" in str(excinfo.value)
