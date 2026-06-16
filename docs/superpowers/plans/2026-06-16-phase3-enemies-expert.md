# Phase 3 — Enemies Tab + Gated Expert Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Enemies tab the entity-centric home for safe enemy/boss/encounter editing (roster stats editable), and gate the Expert tab's danger byte-tables behind an explicit unlock — with crash enemy IDs unselectable everywhere from a single source.

**Architecture:** Extend the existing field-metadata pipeline with an `enemy` entity + a canonical selectable-enemy-IDs source (backend). On the frontend, rework `EnemiesView` into a 4-section segmented view (Roster / Encounters / Bosses / Overworld), make roster stats editable with Phase-1 guided components, hard-filter every enemy dropdown through one shared helper, and add a session unlock gate to the Expert tab. No panel appears in two tabs.

**Tech Stack:** Python 3 / FastAPI (backend), React 19 + TypeScript + Zustand 5 + Vite + Tailwind 4 (frontend). Backend tests: pytest. FE tests: vitest. TS check: `npx tsc -b` from `ui/`.

**Git hygiene (every task):** stage ONLY the files named in that task. NEVER `git add -A` / `git add .`. NEVER create or switch branches — we are already on `feat/phase3-enemies-expert`. Untracked files in the tree (`.worktrees/`, `reports/`, stray PNGs) are unrelated — do not touch or stage them.

**Working dirs:**
- Backend: `projects/TMOS_Randomizer_V2/src/tmos_randomizer/`
- Frontend: `projects/TMOS_Randomizer_V2/ui/`
- Run backend tests: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/ -q`
- Run FE type check: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b`
- Run FE unit tests: `cd projects/TMOS_Randomizer_V2/ui && npx vitest run`

---

## File Structure

**Backend (modify/create):**
- Modify: `src/tmos_randomizer/core/field_metadata.py` — add `_enemy_fields()` + `enemy` entity.
- Create: `src/tmos_randomizer/core/enemy_selection.py` — canonical selectable-enemy-IDs helper.
- Modify: `src/tmos_randomizer/api/server.py` — add `GET /api/rom/enemies/selectable`.
- Modify: `src/tmos_randomizer/data/field_metadata.json` — regenerated artifact (via generator CLI).
- Test: `tests/test_field_metadata*.py` (existing) + new `tests/test_enemy_selection.py`.

**Frontend (modify/create):**
- Modify: `ui/src/api/client.ts` — `SelectableEnemy` type + `getSelectableEnemies()`; widen `EnemyStat`/patch if needed.
- Create: `ui/src/utils/enemySelection.ts` (+ `.test.ts`) — filter helper.
- Modify: `ui/src/store/index.ts` — `selectableEnemies` + loader; `expertUnlocked` flag + `unlockExpert()`.
- Create: `ui/src/components/enemies/BattleRosterEditor.tsx` — list + persistent edit panel.
- Modify: `ui/src/components/views/EnemiesView.tsx` — segmented 4-section layout.
- Modify: `ui/src/components/enemies/LineupEditor.tsx` (+ EncounterGroupEditor) — dropdowns use shared filter.
- Create: `ui/src/components/enemies/BossSafeSection.tsx`, `OverworldSafeSection.tsx` — safe-field subsets.
- Modify: `ui/src/components/views/ExpertView.tsx` (or `AdvancedView.tsx`) — unlock gate; drop safe-only boss/overworld duplication.

> Note: exact existing component filenames (e.g. whether `LineupEditor`/`EnemyRoster` live in `components/enemies/` vs inline in `EnemiesView.tsx`) must be confirmed by the implementer with a quick grep before editing; the plan names the responsibility, not a guessed path.

---

## Task 1: Backend — `enemy` entity in field metadata

**Files:**
- Modify: `src/tmos_randomizer/core/field_metadata.py`
- Test: `projects/TMOS_Randomizer_V2/tests/` (add/extend a field-metadata test)

- [ ] **Step 1: Confirm current structure.** Read `core/field_metadata.py` to see `build_field_metadata()` and the worldscreen `_..._fields()` helper + `_enum_options()`. Match its exact dict shape (`label, byte, tier, description, control?, enum?, valid_range?, warning?, used_by?`).

- [ ] **Step 2: Write failing test.** In a new/existing test file, assert:
```python
from tmos_randomizer.core.field_metadata import build_field_metadata

def test_metadata_includes_enemy_entity():
    meta = build_field_metadata()
    enemy = meta["entities"]["enemy"]
    assert enemy["label"]
    for key in ("hp", "ep", "rupia"):
        f = enemy["fields"][key]
        assert f["tier"] == "safe"
        assert f["control"] == "number"
        assert len(f["valid_range"]) == 2
        assert f["description"]
```
Run: `python -m pytest tests/ -k enemy_entity -q` → expect FAIL (KeyError 'enemy').

- [ ] **Step 3: Implement `_enemy_fields()`** returning hp/ep/rupia as safe number fields with `valid_range` `[0, 255]` and concise descriptions (HP = "Hit points in turn-based battle"; EP = "Experience awarded on defeat"; Rupia = "Currency dropped on defeat"). Add caution-tier read-only entries for the undocumented combat bytes if cheap; otherwise skip (YAGNI). Add `enemy` to the `entities` dict in `build_field_metadata()` with `label: "Battle Enemy"`. Include a field `warning` on relevant entries noting crash IDs 0x0B/0x0C are never selectable.

- [ ] **Step 4: Run test** → expect PASS. Run full suite `python -m pytest tests/ -q` → all green (fix the staleness test in Task 2 if it now fails on stale artifact — that's expected and handled next).

- [ ] **Step 5: Commit.**
```bash
git add src/tmos_randomizer/core/field_metadata.py tests/<the_test_file>.py
git commit -m "feat(v2): add enemy entity to field-metadata pipeline"
```

## Task 2: Backend — regenerate baked metadata artifact

**Files:**
- Modify: `src/tmos_randomizer/data/field_metadata.json`

- [ ] **Step 1:** Find the generator CLI (per project memory: `tools/generate_field_metadata.py`). Confirm its invocation by reading it.
- [ ] **Step 2:** Run the generator to rewrite `data/field_metadata.json` so it now contains the `enemy` entity.
- [ ] **Step 3:** Run the staleness test (the one that compares live `build_field_metadata()` to the baked JSON) → expect PASS now. Run full suite → green.
- [ ] **Step 4: Commit.**
```bash
git add src/tmos_randomizer/data/field_metadata.json
git commit -m "chore(v2): regenerate baked field_metadata.json with enemy entity"
```

## Task 3: Backend — canonical selectable-enemy-IDs source

**Files:**
- Create: `src/tmos_randomizer/core/enemy_selection.py`
- Modify: `src/tmos_randomizer/api/server.py`
- Test: `tests/test_enemy_selection.py`

- [ ] **Step 1: Write failing test** `tests/test_enemy_selection.py`:
```python
from tmos_randomizer.core.enemy_selection import selectable_enemy_ids
from tmos_randomizer.core.enums import CONSERVATIVE_DANGER_ENEMY_IDS

def test_selectable_excludes_all_danger_ids():
    ids = {e["enemy_id"] for e in selectable_enemy_ids()}
    assert ids.isdisjoint(CONSERVATIVE_DANGER_ENEMY_IDS)
    assert ids  # non-empty
    # every entry has a name
    assert all(e.get("name") for e in selectable_enemy_ids())
```
Run → FAIL (module missing).

- [ ] **Step 2: Implement** `enemy_selection.py` with `selectable_enemy_ids() -> list[dict]` that reads the turn-based roster (reuse `core/enemies.py` roster source) and returns `[{"enemy_id": int, "enemy_id_hex": str, "name": str}, ...]` for every roster ID **not** in `CONSERVATIVE_DANGER_ENEMY_IDS`.

- [ ] **Step 3: Run test** → PASS.

- [ ] **Step 4: Add endpoint** in `server.py`: `GET /api/rom/enemies/selectable` returning `{"enemies": selectable_enemy_ids()}`. Place it near the other enemy endpoints; follow the existing handler style.

- [ ] **Step 5:** Quick smoke: start nothing — just assert import + a FastAPI route test if the suite has a TestClient pattern; otherwise rely on the unit test. Run full suite → green.

- [ ] **Step 6: Commit.**
```bash
git add src/tmos_randomizer/core/enemy_selection.py src/tmos_randomizer/api/server.py tests/test_enemy_selection.py
git commit -m "feat(v2): canonical selectable-enemy-IDs source + endpoint (excludes crash/danger IDs)"
```

## Task 4: Frontend — client + store wiring for selectable enemies & expert gate

**Files:**
- Modify: `ui/src/api/client.ts`
- Modify: `ui/src/store/index.ts`

- [ ] **Step 1:** In `client.ts` add:
```ts
export interface SelectableEnemy { enemy_id: number; enemy_id_hex: string; name: string; }
```
and method `async getSelectableEnemies(): Promise<{ enemies: SelectableEnemy[] }>` using the existing `this.fetch<T>` pattern → `GET /api/rom/enemies/selectable`.

- [ ] **Step 2:** In `store/index.ts` add state `selectableEnemies: SelectableEnemy[]` (default `[]`) + `loadSelectableEnemies()` (call on API-connect success alongside the existing loaders), and `expertUnlocked: boolean` (default `false`) + `unlockExpert: () => void`.

- [ ] **Step 3: Verify types** `cd ui && npx tsc -b` → 0 errors.

- [ ] **Step 4: Commit.**
```bash
git add ui/src/api/client.ts ui/src/store/index.ts
git commit -m "feat(v2/ui): wire selectable-enemies client + store, add expertUnlocked flag"
```

## Task 5: Frontend — shared dropdown filter helper

**Files:**
- Create: `ui/src/utils/enemySelection.ts`
- Test: `ui/src/utils/enemySelection.test.ts`

- [ ] **Step 1: Write failing vitest** `enemySelection.test.ts`:
```ts
import { describe, it, expect } from 'vitest';
import { toEnemyOptions } from './enemySelection';

describe('toEnemyOptions', () => {
  it('maps selectable enemies to {value,label} options', () => {
    const opts = toEnemyOptions([{ enemy_id: 0x0d, enemy_id_hex: '0x0D', name: 'Pandarm' }]);
    expect(opts[0]).toEqual({ value: 0x0d, label: expect.stringContaining('Pandarm') });
  });
  it('returns empty for empty input', () => {
    expect(toEnemyOptions([])).toEqual([]);
  });
});
```
Run: `npx vitest run enemySelection` → FAIL.

- [ ] **Step 2: Implement** `enemySelection.ts`:
```ts
import type { SelectableEnemy } from '../api/client';
export interface EnemyOption { value: number; label: string; }
export function toEnemyOptions(enemies: SelectableEnemy[]): EnemyOption[] {
  return enemies.map((e) => ({ value: e.enemy_id, label: `${e.enemy_id_hex} · ${e.name}` }));
}
```
(The backend source already excludes crash/danger IDs; this helper is the single FE place dropdowns get their options.)

- [ ] **Step 3: Run test** → PASS. `npx tsc -b` → 0 errors.

- [ ] **Step 4: Commit.**
```bash
git add ui/src/utils/enemySelection.ts ui/src/utils/enemySelection.test.ts
git commit -m "feat(v2/ui): shared enemy-option helper for crash-safe dropdowns"
```

## Task 6: Frontend — Battle Roster entity-centric editor (editable stats)

**Files:**
- Create: `ui/src/components/enemies/BattleRosterEditor.tsx`
- Modify: `ui/src/api/client.ts` (only if a `patchEnemyStat` method is missing — confirm first)

- [ ] **Step 1: Confirm** `client.ts` already has `patchEnemyStat(enemyId, patch)` (it does per exploration). If present, no client change.
- [ ] **Step 2: Build `BattleRosterEditor`** — left: scrollable enemy list (from store `battleEnemies`), selecting one sets local selected id. Right: persistent panel showing image/name/confidence/first-seen + **editable** HP/EP/Rupia using `GuidedNumberField` wrapped in `GuidedField` with metadata from `fieldMetadata.entities.enemy` and vanilla values from the enemy's vanilla stat. On change → optimistic update → `api.patchEnemyStat(id, patch)` → reconcile (mirror the World-tab edit pattern). Show a computed **"Appears in"** list by scanning loaded `encounterLineups` for the selected enemy id. Crash/danger IDs render as a read-only flagged row (badge: danger) — not editable.
- [ ] **Step 3: Verify** `npx tsc -b` → 0 errors.
- [ ] **Step 4: Commit.**
```bash
git add ui/src/components/enemies/BattleRosterEditor.tsx
git commit -m "feat(v2/ui): entity-centric Battle Roster editor with editable HP/EP/Rupia"
```

## Task 7: Frontend — EnemiesView 4-section segmented layout + dropdown hardening

**Files:**
- Modify: `ui/src/components/views/EnemiesView.tsx`
- Modify: existing lineup/group editor component(s) (confirm paths first)

- [ ] **Step 1:** Add a segmented control to `EnemiesView` with sections: **Roster** (renders `BattleRosterEditor`), **Encounters** (existing lineups + groups), **Bosses** (Task 8 component), **Overworld** (Task 8 component). Default to Roster.
- [ ] **Step 2:** Replace any hardcoded/full-roster enemy `<select>` option sources in the lineup/group editors with `toEnemyOptions(selectableEnemies)` from the store, so crash/danger IDs cannot be chosen. Keep the existing "empty slot" option (0x00/0xFF) handling.
- [ ] **Step 3: Verify** `npx tsc -b` → 0; `npx vitest run` → green.
- [ ] **Step 4: Commit.**
```bash
git add ui/src/components/views/EnemiesView.tsx ui/src/components/enemies/<lineup/group files>
git commit -m "feat(v2/ui): segmented Enemies tab + crash-safe encounter dropdowns"
```

## Task 8: Frontend — Bosses (safe) + Overworld (safe) sections in Enemies

**Files:**
- Create: `ui/src/components/enemies/BossSafeSection.tsx`
- Create: `ui/src/components/enemies/OverworldSafeSection.tsx`

- [ ] **Step 1:** `BossSafeSection` — load `api.getBossStats()`; render only **safe-tier** boss fields (filter `field.tier === 'safe'`) as editable (`patchBossStat`), with vanilla diff. For bosses that have expert-tier fields, render a single inline note: "Advanced boss bytes are in the Expert tab." Reuse `useRomResource`/`PanelFrame`.
- [ ] **Step 2:** `OverworldSafeSection` — load `api.getOverworldEnemyStats()`; render editable per-chapter HP (`patchOverworldEnemyHp`); derived fields read-only. Reuse `useRomResource`/`PanelFrame`.
- [ ] **Step 3: Verify** `npx tsc -b` → 0 errors.
- [ ] **Step 4: Commit.**
```bash
git add ui/src/components/enemies/BossSafeSection.tsx ui/src/components/enemies/OverworldSafeSection.tsx
git commit -m "feat(v2/ui): safe Boss + Overworld editing sections in Enemies tab"
```

## Task 9: Frontend — Expert tab gate + de-duplicate panels

**Files:**
- Modify: `ui/src/components/views/ExpertView.tsx` and/or `AdvancedView.tsx`

- [ ] **Step 1:** In `ExpertView`, if `!expertUnlocked` (from store), render a warning screen: explains risk + an **"I understand this can crash the game"** button calling `unlockExpert()`. When unlocked, render `AdvancedView` (danger panels) as today.
- [ ] **Step 2:** Remove redundancy: in `AdvancedView`'s sub-tab list, **drop the "Enemies & Encounters" sub-tab** (now fully owned by the Enemies tab) and the **safe-only** boss/overworld duplication. Keep `TbFormulasPanel`, `WeaponDamagePanel`, `EncounterRatesPanel`, expert-tier boss controls, Debug, and any not-yet-migrated non-enemy panels. Each remaining panel must exist in exactly one tab.
- [ ] **Step 3: Verify** `npx tsc -b` → 0; `npx vitest run` → green.
- [ ] **Step 4: Commit.**
```bash
git add ui/src/components/views/ExpertView.tsx ui/src/components/views/AdvancedView.tsx
git commit -m "feat(v2/ui): gate Expert tab behind explicit unlock; de-duplicate enemy panels"
```

## Task 10: Live verification (controller-run, not a subagent)

- [ ] Start backend: `cd projects/TMOS_Randomizer_V2 && python -m uvicorn tmos_randomizer.api.server:app --port 8023` (background).
- [ ] Start FE: `cd projects/TMOS_Randomizer_V2/ui && npm run dev -- --port 5191` (background).
- [ ] Via Playwright: (a) Enemies→Roster: edit an HP value, confirm it persists + shows "changed" vs vanilla; (b) Enemies→Encounters: open a lineup dropdown, confirm `0x0B/0x0C/0x0F/0x17/0x25` are absent; (c) Bosses/Overworld sections render + a safe field edits; (d) Expert tab shows the gate, unlock reveals panels; (e) confirm no panel appears in both Enemies and Expert.
- [ ] Stop servers and clean up screenshots/`.playwright-mcp/`.

## Final: holistic review + finish

- [ ] Dispatch a final code-reviewer over the whole branch diff (`git diff master...HEAD`).
- [ ] Run full backend suite + FE `tsc -b` + vitest one more time on the branch.
- [ ] Use superpowers:finishing-a-development-branch to merge to master (Option 1) per established workflow.
