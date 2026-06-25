# Tile-Section Theme Filter & Coherent Swap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Classify the 471 tile sections into 5 biomes and add a soft theme filter + a same-biome "coherent swap" to the Edit-modal tile picker, composing with the Spec #2 collision filter.

**Architecture:** A new cacheable backend endpoint classifies each section's biome from the plurality SectionType of screens that use it (reverse index over all 739 screens) with a tile-ID content tiebreaker. The frontend fetches it once and uses a pure util to (a) sort the picker by a `[offTheme, collisionMismatch, globalIndex]` composite key and (b) constrain the existing `suggestPairs` to same-biome candidates.

**Tech Stack:** FastAPI + Python (backend, pytest), React 19 + TypeScript + Tailwind + zustand (frontend), Vitest (node env).

## Global Constraints

- 5 biomes only: `overworld · town · dungeon · maze · special`. SectionType collapse: OVERWORLD→overworld, TOWN→town, DUNGEON/MINI_DUNGEON→dungeon, MAZE→maze, SPECIAL/BOSS/VICTORY/UNKNOWN→special.
- Theme is a **reference classification** computed once from the as-loaded ROM; cached server-side on `id(_rom_data)` (mirrors the Spec #2 walkability cache). Endpoint returns `{ "themes": { "0": "<biome>", ... } }` (471 entries).
- Reuse existing primitives: `SectionType`/`PARENTWORLD_TO_SECTION` (`core/enums.py`), `WorldScreen.section_type`, `get_bank_offset`/`read_tilesection`/`get_tilesection_grid` (`validation/tiles/edges.py`), `COLLIDABLE_TILES`/`DEADLY_TILES` (`validation/tiles/categories.py`). NO `TMOS_World_Editor` import.
- Section global index `0..470` is bank-encoded: `global = byte + bank_offset` where `get_bank_offset(datapointer) -> (top_off, bottom_off)` returns 0 or 256. `TILESECTION_COUNT = 471` (`core/constants.py`).
- **Soft, never-hide** UI (consistent with Spec #2): off-theme sections are dimmed and sorted last, never removed. Theme = `all` ⇒ behavior is identical to Spec #2.
- Do NOT change the Spec #2 collision filter's behavior; theme composes with it. The "coherent swap" reuses `suggestPairs` constrained to same-biome candidates and applies via the existing atomic `onPickPair`.
- Backend pytest must run with `PYTHONPATH` set to the worktree src (package is editable-installed against the main tree). Frontend: Vitest is node-env, unit-tests only pure `.test.ts` utils; `.tsx` verified by `tsc`/lint/manual.
- Shared working tree: commit **explicit paths only**, never `git add -A`. Run frontend cmds from `projects/TMOS_Randomizer_V2/ui`, backend from `projects/TMOS_Randomizer_V2`.

---

## File Structure

| File | Responsibility |
|---|---|
| `src/tmos_randomizer/validation/tiles/themes.py` (create) | `section_type_to_biome`, `tile_biome`, `score_tilesection_biome`, `compute_section_themes`. |
| `tests/test_tilesection_themes.py` (create) | Backend unit + endpoint tests. |
| `src/tmos_randomizer/api/server.py` (modify) | `GET /api/rom/tilesection-themes` (cached). |
| `ui/src/components/screen/tileFilter.ts` (modify) | Extend `suggestPairs` with an optional `candidates` filter. |
| `ui/src/components/screen/themeFilter.ts` (create) | `offTheme`, `coherentPairCandidates`, biome types/options. |
| `ui/src/components/screen/themeFilter.test.ts` (create) | Unit tests for the theme util + candidates. |
| `ui/src/api/client.ts` (modify) | `getTileSectionThemes()` + response type. |
| `ui/src/store/index.ts` (modify) | `tileThemes` state + lazy `loadTileThemes()`. |
| `ui/src/components/screen/ScreenEditorModal.tsx` (modify) | Theme dropdown, composite ordering, biome tags, coherent-swap button. |

---

### Task 1: Backend theme classifier

**Files:**
- Create: `projects/TMOS_Randomizer_V2/src/tmos_randomizer/validation/tiles/themes.py`
- Test: `projects/TMOS_Randomizer_V2/tests/test_tilesection_themes.py`

**Interfaces:**
- Consumes: `SectionType` (`...core.enums`), `TILESECTION_COUNT` (`...core.constants`), `get_bank_offset`/`read_tilesection`/`get_tilesection_grid` (`.edges`), `COLLIDABLE_TILES`/`DEADLY_TILES` (`.categories`).
- Produces: `BIOMES: tuple[str, ...]`; `section_type_to_biome(st) -> str`; `tile_biome(tile_id: int) -> str | None`; `score_tilesection_biome(tile_ids) -> str`; `compute_section_themes(game_world, rom_data) -> dict[str, str]` (keys `"0".."470"`, values in `BIOMES`).

- [ ] **Step 1: Write the failing test**

Create `projects/TMOS_Randomizer_V2/tests/test_tilesection_themes.py`:

```python
from types import SimpleNamespace

from tmos_randomizer.core.enums import SectionType
from tmos_randomizer.validation.tiles.edges import TILESECTION_BASE
from tmos_randomizer.core.constants import TILESECTION_COUNT
from tmos_randomizer.validation.tiles.themes import (
    BIOMES,
    section_type_to_biome,
    tile_biome,
    score_tilesection_biome,
    compute_section_themes,
)


def test_section_type_collapse():
    assert section_type_to_biome(SectionType.OVERWORLD) == "overworld"
    assert section_type_to_biome(SectionType.TOWN) == "town"
    assert section_type_to_biome(SectionType.DUNGEON) == "dungeon"
    assert section_type_to_biome(SectionType.MINI_DUNGEON) == "dungeon"
    assert section_type_to_biome(SectionType.MAZE) == "maze"
    assert section_type_to_biome(SectionType.SPECIAL) == "special"
    assert section_type_to_biome(SectionType.BOSS) == "special"
    assert section_type_to_biome(SectionType.UNKNOWN) == "special"


def test_tile_biome_buckets():
    assert tile_biome(0x00) == "maze"      # maze wall
    assert tile_biome(0x53) == "dungeon"   # dungeon wall
    assert tile_biome(0x86) == "town"      # building wall
    assert tile_biome(0x46) == "overworld" # grass
    assert tile_biome(0x3F) == "special"   # deep water (deadly)
    assert tile_biome(0x4F) == "special"   # dark world
    assert tile_biome(0x5F) is None        # walkable dungeon floor → uncategorized


def test_score_tilesection_biome():
    assert score_tilesection_biome([0x53] * 32) == "dungeon"
    assert score_tilesection_biome([0x46] * 32) == "overworld"
    assert score_tilesection_biome([0x86] * 32) == "town"
    assert score_tilesection_biome([0x5F] * 32) == "special"  # no categorized tiles → special


def _fake_rom() -> bytes:
    size = TILESECTION_BASE + TILESECTION_COUNT * 32 + 32
    rom = bytearray(size)
    # section 7 (unused by screens below) → all dungeon-wall tiles
    for i in range(32):
        rom[TILESECTION_BASE + 7 * 32 + i] = 0x53
    return bytes(rom)


def _screen(dp, top, bot, st):
    return SimpleNamespace(datapointer=dp, top_tiles=top, bottom_tiles=bot, section_type=st)


def test_compute_section_themes_votes_and_fallback():
    # dp 0x00 → bank offsets (0, 0); top_global=5, bottom_global=6
    game_world = [[_screen(0x00, 5, 6, SectionType.OVERWORLD)]]
    themes = compute_section_themes(game_world, _fake_rom())
    assert len(themes) == TILESECTION_COUNT
    assert themes["5"] == "overworld"   # voted
    assert themes["6"] == "overworld"   # voted
    assert themes["7"] == "dungeon"     # unused → tile-ID score
    assert set(themes.values()) <= set(BIOMES)
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd projects/TMOS_Randomizer_V2 && PYTHONPATH=src python -m pytest tests/test_tilesection_themes.py -v
```
Expected: FAIL — `ModuleNotFoundError: ...validation.tiles.themes`.

- [ ] **Step 3: Implement the classifier**

Create `projects/TMOS_Randomizer_V2/src/tmos_randomizer/validation/tiles/themes.py`:

```python
"""Biome/theme classification for TileSections.

A section's biome is derived from how the ROM uses it: the plurality SectionType
of the screens that reference it (as top or bottom), with a tile-ID content score
as the tiebreaker for unused or tied sections. 5 biomes:
overworld, town, dungeon, maze, special.
"""

from __future__ import annotations

from collections import Counter, defaultdict

from ...core.enums import SectionType
from ...core.constants import TILESECTION_COUNT
from .edges import get_bank_offset, read_tilesection, get_tilesection_grid
from .categories import COLLIDABLE_TILES, DEADLY_TILES

BIOMES: tuple[str, ...] = ("overworld", "town", "dungeon", "maze", "special")

_SECTIONTYPE_BIOME = {
    SectionType.OVERWORLD: "overworld",
    SectionType.TOWN: "town",
    SectionType.DUNGEON: "dungeon",
    SectionType.MINI_DUNGEON: "dungeon",
    SectionType.MAZE: "maze",
    SectionType.SPECIAL: "special",
    SectionType.BOSS: "special",
    SectionType.VICTORY: "special",
    SectionType.UNKNOWN: "special",
}

# Hazard / dark-world / underwater tiles read as "special" regardless of range.
_DARK_WORLD = frozenset({0x4C, 0x4F, 0x50, 0x51, 0x52, 0xCB, 0xCC})
_UNDERWATER = frozenset({0xDE, 0xF6, 0xF7, 0xF8, 0xF9})
# Nature/grass tiles that are walkable (not in COLLIDABLE_TILES) but signal overworld.
_NATURE = frozenset({0x22, 0x23, 0x47, 0x43, 0x46})


def section_type_to_biome(section_type: SectionType) -> str:
    return _SECTIONTYPE_BIOME.get(section_type, "special")


def tile_biome(tile_id: int) -> str | None:
    """Biome a single tile ID signals, or None if it carries no biome signal."""
    if tile_id in DEADLY_TILES:               # water / lava
        return "special"
    if tile_id in _DARK_WORLD or tile_id in _UNDERWATER:
        return "special"
    if tile_id in COLLIDABLE_TILES:
        if 0x00 <= tile_id <= 0x19:
            return "maze"
        if 0x53 <= tile_id <= 0x6B:
            return "dungeon"
        if 0x73 <= tile_id <= 0x84:
            return "overworld"
        if 0x86 <= tile_id <= 0xFE:
            return "town"
    if tile_id in _NATURE:
        return "overworld"
    return None


def score_tilesection_biome(tile_ids) -> str:
    """Dominant biome of a tile list; 'special' when no tile carries a signal."""
    counts: Counter = Counter()
    for t in tile_ids:
        b = tile_biome(t)
        if b is not None:
            counts[b] += 1
    if not counts:
        return "special"
    top = max(counts.values())
    for b in BIOMES:  # deterministic tie-break by BIOMES order
        if counts.get(b, 0) == top:
            return b
    return "special"


def _section_tiles(rom_data: bytes, global_index: int) -> list:
    return [t for row in get_tilesection_grid(read_tilesection(rom_data, global_index)) for t in row]


def compute_section_themes(game_world, rom_data: bytes) -> dict:
    """Biome for every global section index 0..TILESECTION_COUNT-1.

    Primary: plurality SectionType-biome of screens that reference the section.
    Fallback (no votes or a tie): tile-ID content score.
    """
    votes: dict[int, Counter] = defaultdict(Counter)
    for chapter in game_world:
        for screen in chapter:
            top_off, bot_off = get_bank_offset(screen.datapointer)
            biome = section_type_to_biome(screen.section_type)
            votes[screen.top_tiles + top_off][biome] += 1
            votes[screen.bottom_tiles + bot_off][biome] += 1

    themes: dict[str, str] = {}
    for g in range(TILESECTION_COUNT):
        c = votes.get(g)
        if c:
            top = max(c.values())
            tied = [b for b in BIOMES if c.get(b, 0) == top]
            if len(tied) == 1:
                themes[str(g)] = tied[0]
            else:
                scored = score_tilesection_biome(_section_tiles(rom_data, g))
                themes[str(g)] = scored if scored in tied else tied[0]
        else:
            themes[str(g)] = score_tilesection_biome(_section_tiles(rom_data, g))
    return themes
```

- [ ] **Step 4: Run test to verify it passes**

Run:
```bash
cd projects/TMOS_Randomizer_V2 && PYTHONPATH=src python -m pytest tests/test_tilesection_themes.py -v
```
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/src/tmos_randomizer/validation/tiles/themes.py projects/TMOS_Randomizer_V2/tests/test_tilesection_themes.py
git commit -m "feat(tiles): add tilesection biome/theme classifier"
```

---

### Task 2: Themes endpoint

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/server.py`
- Test: `projects/TMOS_Randomizer_V2/tests/test_tilesection_themes.py` (add endpoint tests)

**Interfaces:**
- Consumes: `compute_section_themes` (Task 1); module globals `_rom_data`, `_game_world`, `app`.
- Produces: `GET /api/rom/tilesection-themes` → `{"themes": {...471...}}`; `400` when no ROM/world. Cached on `id(_rom_data)`.

- [ ] **Step 1: Write the failing test**

Append to `projects/TMOS_Randomizer_V2/tests/test_tilesection_themes.py`:

```python
from fastapi.testclient import TestClient
import tmos_randomizer.api.server as server


def test_endpoint_no_rom_returns_400():
    server._rom_data = None
    server._game_world = None
    server._ts_theme_cache = None
    server._ts_theme_cache_key = None
    client = TestClient(server.app)
    assert client.get("/api/rom/tilesection-themes").status_code == 400


def test_endpoint_returns_themes():
    server._rom_data = _fake_rom()
    server._game_world = [[_screen(0x00, 5, 6, SectionType.OVERWORLD)]]
    server._ts_theme_cache = None
    server._ts_theme_cache_key = None
    client = TestClient(server.app)
    resp = client.get("/api/rom/tilesection-themes")
    assert resp.status_code == 200
    themes = resp.json()["themes"]
    assert len(themes) == TILESECTION_COUNT
    assert themes["5"] == "overworld"
    assert themes["7"] == "dungeon"
    assert all(v in BIOMES for v in themes.values())
    server._rom_data = None
    server._game_world = None
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd projects/TMOS_Randomizer_V2 && PYTHONPATH=src python -m pytest tests/test_tilesection_themes.py -k endpoint -v
```
Expected: FAIL — `AttributeError: ... '_ts_theme_cache'` or 404 on the route.

- [ ] **Step 3: Add the cache globals + endpoint**

In `api/server.py`, near the Spec #2 walkability cache globals (`_ts_walk_cache`/`_ts_walk_cache_key`), add:

```python
# Cache for the per-section theme table (pure function of the loaded ROM).
_ts_theme_cache: dict | None = None
_ts_theme_cache_key: int | None = None
```

Add the endpoint next to `get_tilesection_walkability`:

```python
@app.get("/api/rom/tilesection-themes")
async def get_tilesection_themes():
    """Biome ('overworld'/'town'/'dungeon'/'maze'/'special') for every global
    TileSection (0..470). Pure function of the loaded ROM, cached.
    """
    global _ts_theme_cache, _ts_theme_cache_key
    if _rom_data is None or _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    key = id(_rom_data)
    if _ts_theme_cache is None or _ts_theme_cache_key != key:
        from ..validation.tiles.themes import compute_section_themes
        _ts_theme_cache = compute_section_themes(_game_world, _rom_data)
        _ts_theme_cache_key = key

    return {"themes": _ts_theme_cache}
```

- [ ] **Step 4: Run test to verify it passes**

Run:
```bash
cd projects/TMOS_Randomizer_V2 && PYTHONPATH=src python -m pytest tests/test_tilesection_themes.py -v
```
Expected: PASS (6 tests total).

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/server.py projects/TMOS_Randomizer_V2/tests/test_tilesection_themes.py
git commit -m "feat(api): add /api/rom/tilesection-themes endpoint (cached)"
```

---

### Task 3: Frontend theme util + `suggestPairs` candidate filter

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/screen/tileFilter.ts`
- Create: `projects/TMOS_Randomizer_V2/ui/src/components/screen/themeFilter.ts`
- Test: `projects/TMOS_Randomizer_V2/ui/src/components/screen/themeFilter.test.ts`

**Interfaces:**
- Consumes: existing `rankSections`/`SuggestedPair` (`tileFilter.ts`).
- Produces:
  - `tileFilter.suggestPairs(table, neighbors, count, k?, limit?, candidates?: number[])` — when `candidates` is given, only those global indices are eligible as top/bottom.
  - `themeFilter`: `Biome`, `TargetTheme = Biome | 'all'`, `ThemeTable = Record<string,string>`, `BIOME_OPTIONS: TargetTheme[]`, `offTheme(theme, target): 0|1`, `coherentPairCandidates(themes, target, count): number[]`.

- [ ] **Step 1: Write the failing test**

Create `projects/TMOS_Randomizer_V2/ui/src/components/screen/themeFilter.test.ts`:

```ts
import { describe, it, expect } from 'vitest';
import { offTheme, coherentPairCandidates, BIOME_OPTIONS } from './themeFilter';
import { suggestPairs, type NeighborSigs, type WalkabilityTable } from './tileFilter';

const NONE: NeighborSigs = { up: null, down: null, left: null, right: null };

describe('offTheme', () => {
  it('is 0 for target=all regardless of theme', () => {
    expect(offTheme('dungeon', 'all')).toBe(0);
    expect(offTheme(undefined, 'all')).toBe(0);
  });
  it('is 0 on-theme, 1 off-theme', () => {
    expect(offTheme('dungeon', 'dungeon')).toBe(0);
    expect(offTheme('overworld', 'dungeon')).toBe(1);
    expect(offTheme(undefined, 'dungeon')).toBe(1);
  });
});

describe('coherentPairCandidates', () => {
  it('returns all indices for target=all', () => {
    const themes = { '0': 'overworld', '1': 'dungeon', '2': 'town' };
    expect(coherentPairCandidates(themes, 'all', 3)).toEqual([0, 1, 2]);
  });
  it('filters to the target biome', () => {
    const themes = { '0': 'overworld', '1': 'dungeon', '2': 'dungeon' };
    expect(coherentPairCandidates(themes, 'dungeon', 3)).toEqual([1, 2]);
  });
});

describe('BIOME_OPTIONS', () => {
  it('starts with all then the 5 biomes', () => {
    expect(BIOME_OPTIONS).toEqual(['all', 'overworld', 'town', 'dungeon', 'maze', 'special']);
  });
});

describe('suggestPairs candidates filter', () => {
  it('restricts both halves to the candidate set', () => {
    const table: WalkabilityTable = { '0': '1'.repeat(32), '1': '0'.repeat(32) };
    const pairs = suggestPairs(table, NONE, 2, 40, 12, [0]);
    expect(pairs.length).toBeGreaterThan(0);
    for (const p of pairs) {
      expect(p.top).toBe(0);
      expect(p.bottom).toBe(0);
    }
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd projects/TMOS_Randomizer_V2/ui && npm test -- src/components/screen/themeFilter.test.ts`
Expected: FAIL — module `./themeFilter` not found (and `suggestPairs` rejects the 6th arg).

- [ ] **Step 3a: Extend `suggestPairs`**

In `tileFilter.ts`, replace the `suggestPairs` function with this (adds the optional `candidates` param; everything else unchanged):

```ts
export function suggestPairs(
  table: WalkabilityTable,
  neighbors: NeighborSigs,
  count: number,
  k = 40,
  limit = 12,
  candidates?: number[],
): SuggestedPair[] {
  const allow = candidates ? new Set(candidates) : null;
  const pick = (half: Half): RankedSection[] => {
    let ranked = rankSections(table, half, neighbors, count);
    if (allow) ranked = ranked.filter((r) => allow.has(r.globalIndex));
    return ranked.slice(0, k);
  };
  const tops = pick('top');
  const bottoms = pick('bottom');
  const pairs: SuggestedPair[] = [];
  for (const t of tops) {
    const tSig = table[String(t.globalIndex)];
    if (tSig == null) continue;
    for (const b of bottoms) {
      const bSig = table[String(b.globalIndex)];
      if (bSig == null) continue;
      pairs.push({
        top: t.globalIndex,
        bottom: b.globalIndex,
        mismatch: scorePair(tSig, bSig, neighbors),
      });
    }
  }
  pairs.sort((a, b) => a.mismatch - b.mismatch || a.top - b.top || a.bottom - b.bottom);
  return pairs.slice(0, limit);
}
```

- [ ] **Step 3b: Create `themeFilter.ts`**

Create `projects/TMOS_Randomizer_V2/ui/src/components/screen/themeFilter.ts`:

```ts
// Pure theme/biome filtering helpers for the tile-section picker.
// Composes with the Spec #2 collision filter: the picker sorts by the
// [offTheme, collisionMismatch, globalIndex] composite key.

export type Biome = 'overworld' | 'town' | 'dungeon' | 'maze' | 'special';
export type TargetTheme = Biome | 'all';
export type ThemeTable = Record<string, string>;

// Dropdown options: "all" plus the 5 biomes, in display order.
export const BIOME_OPTIONS: TargetTheme[] = ['all', 'overworld', 'town', 'dungeon', 'maze', 'special'];

// Primary sort key component: 0 = on-theme (or target 'all'), 1 = off-theme.
export function offTheme(theme: string | undefined, target: TargetTheme): 0 | 1 {
  if (target === 'all') return 0;
  return theme === target ? 0 : 1;
}

// Global section indices whose theme matches the target (all when target='all').
export function coherentPairCandidates(themes: ThemeTable, target: TargetTheme, count: number): number[] {
  const out: number[] = [];
  for (let g = 0; g < count; g++) {
    if (target === 'all' || themes[String(g)] === target) out.push(g);
  }
  return out;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd projects/TMOS_Randomizer_V2/ui && npm test -- src/components/screen/themeFilter.test.ts && npm test`
Expected: new file PASS; full suite green (Spec #2 `tileFilter` tests still pass — the `candidates` param is optional/backward-compatible).

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/tileFilter.ts projects/TMOS_Randomizer_V2/ui/src/components/screen/themeFilter.ts projects/TMOS_Randomizer_V2/ui/src/components/screen/themeFilter.test.ts
git commit -m "feat(tiles): theme filter util + suggestPairs candidate filter"
```

---

### Task 4: Client method + store loader (themes)

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/api/client.ts`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/store/index.ts`

**Interfaces:**
- Produces: `api.getTileSectionThemes(): Promise<TileSectionThemesResponse>` where `TileSectionThemesResponse = { themes: Record<string,string> }`; store `tileThemes: Record<string,string> | null`, `tileThemesLoading: boolean`, `loadTileThemes(): Promise<void>` (lazy, session-cached — mirrors `tileWalkability`/`loadTileWalkability`).

- [ ] **Step 1: Add the client method**

In `ui/src/api/client.ts`, add the response type next to `TileSectionWalkabilityResponse`:

```ts
export interface TileSectionThemesResponse {
  themes: Record<string, string>;  // global index -> biome
}
```

And the method inside `ApiClient`, next to `getTileSectionWalkability`:

```ts
  // Per-section biome/theme table (read-only, cached server-side).
  async getTileSectionThemes(): Promise<TileSectionThemesResponse> {
    return this.fetch<TileSectionThemesResponse>(`/api/rom/tilesection-themes`);
  }
```

- [ ] **Step 2: Add store state + loader**

In `ui/src/store/index.ts`, mirror the `tileWalkability` slice.

Interface state (near `tileWalkability`):
```ts
  tileThemes: Record<string, string> | null;
  tileThemesLoading: boolean;
```

Interface action (near `loadTileWalkability`):
```ts
  loadTileThemes: () => Promise<void>;
```

Initial state (near `tileWalkability: null,`):
```ts
  tileThemes: null,
  tileThemesLoading: false,
```

Action implementation (near `loadTileWalkability`):
```ts
  loadTileThemes: async () => {
    if (get().tileThemes || get().tileThemesLoading) return;
    set({ tileThemesLoading: true });
    try {
      const r = await api.getTileSectionThemes();
      set({ tileThemes: r.themes, tileThemesLoading: false });
    } catch (e) {
      console.error('Failed to load tilesection themes', e);
      set({ tileThemesLoading: false });
    }
  },
```

- [ ] **Step 3: Verify**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit && npm test`
Expected: 0 type errors; suites green.

- [ ] **Step 4: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/api/client.ts projects/TMOS_Randomizer_V2/ui/src/store/index.ts
git commit -m "feat(tiles): client + store for tilesection themes"
```

---

### Task 5: Modal — theme dropdown, composite ordering, biome tags

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx`

**Interfaces:**
- Consumes: store `tileThemes`/`loadTileThemes` (Task 4); `themeFilter` (`offTheme`, `BIOME_OPTIONS`, type `TargetTheme`); existing `ordered`/`neighbors`/`getBanks`/`currentGlobal`.
- Produces: extends `SectionThumb` with optional `theme?: string` (biome dot) and folds off-theme into dimming. (Coherent-swap button is Task 6.)

- [ ] **Step 1: Imports + load themes + dropdown state**

Add imports:
```ts
import { offTheme, BIOME_OPTIONS, type TargetTheme } from './themeFilter';
```

Add a biome color map at module scope (after `getBanks`):
```ts
const BIOME_COLORS: Record<string, string> = {
  overworld: '#22c55e',
  town: '#3b82f6',
  dungeon: '#a855f7',
  maze: '#f97316',
  special: '#eab308',
};
```

Inside the component, after the `tileWalkability`/`loadTileWalkability` hooks, add:
```ts
  const tileThemes = useRandomizerStore((s) => s.tileThemes);
  const loadTileThemes = useRandomizerStore((s) => s.loadTileThemes);
  const [themeSel, setThemeSel] = useState<TargetTheme>('all');

  useEffect(() => {
    loadTileThemes();
  }, [loadTileThemes]);

  // The screen's own biome = theme of its current top section (top half global index).
  const screenTopGlobal = banks.top * 256 + screen.top_tiles;
  const screenBiome = tileThemes?.[String(screenTopGlobal)];

  // Default the dropdown to the screen's biome when themes load / the screen changes.
  useEffect(() => {
    if (tileThemes && screenBiome) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setThemeSel(screenBiome as TargetTheme);
    }
  }, [tileThemes, screen.index, screenBiome]);
```

- [ ] **Step 2: Compose theme into `ordered`**

Replace the existing `ordered` memo with one that applies the composite sort when a specific theme is selected:

```ts
  const filterOn = collisionFilter && tileWalkability != null;
  const base = useMemo(() => {
    if (filterOn) return rankSections(tileWalkability!, activeHalf, neighbors, TOTAL);
    return indices.map((g) => ({ globalIndex: g, mismatch: 0 }));
  }, [filterOn, tileWalkability, activeHalf, neighbors, indices]);

  const ordered = useMemo(() => {
    if (themeSel === 'all') return base;
    return base.slice().sort((a, b) => {
      const oa = offTheme(tileThemes?.[String(a.globalIndex)], themeSel);
      const ob = offTheme(tileThemes?.[String(b.globalIndex)], themeSel);
      return oa - ob || a.mismatch - b.mismatch || a.globalIndex - b.globalIndex;
    });
  }, [base, themeSel, tileThemes]);
```

- [ ] **Step 3: Add the theme dropdown to the header row**

In the filter header row (after the collision `<label>` / loading span, before the `Suggest pairs` button), add:

```tsx
            <label className="flex items-center gap-1.5 text-slate-300">
              Theme:
              <select
                value={themeSel}
                disabled={tileThemes == null}
                onChange={(e) => setThemeSel(e.target.value as TargetTheme)}
                className="bg-slate-700 text-slate-200 rounded px-1 py-0.5 disabled:opacity-40"
              >
                {BIOME_OPTIONS.map((b) => (
                  <option key={b} value={b}>{b === 'all' ? 'All' : b[0].toUpperCase() + b.slice(1)}</option>
                ))}
              </select>
            </label>
```

- [ ] **Step 4: Pass theme + off-theme dim to `SectionThumb`**

In the grid `ordered.map(...)`, update the `SectionThumb` props:

```tsx
            {ordered.map(({ globalIndex: g, mismatch }) => {
              const theme = tileThemes?.[String(g)];
              const off = themeSel !== 'all' && offTheme(theme, themeSel) === 1;
              return (
                <SectionThumb
                  key={g}
                  globalIndex={g}
                  chr={chr}
                  selected={g === currentGlobal}
                  crossBank={g >= 256}
                  shadeBottomRows={activeHalf === 'bottom'}
                  dim={(filterOn && mismatch > 0) || off}
                  badge={filterOn && mismatch > 0 ? mismatch : undefined}
                  perfect={filterOn && mismatch === 0 && !off}
                  theme={theme}
                  onClick={() => onTilePick(activeHalf, g)}
                />
              );
            })}
```

- [ ] **Step 5: Extend `SectionThumb` with the biome dot**

Add `theme?: string` to `SectionThumb`'s props (signature + type), and render a small biome dot. In the props destructure add `theme`, in the type add `theme?: string;`, and inside the `<button>` (next to the index label `<span>`) add:

```tsx
      {theme && (
        <span
          className="absolute bottom-0 left-0 w-2 h-2 rounded-full m-0.5"
          style={{ backgroundColor: BIOME_COLORS[theme] ?? '#64748b' }}
          title={theme}
        />
      )}
```

- [ ] **Step 6: Verify**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit && npm run lint && npm test`
Expected: 0 type errors; no new lint errors in `ScreenEditorModal.tsx`; tests green.

- [ ] **Step 7: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx
git commit -m "feat(tiles): theme dropdown + composite ordering + biome tags in picker"
```

---

### Task 6: Modal — coherent swap

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx`

**Interfaces:**
- Consumes: `coherentPairCandidates` (`themeFilter`), `suggestPairs` candidates param (Task 3), `themeSel`/`tileThemes`/`neighbors` (Task 5), existing `onPickPair`.
- Produces: a `pairMode: 'off' | 'collision' | 'coherent'` state replacing the boolean `showPairs`; a "Coherent swap" button; the pairs panel computes collision-only or theme-constrained pairs.

- [ ] **Step 1: Replace `showPairs` with `pairMode`**

Add the import:
```ts
import { offTheme, coherentPairCandidates, BIOME_OPTIONS, type TargetTheme } from './themeFilter';
```
(merge with the Task 5 themeFilter import line).

Replace the `showPairs` state + `pairs` memo with:

```ts
  const [pairMode, setPairMode] = useState<'off' | 'collision' | 'coherent'>('off');
  const pairs = useMemo(() => {
    if (pairMode === 'off' || tileWalkability == null) return [];
    if (pairMode === 'coherent') {
      if (tileThemes == null) return [];
      const cands = coherentPairCandidates(tileThemes, themeSel, TOTAL);
      return suggestPairs(tileWalkability, neighbors, TOTAL, 40, 12, cands);
    }
    return suggestPairs(tileWalkability, neighbors, TOTAL);
  }, [pairMode, tileWalkability, tileThemes, themeSel, neighbors]);
```

- [ ] **Step 2: Update the buttons**

Replace the single "Suggest pairs" button with two buttons (collision + coherent):

```tsx
            <div className="ml-auto flex items-center gap-1.5">
              <button
                type="button"
                disabled={tileWalkability == null}
                onClick={() => setPairMode((m) => (m === 'collision' ? 'off' : 'collision'))}
                className={`px-2 py-0.5 rounded text-slate-200 disabled:opacity-40 ${pairMode === 'collision' ? 'bg-emerald-700' : 'bg-slate-700 hover:bg-slate-600'}`}
              >
                Suggest pairs
              </button>
              <button
                type="button"
                disabled={tileWalkability == null || tileThemes == null}
                onClick={() => setPairMode((m) => (m === 'coherent' ? 'off' : 'coherent'))}
                className={`px-2 py-0.5 rounded text-slate-200 disabled:opacity-40 ${pairMode === 'coherent' ? 'bg-emerald-700' : 'bg-slate-700 hover:bg-slate-600'}`}
                title={themeSel === 'all' ? 'Coherent pairs across all biomes' : `Coherent ${themeSel} pairs`}
              >
                Coherent swap
              </button>
            </div>
```

- [ ] **Step 3: Update the panel guard**

The pairs panel currently renders under `{showPairs && (...)}`. Change that condition to `{pairMode !== 'off' && (...)}`. The panel body (`pairs.length === 0 ? ... : pairs.map(...)`) is unchanged — it already reads the `pairs` memo and applies via `onPickPair?.(p.top, p.bottom)`.

- [ ] **Step 4: Verify**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit && npm run build && npm run lint && npm test`
Expected: 0 type errors; build succeeds; no new lint errors; tests green.

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx
git commit -m "feat(tiles): coherent-swap mode (same-biome collision-fit pairs)"
```

---

### Task 7: Full verification

**Files:** none (verification only).

- [ ] **Step 1: Backend + frontend suites**

Run:
```bash
cd projects/TMOS_Randomizer_V2 && PYTHONPATH=src python -m pytest tests/test_tilesection_themes.py -v
cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit && npm run build && npm run lint && npm test
```
Expected: backend themes tests pass; tsc 0 errors; build succeeds; frontend suites green.

- [ ] **Step 2: Manual smoke test**

Backend (`tmos-randomize serve`) + `npm run dev`, load a ROM, open a screen's editor:
1. Theme dropdown defaults to the screen's own biome; on-theme sections sort first, off-theme dimmed; each thumb shows a biome color dot.
2. Switch the dropdown (e.g. Overworld→Dungeon) → grouping changes; "All" restores the Spec #2 collision-only order exactly.
3. Enable **Filter: collision** too → on-theme **and** perfect-fit sections lead; off-theme stays dimmed.
4. **Suggest pairs** → collision pairs (any biome); **Coherent swap** → pairs constrained to the selected biome; clicking applies both halves atomically.
5. While themes load, the dropdown/coherent-swap show disabled state and the grid is ungrouped.

- [ ] **Step 3: Final commit (only if manual QA required tweaks)**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx
git commit -m "fix(tiles): polish theme filter after manual QA"
```

---

## Self-Review Notes

- **Spec coverage:** 5-biome classifier via reverse-index + tile-ID tiebreaker (Task 1) ✔; cacheable endpoint 471 entries (Task 2) ✔; client+store (Task 4) ✔; soft theme dropdown defaulting to screen biome + never-hide composite ordering + biome tags (Task 5) ✔; coherent swap = `suggestPairs` constrained to same-biome candidates + atomic apply (Tasks 3,6) ✔; composes with Spec #2, theme=All is a no-op (Task 5 ordering) ✔; reuse V2 primitives, no World-Editor import ✔.
- **Type consistency:** `suggestPairs(..., candidates?)` signature matches its coherent-swap call (Task 6); `offTheme`/`coherentPairCandidates`/`TargetTheme`/`BIOME_OPTIONS` match between `themeFilter.ts` (Task 3) and the modal (Tasks 5,6); `{themes: Record<string,string>}` consistent across endpoint/client/store. `compute_section_themes(game_world, rom_data)` is called with `(_game_world, _rom_data)` in the endpoint.
- **Honest gaps:** `get_bank_offset` leaves datapointer `0xA0–0xBF` at `(0,0)` (known gap); the tile-ID tiebreaker covers any section left unvoted by it. Theme is a soft signal (never hides), so a mislabel only changes sort order. Palette coherence is out of scope.
