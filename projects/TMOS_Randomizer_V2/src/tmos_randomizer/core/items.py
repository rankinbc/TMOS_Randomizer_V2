"""Item registries for TMOS.

This module deliberately keeps **two separate item-ID namespaces**, because
the game itself uses two different ID spaces in two different subsystems.
DO NOT conflate or collapse them.

Namespace 1: GAMEPLAY_ITEMS (0..29)
    The menu/HUD ID space. This is what the pause menu inventory grid,
    the item sprites in the overworld, and most user-visible displays use.
    IDs come from the game's knowledge base (knowledge/enums/items.md).
    ram_address, where set, points to the $03xx inventory variable that
    tracks the item's count (cross-referenced against
    tmos_randomizer.core.inventory_caps.RAM_LABELS).

Namespace 2: BATTLE_ITEMS (0..29)
    The equipment/battle ID space used by the Bank 6 $98E8 item table
    (30 records x 8 bytes each, documented at RETMOS/REVERSE.md:1747-1788).
    The game reads this table for pickup dispatch, equipment handling,
    RPG-battle item use, and spell/quest event triggers. IDs in this
    space do not match the GAMEPLAY_ITEMS space (e.g. ID 1 is BREAD in
    GAMEPLAY_ITEMS but ROD in BATTLE_ITEMS).

The two namespaces are independent. There is no runtime conversion between
them that we've found. If you need the gameplay ID for a battle-table entry
or vice versa, look it up by name, not by ID.

References:
    - RETMOS/REVERSE.md lines 1620-1810 (RAM map + Bank 6 $98E8 table)
    - TMOS_AI/docs/human/items-economy-re-answers.md (unification rationale)
    - tmos_randomizer.core.inventory_caps.RAM_LABELS
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Optional


class ItemCategory(str, Enum):
    CONSUMABLE = "consumable"
    EQUIPMENT = "equipment"
    PROGRESSION = "progression"
    SPECIAL = "special"      # world-drop or non-inventory (Rupia, MoneyBag)


@dataclass(frozen=True)
class GameplayItem:
    """An item in the menu/HUD namespace (GAMEPLAY_ITEMS)."""
    id: int
    name: str
    category: ItemCategory
    effect: str
    max_count: Optional[int] = None          # caps that are user-visible in HUD
    ram_address: Optional[int] = None        # $03xx inventory variable, if any
    chapter: Optional[int] = None            # progression chapter (0=start)


@dataclass(frozen=True)
class BattleItem:
    """A record from the Bank 6 $98E8 item table.

    Fields map to the 8-byte record format:
        byte 0 = item_id
        byte 1 = pickup sound
        byte 2 = flags (bit 4=HP cost, bit 6=skip display, bit 7=skip, $FE=one-time)
        bytes 3-4 = handler pointer (LE, in Bank 6)
        byte 5 = unused
        bytes 6-7 = sub-type / parameter
    """
    id: int
    name: str
    pickup_sound: int
    flags: int
    handler_addr: Optional[int]     # CPU address in Bank 6, None if no handler
    count_addr: Optional[int]        # $03xx or $05xx RAM addr, None if one-time
    notes: str = ""


# =============================================================================
# GAMEPLAY_ITEMS — menu/HUD namespace (IDs 0..29)
# =============================================================================
#
# ram_address corrections (2026-04-16): the prior ItemsView.tsx hardcodes
# had bogus addresses for Carpet/Hammer/Horn/R.Seed/Key — those were carried
# over from the misinterpretation of the 0xD544 table. Corrected against
# RETMOS/REVERSE.md lines 1620-1810.

GAMEPLAY_ITEMS: dict[int, GameplayItem] = {
    # Consumables (0-11) ----------------------------------------------------
    0: GameplayItem(
        id=0, name="Amulet", category=ItemCategory.CONSUMABLE,
        effect="Protects from wizard transformation",
        max_count=9, ram_address=0x0309,
    ),
    1: GameplayItem(
        id=1, name="Bread", category=ItemCategory.CONSUMABLE,
        effect="Auto-restore 50 HP on death",
        max_count=10, ram_address=0x0306,
    ),
    2: GameplayItem(
        id=2, name="Carpet", category=ItemCategory.CONSUMABLE,
        effect="Warp to towns / escape dungeon",
        # No fixed $03xx RAM address — managed by Bank 2 bytecode interpreter.
        max_count=None, ram_address=None,
    ),
    3: GameplayItem(
        id=3, name="Hammer", category=ItemCategory.CONSUMABLE,
        effect="Stars hit all enemies",
        max_count=None, ram_address=None,  # Bank 2 bytecode
    ),
    4: GameplayItem(
        id=4, name="Horn", category=ItemCategory.CONSUMABLE,
        effect="Disable gargoyles",
        max_count=None, ram_address=None,  # Bank 2 bytecode
    ),
    5: GameplayItem(
        id=5, name="HP Drink", category=ItemCategory.CONSUMABLE,
        effect="HP restoration (rare drop)",
    ),
    6: GameplayItem(
        id=6, name="Key", category=ItemCategory.CONSUMABLE,
        effect="Open palace doors; auto-DEC on use at $F2CB",
        max_count=9, ram_address=0x0308,
    ),
    7: GameplayItem(
        id=7, name="Map", category=ItemCategory.CONSUMABLE,
        effect="Show palace layout",
    ),
    8: GameplayItem(
        id=8, name="Mashroob", category=ItemCategory.CONSUMABLE,
        effect="Auto-restore 50 MP when empty",
        max_count=10, ram_address=0x0307,
    ),
    9: GameplayItem(
        id=9, name="Money Bag", category=ItemCategory.SPECIAL,
        effect="Large Rupia drop",
    ),
    10: GameplayItem(
        id=10, name="R.Seed", category=ItemCategory.CONSUMABLE,
        effect="Plant for money / invisibility",
        max_count=None, ram_address=None,  # Bank 2 bytecode
    ),
    11: GameplayItem(
        id=11, name="Rupia", category=ItemCategory.SPECIAL,
        effect="Currency pickup",
    ),

    # Equipment (12-17) ----------------------------------------------------
    12: GameplayItem(
        id=12, name="Holy Robe", category=ItemCategory.EQUIPMENT,
        effect="Survive lava at north cape; always available (boolean)",
        max_count=1, ram_address=0x0305,
    ),
    13: GameplayItem(
        id=13, name="L.Armor", category=ItemCategory.EQUIPMENT,
        effect="Armor of Light: ¼ damage + palace access (value 2 at $0302)",
        max_count=1, ram_address=0x0302,  # shared with R.Armor; value-encoded
    ),
    14: GameplayItem(
        id=14, name="M.Boots", category=ItemCategory.EQUIPMENT,
        effect="Walk over damage tiles (boolean)",
        max_count=1, ram_address=0x0304,
    ),
    15: GameplayItem(
        id=15, name="M.Shield", category=ItemCategory.EQUIPMENT,
        effect="Reflect bullets (with Kebabu ally)",
        max_count=1, ram_address=0x0303,
    ),
    16: GameplayItem(
        id=16, name="R.Armor", category=ItemCategory.EQUIPMENT,
        effect="½ damage reduction (value 1 at $0302)",
        max_count=1, ram_address=0x0302,  # shared with L.Armor; value-encoded
    ),
    17: GameplayItem(
        id=17, name="Ring", category=ItemCategory.EQUIPMENT,
        effect="Escape battles (with Kebabu ally)",
        max_count=None, ram_address=None,  # Bank 2 bytecode
    ),

    # Progression Rods (18-23) ---------------------------------------------
    18: GameplayItem(
        id=18, name="Rod", category=ItemCategory.PROGRESSION,
        effect="Starting magic rod (chapter 1 upgrade)",
        chapter=0,
    ),
    19: GameplayItem(
        id=19, name="Flame", category=ItemCategory.PROGRESSION,
        effect="Fire magic rod (chapter 1 upgrade)",
        chapter=1,
    ),
    20: GameplayItem(
        id=20, name="Stardust", category=ItemCategory.PROGRESSION,
        effect="Star magic rod (chapter 2 upgrade)",
        chapter=2,
    ),
    21: GameplayItem(
        id=21, name="Cimaron", category=ItemCategory.PROGRESSION,
        effect="Cimaron magic rod (chapter 3 upgrade)",
        chapter=3,
    ),
    22: GameplayItem(
        id=22, name="Crystal", category=ItemCategory.PROGRESSION,
        effect="Crystal magic rod (chapter 4 upgrade)",
        chapter=4,
    ),
    23: GameplayItem(
        id=23, name="Isfa", category=ItemCategory.PROGRESSION,
        effect="Final magic rod (chapter 5 upgrade)",
        chapter=5,
    ),

    # Progression Swords (24-29) -------------------------------------------
    24: GameplayItem(
        id=24, name="Sword", category=ItemCategory.PROGRESSION,
        effect="Starting sword",
        chapter=0, ram_address=0x0332,
    ),
    25: GameplayItem(
        id=25, name="Simitar", category=ItemCategory.PROGRESSION,
        effect="Chapter 1 sword upgrade",
        chapter=1, ram_address=0x0332,
    ),
    26: GameplayItem(
        id=26, name="Dragoon", category=ItemCategory.PROGRESSION,
        effect="Chapter 2 sword upgrade",
        chapter=2, ram_address=0x0332,
    ),
    27: GameplayItem(
        id=27, name="Kashim", category=ItemCategory.PROGRESSION,
        effect="Chapter 3 sword upgrade (named)",
        chapter=3, ram_address=0x0332,
    ),
    28: GameplayItem(
        id=28, name="Rostam", category=ItemCategory.PROGRESSION,
        effect="Chapter 4 sword upgrade (named)",
        chapter=4, ram_address=0x0332,
    ),
    29: GameplayItem(
        id=29, name="Legend", category=ItemCategory.PROGRESSION,
        effect="Final legendary sword",
        chapter=5, ram_address=0x0332,
    ),
}


# =============================================================================
# BATTLE_ITEMS — ROM Bank 6 $98E8 table (IDs 0..29)
# =============================================================================
#
# Source: RETMOS/REVERSE.md lines 1747-1788 (30 records x 8 bytes each,
# accessed as $98E8 + item_id * 8).
#
# DIFFERENT NAMESPACE from GAMEPLAY_ITEMS. ID 1 is BREAD in GAMEPLAY_ITEMS
# but ROD in BATTLE_ITEMS. Do not cross-reference by ID.

BATTLE_ITEMS: dict[int, BattleItem] = {
    0: BattleItem(
        id=0, name="(null)", pickup_sound=0x00, flags=0x26,
        handler_addr=None, count_addr=None, notes="Empty/placeholder",
    ),
    1: BattleItem(
        id=1, name="ROD", pickup_sound=0x74, flags=0x3E,
        handler_addr=0x8CA9, count_addr=0x030F, notes="Consumable weapon ammo",
    ),
    2: BattleItem(
        id=2, name="FLAME", pickup_sound=0x1A, flags=0x3E,
        handler_addr=0x8CCF, count_addr=0x0310, notes="Consumable weapon ammo",
    ),
    3: BattleItem(
        id=3, name="STARDUST", pickup_sound=0x00, flags=0xFE,
        handler_addr=0x8CFE, count_addr=0x0311, notes="One-time activate",
    ),
    4: BattleItem(
        id=4, name="CIMARON", pickup_sound=0x00, flags=0xFE,
        handler_addr=None, count_addr=None, notes="One-time quest pickup",
    ),
    5: BattleItem(
        id=5, name="CRYSTAL", pickup_sound=0x00, flags=0xEE,
        handler_addr=0x9106, count_addr=None, notes="Active item (param=5)",
    ),
    6: BattleItem(
        id=6, name="ISFA", pickup_sound=0x00, flags=0xC6,
        handler_addr=0x8D8E, count_addr=None, notes="Active item",
    ),
    7: BattleItem(
        id=7, name="KEY", pickup_sound=0x00, flags=0xFE,
        handler_addr=None, count_addr=None, notes="One-time quest key",
    ),
    8: BattleItem(
        id=8, name="AMULET", pickup_sound=0x00, flags=0xFE,
        handler_addr=None, count_addr=None, notes="One-time quest key",
    ),
    9: BattleItem(
        id=9, name="SWORD", pickup_sound=0x74, flags=0xE6,
        handler_addr=0x8E3D, count_addr=0x0332, notes="Equip: sword tier 0",
    ),
    10: BattleItem(
        id=10, name="SIMITAR", pickup_sound=0x74, flags=0xE6,
        handler_addr=0x8E3D, count_addr=0x0332, notes="Equip: sword tier 1",
    ),
    11: BattleItem(
        id=11, name="DRAGOON", pickup_sound=0x74, flags=0xE6,
        handler_addr=0x8E3D, count_addr=0x0332, notes="Equip: sword tier 2",
    ),
    12: BattleItem(
        id=12, name="KASHIM", pickup_sound=0x74, flags=0x06,
        handler_addr=0x8ECE, count_addr=0x0332, notes="Equip: named sword",
    ),
    13: BattleItem(
        id=13, name="ROSTAM", pickup_sound=0x74, flags=0x06,
        handler_addr=0x8ECE, count_addr=0x0332, notes="Equip: named sword",
    ),
    14: BattleItem(
        id=14, name="LEGEND", pickup_sound=0x74, flags=0x06,
        handler_addr=0x8ECE, count_addr=0x0332, notes="Equip: named sword (best)",
    ),
    15: BattleItem(
        id=15, name="HAMMER", pickup_sound=0x6A, flags=0x26,
        handler_addr=0x8F4F, count_addr=None, notes="Quest item (Bank 2 bytecode counts)",
    ),
    16: BattleItem(
        id=16, name="R-SEED", pickup_sound=0x6A, flags=0x26,
        handler_addr=0x8F4F, count_addr=None, notes="Quest item (Rupia seed)",
    ),
    17: BattleItem(
        id=17, name="CARPET", pickup_sound=0x00, flags=0x06,
        handler_addr=None, count_addr=None, notes="Passive equip",
    ),
    18: BattleItem(
        id=18, name="HORN", pickup_sound=0x00, flags=0xFE,
        handler_addr=None, count_addr=None, notes="One-time quest item",
    ),
    19: BattleItem(
        id=19, name="OPRIN", pickup_sound=0x69, flags=0x06,
        handler_addr=0x8F73, count_addr=None, notes="Quest item",
    ),
    20: BattleItem(
        id=20, name="RING", pickup_sound=0x69, flags=0x06,
        handler_addr=0x8F73, count_addr=None, notes="Quest item",
    ),
    21: BattleItem(
        id=21, name="(blank)", pickup_sound=0x69, flags=0x06,
        handler_addr=0x8F73, count_addr=None, notes="Quest variant",
    ),
    22: BattleItem(
        id=22, name="MAP", pickup_sound=0x6A, flags=0x26,
        handler_addr=0x8F7B, count_addr=None, notes="Quest item",
    ),
    23: BattleItem(
        id=23, name="Mode change", pickup_sound=0x70, flags=0x26,
        handler_addr=0x9654, count_addr=None, notes="Sets $72=5 (area/mode flag)",
    ),
    24: BattleItem(
        id=24, name="Battle event", pickup_sound=0x00, flags=0x0E,
        handler_addr=0x9659, count_addr=0x03E0, notes="Triggers RPG battle via $DE93 (ch4-only)",
    ),
    25: BattleItem(
        id=25, name="Full restore", pickup_sound=0x39, flags=0x0E,
        handler_addr=0x966A, count_addr=0x03E1,
        notes="Max ROD/FLAME/STARDUST/Bread/Mashroob; zero gold; triggers battle event",
    ),
    26: BattleItem(
        id=26, name="Screen event", pickup_sound=0x00, flags=0x0E,
        handler_addr=0x96AE, count_addr=0x03E2, notes="Screen transition via $E019 (ch3+)",
    ),
    27: BattleItem(
        id=27, name="Ceremony", pickup_sound=0x00, flags=0x6E,
        handler_addr=0x96B9, count_addr=0x03E3,
        notes="Cutscene: sound $1E + jingle $4F (ch1+)",
    ),
    28: BattleItem(
        id=28, name="Magic effect", pickup_sound=0x00, flags=0x6E,
        handler_addr=0x9725, count_addr=0x03E4, notes="Palette cycle effect (ch2+)",
    ),
    29: BattleItem(
        id=29, name="Entity action", pickup_sound=0x00, flags=0xF6,
        handler_addr=0x91DC, count_addr=None,
        notes="NPC/entity interaction: reads $0319 slot; branches by entity type bit 0",
    ),
}


# =============================================================================
# Accessors
# =============================================================================

def get_gameplay_items_by_category(category: ItemCategory) -> list[GameplayItem]:
    """Return all GAMEPLAY_ITEMS in the given category, sorted by ID."""
    return sorted(
        (item for item in GAMEPLAY_ITEMS.values() if item.category == category),
        key=lambda it: it.id,
    )


def find_gameplay_item_by_name(name: str) -> Optional[GameplayItem]:
    """Case-insensitive name lookup in GAMEPLAY_ITEMS."""
    key = name.lower()
    for item in GAMEPLAY_ITEMS.values():
        if item.name.lower() == key:
            return item
    return None


def find_battle_item_by_name(name: str) -> Optional[BattleItem]:
    """Case-insensitive name lookup in BATTLE_ITEMS."""
    key = name.lower()
    for item in BATTLE_ITEMS.values():
        if item.name.lower() == key:
            return item
    return None
