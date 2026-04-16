# Reverse-Engineering Notes — Maintainer Context

This directory holds context that helps future contributors understand *why* certain TMOS Randomizer modules look the way they do. It is not exhaustive RE documentation — the authoritative RE lives in the separate RETMOS project (`C:\claude-workspace\RETMOS\REVERSE.md`). This is just the parts a developer touching *this* codebase needs to know.

Scope right now: the **shop subsystem incident** of 2026-04-16 and the **four item-ID namespaces** that grew out of it.

---

## The shop subsystem is deliberately disabled

All of these raise exceptions by design:

| Surface | Raises | Reason |
|---|---|---|
| `ShopInventory.to_rom_bytes()` | `NotImplementedError` | Target table at `0xD544` isn't shop data |
| `ROMWriter.write_shop_inventory()` | `NotImplementedError` | Would corrupt inventory cap table |
| `ROMWriter.write_chapter_shops()` | `NotImplementedError` | Calls the above |
| `ROMWriter.write_all_shops()` | `NotImplementedError` | Calls the above |
| `patch_rom(..., shop_data=<non-None>)` | `NotImplementedError` | Entry point guard |
| `import tmos_randomizer.logic.shop_randomization` | `ImportError` | Randomizes a phantom data structure |
| `SpoilerLogBuilder.add_shop_inventory()` | `NotImplementedError` | Consumes the broken core model |
| `SpoilerLogBuilder.add_chapter_shops()` | `NotImplementedError` | Same |

**Do not "fix" these by removing the raises.** The tripwires in `tests/test_io/test_rom_writer_no_corruption.py`, `tests/test_integration/test_patch_rom_no_shop_data_arg.py`, `tests/test_logic/test_shop_randomization_disabled.py`, and `tests/test_output/test_spoiler_log.py` exist to catch exactly that.

### What went wrong

1. Someone documented a constant `SHOP_ITEM_TABLE = 0xD544`, believing that offset held shop slot records of the form `[item_id, qty, price_lo, price_hi]`.
2. The bank-math comment said *"Bank 6 file offset = 16 + 6 * 0x2000 = 0xC010"*. NES MMC1 PRG banks are 16 KB, not 8 KB. `0xC010` is actually **Bank 3**.
3. A shop randomization pipeline (`logic/shop_randomization.py` → `core/shop_inventory.py::to_rom_bytes` → `io/rom_writer.py::write_all_shops`) serialized fabricated shop data into that offset.
4. The pipeline was never wired into `randomizer.py` or the API server — pure luck that no released ROM was corrupted. The dormant corruption path would have fired the moment anyone called `patch_rom(..., shop_data={...})` from a script.

### What's actually at `0xD544`

It's the **inventory-pickup cap table**: 8 records × 4 bytes, each `[ram_addr_lo, 0x03, max_cap, slot_idx]`. Read by the Bank 3 `$94B0` routine (`inv_pickup_handler`) to increment a `$03xx` inventory variable when the player picks up an item. Byte 0+1 is the low/high of a RAM pointer (high is always `0x03` because page 3 is the inventory variable bank); byte 2 is the cap; byte 3 is a party-slot mirror index.

Vanilla contents: 8 slots covering STARDUST charges (cap 15), ROD/FLAME/Gortrat-mashroob/Max-MP/Gortrat-bread (caps 1, 1, 1, 5, 9), and the carried BREAD/MASHROOB caps (10 each). See `src/tmos_randomizer/core/inventory_caps.py` for the live API.

### Real shop data lives in Bank 2 bytecode

Shop inventories and prices are **driven by a bytecode interpreter in PRG Bank 2** that has not been reverse-engineered. Until that RE is done:
- There is no way to edit per-shop inventory.
- There is no way to edit prices.
- There is no way to map "shop ID" to a Content byte meaningfully.

Full details: `TMOS_AI/docs/human/items-economy-re-answers.md` and `RETMOS/REVERSE.md` lines 1620-1810 / 2401-2450.

---

## Four item-ID namespaces (pick the right one)

TMOS uses multiple overlapping item-ID systems. Do not conflate them:

| Namespace | Where | ID Example |
|---|---|---|
| **Gameplay (menu/HUD)** | `core/items.py::GAMEPLAY_ITEMS` | ID 1 = Bread, ID 6 = Key, ID 17 = Ring |
| **Battle table** ($98E8 in ROM) | `core/items.py::BATTLE_ITEMS` | ID 1 = ROD, ID 6 = ISFA, ID 17 = CARPET |
| **Inventory RAM pointers** ($03xx) | `core/inventory_caps.py::RAM_LABELS` | `$0306` = BREAD, `$0308` = KEY |
| **Previously fabricated** (deleted) | was `core/shop_items.py::SHOP_ITEMS` | Do not resurrect |

**Rule of thumb:** if you need an item ID and you don't know which namespace, look it up by **name** (`find_gameplay_item_by_name` / `find_battle_item_by_name` in `core/items.py`), not by number. There is no known runtime conversion between namespaces.

---

## The testing contract

If you add a new ROM-offset constant to `core/constants.py`:

1. **Add a ROM truth anchor** to `tests/test_core/test_rom_truth_anchors.py`. Assert at least one byte pattern at the documented offset. This is what would have caught the `SHOP_ITEM_TABLE = 0xD544` mistake on the day it was written.
2. **Compute file offsets from `bank * 0x4000 + 16`**, not `bank * 0x2000 + 16`. A test (`test_bank_3_file_offset_matches_spec`) enforces this.
3. **Grep for name collisions.** A test (`test_no_constant_shares_offset_with_inv_cap_table`) catches the specific case where two constants with different names point at the same offset — the exact smell of the original bug.

---

## Further reading

- `RETMOS/REVERSE.md` — authoritative RE notes, ~2500 lines
- `TMOS_AI/docs/human/items-economy-re-answers.md` — the incident response document that drove this remediation
- `docs/planning/data-contract.md` — UI ↔ backend contract (shop sections marked `PROVISIONAL`)
- `CHANGELOG.md` — chronological record of the remediation phases (0-6)
