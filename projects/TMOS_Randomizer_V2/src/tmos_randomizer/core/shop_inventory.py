"""Shop inventory data structures for randomization.

This module provides:
- ShopSlot: Single item slot in a shop
- ShopInventory: Complete inventory for a shop screen
"""

from dataclasses import dataclass, field
from typing import List, Optional

from .shop_items import ShopItem, ShopType


@dataclass
class ShopSlot:
    """Single item slot in a shop inventory.

    Attributes:
        item: The ShopItem in this slot
        price: Randomized price (may differ from base_price)
        quantity: Stock quantity (0 = unlimited)
        slot_index: Position in shop menu (0-3)
    """

    item: ShopItem
    price: int
    quantity: int = 0
    slot_index: int = 0

    def to_dict(self) -> dict:
        """Serialize for spoiler log."""
        return {
            "name": self.item.name,
            "item_id": self.item.item_id,
            "price": self.price,
            "quantity": self.quantity,
            "slot": self.slot_index,
        }


@dataclass
class ShopInventory:
    """Complete inventory for a shop screen.

    Attributes:
        content_value: WorldScreen Content byte (0x60-0x7D)
        chapter: Chapter number (1-5)
        screen_index: Screen index within chapter
        shop_type: Type of shop (GENERAL or MAGIC)
        items: List of 4 ShopSlot objects
        original_content: Original Content value before randomization
    """

    content_value: int
    chapter: int
    screen_index: int
    shop_type: ShopType
    items: List[ShopSlot] = field(default_factory=list)
    original_content: Optional[int] = None

    @property
    def shop_id(self) -> str:
        """Unique identifier for this shop."""
        return f"shop_ch{self.chapter}_scr{self.screen_index}"

    @property
    def item_count(self) -> int:
        """Number of items in this shop."""
        return len(self.items)

    def get_item_names(self) -> List[str]:
        """Get list of item names in this shop."""
        return [slot.item.name for slot in self.items]

    def has_item(self, item_name: str) -> bool:
        """Check if shop sells a specific item."""
        return item_name in self.get_item_names()

    def to_dict(self) -> dict:
        """Serialize for spoiler log."""
        return {
            "shop_id": self.shop_id,
            "chapter": self.chapter,
            "screen_index": self.screen_index,
            "content_value": f"0x{self.content_value:02X}",
            "shop_type": self.shop_type.name,
            "items": [slot.to_dict() for slot in self.items],
        }

    def to_rom_bytes(self) -> bytes:
        """DISABLED — the byte layout this method produced is wrong for 0xD544.

        The ROM table at 0xD544 is the inventory cap table (8 x 4-byte entries
        of [ram_addr_lo, 0x03, max_cap, slot_idx]), NOT a shop slot table.
        Writing [item_id, quantity, price_lo, price_hi] there corrupts both
        the cap table and the adjacent 6502 code at bank 3 $9564+.

        See TMOS_AI/docs/human/items-economy-re-answers.md for the RE finding.
        For editing inventory caps, use tmos_randomizer.core.inventory_caps.write_cap().
        Real per-shop pricing lives in an undecoded Bank 2 bytecode interpreter.
        """
        raise NotImplementedError(
            "ShopInventory.to_rom_bytes is disabled: the target table at 0xD544 "
            "is the inventory cap table, not shop slots. "
            "Use tmos_randomizer.core.inventory_caps.write_cap() to edit caps. "
            "See TMOS_AI/docs/human/items-economy-re-answers.md."
        )


@dataclass
class ChapterShopData:
    """All shop data for a chapter.

    Attributes:
        chapter_num: Chapter number (1-5)
        inventories: List of ShopInventory objects
    """

    chapter_num: int
    inventories: List[ShopInventory] = field(default_factory=list)

    @property
    def shop_count(self) -> int:
        """Number of shops in this chapter."""
        return len(self.inventories)

    def get_all_items(self) -> set[str]:
        """Get set of all item names available in this chapter's shops."""
        items = set()
        for inv in self.inventories:
            items.update(inv.get_item_names())
        return items

    def has_required_items(self, required: set[str]) -> bool:
        """Check if all required items are available somewhere."""
        available = self.get_all_items()
        return required.issubset(available)

    def to_dict(self) -> dict:
        """Serialize for spoiler log."""
        return {
            "chapter": self.chapter_num,
            "shop_count": self.shop_count,
            "shops": [inv.to_dict() for inv in self.inventories],
        }
