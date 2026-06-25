# Edit-Modal Tile-Picker Collision Filter — Design

**Date:** 2026-06-25
**Status:** Approved (design); ready for implementation plan
**Area:** `projects/TMOS_Randomizer_V2` (FastAPI backend + React/TypeScript frontend)
**Scope:** Spec #2 of the tile-editing series. (Spec #1 = the Selected World Screen panel, shipped. Theme-based filtering and coherent whole-screen biome swap are deferred to Spec #3 — see Follow-on.)

## Problem

The Edit World Screen modal (`ScreenEditorModal`) presents the tile-section picker as a
flat grid of all **471 sections** with no filtering. Choosing the top and bottom sections
is unconstrained, so it is easy to build screens whose edges don't line up with their
neighbors — a walkable opening on one screen meeting a wall on the next — producing
impassable or broken-looking transitions. World customization is tedious because the user
must eyeball 471 thumbnails and mentally check seams.

## Goal

Add an opt-in **collision filter** to the picker that ranks sections by how well their
edges match the adjacent screens, plus a **pair helper** that suggests top+bottom
combinations whose internal seam is clean and that fit the neighbors. The collision logic
is the backbone; aesthetic ("theme") coherence is a later phase.

## Non-Goals

- **Theme / biome classification** (e.g. "this is a dungeon section") — no classifier
  exists; deferred to Spec #3.
- **Coherent whole-screen biome swap** (avoiding dungeon-bottom + overworld-top by *look*)
  — depends on the theme classifier; deferred to Spec #3.
- No change to how tiles are written: selection still flows through the existing
  `onTilePick(which, globalIndex)` → `PATCH /api/rom/screen/{ch}/{idx}/tiles`.
- The filter is **off by default**; with it off the picker behaves exactly as today.

## Key Insight (de-risks the whole feature)

A tile section's **walkability is intrinsic to its tile IDs** — collision depends on the
tile ID, not on the CHR/graphics bank or the screen's `datapointer`. So each of the 471
sections has a **fixed** walkability grid that can be computed **once** from the ROM and
cached. The frontend already knows each neighbor's `top_tiles`/`bottom_tiles`/`datapointer`,
so with a per-section table it can resolve and compare **both** candidate sections **and**
neighbor sections entirely client-side, with no per-interaction round-trips.

The V2 backend **already has** the collision primitives (no port from `TMOS_World_Editor`
needed):
- `validation/tiles/categories.py` — the 4-category system (`WALKABLE`, `HAZARDOUS`,
  `COLLIDABLE`, `DEADLY`), `is_walkable(...)`, `get_walkability_signature(tiles) -> str`
  (`'1'`=walkable/`'0'`=blocking), `edges_match(edge_a, edge_b) -> (bool, mismatch_count, positions)`.
- `validation/tiles/edges.py` — `read_tilesection(rom_data, index) -> bytes` (32 tile IDs),
  `extract_edges(rom_data, screen_index, top_tiles, bottom_tiles, datapointer) -> ScreenEdges`.
- `rendering/screen_renderer.py` — `build_screen_tile_grid(rom_data, top_tiles, bottom_tiles, datapointer)`
  and the `TILESECTION_BASE`/stride constants.

## Architecture

Chosen approach: **backend precompute table + client-side filtering.**

### Backend — one new cacheable endpoint

`GET /api/rom/tilesection-walkability`

Returns the intrinsic walkability grid for every section the picker can show
(global indices `0..470`):

```json
{ "sections": { "0": "11110110...", "1": "....", "470": "...." } }
```

- Each value is a **32-character** bitstring = the section's **4 rows × 8 cols** grid in
  row-major order (`'1'`=walkable, `'0'`=blocking).
- Computed per section as: resolve the **global** index `0..470` to its 32 section tile-ID
  bytes **using the same global-index → bytes resolution the existing
  `GET /api/rom/tilesection/{index}` image endpoint already uses** (bank-encoded global
  index; do not assume `read_tilesection`'s raw-offset arg without that resolution), then
  map each tile ID through `is_walkable(...)` (reusing the authoritative `COLLIDABLE`/`DEADLY`
  tables; `WALKABLE`/`HAZARDOUS` → `'1'`, `COLLIDABLE`/`DEADLY` → `'0'`). Same classification
  `get_walkability_signature` already applies to edges, here applied to the full section.
- Pure function of the loaded ROM → compute once and **cache** (module-level, keyed by the
  loaded ROM; invalidate on ROM change). Payload ≈ 15 KB.
- ROM-gated like the existing tile endpoints (`No ROM loaded` → the standard error the other
  loaders surface).

The endpoint deliberately returns **grids, not pre-sliced edges** — keeping the server
dumb and letting the client derive whatever edges it needs (so the same table serves the
active-half ranking and the pair helper without endpoint changes).

### Frontend data flow

1. On modal open (or app start), fetch the table once via a new client method
   `api.getTileSectionWalkability(): Promise<{ sections: Record<string, string> }>`, stored
   in the zustand store (`tileWalkability`, loaded lazily, cached for the session).
2. All ranking, dimming, and pair scoring run client-side in a new **pure util**
   `components/screen/tileFilter.ts` (no React, no store — node-testable).

## Edge Model & Matching

A screen is **6 rows × 8 cols**: **rows 0–3** come from the top section (its 4 rows);
**rows 4–5** come from the bottom section's **rows 0–1**. From a section's 32-char grid the
client slices:

- `topEdge(section)` = grid row 0 (8 chars)
- `bottomEdgeAsScreen(section)` = grid row 1 (8 chars) — the visible bottom row (screen row 5)
- `leftCol(section, rows)` / `rightCol(section, rows)` = col 0 / col 7 for the given rows

A screen's four full edges are built from its two section grids:
- screen **top edge** = `topEdge(topSection)`
- screen **bottom edge** = `bottomEdgeAsScreen(bottomSection)`
- screen **left edge** (6 tiles) = `leftCol(topSection, rows 0–3)` ++ `leftCol(bottomSection, rows 0–1)`
- screen **right edge** (6 tiles) = `rightCol(topSection, rows 0–3)` ++ `rightCol(bottomSection, rows 0–1)`

A neighbor's section indices are resolved from `neighbor.top_tiles`/`bottom_tiles` plus the
modal's existing `getBanks(neighbor.datapointer)` helper (`bank*256 + byte`), then looked up
in the table.

### Active-half ranking

**Active half = TOP** (candidate owns screen rows 0–3) is matched against:
- candidate `topEdge` ↔ **UP** neighbor's bottom edge (full 8)
- candidate `leftCol(rows 0–3)` ↔ **LEFT** neighbor's right-edge rows 0–3
- candidate `rightCol(rows 0–3)` ↔ **RIGHT** neighbor's left-edge rows 0–3

**Active half = BOTTOM** (candidate owns screen rows 4–5 = section rows 0–1) is matched against:
- candidate `bottomEdgeAsScreen` ↔ **DOWN** neighbor's top edge (full 8)
- candidate `leftCol(rows 0–1)` ↔ **LEFT** neighbor's right-edge rows 4–5
- candidate `rightCol(rows 0–1)` ↔ **RIGHT** neighbor's left-edge rows 4–5

**Compatibility** is per-position walkability equality: `'1'`↔`'1'` and `'0'`↔`'0'` both pass;
only `'1'` vs `'0'` is a mismatch (the existing `edges_match` rule). The **score** for a
candidate is the **total mismatch count** summed across the relevant neighbor edges.

- Only neighbors whose `nav_*` resolves to a **real screen index** (`< chapter screen count`,
  i.e. not `0xFF` blocked / `0xFE` building) contribute; absent directions are skipped and
  surfaced in the UI summary.
- A candidate global index outside `0..470`, or a neighbor section missing from the table,
  is treated as **max mismatch** (sorted last) rather than throwing.

### Pair helper

Suggests top+bottom **pairs** ranked by total mismatch =
- **internal mid-screen seam:** `topSection` row 3 ↔ `bottomSection` row 0, per-position
  (a clean seam where the two halves meet), **plus**
- the top half's neighbor fit (up / left-upper / right-upper) **plus** the bottom half's
  neighbor fit (down / left-lower / right-lower).

To stay tractable without enumerating 471×471, the helper first takes the top-K best top
candidates and top-K best bottom candidates by their own neighbor fit (K ≈ 40), forms the
K×K pairs, scores each by the formula above, and returns the best ~12. Applying a pair sets
both halves (two `onTilePick` calls, or one combined update).

## UI (`ScreenEditorModal`)

- A **"Filter: collision"** toggle above the section grid. **Off by default**; off = today's
  behavior. On:
  - The grid is **sorted** perfect-fit (0 mismatches) first, then ascending mismatch count.
    Incompatible sections remain **visible but dimmed**, each with a small **mismatch badge**
    (e.g. `⚠3`). Perfect-fit sections get a highlight ring. **Nothing is hidden.**
  - A one-line **summary** states what is being matched, e.g.
    *"Ranked vs ↑ up, ← left (top half) — ↓ down skipped (blocked)"*, so ranking is never opaque.
  - Re-ranks client-side when `activeHalf` flips or a different screen is selected.
- A **"Suggest pairs"** button opens a small panel of the top ~12 top+bottom combinations
  (paired thumbnails reusing `api.getTileSectionPreviewUrl`, with a combined score). Clicking
  a pair applies both halves. The panel is independent of the active-half grid so the two
  modes don't conflict.
- **Loading/empty states:** if the table hasn't loaded, the toggle shows a brief loading
  state and the grid stays unfiltered; the feature degrades gracefully (never blocks normal
  picking).

## Files Touched

- `src/tmos_randomizer/api/server.py` — **new** `GET /api/rom/tilesection-walkability`
  endpoint (+ a small cached builder, e.g. `compute_tilesection_walkability(rom_data)` near
  the existing tile helpers).
- `ui/src/api/client.ts` — **new** `getTileSectionWalkability()` + response type.
- `ui/src/store/index.ts` — **new** `tileWalkability` state + lazy loader (session-cached).
- `ui/src/components/screen/tileFilter.ts` — **new** pure util: edge slicing, screen-edge
  assembly, per-position compatibility, active-half ranking, pair scoring.
- `ui/src/components/screen/tileFilter.test.ts` — **new** unit tests.
- `ui/src/components/screen/ScreenEditorModal.tsx` — toggle, ranked/dimmed grid, summary
  line, "Suggest pairs" panel. (This file is now in scope — Spec #1 left it untouched; this
  spec modifies it.)

## Testing

- **Backend:** unit-test `compute_tilesection_walkability` against known sections (a known
  wall/dungeon section → mostly `'0'`; a known open overworld section → mostly `'1'`) and an
  endpoint test asserting 471 entries each of length 32 over `[01]`. ROM-gated like existing
  tile tests.
- **Frontend (`tileFilter.ts`, pure, node-env vitest — matches the repo's util-only test
  convention):** edge slicing (rows/cols correct), screen-edge assembly from two section
  grids, per-position compatibility (`1`-vs-`0` mismatch, `0`-vs-`0` and `1`-vs-`1` pass),
  active-half → which-neighbors mapping (top vs bottom), mismatch ranking order, neighbor
  skip for `0xFF`/`0xFE`, out-of-range/missing-section → max-mismatch, and pair scoring
  (internal seam + neighbor fit).
- **`ScreenEditorModal`** wiring verified by `tsc`/lint/manual (consistent with Spec #1's
  approach for `.tsx`).
- **Manual:** toggle on for a screen with known neighbors → perfect-fit sections sort first
  and highlight; flip halves → ranking switches to the down/lower neighbors and the summary
  updates; pick a dimmed section → still works (nothing blocked); "Suggest pairs" → applies
  both halves with a clean internal seam.

## Risks / Open Notes

- **Walkability ≠ navigability.** Matching edges prevents *visual/collision* seams; it does
  not guarantee the randomizer's navigability graph. This is a picker aid, not a validator —
  it complements, and does not replace, the existing edge validators.
- **Category divergence to confirm during implementation:** V2's `DEADLY_TILES` and the
  World Editor's `HAZARD_TILES` differ slightly (e.g. `0xE9`). The endpoint uses **V2's**
  authoritative tables; no World Editor code is imported. (Note: the earlier project memory
  said to *port* the World Editor's `edges_compatible`/`compatible_neighbors` — that premise
  is now stale; V2 grew its own primitives. The memory should be updated.)
- **Pair helper K-cap** (K ≈ 40 per half) is a heuristic to bound K×K scoring; if it ever
  hides a good pair, raising K is cheap. The cap is disclosed in the UI ("top suggestions").

## Follow-on (Spec #3)

**Theme / biome coherence:** a section-theme heuristic (palette / CHR bank / dominant tile
category / biome) used to (a) add a **theme filter** to the picker and (b) offer a
**coherent whole-screen swap** to a matching top+bottom pair — so a dungeon bottom is never
paired with an overworld top by *look*, not just by collision. Separate brainstorm/spec.
