# Selected World Screen Panel — Design

**Date:** 2026-06-24
**Status:** Approved (design); ready for implementation plan
**Area:** `projects/TMOS_Randomizer_V2/ui` (React/TypeScript frontend)
**Scope:** Spec #1 of 2. (Spec #2 = Edit-modal tile-picker collision/theme filtering — separate doc, not started.)

## Problem

The World tab's screen sidebar (`ScreenDetailPanel`) is a docked 320px column that
consumes layout width and presents data as a fixed set of curated sections. It does
not surface every worldscreen byte, and it does almost nothing to connect a screen to
the rest of the app (enemies, allies, tile graphics, shops, palettes).

## Goal

Replace it with a **floating "Selected World Screen" panel** that:

1. Floats over the map (top-right), freeing the map to full width.
2. Surfaces **all 16 worldscreen bytes** in a Raw Data table (name · hex · decoded label).
3. On clicking a byte row, shows a **detail/links box** with that byte's description,
   warning, and **cross-links** into the relevant part of the app.
4. Becomes the **primary mechanism that ties the app together** — the place where a
   screen's data points you to the enemy set, ally, tile sections, shop, or palette it
   references.

The in-depth **Edit World Screen modal (`ScreenEditorModal`) is unchanged** — the panel's
"Edit World Screen" button opens it exactly as today.

## Non-Goals

- No changes to `ScreenEditorModal` (tile editing stays as-is; improvements are spec #2).
- No new backend endpoints. All data already exists:
  `/api/metadata/fields`, `/api/rom/chapter/{n}`, `/api/rom/objectset/{ch}/{id}/enemies`.
- Shop-inventory and per-screen EXP mappings are **not decoded**; we link to the relevant
  panel with an honest "exact mapping not yet decoded" note rather than fabricating rows.

## Data Sources (already available)

- **`/api/metadata/fields`** → `entities.worldscreen.fields`: the 16 bytes, each with
  `label`, `byte` (ROM order), `tier` (safe/caution/danger), `control` (enum/number),
  `enum` (value→label), `description`, `warning`, `used_by`. Loaded once into
  `store.fieldMetadata`.
  - **Key mapping:** metadata keys `screen_index_right/left/down/up` correspond to
    `ScreenData.nav_right/left/down/up`. All other keys match `ScreenData` 1:1.
  - ROM byte order: `0 parent_world, 1 ambient_sound, 2 content, 3 objectset,
    4 nav_right, 5 nav_left, 6 nav_down, 7 nav_up, 8 datapointer, 9 exit_position,
    10 top_tiles, 11 bottom_tiles, 12 worldscreen_color, 13 sprites_color, 14 unknown,
    15 event`.
- **`screenEnums.ts`** (`CONTENT_TYPES`, per-chapter `CHAPTER_NPCS`, `EVENT_TYPES`) and
  the parent-world map: richer human labels than the sparse metadata enums. Preferred for
  display.
- **`ScreenData`** (the selected screen) holds the live byte values.

## Architecture

### Component layout (top → bottom)

A rewritten `ScreenDetailPanel` (the "Selected World Screen" panel), rendered as a
floating card:

1. **Header** — `Screen #17 / 0x11`, PRESENT/PAST badge, global-index subline,
   **Edit World Screen** button (opens `ScreenEditorModal`), **collapse** chevron,
   **close** ×.
2. **Preview** — `ScreenRenderer` thumbnail + one-line content summary (icon + name).
3. **Spatial nav grid** — the existing up/down/left/right grid, kept directly under the
   preview (it is genuinely spatial, not tabular). Clicking a direction navigates.
4. **Raw Data table (primary)** — all 16 bytes in ROM order. Columns:
   **Field name · Hex · Decoded label**. Each row shows a tier dot
   (safe/caution/danger). Rows are clickable; the selected row is highlighted.
5. **Detail / links box** — appears below the table when a row is selected. Shows the
   field's `description`, `warning` (if any), `used_by`, the decoded value, and the
   **cross-links** for that byte (see registry below).

### Floating container (`WorldView`)

- Remove the docked `w-80 border-l` column. The map area becomes full-width.
- Render the panel as `absolute top-3 right-3`, fixed width ≈ 340px,
  `max-height: calc(100% - 1.5rem)`, internal scroll, shadow, rounded, slightly
  translucent slate background. The map container becomes `relative` so the panel
  positions against it.
- Collapse state lives in panel component state (session-only). Collapsed = title bar only.
- Panel shows only when `selectedScreen != null` (unchanged trigger).

### Label resolution — `byteLabels.ts` (new util)

`resolveByteLabel(fieldKey, value, chapterNum): { text: string; tier: SafetyTier }`

- Prefers the frontend enum tables: content → `CONTENT_TYPES` + `CHAPTER_NPCS[chapter]`,
  event → `EVENT_TYPES`, parent_world → parent-world map.
- Falls back to the metadata `enum` (value→label), then to raw `0xNN`.
- `tier` comes from the metadata field.
- Nav bytes decode `0xFF` → "Blocked", `0xFE` → "Building", else "Screen 0xNN".

### Cross-link registry — `screenLinks.ts` (new util)

`screenLinksFor(fieldKey, value, screen, chapterNum): ScreenLink[]`
where `ScreenLink = { label: string; note?: string; onActivate: () => void }`.

| Byte | Link |
|---|---|
| `objectset` | Enemies tab → Overworld section, focused on this objectset's enemies. Also renders the enemy sprite strip inline (via `getObjectSetEnemies`). |
| `content` NPC `0x80–0x8F` | Allies tab → that ally selected (matched by content byte + chapter). |
| `content` boss stage `0x21–0x2A` | Enemies tab → Bosses section. |
| `content` shop `0x60–0x7D` | Advanced/Expert → Economy & Shops (note: per-screen→shop_index not decoded; opens the panel). Calls `unlockExpert()` first. |
| `content`/`event` Time Door / `event` stairway `0x40` | Navigate to linked destination screen (stairway dest = content byte). |
| `top_tiles` / `bottom_tiles` | Graphics tab → that tile section (`navigateToTile`). |
| `worldscreen_color` / `sprites_color` | Advanced → Cosmetic (palette). |
| `nav_right/left/down/up` | Navigate to destination screen (stays in World view via `onScreenSelect`). |

### Generic cross-navigation — store change

Destination views currently keep section/selection in local `useState`, so a link can
switch the tab but cannot land on the right item. Add a generic focus mechanism to the
zustand store:

```ts
focusTarget: { tab: TabType; section?: string; kind?: string; id?: number } | null
setFocusTarget(target): void      // sets focusTarget AND selectedTab
consumeFocusTarget(): FocusTarget  // returns + clears (one-shot)
```

Destination views read it once on mount/update and clear it:

- **`AlliesView`** — lift `selectedAlly` seed from focus (`kind: 'ally', id: allyId`),
  resolving content-byte+chapter → ally id.
- **`EnemiesView`** — lift `section` (`'overworld'` / `'bosses'`) and optional enemy
  highlight from focus.
- **`AdvancedView`** — lift `sub` sub-tab (`'economy'` / `'cosmetic'`) from focus.
- **Graphics** — reuse the existing `navigateToTile(index)` (already sets tab + tile).

This focus mechanism is the reusable backbone for "tie the app together" and will serve
future cross-links beyond this panel.

## Files Touched

- `components/screen/ScreenDetailPanel.tsx` — rewrite into the floating Selected World
  Screen panel (header, preview, nav grid, Raw Data table, detail/links box).
- `components/views/WorldView.tsx` — full-width map + floating-panel container.
- `components/screen/byteLabels.ts` — **new**: `resolveByteLabel`, field-key↔ScreenData map.
- `components/screen/screenLinks.ts` — **new**: cross-link registry.
- `store/index.ts` — **new**: `focusTarget` + `setFocusTarget` + `consumeFocusTarget`.
- `components/views/AlliesView.tsx`, `EnemiesView.tsx`, `AdvancedView.tsx` — consume
  `focusTarget` to land on the right section/item.

## Testing

- `byteLabels`: unit-test resolution for each control type (enum/number/nav) and the
  enum-vs-metadata-vs-hex fallback order, including per-chapter NPC labels.
- `screenLinks`: unit-test that each byte yields the expected link target(s) for
  representative values (objectset overworld, content NPC/boss/shop, tiles, palettes,
  nav).
- Manual: select a screen → table shows 16 rows with correct hex + labels; clicking a
  row reveals detail + links; each link lands on the right tab/section/item; panel floats
  top-right, collapses, and closes; map is full-width.

## Risks / Open Notes

- Shop and EXP mappings are undecoded — links are honest "open panel + note", not precise
  rows. Acceptable per goal (most value with truthful gaps).
- `EnemiesView`/`AdvancedView`/`AlliesView` lifting local state to a store-seeded initial
  value must not regress their normal (non-linked) usage — focus is one-shot and only
  seeds the initial section/selection.

## Follow-on

**Spec #2 — Edit-modal tile-picker filtering** (separate brainstorm/spec): filter the
471-tilesection picker to ease world-building, including neighbor **collision matching**
(port `tmos_world` `edges_compatible`/`compatible_neighbors` into V2 `core/` + a new
endpoint), a **theme** heuristic (to be defined), choosing top/bottom **combinations**
that work with neighbors, and a **whole-screen tileset swap** to coherent top+bottom
pairs (no dungeon-bottom + overworld-top mismatch).
