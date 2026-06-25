# Screen Detail Panel — 2×2 Layout Redesign

**Date:** 2026-06-25
**Status:** Approved, ready for implementation
**Area:** `ui/` — single component, `ScreenDetailPanel.tsx`

## Problem

The selected-world-screen detail panel (`ScreenDetailPanel.tsx`) is a fixed **340px-wide vertical stack**: header, then tile preview → nav D-pad → field table → details box, each full-width and stacked top-to-bottom. With 17 field rows plus the preview, nav, and details, the panel runs very tall (off-screen) while leaving horizontal space unused.

## Goal

Rearrange the body into a **2×2 grid** so the panel is wider and much shorter, without changing any behavior, data, or styling of the inner pieces.

```
┌───────────────────────────────────────────────────────┐
│ Screen #115 / 0x73  [PRESENT]            [Edit][▾][×]   │  header (spans both cols)
├─────────────────────┬─────────────────────────────────┤
│   Nav D-pad         │     Tile display (square, bigger)│  row 1 (height = tile)
├─────────────────────┼─────────────────────────────────┤
│  Field table        │   Details (selected field)       │  row 2 (fills, table scrolls)
│  (scrolls if tall)  │   or "Select a field" hint       │
└─────────────────────┴─────────────────────────────────┘
```

Grid placement (DOM order inside a `grid grid-cols-2`):
1. Nav D-pad → top-left
2. Tile preview → top-right
3. Field table → bottom-left
4. Details box → bottom-right

## Requirements

1. **Panel width:** widen the root from `w-[340px]` to `w-[660px]`. Keep `max-h-[calc(100vh-7rem)]` and the `flex flex-col` root so the header stays pinned and the body can scroll within the viewport.
2. **Header unchanged:** title, time-period badge, global id, Edit / collapse / close buttons keep their current markup and behavior, spanning the full width above the grid.
3. **Collapsed state unchanged:** when `collapsed` is true, the body (grid) is hidden exactly as today.
4. **Body becomes a grid:** the `!collapsed` body is a `grid grid-cols-2 grid-rows-[auto_1fr] min-h-0 flex-1` (or equivalent) with column/row dividers using the existing `border-slate-700` treatment.
5. **Nav D-pad (top-left):** the existing 3×3 `NavCell` grid, unchanged internally. Sits in the top-left cell, vertically centered.
6. **Tile preview (top-right):** the existing `ScreenRenderer`, rendered larger than the current `scale={0.5}` so it fills a roughly square cell (target ≈ scale `0.9`–`1.0`; pick the value that fits the right column without horizontal overflow). Centered in its cell.
7. **Field table (bottom-left):** the existing `<table>` (Field / Hex / Label) unchanged internally, in the bottom-left cell with `overflow-y-auto min-h-0` so a tall table scrolls within the cell rather than growing the panel.
8. **Details box (bottom-right):** the existing selected-field detail/links box (including `ObjectSetEnemyStrip` and links) unchanged internally, in the bottom-right cell. When no field is selected (`selectedKey == null`), show a muted placeholder: "Select a field for details." (instead of rendering nothing).
9. **No logic changes:** `selectedKey` selection, `onScreenSelect`, `onEdit`, `onClose`, tooltips, byte-label resolution, and the enemy strip all keep their current behavior. This is a pure JSX/Tailwind rearrangement.

## Out of scope

- No changes to `ScreenRenderer`, `NavCell`, `byteLabels`, `screenLinks`, or any data/API.
- No responsive breakpoints beyond the fixed width (the panel is a desktop overlay); if the fixed `660px` is a concern on very small viewports it can be revisited later.
- No restyling of colors, fonts, or the inner components — only their container layout.

## Testing

- **Typecheck:** `npm run build` passes (no TS/JSX errors).
- **Full suite:** `npx vitest run` stays green (no component tests exist for this panel; this guards against collateral breakage).
- **Visual (Playwright):** with a screen selected on the World tab, confirm the panel renders the 2×2 grid — nav top-left, tile top-right, field table bottom-left, details bottom-right — the panel is visibly wider and shorter than before, the tile is a larger square, and selecting a field populates the bottom-right details cell (deselecting shows the placeholder).

## Footprint

1 file: `ui/src/components/screen/ScreenDetailPanel.tsx`. No new files, no dependencies.
