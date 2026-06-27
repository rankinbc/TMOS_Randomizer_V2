# TMOS Randomizer UI Overhaul — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the World tab into the primary world-customization hub, generalize the click-to-select picker pattern across the whole UI, add an Encounters editing surface with 2-way sync, and enrich every "data dump" tab with graphics, explanations, links, and (where safe) editing.

**Architecture:** Foundation-first. One foundation workstream (A) builds the shared `GridPicker`, a `jumpToWorldScreen` link primitive, a `ScreenByteRef` chip, and the four new backend reverse-lookup/roster endpoints. The remaining workstreams (B–I) are independent and run in parallel via subagents, each consuming foundation primitives. Backend is FastAPI (`src/tmos_randomizer/api/server.py`) + per-domain core modules; frontend is React 19 + Zustand (`ui/src/`).

**Tech Stack:** Python 3.11 / FastAPI / pytest (backend); React 19 / TypeScript / Zustand / Tailwind v4 / Vite / Vitest (frontend); Playwright MCP for visual verification.

## Global Constraints

- **Backend dev venv:** `projects/TMOS_Randomizer_V2/.venv-win/Scripts/python.exe`. Run server with `.venv-win/Scripts/tmos-randomize.exe serve --port 8000`.
- **Backend tests:** `.venv-win/Scripts/python.exe -m pytest projects/TMOS_Randomizer_V2/tests/ -v`.
- **Frontend gate:** `npm run build` (in `ui/`) MUST pass, and `npx eslint <changed files>` MUST be clean. Do NOT gate on whole-tree `npm run lint` — the UI has 32 pre-existing ESLint errors unrelated to this work.
- **Frontend dev server:** `cd ui && npm run dev` → http://localhost:5173. Backend at http://localhost:8000.
- **Edit safety is a hard rule.** Only expose editing for fields confirmed safe by the exploration: encounter lineups/groups (never enemy IDs `0x0B`/`0x0C` — crash), enemy `ep`/`rupia`/`bribe`, hero HP/MP/damage tables, shop prices, trooper cost, tile-bank minitiles, and the world-screen `safe`/`caution`-tier fields. Allies stats/magics, the Cosmetic palette, and Level Caps are **READ-ONLY** (no ROM write target). Never wire an editor to them.
- **No fabricated graphics.** Use only ROM-derived images (enemy `image` filenames, `/api/rom/render/...`, `/api/rom/tilesection/...`). Do not introduce emoji or clip-art as primary item/enemy graphics.
- **Optimistic-update pattern:** follow the existing store actions (e.g. `updateEnemyStat`, `updateLineupSlot`) — optimistic set, await PATCH, reconcile from server response, rollback + set error on failure, `pushEditLog`.
- **Staging discipline:** concurrent Claude threads share this working tree. Commit explicit paths only, never `git add -A`, never create branches.

---

## File / Endpoint Structure (decomposition lock-in)

**New backend (Workstream A):**
- `src/tmos_randomizer/core/encounter_groups.py` — add `groups_for_screen(chapter, screen_index)` + `lineup_for_group(...)` helpers.
- `src/tmos_randomizer/core/enemy_appearances.py` — NEW: compute enemy→screens.
- `src/tmos_randomizer/core/allies.py` — NEW: static ally roster + location scan + trooper roster.
- `src/tmos_randomizer/api/server.py` — add 4 routes (see Task A1–A4).

**New shared frontend (Workstream A):**
- `ui/src/components/shared/GridPicker.tsx` — generic modal grid picker (extracted from `EnemyPicker`).
- `ui/src/components/shared/jumpLinks.ts` — `useJumpToWorldScreen()` hook + `ScreenByteRef` data helper.
- `ui/src/components/shared/ScreenByteRef.tsx` — clickable chip: shows hex + mini render + "open in World".
- `ui/src/api/client.ts` — add 4 client methods + types.
- `ui/src/store/index.ts` — add `jumpToWorldScreen(chapter, screenIndex)` action.

**Per-workstream frontend files:** listed in each workstream below.

---

# WORKSTREAM A — Foundation (do FIRST, alone)

This workstream must land and be committed before B–I start; everything else imports from it.

### Task A1: Backend — encounter-by-screen endpoint

**Files:**
- Modify: `src/tmos_randomizer/core/encounter_groups.py`
- Modify: `src/tmos_randomizer/api/server.py`
- Test: `tests/test_encounter_by_screen.py`

**Interfaces:**
- Produces: `GET /api/rom/encounter-groups/screen/{chapter}/{screen_index}` → `{ chapter, screen_index, groups: [{ entry_index, monster_group, flag, lineup_index, lineup: { lineup_index, start_byte, slots: [{slot, enemy_id, enemy_name, is_empty}], total_hp } }] }`. Empty `groups: []` when no encounter is mapped to that screen.

- [ ] **Step 1: Write the failing test**

```python
# tests/test_encounter_by_screen.py
from fastapi.testclient import TestClient
from tmos_randomizer.api.server import app, configure_asset_paths

def _client():
    configure_asset_paths()
    c = TestClient(app)
    c.post("/api/rom/load-default")  # adjust to the project's default-ROM load route
    return c

def test_encounter_by_screen_returns_lineup_for_known_group():
    c = _client()
    # Pull a real (chapter, screen) that has an encounter group from the groups table.
    groups = c.get("/api/rom/encounter-groups/1").json()["current"]
    screen = groups["entries"][0]["screen"]
    r = c.get(f"/api/rom/encounter-groups/screen/1/{screen}")
    assert r.status_code == 200
    body = r.json()
    assert body["screen_index"] == screen
    assert len(body["groups"]) >= 1
    g = body["groups"][0]
    assert "lineup" in g and "slots" in g["lineup"]
    assert g["lineup_index"] == (g["monster_group"] & 0x7F)

def test_encounter_by_screen_empty_for_unmapped_screen():
    c = _client()
    r = c.get("/api/rom/encounter-groups/screen/1/254")  # unlikely to be mapped
    assert r.status_code == 200
    assert r.json()["groups"] == []
```

- [ ] **Step 2: Run test to verify it fails**

Run: `.venv-win/Scripts/python.exe -m pytest tests/test_encounter_by_screen.py -v`
Expected: FAIL (route 404 / not found).

- [ ] **Step 3: Add core helper**

In `core/encounter_groups.py`, add a function that, given a chapter and screen index, returns the matching group entries, and resolves each entry's `monster_group` low-7-bits to the lineup record (reuse the existing lineup loader from `encounter_lineups.py`). Mirror the shapes already returned by `get_chapter_encounter_groups` and `get_chapter_encounter_lineups`.

- [ ] **Step 4: Add route in `server.py`**

Register `GET /api/rom/encounter-groups/screen/{chapter}/{screen_index}` that calls the helper and returns the documented shape. Place it next to the existing encounter-groups routes (~line 3375–3458).

- [ ] **Step 5: Run tests to verify they pass**

Run: `.venv-win/Scripts/python.exe -m pytest tests/test_encounter_by_screen.py -v`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/tmos_randomizer/core/encounter_groups.py src/tmos_randomizer/api/server.py tests/test_encounter_by_screen.py
git commit -m "feat(api): encounter-groups lookup by screen (random-encounter resolution)"
```

### Task A2: Backend — enemy appearances endpoint

**Files:**
- Create: `src/tmos_randomizer/core/enemy_appearances.py`
- Modify: `src/tmos_randomizer/api/server.py`
- Test: `tests/test_enemy_appearances.py`

**Interfaces:**
- Produces: `GET /api/rom/enemies/{enemy_id}/appearances` → `{ enemy_id, enemy_id_hex, appearances: [{ chapter, screen_index, screen_hex, lineup_index, flag }] }`. Computed: enemy_id → lineups containing it (per chapter) → encounter-group entries whose `monster_group & 0x7F` equals that lineup index → their `screen`.

- [ ] **Step 1: Write the failing test**

```python
# tests/test_enemy_appearances.py
from fastapi.testclient import TestClient
from tmos_randomizer.api.server import app, configure_asset_paths

def _client():
    configure_asset_paths(); c = TestClient(app); c.post("/api/rom/load-default"); return c

def test_enemy_appearances_shape_and_nonempty_for_common_enemy():
    c = _client()
    # 0x0D (Pandarm) is a Chapter-1 staple; expect >=1 appearance.
    r = c.get("/api/rom/enemies/13/appearances")  # 0x0D
    assert r.status_code == 200
    body = r.json()
    assert body["enemy_id"] == 13
    for a in body["appearances"]:
        assert {"chapter", "screen_index", "lineup_index"} <= a.keys()

def test_enemy_appearances_empty_for_unused_id():
    c = _client()
    r = c.get("/api/rom/enemies/255/appearances")
    assert r.status_code == 200
    assert r.json()["appearances"] == []
```

- [ ] **Step 2: Run to verify it fails** — `... -m pytest tests/test_enemy_appearances.py -v` → FAIL (404).
- [ ] **Step 3: Implement `enemy_appearances.py`** — iterate all chapters: load lineups, find lineups whose slots contain `enemy_id`; load groups, collect entries where `(monster_group & 0x7F) == lineup_index`; emit `{chapter, screen_index, screen_hex, lineup_index, flag}`. Dedupe.
- [ ] **Step 4: Add route** `GET /api/rom/enemies/{enemy_id}/appearances` near the enemies routes (~line 3052–3120).
- [ ] **Step 5: Run to verify pass.**
- [ ] **Step 6: Commit**

```bash
git add src/tmos_randomizer/core/enemy_appearances.py src/tmos_randomizer/api/server.py tests/test_enemy_appearances.py
git commit -m "feat(api): enemy appearances (which screens an enemy spawns on)"
```

### Task A3: Backend — allies + troopers roster endpoint (READ-ONLY)

**Files:**
- Create: `src/tmos_randomizer/core/allies.py`
- Modify: `src/tmos_randomizer/api/server.py`
- Test: `tests/test_allies.py`

**Interfaces:**
- Produces:
  - `GET /api/rom/allies` → `{ allies: [{ id, name, klass, chapter, content_byte, content_hex, sprite, description, spells: string[], locations: [{chapter, screen_index, screen_hex}] }] }`
  - `GET /api/rom/troopers` → `{ trooper_cost, sprite, locations: [{chapter, screen_index, screen_hex}] }` (cost is editable via the EXISTING `PATCH /api/rom/trooper-cost`; this is read-only aggregation).
- Ally static metadata is ported from the current hardcoded `ui/src/components/views/AlliesView.tsx` `KNOWN_ALLIES`. `locations` are computed by scanning every chapter's screens for `content` in the ally content-byte range (`ContentType.ALLY_*` from `core/enums.py`); troopers scan for `content == 0x7F`.

- [ ] **Step 1: Write failing test**

```python
# tests/test_allies.py
from fastapi.testclient import TestClient
from tmos_randomizer.api.server import app, configure_asset_paths

def _client():
    configure_asset_paths(); c = TestClient(app); c.post("/api/rom/load-default"); return c

def test_allies_roster_has_known_allies_with_locations_field():
    c = _client()
    r = c.get("/api/rom/allies")
    assert r.status_code == 200
    allies = r.json()["allies"]
    assert len(allies) >= 5
    a = allies[0]
    assert {"id","name","content_byte","locations","sprite"} <= a.keys()
    assert isinstance(a["locations"], list)

def test_troopers_endpoint_exposes_cost_and_locations():
    c = _client()
    r = c.get("/api/rom/troopers")
    assert r.status_code == 200
    body = r.json()
    assert "trooper_cost" in body and "locations" in body
```

- [ ] **Step 2: Run to verify fail.**
- [ ] **Step 3: Implement `allies.py`** — `ALLY_ROSTER` dict (port from `AlliesView.tsx`), `scan_ally_locations(chapter_loader)`, `get_allies()`, `get_troopers()`. Read trooper cost from `shop_economy.py`.
- [ ] **Step 4: Add both routes** to `server.py`.
- [ ] **Step 5: Run to verify pass.**
- [ ] **Step 6: Commit**

```bash
git add src/tmos_randomizer/core/allies.py src/tmos_randomizer/api/server.py tests/test_allies.py
git commit -m "feat(api): allies + troopers roster with computed screen locations (read-only)"
```

### Task A4: Frontend — client methods + types for A1–A3

**Files:**
- Modify: `ui/src/api/client.ts`

**Interfaces:**
- Produces: `api.getEncounterByScreen(chapter, screenIndex)`, `api.getEnemyAppearances(enemyId)`, `api.getAllies()`, `api.getTroopers()` and exported types `EncounterByScreen`, `EnemyAppearances`, `AlliesResponse`, `TroopersResponse` matching the JSON shapes in A1–A3.

- [ ] **Step 1: Add the 4 methods + types**, following the existing method style in `client.ts` (constructor `baseUrl`, `fetch` + `.json()`).
- [ ] **Step 2: Typecheck** — Run: `cd ui && npx tsc -b --noEmit`. Expected: no new errors.
- [ ] **Step 3: Commit**

```bash
git add ui/src/api/client.ts
git commit -m "feat(ui): API client methods for encounter-by-screen, enemy appearances, allies, troopers"
```

### Task A5: Frontend — generic `GridPicker` extracted from `EnemyPicker`

**Files:**
- Create: `ui/src/components/shared/GridPicker.tsx`
- Modify: `ui/src/components/enemies/EnemyPicker.tsx` (re-implement on top of `GridPicker`)
- Test: `ui/src/components/shared/GridPicker.test.tsx`

**Interfaces:**
- Produces:
```typescript
export interface GridPickerItem { id: number; label: string; hex?: string; sub?: string; imageUrl?: string; }
export interface GridPickerProps {
  items: GridPickerItem[];
  currentId: number;
  onPick: (id: number) => void;
  onClose: () => void;
  anchorRef: React.RefObject<HTMLElement | null>;
  allowEmpty?: boolean;           // shows the Ø option (emits emptyId)
  emptyId?: number;               // default 0xFF
  columns?: number;               // default 8
  title?: string;
  renderCell?: (item: GridPickerItem) => React.ReactNode; // optional custom cell
}
```
The portal/positioning/Esc/click-outside/filter ("N of M") behavior is moved verbatim from `EnemyPicker.tsx`. `EnemyPicker` becomes a thin wrapper mapping `BattleEnemy[]` → `GridPickerItem[]` (imageUrl from the enemy sprite path it already builds) so its existing callers (`LineupEditor`) keep working unchanged.

- [ ] **Step 1: Write failing test** (Vitest + Testing Library):

```tsx
// ui/src/components/shared/GridPicker.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { useRef } from 'react';
import { GridPicker } from './GridPicker';

function Harness({ onPick }: { onPick: (id: number) => void }) {
  const ref = useRef<HTMLButtonElement>(null);
  return (
    <>
      <button ref={ref}>anchor</button>
      <GridPicker
        items={[{ id: 1, label: 'Alpha', hex: '0x01' }, { id: 2, label: 'Beta', hex: '0x02' }]}
        currentId={1} onPick={onPick} onClose={() => {}} anchorRef={ref}
      />
    </>
  );
}

test('filters by label and emits id on pick', () => {
  const picks: number[] = [];
  render(<Harness onPick={(id) => picks.push(id)} />);
  fireEvent.change(screen.getByPlaceholderText(/filter/i), { target: { value: 'Beta' } });
  fireEvent.click(screen.getByText('Beta'));
  expect(picks).toEqual([2]);
});
```
> If `@testing-library/react` is not installed, install it as a devDependency first (`npm i -D @testing-library/react @testing-library/dom`); it is the standard companion to the existing Vitest setup.

- [ ] **Step 2: Run to verify fail** — `cd ui && npx vitest run src/components/shared/GridPicker.test.tsx` → FAIL.
- [ ] **Step 3: Implement `GridPicker.tsx`** by generalizing `EnemyPicker` (replace `BattleEnemy` with `GridPickerItem`, render `imageUrl` when present, else `hex`/`label`).
- [ ] **Step 4: Re-point `EnemyPicker.tsx`** to wrap `GridPicker`; keep its public props identical.
- [ ] **Step 5: Run to verify pass** + `cd ui && npm run build` passes.
- [ ] **Step 6: Commit**

```bash
git add ui/src/components/shared/GridPicker.tsx ui/src/components/shared/GridPicker.test.tsx ui/src/components/enemies/EnemyPicker.tsx
git commit -m "feat(ui): generic GridPicker (extracted from EnemyPicker) for reuse across selectors"
```

### Task A6: Frontend — `jumpToWorldScreen` action + `ScreenByteRef` chip

**Files:**
- Modify: `ui/src/store/index.ts` (add action)
- Create: `ui/src/components/shared/jumpLinks.ts`
- Create: `ui/src/components/shared/ScreenByteRef.tsx`

**Interfaces:**
- Produces:
  - Store action `jumpToWorldScreen: (chapter: number, screenIndex: number) => Promise<void>` — sets `selectedTab='world'`, ensures `selectedChapter===chapter` (calling `loadChapterData` if not), then `setSelectedScreen(screenIndex)`.
  - `jumpLinks.ts`: `useJumpToWorldScreen()` returning that action from the store.
  - `ScreenByteRef.tsx`:
```typescript
export function ScreenByteRef(props: {
  chapter: number; screenIndex: number;
  showRender?: boolean;   // default true: 64px mini ScreenRenderer thumbnail
  label?: string;         // default "0x{screenIndex} → World"
}): JSX.Element;
```
It renders the hex value, an optional `ScreenRenderer` thumbnail (reuse `ui/src/components/screen/ScreenRenderer.tsx`), and is a button calling `jumpToWorldScreen`.

- [ ] **Step 1: Add `jumpToWorldScreen`** to the store (action signature in the `RandomizerState` interface + implementation in the store object). Implementation:
```typescript
jumpToWorldScreen: async (chapter, screenIndex) => {
  const s = get();
  set({ selectedTab: 'world' });
  if (s.selectedChapter !== chapter || !s.chapterData) {
    await s.loadChapterData(chapter);
  }
  set({ selectedScreen: screenIndex });
},
```
- [ ] **Step 2: Create `jumpLinks.ts` and `ScreenByteRef.tsx`** per the interface.
- [ ] **Step 3: Build** — `cd ui && npm run build` passes; `npx eslint src/store/index.ts src/components/shared/jumpLinks.ts src/components/shared/ScreenByteRef.tsx` clean.
- [ ] **Step 4: Commit**

```bash
git add ui/src/store/index.ts ui/src/components/shared/jumpLinks.ts ui/src/components/shared/ScreenByteRef.tsx
git commit -m "feat(ui): jumpToWorldScreen action + ScreenByteRef chip (clickable screen links)"
```

### Task A7: Foundation smoke test (visual)

- [ ] Start backend + frontend; with Playwright MCP, hit each new endpoint via `curl` (200 + shape) and confirm the app still builds/loads with 0 console errors. Commit nothing (verification only). Report results, then hand off B–I to parallel subagents.

---

# PARALLEL WORKSTREAMS (B–I) — start only after A is committed

Each is independent. Each subagent: stage only its own listed files; gate on `npm run build` + scoped eslint (+ pytest if it touches backend); verify visually with Playwright (screenshot, 0 console errors) before claiming done.

### Workstream B — Enemies tab: compact rows, full monster info, appearances, encounter-map previews

**Files:** `ui/src/components/enemies/LineupEditor.tsx`, `ui/src/components/enemies/BattleRosterEditor.tsx`, `ui/src/components/enemies/EnemyPanel.tsx` (find exact name), `ui/src/components/enemies/EncounterGroupEditor.tsx`.

**Requirements:**
1. **WAY smaller rows.** Reduce LineupEditor slot size and the BattleRoster left-list row height substantially (tighter padding, smaller sprite, single-line). Keep changed-from-vanilla highlighting.
2. **Show ALL info we know about the selected monster** in the roster's right panel: every one of the 10 stat bytes (`ep, rupia, bribe, escape_trigger, action_prob, lineup_min, action_prob2, hp, atk, byte_9`) with the human labels/semantics from `field_metadata.py`, plus `name`, hex id, sprite, `confidence`, `chapter_first_seen`, `notes`. Editable ONLY for the safe/caution-tier bytes; render `hp` (byte 7) and `byte_9` read-only with an "unverified semantics" note.
3. **"Appears on screens"**: call `api.getEnemyAppearances(enemyId)`; render the result as a list of `ScreenByteRef` chips (foundation A6) that jump to the World tab on click.
4. **Per-Screen EncounterMap previews**: in `EncounterGroupEditor`, for each row's `screen`, add a small `ScreenRenderer` thumbnail + a `ScreenByteRef` "jump to World" link.

**Acceptance:** rows visibly smaller; selecting an enemy shows all 10 bytes + metadata; appearance chips navigate to the correct World screen; encounter-map rows show screen thumbnails and jump links. `npm run build` + scoped eslint clean; screenshot captured.

### Workstream C — World tab: Encounters section + "edit everything" hub

**Files:** `ui/src/components/screen/ScreenDetailPanel.tsx`, `ui/src/components/screen/ScreenEditorModal.tsx`, new `ui/src/components/screen/ScreenEncountersSection.tsx`.

**Requirements:**
1. **Split the detail panel** into two clearly separated sections: **"World Screen Properties"** (the existing 16 object-byte field table — unchanged) and a NEW **"Encounters"** section (component `ScreenEncountersSection`).
2. **Encounters section** calls `api.getEncounterByScreen(chapter, screenIndex)`. If `content === 0xFF`, headline it "Random Encounter". Show the resolved lineup: each slot as a small enemy sprite (reuse the enemy sprite rendering) with name + hex.
3. **Customization (2-way):** a dropdown to switch which lineup the screen's encounter group points at (`monster_group` low-7-bits) via `api.patchEncounterGroup` (store `updateEncounterGroup`), and per-slot enemy editing via the `GridPicker` (selectable enemies) → `updateLineupSlot`. Because these write the same store slices the Enemies→Encounters tab reads, edits here refresh that tab automatically — verify both directions.
4. **More world-screen editing from the World tab:** ensure the `caution`/`safe` fields editable in `ScreenEditorModal` are also reachable inline from the detail panel (at minimum: a prominent Edit affordance per section). Do NOT add editors for `danger`-tier fields beyond what the modal already gates.

**Acceptance:** on a `0xFF` screen the Encounters section shows the lineup with sprites; changing the lineup dropdown or a slot persists and is reflected in the Enemies→Encounters tab without reload; 0 console errors; screenshot.

### Workstream D — Items & Economy tab redesign

**Files:** `ui/src/components/views/ItemsView.tsx` (+ item card subcomponents).

**Requirements:**
1. Replace emoji/non-game icons. Render each weapon/item with ROM-derived graphics where available; where no sprite exists, show a clean typographic card (name + category + effect) — **no clip-art/emoji**.
2. Show all available info per item: `name, category, effect, max_count, ram_address, chapter` (gameplay items) and the battle-item metadata. Group sensibly (progression / consumable / equipment / battle).
3. **Customizability + links:** wire shop prices and trooper cost (already editable endpoints) into this tab where relevant; for any item referencing a world screen (e.g. chapter availability), show a `ScreenByteRef` link when a screen is known.
4. Use `GridPicker` for shop item-code selection (item_code → label) instead of a raw number box.

**Acceptance:** no emoji as primary graphics; price/cost edits persist; build + scoped eslint clean; screenshot.

### Workstream E — Hero tab: HP-per-level picker, uncollapse + explain expert tables

**Files:** `ui/src/components/advanced/MpTablePanel.tsx`, new `ui/src/components/advanced/HpTablePanel.tsx`, `ui/src/components/views/HeroView.tsx`, `ui/src/components/advanced/LevelCapsPanel.tsx`, `ui/src/components/advanced/EncounterRatesPanel.tsx` (Enemies tab), `ui/src/components/advanced/TbFormulasPanel.tsx` (Enemies tab).

**Requirements:**
1. **HP-per-level grid** mirroring `MpTablePanel` exactly (same layout, vanilla diff, ByteField), backed by `playerStats.current.hp[25]` and `updatePlayerHp`. Add it beside/under the MP grid.
2. **Encounter Rates** and **Turn-Based Combat Formulas**: render expanded by default (not collapsed). Add a short plain-language explanation per table using the semantics from `encounter_rates.py` / the exploration (RAMP = EXP-driven pressure escalation w/ protected loop markers; CURVE = index→probability 0=never…255=always; TB formula grids: [6,6]/[30,2 base·mult]/[5 per-chapter]). Keep the existing "Expert" warning badge.
3. **Level Caps**: enrich the display (per-chapter cap, source, why it's read-only). Keep read-only.

**Acceptance:** HP grid edits persist and update the preview; expert panels are open by default with readable explanations + warnings; build + scoped eslint clean; screenshot.

### Workstream F — Allies tab: enrich + link (READ-ONLY stats)

**Files:** `ui/src/components/views/AlliesView.tsx`, new `ui/src/store` ally loader (add `loadAllies`/`loadTroopers` actions + state), `ui/src/api/client.ts` (already added in A4).

**Requirements:**
1. Replace the hardcoded list with data from `api.getAllies()` / `api.getTroopers()`.
2. Per ally: sprite, name, class, chapter, content byte, description, spells, and **`ScreenByteRef` link(s)** to the screen(s) where found (`locations`).
3. **Troopers selectable**: show trooper sprite + the editable recruitment **cost** (existing `PATCH /api/rom/trooper-cost`) and their found-screens. 
4. **Do NOT** add editors for ally HP/MP/magics — render any such info read-only with a short "not safely editable" note (the ROM table isn't located).

**Acceptance:** allies load from API with working screen links; trooper cost edit persists; no stat-editing controls on allies; build + scoped eslint clean; screenshot.

### Workstream G — Graphics tab: Tile Bank re-render correctness + Cosmetic enrichment

**Files:** `ui/src/components/tilebank/TileBankView.tsx`, `ui/src/components/tilebank/TileBankGrid.tsx`, `ui/src/components/advanced/PalettePanel.tsx`.

**Requirements:**
1. **Tile re-render:** verify (and fix if needed) that `TileBankGrid` tile images re-fetch when `selectedChapter` OR the `dataPointer`/CHR selection changes — include `chr`/`dataPointer` in the tile preview URL/query and in the effect deps so stale tiles never show.
2. **Cosmetic (Palette):** enrich the display — show swatches grouped by purpose, RAM address, color index, and a clear "read-only (PPU shadow RAM, no ROM write target)" note. Keep read-only.

**Acceptance:** switching chapter/datapointer visibly updates tiles; palette panel shows enriched read-only info; build + scoped eslint clean; before/after screenshots of the tile grid across two datapointers.

### Workstream H — Remove Boss Bytes tab; consolidate + compact Bosses

**Files:** `ui/src/components/views/EnemiesView.tsx`, `ui/src/components/enemies/BossSafeSection.tsx`, `ui/src/components/advanced/BossesPanel.tsx`, `ui/src/store/index.ts` (`EnemiesSection` type).

**Requirements:**
1. Remove the `bossbytes` sub-tab from `EnemiesView` and from the `EnemiesSection` union; ensure no router/links reference it.
2. Fold expert boss fields into the **Bosses** sub-tab via a single `BossesPanel` rendering with a "Show advanced/expert fields" toggle (one `getBossStats()` fetch, not two). Retire `BossSafeSection` or repurpose it as the toggle's "safe" view.
3. Make boss rows **a lot more compact** and make the **Edit affordance prominent**.

**Acceptance:** only one Bosses surface; advanced fields reachable via toggle; compact layout; no dangling `bossbytes` references (grep clean); build + scoped eslint clean; screenshot.

### Workstream I — Cross-UI: replace raw byte inputs with selector modules + screen links

**Files:** sweep across views; primary targets are any remaining raw enemy/lineup/screen-pointer number inputs not already covered by B/C, plus `ui/src/components/screen/ObjectSetField.tsx` and `ui/src/components/screen/EnumSelectField.tsx`.

**Requirements:**
1. Wherever a control selects an **enemy**, use `GridPicker` (with sprites) instead of a number box.
2. Wherever a field **references a world screen** (nav pointers, encounter-group `screen`, exit targets), render a `ScreenByteRef` chip (hex grid value + jump link). For editable screen pointers, offer a lightweight "world-screen picker" (a `GridPicker` whose items are the current chapter's screens with mini renders) to set the target.
3. Keep `danger`-tier fields gated exactly as today — this workstream changes the *input affordance*, not the safety policy.

**Acceptance:** representative byte inputs replaced with graphical selectors; screen references are clickable; nothing newly editable that was `danger`-tier; build + scoped eslint clean; screenshots of two converted controls.

---

## Self-Review

**Spec coverage (from the user's message):**
- Compact enemy rows → **B**. Show all monster info → **B**. Appears-on-screens with World links → **A2 + B**. EncounterMap screen preview + jump → **B**.
- World-tab Encounters section separate from Properties, 0xFF lookup + lineup, slot dropdown, 2-way editing → **A1 + C**. World tab as primary edit hub → **C**.
- Encounter Rates uncollapsed + explained, keep Expert warning → **E**. TB Combat Formulas same → **E**. "More than a grid of bytes" → **E** (explanations) + **I** (selectors).
- Selector modules with graphics instead of byte inputs everywhere → **A5 + I**. Screen-byte references show grid + World link; world-screen picker → **A6 + I**.
- Items tab redesign: graphics, info, customizability, links, no non-game graphics → **D**.
- HP equivalent to Max-MP-per-level grid → **E** (data confirmed to exist).
- Level Caps "show whatever data possible" → **E** (read-only enrich).
- Allies: more stats, customizable-if-safe, world-screen link, swap magics if safe, troopers selectable w/ info + editable cost/stats-if-safe, found-screens → **A3 + F** (stats/magics read-only per confirmed constraint; cost editable; locations linked).
- Tile Bank tiles update on chapter/datapointer change → **G**. Cosmetic revamp (customizable if possible) → **G** (read-only enrich; palette not safely writable).
- Remove Boss Bytes (redundant), compact + prominent Edit → **H**.

**Documented scope cuts (confirmed with user, "enrich + read-only"):** ally stats/magics editing, Cosmetic palette editing, Level Caps editing — all not safely writable; exposed as enriched read-only with explanatory notes.

**Type consistency:** `GridPickerItem`/`GridPickerProps` (A5) used by B/C/D/I; `ScreenByteRef` props (A6) used by B/C/D/F/I; `jumpToWorldScreen(chapter, screenIndex)` (A6) is the single navigation primitive; new client methods/types (A4) consumed by B/C/F. Endpoint shapes in A1–A3 match the client types in A4.

**Placeholder scan:** none — every task names exact files, endpoints, and acceptance gates.

---

## Execution Handoff

After A1–A7 land and are committed, B–I run in parallel (one subagent each), reviewed between tasks.
