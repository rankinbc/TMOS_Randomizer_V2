"""Tripwire: patch_rom(..., shop_data=...) must raise without writing the output file.

Integration-level guard complementing the unit tripwires in
tests/test_io/test_rom_writer_no_corruption.py. Verifies the convenience
function refuses shop_data early, before opening or saving the ROM.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.shop_inventory import (
    ChapterShopData,
    ShopInventory,
    ShopSlot,
)
from tmos_randomizer.core.shop_items import ItemCategory, ShopItem, ShopType
from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.io.rom_writer import patch_rom


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(
    not ROM_PATH.exists(),
    reason=f"ROM file not found at {ROM_PATH}",
)


def _dummy_chapter_data() -> ChapterShopData:
    item = ShopItem(
        item_id=1, name="Bread", base_price=20,
        category=ItemCategory.CONSUMABLE,
        shop_types=frozenset({ShopType.GENERAL}),
    )
    inv = ShopInventory(
        content_value=0x60, chapter=1, screen_index=0,
        shop_type=ShopType.GENERAL,
        items=[ShopSlot(item=item, price=20, quantity=0, slot_index=0)],
    )
    return ChapterShopData(chapter_num=1, inventories=[inv])


def test_patch_rom_with_shop_data_raises(tmp_path):
    """Passing shop_data must raise NotImplementedError before any file I/O."""
    world = load_rom(ROM_PATH)
    output_path = tmp_path / "patched.nes"
    with pytest.raises(NotImplementedError):
        patch_rom(ROM_PATH, output_path, world, shop_data={1: _dummy_chapter_data()})


def test_patch_rom_does_not_write_output_when_shop_data_present(tmp_path):
    """Guard fires before writer.save() — the output file must not exist."""
    world = load_rom(ROM_PATH)
    output_path = tmp_path / "patched.nes"
    assert not output_path.exists()
    with pytest.raises(NotImplementedError):
        patch_rom(ROM_PATH, output_path, world, shop_data={1: _dummy_chapter_data()})
    assert not output_path.exists(), (
        "patch_rom wrote an output file despite raising — guard is in the wrong place"
    )


def test_patch_rom_without_shop_data_writes_output(tmp_path):
    """Smoke test: the happy path (shop_data=None) still works end-to-end."""
    world = load_rom(ROM_PATH)
    output_path = tmp_path / "patched.nes"
    result = patch_rom(ROM_PATH, output_path, world, shop_data=None)
    assert output_path.exists()
    assert output_path.stat().st_size == ROM_PATH.stat().st_size
    assert result["shops"] == 0


def test_patch_rom_error_message_points_to_re_doc(tmp_path):
    world = load_rom(ROM_PATH)
    output_path = tmp_path / "patched.nes"
    with pytest.raises(NotImplementedError) as excinfo:
        patch_rom(ROM_PATH, output_path, world, shop_data={1: _dummy_chapter_data()})
    assert "items-economy-re-answers.md" in str(excinfo.value)
