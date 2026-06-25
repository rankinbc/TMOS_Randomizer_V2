# Expert Tab Dissolution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retire the `⚠ Expert` tab; re-home its advanced panels into the Hero / Enemies / Items / Graphics tabs via per-tab segmented sub-tab bars, drop the unlock wall in favor of inline amber warning tags, and repoint the World-screen shop/palette cross-links.

**Architecture:** Pure frontend IA refactor. A new shared `SubTabBar` component renders each tab's segmented sub-tab bar (with an optional amber "expert" tag per tab). The eight advanced panel components are reused **unchanged** — only where they mount and how they are reached changes. `ExpertView` and `AdvancedView` are deleted; the `expert` `TabType` member and the `expertUnlocked`/`unlockExpert` store machinery are removed. Narrowing `TabType` is the safety net: `tsc` flags every dangling reference.

**Tech Stack:** React 19 + TypeScript (strict) + Tailwind v4 + zustand; Vitest for pure-util unit tests; ESLint. All frontend commands run from `projects/TMOS_Randomizer_V2/ui`.

## Global Constraints

- **No panel rewrites.** Reuse `MpTablePanel`, `WeaponDamagePanel`, `LevelCapsPanel`, `BossesPanel`, `EncounterRatesPanel`, `TbFormulasPanel`, `EconomyPanel`, `PalettePanel` exactly as `AdvancedView.tsx` mounts them today (same props). Do not edit their internals.
- **No backend changes.** Frontend-only.
- **No editable field appears in two tabs** in the END state. `BossesPanel` under Enemies keeps `tierFilter={(tier) => tier !== 'safe'}` so safe boss fields (already in the existing Enemies → Bosses section) never duplicate. Temporary duplication mid-plan (before Expert is deleted in Task 6) is acceptable.
- **Each task must end with `npm run build` (tsc -b) passing clean** — this is the primary gate. Mid-plan the build stays green; `TabType` is narrowed only in the final task, after all consumers are migrated.
- **LINT GATE — read carefully.** The repo baseline has **32 pre-existing ESLint errors** in files unrelated to this work (e.g. `panelHelpers.tsx`, `Tooltip.tsx`, `ConsequencePreview.tsx`, `MapView.tsx`, `LineupEditor.tsx`, `EnemyPicker.tsx`). Do **NOT** use whole-tree `npm run lint` (`eslint .`) as a task gate — it fails on that pre-existing debt and is not yours to fix. Instead lint **only the files this task created or modified**: `npx eslint <file1> <file2> …` and require **0 errors** on those files. (`EnemiesView.tsx` carries a pre-existing exhaustive-deps *warning* on its mount effect; warnings don't fail the gate — only errors do. Don't "fix" pre-existing warnings outside your task's lines.)
- **Danger marker = inline only.** Danger sub-tabs get the amber "expert" tag on their `SubTabBar` button (the same markup `AdvancedView`'s `t.expert` buttons render today: `text-[10px] uppercase tracking-wide text-amber-400/80`, label `expert`). No full-page gate anywhere.
- **Shared working tree.** Commit explicit paths only — never `git add -A`.
- **Verification convention (matches Specs #1–#3):** `.tsx` view wiring is verified by `tsc` + `eslint` + a manual checklist (no React testing-library in this repo). Pure `.ts` utils get Vitest tests. Only `screenLinks.test.ts` changes here.

**Sub-tab section id vocabulary (use these exact string literals):**
- Hero (`HeroSection`): `'progression' | 'magic' | 'weapons' | 'caps'`
- Enemies (`EnemiesSection`, extended): `'roster' | 'encounters' | 'bosses' | 'overworld' | 'bossbytes' | 'encrates' | 'tbformulas'`
- Items (`ItemsSection`): `'items' | 'economy'`
- Graphics (`GraphicsSection`): `'tiles' | 'cosmetic'`

---

### Task 1: Shared `SubTabBar` + three new Enemies danger sub-tabs

Adds the reusable segmented bar and uses it first in Enemies, where it also adds the Boss Bytes / Encounter Rates / TB Formulas sub-tabs. (Enemies already has a store-backed section, so its three new tabs extend that union.)

**Files:**
- Create: `projects/TMOS_Randomizer_V2/ui/src/components/common/SubTabBar.tsx`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/store/index.ts:32` (extend `EnemiesSection`)
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/views/EnemiesView.tsx`

**Interfaces:**
- Produces: `SubTabBar<T extends string>(props: { tabs: SubTab<T>[]; active: T; onSelect: (id: T) => void })` and `interface SubTab<T extends string> { id: T; label: string; expert?: boolean }` — exported from `common/SubTabBar.tsx`. Consumed by Tasks 2, 3, 4.
- Produces: `EnemiesSection` now includes `'bossbytes' | 'encrates' | 'tbformulas'`.

- [ ] **Step 1: Create the shared `SubTabBar` component**

Create `projects/TMOS_Randomizer_V2/ui/src/components/common/SubTabBar.tsx` with exactly this content (markup copied from `EnemiesView`'s existing bar + `AdvancedView`'s amber expert tag):

```tsx
export interface SubTab<T extends string> {
  id: T;
  label: string;
  expert?: boolean;
}

interface SubTabBarProps<T extends string> {
  tabs: SubTab<T>[];
  active: T;
  onSelect: (id: T) => void;
}

/**
 * Segmented sub-tab bar shared by the entity tabs (Hero / Enemies / Items /
 * Graphics). A tab flagged `expert` renders an inline amber "expert" tag — the
 * danger marker that replaced the old full-page Expert gate.
 */
export function SubTabBar<T extends string>({ tabs, active, onSelect }: SubTabBarProps<T>) {
  return (
    <div className="flex-shrink-0 bg-slate-800/60 border-b border-slate-700 overflow-x-auto">
      <div className="flex">
        {tabs.map((t) => (
          <button
            key={t.id}
            type="button"
            onClick={() => onSelect(t.id)}
            className={`whitespace-nowrap px-4 py-2.5 text-sm font-medium border-b-2 transition-colors ${
              active === t.id
                ? 'text-blue-400 border-blue-400 bg-slate-700/40'
                : 'text-slate-400 border-transparent hover:text-slate-200 hover:bg-slate-700/20'
            }`}
          >
            {t.label}
            {t.expert && (
              <span className="ml-1.5 align-middle text-[10px] uppercase tracking-wide text-amber-400/80">
                expert
              </span>
            )}
          </button>
        ))}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Extend the `EnemiesSection` union in the store**

In `projects/TMOS_Randomizer_V2/ui/src/store/index.ts`, change line 32 from:

```ts
export type EnemiesSection = 'roster' | 'encounters' | 'bosses' | 'overworld';
```

to:

```ts
export type EnemiesSection =
  | 'roster'
  | 'encounters'
  | 'bosses'
  | 'overworld'
  | 'bossbytes'
  | 'encrates'
  | 'tbformulas';
```

- [ ] **Step 3: Wire the three advanced panels + shared bar into `EnemiesView`**

In `projects/TMOS_Randomizer_V2/ui/src/components/views/EnemiesView.tsx`:

(a) Add imports near the other imports (after line 9):

```tsx
import { SubTabBar, type SubTab } from '../common/SubTabBar';
import { BossesPanel } from '../advanced/BossesPanel';
import { EncounterRatesPanel } from '../advanced/EncounterRatesPanel';
import { TbFormulasPanel } from '../advanced/TbFormulasPanel';
```

(b) Replace the `SECTIONS` array (lines 11–16) with a typed `SubTab` list that adds the three danger tabs:

```tsx
const SECTIONS: SubTab<EnemiesSection>[] = [
  { id: 'roster', label: 'Roster' },
  { id: 'encounters', label: 'Encounters' },
  { id: 'bosses', label: 'Bosses' },
  { id: 'overworld', label: 'Overworld' },
  { id: 'bossbytes', label: 'Boss Bytes', expert: true },
  { id: 'encrates', label: 'Encounter Rates', expert: true },
  { id: 'tbformulas', label: 'TB Formulas', expert: true },
];
```

(c) Replace the inline segmented-control markup (lines 94–112, the `<div className="flex-shrink-0 bg-slate-800/60 ...">` block) with the shared component:

```tsx
      <SubTabBar tabs={SECTIONS} active={section} onSelect={setSection} />
```

(d) Add the three new section bodies immediately after the existing `overworld` block (after line 248, before the closing `</div>` of the root). The `BossesPanel` props are copied verbatim from `AdvancedView.tsx:91-99`:

```tsx
      {/* ---- BOSS BYTES (advanced, non-safe tiers only) ---- */}
      {section === 'bossbytes' && (
        <div className="flex-1 overflow-auto">
          <BossesPanel
            tierFilter={(tier) => tier !== 'safe'}
            title="Boss Bytes (Advanced)"
            romNote="Advanced boss bytes — expert/display tiers only · safe HP & damage live in the Bosses section"
            headerTier="expert"
          />
        </div>
      )}

      {/* ---- ENCOUNTER RATES (advanced) ---- */}
      {section === 'encrates' && (
        <div className="flex-1 overflow-auto">
          <EncounterRatesPanel />
        </div>
      )}

      {/* ---- TB COMBAT FORMULAS (advanced) ---- */}
      {section === 'tbformulas' && (
        <div className="flex-1 overflow-auto">
          <TbFormulasPanel />
        </div>
      )}
```

- [ ] **Step 4: Typecheck + scoped lint**

Run (from `projects/TMOS_Randomizer_V2/ui`):

```bash
npm run build
npx eslint src/components/common/SubTabBar.tsx src/store/index.ts src/components/views/EnemiesView.tsx
```

Expected: `npm run build` (`tsc -b` + `vite build`) succeeds (exit 0). The scoped `eslint` reports **0 errors** on these three files (a pre-existing exhaustive-deps *warning* on `EnemiesView.tsx:52` may remain — warnings are fine). Do NOT run whole-tree `npm run lint` (32 pre-existing baseline errors, not yours).

- [ ] **Step 5: Manual check**

Start the dev server (`npm run dev`), load a ROM, open the **Enemies** tab. Expected: seven sub-tabs — Roster (default) / Encounters / Bosses / Overworld / Boss Bytes ᵉˣᵖᵉʳᵗ / Encounter Rates ᵉˣᵖᵉʳᵗ / TB Formulas ᵉˣᵖᵉʳᵗ. The three new tabs render their panels; the amber "expert" tag shows on exactly those three.

- [ ] **Step 6: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/common/SubTabBar.tsx projects/TMOS_Randomizer_V2/ui/src/store/index.ts projects/TMOS_Randomizer_V2/ui/src/components/views/EnemiesView.tsx
git commit -m "feat(ui): shared SubTabBar + advanced Enemies sub-tabs"
```

---

### Task 2: Hero sub-tab bar (Progression / Magic / Weapon Damage / Caps)

Wraps the existing `PlayerStatsView` as the default "Progression & Combat" sub-tab and adds three siblings. A thin new `HeroView` wrapper keeps `PlayerStatsView` (381 lines) untouched. Hero has no deep-link, so section state is local.

**Files:**
- Create: `projects/TMOS_Randomizer_V2/ui/src/components/views/HeroView.tsx`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts` (export `HeroView`)
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx:139` (route `hero` → `HeroView`)

**Interfaces:**
- Consumes: `SubTabBar`, `SubTab` from Task 1; `PlayerStatsView` (existing), `MpTablePanel`, `WeaponDamagePanel`, `LevelCapsPanel` from `../advanced/`.
- Produces: `HeroView()` (no props), exported from the views barrel.

- [ ] **Step 1: Create `HeroView`**

Create `projects/TMOS_Randomizer_V2/ui/src/components/views/HeroView.tsx`:

```tsx
import { useState } from 'react';
import { SubTabBar, type SubTab } from '../common/SubTabBar';
import { PlayerStatsView } from './PlayerStatsView';
import { MpTablePanel } from '../advanced/MpTablePanel';
import { WeaponDamagePanel } from '../advanced/WeaponDamagePanel';
import { LevelCapsPanel } from '../advanced/LevelCapsPanel';

type HeroSection = 'progression' | 'magic' | 'weapons' | 'caps';

const SECTIONS: SubTab<HeroSection>[] = [
  { id: 'progression', label: 'Progression & Combat' },
  { id: 'magic', label: 'Magic & Spells' },
  { id: 'weapons', label: 'Weapon Damage', expert: true },
  { id: 'caps', label: 'Caps & Limits' },
];

/**
 * Hero tab: the player-progression editor (default) plus the magic, weapon-damage,
 * and caps panels re-homed from the retired Expert tab.
 */
export function HeroView() {
  const [section, setSection] = useState<HeroSection>('progression');
  return (
    <div className="h-full flex flex-col">
      <SubTabBar tabs={SECTIONS} active={section} onSelect={setSection} />
      <div className="flex-1 overflow-auto">
        {section === 'progression' && <PlayerStatsView />}
        {section === 'magic' && <MpTablePanel />}
        {section === 'weapons' && <WeaponDamagePanel />}
        {section === 'caps' && <LevelCapsPanel />}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Export `HeroView` from the barrel**

In `projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts`, add after the `PlayerStatsView` export (line 4):

```ts
export { HeroView } from './HeroView';
```

- [ ] **Step 3: Route the Hero tab to `HeroView`**

In `projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx`:

(a) Update the import on line 5 to include `HeroView` and drop `PlayerStatsView` (it is no longer referenced directly here):

```tsx
import { ItemsView, HeroView, EnemiesView, AlliesView, MapView, ExpertView, WorldView } from '../views';
```

(b) Change line 139 from:

```tsx
              {selectedTab === 'hero' && <PlayerStatsView />}
```

to:

```tsx
              {selectedTab === 'hero' && <HeroView />}
```

- [ ] **Step 4: Typecheck + scoped lint**

```bash
npm run build
npx eslint src/components/views/HeroView.tsx src/components/views/index.ts src/components/layout/MainContent.tsx
```

Expected: `npm run build` exit 0; scoped `eslint` reports 0 errors on these files. Do NOT run whole-tree `npm run lint` (pre-existing baseline errors).

- [ ] **Step 5: Manual check**

Hero tab shows four sub-tabs; Progression is default and renders the existing player-stats editor; Magic / Weapon Damage ᵉˣᵖᵉʳᵗ / Caps render their panels; the amber tag shows only on Weapon Damage.

- [ ] **Step 6: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/views/HeroView.tsx projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx
git commit -m "feat(ui): Hero sub-tabs (progression/magic/weapons/caps)"
```

---

### Task 3: Items sub-tab bar (Items / Economy) + economy deep-link

Wraps the existing `ItemsView` as the default "Items" sub-tab and adds an "Economy & Shops" sub-tab hosting `EconomyPanel`. A thin `ItemsTabView` wrapper holds local section state plus the `focusTarget` consumer that lands the World-screen shop link on Economy. `ItemsTabView` receives the same non-null `chapter` `ItemsView` requires today (the tab stays chapter-gated, matching current behavior).

**Files:**
- Create: `projects/TMOS_Randomizer_V2/ui/src/components/views/ItemsTabView.tsx`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts` (export `ItemsTabView`)
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx:138` (route `items` → `ItemsTabView`)

**Interfaces:**
- Consumes: `SubTabBar`/`SubTab` (Task 1); `ItemsView` (existing, prop `{ chapter: SimplifiedChapterPlan }`); `EconomyPanel` from `../advanced/`; store `focusTarget`/`consumeFocusTarget`.
- Produces: `ItemsTabView(props: { chapter: SimplifiedChapterPlan })`, exported from the barrel.

- [ ] **Step 1: Create `ItemsTabView`**

Create `projects/TMOS_Randomizer_V2/ui/src/components/views/ItemsTabView.tsx`:

```tsx
import { useEffect, useState } from 'react';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { useRandomizerStore } from '../../store';
import { SubTabBar, type SubTab } from '../common/SubTabBar';
import { ItemsView } from './ItemsView';
import { EconomyPanel } from '../advanced/EconomyPanel';

type ItemsSection = 'items' | 'economy';

const SECTIONS: SubTab<ItemsSection>[] = [
  { id: 'items', label: 'Items' },
  { id: 'economy', label: 'Economy & Shops' },
];

interface ItemsTabViewProps {
  chapter: SimplifiedChapterPlan;
}

/**
 * Items & Economy tab: the per-chapter items view (default) plus the economy/shops
 * panel re-homed from the retired Expert tab. Consumes a focusTarget so the
 * World-screen shop link deep-links straight to Economy.
 */
export function ItemsTabView({ chapter }: ItemsTabViewProps) {
  const [section, setSection] = useState<ItemsSection>('items');
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  useEffect(() => {
    if (focusTarget?.tab === 'items' && focusTarget.section === 'economy') {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setSection('economy');
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget]);

  return (
    <div className="h-full flex flex-col">
      <SubTabBar tabs={SECTIONS} active={section} onSelect={setSection} />
      <div className="flex-1 overflow-auto">
        {section === 'items' && <ItemsView chapter={chapter} />}
        {section === 'economy' && <EconomyPanel />}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Export `ItemsTabView` from the barrel**

In `projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts`, add after the `ItemsView` export (line 3):

```ts
export { ItemsTabView } from './ItemsTabView';
```

- [ ] **Step 3: Route the Items tab to `ItemsTabView`**

In `projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx`:

(a) Update the import on line 5 to swap `ItemsView` for `ItemsTabView`:

```tsx
import { ItemsTabView, HeroView, EnemiesView, AlliesView, MapView, ExpertView, WorldView } from '../views';
```

(b) Change line 138 from:

```tsx
              {selectedTab === 'items' && planChapter && <ItemsView chapter={planChapter} />}
```

to:

```tsx
              {selectedTab === 'items' && planChapter && <ItemsTabView chapter={planChapter} />}
```

- [ ] **Step 4: Typecheck + scoped lint**

```bash
npm run build
npx eslint src/components/views/ItemsTabView.tsx src/components/views/index.ts src/components/layout/MainContent.tsx
```

Expected: `npm run build` exit 0; scoped `eslint` reports 0 errors on these files. Do NOT run whole-tree `npm run lint` (pre-existing baseline errors).

- [ ] **Step 5: Manual check**

With a chapter loaded, the Items & Economy tab shows two sub-tabs: Items (default, the existing chapter items view) and Economy & Shops (the EconomyPanel). Both render.

- [ ] **Step 6: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/views/ItemsTabView.tsx projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx
git commit -m "feat(ui): Items sub-tabs (items/economy) + economy deep-link"
```

---

### Task 4: Graphics sub-tab bar (Tiles / Cosmetic) + cosmetic deep-link

Wraps the existing `TileBankView` as the default "Tiles" sub-tab and adds a "Cosmetic" sub-tab hosting `PalettePanel`, plus the `focusTarget` consumer for the World-screen palette link. A thin `GraphicsView` wrapper holds local section state. `graphics` is already a global tab.

**Files:**
- Create: `projects/TMOS_Randomizer_V2/ui/src/components/views/GraphicsView.tsx`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts` (export `GraphicsView`)
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx:142` (route `graphics` → `GraphicsView`)

**Interfaces:**
- Consumes: `SubTabBar`/`SubTab` (Task 1); `TileBankView` from `../tilebank`; `PalettePanel` from `../advanced/`; store `focusTarget`/`consumeFocusTarget`.
- Produces: `GraphicsView()` (no props), exported from the barrel.

- [ ] **Step 1: Create `GraphicsView`**

Create `projects/TMOS_Randomizer_V2/ui/src/components/views/GraphicsView.tsx`:

```tsx
import { useEffect, useState } from 'react';
import { useRandomizerStore } from '../../store';
import { SubTabBar, type SubTab } from '../common/SubTabBar';
import { TileBankView } from '../tilebank';
import { PalettePanel } from '../advanced/PalettePanel';

type GraphicsSection = 'tiles' | 'cosmetic';

const SECTIONS: SubTab<GraphicsSection>[] = [
  { id: 'tiles', label: 'Tiles' },
  { id: 'cosmetic', label: 'Cosmetic' },
];

/**
 * Graphics tab: the tile-bank editor (default) plus the palette/cosmetic panel
 * re-homed from the retired Expert tab. Consumes a focusTarget so the World-screen
 * palette link deep-links straight to Cosmetic.
 */
export function GraphicsView() {
  const [section, setSection] = useState<GraphicsSection>('tiles');
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  useEffect(() => {
    if (focusTarget?.tab === 'graphics' && focusTarget.section === 'cosmetic') {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setSection('cosmetic');
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget]);

  return (
    <div className="h-full flex flex-col">
      <SubTabBar tabs={SECTIONS} active={section} onSelect={setSection} />
      <div className="flex-1 overflow-auto">
        {section === 'tiles' && <TileBankView />}
        {section === 'cosmetic' && <PalettePanel />}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Export `GraphicsView` from the barrel**

In `projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts`, add:

```ts
export { GraphicsView } from './GraphicsView';
```

- [ ] **Step 3: Route the Graphics tab to `GraphicsView`**

In `projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx`:

(a) Update the import on line 5 to include `GraphicsView`, and remove the now-unused direct `TileBankView` import on line 4:

Change line 4 from:

```tsx
import { TileBankView } from '../tilebank';
```

to (delete the line entirely — `TileBankView` is no longer referenced in `MainContent`).

And update the views import (line 5) to add `GraphicsView`:

```tsx
import { ItemsTabView, HeroView, EnemiesView, AlliesView, MapView, ExpertView, WorldView, GraphicsView } from '../views';
```

(b) Change line 142 from:

```tsx
              {selectedTab === 'graphics' && <TileBankView />}
```

to:

```tsx
              {selectedTab === 'graphics' && <GraphicsView />}
```

- [ ] **Step 4: Typecheck + scoped lint**

```bash
npm run build
npx eslint src/components/views/GraphicsView.tsx src/components/views/index.ts src/components/layout/MainContent.tsx
```

Expected: `npm run build` exit 0 (if `tsc` reports `TileBankView` declared-but-unused, confirm line 4's import was removed); scoped `eslint` reports 0 errors on these files. Do NOT run whole-tree `npm run lint` (pre-existing baseline errors).

- [ ] **Step 5: Manual check**

Graphics tab shows two sub-tabs: Tiles (default, the tile-bank editor) and Cosmetic (the PalettePanel). Both render.

- [ ] **Step 6: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/views/GraphicsView.tsx projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx
git commit -m "feat(ui): Graphics sub-tabs (tiles/cosmetic) + cosmetic deep-link"
```

---

### Task 5: Repoint shop/palette cross-links to Items/Graphics

Repoints the two World-screen deep-links that previously unlocked + opened the Expert tab so they now target the re-homed Economy (Items) and Cosmetic (Graphics) sub-tabs, and removes the `unlockExpert` action from the link surface. This is the one task with a real unit test.

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/screen/screenLinks.ts`
- Test: `projects/TMOS_Randomizer_V2/ui/src/components/screen/screenLinks.test.ts`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/views/WorldView.tsx:18-46`

**Interfaces:**
- Consumes: `ScreenLinkActions` (existing), minus its `unlockExpert` member after this task.
- Produces: shop link → `setFocusTarget({ tab: 'items', section: 'economy' })`; palette link → `setFocusTarget({ tab: 'graphics', section: 'cosmetic' })`; `ScreenLinkActions` no longer declares `unlockExpert`.

- [ ] **Step 1: Update the unit test to the new expectations (TDD — write the failing test first)**

In `projects/TMOS_Randomizer_V2/ui/src/components/screen/screenLinks.test.ts`:

(a) Remove `unlockExpert: vi.fn(),` from the `spies()` factory (lines 7–14) so it becomes:

```ts
function spies(): ScreenLinkActions {
  return {
    setFocusTarget: vi.fn(),
    navigateToTile: vi.fn(),
    selectScreen: vi.fn(),
  };
}
```

(b) Replace the shop test (lines 42–49) with:

```ts
  it('content shop 0x60 → Items/Economy, with note', () => {
    const a = spies();
    const link = screenLinksFor('content', 0x60, screen, 1, a)[0];
    expect(link.note).toBeTruthy();
    link.onActivate();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'items', section: 'economy' });
  });
```

(c) Replace the palette test (lines 63–68) with:

```ts
  it('palette byte → Graphics/Cosmetic', () => {
    const a = spies();
    screenLinksFor('worldscreen_color', 0x01, screen, 1, a)[0].onActivate();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'graphics', section: 'cosmetic' });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

From `projects/TMOS_Randomizer_V2/ui`:

```bash
npm test -- screenLinks
```

Expected: FAIL — the shop assertion expects `{ tab: 'items', section: 'economy' }` but the current code calls `unlockExpert()` and sets `{ tab: 'expert', section: 'economy' }`; also `ScreenLinkActions` still requires `unlockExpert`, so the trimmed `spies()` may be a type error under `vitest`'s type checking — both confirm the test now drives the change.

- [ ] **Step 3: Repoint the links and drop `unlockExpert` from `ScreenLinkActions`**

In `projects/TMOS_Randomizer_V2/ui/src/components/screen/screenLinks.ts`:

(a) Remove `unlockExpert` from the `ScreenLinkActions` interface (lines 6–11) so it becomes:

```ts
export interface ScreenLinkActions {
  setFocusTarget: (target: FocusTarget) => void;
  navigateToTile: (index: number) => void;
  selectScreen: (index: number) => void;
}
```

(b) Replace the shop link block (lines 47–56) with:

```ts
  if (value >= 0x60 && value <= 0x7D) {
    return [{
      label: 'Open Economy & Shops',
      note: 'Per-screen shop inventory is not yet decoded (Bank 2 RE pending).',
      onActivate: () => actions.setFocusTarget({ tab: 'items', section: 'economy' }),
    }];
  }
```

(c) Replace the palette link block (lines 81–89) with:

```ts
    case 'worldscreen_color':
    case 'sprites_color':
      return [{
        label: 'Edit palette in Graphics → Cosmetic',
        onActivate: () => actions.setFocusTarget({ tab: 'graphics', section: 'cosmetic' }),
      }];
```

- [ ] **Step 4: Remove `unlockExpert` from `WorldView`'s `linkActions` bundle**

In `projects/TMOS_Randomizer_V2/ui/src/components/views/WorldView.tsx`:

(a) Remove `unlockExpert,` from the store destructure (line 30).

(b) Update the `linkActions` memo (lines 41–46) to:

```tsx
  const linkActions: ScreenLinkActions = useMemo(() => ({
    setFocusTarget,
    navigateToTile,
    selectScreen: setSelectedScreen,
  }), [setFocusTarget, navigateToTile, setSelectedScreen]);
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
npm test -- screenLinks
```

Expected: PASS — all `screenLinksFor` tests green, including the repointed shop and palette assertions.

- [ ] **Step 6: Typecheck + scoped lint**

```bash
npm run build
npx eslint src/components/screen/screenLinks.ts src/components/screen/screenLinks.test.ts src/components/views/WorldView.tsx
```

Expected: `npm run build` exit 0 (`store` still defines `unlockExpert`/`expertUnlocked` and `TabType` still has `'expert'` — `ExpertView`/`AdvancedView` still consume them, so the build stays green; they are removed in Task 6). Scoped `eslint` reports 0 errors on these files. Do NOT run whole-tree `npm run lint` (pre-existing baseline errors).

- [ ] **Step 7: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/screenLinks.ts projects/TMOS_Randomizer_V2/ui/src/components/screen/screenLinks.test.ts projects/TMOS_Randomizer_V2/ui/src/components/views/WorldView.tsx
git commit -m "feat(ui): repoint shop/palette links to Items/Graphics sub-tabs"
```

---

### Task 6: Delete the Expert tab, gate, and store machinery

Removes `ExpertView`/`AdvancedView`, the `expert` tab entry/route, and the `expertUnlocked`/`unlockExpert` store state — then narrows `TabType` so `tsc` proves no dangling references remain. The redundant `JsonDebugPanel` render in `ExpertView` simply disappears (the Debug tab's Inspector section already hosts it).

**Files:**
- Delete: `projects/TMOS_Randomizer_V2/ui/src/components/views/ExpertView.tsx`
- Delete: `projects/TMOS_Randomizer_V2/ui/src/components/views/AdvancedView.tsx`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts` (drop `ExpertView`/`AdvancedView` exports)
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/store/index.ts` (remove `expertUnlocked`/`unlockExpert`; narrow `TabType`)

**Interfaces:**
- Produces: `TabType = 'world' | 'enemies' | 'items' | 'hero' | 'allies' | 'graphics' | 'randomize' | 'debug'` (no `'expert'`). No `expertUnlocked` state or `unlockExpert` action on the store.

- [ ] **Step 1: Delete the two view files**

```bash
git rm projects/TMOS_Randomizer_V2/ui/src/components/views/ExpertView.tsx projects/TMOS_Randomizer_V2/ui/src/components/views/AdvancedView.tsx
```

- [ ] **Step 2: Drop the barrel exports**

In `projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts`, delete these two lines:

```ts
export { AdvancedView } from './AdvancedView';
export { ExpertView } from './ExpertView';
```

- [ ] **Step 3: Remove the Expert tab from `MainContent`**

In `projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx`:

(a) Drop `ExpertView` from the views import (line 5):

```tsx
import { ItemsTabView, HeroView, EnemiesView, AlliesView, MapView, WorldView, GraphicsView } from '../views';
```

(b) Remove the Expert entry from `TABS` (line 16): delete

```tsx
  { id: 'expert', label: '⚠ Expert' },
```

(c) Remove `'expert'` from the `GLOBAL_TABS` set (line 27):

```tsx
const GLOBAL_TABS = new Set<TabType>(['enemies', 'hero', 'graphics', 'randomize', 'debug']);
```

(d) Remove the Expert route (line 143): delete

```tsx
              {selectedTab === 'expert' && <ExpertView />}
```

- [ ] **Step 4: Remove the gate state/action and narrow `TabType` in the store**

In `projects/TMOS_Randomizer_V2/ui/src/store/index.ts`:

(a) Narrow `TabType` (line 35) — drop `'expert'`:

```ts
export type TabType = 'world' | 'enemies' | 'items' | 'hero' | 'allies' | 'graphics' | 'randomize' | 'debug';
```

(b) Delete the `expertUnlocked: boolean;` interface field (line 176).

(c) Delete the `unlockExpert: () => void;` interface declaration (line 272).

(d) Delete the `expertUnlocked: false,` initial value (line 407).

(e) Delete the `unlockExpert: () => set({ expertUnlocked: true }),` implementation (line 1412).

- [ ] **Step 5: Repo-wide sweep for stragglers**

From `projects/TMOS_Randomizer_V2/ui`, search for any remaining references:

```bash
grep -rn "expertUnlocked\|unlockExpert\|ExpertView\|AdvancedView\|tab: 'expert'\|'expert'" src
```

Expected: no matches. If any appear (other than already-handled ones), resolve them — `tsc` in the next step is the backstop.

- [ ] **Step 6: Typecheck + scoped lint + full test run**

```bash
npm run build
npx eslint src/components/views/index.ts src/components/layout/MainContent.tsx src/store/index.ts
npm test
```

Expected: `npm run build` passes (`tsc -b` — the narrowed `TabType` surfaces any missed `'expert'` reference as a compile error; there should be none). Scoped `eslint` reports 0 errors on these files. All Vitest suites green (80+ tests). Do NOT run whole-tree `npm run lint` (32 pre-existing baseline errors unrelated to this work). Note: the whole-tree error count must not *increase* from the 32-error baseline — the scoped lint on changed files guarantees this.

- [ ] **Step 7: Manual checklist**

Load a ROM and verify:
- The `⚠ Expert` tab is gone; there is no full-page "I understand this can crash" wall anywhere.
- Hero → Progression (default) / Magic / Weapon Damage ᵉˣᵖᵉʳᵗ / Caps.
- Enemies → Roster (default) / Encounters / Bosses / Overworld / Boss Bytes ᵉˣᵖᵉʳᵗ / Encounter Rates ᵉˣᵖᵉʳᵗ / TB Formulas ᵉˣᵖᵉʳᵗ.
- Items & Economy → Items (default) / Economy & Shops (chapter loaded).
- Graphics → Tiles (default) / Cosmetic.
- From a World screen detail panel: the shop link (content `0x60–0x7D`) opens Items → Economy; the palette link (`worldscreen_color`/`sprites_color`) opens Graphics → Cosmetic.
- Danger panels are editable immediately (no gate), marked only by their inline `TierBadge` + the amber sub-tab tag. Safe boss fields appear only under Enemies → Bosses; advanced boss bytes only under Enemies → Boss Bytes (no field editable in two places).
- Debug tab still shows Changes / Validation / Inspector (Inspector = the JSON panel).

- [ ] **Step 8: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/views/index.ts projects/TMOS_Randomizer_V2/ui/src/components/layout/MainContent.tsx projects/TMOS_Randomizer_V2/ui/src/store/index.ts
git commit -m "feat(ui): retire Expert tab + unlock gate; narrow TabType"
```

(The two deleted files are already staged by `git rm` in Step 1.)

---

## Self-Review

**Spec coverage:**
- Section 1 (re-home panels into entity tabs): Hero → Task 2; Enemies danger sub-tabs → Task 1; Items/Economy → Task 3; Graphics/Cosmetic → Task 4; Debug already hosts JsonDebugPanel (no task needed, noted in Task 6). ✔
- Section 2 (remove gate + tab, narrow TabType): Task 6. ✔
- Section 3 (repoint cross-links, move deep-link consumers, drop unlockExpert from bundle/interface): shop/palette repoint + WorldView + ScreenLinkActions → Task 5; economy consumer → Task 3; cosmetic consumer → Task 4; Enemies/Allies consumers untouched ✔; repo-wide sweep → Task 6 Step 5. ✔
- Section 4 (tests): screenLinks.test.ts updates → Task 5; tsc/lint/manual → every task. ✔
- "No editable field in two tabs": `BossesPanel tierFilter={tier!=='safe'}` preserved verbatim (Task 1 Step 3d); end-state verified Task 6 Step 7. ✔

**Placeholder scan:** No TBD/TODO/"handle edge cases"/"similar to Task N". Every code step shows complete code. ✔

**Type consistency:** `SubTab<T>`/`SubTabBar<T>` signature defined in Task 1 and consumed identically in Tasks 2–4. Section unions match the Global-Constraints vocabulary. `EnemiesSection` extension (Task 1) consumed by the extended `SECTIONS` in the same task. `ScreenLinkActions` loses `unlockExpert` in Task 5; `WorldView` and `screenLinks.test.ts` updated in the same task; store/`TabType` cleanup deferred to Task 6 with the build kept green in between. `FocusTarget.section` is a free `string`, so `'economy'`/`'cosmetic'` need no type change. ✔
