# Design: World Screen Editor Modal (Stage A)

**Date:** 2026-06-15
**Project:** TMOS_Randomizer_V2 (React UI + FastAPI)
**Status:** Approved design — ready for implementation plan
**Parallel sibling:** `2026-06-15-objectset-enemy-thumbnails.md` (Stage B). The two share one
seam — the `ObjectSetField` component contract (below). Stage A ships it; Stage B enhances
its internals only.
**Builds on:** the merged tile-section picker + 3×3 `ScreenNeighborhood` context header.

## Problem

The tile-section picker modal should become a small **world-screen editor**: edit the
low-risk WorldScreen fields (ObjectSet, Content, Event, palette colors) alongside the tile
sections, live, across multiple screens in one modal session. Excluded by user direction:
parent_world, ambient_sound (music), navigation, exit_position, datapointer/chr (managed via
tile-section bank logic).

## Decisions (confirmed)

- Modal stays open on every edit (live); closes only via ×/overlay.
- Clicking a neighbor screen changes the **global** selected screen (panel + map follow) and
  re-centers the modal.
- Editable fields: Top/Bottom TileSection (existing), **ObjectSet, Content, Event,
  WorldScreen color, Sprite color**.
- **Tile-half selection by clicking the screen preview:** click the active screen's top
  region (rows 0–3) → edit Top section; bottom region (rows 4–5) → edit Bottom. Selected half
  shaded. When Bottom is active, the bottom 2 rows of every section thumbnail are shaded
  (a screen's bottom uses only the section's top 2 rows — see `build_screen_tile_grid`).
- ObjectSet images are Stage B; Stage A ships ObjectSet as select-with-descriptions + input.

## The shared seam — `ObjectSetField`

```tsx
// ui/src/components/screen/ObjectSetField.tsx
interface ObjectSetFieldProps {
  value: number;            // current objectset byte (0-255)
  chapterNum: number;
  chr: number;              // CHR index of the active screen (Stage B context)
  onChange: (v: number) => void;
}
```
Stage A implementation: a `<select>` of known ObjectSet ranges (from the existing
`getObjectSetDescription` mapping, enumerated as labeled options) + a raw 0–255 number input,
kept in sync; calls `onChange`. Stage B adds an enemy-thumbnail strip **inside** this
component without changing the props or the modal.

## Architecture (all frontend except the one endpoint)

### Backend — `src/tmos_randomizer/api/server.py`

`PATCH /api/rom/screen/{chapter_num}/{screen_index}/fields`
- Pydantic `ScreenFieldsUpdate { objectset?, content?, event?, worldscreen_color?, sprites_color? }` — all `Optional[int]`.
- Strict allowlist: only those five fields. Validate each provided value is 0–255 (400 otherwise); 400 no-ROM, 404 missing chapter/screen; 400 if no field provided — same guard order as the tiles PATCH.
- Set each provided attribute on the screen, `screen.mark_modified()`, return the standard
  screen dict (same shape/keys as the tiles PATCH `screen` object).
- A pure helper isn't needed (direct attribute set); but the allowlist must be explicit in code
  so parent_world/ambient_sound/etc. can never be set here.

### Frontend

**`client.ts`:** `updateScreenFields(chapterNum, screenIndex, fields)` → the new PATCH; reuse
`ScreenTilesUpdateResponse`-shaped result (`{ status, screen: ScreenData }`).

**`store/index.ts`:** `updateScreenFields(screenIndex, fields)` action — same call-PATCH-then-
merge-into-`chapterData.screens` pattern as `updateScreenTiles`.

**`ScreenDetailPanel.tsx`:** owns the modal. New state: `editorOpen: boolean`,
`activeHalf: 'top' | 'bottom'`. Renders one `<ScreenEditorModal>` when `editorOpen`. The
panel's value displays for Top/Bottom tiles, ObjectSet, Content, Event, and the two colors
become buttons that open the editor (tile buttons also set `activeHalf`). The existing
`handlePickTile` is reused for tile picks; a new `handleFieldChange(field, value)` calls the
store's `updateScreenFields`. `onScreenSelect` (already a prop) is threaded in for neighbor
navigation.

**`ScreenEditorModal.tsx` (new — evolves today's `TileSectionDropdown`):**
- Props: `screen, screens, chapterNum, activeHalf, onHalfChange, onClose, onScreenSelect, onFieldChange, onTilePick`.
- Header "Edit World Screen — #X".
- `<ScreenNeighborhood>` with the center as the **half-selector** (see below) and clickable
  neighbors (`onScreenSelect`).
- A **Fields** block: `<ObjectSetField>` (seam) + `<EnumSelectField>` instances for Content,
  Event, WS color, Sprite color.
- The **section grid** (the existing 471-thumbnail `SectionThumb` grid, kept with the
  `grid-auto-rows` shape fix), driven by `activeHalf`: highlight = the active half's current
  global section; `onClick` → `onTilePick(globalIndex)` (does NOT close); when
  `activeHalf==='bottom'`, pass a `shadeBottomRows` flag so each thumbnail shades its lower
  half.

**`ScreenNeighborhood.tsx` (extend):**
- Add `onSelect?(screenIndex)` — non-center cells become clickable (ScreenMini `onClick`).
- The **center cell** gains two clickable zones overlaid on the rendered screen: a top zone
  (upper 4/6 = rows 0–3) and a bottom zone (lower 2/6 = rows 4–5), wired to
  `onHalfSelect('top'|'bottom')`; the active half gets a translucent shade + label. Bump the
  neighborhood cell size modestly (~100px) so the zones are comfortably clickable.

**`EnumSelectField.tsx` (new, reusable):** props `{ label, value, options: {value:number,label:string}[], onChange }` — a `<select>` of known values + a 0–255 number input kept in sync. Used for Content (from `CONTENT_TYPES`+chapter NPCs), Event (`EVENT_TYPES`), and the two colors (a small known-color list from the renderer's `getGroundColor` cases).

**`SectionThumb` (extend):** accept `shadeBottomRows?: boolean`; when true, overlay a
semi-opaque band over the lower 50% of the thumbnail (the unused rows 2–3).

## Data flow

```
open editor (click any field) → ScreenEditorModal
  center screen: click top/bottom zone → onHalfChange → activeHalf, grid re-keys + re-shades
  field edit → onFieldChange → store.updateScreenFields → PATCH → merge → live re-render
  tile pick (active half) → onTilePick → store.updateScreenTiles → PATCH → merge → live
  neighbor click → onScreenSelect → store.setSelectedScreen → panel re-renders, modal re-centers
close → ×/overlay
```
Because the component tree persists across selection changes (no remount), the modal stays
open while navigating; all sub-views read the (updated) `screen`/`screens` props.

## Error handling

- Field/tile out-of-range → 400, surfaced via existing `apiError`.
- `screens` absent → neighborhood header omitted (existing graceful degrade); fields still work.
- Cross-bank tile note continues to render in the panel; acceptable (modal covers it).

## Testing

- Backend: `PATCH .../fields` happy path per field + out-of-range 400 + missing-screen 404,
  via the existing skip-graceful `TestClient` pattern; assert parent_world/ambient_sound are
  rejected/ignored (allowlist).
- Frontend: no unit harness — verify live in the running app (Playwright): open editor, edit
  each field and see the live re-render; click top/bottom zones and confirm shading + which
  half the grid edits; navigate to a neighbor; confirm the modal stays open throughout.

## Out of scope (→ Stage B / elsewhere)

- ObjectSet enemy thumbnails (Stage B, via the `ObjectSetField` seam).
- Editing parent_world, ambient_sound, navigation, exit_position.
