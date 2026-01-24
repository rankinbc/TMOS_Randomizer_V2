"""Shop inventory randomization algorithm.

This module implements the shop randomization algorithm which:
- Randomizes which items appear in each shop
- Randomizes prices with configurable variance
- Preserves shop type distinctions (general vs magic)
- Excludes progression items (swords/rods)
- Ensures required items are available
"""

import random
from collections import defaultdict
from dataclasses import dataclass
from typing import Dict, List, Optional, Set

from ..core.shop_items import (
    REQUIRED_ITEMS,
    SHOP_ITEMS,
    ShopItem,
    ShopType,
    get_item_pool,
    get_shop_type,
    is_shop_content,
)
from ..core.shop_inventory import ChapterShopData, ShopInventory, ShopSlot
from ..io.config_loader import ShopRandomizationConfig


@dataclass
class ShopRandomizationResult:
    """Result of shop randomization for the game.

    Attributes:
        chapter_data: Dict mapping chapter number to ChapterShopData
        errors: List of validation error messages
        warnings: List of warning messages
    """

    chapter_data: Dict[int, ChapterShopData]
    errors: List[str]
    warnings: List[str]

    @property
    def is_valid(self) -> bool:
        """Check if randomization is valid (no errors)."""
        return len(self.errors) == 0

    @property
    def total_shops(self) -> int:
        """Total number of shops randomized."""
        return sum(data.shop_count for data in self.chapter_data.values())


def collect_shop_screens(game_world) -> Dict[int, List]:
    """Collect all shop screens from the game world.

    Args:
        game_world: GameWorld containing all chapters

    Returns:
        Dict mapping chapter number to list of shop screens
    """
    shops = defaultdict(list)

    for chapter in game_world:
        for screen in chapter:
            if is_shop_content(screen.content):
                shops[chapter.chapter_num].append(screen)

    return dict(shops)


def generate_shop_inventory(
    screen,
    config: ShopRandomizationConfig,
    rng: random.Random,
) -> ShopInventory:
    """Generate randomized inventory for a single shop.

    Args:
        screen: WorldScreen object for the shop
        config: Randomization configuration
        rng: Random number generator

    Returns:
        ShopInventory with 4 randomized items
    """
    shop_type = get_shop_type(screen.content)

    # Get eligible items for this shop type
    if config.preserve_shop_types:
        eligible_items = get_item_pool(shop_type, config.exclude_progression_items)
    else:
        # Mix all items if not preserving shop types
        eligible_items = list(SHOP_ITEMS.values())
        if config.exclude_progression_items:
            eligible_items = [item for item in eligible_items if not item.is_progression]

    # Ensure we have items to choose from
    if not eligible_items:
        eligible_items = list(SHOP_ITEMS.values())

    # Select 4 items (avoid duplicates)
    selected_items = []
    available = list(eligible_items)

    for slot_index in range(4):
        if not available:
            # Refill if we run out (allows duplicates as fallback)
            available = list(eligible_items)

        # Random selection
        item = rng.choice(available)
        available.remove(item)

        # Calculate price
        price = calculate_item_price(item, config, rng)

        # Determine quantity
        quantity = item.max_quantity if item.max_quantity > 0 else 0

        selected_items.append(
            ShopSlot(
                item=item,
                price=price,
                quantity=quantity,
                slot_index=slot_index,
            )
        )

    return ShopInventory(
        content_value=screen.content,
        chapter=screen.chapter,
        screen_index=screen.relative_index,
        shop_type=shop_type,
        items=selected_items,
        original_content=screen.content,
    )


def calculate_item_price(
    item: ShopItem,
    config: ShopRandomizationConfig,
    rng: random.Random,
) -> int:
    """Calculate randomized price for an item.

    Args:
        item: ShopItem to price
        config: Randomization configuration
        rng: Random number generator

    Returns:
        Randomized price in rupias
    """
    base_price = item.base_price

    if config.randomize_prices and config.price_variance > 0:
        # Apply variance
        min_mult = 1.0 - config.price_variance
        max_mult = 1.0 + config.price_variance
        variance = rng.uniform(min_mult, max_mult)
        price = int(base_price * variance)
    else:
        price = base_price

    # Apply global multiplier
    price = int(price * config.price_multiplier)

    # Ensure minimum price of 1
    return max(1, price)


def validate_chapter_shops(
    chapter_data: ChapterShopData,
    config: ShopRandomizationConfig,
) -> List[str]:
    """Validate shop inventories for a chapter.

    Args:
        chapter_data: ChapterShopData to validate
        config: Randomization configuration

    Returns:
        List of validation error messages
    """
    errors = []
    chapter = chapter_data.chapter_num

    # Get all items available in this chapter
    available_items = chapter_data.get_all_items()

    # Check required items
    if config.ensure_bread_available and "Bread" not in available_items:
        errors.append(f"Chapter {chapter}: Bread not available in any shop")

    if config.ensure_mashroob_available and "Mashroob" not in available_items:
        errors.append(f"Chapter {chapter}: Mashroob not available in any shop")

    if config.ensure_keys_available and "Key" not in available_items:
        errors.append(f"Chapter {chapter}: Key not available in any shop")

    return errors


def ensure_required_items(
    chapter_data: ChapterShopData,
    config: ShopRandomizationConfig,
    rng: random.Random,
) -> None:
    """Ensure required items are available in the chapter.

    Modifies chapter_data in place to add missing required items.

    Args:
        chapter_data: ChapterShopData to modify
        config: Randomization configuration
        rng: Random number generator
    """
    if not chapter_data.inventories:
        return

    available_items = chapter_data.get_all_items()
    missing = []

    if config.ensure_bread_available and "Bread" not in available_items:
        missing.append(SHOP_ITEMS["Bread"])

    if config.ensure_mashroob_available and "Mashroob" not in available_items:
        missing.append(SHOP_ITEMS["Mashroob"])

    if config.ensure_keys_available and "Key" not in available_items:
        missing.append(SHOP_ITEMS["Key"])

    # Add missing items to random shop slots
    for item in missing:
        # Pick a random shop
        inventory = rng.choice(chapter_data.inventories)

        # Replace a random slot
        slot_index = rng.randint(0, 3)
        price = calculate_item_price(item, config, rng)

        inventory.items[slot_index] = ShopSlot(
            item=item,
            price=price,
            quantity=item.max_quantity if item.max_quantity > 0 else 0,
            slot_index=slot_index,
        )


def randomize_all_shops(
    game_world,
    config: ShopRandomizationConfig,
    rng: random.Random,
) -> ShopRandomizationResult:
    """Randomize all shop inventories in the game.

    Args:
        game_world: GameWorld containing all chapters
        config: Randomization configuration
        rng: Random number generator

    Returns:
        ShopRandomizationResult with all chapter data
    """
    if not config.enabled:
        return ShopRandomizationResult(
            chapter_data={},
            errors=[],
            warnings=["Shop randomization is disabled"],
        )

    # Collect all shop screens
    shop_screens = collect_shop_screens(game_world)

    chapter_data = {}
    all_errors = []
    all_warnings = []

    # Process each chapter
    for chapter_num, screens in shop_screens.items():
        inventories = []

        for screen in screens:
            inventory = generate_shop_inventory(screen, config, rng)
            inventories.append(inventory)

        data = ChapterShopData(
            chapter_num=chapter_num,
            inventories=inventories,
        )

        # Ensure required items are available
        ensure_required_items(data, config, rng)

        # Validate
        errors = validate_chapter_shops(data, config)
        all_errors.extend(errors)

        chapter_data[chapter_num] = data

    # Generate warnings for chapters without shops
    for chapter_num in range(1, 6):
        if chapter_num not in chapter_data:
            all_warnings.append(f"Chapter {chapter_num}: No shops found")

    return ShopRandomizationResult(
        chapter_data=chapter_data,
        errors=all_errors,
        warnings=all_warnings,
    )


def randomize_chapter_shops(
    chapter,
    config: ShopRandomizationConfig,
    rng: random.Random,
) -> ChapterShopData:
    """Randomize shop inventories for a single chapter.

    Args:
        chapter: Chapter object to randomize
        config: Randomization configuration
        rng: Random number generator

    Returns:
        ChapterShopData with randomized inventories
    """
    inventories = []

    for screen in chapter:
        if is_shop_content(screen.content):
            inventory = generate_shop_inventory(screen, config, rng)
            inventories.append(inventory)

    data = ChapterShopData(
        chapter_num=chapter.chapter_num,
        inventories=inventories,
    )

    # Ensure required items
    ensure_required_items(data, config, rng)

    return data
