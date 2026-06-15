# Design: Tile-Section Picker — whole-section thumbnails + screen context header

**Date:** 2026-06-15
**Project:** TMOS_Randomizer_V2 (React UI)
**Status:** Approved design — ready for implementation plan
**Builds on:** `2026-06-15-clickable-tile-sections-design.md` (the picker this enhances)

## Problem

The tile-section picker modal (`TileSectionPicker.tsx`) has two usability gaps:

1. **Thumbnails are small and use `object-cover`** — the user wants to clearly see the
   *whole* tile section while choosing.
2. **No screen context** — when picking a top or bottom section, the user can't see the
   screen they're editing or what surrounds it, so they can't tell what they're pairing
   the section with.

## Decisions (confirmed with user)

- **Preview behavior: fixed current screen.** The context header shows the selected screen
  as it currently is. It does NOT recompose on hover. (Rejected: live hover-composite — it
  would require backend render overrides; the user chose the simpler fixed view.)
- **Surrounding screens: spatial 3×3 block.** Center = selected screen; the 8 surrounding
  cells show physically adjacent screens, faded/transparent.
- **3×3 source: nav-pointer composition** (not the map's BFS layout engine). In this game
  the nav pointers *are* the spatial layout — the Navigation Map is built from them
  (`nav_right` → east, etc.). So orthogonal neighbors match the map exactly; diagonals are
  derived by composing two nav hops (best-effort). (Rejected: extracting the map's
  section-scoped BFS layout for pixel-perfect diagonals — heavier, needs the screen's
  section threaded in; not worth it for a context strip.)

**No backend changes.** Everything is frontend, using existing endpoints
(`/api/rom/render/{ch}/{screen}` via `ScreenMini`) and existing `ScreenData` fields.

## Architecture

All changes are in `ui/src/components/screen/`.

### 1. Whole, bigger thumbnails — `TileSectionPicker.tsx`

- `SectionThumb` image: `object-cover` → `object-contain` (the section render is 8×4 tiles
  = 2:1, the cell is `aspectRatio: 2/1`; `contain` guarantees no cropping regardless).
- Request a higher render scale for crispness (`getTileSectionPreviewUrl(globalIndex, chr, 3)`).
- Widen the modal container (`w-[640px]` → `w-[820px]`, keep `max-h-[80vh]`) and change the
  grid from `grid-cols-6` → `grid-cols-4`, roughly doubling thumbnail size.
- Keep: lazy IntersectionObserver loading, the `index`/`*` bank marker, selection highlight,
  `onError` fallback, the bank-1 footnote.

### 2. Context header — `ScreenNeighborhood.tsx` (new)

A component pinned at the top of the dropdown, between the title bar and the scrolling
thumbnail grid (so it stays visible while scrolling sections).

**Pure helper** (same file, exported for clarity/testability):

```
type Neighborhood = {
  // 3x3, row-major: [NW, N, NE, W, center, E, SW, S, SE]
  cells: (ScreenData | null)[];
};

function buildNeighborhood(
  selected: ScreenData,
  byIndex: Map<number, ScreenData>,
): Neighborhood
```

Rules:
- `NAV_BLOCKED = 0xFF`, `NAV_BUILDING = 0xFE` → treat as "no neighbor" (null cell).
- Orthogonals: `N = byIndex.get(selected.nav_up)` (if valid), etc.
- Diagonals via two-path composition, first valid wins, else null:
  - `NE` = `N`'s `nav_right`, else `E`'s `nav_up`
  - `NW` = `N`'s `nav_left`,  else `W`'s `nav_up`
  - `SE` = `S`'s `nav_right`, else `E`'s `nav_down`
  - `SW` = `S`'s `nav_left`,  else `W`'s `nav_down`
- A helper `resolve(idx)` returns `byIndex.get(idx)` only when `idx` is a real screen and
  not blocked/building; otherwise null.

**Render:**
- 3×3 CSS grid. Each non-null cell renders the existing `ScreenMini` (from
  `ScreenRenderer.tsx`) at a fixed small `size` (~84px wide; it keeps 4:3 internally).
- **Center**: full opacity (`tileOpacity={1}`), a ring/border to mark it, small "current"
  label.
- **Neighbors**: faded via `ScreenMini`'s existing `tileOpacity` prop (~0.35).
- **Null cells**: a dim empty placeholder (`bg-slate-900/40`, same footprint) so the grid
  stays aligned.
- A one-line caption: e.g. "Selected screen (center) and its neighbors — pairing context."

`ScreenMini` already renders through `/api/rom/render/...` with the screen's current tiles,
supports `tileOpacity`, and has an `onError` fallback — reuse it as-is; no changes to
`ScreenRenderer.tsx`.

### 3. Data threading

- `ScreenDetailPanel` already has `screens: ScreenData[]` and `chapterNum`. Pass both into
  `<TileSectionPicker ... screens={screens} chapterNum={chapterNum} />`.
- `TileSectionPicker` forwards `screen` (the selected one), `screens`, `chapterNum` into
  `TileSectionDropdown`, which builds `byIndex = new Map(screens.map(s => [s.index, s]))`
  once (useMemo) and renders `<ScreenNeighborhood selected={screen} byIndex={byIndex}
  chapterNum={chapterNum} />`.
- `screens` may be `undefined` (the prop is optional on `ScreenDetailPanel`); when absent or
  empty, render the dropdown without the neighborhood header (graceful degrade).

## Data flow

```
open picker → TileSectionDropdown renders:
  [ ScreenNeighborhood: buildNeighborhood(selected, byIndex) → 9 cells ]
      center = current screen (ScreenMini, opacity 1)
      neighbors = ScreenMini opacity 0.35 (current tiles, via render endpoint)
  [ scrollable grid-cols-4 of section thumbnails (object-contain, larger) ]
pick a section → unchanged from existing behavior (PATCH → store merge → re-render)
```

The neighborhood is read-only context; picking a section does not change it (fixed-preview
decision). After a pick the panel re-renders and, if reopened, the header reflects the new
current tiles.

## Error handling

- Missing/blocked/building neighbor → null cell → dim placeholder (no request fired).
- `ScreenMini` image load failure → its existing colored fallback.
- `screens` undefined/empty → omit the neighborhood header; thumbnail grid still works.
- Self-referential or out-of-range nav indices → `resolve()` returns null (guarded by
  `byIndex.has` + blocked/building checks).

## Testing

- `buildNeighborhood` is pure and exported. This UI has **no unit-test harness** (consistent
  with the prior feature); verification is live in the running app via Playwright:
  - Open the picker on a mid-map screen → header shows a 3×3 with the center highlighted and
    faded neighbors; orthogonal cells match the screen's `nav_*` targets.
  - Open the picker on an edge/orphan screen → blocked directions show empty placeholders,
    grid stays aligned.
  - Thumbnails render the full section (no cropping) and are visibly larger (grid-cols-4).
  - Picking a section still updates the screen (regression check of the base feature).

## Out of scope

- Live hover-composite of the candidate section into the center screen (needs backend
  render overrides) — explicitly deferred.
- Pixel-perfect diagonal fidelity to the map's BFS layout.
- Reconciling the pre-existing bit-model "Top/Bottom Tile Bank" rows (tracked separately).
