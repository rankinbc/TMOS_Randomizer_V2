# TMOS Randomizer V2

Map randomizer for **The Magic of Scheherazade** (NES, 1989).

Takes a vanilla ROM (`TMOS_ORIGINAL.nes`) and outputs a patched ROM with randomized world layouts, encounters, and (selected) player/enemy stats. A FastAPI backend + React UI let users preview and tune the randomization before patching.

## Status

Active development. Alpha.

### What works

- Map randomization (world layout, section shaping, connections, navigation).
- Encounter randomization (groups, lineups, per-enemy stats).
- Player stat editing (HP, sword/rod indices, damage curves).
- Inventory cap editing (8 slots at file `0xD544`; raise BREAD cap 10 → 99 etc).
- EXP tier table editing.
- Item registry browser (`/api/rom/items`, backed by `core/items.py`).

### What doesn't

- **Shop randomization (per-shop inventory + prices): not yet supported.** Deferred as a stretch goal. Real shop data lives in an undecoded Bank 2 bytecode interpreter. All shop-writing code paths (`ROMWriter.write_shop_inventory`, `ShopInventory.to_rom_bytes`, `logic.shop_randomization`, the `shop_data` argument of `patch_rom`) raise `NotImplementedError` / `ImportError` to prevent accidental use. See [`docs/re/README.md`](docs/re/README.md) and the upstream RE doc at `TMOS_AI/docs/human/items-economy-re-answers.md`.
- Shop-related types in `ui/src/types/randomizer.ts` and `docs/planning/data-contract.md` are marked **PROVISIONAL** — do not build against them.

## Quick start

```bash
# Install
pip install -e .

# Run API server
uvicorn tmos_randomizer.api.server:app --reload --port 8000

# Run UI (separate terminal, ui/ directory)
cd ui && npm install && npm run dev

# Run tests
pytest tests/ --ignore=tests/test_rendering
```

Tests require a copy of `TMOS_ORIGINAL.nes` at the project root for integration coverage; unit tests run without it.

## Project layout

- `src/tmos_randomizer/` — Python package (core, io, logic, phases, output, api)
- `ui/` — React + Vite front-end (TypeScript, Zustand store, FastAPI client)
- `tests/` — pytest suites (test_core, test_io, test_logic, test_integration, test_output, test_phases, test_rendering, test_validation)
- `docs/planning/` — design documents and data contracts
- `docs/re/` — reverse-engineering notes and maintainer-facing context
- `config/` — default configuration (`default.yaml`)

## Contributing

Before adding a new ROM offset constant, read [`docs/re/README.md`](docs/re/README.md). The 2026-04-16 shop-corruption incident was caused by a bank-math error plus a byte-pattern misidentification that should have been caught by one simple test; we now enforce those as **ROM truth anchors** in `tests/test_core/test_rom_truth_anchors.py`. Add an anchor for any new ROM table you document.

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).
