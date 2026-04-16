# Changelog

## Unreleased

### Critical fixes

- **Disabled latent ROM-corruption path in shop randomization.** `ShopInventory.to_rom_bytes()`, `ROMWriter.write_shop_inventory()`, `write_chapter_shops()`, `write_all_shops()`, `patch_rom(..., shop_data=...)`, and the entire `logic.shop_randomization` module now raise `NotImplementedError` / `ImportError`. The target table at file offset `0xD544` is actually the **inventory cap table** (Bank 3 `$9534`), not a shop slot table. Writing 4-byte `[item_id, qty, price_lo, price_hi]` records there would have corrupted both the inventory caps and the adjacent `inv_pickup_handler` 6502 code. The shop-randomization pipeline was dormant in all active code paths (not wired into `randomizer.py`, `main.py`, `api/server.py`, or `phase7_content.py`), so no released ROM was affected, but the methods were callable by downstream scripts.

  Real shop data lives in an undecoded Bank 2 bytecode interpreter. Shop randomization is deferred indefinitely. See `TMOS_AI/docs/human/items-economy-re-answers.md` and `RETMOS/REVERSE.md` for the RE finding.

- **`SpoilerLogBuilder.add_shop_inventory()` and `add_chapter_shops()`** now raise `NotImplementedError` (consumed the broken `CoreShopInventory` / `ChapterShopData` models). The `add_shop()` method (generic dict-based) remains usable for future real shop data.

- **Spoiler log shop section** now emits a fixed "not yet supported" notice instead of rendering fabricated shop data.

### Cleanup

- Removed unused `SHOP_ITEMS`, `PROGRESSION_ITEMS`, `ItemCategory` imports from `api/server.py`.
- Removed unused `SHOP_ITEM_TABLE`, `SHOP_ENTRY_SIZE` imports from `io/rom_writer.py`.
- **Deleted deprecated `SHOP_*` aliases from `core/constants.py`** (`SHOP_BANK_FILE_OFFSET`, `SHOP_INDEX_TABLE`, `SHOP_ITEM_TABLE`, `SHOP_PRICE_TABLE`, `SHOP_SLOT_SIZE`, `SHOP_SLOTS_PER_SHOP`, `SHOP_ENTRY_SIZE`). Use `BANK_3_FILE_OFFSET`, `INV_PICKUP_INDEXER`, `INV_CAP_TABLE`, `INV_PICKUP_AUX_DATA`, `INV_CAP_SLOT_SIZE`, `INV_CAP_SLOT_COUNT` instead.
- Deleted fabricated `SHOP_ITEMS`, `PROGRESSION_ITEMS`, `REQUIRED_ITEMS` registries and helper functions from `core/shop_items.py`. Dataclasses (`ShopType`, `ItemCategory`, `ShopItem`) remain for backwards compatibility with `shop_inventory.py` typedefs.

### Added

- **`core/items.py`**: single Python source of truth for item metadata. Two explicit namespaces (`GAMEPLAY_ITEMS` and `BATTLE_ITEMS`) with the `$98E8` battle-table ID space documented separately from the menu/HUD gameplay ID space.
- **`/api/rom/items` endpoint**: returns both item namespaces as JSON; UI consumes via `store.loadItems()`.
- **`tests/test_core/test_items_registry.py`**: 22 tests verifying namespace completeness, RAM-address cross-reference with `inventory_caps.RAM_LABELS`, and regression guards for the previously-wrong Key/Amulet/Carpet/Hammer RAM addresses.
- **`PROVISIONAL` annotations** in `docs/planning/data-contract.md`, `ui/src/types/randomizer.ts`, and `docs/planning/spoiler-log.md` flagging all shop-shape contract surfaces as blocked on Bank 2 bytecode RE.
- **Regression tripwires** (Phase 5): 37 new tests across `tests/test_io/test_rom_writer_no_corruption.py` (6 tests, SHA256-hash proof that shop writers leave ROM bytes unchanged), `tests/test_integration/test_patch_rom_no_shop_data_arg.py` (4 tests, guard fires before `writer.save()`), `tests/test_logic/test_shop_randomization_disabled.py` (2 tests, import fails loudly), `tests/test_core/test_inventory_caps_no_overflow.py` (5 tests, writes stay within the 32-byte window `[0xD544, 0xD564)`), and extensions to `tests/test_output/test_spoiler_log.py` (3 tests). Total: 322 tests passing (up from 269 pre-remediation).
- **`tests/test_core/test_rom_truth_anchors.py`** (17 tests): cross-cutting ROM byte-pattern invariants for every major offset constant. Includes `test_bank_3_file_offset_matches_spec` — the test that would have caught the original 8-KB-vs-16-KB bank-math bug on day one.
- **`README.md`** and **`docs/re/README.md`** — maintainer-facing context explaining why shop modules hard-fail and the four item-ID-namespace situation.

### Fixed

- `rom_writer.py::write_shop_inventory` error message now references `TMOS_AI/docs/human/items-economy-re-answers.md` (consistency with other disabled surfaces).
- `spoiler_log.py` `_generate_shops_section` now emits its "not yet supported" notice unconditionally (previously gated on `log.shops` being non-empty; matches Phase 0 intent of "visible status over mystery omission").
