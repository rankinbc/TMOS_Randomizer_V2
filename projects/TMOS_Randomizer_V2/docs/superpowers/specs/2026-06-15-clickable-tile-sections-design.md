# Design: Clickable Tile Sections with Section-Picker Dropdown

**Date:** 2026-06-15
**Project:** TMOS_Randomizer_V2 (React UI + FastAPI backend)
**Status:** Approved design — ready for implementation plan

## Problem

In the screen detail panel (`ScreenDetailPanel.tsx`, "Graphics (DataPointer)" section),
the **Top TileSection** and **Bottom TileSection** values are read-only text. The user
wants them clickable: clicking a value opens a scrollable dropdown that renders all
possible tile sections, and selecting one updates the tiles on the currently selected
screen, live.

## Domain background (why this isn't a one-liner)

A tile-section value stored on a `WorldScreen` (`top_tiles` / `bottom_tiles`) is a single
**0–255 byte**. But the game has **471 tile sections** (`TILESECTION_COUNT = 471`). The
sections above 255 live in "bank 1." The bank for each half is **not** encoded in the byte —
it is derived from the screen's **DataPointer** via value ranges
(`get_bank_offset` in `rendering/screen_renderer.py`):

| DataPointer range | Top bank | Bottom bank |
|-------------------|----------|-------------|
| `< 0x40`          | 0        | 0           |
| `0x40–0x8E`       | 0        | 1           |
| `0x8F–0x9F`       | 1        | 0           |
| `>= 0xC0`         | 1        | 1           |

A section read uses global index `byte + bank_offset` where `bank_offset ∈ {0, 256}`
(`read_tilesection`: `address = TILESECTION_BASE(0x03C4C7) + index * 32`).

The DataPointer **also** carries the CHR bank index (`chr_index = datapointer & 0x3F`),
which selects tile graphics. Consequences:

- Within the current DataPointer bank, **256 sections** are reachable per half by changing
  only the byte — zero side effects.
- Reaching a section in the *other* bank requires rewriting the DataPointer, which can
  change the *other* half's bank and/or the CHR bank.
- The combo **top bank 1 + bottom bank 0** forces DataPointer into `0x8F–0x9F`, so CHR
  clamps to `0x0F–0x1F`. This is the only combo that cannot always preserve CHR.

A global section index `g ∈ [0, 470]` decomposes as: `bank = 1 if g >= 256 else 0`,
`byte = g - 256*bank`.

### ⚠️ Two conflicting bank models in the codebase

The codebase contains **two disagreeing** models for how the DataPointer selects banks:

- **Bit model** — `get_chr_index` / `get_all_valid_datapointers` in `core/constants.py`:
  `datapointer = chr | (top_bank << 7) | (bottom_bank << 6)`, i.e. the four valid
  DataPointers for a CHR are `[chr, chr+0x40, chr+0x80, chr+0xC0]`.
- **Value-range model** — `get_bank_offset` in `rendering/screen_renderer.py` (claims to
  match TMOS_Romhack1): the table above.

They agree for combos `(0,0)`, `(0,1)`, `(1,1)`, but **disagree for `(1,0)`**: the
value-range model only yields `(1,0)` for DataPointer `0x8F–0x9F` (CHR `0x0F–0x1F`),
whereas the bit model yields `(1,0)` for any `chr | 0x80`.

**The renderer (`get_bank_offset`) is authoritative** for this feature, because it is what
actually produces the images the user sees. We compute DataPointers against it. The
`(1,0)` constraint (CHR clamps to `0x0F–0x1F`) is the "cross-bank CHR shift" the picker
warns about. The implementation plan must NOT use `get_all_valid_datapointers` for this,
and should include a task to verify the `(1,0)` behavior against the real ROM and, if the
value-range model proves wrong, reconcile the two (out of scope to fix here unless the
verification forces it).

## Decisions (confirmed with user)

- **Preview style:** section half only — render the candidate section's 4-row block in
  isolation (not the whole screen).
- **Option set:** all 471 sections; picking one outside the current bank also rewrites the
  DataPointer (bank).
- **Persistence:** in-memory live edit — mirrors the existing navigation PATCH; the change
  flows into the eventual ROM export/apply path. No separate save step.
- **Cross-bank CHR shift:** allow-but-warn. The picker flags sections that would change the
  DataPointer/CHR; the panel notes the change after applying. (Rejected alternative:
  restrict the dropdown to the current bank's 256 sections — simpler but violates the
  "all 471" decision.)

## Architecture

### Backend (`src/tmos_randomizer/api/server.py`)

**1. Section preview endpoint — `GET /api/rom/tilesection/{index}`**
- Query params: `chr` (CHR bank, 0–63, default 0), `scale` (1–8, default 4).
- Reads section `index` (0–470) directly: 32 bytes at `TILESECTION_BASE + index*32`,
  build 4×8 grid via `get_tilesection_grid`, render with the given CHR bank.
- Decoupled from any screen/DataPointer — this is what lets the dropdown show all 471
  sections without bank gymnastics.
- Returns PNG (with `Cache-Control: public, max-age=...` since section bytes are static
  for a loaded ROM).
- Add a small renderer helper (e.g. `render_tilesection_to_bytes(index, chr_bank, scale)`)
  in `rendering/screen_renderer.py` rather than duplicating render logic in the route.

**2. Tile update endpoint — `PATCH /api/rom/screen/{chapter_num}/{screen_index}/tiles`**
- Body: `{ top_tiles?: int, bottom_tiles?: int }` where each is a **global section index
  (0–470)**.
- For each provided half: split into `(byte, bank)`. Compute a new DataPointer that yields
  the required bank for that half while preserving the other half's current bank and the
  CHR index wherever the value-range rules allow (see table). When the requested combo is
  `(top=1, bottom=0)` and current CHR ∉ `0x0F–0x1F`, clamp CHR into `0x0F–0x1F` and report
  it in the response.
- Set `screen.top_tiles` / `screen.bottom_tiles` to the byte, set `screen.datapointer`,
  call `screen.mark_modified()`.
- Validate indices are in `[0, TILESECTION_COUNT)`; 400 on out-of-range. 400 if no ROM,
  404 for missing chapter/screen — same guards as the navigation PATCH.
- Response mirrors the navigation PATCH shape: `{ status, screen: <full screen dict> }`
  (full screen dict via the same field set used elsewhere), plus a
  `datapointer_changed: bool` / `chr_changed: bool` hint for the UI note.

**Datapointer computation helper** (pure function, unit-testable in isolation):
`compute_datapointer(top_bank, bottom_bank, current_chr) -> (datapointer, chr_used)`.
This is the riskiest logic; it gets dedicated tests covering all four bank combos and the
CHR-clamp case.

### Frontend

**3. `ui/src/api/client.ts`**
- `updateScreenTiles(chapterNum, screenIndex, { top_tiles?, bottom_tiles? })` → PATCH #2.
- `getTileSectionPreviewUrl(index, chr, scale?)` → URL for endpoint #1.
- Response type `ScreenTilesUpdateResponse { status; screen: ScreenData; datapointer_changed; chr_changed }`.

**4. `ui/src/store/index.ts`**
- `updateScreenTiles(screenIndex, update)` action — same shape as `updateScreenNavigation`:
  call API, merge the returned screen into `chapterData.screens`, `set(...)`. Because
  `top_tiles`/`bottom_tiles`/`datapointer` change, `ScreenRenderer`'s cache-busting URL
  changes and the preview re-renders automatically. No new global state.

**5. `ui/src/components/screen/TileSectionPicker.tsx` (new)**
- Props: `which: 'top' | 'bottom'`, `screen`, `chapterNum`, `onPick(globalIndex)`.
- Renders the current value as a clickable button (replaces the static `DataRow` for Top
  and Bottom in `ScreenDetailPanel`).
- On open: a scrollable popover/grid of all 471 section thumbnails, lazy-loaded
  (IntersectionObserver or windowing) so we don't fire 471 requests at once. Thumbnails use
  endpoint #1 with the screen's current CHR. Current selection highlighted; hover shows
  index + bank. Sections whose selection would change the DataPointer/CHR are visually
  flagged.
- Pick → `onPick(globalIndex)` → store `updateScreenTiles`. After apply, if
  `datapointer_changed`, show a brief inline note in the panel.

**6. `ui/src/components/screen/ScreenDetailPanel.tsx`**
- Replace the two static `DataRow`s for Top/Bottom TileSection with `TileSectionPicker`
  instances. Wire an `updateScreenTiles` call (from the store, via a passed callback or
  direct store hook consistent with how `NavigationMapView` consumes the store).

## Data flow

```
click Top/Bottom value
  → TileSectionPicker opens
  → thumbnails render via GET /api/rom/tilesection/{i}?chr=<screen chr>
  → user picks global index g
  → store.updateScreenTiles(screenIndex, { top_tiles: g })
  → PATCH /api/rom/screen/{ch}/{idx}/tiles
  → backend sets byte + datapointer, returns updated screen
  → store merges into chapterData.screens
  → ScreenDetailPanel + ScreenRenderer re-render (live)
```

## Error handling

- Out-of-range section index → 400 (backend), surfaced via existing `apiError` store field.
- No ROM / missing chapter/screen → 400/404, same as navigation PATCH.
- Thumbnail render failure → per-image `onError` fallback (reuse the colored-fallback
  pattern already in `ScreenRenderer`).
- CHR clamp on the `(1,0)` combo → not an error; reported via `chr_changed` and shown as a
  panel note.

## Testing

- **Backend unit:** `compute_datapointer` for all four bank combos + CHR-clamp case
  (expected, edge, failure). `render_tilesection_to_bytes` returns non-empty PNG for a valid
  index; raises/400 path for out-of-range.
- **Backend API:** PATCH updates `top_tiles`/`bottom_tiles` and `datapointer` correctly for
  a same-bank pick (no datapointer change) and a cross-bank pick (datapointer changes);
  out-of-range → 400.
- **Frontend:** `TileSectionPicker` renders a button with the current value, opens the
  popover, calls `onPick` with the correct global index; store `updateScreenTiles` merges
  the returned screen. (Follow existing UI test conventions in `ui/`.)

## Out of scope

- Editing CHR index / DataPointer directly (only changed as a side effect of section picks).
- Bulk/multi-screen tile edits.
- Persisting to a `.nes` file here — handled by the existing apply/export flow.
