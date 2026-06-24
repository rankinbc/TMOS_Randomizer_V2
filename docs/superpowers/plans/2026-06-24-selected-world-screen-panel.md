# Selected World Screen Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the docked World-tab screen sidebar with a floating "Selected World Screen" panel that surfaces all 16 worldscreen bytes in a Raw Data table and cross-links each byte into the relevant part of the app.

**Architecture:** Two new pure utils (`byteLabels.ts` for value→label/tier resolution, `screenLinks.ts` for the cross-link registry) drive a rewritten `ScreenDetailPanel` rendered as a floating card by `WorldView`. A new generic `focusTarget` mechanism in the zustand store lets a link switch tabs *and* land on the right section/item; the Allies/Enemies/Advanced views consume it on mount. The in-depth `ScreenEditorModal` is **not touched**.

**Tech Stack:** React 19 + TypeScript (strict), zustand 5, Tailwind CSS 4, Vitest (node env).

## Global Constraints

- **Do NOT modify `ScreenEditorModal.tsx`** — the tile editor stays exactly as-is. The panel's Edit button opens it via the existing `onEdit` callback.
- **No new backend endpoints.** All data already exists: `fieldMetadata` (store), `ScreenData` (chapter data), `api.getObjectSetEnemies`, `api.objectSetImageUrl`.
- **Vitest runs in `node` env and only includes `src/**/*.test.ts`** (see `vitest.config.ts`). Therefore: unit-test the pure utils and the store (all `.test.ts`, no DOM). Component files (`.tsx`) are verified by `npm run build` (tsc typecheck) + `npm run lint` + a manual checklist — matching the existing repo, which only unit-tests utils.
- **ROM byte order (0→15):** `parent_world, ambient_sound, content, objectset, screen_index_right, screen_index_left, screen_index_down, screen_index_up, datapointer, exit_position, top_tiles, bottom_tiles, worldscreen_color, sprites_color, unknown, event`.
- **Metadata key ↔ ScreenData key:** identical for all fields **except** the four nav bytes: `screen_index_right→nav_right`, `screen_index_left→nav_left`, `screen_index_down→nav_down`, `screen_index_up→nav_up`.
- All work is under `projects/TMOS_Randomizer_V2/ui/`. Run commands from that directory.
- Commit only the explicit paths each task lists (`git add <paths>`), never `git add -A` — this is a shared working tree with concurrent threads.

---

## File Structure

| File | Responsibility |
|---|---|
| `src/store/index.ts` (modify) | Add `FocusTarget` type + `focusTarget` state + `setFocusTarget`/`consumeFocusTarget`. |
| `src/store/index.test.ts` (create) | Unit-test the focus mechanism. |
| `src/components/screen/byteLabels.ts` (create) | Byte order, key mapping, `resolveByteLabel`, parent-world map. Pure. |
| `src/components/screen/byteLabels.test.ts` (create) | Unit tests for label resolution. |
| `src/components/screen/screenLinks.ts` (create) | `screenLinksFor` cross-link registry. Pure (takes an actions bundle). |
| `src/components/screen/screenLinks.test.ts` (create) | Unit tests for each byte's link target. |
| `src/components/screen/ScreenDetailPanel.tsx` (rewrite) | Floating panel: header, preview, nav grid, Raw Data table, detail/links box. |
| `src/components/views/WorldView.tsx` (modify) | Full-width map + floating-panel container + link-actions wiring. |
| `src/components/views/AlliesView.tsx` (modify) | Consume `focusTarget` → seed `selectedAlly`. |
| `src/components/views/EnemiesView.tsx` (modify) | Consume `focusTarget` → seed `section`. |
| `src/components/views/AdvancedView.tsx` (modify) | Consume `focusTarget` → seed `sub`. |

---

### Task 1: Store focus mechanism

**Files:**
- Modify: `src/store/index.ts`
- Test: `src/store/index.test.ts`

**Interfaces:**
- Produces: `interface FocusTarget { tab: TabType; section?: string; kind?: string; id?: number }`; store actions `setFocusTarget(t: FocusTarget): void` (sets `focusTarget` AND `selectedTab`) and `consumeFocusTarget(): FocusTarget | null` (returns then clears, one-shot); store field `focusTarget: FocusTarget | null`.

- [ ] **Step 1: Write the failing test**

Create `src/store/index.test.ts`:

```ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useRandomizerStore } from './index';

describe('focusTarget mechanism', () => {
  beforeEach(() => {
    useRandomizerStore.setState({ focusTarget: null, selectedTab: 'world' });
  });

  it('setFocusTarget stores the target and switches the active tab', () => {
    useRandomizerStore.getState().setFocusTarget({ tab: 'enemies', section: 'overworld' });
    const s = useRandomizerStore.getState();
    expect(s.selectedTab).toBe('enemies');
    expect(s.focusTarget).toEqual({ tab: 'enemies', section: 'overworld' });
  });

  it('consumeFocusTarget returns the target then clears it', () => {
    useRandomizerStore.getState().setFocusTarget({ tab: 'allies', kind: 'ally', id: 0x81 });
    const consumed = useRandomizerStore.getState().consumeFocusTarget();
    expect(consumed).toEqual({ tab: 'allies', kind: 'ally', id: 0x81 });
    expect(useRandomizerStore.getState().focusTarget).toBeNull();
  });

  it('consumeFocusTarget returns null when nothing is focused', () => {
    expect(useRandomizerStore.getState().consumeFocusTarget()).toBeNull();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test -- src/store/index.test.ts`
Expected: FAIL — `setFocusTarget is not a function`.

- [ ] **Step 3: Add the type, state, and actions**

In `src/store/index.ts`, after the `ViewMode` type (around line 43), add:

```ts
// Generic cross-view focus: a link sets this to switch tab AND land on a
// section/item. Destination views consume it once on mount/update.
export interface FocusTarget {
  tab: TabType;
  section?: string;  // destination view's local section/sub-tab id
  kind?: string;     // e.g. 'ally'
  id?: number;       // e.g. a content byte to resolve to an ally
}
```

In the `RandomizerState` interface, next to the other UI state (after `selectedScreen: number | null;`, ~line 90), add:

```ts
  focusTarget: FocusTarget | null;
```

In the actions section of the interface (after `setSelectedScreen: ...`, ~line 164), add:

```ts
  setFocusTarget: (target: FocusTarget) => void;
  consumeFocusTarget: () => FocusTarget | null;
```

In the initial-state object (after `selectedScreen: null,`, ~line 313), add:

```ts
  focusTarget: null,
```

In the actions implementation (after the `setSelectedScreen` impl, ~line 391), add:

```ts
  setFocusTarget: (target) => set({ focusTarget: target, selectedTab: target.tab }),

  consumeFocusTarget: () => {
    const target = get().focusTarget;
    if (target) set({ focusTarget: null });
    return target;
  },
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npm test -- src/store/index.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add src/store/index.ts src/store/index.test.ts
git commit -m "feat(world): add generic focusTarget store mechanism"
```

---

### Task 2: byteLabels util

**Files:**
- Create: `src/components/screen/byteLabels.ts`
- Test: `src/components/screen/byteLabels.test.ts`

**Interfaces:**
- Consumes: `ScreenData` (api/client), `FieldMetadata`/`SafetyTier` (types/metadata), `CONTENT_TYPES`/`CHAPTER_NPCS`/`EVENT_TYPES` (screenEnums).
- Produces:
  - `BYTE_FIELD_KEYS: readonly string[]` — the 16 metadata keys in ROM byte order.
  - `FIELD_TO_SCREEN_KEY: Record<string, keyof ScreenData>`.
  - `PARENT_WORLD_TYPES: Record<number, { name: string; color: string }>`.
  - `screenValueFor(screen: ScreenData, fieldKey: string): number`.
  - `parentWorldName(value: number): string | null`.
  - `resolveByteLabel(fieldKey: string, value: number, chapterNum: number, field?: FieldMetadata): { text: string; tier: SafetyTier }`.

- [ ] **Step 1: Write the failing test**

Create `src/components/screen/byteLabels.test.ts`:

```ts
import { describe, it, expect } from 'vitest';
import {
  resolveByteLabel,
  screenValueFor,
  parentWorldName,
  BYTE_FIELD_KEYS,
} from './byteLabels';
import type { ScreenData } from '../../api/client';
import type { FieldMetadata } from '../../types/metadata';

const baseScreen = {
  index: 1, global_index: 1, datapointer: 0, chr_index: 0,
  top_tiles: 0, bottom_tiles: 0, objectset: 0, parent_world: 0,
  ambient_sound: 0, event: 0, content: 0,
  nav_right: 0, nav_left: 0, nav_down: 0, nav_up: 0,
  worldscreen_color: 0, sprites_color: 0, exit_position: 0, unknown: 0,
} as ScreenData;

const numberField = (tier: FieldMetadata['tier']): FieldMetadata => ({
  label: 'x', byte: 0, tier, control: 'number', description: '',
});

describe('BYTE_FIELD_KEYS', () => {
  it('lists all 16 bytes in ROM order', () => {
    expect(BYTE_FIELD_KEYS).toHaveLength(16);
    expect(BYTE_FIELD_KEYS[0]).toBe('parent_world');
    expect(BYTE_FIELD_KEYS[4]).toBe('screen_index_right');
    expect(BYTE_FIELD_KEYS[15]).toBe('event');
  });
});

describe('screenValueFor', () => {
  it('maps nav metadata keys to nav_* ScreenData props', () => {
    const s = { ...baseScreen, nav_right: 0x2A };
    expect(screenValueFor(s, 'screen_index_right')).toBe(0x2A);
  });
  it('maps 1:1 keys directly', () => {
    const s = { ...baseScreen, objectset: 0x10 };
    expect(screenValueFor(s, 'objectset')).toBe(0x10);
  });
});

describe('resolveByteLabel', () => {
  it('decodes chapter-specific NPC content', () => {
    expect(resolveByteLabel('content', 0x81, 1).text).toBe('Faruk');
    expect(resolveByteLabel('content', 0x80, 2).text).toBe('Gun Meca');
  });
  it('decodes shop content via CONTENT_TYPES', () => {
    expect(resolveByteLabel('content', 0x60, 1).text).toBe('Shop');
  });
  it('decodes event names', () => {
    expect(resolveByteLabel('event', 0x40, 1).text).toBe('Stairway');
  });
  it('decodes nav bytes', () => {
    expect(resolveByteLabel('screen_index_right', 0xFF, 1).text).toBe('Blocked');
    expect(resolveByteLabel('screen_index_right', 0xFE, 1).text).toBe('Building');
    expect(resolveByteLabel('screen_index_right', 0x2A, 1).text).toBe('Screen 0x2A');
  });
  it('decodes parent_world exact then by high nibble', () => {
    expect(resolveByteLabel('parent_world', 0x10, 1).text).toBe('Town A');
    expect(resolveByteLabel('parent_world', 0x4A, 1).text).toBe('Overworld');
  });
  it('falls back to hex for plain number fields', () => {
    expect(resolveByteLabel('ambient_sound', 0x05, 1).text).toBe('0x05');
  });
  it('takes tier from the metadata field, defaulting to safe', () => {
    expect(resolveByteLabel('objectset', 0, 1, numberField('danger')).tier).toBe('danger');
    expect(resolveByteLabel('objectset', 0, 1).tier).toBe('safe');
  });
});

describe('parentWorldName', () => {
  it('resolves by high nibble when no exact match', () => {
    expect(parentWorldName(0x62)).toBe('Dungeon');
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test -- src/components/screen/byteLabels.test.ts`
Expected: FAIL — module `./byteLabels` not found.

- [ ] **Step 3: Write the implementation**

Create `src/components/screen/byteLabels.ts`:

```ts
import type { ScreenData } from '../../api/client';
import type { FieldMetadata, SafetyTier } from '../../types/metadata';
import { CONTENT_TYPES, CHAPTER_NPCS, EVENT_TYPES } from './screenEnums';

// The 16 worldscreen metadata field keys, in ROM byte order (byte 0 → 15).
export const BYTE_FIELD_KEYS = [
  'parent_world', 'ambient_sound', 'content', 'objectset',
  'screen_index_right', 'screen_index_left', 'screen_index_down', 'screen_index_up',
  'datapointer', 'exit_position', 'top_tiles', 'bottom_tiles',
  'worldscreen_color', 'sprites_color', 'unknown', 'event',
] as const;

// Metadata field key → ScreenData property. All identical except the nav bytes.
export const FIELD_TO_SCREEN_KEY: Record<string, keyof ScreenData> = {
  parent_world: 'parent_world',
  ambient_sound: 'ambient_sound',
  content: 'content',
  objectset: 'objectset',
  screen_index_right: 'nav_right',
  screen_index_left: 'nav_left',
  screen_index_down: 'nav_down',
  screen_index_up: 'nav_up',
  datapointer: 'datapointer',
  exit_position: 'exit_position',
  top_tiles: 'top_tiles',
  bottom_tiles: 'bottom_tiles',
  worldscreen_color: 'worldscreen_color',
  sprites_color: 'sprites_color',
  unknown: 'unknown',
  event: 'event',
};

// Parent world / section types (value can vary by chapter; high-nibble fallback).
export const PARENT_WORLD_TYPES: Record<number, { name: string; color: string }> = {
  0x00: { name: 'Overworld', color: '#22c55e' },
  0x10: { name: 'Town A', color: '#3b82f6' },
  0x20: { name: 'Town B', color: '#6366f1' },
  0x40: { name: 'Overworld', color: '#22c55e' },
  0x50: { name: 'Maze', color: '#f97316' },
  0x60: { name: 'Dungeon', color: '#a855f7' },
  0x70: { name: 'Special', color: '#eab308' },
  0x80: { name: 'Special', color: '#eab308' },
  0xA0: { name: 'Boss Area', color: '#ef4444' },
  0xAC: { name: 'Boss Area', color: '#ef4444' },
  0xC0: { name: 'Boss Area', color: '#ef4444' },
  0xE0: { name: 'Overworld', color: '#22c55e' },
};

const NAV_KEYS = new Set([
  'screen_index_right', 'screen_index_left', 'screen_index_down', 'screen_index_up',
]);

function hex(value: number): string {
  return value.toString(16).toUpperCase().padStart(2, '0');
}

export function screenValueFor(screen: ScreenData, fieldKey: string): number {
  const key = FIELD_TO_SCREEN_KEY[fieldKey];
  return (screen[key] as number) ?? 0;
}

export function parentWorldName(value: number): string | null {
  if (PARENT_WORLD_TYPES[value]) return PARENT_WORLD_TYPES[value].name;
  return PARENT_WORLD_TYPES[value & 0xF0]?.name ?? null;
}

function contentLabel(value: number, chapterNum: number): string | null {
  if (value >= 0x80 && value <= 0x9F) {
    return CHAPTER_NPCS[chapterNum]?.[value]?.name ?? `NPC 0x${hex(value)}`;
  }
  return CONTENT_TYPES[value]?.name ?? null;
}

function enumLabel(field: FieldMetadata | undefined, value: number): string | null {
  if (field?.control === 'enum' && field.enum) {
    return field.enum.find((o) => o.value === value)?.label ?? null;
  }
  return null;
}

export interface ByteLabel {
  text: string;
  tier: SafetyTier;
}

export function resolveByteLabel(
  fieldKey: string,
  value: number,
  chapterNum: number,
  field?: FieldMetadata,
): ByteLabel {
  const tier: SafetyTier = field?.tier ?? 'safe';
  let text: string;

  if (NAV_KEYS.has(fieldKey)) {
    text = value === 0xFF ? 'Blocked'
      : value === 0xFE ? 'Building'
      : `Screen 0x${hex(value)}`;
  } else if (fieldKey === 'content') {
    text = contentLabel(value, chapterNum) ?? enumLabel(field, value) ?? `0x${hex(value)}`;
  } else if (fieldKey === 'event') {
    text = EVENT_TYPES[value]?.name ?? enumLabel(field, value) ?? `0x${hex(value)}`;
  } else if (fieldKey === 'parent_world') {
    text = parentWorldName(value) ?? enumLabel(field, value) ?? `0x${hex(value)}`;
  } else {
    text = enumLabel(field, value) ?? `0x${hex(value)}`;
  }

  return { text, tier };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npm test -- src/components/screen/byteLabels.test.ts`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/components/screen/byteLabels.ts src/components/screen/byteLabels.test.ts
git commit -m "feat(world): add byteLabels worldscreen value->label util"
```

---

### Task 3: screenLinks cross-link registry

**Files:**
- Create: `src/components/screen/screenLinks.ts`
- Test: `src/components/screen/screenLinks.test.ts`

**Interfaces:**
- Consumes: `ScreenData` (api/client), `FocusTarget` (store, type-only).
- Produces:
  - `interface ScreenLinkActions { setFocusTarget(t: FocusTarget): void; navigateToTile(index: number): void; selectScreen(index: number): void; unlockExpert(): void }`.
  - `interface ScreenLink { label: string; note?: string; onActivate: () => void }`.
  - `screenLinksFor(fieldKey: string, value: number, screen: ScreenData, chapterNum: number, actions: ScreenLinkActions): ScreenLink[]`.

- [ ] **Step 1: Write the failing test**

Create `src/components/screen/screenLinks.test.ts`:

```ts
import { describe, it, expect, vi } from 'vitest';
import { screenLinksFor, type ScreenLinkActions } from './screenLinks';
import type { ScreenData } from '../../api/client';

const screen = { index: 5, content: 0x12 } as ScreenData;

function spies(): ScreenLinkActions {
  return {
    setFocusTarget: vi.fn(),
    navigateToTile: vi.fn(),
    selectScreen: vi.fn(),
    unlockExpert: vi.fn(),
  };
}

describe('screenLinksFor', () => {
  it('objectset → Enemies/Overworld', () => {
    const a = spies();
    screenLinksFor('objectset', 0x10, screen, 1, a)[0].onActivate();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'enemies', section: 'overworld' });
  });

  it('top_tiles → navigateToTile(value)', () => {
    const a = spies();
    screenLinksFor('top_tiles', 42, screen, 1, a)[0].onActivate();
    expect(a.navigateToTile).toHaveBeenCalledWith(42);
  });

  it('valid nav byte → selectScreen; blocked nav → no link', () => {
    const a = spies();
    screenLinksFor('screen_index_right', 0x2A, screen, 1, a)[0].onActivate();
    expect(a.selectScreen).toHaveBeenCalledWith(0x2A);
    expect(screenLinksFor('screen_index_right', 0xFF, screen, 1, a)).toHaveLength(0);
  });

  it('content NPC 0x81 → Allies tab with content byte as id', () => {
    const a = spies();
    screenLinksFor('content', 0x81, screen, 1, a)[0].onActivate();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'allies', kind: 'ally', id: 0x81 });
  });

  it('content shop 0x60 → unlock Expert + Economy, with note', () => {
    const a = spies();
    const link = screenLinksFor('content', 0x60, screen, 1, a)[0];
    expect(link.note).toBeTruthy();
    link.onActivate();
    expect(a.unlockExpert).toHaveBeenCalled();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'expert', section: 'economy' });
  });

  it('content boss stage 0x21 → Enemies/Bosses', () => {
    const a = spies();
    screenLinksFor('content', 0x21, screen, 1, a)[0].onActivate();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'enemies', section: 'bosses' });
  });

  it('event stairway 0x40 → selectScreen(content byte)', () => {
    const a = spies();
    screenLinksFor('event', 0x40, { ...screen, content: 0x33 } as ScreenData, 1, a)[0].onActivate();
    expect(a.selectScreen).toHaveBeenCalledWith(0x33);
  });

  it('palette byte → unlock Expert + Cosmetic', () => {
    const a = spies();
    screenLinksFor('worldscreen_color', 0x01, screen, 1, a)[0].onActivate();
    expect(a.unlockExpert).toHaveBeenCalled();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'expert', section: 'cosmetic' });
  });

  it('byte with no link → empty array', () => {
    expect(screenLinksFor('ambient_sound', 5, screen, 1, spies())).toHaveLength(0);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test -- src/components/screen/screenLinks.test.ts`
Expected: FAIL — module `./screenLinks` not found.

- [ ] **Step 3: Write the implementation**

Create `src/components/screen/screenLinks.ts`:

```ts
import type { ScreenData } from '../../api/client';
import type { FocusTarget } from '../../store';

// The store actions a link may invoke. Passed in so this module stays pure
// and unit-testable (no direct store/React dependency).
export interface ScreenLinkActions {
  setFocusTarget: (target: FocusTarget) => void;
  navigateToTile: (index: number) => void;
  selectScreen: (index: number) => void;
  unlockExpert: () => void;
}

export interface ScreenLink {
  label: string;
  note?: string;
  onActivate: () => void;
}

function hex(value: number): string {
  return value.toString(16).toUpperCase().padStart(2, '0');
}

function contentLinks(
  value: number,
  actions: ScreenLinkActions,
): ScreenLink[] {
  // NPC / ally range (a few are non-party NPCs; the Allies view resolves or
  // just opens the tab if no ally matches the content byte).
  if (value >= 0x80 && value <= 0x8F) {
    return [{
      label: 'View ally on Allies tab',
      onActivate: () => actions.setFocusTarget({ tab: 'allies', kind: 'ally', id: value }),
    }];
  }
  if (value === 0x7F) {
    return [{
      label: 'View Troopers on Allies tab',
      onActivate: () => actions.setFocusTarget({ tab: 'allies', kind: 'ally', id: 0x7F }),
    }];
  }
  if (value >= 0x21 && value <= 0x2A) {
    return [{
      label: 'View boss on Enemies → Bosses',
      onActivate: () => actions.setFocusTarget({ tab: 'enemies', section: 'bosses' }),
    }];
  }
  if (value >= 0x60 && value <= 0x7D) {
    return [{
      label: 'Open Economy & Shops',
      note: 'Per-screen shop inventory is not yet decoded (Bank 2 RE pending).',
      onActivate: () => {
        actions.unlockExpert();
        actions.setFocusTarget({ tab: 'expert', section: 'economy' });
      },
    }];
  }
  return [];
}

export function screenLinksFor(
  fieldKey: string,
  value: number,
  screen: ScreenData,
  _chapterNum: number,
  actions: ScreenLinkActions,
): ScreenLink[] {
  switch (fieldKey) {
    case 'objectset':
      return [{
        label: 'View Overworld enemies',
        onActivate: () => actions.setFocusTarget({ tab: 'enemies', section: 'overworld' }),
      }];

    case 'top_tiles':
    case 'bottom_tiles':
      return [{
        label: `Open TileSection 0x${hex(value)} in Graphics`,
        onActivate: () => actions.navigateToTile(value),
      }];

    case 'worldscreen_color':
    case 'sprites_color':
      return [{
        label: 'Edit palette in Advanced → Cosmetic',
        onActivate: () => {
          actions.unlockExpert();
          actions.setFocusTarget({ tab: 'expert', section: 'cosmetic' });
        },
      }];

    case 'screen_index_right':
    case 'screen_index_left':
    case 'screen_index_down':
    case 'screen_index_up':
      return value < 0xFE
        ? [{ label: `Go to Screen 0x${hex(value)}`, onActivate: () => actions.selectScreen(value) }]
        : [];

    case 'content':
      return contentLinks(value, actions);

    case 'event':
      return value === 0x40
        ? [{
            label: `Stairway → Screen 0x${hex(screen.content)}`,
            onActivate: () => actions.selectScreen(screen.content),
          }]
        : [];

    default:
      return [];
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npm test -- src/components/screen/screenLinks.test.ts`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/components/screen/screenLinks.ts src/components/screen/screenLinks.test.ts
git commit -m "feat(world): add screenLinks cross-link registry"
```

---

### Task 4: Rewrite ScreenDetailPanel as the floating panel

**Files:**
- Modify (full rewrite): `src/components/screen/ScreenDetailPanel.tsx`

**Interfaces:**
- Consumes: `byteLabels` (`BYTE_FIELD_KEYS`, `screenValueFor`, `resolveByteLabel`, `PARENT_WORLD_TYPES`), `screenLinks` (`screenLinksFor`, `ScreenLinkActions`), `tierStyle` (utils/safety), `useRandomizerStore` (for `fieldMetadata`), existing `ScreenRenderer`/`Tooltip`/`formatScreenId`.
- Produces: `ScreenDetailPanel` now requires a new `linkActions: ScreenLinkActions` prop (Task 6 supplies it). The objectset enemy sprite strip is added in Task 5; this task renders the panel without it.

> This is a full-file replacement. The new panel is a self-contained floating card (no outer width/border — its container in `WorldView` positions it). It keeps the existing `NavCell` and its helpers (`getContentInfo`, `getParentWorldInfo`, `getCategoryIcon`) for the spatial nav grid, and drops the now-unused `DataSection`/`DataRow`/`getCategoryBg`/`getEventInfo`/`getObjectSetDescription` and the local `PARENT_WORLD_TYPES` (now imported from `byteLabels`).

- [ ] **Step 1: Replace the file contents**

Overwrite `src/components/screen/ScreenDetailPanel.tsx` with:

```tsx
import { useState } from 'react';
import type { ScreenData } from '../../api/client';
import { ScreenRenderer } from './ScreenRenderer';
import { Tooltip } from '../shared/Tooltip';
import { formatScreenId } from '../../utils/formatters';
import { tierStyle } from '../../utils/safety';
import { useRandomizerStore } from '../../store';
import {
  BYTE_FIELD_KEYS,
  screenValueFor,
  resolveByteLabel,
  PARENT_WORLD_TYPES,
} from './byteLabels';
import { screenLinksFor, type ScreenLinkActions } from './screenLinks';
import { CONTENT_TYPES, CHAPTER_NPCS } from './screenEnums';

interface ScreenDetailPanelProps {
  screen: ScreenData;
  chapterNum: number;
  screens?: ScreenData[];
  onScreenSelect?: (index: number) => void;
  onEdit?: (half: 'top' | 'bottom') => void;
  onClose?: () => void;
  linkActions: ScreenLinkActions;
}

export function ScreenDetailPanel({
  screen, chapterNum, screens, onScreenSelect, onEdit, onClose, linkActions,
}: ScreenDetailPanelProps) {
  const [collapsed, setCollapsed] = useState(false);
  const [selectedKey, setSelectedKey] = useState<string | null>(null);
  const fieldMetadata = useRandomizerStore((s) => s.fieldMetadata);
  const fields = fieldMetadata?.entities.worldscreen?.fields ?? {};

  const screenId = formatScreenId(screen.index, screen.global_index, chapterNum);
  const isPast = screen.is_past ?? false;
  const timePeriod = isPast ? 'PAST' : 'PRESENT';

  const selectedField = selectedKey ? fields[selectedKey] : undefined;
  const selectedValue = selectedKey ? screenValueFor(screen, selectedKey) : 0;
  const selectedLabel = selectedKey
    ? resolveByteLabel(selectedKey, selectedValue, chapterNum, selectedField).text
    : '';
  const selectedLinks = selectedKey
    ? screenLinksFor(selectedKey, selectedValue, screen, chapterNum, linkActions)
    : [];

  return (
    <div className="w-[340px] max-h-[calc(100vh-7rem)] flex flex-col rounded-lg border border-slate-700 bg-slate-800/95 shadow-2xl backdrop-blur">
      {/* Header */}
      <div className="flex items-center justify-between gap-2 p-2.5 border-b border-slate-700 flex-shrink-0">
        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <h3 className="font-semibold text-slate-200 text-sm truncate">Screen {screenId.short}</h3>
            <span className={`px-1.5 py-0.5 rounded text-[10px] font-bold ${
              isPast ? 'bg-amber-500/20 text-amber-400' : 'bg-emerald-500/20 text-emerald-400'
            }`}>{timePeriod}</span>
          </div>
          <span className="text-[10px] text-slate-500 font-mono">{screenId.global}</span>
        </div>
        <div className="flex items-center gap-1 flex-shrink-0">
          <button
            onClick={() => onEdit?.('top')}
            className="px-2 py-1 text-xs rounded bg-blue-600 hover:bg-blue-500 text-white"
          >
            Edit
          </button>
          <button
            onClick={() => setCollapsed((c) => !c)}
            className="text-slate-400 hover:text-white px-1"
            title={collapsed ? 'Expand' : 'Collapse'}
          >
            {collapsed ? '▸' : '▾'}
          </button>
          {onClose && (
            <button onClick={onClose} className="text-slate-400 hover:text-white text-lg leading-none px-1">
              &times;
            </button>
          )}
        </div>
      </div>

      {!collapsed && (
        <div className="overflow-y-auto">
          {/* Preview */}
          <div className="p-3 flex justify-center bg-slate-900 border-b border-slate-700">
            <ScreenRenderer screen={screen} chapterNum={chapterNum} scale={0.5} showInfo={false} />
          </div>

          {/* Spatial nav grid */}
          <div className="p-3 border-b border-slate-700">
            <div className="grid grid-cols-3 gap-1.5 text-center">
              <div />
              <NavCell direction="Up" value={screen.nav_up} screens={screens} chapterNum={chapterNum} onScreenSelect={onScreenSelect} />
              <div />
              <NavCell direction="Left" value={screen.nav_left} screens={screens} chapterNum={chapterNum} onScreenSelect={onScreenSelect} />
              <div className="bg-blue-500/20 rounded p-2 text-[10px] text-blue-300 font-mono flex items-center justify-center">
                {screenId.compact}
              </div>
              <NavCell direction="Right" value={screen.nav_right} screens={screens} chapterNum={chapterNum} onScreenSelect={onScreenSelect} />
              <div />
              <NavCell direction="Down" value={screen.nav_down} screens={screens} chapterNum={chapterNum} onScreenSelect={onScreenSelect} />
              <div />
            </div>
          </div>

          {/* Raw Data table */}
          <table className="w-full text-xs">
            <thead>
              <tr className="text-slate-500 text-[10px] uppercase tracking-wide">
                <th className="text-left font-medium px-3 py-1.5">Field</th>
                <th className="text-right font-medium px-1 py-1.5">Hex</th>
                <th className="text-left font-medium px-3 py-1.5">Label</th>
              </tr>
            </thead>
            <tbody>
              {BYTE_FIELD_KEYS.map((key) => {
                const field = fields[key];
                const value = screenValueFor(screen, key);
                const { text, tier } = resolveByteLabel(key, value, chapterNum, field);
                const isSel = selectedKey === key;
                return (
                  <tr
                    key={key}
                    onClick={() => setSelectedKey(isSel ? null : key)}
                    className={`cursor-pointer border-t border-slate-700/50 ${
                      isSel ? 'bg-blue-500/15' : 'hover:bg-slate-700/40'
                    }`}
                  >
                    <td className="px-3 py-1.5 text-slate-300">
                      <span className="inline-flex items-center gap-1.5">
                        <span className={`w-1.5 h-1.5 rounded-full ${tierStyle(tier).dot}`} />
                        {field?.label ?? key}
                      </span>
                    </td>
                    <td className="px-1 py-1.5 text-right font-mono text-slate-400">
                      0x{value.toString(16).toUpperCase().padStart(2, '0')}
                    </td>
                    <td className="px-3 py-1.5 text-slate-200 truncate max-w-[140px]">{text}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>

          {/* Detail / links box */}
          {selectedKey && (
            <div className="m-3 rounded-lg border border-slate-700 bg-slate-900 p-3 space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm font-semibold text-slate-200">{selectedField?.label ?? selectedKey}</span>
                <span className="font-mono text-xs text-slate-400">
                  0x{selectedValue.toString(16).toUpperCase().padStart(2, '0')} ({selectedValue})
                </span>
              </div>
              <div className="text-xs text-slate-300">{selectedLabel}</div>
              {selectedField?.description && (
                <p className="text-xs text-slate-400">{selectedField.description}</p>
              )}
              {selectedField?.warning && (
                <p className="text-xs text-amber-400">{'⚠'} {selectedField.warning}</p>
              )}
              {selectedField?.used_by && selectedField.used_by.length > 0 && (
                <p className="text-[10px] text-slate-500">Used by: {selectedField.used_by.join(', ')}</p>
              )}
              {selectedLinks.length > 0 && (
                <div className="space-y-1 pt-1">
                  {selectedLinks.map((link, i) => (
                    <div key={i}>
                      <button
                        onClick={link.onActivate}
                        className="text-xs text-blue-400 hover:text-blue-300 underline"
                      >
                        {link.label} {'→'}
                      </button>
                      {link.note && <p className="text-[10px] text-slate-500">{link.note}</p>}
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function getContentInfo(content: number, chapterNum: number): { name: string; category: string } | null {
  if (content >= 0x80 && content <= 0x9F) {
    const chapterNpcs = CHAPTER_NPCS[chapterNum];
    if (chapterNpcs?.[content]) return { ...chapterNpcs[content], category: 'npc' };
    return { name: `NPC 0x${content.toString(16).toUpperCase()}`, category: 'npc' };
  }
  if (content >= 0xA0 && content <= 0xB0) {
    return CONTENT_TYPES[content] || { name: 'Hotel', category: 'hotel' };
  }
  return CONTENT_TYPES[content] || null;
}

function getParentWorldInfo(parentWorld: number): { name: string; color: string } | null {
  if (PARENT_WORLD_TYPES[parentWorld]) return PARENT_WORLD_TYPES[parentWorld];
  return PARENT_WORLD_TYPES[parentWorld & 0xF0] || null;
}

function getCategoryIcon(category: string): string {
  const icons: Record<string, string> = {
    'shop': '\u{1F3EA}', 'magic-shop': '✨', 'mosque': '\u{1F54C}', 'hotel': '\u{1F3E8}',
    'university': '\u{1F393}', 'boss': '\u{1F479}', 'battle': '⚔️', 'npc': '\u{1F464}',
    'special': '⭐', 'time-door': '\u{1F6AA}', 'service': '\u{1F6CE}️',
  };
  return icons[category] || '\u{1F4CD}';
}

interface NavCellProps {
  direction: string;
  value: number;
  screens?: ScreenData[];
  chapterNum?: number;
  onScreenSelect?: (index: number) => void;
}

function NavCell({ direction, value, screens, chapterNum, onScreenSelect }: NavCellProps) {
  const isBlocked = value === 0xFF;
  const isBuilding = value === 0xFE;
  const isValid = !isBlocked && !isBuilding;

  const destScreen = isValid && screens ? screens.find((s) => s.index === value) : null;
  const destScreenId = destScreen
    ? formatScreenId(destScreen.index, destScreen.global_index, chapterNum)
    : isValid
    ? formatScreenId(value, value)
    : null;
  const destContentInfo = destScreen ? getContentInfo(destScreen.content, chapterNum ?? 1) : null;
  const destParentInfo = destScreen ? getParentWorldInfo(destScreen.parent_world) : null;

  let bgColor = 'bg-slate-700';
  let textColor = 'text-slate-300';
  let displayValue: string;

  if (isBlocked) {
    bgColor = 'bg-red-500/20'; textColor = 'text-red-400'; displayValue = '✕';
  } else if (isBuilding) {
    bgColor = 'bg-amber-500/20'; textColor = 'text-amber-400'; displayValue = '\u{1F3E0}';
  } else {
    bgColor = 'bg-green-500/20'; textColor = 'text-green-400';
    displayValue = destScreenId?.compact ?? value.toString();
  }

  const isClickable = isValid && onScreenSelect;

  const tooltipContent = isBlocked ? (
    <span>Blocked (no exit)</span>
  ) : isBuilding ? (
    <div>
      <div className="font-medium">Building Entrance</div>
      <div className="text-slate-400 text-xs">Enter building interior</div>
    </div>
  ) : destScreen ? (
    <div className="space-y-1">
      <div className="font-medium">Screen {destScreenId?.short}</div>
      <div className="text-slate-400 text-xs">{destScreenId?.global}</div>
      {destParentInfo && (
        <div className="flex items-center gap-1.5 text-xs">
          <div className="w-2 h-2 rounded" style={{ backgroundColor: destParentInfo.color }} />
          <span className="text-slate-300">{destParentInfo.name}</span>
        </div>
      )}
      {destContentInfo && (
        <div className="text-xs text-slate-300">
          {getCategoryIcon(destContentInfo.category)} {destContentInfo.name}
        </div>
      )}
      {isClickable && <div className="text-xs text-blue-400 mt-1">Click to navigate</div>}
    </div>
  ) : (
    <span>Screen {destScreenId?.short}</span>
  );

  const cell = (
    <div
      className={`${bgColor} rounded p-2 transition-all ${
        isClickable ? 'cursor-pointer hover:ring-2 hover:ring-blue-400' : ''
      }`}
      onClick={isClickable ? () => onScreenSelect(value) : undefined}
    >
      <div className="text-[10px] text-slate-500 mb-0.5">{direction}</div>
      <div className={`${textColor} font-mono text-xs`}>{displayValue}</div>
    </div>
  );

  return (
    <Tooltip content={tooltipContent} position="top" delay={150}>
      {cell}
    </Tooltip>
  );
}
```

- [ ] **Step 2: Typecheck (the panel now requires `linkActions`, so the build fails until Task 6 wires it — that is expected here; verify only that the new file itself has no internal type errors)**

Run: `npx tsc -b --noEmit`
Expected: The ONLY errors are in `WorldView.tsx` (missing `linkActions` prop on `<ScreenDetailPanel>`). No errors inside `ScreenDetailPanel.tsx`, `byteLabels.ts`, or `screenLinks.ts`. If any error points into those files, fix it before continuing.

- [ ] **Step 3: Run the util + store tests to confirm no regressions**

Run: `npm test`
Expected: PASS (Tasks 1–3 suites green).

- [ ] **Step 4: Commit**

```bash
git add src/components/screen/ScreenDetailPanel.tsx
git commit -m "feat(world): rewrite ScreenDetailPanel as floating panel with raw-byte table"
```

---

### Task 5: ObjectSet enemy sprite strip in the detail box

**Files:**
- Modify: `src/components/screen/ScreenDetailPanel.tsx`

**Interfaces:**
- Consumes: `api` and `ObjectSetEnemy` from `../../api/client` (`api.getObjectSetEnemies(chapterNum, objectset)`, `api.objectSetImageUrl(file)`).
- Produces: an internal `ObjectSetEnemyStrip` component rendered inside the detail box when the selected byte is `objectset`.

- [ ] **Step 1: Add the imports**

In `ScreenDetailPanel.tsx`, update the client import line:

```tsx
import type { ScreenData } from '../../api/client';
```

to:

```tsx
import { api, type ScreenData, type ObjectSetEnemy } from '../../api/client';
```

and add `useEffect` to the React import:

```tsx
import { useEffect, useState } from 'react';
```

- [ ] **Step 2: Render the strip in the detail box**

In the detail/links box, immediately **before** the `{selectedLinks.length > 0 && (` block, add:

```tsx
              {selectedKey === 'objectset' && (
                <ObjectSetEnemyStrip chapterNum={chapterNum} objectset={selectedValue} />
              )}
```

- [ ] **Step 3: Add the component**

Add this component at the end of the file (after `NavCell`):

```tsx
function ObjectSetEnemyStrip({ chapterNum, objectset }: { chapterNum: number; objectset: number }) {
  const [enemies, setEnemies] = useState<ObjectSetEnemy[] | null>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    let active = true;
    setEnemies(null);
    setFailed(false);
    api.getObjectSetEnemies(chapterNum, objectset)
      .then((r) => { if (active) setEnemies(r.enemies); })
      .catch(() => { if (active) setFailed(true); });
    return () => { active = false; };
  }, [chapterNum, objectset]);

  if (failed) return <p className="text-[10px] text-slate-500">Enemy set unavailable.</p>;
  if (!enemies) return <p className="text-[10px] text-slate-500">Loading enemies{'…'}</p>;
  if (enemies.length === 0) return <p className="text-[10px] text-slate-500">No enemies in this set.</p>;

  return (
    <div className="flex flex-wrap gap-1.5">
      {enemies.map((enemy, i) => (
        <div key={i} className="flex flex-col items-center w-12">
          {enemy.image ? (
            <img
              src={api.objectSetImageUrl(enemy.image)}
              alt={enemy.name}
              className="w-8 h-8 object-contain"
              style={{ imageRendering: 'pixelated' }}
            />
          ) : (
            <div className="w-8 h-8 bg-slate-700 rounded" />
          )}
          <span className="text-[9px] text-slate-400 truncate w-full text-center">{enemy.name}</span>
        </div>
      ))}
    </div>
  );
}
```

- [ ] **Step 4: Typecheck**

Run: `npx tsc -b --noEmit`
Expected: Same as Task 4 — only the `WorldView.tsx` missing-`linkActions` error remains; no errors inside `ScreenDetailPanel.tsx`.

- [ ] **Step 5: Commit**

```bash
git add src/components/screen/ScreenDetailPanel.tsx
git commit -m "feat(world): show objectset enemy sprite strip in panel detail box"
```

---

### Task 6: Float the panel in WorldView + wire link actions

**Files:**
- Modify: `src/components/views/WorldView.tsx`

**Interfaces:**
- Consumes: `ScreenLinkActions` (screenLinks), store actions `setFocusTarget`/`navigateToTile`/`unlockExpert`/`setSelectedScreen`.
- Produces: a full-width map with the panel floating top-right; supplies the `linkActions` prop the panel now requires. This is the task that makes the build green again.

- [ ] **Step 1: Add imports**

At the top of `WorldView.tsx`, add to the React import and add a `ScreenLinkActions` type import:

```tsx
import { useState, useCallback, useEffect, useMemo } from 'react';
```
(already present — leave as-is)

Add:

```tsx
import type { ScreenLinkActions } from '../screen/screenLinks';
```

- [ ] **Step 2: Pull the new store actions**

In the `useRandomizerStore()` destructure (the `const { ... } = useRandomizerStore();` block), add these three:

```tsx
    setFocusTarget,
    navigateToTile,
    unlockExpert,
```

- [ ] **Step 3: Build the link-actions bundle**

After the `editorScreen` memo (around line 35), add:

```tsx
  const linkActions: ScreenLinkActions = useMemo(() => ({
    setFocusTarget,
    navigateToTile,
    unlockExpert,
    selectScreen: setSelectedScreen,
  }), [setFocusTarget, navigateToTile, unlockExpert, setSelectedScreen]);
```

- [ ] **Step 4: Replace the layout JSX**

Replace the entire `return (...)` block (currently the `<div className="flex h-full">...`, lines ~64–132) with:

```tsx
  return (
    <div className="relative h-full">
      <div className="absolute inset-0 overflow-hidden">
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
        <div className="absolute top-3 right-3 z-20">
          <ScreenDetailPanel
            screen={selectedScreenData}
            chapterNum={chapterData.chapter_num}
            screens={screens}
            onScreenSelect={setSelectedScreen}
            onEdit={(half) => openEditor(selectedScreen!, half)}
            onClose={() => setSelectedScreen(null)}
            linkActions={linkActions}
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
          vanilla={
            screenVanilla && screenVanilla.index === editor.index ? screenVanilla : null
          }
          onFieldChange={(field, value) => {
            updateScreenFields(editor.index, { [field]: value }).catch(() => {});
          }}
          onTilePick={(which, globalIndex) => {
            updateScreenTiles(
              editor.index,
              which === 'top' ? { top_tiles: globalIndex } : { bottom_tiles: globalIndex },
            ).catch(() => {});
          }}
        />
      )}
    </div>
  );
```

(The `<ScreenEditorModal>` block is unchanged from the original — it is repeated here only because the wrapping element changed from `flex` to `relative`.)

- [ ] **Step 5: Typecheck + build**

Run: `npx tsc -b --noEmit && npm run build`
Expected: PASS — no type errors. The build now succeeds because `linkActions` is supplied.

- [ ] **Step 6: Lint**

Run: `npm run lint`
Expected: No new errors in `WorldView.tsx` or `ScreenDetailPanel.tsx`.

- [ ] **Step 7: Commit**

```bash
git add src/components/views/WorldView.tsx
git commit -m "feat(world): float Selected World Screen panel over full-width map"
```

---

### Task 7: AlliesView consumes focusTarget

**Files:**
- Modify: `src/components/views/AlliesView.tsx`

**Interfaces:**
- Consumes: store `focusTarget` + `consumeFocusTarget`. Resolves `focusTarget.id` (a content byte) + `selectedChapter` → an entry in the local `KNOWN_ALLIES` and seeds `selectedAlly`.

- [ ] **Step 1: Add the effect import**

Update the React import:

```tsx
import { useState, useMemo, useEffect } from 'react';
```

- [ ] **Step 2: Read the focus state and consume it**

Inside `AlliesView`, replace:

```tsx
  const [selectedAlly, setSelectedAlly] = useState<AllyData | null>(null);
  const [showAllChapters, setShowAllChapters] = useState(false);
  const { chapterData, selectedChapter } = useRandomizerStore();
```

with:

```tsx
  const [selectedAlly, setSelectedAlly] = useState<AllyData | null>(null);
  const [showAllChapters, setShowAllChapters] = useState(false);
  const { chapterData, selectedChapter } = useRandomizerStore();
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  // Deep-link: a World-panel content link asks us to select a specific ally,
  // identified by its content byte (focusTarget.id) within the current chapter.
  useEffect(() => {
    if (focusTarget?.tab === 'allies' && focusTarget.kind === 'ally' && focusTarget.id != null) {
      const ally = KNOWN_ALLIES.find(
        (a) => a.contentByte === focusTarget.id && a.chapter === selectedChapter,
      );
      if (ally) setSelectedAlly(ally);
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget, selectedChapter]);
```

- [ ] **Step 3: Typecheck**

Run: `npx tsc -b --noEmit`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add src/components/views/AlliesView.tsx
git commit -m "feat(world): AlliesView lands on the linked ally from the screen panel"
```

---

### Task 8: EnemiesView consumes focusTarget

**Files:**
- Modify: `src/components/views/EnemiesView.tsx`

**Interfaces:**
- Consumes: store `focusTarget` + `consumeFocusTarget`. Maps `focusTarget.section` (`'overworld'` / `'bosses'`) onto the local `EnemiesSection` state.

- [ ] **Step 1: Read the focus state and consume it**

Inside `EnemiesView`, after the existing `const [section, setSection] = useState<EnemiesSection>('roster');` and `const [selectedChapter, setSelectedChapter] = useState(1);` lines, add:

```tsx
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  // Deep-link: a World-panel link (objectset / boss content) asks us to open a
  // specific section.
  useEffect(() => {
    if (focusTarget?.tab === 'enemies' && focusTarget.section) {
      const target = focusTarget.section as EnemiesSection;
      if (SECTIONS.some((s) => s.id === target)) setSection(target);
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget]);
```

(`useEffect` is already imported in this file.)

- [ ] **Step 2: Typecheck**

Run: `npx tsc -b --noEmit`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add src/components/views/EnemiesView.tsx
git commit -m "feat(world): EnemiesView opens the linked section from the screen panel"
```

---

### Task 9: AdvancedView consumes focusTarget

**Files:**
- Modify: `src/components/views/AdvancedView.tsx`

**Interfaces:**
- Consumes: store `focusTarget` + `consumeFocusTarget`. Maps `focusTarget.section` (`'economy'` / `'cosmetic'`) onto the local `SubTabId` state. (Palette/economy links also call `unlockExpert()` so `ExpertView` renders this view.)

- [ ] **Step 1: Add imports**

Update the React import and add the store import:

```tsx
import { useEffect, useState } from 'react';
import { useRandomizerStore } from '../../store';
```

- [ ] **Step 2: Read the focus state and consume it**

Inside `AdvancedView`, replace:

```tsx
  const [sub, setSub] = useState<SubTabId>('progression');
```

with:

```tsx
  const [sub, setSub] = useState<SubTabId>('progression');
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  // Deep-link: a World-panel palette/shop link asks us to open a specific
  // sub-tab. (focusTarget.tab is 'expert' since this view lives under ExpertView.)
  useEffect(() => {
    if (focusTarget?.tab === 'expert' && focusTarget.section) {
      const target = focusTarget.section as SubTabId;
      if (SUB_TABS.some((t) => t.id === target)) setSub(target);
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget]);
```

- [ ] **Step 3: Typecheck**

Run: `npx tsc -b --noEmit`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add src/components/views/AdvancedView.tsx
git commit -m "feat(world): AdvancedView opens the linked sub-tab from the screen panel"
```

---

### Task 10: Full verification

**Files:** none (verification only).

- [ ] **Step 1: Full typecheck + build + lint + tests**

Run:
```bash
npx tsc -b --noEmit && npm run build && npm run lint && npm test
```
Expected: all green; util + store test suites pass.

- [ ] **Step 2: Manual smoke test**

Start the backend (`tmos-randomize serve` from the repo) and `npm run dev`, load the default ROM, open the **World** tab, select a screen, and verify:

1. The panel **floats** top-right over a now **full-width** map; collapse chevron hides the body; `×` closes it; **Edit** opens the unchanged `ScreenEditorModal`.
2. The **Raw Data table** shows **16 rows** in ROM order with correct hex values, decoded labels, and a tier dot per row.
3. Clicking a row opens the **detail/links box** with description, warning, used-by, and the decoded value.
4. Cross-links land correctly:
   - `objectset` row → shows the enemy sprite strip + "View Overworld enemies" jumps to Enemies → Overworld.
   - `content` on an NPC screen (e.g. 0x81) → Allies tab with that ally selected.
   - `content` on a boss-stage screen → Enemies → Bosses.
   - `content` on a shop screen → Expert unlocks, Economy & Shops opens (with the "not decoded" note).
   - `top_tiles` / `bottom_tiles` → Graphics tab on that tile section.
   - palette rows → Expert → Cosmetic.
   - a valid nav row, and the spatial grid cells → navigate within the World view (panel updates to the new screen).
5. Selecting a different screen resets the selected row/detail box.

- [ ] **Step 3: Final commit (if the manual pass required tweaks)**

```bash
git add src/components/screen/ScreenDetailPanel.tsx src/components/views/WorldView.tsx
git commit -m "fix(world): polish Selected World Screen panel after manual QA"
```

---

## Self-Review Notes

- **Spec coverage:** floating top-right + collapse (Task 4/6) ✔; all 16 bytes in Raw Data table (Task 4, `BYTE_FIELD_KEYS`) ✔; click-row detail/links box (Task 4) ✔; full cross-link registry incl. shops/exp honest notes (Task 3) ✔; objectset sprite strip (Task 5) ✔; generic `focusTarget` backbone + consumers (Tasks 1,7,8,9) ✔; `ScreenEditorModal` untouched ✔; no new backend endpoints ✔.
- **Key mapping** (`screen_index_* ↔ nav_*`) is centralized in `FIELD_TO_SCREEN_KEY` and unit-tested.
- **Type consistency:** `ScreenLinkActions` is defined once (screenLinks.ts) and imported by WorldView; `FocusTarget` is defined once (store) and imported by screenLinks (type-only) and the consumer views; `resolveByteLabel`/`screenValueFor`/`screenLinksFor` signatures match their call sites in the panel.
- **Honest gaps:** shop-inventory and per-screen EXP mappings are undecoded — their links open the relevant panel with a note rather than fabricating data.
