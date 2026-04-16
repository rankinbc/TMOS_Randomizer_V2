"""Tests for core/items.py.

Verifies:
- GAMEPLAY_ITEMS and BATTLE_ITEMS are each a complete 0..29 ID space.
- GAMEPLAY_ITEMS ram_addresses (where set) point at documented $03xx labels.
- The two namespaces are demonstrably distinct (same ID, different name).
- No duplicate IDs or names within a namespace.
- Enum values are lowercase strings (UI contract).
"""

from tmos_randomizer.core.items import (
    BATTLE_ITEMS,
    BattleItem,
    GAMEPLAY_ITEMS,
    GameplayItem,
    ItemCategory,
    find_battle_item_by_name,
    find_gameplay_item_by_name,
    get_gameplay_items_by_category,
)
from tmos_randomizer.core.inventory_caps import RAM_LABELS


# =============================================================================
# Shape / completeness
# =============================================================================

def test_gameplay_items_cover_0_to_29():
    assert set(GAMEPLAY_ITEMS.keys()) == set(range(30))


def test_battle_items_cover_0_to_29():
    assert set(BATTLE_ITEMS.keys()) == set(range(30))


def test_gameplay_item_ids_match_keys():
    for key, item in GAMEPLAY_ITEMS.items():
        assert item.id == key, f"GAMEPLAY_ITEMS[{key}].id == {item.id}"


def test_battle_item_ids_match_keys():
    for key, item in BATTLE_ITEMS.items():
        assert item.id == key, f"BATTLE_ITEMS[{key}].id == {item.id}"


def test_gameplay_names_unique():
    names = [item.name for item in GAMEPLAY_ITEMS.values()]
    assert len(names) == len(set(names)), f"Duplicate names in GAMEPLAY_ITEMS: {names}"


def test_battle_names_unique_except_blanks():
    names = [item.name for item in BATTLE_ITEMS.values()
             if item.name not in ("(null)", "(blank)")]
    assert len(names) == len(set(names)), f"Duplicate names in BATTLE_ITEMS: {names}"


# =============================================================================
# RAM address cross-reference
# =============================================================================

def test_gameplay_ram_addresses_match_inventory_caps_labels():
    """Every GAMEPLAY_ITEMS ram_address (where set) must be a documented $03xx."""
    for item in GAMEPLAY_ITEMS.values():
        if item.ram_address is None:
            continue
        assert item.ram_address in RAM_LABELS, (
            f"Item {item.name!r} claims ram_address ${item.ram_address:04X} "
            f"but that address is not in inventory_caps.RAM_LABELS"
        )


def test_key_has_correct_ram_address():
    """Regression: Key was previously claimed at $0300 (Gortrat bread). Should be $0308."""
    key = GAMEPLAY_ITEMS[6]
    assert key.name == "Key"
    assert key.ram_address == 0x0308


def test_amulet_has_ram_address():
    """Regression: Amulet had no ram_address in old hardcodes. Should be $0309."""
    amulet = GAMEPLAY_ITEMS[0]
    assert amulet.name == "Amulet"
    assert amulet.ram_address == 0x0309


def test_carpet_hammer_horn_rseed_have_no_ram_address():
    """These items are managed by the Bank 2 bytecode interpreter, not $03xx."""
    for id_, expected_name in [(2, "Carpet"), (3, "Hammer"), (4, "Horn"), (10, "R.Seed")]:
        item = GAMEPLAY_ITEMS[id_]
        assert item.name == expected_name
        assert item.ram_address is None, (
            f"{item.name} should have no fixed $03xx address (Bank 2 bytecode), "
            f"got ${item.ram_address:04X}"
        )


# =============================================================================
# Namespace separation
# =============================================================================

def test_namespaces_are_distinct_at_id_1():
    """ID 1 is Bread in GAMEPLAY, ROD in BATTLE. Proves separate namespaces."""
    assert GAMEPLAY_ITEMS[1].name == "Bread"
    assert BATTLE_ITEMS[1].name == "ROD"


def test_namespaces_are_distinct_at_id_17():
    """ID 17 is Ring in GAMEPLAY, CARPET in BATTLE."""
    assert GAMEPLAY_ITEMS[17].name == "Ring"
    assert BATTLE_ITEMS[17].name == "CARPET"


def test_namespaces_are_distinct_at_id_6():
    """ID 6 is Key in GAMEPLAY, ISFA in BATTLE."""
    assert GAMEPLAY_ITEMS[6].name == "Key"
    assert BATTLE_ITEMS[6].name == "ISFA"


# =============================================================================
# Category enum
# =============================================================================

def test_item_category_values_are_lowercase_strings():
    """UI contract: category serializes as lowercase string."""
    for cat in ItemCategory:
        assert cat.value == cat.value.lower(), f"{cat} is not lowercase"
        assert isinstance(cat.value, str)


def test_all_gameplay_categories_accounted_for():
    """Every GAMEPLAY_ITEM has a category from the ItemCategory enum."""
    for item in GAMEPLAY_ITEMS.values():
        assert isinstance(item.category, ItemCategory)


def test_expected_id_ranges_by_category():
    """ID ranges match core/items.py layout: 0-11 consumable/special,
    12-17 equipment, 18-29 progression."""
    for id_ in range(0, 12):
        cat = GAMEPLAY_ITEMS[id_].category
        assert cat in (ItemCategory.CONSUMABLE, ItemCategory.SPECIAL), (
            f"ID {id_} ({GAMEPLAY_ITEMS[id_].name}) has unexpected category {cat}"
        )
    for id_ in range(12, 18):
        assert GAMEPLAY_ITEMS[id_].category == ItemCategory.EQUIPMENT
    for id_ in range(18, 30):
        assert GAMEPLAY_ITEMS[id_].category == ItemCategory.PROGRESSION


# =============================================================================
# Accessors
# =============================================================================

def test_get_gameplay_items_by_category_returns_sorted():
    equipment = get_gameplay_items_by_category(ItemCategory.EQUIPMENT)
    assert len(equipment) == 6
    assert [i.id for i in equipment] == [12, 13, 14, 15, 16, 17]


def test_find_gameplay_item_by_name_is_case_insensitive():
    assert find_gameplay_item_by_name("BREAD").id == 1
    assert find_gameplay_item_by_name("bread").id == 1
    assert find_gameplay_item_by_name("Bread").id == 1


def test_find_gameplay_item_by_name_returns_none_for_missing():
    assert find_gameplay_item_by_name("Nonsense") is None


def test_find_battle_item_by_name_is_case_insensitive():
    assert find_battle_item_by_name("ROD").id == 1
    assert find_battle_item_by_name("rod").id == 1


# =============================================================================
# Battle table specific
# =============================================================================

def test_battle_sword_handler_addresses_are_in_bank6_range():
    """Swords at IDs 9-14 have handlers at $8E3D or $8ECE (both in Bank 6)."""
    for id_ in range(9, 15):
        item = BATTLE_ITEMS[id_]
        assert item.handler_addr in (0x8E3D, 0x8ECE), (
            f"Sword {item.name} handler ${item.handler_addr:04X} not in expected set"
        )


def test_battle_rod_count_addrs_match_gameplay_ram():
    """BATTLE_ITEMS 1/2/3 (ROD/FLAME/STARDUST) count_addr matches the RAM addresses
    we know from the inventory cap table."""
    assert BATTLE_ITEMS[1].count_addr == 0x030F  # ROD
    assert BATTLE_ITEMS[2].count_addr == 0x0310  # FLAME
    assert BATTLE_ITEMS[3].count_addr == 0x0311  # STARDUST
