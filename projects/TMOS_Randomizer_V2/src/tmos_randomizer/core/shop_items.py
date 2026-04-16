"""Shop item dataclasses (legacy — registries removed 2026-04-16).

Historical: this module housed a fabricated SHOP_ITEMS registry built on a
misinterpretation of the 0xD544 table. That table is actually the inventory
cap table (see core/inventory_caps.py), not shop slot data. The registries
and helper functions (SHOP_ITEMS, PROGRESSION_ITEMS, REQUIRED_ITEMS,
get_item_pool, get_all_items, get_shop_type, is_shop_content) were deleted
because:

  - The ID assignments were fabricated, not ROM-sourced.
  - The one real consumer was logic/shop_randomization.py, which is now
    ImportError-gated pending Bank 2 bytecode RE.
  - get_shop_type / is_shop_content are duplicated in core/enums.py.

The dataclasses below remain because core/shop_inventory.py's ShopSlot /
ShopInventory dataclasses still reference them for type hints (those
dataclasses survive disabled-for-now but may serve a future real shop
implementation once Bank 2 bytecode is decoded).

For the live item registry, see core/items.py (GAMEPLAY_ITEMS + BATTLE_ITEMS).
See also TMOS_AI/docs/human/items-economy-re-answers.md.
"""

from dataclasses import dataclass
from enum import Enum, auto


class ShopType(Enum):
    """Type of shop based on Content byte value."""

    GENERAL = auto()  # 0x60-0x66 - sells consumables, equipment
    MAGIC = auto()  # 0x75-0x79 - sells magic items, formations


class ItemCategory(Enum):
    """Category of shop item (used by ShopItem dataclass).

    NOTE: this is distinct from core/items.py::ItemCategory. This enum
    exists solely to preserve the ShopItem dataclass shape used by the
    disabled shop pipeline.
    """

    CONSUMABLE = auto()
    EQUIPMENT = auto()
    MAGIC_ITEM = auto()
    PROGRESSION = auto()


@dataclass(frozen=True)
class ShopItem:
    """Definition of an item as carried by ShopSlot / ShopInventory.

    The shop pipeline is currently disabled; this dataclass is preserved
    for type compatibility with core/shop_inventory.py.
    """

    item_id: int
    name: str
    base_price: int
    category: ItemCategory
    shop_types: frozenset  # frozenset[ShopType] for hashability
    is_progression: bool = False
    max_quantity: int = 0

    def can_appear_in(self, shop_type: ShopType) -> bool:
        """Check if this item can appear in the given shop type."""
        return shop_type in self.shop_types
