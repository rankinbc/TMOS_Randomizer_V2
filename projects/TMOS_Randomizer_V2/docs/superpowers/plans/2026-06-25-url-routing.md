# Hierarchical URL Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the URL hash reflect where you are in the app (tab, Enemies sub-tab, selected enemy, Encounters chapter) and reflect URL changes back into the app — bookmarkable, refreshable, back/forward-aware.

**Architecture:** A pure routing module (`appRoute.ts`) defines the `#/tab/sub/id` grammar and parse/format. The three pieces of Enemies navigation that currently live in component-local `useState` are lifted into the Zustand store so they're observable. A single `useAppRouting()` hook mirrors store ↔ `window.location.hash` in both directions, guarded against feedback loops.

**Tech Stack:** React 19, Zustand v5, TypeScript, Vite, Vitest. No new dependencies.

## Global Constraints

- URL style: **hash-based** (`#/...`). Never use `history.pushState` with a path; only the hash carries route state. Hydration-on-load uses `history.replaceState` (no extra history entry).
- Enemy id in the URL is **lowercase hex, zero-padded to 2 digits, no `0x`** (e.g. `1c`). Valid range `0x00`–`0xFF`.
- Encounters chapter in the URL is **decimal, range 1–5**.
- Default/fallback tab is `world`. Default Enemies sub-tab is `roster`. Default Encounters chapter is `1`.
- All work is under `ui/`. Run commands from `ui/` (`cd ui` first).
- Match existing test convention: Vitest with `import { describe, it, expect } from 'vitest'`, files named `*.test.ts` colocated next to source.
- Follow the shared-checkout rule: `git add` only the exact files listed in each task. Never `git add -A`.

---

### Task 1: Store navigation fields for Enemies

**Files:**
- Modify: `ui/src/store/index.ts`
- Test: `ui/src/store/index.test.ts`

**Interfaces:**
- Consumes: nothing (foundation task).
- Produces:
  - Exported type `EnemiesSection = 'roster' | 'encounters' | 'bosses' | 'overworld'`.
  - Store fields `enemiesSection: EnemiesSection` (default `'roster'`), `enemiesSelectedId: number | null` (default `null`), `enemiesChapter: number` (default `1`).
  - Store actions `setEnemiesSection(section: EnemiesSection): void`, `setEnemiesSelectedId(id: number | null): void`, `setEnemiesChapter(ch: number): void`.

- [ ] **Step 1: Write the failing test**

Append to `ui/src/store/index.test.ts`:

```ts
describe('enemies navigation state', () => {
  beforeEach(() => {
    useRandomizerStore.setState({
      enemiesSection: 'roster',
      enemiesSelectedId: null,
      enemiesChapter: 1,
    });
  });

  it('defaults to roster / no selection / chapter 1', () => {
    const s = useRandomizerStore.getState();
    expect(s.enemiesSection).toBe('roster');
    expect(s.enemiesSelectedId).toBeNull();
    expect(s.enemiesChapter).toBe(1);
  });

  it('setEnemiesSection updates the sub-tab', () => {
    useRandomizerStore.getState().setEnemiesSection('encounters');
    expect(useRandomizerStore.getState().enemiesSection).toBe('encounters');
  });

  it('setEnemiesSelectedId stores and clears the selection', () => {
    useRandomizerStore.getState().setEnemiesSelectedId(0x1c);
    expect(useRandomizerStore.getState().enemiesSelectedId).toBe(0x1c);
    useRandomizerStore.getState().setEnemiesSelectedId(null);
    expect(useRandomizerStore.getState().enemiesSelectedId).toBeNull();
  });

  it('setEnemiesChapter updates the encounters chapter', () => {
    useRandomizerStore.getState().setEnemiesChapter(3);
    expect(useRandomizerStore.getState().enemiesChapter).toBe(3);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ui && npx vitest run src/store/index.test.ts`
Expected: FAIL — `setEnemiesSection is not a function` (and the other new fields undefined).

- [ ] **Step 3: Add the exported type**

In `ui/src/store/index.ts`, just above the existing `TabType` export (line ~32), add:

```ts
// Enemies-tab sub-sections (also used by the URL router).
export type EnemiesSection = 'roster' | 'encounters' | 'bosses' | 'overworld';
```

- [ ] **Step 4: Declare fields + actions on the interface**

In `interface RandomizerState`, in the `// UI State` block (right after `selectedTab: TabType;`), add:

```ts
  // Enemies-tab navigation (URL-addressable; lifted from component-local state)
  enemiesSection: EnemiesSection;
  enemiesSelectedId: number | null;
  enemiesChapter: number;
```

In the `// Actions` block (right after `setSelectedTab: (tab: TabType) => void;`), add:

```ts
  setEnemiesSection: (section: EnemiesSection) => void;
  setEnemiesSelectedId: (id: number | null) => void;
  setEnemiesChapter: (ch: number) => void;
```

- [ ] **Step 5: Add initial values + action implementations**

In the `create<RandomizerState>(...)` initial-state object, right after `selectedTab: 'world',`, add:

```ts
  enemiesSection: 'roster',
  enemiesSelectedId: null,
  enemiesChapter: 1,
```

Right after the `setSelectedTab: (tab) => set({ selectedTab: tab }),` action, add:

```ts
  setEnemiesSection: (section) => set({ enemiesSection: section }),
  setEnemiesSelectedId: (id) => set({ enemiesSelectedId: id }),
  setEnemiesChapter: (ch) => set({ enemiesChapter: ch }),
```

- [ ] **Step 6: Run test to verify it passes**

Run: `cd ui && npx vitest run src/store/index.test.ts`
Expected: PASS (all `enemies navigation state` tests green, existing `focusTarget` tests still green).

- [ ] **Step 7: Commit**

```bash
git add ui/src/store/index.ts ui/src/store/index.test.ts
git commit -m "feat(ui): add URL-addressable Enemies navigation state to store"
```

---

### Task 2: Pure routing module (`appRoute.ts`)

**Files:**
- Create: `ui/src/routing/appRoute.ts`
- Test: `ui/src/routing/appRoute.test.ts`

**Interfaces:**
- Consumes: `TabType`, `EnemiesSection` (type-only) from `../store`.
- Produces:
  - `interface AppRoute { tab: TabType; sub?: EnemiesSection; id?: number; chapter?: number }`
  - `parseHash(hash: string): AppRoute`
  - `hashForRoute(route: AppRoute): string`
  - `hexToId(s: string): number | null`
  - `idToHex(n: number): string`

- [ ] **Step 1: Write the failing test**

Create `ui/src/routing/appRoute.test.ts`:

```ts
import { describe, it, expect } from 'vitest';
import { parseHash, hashForRoute, hexToId, idToHex } from './appRoute';

describe('hexToId / idToHex', () => {
  it('round-trips a byte id', () => {
    expect(idToHex(0x1c)).toBe('1c');
    expect(hexToId('1c')).toBe(0x1c);
  });
  it('zero-pads to two digits', () => {
    expect(idToHex(0x0d)).toBe('0d');
    expect(hexToId('0d')).toBe(0x0d);
  });
  it('tolerates a 0x prefix and unpadded input', () => {
    expect(hexToId('0x1c')).toBe(28);
    expect(hexToId('d')).toBe(13);
  });
  it('rejects non-hex and out-of-range', () => {
    expect(hexToId('zz')).toBeNull();
    expect(hexToId('')).toBeNull();
    expect(hexToId('-1')).toBeNull();
    expect(hexToId('100')).toBeNull(); // 256 > 0xFF
  });
});

describe('parseHash', () => {
  it('parses a bare tab', () => {
    expect(parseHash('#/hero')).toEqual({ tab: 'hero' });
  });
  it('falls back to world for empty / unknown', () => {
    expect(parseHash('')).toEqual({ tab: 'world' });
    expect(parseHash('#/')).toEqual({ tab: 'world' });
    expect(parseHash('#/garbage')).toEqual({ tab: 'world' });
  });
  it('defaults a bare enemies route to the roster sub-tab', () => {
    expect(parseHash('#/enemies')).toEqual({ tab: 'enemies', sub: 'roster' });
  });
  it('falls back to roster for an unknown sub-tab', () => {
    expect(parseHash('#/enemies/nope')).toEqual({ tab: 'enemies', sub: 'roster' });
  });
  it('parses a roster enemy id from hex', () => {
    expect(parseHash('#/enemies/roster/1c')).toEqual({ tab: 'enemies', sub: 'roster', id: 0x1c });
  });
  it('omits the id when unparseable', () => {
    expect(parseHash('#/enemies/roster/zz')).toEqual({ tab: 'enemies', sub: 'roster' });
  });
  it('parses an encounters chapter (decimal)', () => {
    expect(parseHash('#/enemies/encounters/3')).toEqual({ tab: 'enemies', sub: 'encounters', chapter: 3 });
  });
  it('clamps a missing/out-of-range chapter to 1', () => {
    expect(parseHash('#/enemies/encounters')).toEqual({ tab: 'enemies', sub: 'encounters', chapter: 1 });
    expect(parseHash('#/enemies/encounters/9')).toEqual({ tab: 'enemies', sub: 'encounters', chapter: 1 });
  });
  it('ignores a third segment for bosses/overworld', () => {
    expect(parseHash('#/enemies/bosses')).toEqual({ tab: 'enemies', sub: 'bosses' });
    expect(parseHash('#/enemies/overworld')).toEqual({ tab: 'enemies', sub: 'overworld' });
  });
});

describe('hashForRoute', () => {
  it('formats a bare tab', () => {
    expect(hashForRoute({ tab: 'world' })).toBe('#/world');
  });
  it('normalizes bare enemies to roster', () => {
    expect(hashForRoute({ tab: 'enemies' })).toBe('#/enemies/roster');
  });
  it('formats a roster selection in hex', () => {
    expect(hashForRoute({ tab: 'enemies', sub: 'roster', id: 0x1c })).toBe('#/enemies/roster/1c');
  });
  it('omits the id segment when there is no selection', () => {
    expect(hashForRoute({ tab: 'enemies', sub: 'roster' })).toBe('#/enemies/roster');
  });
  it('always emits the encounters chapter (defaulting to 1)', () => {
    expect(hashForRoute({ tab: 'enemies', sub: 'encounters', chapter: 3 })).toBe('#/enemies/encounters/3');
    expect(hashForRoute({ tab: 'enemies', sub: 'encounters' })).toBe('#/enemies/encounters/1');
  });
});

describe('round-trip', () => {
  for (const h of ['#/world', '#/hero', '#/enemies/roster', '#/enemies/roster/1c', '#/enemies/encounters/3', '#/enemies/bosses']) {
    it(`${h} survives parse → format`, () => {
      expect(hashForRoute(parseHash(h))).toBe(h);
    });
  }
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ui && npx vitest run src/routing/appRoute.test.ts`
Expected: FAIL — cannot find module `./appRoute`.

- [ ] **Step 3: Write the implementation**

Create `ui/src/routing/appRoute.ts`:

```ts
import type { TabType, EnemiesSection } from '../store';

export interface AppRoute {
  tab: TabType;
  sub?: EnemiesSection;
  id?: number;       // roster: enemy id (decoded from hex)
  chapter?: number;  // encounters: chapter 1–5
}

const VALID_TABS: TabType[] = [
  'world', 'enemies', 'items', 'hero', 'allies', 'graphics', 'randomize', 'expert', 'debug',
];
const ENEMIES_SUBS: EnemiesSection[] = ['roster', 'encounters', 'bosses', 'overworld'];

export function idToHex(n: number): string {
  return n.toString(16).padStart(2, '0');
}

export function hexToId(s: string): number | null {
  if (!s) return null;
  const cleaned = s.toLowerCase().replace(/^0x/, '');
  if (!/^[0-9a-f]+$/.test(cleaned)) return null;
  const n = parseInt(cleaned, 16);
  if (Number.isNaN(n) || n < 0 || n > 0xff) return null;
  return n;
}

function parseChapter(s: string | undefined): number {
  const n = Number(s);
  if (!Number.isInteger(n) || n < 1 || n > 5) return 1;
  return n;
}

export function parseHash(hash: string): AppRoute {
  const raw = hash.replace(/^#/, '').replace(/^\//, '');
  const segs = raw.split('/').filter(Boolean);
  const tab = segs[0];

  if (!VALID_TABS.includes(tab as TabType)) return { tab: 'world' };
  if (tab !== 'enemies') return { tab: tab as TabType };

  const sub: EnemiesSection = ENEMIES_SUBS.includes(segs[1] as EnemiesSection)
    ? (segs[1] as EnemiesSection)
    : 'roster';
  const route: AppRoute = { tab: 'enemies', sub };

  if (sub === 'roster') {
    const id = hexToId(segs[2] ?? '');
    if (id !== null) route.id = id;
  } else if (sub === 'encounters') {
    route.chapter = parseChapter(segs[2]);
  }
  return route;
}

export function hashForRoute(route: AppRoute): string {
  if (route.tab !== 'enemies') return `#/${route.tab}`;
  const sub = route.sub ?? 'roster';
  let h = `#/enemies/${sub}`;
  if (sub === 'roster' && route.id != null) h += `/${idToHex(route.id)}`;
  if (sub === 'encounters') h += `/${route.chapter ?? 1}`;
  return h;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd ui && npx vitest run src/routing/appRoute.test.ts`
Expected: PASS (all cases green).

- [ ] **Step 5: Commit**

```bash
git add ui/src/routing/appRoute.ts ui/src/routing/appRoute.test.ts
git commit -m "feat(ui): pure hash-route grammar (parse/format + hex/chapter)"
```

---

### Task 3: Migrate EnemiesView to store-backed sub-tab + chapter

**Files:**
- Modify: `ui/src/components/views/EnemiesView.tsx`

**Interfaces:**
- Consumes: `EnemiesSection`, `enemiesSection`/`setEnemiesSection`, `enemiesChapter`/`setEnemiesChapter` from the store (Task 1).
- Produces: no new exports; behavior unchanged from the user's perspective. The sub-tab and Encounters chapter now read/write the store.

- [ ] **Step 1: Replace the React + store imports**

Change line 1 from:

```ts
import { useEffect, useState } from 'react';
```

to:

```ts
import { useEffect } from 'react';
```

Change line 2 from:

```ts
import { useRandomizerStore } from '../../store';
```

to:

```ts
import { useRandomizerStore, type EnemiesSection } from '../../store';
```

- [ ] **Step 2: Remove the now-duplicate local type**

Delete the local declaration (line ~11):

```ts
type EnemiesSection = 'roster' | 'encounters' | 'bosses' | 'overworld';
```

(The `SECTIONS` array below it keeps using the now-imported `EnemiesSection` type — no change needed there.)

- [ ] **Step 3: Replace the two local `useState` hooks with store selectors**

Change (lines ~38–39):

```ts
  const [section, setSection] = useState<EnemiesSection>('roster');
  const [selectedChapter, setSelectedChapter] = useState(1);
```

to:

```ts
  const section = useRandomizerStore((s) => s.enemiesSection);
  const setSection = useRandomizerStore((s) => s.setEnemiesSection);
  const selectedChapter = useRandomizerStore((s) => s.enemiesChapter);
  const setSelectedChapter = useRandomizerStore((s) => s.setEnemiesChapter);
```

(Every other use of `section`, `setSection`, `selectedChapter`, `setSelectedChapter` in the file is unchanged, including the `focusTarget` effect that calls `setSection(target)`.)

- [ ] **Step 4: Typecheck**

Run: `cd ui && npm run build`
Expected: PASS — no TypeScript errors. (`useState` is no longer imported and no longer referenced; `EnemiesSection` resolves to the store import.)

- [ ] **Step 5: Run the test suite**

Run: `cd ui && npx vitest run`
Expected: PASS — existing suites unaffected.

- [ ] **Step 6: Commit**

```bash
git add ui/src/components/views/EnemiesView.tsx
git commit -m "refactor(ui): EnemiesView reads sub-tab + chapter from store"
```

---

### Task 4: Migrate BattleRosterEditor to store-backed selection

**Files:**
- Modify: `ui/src/components/enemies/BattleRosterEditor.tsx`

**Interfaces:**
- Consumes: `enemiesSelectedId`/`setEnemiesSelectedId` from the store (Task 1).
- Produces: no new exports; the selected enemy is now store state, so it becomes observable by the router (Task 5) and survives tab switches.

- [ ] **Step 1: Drop `useState` from the React import**

Change line 1 from:

```ts
import { useEffect, useMemo, useState } from 'react';
```

to:

```ts
import { useEffect, useMemo } from 'react';
```

- [ ] **Step 2: Replace the local selection state with store selectors**

Change (line ~39):

```ts
  const [selectedId, setSelectedId] = useState<number | null>(null);
```

to:

```ts
  const selectedId = useRandomizerStore((s) => s.enemiesSelectedId);
  const setSelectedId = useRandomizerStore((s) => s.setEnemiesSelectedId);
```

(The roster list's `onClick={() => setSelectedId(e.enemy_id)}` and all `selectedId` reads are unchanged.)

- [ ] **Step 3: Typecheck**

Run: `cd ui && npm run build`
Expected: PASS — no TypeScript errors (`useState` no longer imported or referenced).

- [ ] **Step 4: Run the test suite**

Run: `cd ui && npx vitest run`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add ui/src/components/enemies/BattleRosterEditor.tsx
git commit -m "refactor(ui): BattleRosterEditor selection lives in store"
```

---

### Task 5: Wire the routing hook into the app

**Files:**
- Create: `ui/src/routing/useAppRouting.ts`
- Modify: `ui/src/App.tsx`

**Interfaces:**
- Consumes: `parseHash`, `hashForRoute` (Task 2); store fields/actions `selectedTab`/`setSelectedTab`, `enemiesSection`/`setEnemiesSection`, `enemiesSelectedId`/`setEnemiesSelectedId`, `enemiesChapter`/`setEnemiesChapter` (Task 1).
- Produces: `useAppRouting(): void` — call once near the app root.

- [ ] **Step 1: Write the hook**

Create `ui/src/routing/useAppRouting.ts`:

```ts
import { useEffect } from 'react';
import { useRandomizerStore } from '../store';
import { parseHash, hashForRoute, type AppRoute } from './appRoute';

type StoreState = ReturnType<typeof useRandomizerStore.getState>;

/**
 * Two-way sync between the active app location and `window.location.hash`.
 * Grammar lives in appRoute.ts. Every write is guarded by an equality check so
 * a store-driven hash write and a hash-driven store write cannot ping-pong.
 *
 * Scope: tab for every tab; for the Enemies tab also its sub-tab, the roster
 * selection, and the Encounters chapter. Other tabs are tab-level only.
 */
export function useAppRouting(): void {
  useEffect(() => {
    const store = useRandomizerStore;

    const hashFromStore = (s: StoreState): string => {
      const route: AppRoute = { tab: s.selectedTab };
      if (s.selectedTab === 'enemies') {
        route.sub = s.enemiesSection;
        if (s.enemiesSection === 'roster') route.id = s.enemiesSelectedId ?? undefined;
        if (s.enemiesSection === 'encounters') route.chapter = s.enemiesChapter;
      }
      return hashForRoute(route);
    };

    const applyHashToStore = (hash: string): void => {
      const r = parseHash(hash);
      const s = store.getState();
      if (s.selectedTab !== r.tab) s.setSelectedTab(r.tab);
      if (r.tab === 'enemies' && r.sub) {
        if (s.enemiesSection !== r.sub) s.setEnemiesSection(r.sub);
        if (r.sub === 'roster') {
          const id = r.id ?? null;
          if (s.enemiesSelectedId !== id) s.setEnemiesSelectedId(id);
        }
        if (r.sub === 'encounters') {
          const ch = r.chapter ?? 1;
          if (s.enemiesChapter !== ch) s.setEnemiesChapter(ch);
        }
      }
    };

    // 1. Hydrate store from the initial URL, then normalize the hash in place
    //    (replaceState → no spurious history entry on load).
    applyHashToStore(window.location.hash);
    const canonical = hashFromStore(store.getState());
    if (window.location.hash !== canonical) {
      window.history.replaceState(null, '', canonical);
    }

    // 2. store → URL
    const unsubscribe = store.subscribe((s) => {
      const next = hashFromStore(s);
      if (window.location.hash !== next) {
        window.location.hash = next;
      }
    });

    // 3. URL → store (back/forward, manual edits)
    const onHashChange = () => applyHashToStore(window.location.hash);
    window.addEventListener('hashchange', onHashChange);

    return () => {
      unsubscribe();
      window.removeEventListener('hashchange', onHashChange);
    };
  }, []);
}
```

- [ ] **Step 2: Call the hook from `App`**

In `ui/src/App.tsx`, add the import after the existing store import (line ~8):

```ts
import { useAppRouting } from './routing/useAppRouting';
```

Then add the hook call as the first line inside `function App()` (before the existing `const { ... } = useRandomizerStore();`):

```ts
  useAppRouting();
```

- [ ] **Step 3: Typecheck**

Run: `cd ui && npm run build`
Expected: PASS — no TypeScript errors. (The hook derives the store state type via `ReturnType<typeof useRandomizerStore.getState>`, so no new store export is needed.)

- [ ] **Step 4: Run the full test suite**

Run: `cd ui && npx vitest run`
Expected: PASS — all suites green.

- [ ] **Step 5: Manual verification in the browser**

Run: `cd ui && npm run dev`, open the app, load a ROM, then verify each:

1. Click each top tab → the address bar hash updates (`#/world`, `#/hero`, `#/enemies/roster`, …).
2. On Enemies, click **Encounters** → hash becomes `#/enemies/encounters/1`; click **Ch 3** → `#/enemies/encounters/3`.
3. On Enemies → **Roster**, click an enemy (e.g. Romsarb `0x1C`) → hash becomes `#/enemies/roster/1c`; the right panel shows that enemy.
4. Paste `#/enemies/roster/1c` into a fresh tab (or edit the hash) → lands on Enemies/Roster with `0x1C` selected.
5. Refresh on `#/enemies/encounters/3` → returns to the same place.
6. Use the browser **Back/Forward** buttons → tab/sub/selection follow the history.
7. Enter a garbage hash `#/nonsense` → normalizes to `#/world`.

Confirm all 7 behave as described.

- [ ] **Step 6: Commit**

```bash
git add ui/src/routing/useAppRouting.ts ui/src/App.tsx
git commit -m "feat(ui): two-way URL hash routing for tabs + Enemies deep-links"
```

---

## Notes for the implementer

- **Why `store.subscribe` with no selector:** this project's Zustand store has no `subscribeWithSelector` middleware, so `subscribe` fires on every state change. That's fine here — the callback just recomputes a short string and compares; it writes the hash only on an actual change. Don't add middleware for this.
- **Loop safety:** writing `window.location.hash` fires `hashchange`, which calls `applyHashToStore`; but the store values already match the hash we just wrote, so its guarded setters do nothing and no further `subscribe` fires. Likewise a back/forward `hashchange` updates the store, the `subscribe` recomputes the same hash, and the equality check suppresses the write.
- **Async roster load:** a deep link like `#/enemies/roster/1c` sets `enemiesSelectedId` before the roster has loaded. `BattleRosterEditor` shows "Select an enemy" until `battleEnemies` arrives, then the selected panel resolves automatically — no extra wiring needed.
