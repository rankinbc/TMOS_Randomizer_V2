# World Screen Editor Modal (Stage A) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Evolve the tile-section picker modal into a live World Screen editor: edit ObjectSet, Content, Event, and the two palette colors alongside Top/Bottom tile sections, without closing the modal, and navigate between neighbor screens in one session.

**Architecture:** One additive backend endpoint (`PATCH .../fields`, allowlisted) mirrors the existing tiles PATCH. The frontend restructures so `ScreenDetailPanel` owns the modal state (`editorOpen`, `activeHalf`) and renders a single `ScreenEditorModal` (which replaces today's `TileSectionDropdown`). New reusable field components (`EnumSelectField`, `ObjectSetField`) and an extended `ScreenNeighborhood` (clickable neighbors + center half-selector) compose the editor. Selecting a tile or editing a field does NOT close the modal — both flow through the store and re-render live.

**Tech Stack:** Python 3.13 / FastAPI / Pydantic (backend), React 19 + TypeScript + Vite + Zustand + Tailwind (frontend). Backend tested with pytest `TestClient` (skip-graceful without ROM). Frontend has no unit-test harness — verified live via Playwright against a throwaway server.

---

## Shared seam (locked — Stage B depends on this exact contract)

```tsx
// ui/src/components/screen/ObjectSetField.tsx
interface ObjectSetFieldProps {
  value: number;            // current objectset byte (0-255)
  chapterNum: number;
  chr: number;              // CHR index of the active screen (Stage B context)
  onChange: (v: number) => void;
}
```

Stage A ships this as a labeled `<select>` of ObjectSet category ranges + a raw 0-255 number input. Stage B adds an enemy-thumbnail strip **inside** this component without changing the props. Keep `ObjectSetField` minimal and self-contained to minimize the merge conflict with Stage B.

---

## File Structure

| File | Create/Modify | Responsibility |
|------|---------------|----------------|
| `src/tmos_randomizer/api/server.py` | Modify | Add `ScreenFieldsUpdate` model + `PATCH /api/rom/screen/{ch}/{idx}/fields` (allowlisted 5 fields) |
| `tests/test_integration/test_screen_fields_endpoint.py` | Create | TestClient tests for the new endpoint |
| `ui/src/api/client.ts` | Modify | `ScreenFieldsUpdateResponse` type + `updateScreenFields()` method |
| `ui/src/store/index.ts` | Modify | `updateScreenFields` action (mirror `updateScreenTiles`) |
| `ui/src/components/screen/EnumSelectField.tsx` | Create | Reusable labeled `<select>` of known values + raw 0-255 input |
| `ui/src/components/screen/ObjectSetField.tsx` | Create | The seam (select of ObjectSet ranges + raw input) |
| `ui/src/components/screen/ScreenEditorModal.tsx` | Create | The editor modal (replaces `TileSectionDropdown`); owns `SectionThumb` with `shadeBottomRows` |
| `ui/src/components/screen/ScreenNeighborhood.tsx` | Modify | `onSelect` for neighbors + center half-selector zones with shading |
| `ui/src/components/screen/ScreenDetailPanel.tsx` | Modify | Own `editorOpen`/`activeHalf`; field buttons open editor; `handleFieldChange`; render one `ScreenEditorModal` |
| `ui/src/components/screen/TileSectionPicker.tsx` | Delete | Its role is absorbed by `ScreenDetailPanel` + `ScreenEditorModal` |

**Known-value data the editor needs** (reuse, do NOT re-derive): `CONTENT_TYPES`, `CHAPTER_NPCS`, `EVENT_TYPES` already exist in `ScreenDetailPanel.tsx`. Stage A moves the *content/event option building* into the modal but reads from these same maps — to avoid a circular import, export the three maps from `ScreenDetailPanel.tsx` (named exports) and import them in `ScreenEditorModal.tsx`.

---

## Task 1: Backend — `PATCH .../fields` endpoint (allowlisted)

**Files:**
- Modify: `src/tmos_randomizer/api/server.py` (add model near line 150 next to `TileSectionUpdate`; add endpoint after the tiles PATCH which ends at line 709)
- Test: `tests/test_integration/test_screen_fields_endpoint.py`

- [ ] **Step 1: Write the failing tests**

Create `tests/test_integration/test_screen_fields_endpoint.py`:

```python
"""Endpoint tests for the screen-fields PATCH API (Stage A world-screen editor).

Drives the real FastAPI app; loads the default ROM if present and skips when it
is unavailable, matching the project's existing asset-dependent test pattern.
"""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    resp = c.post("/api/rom/load-default")
    if resp.status_code != 200:
        pytest.skip("default ROM not available")
    return c


def test_update_field_objectset_ok(client):
    before = client.get("/api/rom/screen/1/0").json()
    resp = client.patch("/api/rom/screen/1/0/fields", json={"objectset": 7})
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "updated"
    assert body["screen"]["objectset"] == 7
    # restore
    client.patch("/api/rom/screen/1/0/fields", json={"objectset": before["objectset"]})


def test_update_field_all_five(client):
    before = client.get("/api/rom/screen/1/0").json()
    resp = client.patch(
        "/api/rom/screen/1/0/fields",
        json={
            "objectset": 3,
            "content": 0x60,
            "event": 0x05,
            "worldscreen_color": 0x30,
            "sprites_color": 0x0F,
        },
    )
    assert resp.status_code == 200
    s = resp.json()["screen"]
    assert s["objectset"] == 3
    assert s["content"] == 0x60
    assert s["event"] == 0x05
    assert s["worldscreen_color"] == 0x30
    assert s["sprites_color"] == 0x0F
    # restore each
    client.patch(
        "/api/rom/screen/1/0/fields",
        json={
            "objectset": before["objectset"],
            "content": before["content"],
            "event": before["event"],
            "worldscreen_color": before["worldscreen_color"],
            "sprites_color": before["sprites_color"],
        },
    )


def test_update_field_rejects_parent_world(client):
    # parent_world is NOT in the allowlist — sending it must not change the screen.
    before = client.get("/api/rom/screen/1/0").json()
    resp = client.patch(
        "/api/rom/screen/1/0/fields",
        json={"parent_world": (before["parent_world"] + 1) & 0xFF},
    )
    # No allowlisted field provided -> 400 (same guard as tiles PATCH).
    assert resp.status_code == 400
    after = client.get("/api/rom/screen/1/0").json()
    assert after["parent_world"] == before["parent_world"]


def test_update_field_out_of_range(client):
    resp = client.patch("/api/rom/screen/1/0/fields", json={"content": 256})
    assert resp.status_code == 400


def test_update_field_none_provided(client):
    resp = client.patch("/api/rom/screen/1/0/fields", json={})
    assert resp.status_code == 400


def test_update_field_missing_screen(client):
    resp = client.patch("/api/rom/screen/1/9999/fields", json={"objectset": 5})
    assert resp.status_code == 404
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_integration/test_screen_fields_endpoint.py -v`
Expected: FAIL (404 — route does not exist yet), or all skip if no ROM. If they skip, that is acceptable but you must still implement; re-run after implementing to confirm they would pass on a ROM-present machine.

- [ ] **Step 3: Add the Pydantic model**

In `src/tmos_randomizer/api/server.py`, immediately after the `TileSectionUpdate` class (ends ~line 153), add:

```python
class ScreenFieldsUpdate(BaseModel):
    """Allowlisted low-risk WorldScreen fields for the editor modal.

    Deliberately EXCLUDES parent_world, ambient_sound, navigation, exit_position,
    and datapointer/chr — those are managed elsewhere and are not safe to set here.
    """
    objectset: Optional[int] = None
    content: Optional[int] = None
    event: Optional[int] = None
    worldscreen_color: Optional[int] = None
    sprites_color: Optional[int] = None
```

- [ ] **Step 4: Add the endpoint**

In `src/tmos_randomizer/api/server.py`, after the tiles PATCH endpoint (after line 709), add:

```python
@app.patch("/api/rom/screen/{chapter_num}/{screen_index}/fields")
async def update_screen_fields(
    chapter_num: int,
    screen_index: int,
    update: ScreenFieldsUpdate,
):
    """Update a screen's low-risk fields (live, in-memory).

    Strict allowlist: objectset, content, event, worldscreen_color, sprites_color.
    Each provided value must be 0-255. Mirrors the tiles PATCH guard order.
    """
    from ..core.constants import get_chr_index

    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")
    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found")

    # Allowlist: explicit so excluded fields can never be set here.
    fields = {
        "objectset": update.objectset,
        "content": update.content,
        "event": update.event,
        "worldscreen_color": update.worldscreen_color,
        "sprites_color": update.sprites_color,
    }
    provided = {k: v for k, v in fields.items() if v is not None}
    if not provided:
        raise HTTPException(
            status_code=400,
            detail="Provide at least one of: objectset, content, event, worldscreen_color, sprites_color",
        )
    for label, val in provided.items():
        if val < 0 or val > 255:
            raise HTTPException(status_code=400, detail=f"{label} must be 0-255, got {val}")

    for label, val in provided.items():
        setattr(screen, label, val)
    screen.mark_modified()

    return {
        "status": "updated",
        "screen": {
            "index": screen.relative_index,
            "global_index": screen.global_index,
            "datapointer": screen.datapointer,
            "chr_index": get_chr_index(screen.datapointer),
            "top_tiles": screen.top_tiles,
            "bottom_tiles": screen.bottom_tiles,
            "objectset": screen.objectset,
            "parent_world": screen.parent_world,
            "event": screen.event,
            "content": screen.content,
            "nav_right": screen.screen_index_right,
            "nav_left": screen.screen_index_left,
            "nav_down": screen.screen_index_down,
            "nav_up": screen.screen_index_up,
            "worldscreen_color": screen.worldscreen_color,
            "sprites_color": screen.sprites_color,
            "exit_position": screen.exit_position,
        },
    }
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_integration/test_screen_fields_endpoint.py -v`
Expected: PASS (or skip if no ROM on this machine — in which case confirm there are zero collection/import errors).

- [ ] **Step 6: Commit**

```bash
git add src/tmos_randomizer/api/server.py tests/test_integration/test_screen_fields_endpoint.py
git commit -m "feat(api): add allowlisted PATCH screen/fields endpoint"
```

---

## Task 2: Frontend client — `updateScreenFields`

**Files:**
- Modify: `ui/src/api/client.ts` (add type after `ScreenTilesUpdateResponse` at line 140; add method after `updateScreenTiles` at line 708)

- [ ] **Step 1: Add the response type**

In `ui/src/api/client.ts`, after the `ScreenTilesUpdateResponse` interface (line 140), add:

```typescript
export interface ScreenFieldsUpdateResponse {
  status: string;
  screen: ScreenData;
}

export interface ScreenFieldsUpdate {
  objectset?: number;
  content?: number;
  event?: number;
  worldscreen_color?: number;
  sprites_color?: number;
}
```

- [ ] **Step 2: Add the client method**

In `ui/src/api/client.ts`, after the `updateScreenTiles` method (closes at line 708), add inside the `ApiClient` class:

```typescript
  // Update low-risk screen fields (objectset, content, event, colors).
  async updateScreenFields(
    chapterNum: number,
    screenIndex: number,
    fields: ScreenFieldsUpdate
  ): Promise<ScreenFieldsUpdateResponse> {
    return this.fetch<ScreenFieldsUpdateResponse>(
      `/api/rom/screen/${chapterNum}/${screenIndex}/fields`,
      { method: 'PATCH', body: JSON.stringify(fields) }
    );
  }
```

- [ ] **Step 3: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No NEW errors beyond the pre-existing baseline (8 errors). If the count rises above baseline from files you touched, fix them.

- [ ] **Step 4: Commit**

```bash
git add ui/src/api/client.ts
git commit -m "feat(ui): add updateScreenFields API client method"
```

---

## Task 3: Store — `updateScreenFields` action

**Files:**
- Modify: `ui/src/store/index.ts` (import the type at line 26; declare the action in the interface near line 169; implement it after `updateScreenTiles` at line 642)

- [ ] **Step 1: Import the type**

In `ui/src/store/index.ts`, add `ScreenFieldsUpdate` to the import block from `'../api/client'` (the block ending at line 26):

```typescript
  type EnemyStatPatch,
  type ScreenFieldsUpdate,
} from '../api/client';
```

- [ ] **Step 2: Declare the action in the interface**

In the `RandomizerState` interface, immediately after the `updateScreenTiles` declaration (ends at line 169), add:

```typescript
  updateScreenFields: (
    screenIndex: number,
    fields: ScreenFieldsUpdate
  ) => Promise<void>;
```

- [ ] **Step 3: Implement the action**

In `ui/src/store/index.ts`, immediately after the `updateScreenTiles` implementation (closes at line 642), add:

```typescript
  updateScreenFields: async (screenIndex, fields) => {
    const state = get();
    if (!state.chapterData) {
      throw new Error('No chapter data loaded');
    }
    try {
      const response = await api.updateScreenFields(
        state.selectedChapter,
        screenIndex,
        fields
      );
      const updatedScreens = state.chapterData.screens.map((screen) =>
        screen.index === response.screen.index ? response.screen : screen
      );
      set({
        chapterData: { ...state.chapterData, screens: updatedScreens },
      });
    } catch (error) {
      set({
        apiError: error instanceof Error ? error.message : 'Failed to update fields',
      });
      throw error;
    }
  },
```

- [ ] **Step 4: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond baseline.

- [ ] **Step 5: Commit**

```bash
git add ui/src/store/index.ts
git commit -m "feat(ui): add updateScreenFields store action"
```

---

## Task 4: `EnumSelectField` component

**Files:**
- Create: `ui/src/components/screen/EnumSelectField.tsx`

- [ ] **Step 1: Create the component**

Create `ui/src/components/screen/EnumSelectField.tsx`:

```tsx
export interface EnumOption {
  value: number;
  label: string;
}

interface EnumSelectFieldProps {
  label: string;
  value: number;
  options: EnumOption[];
  onChange: (v: number) => void;
}

/**
 * A labeled field with a <select> of known values plus a raw 0-255 number input,
 * kept in sync. The select shows the current value's label when it is a known
 * option; otherwise it falls back to a synthetic "Custom (0xNN)" entry so the
 * control always reflects the live value. The number input always accepts any
 * 0-255 byte.
 */
export function EnumSelectField({ label, value, options, onChange }: EnumSelectFieldProps) {
  const known = options.some((o) => o.value === value);
  const hex = `0x${value.toString(16).toUpperCase().padStart(2, '0')}`;

  return (
    <div className="flex items-center justify-between gap-2 text-sm">
      <span className="text-slate-500 shrink-0">{label}</span>
      <div className="flex items-center gap-1">
        <select
          className="bg-slate-700 text-slate-200 text-xs rounded px-1 py-0.5 max-w-[150px]"
          value={known ? value : -1}
          onChange={(e) => onChange(Number(e.target.value))}
        >
          {!known && <option value={-1}>{`Custom (${hex})`}</option>}
          {options.map((o) => (
            <option key={o.value} value={o.value}>
              {o.label}
            </option>
          ))}
        </select>
        <input
          type="number"
          min={0}
          max={255}
          value={value}
          onChange={(e) => {
            const n = Number(e.target.value);
            if (!Number.isNaN(n) && n >= 0 && n <= 255) onChange(n);
          }}
          className="w-14 bg-slate-700 text-slate-200 font-mono text-xs rounded px-1 py-0.5"
        />
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond baseline.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/screen/EnumSelectField.tsx
git commit -m "feat(ui): add reusable EnumSelectField (select + raw byte input)"
```

---

## Task 5: `ObjectSetField` component (the seam)

**Files:**
- Create: `ui/src/components/screen/ObjectSetField.tsx`

This is the shared seam with Stage B. Keep it minimal and self-contained. Do NOT add fetch logic — Stage B will.

- [ ] **Step 1: Create the component**

Create `ui/src/components/screen/ObjectSetField.tsx`:

```tsx
export interface ObjectSetFieldProps {
  value: number;            // current objectset byte (0-255)
  chapterNum: number;
  chr: number;              // CHR index of the active screen (Stage B context)
  onChange: (v: number) => void;
}

// Category representatives derived from getObjectSetDescription ranges. The raw
// number input gives exact 0-255 control; the select offers labeled jumping-off
// points for each documented category.
const OBJECTSET_OPTIONS: { value: number; label: string }[] = [
  { value: 0x00, label: '0x00 Empty (no spawns)' },
  { value: 0x01, label: '0x01 Dungeon/staircase' },
  { value: 0x03, label: '0x03 Overworld enemies' },
  { value: 0x16, label: '0x16 Town NPCs (non-hostile)' },
  { value: 0x34, label: '0x34 Dungeon/maze enemies' },
  { value: 0x36, label: '0x36 Special area' },
];

/**
 * ObjectSet editor. Stage A: a labeled select of category ranges + a raw 0-255
 * input. Stage B enhances the INTERNALS of this component (adds an enemy-thumbnail
 * strip) without changing these props. `chapterNum`/`chr` are accepted now so the
 * seam is stable for Stage B.
 */
export function ObjectSetField({ value, chapterNum, chr, onChange }: ObjectSetFieldProps) {
  // chapterNum and chr are part of the stable seam; Stage B consumes them.
  void chapterNum;
  void chr;
  const known = OBJECTSET_OPTIONS.some((o) => o.value === value);
  const hex = `0x${value.toString(16).toUpperCase().padStart(2, '0')}`;

  return (
    <div className="flex items-center justify-between gap-2 text-sm">
      <span className="text-slate-500 shrink-0">ObjectSet</span>
      <div className="flex items-center gap-1">
        <select
          className="bg-slate-700 text-slate-200 text-xs rounded px-1 py-0.5 max-w-[150px]"
          value={known ? value : -1}
          onChange={(e) => onChange(Number(e.target.value))}
        >
          {!known && <option value={-1}>{`Custom (${hex})`}</option>}
          {OBJECTSET_OPTIONS.map((o) => (
            <option key={o.value} value={o.value}>
              {o.label}
            </option>
          ))}
        </select>
        <input
          type="number"
          min={0}
          max={255}
          value={value}
          onChange={(e) => {
            const n = Number(e.target.value);
            if (!Number.isNaN(n) && n >= 0 && n <= 255) onChange(n);
          }}
          className="w-14 bg-slate-700 text-slate-200 font-mono text-xs rounded px-1 py-0.5"
        />
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond baseline. (`void chapterNum; void chr;` deliberately satisfies no-unused-vars while keeping the seam props.)

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/screen/ObjectSetField.tsx
git commit -m "feat(ui): add ObjectSetField seam component (Stage A)"
```

---

## Task 6: Export known-value maps from `ScreenDetailPanel`

**Files:**
- Modify: `ui/src/components/screen/ScreenDetailPanel.tsx` (add `export` to three existing `const` maps + the two helper functions the modal reuses)

The modal needs `CONTENT_TYPES`, `CHAPTER_NPCS`, `EVENT_TYPES`, and the `getContentInfo`/`getObjectSetDescription` helpers. Export them so `ScreenEditorModal` imports from one source (no duplication).

- [ ] **Step 1: Add `export` keywords**

In `ui/src/components/screen/ScreenDetailPanel.tsx`, change these declarations to named exports (add `export` before each):

- Line 18: `const CONTENT_TYPES` → `export const CONTENT_TYPES`
- Line 81: `const CHAPTER_NPCS` → `export const CHAPTER_NPCS`
- Line 136: `const EVENT_TYPES` → `export const EVENT_TYPES`

- [ ] **Step 2: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond baseline.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/screen/ScreenDetailPanel.tsx
git commit -m "refactor(ui): export content/npc/event maps for the editor modal"
```

---

## Task 7: Extend `ScreenNeighborhood` — clickable neighbors + center half-selector

**Files:**
- Modify: `ui/src/components/screen/ScreenNeighborhood.tsx`

The center cell becomes a half-selector: a top zone (rows 0-3) and a bottom zone (rows 4-5) overlaid on the rendered screen; clicking shades that half and calls `onHalfSelect`. Non-center cells become clickable and call `onSelect(screenIndex)`. Both new props are OPTIONAL so the existing call site (today's picker, until it is replaced in Task 9) keeps working.

- [ ] **Step 1: Replace the component (keep `buildNeighborhood` and the `Neighborhood` type unchanged)**

In `ui/src/components/screen/ScreenNeighborhood.tsx`, replace the `ScreenNeighborhood` function (lines 43-88) with:

```tsx
export function ScreenNeighborhood({
  selected,
  byIndex,
  chapterNum,
  onSelect,
  activeHalf,
  onHalfSelect,
}: {
  selected: ScreenData;
  byIndex: Map<number, ScreenData>;
  chapterNum: number;
  /** Click a neighbor cell to make it the selected screen. */
  onSelect?: (screenIndex: number) => void;
  /** When provided, the center cell becomes a top/bottom half-selector. */
  activeHalf?: 'top' | 'bottom';
  onHalfSelect?: (half: 'top' | 'bottom') => void;
}) {
  const { cells } = buildNeighborhood(selected, byIndex);
  // Bump the cell size a touch so the half zones are comfortably clickable.
  const W = 100;
  const H = Math.round(W * 0.75); // 4:3
  const halfSelectable = activeHalf !== undefined && onHalfSelect !== undefined;

  return (
    <div className="p-3 border-b border-slate-700">
      <div className="text-xs text-slate-500 mb-2 text-center">
        {halfSelectable
          ? 'Click the top or bottom of the center screen to choose which half you are editing — click a neighbor to edit it.'
          : 'Selected screen (center) and its neighbors — pairing context'}
      </div>
      <div className="grid grid-cols-3 gap-1 w-fit mx-auto">
        {cells.map((cell, i) => {
          const isCenter = i === 4;
          if (!cell) {
            return (
              <div
                key={i}
                className="bg-slate-900/40 rounded"
                style={{ width: W, height: H }}
              />
            );
          }
          if (isCenter && halfSelectable) {
            return (
              <div
                key={i}
                className="relative rounded overflow-hidden ring-2 ring-yellow-400"
                style={{ width: W, height: H }}
              >
                <ScreenMini
                  screen={cell}
                  chapterNum={chapterNum}
                  size={W}
                  showIndex={true}
                  tileOpacity={1}
                />
                {/* Top zone = rows 0-3 = upper 4/6 of the screen. */}
                <button
                  className={`absolute inset-x-0 top-0 ${
                    activeHalf === 'top' ? 'bg-blue-400/30 ring-1 ring-blue-300' : 'hover:bg-white/10'
                  }`}
                  style={{ height: `${(4 / 6) * 100}%` }}
                  onClick={() => onHalfSelect!('top')}
                  title="Edit Top tile section (rows 0-3)"
                >
                  <span className="absolute top-0 right-0 bg-black/60 text-[8px] text-white px-1">TOP</span>
                </button>
                {/* Bottom zone = rows 4-5 = lower 2/6 of the screen. */}
                <button
                  className={`absolute inset-x-0 bottom-0 ${
                    activeHalf === 'bottom' ? 'bg-blue-400/30 ring-1 ring-blue-300' : 'hover:bg-white/10'
                  }`}
                  style={{ height: `${(2 / 6) * 100}%` }}
                  onClick={() => onHalfSelect!('bottom')}
                  title="Edit Bottom tile section (rows 4-5)"
                >
                  <span className="absolute bottom-0 right-0 bg-black/60 text-[8px] text-white px-1">BOT</span>
                </button>
              </div>
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
                size={W}
                showIndex={true}
                selected={false}
                onClick={!isCenter && onSelect ? () => onSelect(cell.index) : undefined}
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

- [ ] **Step 2: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond baseline. (The existing picker call site passes only `selected`/`byIndex`/`chapterNum` — the new props are optional, so it still compiles until Task 9 deletes it.)

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/screen/ScreenNeighborhood.tsx
git commit -m "feat(ui): add neighbor click + center half-selector to ScreenNeighborhood"
```

---

## Task 8: `ScreenEditorModal` component

**Files:**
- Create: `ui/src/components/screen/ScreenEditorModal.tsx`

This replaces `TileSectionDropdown`. It owns `SectionThumb` (extended with `shadeBottomRows`). It renders the neighborhood half-selector, the Fields block, and the 471-thumbnail grid driven by `activeHalf`.

- [ ] **Step 1: Create the component**

Create `ui/src/components/screen/ScreenEditorModal.tsx`:

```tsx
import { useRef, useEffect, useState, useMemo } from 'react';
import { api, ApiClient } from '../../api/client';
import type { ScreenData } from '../../api/client';
import { ScreenNeighborhood } from './ScreenNeighborhood';
import { EnumSelectField, type EnumOption } from './EnumSelectField';
import { ObjectSetField } from './ObjectSetField';
import { CONTENT_TYPES, CHAPTER_NPCS, EVENT_TYPES } from './ScreenDetailPanel';

const TOTAL = ApiClient.TILESECTION_COUNT; // 471

// WorldScreen color options — labels from the renderer's getGroundColor cases.
const WS_COLOR_OPTIONS: EnumOption[] = [
  { value: 0x21, label: '0x21 Past (green)' },
  { value: 0x30, label: '0x30 Water (blue)' },
  { value: 0x25, label: '0x25 Desert (sand)' },
  { value: 0x1a, label: '0x1A Dark palace' },
  { value: 0x3c, label: '0x3C Red' },
  { value: 0x23, label: '0x23 Winter (gray)' },
  { value: 0x27, label: '0x27 Black' },
  { value: 0x1c, label: '0x1C Lava' },
];

// Sprite color — no rich documented map; offer a couple of known anchors and rely
// on the raw input for the rest.
const SPRITE_COLOR_OPTIONS: EnumOption[] = [
  { value: 0x0f, label: '0x0F Default' },
  { value: 0x30, label: '0x30 Town' },
];

function buildContentOptions(chapterNum: number): EnumOption[] {
  const opts: EnumOption[] = Object.entries(CONTENT_TYPES).map(([k, v]) => ({
    value: Number(k),
    label: `0x${Number(k).toString(16).toUpperCase().padStart(2, '0')} ${v.name}`,
  }));
  const npcs = CHAPTER_NPCS[chapterNum] ?? {};
  for (const [k, v] of Object.entries(npcs)) {
    opts.push({
      value: Number(k),
      label: `0x${Number(k).toString(16).toUpperCase().padStart(2, '0')} ${v.name}`,
    });
  }
  return opts.sort((a, b) => a.value - b.value);
}

const EVENT_OPTIONS: EnumOption[] = Object.entries(EVENT_TYPES)
  .map(([k, v]) => ({
    value: Number(k),
    label: `0x${Number(k).toString(16).toUpperCase().padStart(2, '0')} ${v.name}`,
  }))
  .sort((a, b) => a.value - b.value);

// Bank selection per half from the DataPointer (value-range model — matches the
// backend renderer's get_bank_offset, NOT the bit model). Mirrors getBanks in
// ScreenDetailPanel.
function getBanks(datapointer: number): { top: number; bottom: number } {
  if (datapointer >= 0xc0) return { top: 1, bottom: 1 };
  if (datapointer >= 0x8f && datapointer < 0xa0) return { top: 1, bottom: 0 };
  if (datapointer >= 0x40 && datapointer < 0x8f) return { top: 0, bottom: 1 };
  return { top: 0, bottom: 0 };
}

interface ScreenEditorModalProps {
  screen: ScreenData;
  screens?: ScreenData[];
  chapterNum: number;
  activeHalf: 'top' | 'bottom';
  onHalfChange: (half: 'top' | 'bottom') => void;
  onClose: () => void;
  onScreenSelect?: (index: number) => void;
  onFieldChange: (field: 'objectset' | 'content' | 'event' | 'worldscreen_color' | 'sprites_color', value: number) => void;
  onTilePick: (which: 'top' | 'bottom', globalIndex: number) => void;
}

export function ScreenEditorModal({
  screen,
  screens,
  chapterNum,
  activeHalf,
  onHalfChange,
  onClose,
  onScreenSelect,
  onFieldChange,
  onTilePick,
}: ScreenEditorModalProps) {
  const indices = useMemo(() => Array.from({ length: TOTAL }, (_, i) => i), []);
  const byIndex = useMemo(
    () => new Map((screens ?? []).map((s) => [s.index, s])),
    [screens],
  );
  const showNeighborhood = byIndex.size > 0;

  const chr = screen.datapointer & 0x3f;
  const banks = getBanks(screen.datapointer);
  const currentByte = activeHalf === 'top' ? screen.top_tiles : screen.bottom_tiles;
  const currentBank = activeHalf === 'top' ? banks.top : banks.bottom;
  const currentGlobal = currentBank * 256 + currentByte;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div
        className="bg-slate-800 border border-slate-600 rounded-lg shadow-xl w-[820px] max-h-[85vh] flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-3 border-b border-slate-700">
          <h4 className="text-slate-200 font-semibold">
            Edit World Screen — #{screen.index} (editing {activeHalf} section)
          </h4>
          <button onClick={onClose} className="text-slate-400 hover:text-white text-xl">&times;</button>
        </div>

        {showNeighborhood && (
          <ScreenNeighborhood
            selected={screen}
            byIndex={byIndex}
            chapterNum={chapterNum}
            onSelect={onScreenSelect}
            activeHalf={activeHalf}
            onHalfSelect={onHalfChange}
          />
        )}

        {/* Fields block */}
        <div className="p-3 border-b border-slate-700 space-y-1.5 bg-slate-900/40">
          <ObjectSetField
            value={screen.objectset}
            chapterNum={chapterNum}
            chr={chr}
            onChange={(v) => onFieldChange('objectset', v)}
          />
          <EnumSelectField
            label="Content"
            value={screen.content}
            options={buildContentOptions(chapterNum)}
            onChange={(v) => onFieldChange('content', v)}
          />
          <EnumSelectField
            label="Event"
            value={screen.event}
            options={EVENT_OPTIONS}
            onChange={(v) => onFieldChange('event', v)}
          />
          <EnumSelectField
            label="WS Color"
            value={screen.worldscreen_color}
            options={WS_COLOR_OPTIONS}
            onChange={(v) => onFieldChange('worldscreen_color', v)}
          />
          <EnumSelectField
            label="Sprite Color"
            value={screen.sprites_color}
            options={SPRITE_COLOR_OPTIONS}
            onChange={(v) => onFieldChange('sprites_color', v)}
          />
        </div>

        {/* Section grid — a grid item's own aspect-ratio does NOT size its auto-row
            track, so set an explicit row height (~94px = half the ~189px column
            width in the fixed 820px modal) to give every cell the section's true
            8x4 (2:1) shape. */}
        <div
          className="overflow-y-auto p-3 grid grid-cols-4 gap-2"
          style={{ gridAutoRows: '94px' }}
        >
          {indices.map((g) => (
            <SectionThumb
              key={g}
              globalIndex={g}
              chr={chr}
              selected={g === currentGlobal}
              crossBank={g >= 256}
              shadeBottomRows={activeHalf === 'bottom'}
              onClick={() => onTilePick(activeHalf, g)}
            />
          ))}
        </div>
        <div className="p-2 border-t border-slate-700 text-xs text-slate-500">
          Editing the {activeHalf} half. Sections ≥ 256 are in bank 1 — selecting one also changes the screen's DataPointer/CHR. Picking does not close the editor.
        </div>
      </div>
    </div>
  );
}

function SectionThumb({
  globalIndex, chr, selected, crossBank, shadeBottomRows, onClick,
}: {
  globalIndex: number;
  chr: number;
  selected: boolean;
  crossBank: boolean;
  shadeBottomRows?: boolean;
  onClick: () => void;
}) {
  const ref = useRef<HTMLButtonElement>(null);
  const [visible, setVisible] = useState(false);

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
      style={{ backgroundColor: '#0f172a' }}
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
      {/* When editing the screen's BOTTOM, only the section's top 2 rows are used;
          shade the lower 50% (unused rows 2-3) so the picker reflects that. */}
      {shadeBottomRows && (
        <div className="absolute inset-x-0 bottom-0 h-1/2 bg-black/55 pointer-events-none" />
      )}
      <span className="absolute top-0 left-0 bg-black/70 text-white text-[8px] font-mono px-1">
        {globalIndex}{crossBank ? '*' : ''}
      </span>
    </button>
  );
}
```

- [ ] **Step 2: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond baseline.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/screen/ScreenEditorModal.tsx
git commit -m "feat(ui): add ScreenEditorModal (live editor, half-selector, field block)"
```

---

## Task 9: Rewire `ScreenDetailPanel` + delete `TileSectionPicker`

**Files:**
- Modify: `ui/src/components/screen/ScreenDetailPanel.tsx`
- Delete: `ui/src/components/screen/TileSectionPicker.tsx`

`ScreenDetailPanel` owns `editorOpen` + `activeHalf`. The Top/Bottom tile rows and the ObjectSet/Content/Event/color displays become buttons that open the editor (tile buttons also set `activeHalf`). One `ScreenEditorModal` is rendered when `editorOpen`. `handleFieldChange` calls the store. `onScreenSelect` is threaded to the modal for neighbor navigation.

- [ ] **Step 1: Swap the import**

In `ui/src/components/screen/ScreenDetailPanel.tsx`, replace the import at line 7:

```tsx
import { ScreenEditorModal } from './ScreenEditorModal';
```

(Remove `import { TileSectionPicker } from './TileSectionPicker';`.)

- [ ] **Step 2: Add state, store action, and a field-change handler**

In the `ScreenDetailPanel` function body, after the `updateScreenTiles` line (line 242), add:

```tsx
  const updateScreenFields = useRandomizerStore((s) => s.updateScreenFields);
  const [editorOpen, setEditorOpen] = useState(false);
  const [activeHalf, setActiveHalf] = useState<'top' | 'bottom'>('top');

  const openEditor = (half: 'top' | 'bottom') => {
    setActiveHalf(half);
    setEditorOpen(true);
  };

  const handleFieldChange = async (
    field: 'objectset' | 'content' | 'event' | 'worldscreen_color' | 'sprites_color',
    value: number,
  ) => {
    try {
      await updateScreenFields(screen.index, { [field]: value });
    } catch {
      // store already surfaced the error via apiError
    }
  };
```

- [ ] **Step 3: Replace the two `<TileSectionPicker>` rows with editor-opening buttons**

In the "Graphics (DataPointer)" section, replace the block containing the two `<TileSectionPicker ... />` and the `tileNote` (lines 418-442) with:

```tsx
          <div className="border-t border-slate-700 mt-2 pt-2 space-y-1">
            <div className="flex justify-between text-sm items-center">
              <span className="text-slate-500">Top TileSection</span>
              <button
                onClick={() => openEditor('top')}
                className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
                title="Open the screen editor on the top section"
              >
                0x{screen.top_tiles.toString(16).toUpperCase()} ({screen.top_tiles})
              </button>
            </div>
            <div className="flex justify-between text-sm items-center">
              <span className="text-slate-500">Bottom TileSection</span>
              <button
                onClick={() => openEditor('bottom')}
                className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
                title="Open the screen editor on the bottom section"
              >
                0x{screen.bottom_tiles.toString(16).toUpperCase()} ({screen.bottom_tiles})
              </button>
            </div>
            {tileNote && (
              <div className="text-xs text-amber-400 pt-1">{tileNote}</div>
            )}
          </div>
```

- [ ] **Step 4: Make the ObjectSet row open the editor too**

Replace the "Enemy Spawning" `DataSection` body (lines 446-451) with a clickable row:

```tsx
        <DataSection title="Enemy Spawning">
          <div className="flex justify-between text-sm items-center">
            <span className="text-slate-500">ObjectSet</span>
            <button
              onClick={() => openEditor(activeHalf)}
              className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
              title="Open the screen editor to change ObjectSet"
            >
              0x{screen.objectset.toString(16).toUpperCase()} ({screen.objectset})
            </button>
          </div>
          <div className="text-xs text-slate-500 mt-1">
            {getObjectSetDescription(screen.objectset)}
          </div>
        </DataSection>
```

- [ ] **Step 5: Render the modal once, at the end of the component**

Immediately before the final closing `</div>` of the returned tree (the wrapper `div` that opens at line 267, closes at line 475), add:

```tsx
      {editorOpen && (
        <ScreenEditorModal
          screen={screen}
          screens={screens}
          chapterNum={chapterNum}
          activeHalf={activeHalf}
          onHalfChange={setActiveHalf}
          onClose={() => setEditorOpen(false)}
          onScreenSelect={onScreenSelect}
          onFieldChange={handleFieldChange}
          onTilePick={handlePickTile}
        />
      )}
```

Note: `handlePickTile` already exists (line 246) and accepts `(which, globalIndex)`; its signature matches `onTilePick`. It does NOT close the modal (it only sets `tileNote`), satisfying the "pick does not close" requirement.

- [ ] **Step 6: Delete the obsolete picker**

```bash
git rm ui/src/components/screen/TileSectionPicker.tsx
```

- [ ] **Step 7: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond baseline. Confirm nothing else imports `TileSectionPicker` (grep first): `grep -r TileSectionPicker ui/src` should return nothing.

- [ ] **Step 8: Commit**

```bash
git add ui/src/components/screen/ScreenDetailPanel.tsx
git commit -m "feat(ui): ScreenDetailPanel owns the editor modal; remove TileSectionPicker"
```

---

## Task 10: Live verification (Playwright)

**Files:** none (verification only). Use the `verify` skill.

- [ ] **Step 1: Start a throwaway backend on a fresh port + load the default ROM**

Run (background): `cd projects/TMOS_Randomizer_V2 && python -m uvicorn tmos_randomizer.api.server:app --port 8100`
Then: `curl -s -X POST http://localhost:8100/api/rom/load-default` → expect `200` with chapter list.

- [ ] **Step 2: Start the UI pointed at that backend on a fresh port**

Run (background): `cd projects/TMOS_Randomizer_V2/ui && VITE_API_URL=http://localhost:8100 npx vite --port 5100`

- [ ] **Step 3: Drive the editor with Playwright and capture evidence**

Navigate to `http://localhost:5100`, open a chapter, select a mid-map screen, open its detail panel, and verify each behavior — capture a screenshot for each:
1. Click "Top TileSection" → editor opens; the section grid renders full 8×4 thumbnails (no overlap).
2. Click a section thumbnail → the center screen + panel preview re-render with the new tiles; **modal stays open**.
3. Click the BOTTOM zone of the center screen → its lower 2/6 shades; every section thumbnail now shades its lower half; the grid highlight tracks `bottom_tiles`.
4. Edit ObjectSet via the number input → no crash; value persists (re-open shows it).
5. Edit Content, Event, WS Color, Sprite Color → WS Color change visibly re-tints the screen render.
6. Click a neighbor screen in the 3×3 → it becomes the selected screen, the panel behind follows, and the modal re-centers on it (stays open).
7. Close via × and via overlay click → both close.

- [ ] **Step 4: Probe edge cases**

- Open the editor on an edge/orphan screen (blocked neighbors) → empty neighbor placeholders, grid still works.
- Type `300` into a field's number input → it clamps/ignores (stays ≤255), no bad PATCH.

- [ ] **Step 5: Report**

Produce a verification report (PASS/FAIL) with the screenshots inline. If anything fails, switch to the systematic-debugging skill — do not patch blindly.

---

## Self-Review (completed during planning)

- **Spec coverage:** Modal-stays-open (Task 9 step 5 note + Task 8 grid `onTilePick`), neighbor click changes global selection (Task 7 `onSelect` → Task 9 `onScreenSelect` → store `setSelectedScreen` wired by the panel's existing `onScreenSelect` prop), five field editors (Task 8 Fields block), click-top/bottom half-selector + bottom-row shading (Task 7 center zones + Task 8 `shadeBottomRows`), allowlisted backend (Task 1). ✓
- **Type consistency:** `onFieldChange` field union is identical in `ScreenEditorModal` props (Task 8) and `handleFieldChange` (Task 9). `handlePickTile(which, globalIndex)` matches `onTilePick`. `EnumOption` exported from Task 4, imported in Task 8. `ScreenFieldsUpdate` defined in Task 2, imported in Task 3. ✓
- **Excluded fields:** parent_world/ambient_sound/navigation/exit_position/datapointer never appear in the allowlist (Task 1) or the field block (Task 8). ✓
