"""Shop item definitions for shop inventory randomization.

This module provides:
- ShopType enum for categorizing shops (general vs magic)
- ShopItem dataclass for item metadata
- Item registry with base prices and shop type assignments
"""

from dataclasses import dataclass
from enum import Enum, auto
from typing import Set


class ShopType(Enum):
    """Type of shop based on Content byte value."""

    GENERAL = auto()  # 0x60-0x66 - sells consumables, equipment
    MAGIC = auto()  # 0x75-0x79 - sells magic items, formations


class ItemCategory(Enum):
    """Category of shop item."""

    CONSUMABLE = auto()  # Bread, Mashroob, Key, etc.
    EQUIPMENT = auto()  # Armor, Robe, Shield, etc.
    MAGIC_ITEM = auto()  # Amulet, etc.
    PROGRESSION = auto()  # Swords, Rods (excluded from shops)


@dataclass(frozen=True)
class ShopItem:
    """Definition of an item that can appear in shops.

    Attributes:
        item_id: ROM item ID (0-29)
        name: Display name
        base_price: Default price in rupias
        category: Item category
        shop_types: Set of shop types that can sell this item
        is_progression: If True, excluded from shop randomization
        max_quantity: Maximum stack size in shop (0 = unlimited)
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


# Content value ranges for shop types
GENERAL_SHOP_RANGE = range(0x60, 0x67)  # 0x60-0x66
MAGIC_SHOP_RANGE = range(0x75, 0x7A)  # 0x75-0x79
UNUSED_SHOP_RANGE = range(0x7B, 0x7E)  # 0x7B-0x7D


def get_shop_type(content: int) -> ShopType:
    """Determine shop type from Content byte value.

    Args:
        content: WorldScreen Content byte

    Returns:
        ShopType enum value
    """
    if content in GENERAL_SHOP_RANGE:
        return ShopType.GENERAL
    elif content in MAGIC_SHOP_RANGE:
        return ShopType.MAGIC
    elif content in UNUSED_SHOP_RANGE:
        return ShopType.GENERAL  # Treat unused as general
    else:
        return ShopType.GENERAL  # Default


def is_shop_content(content: int) -> bool:
    """Check if Content byte indicates a shop.

    Args:
        content: WorldScreen Content byte

    Returns:
        True if this is a shop screen
    """
    return (
        content in GENERAL_SHOP_RANGE
        or content in MAGIC_SHOP_RANGE
        or content in UNUSED_SHOP_RANGE
    )


# =============================================================================
# Item Registry
# =============================================================================

# Helper to create frozenset for shop_types
_GENERAL = frozenset({ShopType.GENERAL})
_MAGIC = frozenset({ShopType.MAGIC})
_BOTH = frozenset({ShopType.GENERAL, ShopType.MAGIC})

# All shop items with their properties
SHOP_ITEMS: dict[str, ShopItem] = {
    # Consumables (General shops)
    "Bread": ShopItem(
        item_id=1,
        name="Bread",
        base_price=20,
        category=ItemCategory.CONSUMABLE,
        shop_types=_GENERAL,
        max_quantity=10,
    ),
    "Mashroob": ShopItem(
        item_id=8,
        name="Mashroob",
        base_price=30,
        category=ItemCategory.CONSUMABLE,
        shop_types=_BOTH,
        max_quantity=10,
    ),
    "Key": ShopItem(
        item_id=6,
        name="Key",
        base_price=15,
        category=ItemCategory.CONSUMABLE,
        shop_types=_GENERAL,
        max_quantity=9,
    ),
    "Horn": ShopItem(
        item_id=4,
        name="Horn",
        base_price=40,
        category=ItemCategory.CONSUMABLE,
        shop_types=_GENERAL,
        max_quantity=5,
    ),
    "Carpet": ShopItem(
        item_id=2,
        name="Carpet",
        base_price=60,
        category=ItemCategory.CONSUMABLE,
        shop_types=_GENERAL,
        max_quantity=15,
    ),
    "RSeed": ShopItem(
        item_id=10,
        name="R.Seed",
        base_price=100,
        category=ItemCategory.CONSUMABLE,
        shop_types=_GENERAL,
        max_quantity=5,
    ),
    "Hammer": ShopItem(
        item_id=3,
        name="Hammer",
        base_price=50,
        category=ItemCategory.CONSUMABLE,
        shop_types=_GENERAL,
        max_quantity=5,
    ),
    # Equipment (General shops)
    "RArmor": ShopItem(
        item_id=16,
        name="R.Armor",
        base_price=150,
        category=ItemCategory.EQUIPMENT,
        shop_types=_GENERAL,
    ),
    # Equipment (Magic shops)
    "HolyRobe": ShopItem(
        item_id=12,
        name="HolyRobe",
        base_price=200,
        category=ItemCategory.EQUIPMENT,
        shop_types=_MAGIC,
    ),
    "MShield": ShopItem(
        item_id=15,
        name="M.Shield",
        base_price=180,
        category=ItemCategory.EQUIPMENT,
        shop_types=_MAGIC,
    ),
    "Ring": ShopItem(
        item_id=17,
        name="Ring",
        base_price=250,
        category=ItemCategory.EQUIPMENT,
        shop_types=_MAGIC,
    ),
    "MBoots": ShopItem(
        item_id=14,
        name="M.Boots",
        base_price=300,
        category=ItemCategory.EQUIPMENT,
        shop_types=_MAGIC,
    ),
    # Magic Items
    "Amulet": ShopItem(
        item_id=0,
        name="Amulet",
        base_price=80,
        category=ItemCategory.MAGIC_ITEM,
        shop_types=_MAGIC,
    ),
}

# Items that must always be available somewhere in each chapter
REQUIRED_ITEMS = {"Bread", "Mashroob", "Key"}

# Progression items (excluded from shop randomization)
PROGRESSION_ITEMS: dict[str, ShopItem] = {
    # Swords
    "Sword": ShopItem(24, "Sword", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Simitar": ShopItem(25, "Simitar", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Dragoon": ShopItem(26, "Dragoon", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Kashim": ShopItem(27, "Kashim", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Rostam": ShopItem(28, "Rostam", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Legend": ShopItem(29, "Legend", 0, ItemCategory.PROGRESSION, frozenset(), True),
    # Rods
    "Rod": ShopItem(18, "Rod", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Flame": ShopItem(19, "Flame", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Stardust": ShopItem(20, "Stardust", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Cimaron": ShopItem(21, "Cimaron", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Crystal": ShopItem(22, "Crystal", 0, ItemCategory.PROGRESSION, frozenset(), True),
    "Isfa": ShopItem(23, "Isfa", 0, ItemCategory.PROGRESSION, frozenset(), True),
    # Special equipment
    "LArmor": ShopItem(13, "L.Armor", 0, ItemCategory.PROGRESSION, frozenset(), True),
}


def get_item_pool(shop_type: ShopType, exclude_progression: bool = True) -> list[ShopItem]:
    """Get list of items that can appear in the given shop type.

    Args:
        shop_type: Type of shop to get items for
        exclude_progression: If True, exclude progression items

    Returns:
        List of ShopItem objects valid for this shop type
    """
    items = []
    for item in SHOP_ITEMS.values():
        if item.can_appear_in(shop_type):
            if not exclude_progression or not item.is_progression:
                items.append(item)
    return items


def get_all_items(exclude_progression: bool = True) -> list[ShopItem]:
    """Get all shop items.

    Args:
        exclude_progression: If True, exclude progression items

    Returns:
        List of all ShopItem objects
    """
    if exclude_progression:
        return [item for item in SHOP_ITEMS.values() if not item.is_progression]
    return list(SHOP_ITEMS.values())
