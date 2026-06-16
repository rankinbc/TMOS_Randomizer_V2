# Phase 2 — World-Tab Screen Editor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the World tab the place to edit everything about a screen — open the existing screen editor modal by **right-clicking a screen**, and extend that modal to edit **every WorldScreen byte except the 4 navigation pointers** (those stay on the map via drag), each as an illustrated, descriptive, safety-aware control with a vanilla "changed" indicator.

**Architecture:** A new `WorldView` component owns the World tab: the map (NavigationMapView/ScreenGrid) + the persistent `ScreenDetailPanel` + a reusable `ContextMenu` + the `ScreenEditorModal` state, and it fetches the selected screen's vanilla bytes. Right-clicking a screen opens a context menu whose primary action ("Edit screen") opens the modal. The modal renders each editable field through guided wrappers that compose the Phase 1 `GuidedField` (safety badge + ⓘ description/warning + vanilla "changed") around a descriptive dropdown / number control, with color swatches for palette/parent-world fields and the existing enemy-thumbnail control for the spawn set. Safety tiers from `field_metadata.json` become **warnings/guardrails** (caution = validated, danger = flagged but editable) — no WorldScreen field is routed to the Expert tab.

**Tech Stack:** Python 3.10+/FastAPI/pytest (backend); React 19 + TypeScript + Zustand 5 + Tailwind 4 + Vite 7 + vitest (frontend).

**Working directory:** Python commands from `projects/TMOS_Randomizer_V2`; npm/npx from `projects/TMOS_Randomizer_V2/ui`. Branch: `feat/phase2-world-editor`.

**Design decisions locked (from brainstorming):**
- Editing stays in the **modal** (not inline panel). Right-click is the new access path.
- Modal edits all bytes **except** `screen_index_right/left/down/up` (nav = map drag, unchanged).
- "Illustrated descriptive dropdowns": descriptive labels + color swatches (palettes, parent_world) + enemy thumbnails (objectset, already exists).
- Safety tiers are guardrails, not gates: caution validated; danger editable-with-warning. No WorldScreen field in Expert.

---

## File Structure

**Backend (modify):**
- `src/tmos_randomizer/api/server.py` — extend `ScreenFieldsUpdate` model + `/fields` allowlist (+`parent_world, ambient_sound, datapointer, exit_position, unknown`); ensure screen serialization (chapter + single-screen GET) emits all 16 fields; add `GET /api/rom/screen/{ch}/{idx}/vanilla`.

**Backend (test):**
- `tests/test_api/test_screen_fields_extended.py`, `tests/test_api/test_screen_vanilla.py`.

**Frontend (create):**
- `ui/src/components/shared/ContextMenu.tsx` — reusable right-click menu.
- `ui/src/components/screen/GuidedSelectField.tsx` — GuidedField + label-less descriptive select (+ optional swatch).
- `ui/src/components/screen/GuidedNumberField.tsx` — GuidedField + label-less 0–255 number input.
- `ui/src/components/screen/worldScreenFieldOptions.ts` — option lists + swatches for parent_world & palettes (reusing existing color maps).
- `ui/src/components/views/WorldView.tsx` — owns map + panel + context menu + modal + vanilla fetch.

**Frontend (modify):**
- `ui/src/api/client.ts` — extend `ScreenFieldsUpdate`/`ScreenData` types; add `getScreenVanilla()`.
- `ui/src/store/index.ts` — widen `updateScreenFields` field union; add `screenVanilla` state + `loadScreenVanilla` action.
- `ui/src/components/screen/ScreenEditorModal.tsx` — render all non-nav fields via guided wrappers + metadata tiers + vanilla; widen `onFieldChange`.
- `ui/src/components/screen/ScreenGrid.tsx` — `onScreenContextMenu` prop + `onContextMenu` handler.
- `ui/src/components/screen/NavigationMapView.tsx` — `onScreenContextMenu` prop + right-click on a screen cell.
- `ui/src/components/layout/MainContent.tsx` — render `WorldView` for the `world` tab (replacing the inline map/panel block).

---

## Task 1: Backend — complete the screen read/write path

Ensure every WorldScreen byte can be read (serialization) and written (`/fields`).

**Files:**
- Modify: `src/tmos_randomizer/api/server.py`
- Test: `tests/test_api/test_screen_fields_extended.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_api/test_screen_fields_extended.py`:

```python
from fastapi.testclient import TestClient
from tmos_randomizer.api.server import app

client = TestClient(app)


def _load_rom():
    r = client.post("/api/rom/load-default")
    assert r.status_code == 200, r.text


def test_chapter_screens_expose_all_16_fields():
    _load_rom()
    body = client.get("/api/rom/chapter/1").json()
    s = body["screens"][0]
    for key in ("parent_world", "ambient_sound", "content", "objectset",
                "datapointer", "exit_position", "top_tiles", "bottom_tiles",
                "worldscreen_color", "sprites_color", "unknown", "event"):
        assert key in s, f"missing {key} in screen serialization"


def test_fields_patch_accepts_extended_fields():
    _load_rom()
    r = client.patch("/api/rom/screen/1/0/fields",
                     json={"parent_world": 0x40, "ambient_sound": 3,
                           "exit_position": 5, "unknown": 0})
    assert r.status_code == 200, r.text
    s = r.json()["screen"]
    assert s["parent_world"] == 0x40
    assert s["ambient_sound"] == 3
    assert s["exit_position"] == 5


def test_fields_patch_rejects_out_of_range():
    _load_rom()
    r = client.patch("/api/rom/screen/1/0/fields", json={"ambient_sound": 999})
    assert r.status_code == 400
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_api/test_screen_fields_extended.py -v`
Expected: FAIL — extended keys missing / not accepted.

- [ ] **Step 3: Implement**

In `src/tmos_randomizer/api/server.py`:

a) Find the `class ScreenFieldsUpdate(BaseModel)` definition (near the other Pydantic models). Add the new optional fields so it reads:

```python
class ScreenFieldsUpdate(BaseModel):
    objectset: Optional[int] = None
    content: Optional[int] = None
    event: Optional[int] = None
    worldscreen_color: Optional[int] = None
    sprites_color: Optional[int] = None
    parent_world: Optional[int] = None
    ambient_sound: Optional[int] = None
    datapointer: Optional[int] = None
    exit_position: Optional[int] = None
    unknown: Optional[int] = None
```

b) In `update_screen_fields` (line ~738), extend the `fields` allowlist dict and the response to include the new fields:

```python
    fields = {
        "objectset": update.objectset,
        "content": update.content,
        "event": update.event,
        "worldscreen_color": update.worldscreen_color,
        "sprites_color": update.sprites_color,
        "parent_world": update.parent_world,
        "ambient_sound": update.ambient_sound,
        "datapointer": update.datapointer,
        "exit_position": update.exit_position,
        "unknown": update.unknown,
    }
```

Update the 400 detail string to list the new allowed keys. After `setattr` loop, add `"ambient_sound": screen.ambient_sound,` and `"unknown": screen.unknown,` to the returned `"screen"` dict (it already returns the rest).

c) Find the screen serialization used by `GET /api/rom/chapter/{n}` and `GET /api/rom/screen/{ch}/{idx}` (a helper or inline dict near lines 388–467). Ensure it emits all 16 fields — specifically add `ambient_sound` and `unknown` if absent (the others are already present). If serialization is centralized in a helper (e.g. `_serialize_screen`), update it once; otherwise update both endpoints. Use the `WorldScreen` attribute names: `parent_world, ambient_sound, content, objectset, datapointer, exit_position, top_tiles, bottom_tiles, worldscreen_color, sprites_color, unknown, event` plus the nav fields already present.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_api/test_screen_fields_extended.py -v`
Expected: PASS (3 passed).

- [ ] **Step 5: Commit**

```bash
git add tests/test_api/test_screen_fields_extended.py src/tmos_randomizer/api/server.py
git commit -m "feat(api): screen /fields covers all 16 bytes; full screen serialization"
```

---

## Task 2: Backend — vanilla screen endpoint

**Files:**
- Modify: `src/tmos_randomizer/api/server.py`
- Test: `tests/test_api/test_screen_vanilla.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_api/test_screen_vanilla.py`:

```python
from fastapi.testclient import TestClient
from tmos_randomizer.api.server import app

client = TestClient(app)


def test_vanilla_endpoint_returns_original_after_edit():
    assert client.post("/api/rom/load-default").status_code == 200
    # Capture vanilla, then edit, then confirm vanilla is unchanged.
    before = client.get("/api/rom/screen/1/0/vanilla").json()
    assert "content" in before and "parent_world" in before
    new_content = (before["content"] + 1) % 256
    assert client.patch("/api/rom/screen/1/0/fields",
                        json={"content": new_content}).status_code == 200
    after = client.get("/api/rom/screen/1/0/vanilla").json()
    assert after["content"] == before["content"], "vanilla must not reflect edits"


def test_vanilla_requires_rom():
    # fresh app state may already have a ROM from other tests; just assert shape if 200
    r = client.get("/api/rom/screen/1/0/vanilla")
    assert r.status_code in (200, 400)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_api/test_screen_vanilla.py -v`
Expected: FAIL with 404 (route missing).

- [ ] **Step 3: Implement**

In `server.py`, locate how the uploaded ROM snapshot is kept (`_rom_vanilla: Optional[bytes]`) and how screens are parsed from raw bytes (`ROMReader` / `load_rom` build `_game_world` from `_rom_data`). Add an endpoint that parses the **vanilla** bytes into a throwaway world and returns the one screen's 16 fields. Place it right after `update_screen_fields`:

```python
@app.get("/api/rom/screen/{chapter_num}/{screen_index}/vanilla")
async def get_screen_vanilla(chapter_num: int, screen_index: int):
    """Return a screen's ORIGINAL (as-uploaded) 16 bytes, for change comparison."""
    if _rom_vanilla is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    # Parse the pristine snapshot independently of the (mutated) live world.
    vanilla_world = ROMReader(bytearray(_rom_vanilla)).read_game_world()
    chapter = vanilla_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")
    s = chapter.get_screen(screen_index)
    if s is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found")
    return {
        "index": s.relative_index, "global_index": s.global_index,
        "parent_world": s.parent_world, "ambient_sound": s.ambient_sound,
        "content": s.content, "objectset": s.objectset,
        "datapointer": s.datapointer, "exit_position": s.exit_position,
        "top_tiles": s.top_tiles, "bottom_tiles": s.bottom_tiles,
        "worldscreen_color": s.worldscreen_color, "sprites_color": s.sprites_color,
        "unknown": s.unknown, "event": s.event,
        "nav_right": s.screen_index_right, "nav_left": s.screen_index_left,
        "nav_down": s.screen_index_down, "nav_up": s.screen_index_up,
    }
```

NOTE: confirm the exact `ROMReader` construction + parse method by reading how `_game_world` is built earlier in `server.py` (e.g. `load_rom(...)` or `ROMReader(data).read_game_world()`); mirror that call. If a higher-level `load_rom(bytes)` helper exists, prefer it: `load_rom(bytes(_rom_vanilla)).` Adjust the two lines accordingly. Cache is unnecessary; vanilla screens are tiny.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_api/test_screen_vanilla.py -v`
Expected: PASS (2 passed).

- [ ] **Step 5: Commit**

```bash
git add tests/test_api/test_screen_vanilla.py src/tmos_randomizer/api/server.py
git commit -m "feat(api): GET screen/{ch}/{idx}/vanilla for change comparison"
```

---

## Task 3: Frontend — client + store wiring for extended fields & vanilla

**Files:**
- Modify: `ui/src/api/client.ts`, `ui/src/store/index.ts`

- [ ] **Step 1: Extend client types + add vanilla fetch**

In `ui/src/api/client.ts`:

a) Find the `ScreenFieldsUpdate` interface and widen it:

```typescript
export interface ScreenFieldsUpdate {
  objectset?: number;
  content?: number;
  event?: number;
  worldscreen_color?: number;
  sprites_color?: number;
  parent_world?: number;
  ambient_sound?: number;
  datapointer?: number;
  exit_position?: number;
  unknown?: number;
}
```

b) Find the `ScreenData` interface; ensure it includes `ambient_sound: number;` and `unknown: number;` (add any missing of the 16 fields; keep existing names like `nav_right` etc.).

c) Add a vanilla type + method (use the existing `this.fetch<T>` helper — confirm its name by reading a nearby GET):

```typescript
export interface ScreenVanilla {
  index: number; global_index: number;
  parent_world: number; ambient_sound: number; content: number; objectset: number;
  datapointer: number; exit_position: number; top_tiles: number; bottom_tiles: number;
  worldscreen_color: number; sprites_color: number; unknown: number; event: number;
  nav_right: number; nav_left: number; nav_down: number; nav_up: number;
}
```

```typescript
  async getScreenVanilla(chapterNum: number, screenIndex: number): Promise<ScreenVanilla> {
    return this.fetch<ScreenVanilla>(`/api/rom/screen/${chapterNum}/${screenIndex}/vanilla`);
  }
```

- [ ] **Step 2: Widen store action + add vanilla state**

In `ui/src/store/index.ts`:

a) Find `updateScreenFields` in the actions interface and its implementation. Its `fields` param is typed `ScreenFieldsUpdate` (imported from client) — since that type was widened in Step 1, no signature change is needed, but confirm the import is `ScreenFieldsUpdate` and the impl passes the object straight through to `api.updateScreenFields`. If the action's param is a narrower inline union, replace it with `ScreenFieldsUpdate`.

b) Add vanilla state + loader. Add to imports: `import type { ScreenVanilla } from '../api/client';`. Add to the state interface: `screenVanilla: ScreenVanilla | null;`. Initial value: `screenVanilla: null,`. Add action to interface: `loadScreenVanilla: (chapterNum: number, screenIndex: number) => Promise<void>;` and implement:

```typescript
  loadScreenVanilla: async (chapterNum, screenIndex) => {
    try {
      const v = await api.getScreenVanilla(chapterNum, screenIndex);
      set({ screenVanilla: v });
    } catch (e) {
      console.error('Failed to load vanilla screen', e);
      set({ screenVanilla: null });
    }
  },
```

- [ ] **Step 3: Verify build**

Run (in `ui/`): `npx tsc -b 2>&1 | grep -E "error TS" | head`
Expected: no NEW errors (baseline is currently 0).

- [ ] **Step 4: Commit**

```bash
git add ui/src/api/client.ts ui/src/store/index.ts
git commit -m "feat(ui): extended screen-field types + vanilla fetch wiring"
```

---

## Task 4: Frontend — guided field wrappers

Compose the Phase 1 `GuidedField` (badge + ⓘ + vanilla-changed) around label-less controls.

**Files:**
- Create: `ui/src/components/screen/GuidedSelectField.tsx`, `ui/src/components/screen/GuidedNumberField.tsx`

- [ ] **Step 1: Write `GuidedSelectField`**

Create `ui/src/components/screen/GuidedSelectField.tsx`:

```tsx
import type { FieldMetadata } from '../../types/metadata';
import { GuidedField } from '../shared/GuidedField';
import type { EnumOption } from './EnumSelectField';

export interface SwatchOption extends EnumOption {
  swatch?: string; // CSS color for an illustrated preview
}

interface Props {
  meta: FieldMetadata;
  value: number;
  vanilla?: number;
  options: SwatchOption[];
  onChange: (v: number) => void;
}

/** A descriptive dropdown + raw 0-255 input, wrapped with safety/guidance/vanilla. */
export function GuidedSelectField({ meta, value, vanilla, options, onChange }: Props) {
  const known = options.some((o) => o.value === value);
  const hex = `0x${value.toString(16).toUpperCase().padStart(2, '0')}`;
  const current = options.find((o) => o.value === value);
  return (
    <GuidedField meta={meta} value={value} vanilla={vanilla}>
      <div className="flex items-center gap-1">
        {current?.swatch && (
          <span
            className="w-4 h-4 rounded border border-slate-500 shrink-0"
            style={{ backgroundColor: current.swatch }}
            aria-hidden
          />
        )}
        <select
          className="flex-1 bg-slate-700 text-slate-200 text-xs rounded px-1 py-0.5"
          value={known ? value : -1}
          onChange={(e) => onChange(Number(e.target.value))}
        >
          {!known && <option value={-1}>{`Custom (${hex})`}</option>}
          {options.map((o) => (
            <option key={o.value} value={o.value}>{o.label}</option>
          ))}
        </select>
        <input
          type="number" min={0} max={255} value={value}
          onChange={(e) => {
            const n = Number(e.target.value);
            if (!Number.isNaN(n) && n >= 0 && n <= 255) onChange(n);
          }}
          className="w-14 bg-slate-700 text-slate-200 font-mono text-xs rounded px-1 py-0.5"
        />
      </div>
    </GuidedField>
  );
}
```

- [ ] **Step 2: Write `GuidedNumberField`**

Create `ui/src/components/screen/GuidedNumberField.tsx`:

```tsx
import type { FieldMetadata } from '../../types/metadata';
import { GuidedField } from '../shared/GuidedField';

interface Props {
  meta: FieldMetadata;
  value: number;
  vanilla?: number;
  onChange: (v: number) => void;
}

/** A raw 0-255 byte input wrapped with safety/guidance/vanilla. */
export function GuidedNumberField({ meta, value, vanilla, onChange }: Props) {
  return (
    <GuidedField meta={meta} value={value} vanilla={vanilla}>
      <input
        type="number" min={0} max={255} value={value}
        onChange={(e) => {
          const n = Number(e.target.value);
          if (!Number.isNaN(n) && n >= 0 && n <= 255) onChange(n);
        }}
        className="w-20 bg-slate-700 text-slate-200 font-mono text-xs rounded px-1 py-0.5"
      />
    </GuidedField>
  );
}
```

- [ ] **Step 3: Verify build**

Run (in `ui/`): `npx tsc -b 2>&1 | grep -E "error TS" | head`
Expected: no errors referencing the two new files.

- [ ] **Step 4: Commit**

```bash
git add ui/src/components/screen/GuidedSelectField.tsx ui/src/components/screen/GuidedNumberField.tsx
git commit -m "feat(ui): GuidedSelectField + GuidedNumberField wrappers"
```

---

## Task 5: Frontend — option lists + swatches for new fields

**Files:**
- Create: `ui/src/components/screen/worldScreenFieldOptions.ts`

- [ ] **Step 1: Write the options module**

Create `ui/src/components/screen/worldScreenFieldOptions.ts`. Reuse the parent-world color palette already used by `ScreenGrid` (`PARENT_WORLD_COLORS`). Build a descriptive `parent_world` list (illustrated with swatches) and re-export palette swatch options.

```typescript
import type { SwatchOption } from './GuidedSelectField';

// Mirrors ScreenGrid's PARENT_WORLD_COLORS abstract palette. Labels describe the
// section type each parent-world group represents.
export const PARENT_WORLD_OPTIONS: SwatchOption[] = [
  { value: 0x40, label: '0x40 Overworld', swatch: '#2563eb' },
  { value: 0xe0, label: '0xE0 Overworld (alt)', swatch: '#2563eb' },
  { value: 0x80, label: '0x80 Overworld (alt)', swatch: '#2563eb' },
  { value: 0x30, label: '0x30 Overworld (alt)', swatch: '#2563eb' },
  { value: 0x20, label: '0x20 Town', swatch: '#16a34a' },
  { value: 0x10, label: '0x10 Town (alt)', swatch: '#16a34a' },
  { value: 0xd0, label: '0xD0 Dungeon', swatch: '#dc2626' },
  { value: 0xf0, label: '0xF0 Dungeon (alt)', swatch: '#dc2626' },
  { value: 0xb0, label: '0xB0 Dungeon (alt)', swatch: '#dc2626' },
  { value: 0x53, label: '0x53 Maze', swatch: '#9333ea' },
  { value: 0x55, label: '0x55 Maze (alt)', swatch: '#9333ea' },
  { value: 0x58, label: '0x58 Maze (alt)', swatch: '#9333ea' },
  { value: 0x5d, label: '0x5D Maze (alt)', swatch: '#9333ea' },
];

// Background-palette swatches approximate the renderer's getGroundColor cases.
export const WS_COLOR_SWATCHES: SwatchOption[] = [
  { value: 0x21, label: '0x21 Past (green)', swatch: '#3a7d3a' },
  { value: 0x30, label: '0x30 Water (blue)', swatch: '#2b5fd0' },
  { value: 0x25, label: '0x25 Desert (sand)', swatch: '#c9a86a' },
  { value: 0x1a, label: '0x1A Dark palace', swatch: '#3a3550' },
  { value: 0x3c, label: '0x3C Red', swatch: '#b03030' },
  { value: 0x23, label: '0x23 Winter (gray)', swatch: '#9aa3ad' },
  { value: 0x27, label: '0x27 Black', swatch: '#1a1a1a' },
  { value: 0x1c, label: '0x1C Lava', swatch: '#d2601a' },
];

export const SPRITE_COLOR_SWATCHES: SwatchOption[] = [
  { value: 0x0f, label: '0x0F Default', swatch: '#cccccc' },
  { value: 0x30, label: '0x30 Town', swatch: '#e0c060' },
];
```

- [ ] **Step 2: Verify build**

Run (in `ui/`): `npx tsc -b 2>&1 | grep -E "error TS" | head`
Expected: no errors referencing the new file.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/screen/worldScreenFieldOptions.ts
git commit -m "feat(ui): illustrated option lists for parent-world & palette fields"
```

---

## Task 6: Frontend — extend the modal to all non-nav fields

Render every editable byte (except nav pointers) through the guided wrappers, driven by `field_metadata` tiers + vanilla.

**Files:**
- Modify: `ui/src/components/screen/ScreenEditorModal.tsx`

- [ ] **Step 1: Widen the field-change contract + accept vanilla**

In `ScreenEditorModal.tsx`:

a) Widen `onFieldChange`'s field union in `ScreenEditorModalProps` to include the new fields:

```typescript
  onFieldChange: (
    field: 'objectset' | 'content' | 'event' | 'worldscreen_color' | 'sprites_color'
      | 'parent_world' | 'ambient_sound' | 'datapointer' | 'exit_position' | 'unknown',
    value: number,
  ) => void;
```

b) Add two props: `fieldMetadata: import('../../types/metadata').EntityMetadata | null;` and `vanilla?: import('../../api/client').ScreenVanilla | null;` (the World view passes the `worldscreen` entity metadata + the selected screen's vanilla). Add them to the destructure.

- [ ] **Step 2: Render fields via guided wrappers**

Add a small helper inside the component to fetch a field's metadata, and replace the existing `<ObjectSetField>` + 4 `<EnumSelectField>` block (lines ~123–154) with guided controls covering all non-nav fields. Keep `ObjectSetField` for `objectset` (it already shows enemy thumbnails) but wrap it in a `GuidedField` for the badge/warning. Example structure (imports: `GuidedSelectField`, `GuidedNumberField`, `GuidedField`, the option lists, and existing `buildContentOptions`/`EVENT_OPTIONS`):

```tsx
const fm = fieldMetadata?.fields;
const meta = (k: string) => fm?.[k];
// ...
<div className="p-3 border-b border-slate-700 space-y-1.5 bg-slate-900/40">
  {meta('parent_world') && (
    <GuidedSelectField meta={meta('parent_world')!} value={screen.parent_world}
      vanilla={vanilla?.parent_world} options={PARENT_WORLD_OPTIONS}
      onChange={(v) => onFieldChange('parent_world', v)} />
  )}
  {meta('ambient_sound') && (
    <GuidedNumberField meta={meta('ambient_sound')!} value={screen.ambient_sound}
      vanilla={vanilla?.ambient_sound} onChange={(v) => onFieldChange('ambient_sound', v)} />
  )}
  {meta('content') && (
    <GuidedSelectField meta={meta('content')!} value={screen.content}
      vanilla={vanilla?.content} options={buildContentOptions(chapterNum)}
      onChange={(v) => onFieldChange('content', v)} />
  )}
  {/* objectset keeps the enemy-thumbnail control, wrapped for safety/guidance */}
  {meta('objectset') && (
    <GuidedField meta={meta('objectset')!} value={screen.objectset} vanilla={vanilla?.objectset}>
      <ObjectSetField value={screen.objectset} chapterNum={chapterNum} chr={chr}
        onChange={(v) => onFieldChange('objectset', v)} />
    </GuidedField>
  )}
  {meta('event') && (
    <GuidedSelectField meta={meta('event')!} value={screen.event}
      vanilla={vanilla?.event} options={EVENT_OPTIONS}
      onChange={(v) => onFieldChange('event', v)} />
  )}
  {meta('worldscreen_color') && (
    <GuidedSelectField meta={meta('worldscreen_color')!} value={screen.worldscreen_color}
      vanilla={vanilla?.worldscreen_color} options={WS_COLOR_SWATCHES}
      onChange={(v) => onFieldChange('worldscreen_color', v)} />
  )}
  {meta('sprites_color') && (
    <GuidedSelectField meta={meta('sprites_color')!} value={screen.sprites_color}
      vanilla={vanilla?.sprites_color} options={SPRITE_COLOR_SWATCHES}
      onChange={(v) => onFieldChange('sprites_color', v)} />
  )}
  {meta('datapointer') && (
    <GuidedNumberField meta={meta('datapointer')!} value={screen.datapointer}
      vanilla={vanilla?.datapointer} onChange={(v) => onFieldChange('datapointer', v)} />
  )}
  {meta('exit_position') && (
    <GuidedNumberField meta={meta('exit_position')!} value={screen.exit_position}
      vanilla={vanilla?.exit_position} onChange={(v) => onFieldChange('exit_position', v)} />
  )}
  {meta('unknown') && (
    <GuidedNumberField meta={meta('unknown')!} value={screen.unknown}
      vanilla={vanilla?.unknown} onChange={(v) => onFieldChange('unknown', v)} />
  )}
</div>
```

Keep the existing tile-section picker grid below unchanged. Remove the now-unused `EnumSelectField` import and the local `WS_COLOR_OPTIONS`/`SPRITE_COLOR_OPTIONS` consts (replaced by the swatch option lists) **only if** they're no longer referenced; otherwise leave them. Do NOT add nav-pointer fields.

> Title note: the modal still edits the tile section per `activeHalf`; leave that flow intact. The new fields are screen-wide and don't depend on `activeHalf`.

- [ ] **Step 3: Verify build + tests**

Run (in `ui/`): `npx tsc -b 2>&1 | grep -E "error TS" | head` → no new errors. `npm test` → existing vitest still 4/4.

- [ ] **Step 4: Commit**

```bash
git add ui/src/components/screen/ScreenEditorModal.tsx
git commit -m "feat(ui): modal edits all non-nav WorldScreen bytes with guided controls"
```

---

## Task 7: Frontend — reusable ContextMenu

**Files:**
- Create: `ui/src/components/shared/ContextMenu.tsx`

- [ ] **Step 1: Write the component**

Create `ui/src/components/shared/ContextMenu.tsx`:

```tsx
import { useEffect } from 'react';

export interface ContextMenuItem {
  label: string;
  onClick: () => void;
  danger?: boolean;
  disabled?: boolean;
}

interface Props {
  x: number;
  y: number;
  items: ContextMenuItem[];
  onClose: () => void;
}

export function ContextMenu({ x, y, items, onClose }: Props) {
  useEffect(() => {
    const close = () => onClose();
    window.addEventListener('click', close);
    window.addEventListener('contextmenu', close);
    window.addEventListener('scroll', close, true);
    const onEsc = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', onEsc);
    return () => {
      window.removeEventListener('click', close);
      window.removeEventListener('contextmenu', close);
      window.removeEventListener('scroll', close, true);
      window.removeEventListener('keydown', onEsc);
    };
  }, [onClose]);

  return (
    <div
      className="fixed z-[100] min-w-[160px] bg-slate-800 border border-slate-600 rounded shadow-xl py-1 text-sm"
      style={{ top: y, left: x }}
      onClick={(e) => e.stopPropagation()}
    >
      {items.map((it, i) => (
        <button
          key={i}
          disabled={it.disabled}
          onClick={() => { it.onClick(); onClose(); }}
          className={`block w-full text-left px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40 disabled:cursor-not-allowed ${
            it.danger ? 'text-red-400' : 'text-slate-200'
          }`}
        >
          {it.label}
        </button>
      ))}
    </div>
  );
}
```

- [ ] **Step 2: Verify build**

Run (in `ui/`): `npx tsc -b 2>&1 | grep -E "error TS" | head` → no errors referencing the new file.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/shared/ContextMenu.tsx
git commit -m "feat(ui): reusable ContextMenu component"
```

---

## Task 8: Frontend — WorldView owns map + panel + context menu + modal

Centralize World-tab orchestration so right-click and the panel both open the same modal, and vanilla loads for the selected screen.

**Files:**
- Create: `ui/src/components/views/WorldView.tsx`
- Modify: `ui/src/components/views/index.ts` (export), `ui/src/components/layout/MainContent.tsx`

- [ ] **Step 1: Write `WorldView`**

Create `ui/src/components/views/WorldView.tsx`. It reads store state, renders the map per `viewMode`, the `ScreenDetailPanel`, a `ContextMenu` on right-click, and the `ScreenEditorModal` (passing `worldscreen` metadata + vanilla). It loads vanilla whenever the editor opens.

```tsx
import { useState, useCallback, useEffect } from 'react';
import { useRandomizerStore } from '../../store';
import { NavigationMapView } from '../screen/NavigationMapView';
import { ScreenGrid } from '../screen/ScreenGrid';
import { ScreenDetailPanel } from '../screen/ScreenDetailPanel';
import { ScreenEditorModal } from '../screen/ScreenEditorModal';
import { ContextMenu, type ContextMenuItem } from '../shared/ContextMenu';

export function WorldView() {
  const {
    chapterData, viewMode, selectedScreen, setSelectedScreen,
    updateScreenFields, updateScreenTiles, fieldMetadata,
    screenVanilla, loadScreenVanilla,
  } = useRandomizerStore();

  const [editor, setEditor] = useState<{ index: number; half: 'top' | 'bottom' } | null>(null);
  const [menu, setMenu] = useState<{ x: number; y: number; index: number } | null>(null);

  const screens = chapterData?.screens ?? [];
  const byIndex = new Map(screens.map((s) => [s.index, s]));
  const selectedScreenData = selectedScreen != null ? byIndex.get(selectedScreen) : undefined;
  const editorScreen = editor ? byIndex.get(editor.index) : undefined;

  useEffect(() => {
    if (editor && chapterData) loadScreenVanilla(chapterData.chapter_num, editor.index);
  }, [editor, chapterData, loadScreenVanilla]);

  const openEditor = useCallback((index: number) => {
    setSelectedScreen(index);
    setEditor({ index, half: 'top' });
  }, [setSelectedScreen]);

  const onScreenContextMenu = useCallback((index: number, x: number, y: number) => {
    setSelectedScreen(index);
    setMenu({ x, y, index });
  }, [setSelectedScreen]);

  if (!chapterData) {
    return <div className="flex items-center justify-center h-full text-slate-500">Select a chapter to view screens.</div>;
  }

  const menuItems: ContextMenuItem[] = menu ? [
    { label: `Edit screen #${menu.index}`, onClick: () => openEditor(menu.index) },
  ] : [];

  return (
    <div className="flex h-full">
      <div className="flex-1 overflow-hidden">
        {viewMode === 'navigation' ? (
          <NavigationMapView
            chapter={chapterData}
            selectedScreen={selectedScreen}
            onScreenSelect={setSelectedScreen}
            onScreenContextMenu={onScreenContextMenu}
            tileSize={48}
          />
        ) : (
          <ScreenGrid
            screens={screens}
            selectedScreen={selectedScreen}
            onScreenSelect={setSelectedScreen}
            onScreenContextMenu={onScreenContextMenu}
            gridWidth={16}
          />
        )}
      </div>

      {selectedScreenData && (
        <div className="w-80 flex-shrink-0 border-l border-slate-700 overflow-y-auto">
          <ScreenDetailPanel
            screen={selectedScreenData}
            chapterNum={chapterData.chapter_num}
            screens={screens}
            onScreenSelect={setSelectedScreen}
            onClose={() => setSelectedScreen(null)}
          />
        </div>
      )}

      {menu && (
        <ContextMenu x={menu.x} y={menu.y} items={menuItems} onClose={() => setMenu(null)} />
      )}

      {editor && editorScreen && (
        <ScreenEditorModal
          screen={editorScreen}
          screens={screens}
          chapterNum={chapterData.chapter_num}
          activeHalf={editor.half}
          onHalfChange={(half) => setEditor((e) => (e ? { ...e, half } : e))}
          onClose={() => setEditor(null)}
          onScreenSelect={(i) => setEditor((e) => (e ? { ...e, index: i } : e))}
          fieldMetadata={fieldMetadata?.entities.worldscreen ?? null}
          vanilla={editor && screenVanilla && screenVanilla.index === editor.index ? screenVanilla : null}
          onFieldChange={(field, value) => updateScreenFields(editor.index, { [field]: value })}
          onTilePick={(which, globalIndex) =>
            updateScreenTiles(editor.index, which === 'top' ? { top_tiles: globalIndex } : { bottom_tiles: globalIndex })}
        />
      )}
    </div>
  );
}
```

> Verify exact store action names/signatures (`updateScreenTiles` arg shape uses GLOBAL indices — the existing modal/panel already pass global indices; mirror how `ScreenDetailPanel.onTilePick` currently calls it). Verify `chapterData.chapter_num` exists (used elsewhere in MainContent). If `updateScreenTiles` expects `{top_tiles}`/`{bottom_tiles}` as global indices, the above is correct per the existing panel usage; otherwise match the panel.

- [ ] **Step 2: Export + wire into MainContent**

In `ui/src/components/views/index.ts` add: `export { WorldView } from './WorldView';`

In `ui/src/components/layout/MainContent.tsx`:
- Import `WorldView` from `../views`.
- Replace the `world` routing (the `selectedTab === 'world' && viewMode...` NavigationMapView/ScreenGrid blocks AND the separate ScreenDetailPanel mount block) with a single `{selectedTab === 'world' && <WorldView />}`.
- Remove now-unused imports in MainContent (`NavigationMapView`, `ScreenGrid`, `ScreenDetailPanel`) if no longer referenced there. Keep the view-mode switcher in the tab bar (it sets `viewMode`, which WorldView reads).

- [ ] **Step 3: Verify build + lint + tests**

Run (in `ui/`): `npx tsc -b 2>&1 | grep -E "error TS" | head` → 0 errors. `npm run lint 2>&1 | tail -3` → no NEW errors vs baseline. `npm test` → 4/4.

- [ ] **Step 4: Commit**

```bash
git add ui/src/components/views/WorldView.tsx ui/src/components/views/index.ts ui/src/components/layout/MainContent.tsx
git commit -m "feat(ui): WorldView orchestrates map + panel + context menu + editor modal"
```

---

## Task 9: Frontend — right-click handlers on the map components

**Files:**
- Modify: `ui/src/components/screen/ScreenGrid.tsx`, `ui/src/components/screen/NavigationMapView.tsx`

- [ ] **Step 1: ScreenGrid**

In `ScreenGrid.tsx`: add to `ScreenGridProps`:

```typescript
  onScreenContextMenu?: (index: number, x: number, y: number) => void;
```

On the screen cell `<div>` (the one with `onClick={() => screen && onScreenSelect(screen.index)}`), add:

```tsx
                onContextMenu={(e) => {
                  if (screen && onScreenContextMenu) {
                    e.preventDefault();
                    onScreenContextMenu(screen.index, e.clientX, e.clientY);
                  }
                }}
```

- [ ] **Step 2: NavigationMapView**

In `NavigationMapView.tsx`: add `onScreenContextMenu?: (index: number, x: number, y: number) => void;` to its props interface and destructure it. Find where a screen cell is rendered with its click handler (`onScreenSelect(screenIndex)`, around line ~1319). On that same clickable element add:

```tsx
              onContextMenu={(e) => {
                if (onScreenContextMenu) {
                  e.preventDefault();
                  onScreenContextMenu(screenIndex, e.clientX, e.clientY);
                }
              }}
```

Use the correct in-scope screen-index variable name at that render site (read the surrounding code; it may be `s.index`, `screen.index`, or a loop var). Attach only to actual screen cells, not to empty grid slots or overlays.

- [ ] **Step 3: Verify build + manual check**

Run (in `ui/`): `npx tsc -b 2>&1 | grep -E "error TS" | head` → 0 errors.

Manual (start backend `python -m uvicorn tmos_randomizer.api.server:app --port 8000` from `projects/TMOS_Randomizer_V2`, and `npm run dev` from `ui/`, load default ROM, pick a chapter):
- Right-click a screen in both Grid and Navigation views → context menu appears at cursor → "Edit screen #N" opens the modal.
- Modal shows all non-nav fields with safety badges; palette/parent-world dropdowns show color swatches; objectset shows enemy thumbnails; editing a field shows "changed" vs vanilla.
- The 4 navigation pointers are NOT in the modal.
- Left-click still selects; the side panel still works; drag-nav on the map still works.

- [ ] **Step 4: Commit**

```bash
git add ui/src/components/screen/ScreenGrid.tsx ui/src/components/screen/NavigationMapView.tsx
git commit -m "feat(ui): right-click context menu on screens (grid + navigation map)"
```

---

## Self-Review

**Spec/decision coverage:**
- Right-click → modal: Tasks 7, 8, 9. ✔
- Modal edits all bytes except nav pointers: Task 6 (+ backend Task 1). ✔
- Illustrated descriptive dropdowns (swatches, enemy thumbnails, descriptions): Tasks 4, 5, 6. ✔
- Safety tiers as warnings (no WorldScreen field in Expert): Task 6 via `GuidedField`/metadata; objectset/datapointer/exit/event/unknown all rendered in the modal with danger badges, none routed to Expert. ✔
- Vanilla "changed" indicator: Tasks 2, 3, 6, 8. ✔
- Nav stays on map drag: unchanged; modal omits nav fields. ✔

**Type consistency:** `ScreenFieldsUpdate` widened once in client (Task 3) and consumed by store + WorldView. `onFieldChange` union (Task 6) matches the keys passed in WorldView's `updateScreenFields({ [field]: value })`. `SwatchOption` (Task 4) used by option lists (Task 5) and `GuidedSelectField` (Task 6). `EntityMetadata`/`FieldMetadata` (Phase 1 types) flow store→WorldView→modal. `ScreenVanilla` (Task 3) flows endpoint→client→store→WorldView→modal.

**Placeholder scan:** none — all steps show concrete code or exact change instructions with verification commands.

**Risk notes for the executor:** `NavigationMapView.tsx` is ~1800 lines and complex — make the Task 9 edit surgically at the screen-cell render site only. The store action signatures (`updateScreenTiles`, `updateScreenFields`) and `ScreenData`/`chapter_num` field names must be confirmed against the live code before wiring WorldView (Task 8) — read, don't assume.

---

## Notes for the Executor
- Python from `projects/TMOS_Randomizer_V2`; npm from `ui/`. Backend run: `python -m uvicorn tmos_randomizer.api.server:app --port 8000` (NOT `python -m tmos_randomizer serve`).
- Type-check the right way: `npx tsc -b` (the root tsconfig is references-only; `tsc --noEmit` checks nothing). Baseline is currently 0 errors — keep it there.
- Stage ONLY the files each task names. Never `git add -A`/`git add .`, never touch files you didn't edit for the task, never create or switch branches. The working tree may contain unrelated untracked files — leave them.
- Several existing components are reused as-is (ObjectSetField, ScreenNeighborhood, the tile picker, drag-nav) — do not refactor them.
