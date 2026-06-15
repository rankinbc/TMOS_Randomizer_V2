# Tile-Section Picker Context Header Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a faded 3×3 screen-context header to the tile-section picker modal and make the section thumbnails larger and uncropped.

**Architecture:** A new `ScreenNeighborhood` component (with a pure `buildNeighborhood` helper that derives a 3×3 spatial block from nav pointers) renders at the top of the existing picker modal, reusing `ScreenMini` to draw each screen. `TileSectionPicker` gains `screen`/`screens`/`chapterNum` props, threads them to the dropdown, widens the modal, and enlarges thumbnails. `ScreenDetailPanel` passes the data it already holds.

**Tech Stack:** React + TypeScript + Vite + Tailwind. No backend changes. **No UI unit-test harness exists** — verification is `tsc`/`vite build` + live Playwright in the running app (consistent with the prior feature).

**Reference spec:** `docs/superpowers/specs/2026-06-15-tile-section-picker-context.md`

**Run frontend commands from** `projects/TMOS_Randomizer_V2/ui/`.

---

## Domain cheat-sheet

- `ScreenData` (in `src/api/client.ts`) has `index`, `nav_up`, `nav_down`, `nav_left`, `nav_right`, plus tile fields. Nav values are **relative screen indices** matched against other screens' `.index` (same as the existing `NavCell` lookup). Sentinels: `0xFF` = blocked, `0xFE` = building entrance — neither is a real neighbor.
- `ScreenMini` (exported from `src/components/screen/ScreenRenderer.tsx`) signature: `ScreenMini({ screen, chapterNum, size=64, selected, onClick, showIndex=true, tileOpacity=1 })`. It renders the screen via `/api/rom/render/...` using the screen's **current** tiles, supports `tileOpacity` (fades only the tile graphics), and has a built-in colored fallback on image error. Internal aspect ratio is 4:3, so at `size=84` the rendered height is `round(84 * 384/512) = 63`px.
- Baseline: `npx tsc -b --noEmit` currently reports ~8 **pre-existing** errors (unused vars + 2 unrelated type mismatches), one of them `ScreenDetailPanel.tsx ... 'destIsPast' never read`. Success = the SAME pre-existing errors and ZERO new ones. Do NOT fix the pre-existing ones (out of scope).

---

## Task 1: ScreenNeighborhood component + buildNeighborhood helper

**Files:**
- Create: `src/components/screen/ScreenNeighborhood.tsx`

- [ ] **Step 1: Create the file**

Create `src/components/screen/ScreenNeighborhood.tsx` with EXACTLY this content:

```tsx
import type { ScreenData } from '../../api/client';
import { ScreenMini } from './ScreenRenderer';

// Nav sentinels — neither is a real neighbor screen.
const NAV_BLOCKED = 0xff;
const NAV_BUILDING = 0xfe;

// Each cell is the rendered ScreenMini footprint at size=84 (height = round(84*384/512)).
const CELL_W = 84;
const CELL_H = 63;

export interface Neighborhood {
  // Row-major 3x3: [NW, N, NE, W, center, E, SW, S, SE]
  cells: (ScreenData | null)[];
}

/**
 * Build a 3x3 spatial block around `selected` from nav pointers. In this game the
 * nav pointers ARE the spatial layout (the Navigation Map is built from them), so
 * orthogonal neighbors match the map exactly; diagonals are derived by composing two
 * nav hops (first valid path wins), and are null when unresolved.
 */
export function buildNeighborhood(
  selected: ScreenData,
  byIndex: Map<number, ScreenData>,
): Neighborhood {
  const resolve = (idx: number | undefined | null): ScreenData | null => {
    if (idx === undefined || idx === null) return null;
    if (idx === NAV_BLOCKED || idx === NAV_BUILDING) return null;
    return byIndex.get(idx) ?? null;
  };
  const N = resolve(selected.nav_up);
  const S = resolve(selected.nav_down);
  const W = resolve(selected.nav_left);
  const E = resolve(selected.nav_right);
  const NE = resolve(N?.nav_right) ?? resolve(E?.nav_up);
  const NW = resolve(N?.nav_left) ?? resolve(W?.nav_up);
  const SE = resolve(S?.nav_right) ?? resolve(E?.nav_down);
  const SW = resolve(S?.nav_left) ?? resolve(W?.nav_down);
  return { cells: [NW, N, NE, W, selected, E, SW, S, SE] };
}

export function ScreenNeighborhood({
  selected,
  byIndex,
  chapterNum,
}: {
  selected: ScreenData;
  byIndex: Map<number, ScreenData>;
  chapterNum: number;
}) {
  const { cells } = buildNeighborhood(selected, byIndex);
  return (
    <div className="p-3 border-b border-slate-700">
      <div className="text-xs text-slate-500 mb-2 text-center">
        Selected screen (center) and its neighbors — pairing context
      </div>
      <div className="grid grid-cols-3 gap-1 w-fit mx-auto">
        {cells.map((cell, i) => {
          const isCenter = i === 4;
          if (!cell) {
            return (
              <div
                key={i}
                className="bg-slate-900/40 rounded"
                style={{ width: CELL_W, height: CELL_H }}
              />
            );
          }
          return (
            <div
              key={i}
              className={`rounded overflow-hidden ${isCenter ? 'ring-2 ring-yellow-400' : ''}`}
            >
              <ScreenMini
                screen={cell}
                chapterNum={chapterNum}
                size={CELL_W}
                showIndex={true}
                tileOpacity={isCenter ? 1 : 0.35}
              />
            </div>
          );
        })}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Verify it type-checks**

Run (from `ui/`): `npx tsc -b --noEmit`
Expected: SAME ~8 pre-existing errors, ZERO new ones (nothing in `ScreenNeighborhood.tsx`).

- [ ] **Step 3: Commit**

```bash
git add src/components/screen/ScreenNeighborhood.tsx
git commit -m "feat(v2/ui): ScreenNeighborhood 3x3 context block (nav-derived)"
```

---

## Task 2: Larger thumbnails + render the neighborhood in the picker

**Files:**
- Modify: `src/components/screen/TileSectionPicker.tsx` (overwrite whole file)
- Modify: `src/components/screen/ScreenDetailPanel.tsx` (two picker call sites)

- [ ] **Step 1: Overwrite `TileSectionPicker.tsx`**

Replace the ENTIRE contents of `src/components/screen/TileSectionPicker.tsx` with EXACTLY this. Changes vs. current: new `screen`/`screens`/`chapterNum` props threaded to the dropdown; the dropdown builds `byIndex` and renders `<ScreenNeighborhood>` when screens are available; modal widened `w-[640px]`→`w-[820px]`; grid `grid-cols-6`→`grid-cols-4`; thumbnail image `object-cover`→`object-contain` and preview scale `2`→`3`.

```tsx
import { useState, useRef, useEffect, useMemo } from 'react';
import { api, ApiClient } from '../../api/client';
import type { ScreenData } from '../../api/client';
import { ScreenNeighborhood } from './ScreenNeighborhood';

interface TileSectionPickerProps {
  which: 'top' | 'bottom';
  /** Current value as a 0-255 byte (the screen's stored top_tiles/bottom_tiles). */
  currentByte: number;
  /** Current bank for this half (0 or 1) — to map the byte to a global index. */
  currentBank: number;
  /** CHR bank index for rendering thumbnails. */
  chr: number;
  /** Called with the chosen GLOBAL section index (0-470). */
  onPick: (globalIndex: number) => void;
  /** The selected screen (for the context header). */
  screen?: ScreenData;
  /** All chapter screens (for neighbor lookup). */
  screens?: ScreenData[];
  /** Chapter number (for rendering screen minis). */
  chapterNum?: number;
}

const TOTAL = ApiClient.TILESECTION_COUNT; // 471

export function TileSectionPicker({
  which, currentByte, currentBank, chr, onPick, screen, screens, chapterNum,
}: TileSectionPickerProps) {
  const [open, setOpen] = useState(false);
  const currentGlobal = currentBank * 256 + currentByte;
  const label = which === 'top' ? 'Top TileSection' : 'Bottom TileSection';

  return (
    <div className="flex justify-between text-sm items-center">
      <span className="text-slate-500">{label}</span>
      <button
        onClick={() => setOpen(true)}
        className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
        title="Click to change tile section"
      >
        0x{currentByte.toString(16).toUpperCase()} ({currentByte})
      </button>
      {open && (
        <TileSectionDropdown
          chr={chr}
          currentGlobal={currentGlobal}
          screen={screen}
          screens={screens}
          chapterNum={chapterNum}
          onClose={() => setOpen(false)}
          onPick={(g) => { onPick(g); setOpen(false); }}
        />
      )}
    </div>
  );
}

function TileSectionDropdown({
  chr, currentGlobal, screen, screens, chapterNum, onClose, onPick,
}: {
  chr: number;
  currentGlobal: number;
  screen?: ScreenData;
  screens?: ScreenData[];
  chapterNum?: number;
  onClose: () => void;
  onPick: (globalIndex: number) => void;
}) {
  const indices = Array.from({ length: TOTAL }, (_, i) => i);
  const byIndex = useMemo(
    () => new Map((screens ?? []).map((s) => [s.index, s])),
    [screens],
  );
  const showNeighborhood = screen && chapterNum !== undefined && byIndex.size > 0;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div
        className="bg-slate-800 border border-slate-600 rounded-lg shadow-xl w-[820px] max-h-[80vh] flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-3 border-b border-slate-700">
          <h4 className="text-slate-200 font-semibold">Select Tile Section ({TOTAL} total)</h4>
          <button onClick={onClose} className="text-slate-400 hover:text-white text-xl">&times;</button>
        </div>
        {showNeighborhood && (
          <ScreenNeighborhood selected={screen} byIndex={byIndex} chapterNum={chapterNum} />
        )}
        <div className="overflow-y-auto p-3 grid grid-cols-4 gap-2">
          {indices.map((g) => (
            <SectionThumb
              key={g}
              globalIndex={g}
              chr={chr}
              selected={g === currentGlobal}
              crossBank={g >= 256}
              onClick={() => onPick(g)}
            />
          ))}
        </div>
        <div className="p-2 border-t border-slate-700 text-xs text-slate-500">
          Sections ≥ 256 are in bank 1 — selecting one also changes the screen's DataPointer/CHR.
        </div>
      </div>
    </div>
  );
}

function SectionThumb({
  globalIndex, chr, selected, crossBank, onClick,
}: {
  globalIndex: number;
  chr: number;
  selected: boolean;
  crossBank: boolean;
  onClick: () => void;
}) {
  const ref = useRef<HTMLButtonElement>(null);
  const [visible, setVisible] = useState(false);

  // Lazy-load: only request the thumbnail PNG once the cell scrolls into view.
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) { setVisible(true); obs.disconnect(); }
    }, { rootMargin: '100px' });
    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  const byte = crossBank ? globalIndex - 256 : globalIndex;
  return (
    <button
      ref={ref}
      onClick={onClick}
      className={`relative rounded overflow-hidden border transition-all ${
        selected ? 'border-yellow-400 ring-2 ring-yellow-400' : 'border-slate-700 hover:border-blue-400'
      }`}
      title={`Section ${globalIndex} (0x${byte.toString(16).toUpperCase()}${crossBank ? ', bank 1' : ''})`}
      style={{ aspectRatio: '2 / 1', backgroundColor: '#0f172a' }}
    >
      {visible && (
        <img
          src={api.getTileSectionPreviewUrl(globalIndex, chr, 3)}
          alt={`Section ${globalIndex}`}
          className="w-full h-full object-contain"
          style={{ imageRendering: 'auto' }}
          loading="lazy"
          onError={(e) => { e.currentTarget.style.visibility = 'hidden'; }}
        />
      )}
      <span className="absolute top-0 left-0 bg-black/70 text-white text-[8px] font-mono px-1">
        {globalIndex}{crossBank ? '*' : ''}
      </span>
    </button>
  );
}
```

- [ ] **Step 2: Pass the data from `ScreenDetailPanel.tsx`**

In `src/components/screen/ScreenDetailPanel.tsx`, the two `<TileSectionPicker .../>` instances (the `which="top"` and `which="bottom"` ones in the "Graphics (DataPointer)" section) each currently end with `onPick={(g) => handlePickTile('top', g)}` / `onPick={(g) => handlePickTile('bottom', g)}`. Add `screen={screen}`, `screens={screens}`, and `chapterNum={chapterNum}` props to BOTH.

Change the `which="top"` instance to:
```tsx
            <TileSectionPicker
              which="top"
              currentByte={screen.top_tiles}
              currentBank={banks.top}
              chr={chrBankIndex}
              screen={screen}
              screens={screens}
              chapterNum={chapterNum}
              onPick={(g) => handlePickTile('top', g)}
            />
```
Change the `which="bottom"` instance to:
```tsx
            <TileSectionPicker
              which="bottom"
              currentByte={screen.bottom_tiles}
              currentBank={banks.bottom}
              chr={chrBankIndex}
              screen={screen}
              screens={screens}
              chapterNum={chapterNum}
              onPick={(g) => handlePickTile('bottom', g)}
            />
```
(`screen`, `screens`, and `chapterNum` are all already in scope in this component — `screen` and `chapterNum` are params, `screens` is the optional prop.)

- [ ] **Step 3: Verify type-check + build**

Run (from `ui/`): `npx tsc -b --noEmit`
Expected: SAME ~8 pre-existing errors, ZERO new ones.
Run (from `ui/`): `npx vite build`
Expected: builds successfully (exit 0). (Vite build does not run `tsc`, so the pre-existing errors don't block it — this confirms the new code bundles.)

- [ ] **Step 4: Commit**

```bash
git add src/components/screen/TileSectionPicker.tsx src/components/screen/ScreenDetailPanel.tsx
git commit -m "feat(v2/ui): picker context header + larger uncropped thumbnails"
```

---

## Task 3: Live verification

**Files:** none (verification only). Requires a backend with the merged tile endpoints + a loaded ROM, and a UI dev server pointed at it.

- [ ] **Step 1: Stand up an isolated backend + UI (if not already running the merged code)**

```bash
# from projects/TMOS_Randomizer_V2
python -m uvicorn tmos_randomizer.api.server:app --port 8011 --log-level warning &
# wait until http://localhost:8011/ returns 200, then:
curl -s -X POST http://localhost:8011/api/rom/load-default
# from ui/
VITE_API_URL=http://localhost:8011 npx vite --port 5184 --strictPort &
```
(Use any free ports; these avoid clashing with a running session on 8000/5173.)

- [ ] **Step 2: Drive the UI (Playwright)**

1. Navigate to `http://localhost:5184/`, select Chapter 1, click the **Screens** tab, click a mid-map screen (e.g. screen 8–20, something with neighbors).
2. In the detail panel's "Graphics (DataPointer)" section, click the **Top TileSection** value button.
3. ✅ Modal opens with a **3×3 context header**: center screen ring-highlighted at full opacity, surrounding cells faded (~35%), blocked directions shown as dim placeholders. The center screen's orthogonal neighbors correspond to the screen's `nav_up/down/left/right`.
4. ✅ Thumbnails are in **4 columns**, noticeably larger than before, each showing the **whole** section (no cropping).
5. ✅ Pick a section → modal closes, the panel's Top value and screen preview update (regression check of the base feature).
6. 🔍 Open the picker on an **edge/orphan** screen (one with several blocked nav directions) → header still renders a 3×3 with dim placeholders where neighbors are absent; layout stays aligned; no console errors.

- [ ] **Step 3: Capture evidence + tear down**

Capture a screenshot of the open modal showing the header + enlarged grid. Then stop the throwaway backend/UI servers (kill the `:8011` / `:5184` processes). Do not disturb any pre-existing session servers.

---

## Self-review notes (addressed)

- **Spec coverage:** whole/bigger thumbnails (Task 2: object-contain, scale 3, grid-cols-4, w-820) ✓; 3×3 nav-derived neighborhood with faded neighbors + highlighted center + empty placeholders (Task 1) ✓; data threading from ScreenDetailPanel (Task 2 Step 2) ✓; graceful degrade when `screens` absent (`showNeighborhood` guard) ✓; fixed (non-recomposing) preview — neighborhood uses each screen's current tiles via ScreenMini, no hover recompute ✓.
- **Type consistency:** `buildNeighborhood(selected, byIndex)` and `ScreenNeighborhood({selected, byIndex, chapterNum})` match their callers; `byIndex` keyed by `s.index` (same key nav values resolve against); `ScreenMini` props (`size`, `showIndex`, `tileOpacity`) match its real signature; new optional props on `TileSectionPicker` are all supplied by `ScreenDetailPanel`.
- **No new tsc errors:** target is the unchanged ~8-error baseline; pre-existing errors are out of scope.
- **No UI test harness:** `buildNeighborhood` is pure/exported for future testability; verification is live (Task 3), consistent with the prior feature.
