"""Shop item slots + base prices, and trooper recruitment cost.

This module covers two ROM-confirmed economy tables that the legacy
``shop_inventory.py`` / ``shop_items.py`` modules do NOT handle (those were
built on the superseded 0xD544 cap-table misread and have their writers
disabled). The real shop tables were located by the 2026-06-15 disassembly
trace and live in Bank 1.

Shop inventory table — Bank 1 $94FD → file 0x0550D
  [DISASSEMBLY 2026-06-15] game_specs/systems/economy/README.md:49-75,89-100
  8 shops × 4 slots × 2 bytes. Per-slot layout:
    byte 0 = item_code  ([category_nibble : slot_nibble]; indexes $0300 array)
    byte 1 = base_price (clean per-chapter amount: 20/40/60/100)
  File offset math: 1*0x4000 + ($94FD - 0x8000) + 0x10 = 0x0550D (verified
  against the ROM: decoded bytes match the README's decoded shop table exactly).
  Tier = "expert" (DISASSEMBLY-sourced; confirmed write target).

Trooper recruitment cost — file $4577
  [ROM_VERIFIED] game_specs/systems/economy/README.md:198 ;
  analysis/.../raw_research/trooper_system.md:84-89 ; knowledge rom-map.md:159
  Single byte: the immediate operand of `LDA #$64 / STA $04D6` (the price
  loaded into the purchase-price RAM). Vanilla = 0x64 = 100 rupias for 4
  troopers (25 each). No per-chapter table — one fixed value.
  Tier = "safe" (ROM_VERIFIED).

Conventions mirror core/enemy_stats.py: `rom` is the FULL iNES file bytes
(16-byte header included); address constants are RESOLVED FILE OFFSETS.
"""

from __future__ import annotations

from typing import Optional, TypedDict

from .constants import (
    GOLD_MAX,
    MAGIC_SHOP_BASE_PRICES,
    MAGIC_SHOP_BASE_PRICE_COUNT,
    SHOP_CODE_LEGAL_HI4,
)

# --- Shop inventory table (Bank 1 $94FD) -----------------------------------
# file = 1*0x4000 + (0x94FD - 0x8000) + 0x10 = 0x0550D
SHOP_TABLE = 0x0550D
SHOP_COUNT = 8
SHOP_SLOTS = 4
SHOP_SLOT_SIZE = 2          # [item_code, base_price]
SHOP_RECORD_SIZE = SHOP_SLOTS * SHOP_SLOT_SIZE  # 8 bytes per shop

# --- Trooper recruitment cost (file $4577) ---------------------------------
TROOPER_PRICE_OFFSET = 0x4577


# Labels for shop slot codes. Names are NOT in a ROM lookup table (item names
# are pre-rendered CHR tiles); mapping emulator-verified via RETMOS
# tools/emu.py unit-mode 2026-07-02 (knowledge/systems/shops-and-economy.md).
# Real door KEYS are code $18 -> $0308; $10 credits the $0300 bread counter.
_ITEM_CODE_LABELS: dict[int, str] = {
    0x10: "GORTRAT BREAD",
    0x11: "GORTRAT-paired ($0301)",
    0x18: "KEY",
    0x33: "BREAD",
    0x34: "MASHROOB",
    0x51: "R.SEED",
    0x52: "CARPET",
    0x53: "HORN",
    0x58: "RING",
}


class ShopSlotDTO(TypedDict):
    shop_index: int
    slot_index: int
    rom_offset: str
    item_code: int
    item_code_hex: str
    item_label: str
    base_price: int


class TrooperCostDTO(TypedDict):
    rom_offset: str
    cost: int          # rupias for a batch of 4 troopers (vanilla 100)


# ---------------------------------------------------------------------------
# Shop slots + prices
# ---------------------------------------------------------------------------

def _check_shop(shop_index: int) -> None:
    if not 0 <= shop_index < SHOP_COUNT:
        raise ValueError(
            f"shop_index must be 0..{SHOP_COUNT - 1}, got {shop_index}"
        )


def _check_slot(slot_index: int) -> None:
    if not 0 <= slot_index < SHOP_SLOTS:
        raise ValueError(
            f"slot_index must be 0..{SHOP_SLOTS - 1}, got {slot_index}"
        )


def _slot_offset(shop_index: int, slot_index: int) -> int:
    return (
        SHOP_TABLE
        + shop_index * SHOP_RECORD_SIZE
        + slot_index * SHOP_SLOT_SIZE
    )


def _item_label(item_code: int) -> str:
    return _ITEM_CODE_LABELS.get(item_code, f"${0x0300 + (item_code & 0x0F):04X}?")


def _read_slot(rom: bytes, shop_index: int, slot_index: int) -> ShopSlotDTO:
    _check_shop(shop_index)
    _check_slot(slot_index)
    off = _slot_offset(shop_index, slot_index)
    code = rom[off]
    return {
        "shop_index": shop_index,
        "slot_index": slot_index,
        "rom_offset": f"0x{off:05X}",
        "item_code": code,
        "item_code_hex": f"0x{code:02X}",
        "item_label": _item_label(code),
        "base_price": rom[off + 1],
    }


def read_shop_slot(rom: bytes, shop_index: int, slot_index: int) -> ShopSlotDTO:
    return _read_slot(rom, shop_index, slot_index)


def read_shop(rom: bytes, shop_index: int) -> list[ShopSlotDTO]:
    """Read all 4 slots of one shop."""
    _check_shop(shop_index)
    return [_read_slot(rom, shop_index, s) for s in range(SHOP_SLOTS)]


def read_all_shops(rom: bytes) -> list[ShopSlotDTO]:
    """Read every slot of every shop (8 shops × 4 slots = 32 DTOs)."""
    out: list[ShopSlotDTO] = []
    for shop in range(SHOP_COUNT):
        for slot in range(SHOP_SLOTS):
            out.append(_read_slot(rom, shop, slot))
    return out


def write_shop_slot(
    rom: bytearray,
    shop_index: int,
    slot_index: int,
    *,
    item_code: Optional[int] = None,
    base_price: Optional[int] = None,
) -> ShopSlotDTO:
    """Mutate one shop slot. Untouched fields are preserved."""
    _check_shop(shop_index)
    _check_slot(slot_index)
    off = _slot_offset(shop_index, slot_index)
    if item_code is not None:
        if not 0 <= item_code <= 255:
            raise ValueError(f"item_code must be 0..255, got {item_code}")
        if (item_code >> 4) not in SHOP_CODE_LEGAL_HI4:
            # Codes outside hi4 {1,3,5} fall into the password-opcode space of
            # the $8746 state-command processor: buying one would write
            # arbitrary game state. Refuse loudly.
            raise ValueError(
                f"item_code 0x{item_code:02X} has illegal hi-nibble "
                f"{item_code >> 4:X} (must be 1, 3, or 5 — see "
                f"knowledge/systems/shops-and-economy.md)"
            )
        rom[off] = item_code
    if base_price is not None:
        if not 0 <= base_price <= 255:
            raise ValueError(f"base_price must be 0..255, got {base_price}")
        rom[off + 1] = base_price
    return _read_slot(bytes(rom), shop_index, slot_index)


# ---------------------------------------------------------------------------
# Magic-shop base prices (Bank 1 $8AAC)
#
# Magic/formation shops (Content $75-$79) IGNORE the slot price byte; the
# charged price is base_prices[code & 0x0F] * (chapter + 1). 11 entries.
# ---------------------------------------------------------------------------

# Chapter multiplier maxes out at chapter 5 -> (chapter + 1) = 6. A base above
# GOLD_MAX // 6 = 166 could never be afforded (gold is 3-digit BCD).
MAGIC_BASE_PRICE_MAX = GOLD_MAX // 6


def read_magic_base_prices(rom: bytes) -> list[int]:
    """Read the 11-entry magic-shop base price table."""
    return list(
        rom[MAGIC_SHOP_BASE_PRICES : MAGIC_SHOP_BASE_PRICES + MAGIC_SHOP_BASE_PRICE_COUNT]
    )


def write_magic_base_prices(rom: bytearray, prices: list[int]) -> list[int]:
    """Overwrite the 11-entry magic-shop base price table."""
    if len(prices) != MAGIC_SHOP_BASE_PRICE_COUNT:
        raise ValueError(
            f"expected {MAGIC_SHOP_BASE_PRICE_COUNT} prices, got {len(prices)}"
        )
    for i, p in enumerate(prices):
        if not 0 <= p <= MAGIC_BASE_PRICE_MAX:
            raise ValueError(
                f"magic base price [{i}] = {p} outside 0..{MAGIC_BASE_PRICE_MAX} "
                f"(base * 6 must stay <= {GOLD_MAX})"
            )
    rom[MAGIC_SHOP_BASE_PRICES : MAGIC_SHOP_BASE_PRICES + MAGIC_SHOP_BASE_PRICE_COUNT] = bytes(prices)
    return read_magic_base_prices(bytes(rom))


# ---------------------------------------------------------------------------
# Trooper recruitment cost
# ---------------------------------------------------------------------------

def read_trooper_cost(rom: bytes) -> TrooperCostDTO:
    return {
        "rom_offset": f"0x{TROOPER_PRICE_OFFSET:05X}",
        "cost": rom[TROOPER_PRICE_OFFSET],
    }


def write_trooper_cost(rom: bytearray, cost: int) -> TrooperCostDTO:
    """Set the trooper recruitment cost (rupias for a batch of 4).

    Single ROM byte; valid 0..255. Vanilla is 100.
    """
    if not 0 <= cost <= 255:
        raise ValueError(f"cost must be 0..255, got {cost}")
    rom[TROOPER_PRICE_OFFSET] = cost
    return read_trooper_cost(bytes(rom))
