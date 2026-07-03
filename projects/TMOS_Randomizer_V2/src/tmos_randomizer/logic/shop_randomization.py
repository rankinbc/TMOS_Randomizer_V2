"""Shop randomization against the real Bank 1 tables.

History: the first implementation of this module targeted 0xD544 (actually
the Bank 3 inventory cap table) and was hard-disabled to prevent ROM
corruption. RETMOS RE sessions later resolved the real shop system: flat
tables in Bank 1 ($94FD shop data, $8AAC magic base prices), fully
write-specified and byte-verified 2026-07-02. This implementation writes
ONLY those verified offsets. Spec: knowledge/systems/shops-and-economy.md.

Design:
- Slot shuffle permutes the 32 vanilla [code, price] PAIRS globally across
  the 8 item shops. The code multiset is preserved: no new codes are ever
  introduced (the unverified $10/$11 codes stay exactly as prevalent as
  vanilla), nothing is removed (BREAD/MASHROOB/key availability is
  identical to vanilla in aggregate), and each code keeps a price chosen
  for it, so shuffling alone cannot violate affordability rules.
- Price variance/multiplier then adjust each slot price, clamped to the
  safety rules: quantity-purchasable codes (BREAD/MASHROOB) cap at
  GOLD_MAX // 10 so price x max-quantity stays within 3-digit BCD gold;
  everything else caps at 255.
- Magic base prices are adjusted separately (magic shops IGNORE slot
  prices; charged = base x (chapter+1)) and clamped to MAGIC_BASE_PRICE_MAX.

Caveat from the RE spec: shops 4-7 run a different price post-processing
path ($86CF). Pair shuffling moves slots across that boundary; prices remain
mechanically safe (all bounds hold) but displayed values on shops 4-7 should
be eyeballed in-game once per release.
"""

from __future__ import annotations

import random
from dataclasses import dataclass, field

from ..core.constants import GOLD_MAX, SHOP_COUNT, SHOP_SLOTS_PER_SHOP
from ..core.shop_economy import (
    MAGIC_BASE_PRICE_MAX,
    ShopSlotDTO,
    read_all_shops,
    read_magic_base_prices,
    write_magic_base_prices,
    write_shop_slot,
)

# Codes purchasable in quantity (numeric-input path): price x qty <= GOLD_MAX.
# Their caps are 10, so keep price <= 99.
_QUANTITY_CODES = frozenset({0x33, 0x34})
_QUANTITY_PRICE_MAX = GOLD_MAX // 10

_PRICE_MIN = 1  # price 0 is legal (free item) but never produced here


@dataclass
class ShopRandomizationPlan:
    """Deterministic plan: computed from (rom, seed, options), applied later.

    slot_assignments[shop][slot] = {"item_code", "item_label", "base_price"}
    """

    seed: int
    slot_assignments: list[list[dict]] = field(default_factory=list)
    magic_base_prices: list[int] = field(default_factory=list)
    vanilla_magic_base_prices: list[int] = field(default_factory=list)

    def apply(self, rom: bytearray) -> int:
        """Write the plan into ROM bytes. Returns number of bytes written."""
        written = 0
        for shop_idx, slots in enumerate(self.slot_assignments):
            for slot_idx, slot in enumerate(slots):
                write_shop_slot(
                    rom,
                    shop_idx,
                    slot_idx,
                    item_code=slot["item_code"],
                    base_price=slot["base_price"],
                )
                written += 2
        if self.magic_base_prices != self.vanilla_magic_base_prices:
            write_magic_base_prices(rom, self.magic_base_prices)
            written += len(self.magic_base_prices)
        return written

    def to_spoiler(self) -> dict:
        """Shape consumed by SpoilerLogBuilder.add_shop (generic dict API)."""
        return {
            "seed": self.seed,
            "shops": [
                {
                    "shop_index": i,
                    "slots": [
                        {
                            "item_label": s["item_label"],
                            "item_code": f"0x{s['item_code']:02X}",
                            "price": s["base_price"],
                        }
                        for s in slots
                    ],
                }
                for i, slots in enumerate(self.slot_assignments)
            ],
            "magic_base_prices": self.magic_base_prices,
        }


def _clamp_price(code: int, price: int) -> int:
    ceiling = _QUANTITY_PRICE_MAX if code in _QUANTITY_CODES else 255
    return max(_PRICE_MIN, min(ceiling, price))


# REMOVED FEATURE — "shop-sellable KEYs" (code $18). RETMOS round 3
# resolved that no KEY item exists: $0308 is the pending-gold accumulator
# and command $18 credits +1 gold (which is why no vanilla shop uses it).
# A "$18 key" slot would sell 1 gold for the slot price. The sell_keys
# option was removed rather than shipped as a trap.
# See RETMOS/REVERSE.md "Vanilla Key Source Hunt ($0308)".


def create_shop_plan(
    rom: bytes,
    seed: int,
    *,
    shuffle_slots: bool = True,
    price_variance: float = 0.0,
    price_multiplier: float = 1.0,
    randomize_magic_prices: bool = False,
) -> ShopRandomizationPlan:
    """Build a deterministic shop randomization plan from vanilla shop data.

    Args:
        rom: full iNES ROM bytes (vanilla shop data is read from here).
        seed: RNG seed; same (rom, seed, options) -> same plan.
        shuffle_slots: permute the 32 [code, price] pairs across all shops.
        price_variance: 0.0-1.0; each price jittered by up to this fraction.
        price_multiplier: global scale applied before clamping (0.1-10.0).
        randomize_magic_prices: also jitter/scale the $8AAC magic base table.
    """
    if not 0.0 <= price_variance <= 1.0:
        raise ValueError(f"price_variance must be 0.0..1.0, got {price_variance}")
    if not 0.1 <= price_multiplier <= 10.0:
        raise ValueError(f"price_multiplier must be 0.1..10.0, got {price_multiplier}")

    rng = random.Random(seed)

    def adjust(price: int) -> int:
        p = price * price_multiplier
        if price_variance > 0.0:
            p *= rng.uniform(1.0 - price_variance, 1.0 + price_variance)
        return round(p)

    pairs: list[ShopSlotDTO] = read_all_shops(rom)
    if shuffle_slots:
        rng.shuffle(pairs)

    assignments: list[list[dict]] = []
    it = iter(pairs)
    for _shop in range(SHOP_COUNT):
        slots = []
        for _slot in range(SHOP_SLOTS_PER_SHOP):
            src = next(it)
            slots.append(
                {
                    "item_code": src["item_code"],
                    "item_label": src["item_label"],
                    "base_price": _clamp_price(src["item_code"], adjust(src["base_price"])),
                }
            )
        assignments.append(slots)

    vanilla_magic = read_magic_base_prices(rom)
    magic = list(vanilla_magic)
    if randomize_magic_prices:
        magic = [
            max(_PRICE_MIN, min(MAGIC_BASE_PRICE_MAX, adjust(p)))
            for p in vanilla_magic
        ]

    return ShopRandomizationPlan(
        seed=seed,
        slot_assignments=assignments,
        magic_base_prices=magic,
        vanilla_magic_base_prices=vanilla_magic,
    )
