# Tile-Picker Collision Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an opt-in collision filter (per-half edge-compat ranking) plus a top/bottom pair helper to the Edit World Screen modal's 471-section tile picker.

**Architecture:** One new cacheable backend endpoint returns each of the 471 sections' intrinsic 4×8 walkability grid (32-char bitstring). The frontend fetches it once and does all ranking/dimming + pair scoring client-side in a pure `tileFilter.ts` util, reusing the backend's authoritative collision tables (no World-Editor import).

**Tech Stack:** FastAPI + Python (backend, pytest), React 19 + TypeScript + Tailwind + zustand (frontend), Vitest (node env).

## Global Constraints

- The filter is **off by default**; with it off the picker behaves exactly as today.
- **Reuse V2's existing collision primitives** (`validation/tiles/categories.py`, `validation/tiles/edges.py`); do NOT import anything from `TMOS_World_Editor`.
- Walkability is **intrinsic to tile IDs** (independent of CHR/datapointer) → the per-section table is a pure function of the ROM and is **cached** server-side.
- The endpoint returns **grids (32-char bitstrings), not pre-sliced edges**.
- `TILESECTION_COUNT = 471` (`core.constants`; frontend `ApiClient.TILESECTION_COUNT`). Section global index `0..470` is bank-encoded: `global = bank*256 + byte`; `read_tilesection(rom, global)` reads `TILESECTION_BASE + global*32` directly (bank-1 offset 256 sections = 0x2000 bytes).
- Walkability bit convention: `'1'` = walkable (`is_walkable` true: WALKABLE/HAZARDOUS), `'0'` = blocking (COLLIDABLE/DEADLY). Row-major over 4 rows × 8 cols.
- Frontend: Vitest runs in **node** env, includes only `src/**/*.test.ts` → unit-test the pure `tileFilter.ts`; `.tsx` wiring is verified by `tsc`/lint/manual (per Spec #1's convention).
- Shared working tree: commit **explicit paths only** (`git add <paths>`), never `git add -A`, no branch surgery beyond the feature branch.
- Run frontend commands from `projects/TMOS_Randomizer_V2/ui`; backend from `projects/TMOS_Randomizer_V2`.

---

## File Structure

| File | Responsibility |
|---|---|
| `src/tmos_randomizer/validation/tiles/edges.py` (modify) | Add `tilesection_walkability(rom, index)` + `all_tilesection_walkability(rom)`. |
| `tests/test_tilesection_walkability.py` (create) | Unit-test the builders with a synthetic ROM. |
| `src/tmos_randomizer/api/server.py` (modify) | Add `GET /api/rom/tilesection-walkability` (cached). |
| `tests/test_tilesection_walkability_endpoint.py` (create) | TestClient route test (no-ROM 400 + populated 471×32). |
| `ui/src/api/client.ts` (modify) | `getTileSectionWalkability()` + response type. |
| `ui/src/store/index.ts` (modify) | `tileWalkability` state + lazy `loadTileWalkability()`. |
| `ui/src/components/screen/tileFilter.ts` (create) | Pure util: edge slicing, scoring, ranking, pair suggestions. |
| `ui/src/components/screen/tileFilter.test.ts` (create) | Unit tests for the util. |
| `ui/src/components/screen/ScreenEditorModal.tsx` (modify) | Toggle, ranked/dimmed grid, summary line, pair panel. |
| `ui/src/components/views/WorldView.tsx` (modify) | Wire `onPickPair` → single combined `updateScreenTiles`. |

---

### Task 1: Backend walkability builders

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/src/tmos_randomizer/validation/tiles/edges.py`
- Test: `projects/TMOS_Randomizer_V2/tests/test_tilesection_walkability.py`

**Interfaces:**
- Consumes: existing `read_tilesection`, `get_tilesection_grid` (same file); `get_walkability_signature` (`.categories`); `TILESECTION_COUNT` (`...core.constants`).
- Produces: `tilesection_walkability(rom_data: bytes, index: int) -> str` (32-char `[01]`); `all_tilesection_walkability(rom_data: bytes) -> dict[str, str]` (keys `"0".."470"`).

- [ ] **Step 1: Write the failing test**

Create `projects/TMOS_Randomizer_V2/tests/test_tilesection_walkability.py`:

```python
from tmos_randomizer.validation.tiles.edges import (
    TILESECTION_BASE,
    tilesection_walkability,
    all_tilesection_walkability,
)
from tmos_randomizer.core.constants import TILESECTION_COUNT


def _fake_rom() -> bytes:
    """ROM where section 0 is all walkable (0x5F) and section 1 all blocking (0x00)."""
    size = TILESECTION_BASE + TILESECTION_COUNT * 32 + 32
    rom = bytearray(size)
    for i in range(32):
        rom[TILESECTION_BASE + 0 * 32 + i] = 0x5F  # walkable (dungeon floor)
        rom[TILESECTION_BASE + 1 * 32 + i] = 0x00  # collidable (maze wall)
    return bytes(rom)


def test_single_section_signature():
    rom = _fake_rom()
    assert tilesection_walkability(rom, 0) == "1" * 32
    assert tilesection_walkability(rom, 1) == "0" * 32


def test_all_sections_shape():
    rom = _fake_rom()
    table = all_tilesection_walkability(rom)
    assert len(table) == TILESECTION_COUNT
    assert table["0"] == "1" * 32
    assert table["1"] == "0" * 32
    for sig in table.values():
        assert len(sig) == 32
        assert set(sig) <= {"0", "1"}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_tilesection_walkability.py -v`
Expected: FAIL — `ImportError: cannot import name 'tilesection_walkability'`.

- [ ] **Step 3: Implement the builders**

In `validation/tiles/edges.py`, add the categories import near the top (after the existing imports, before `TILESECTION_BASE`):

```python
from .categories import get_walkability_signature
```

Then add at the end of the file:

```python
def tilesection_walkability(rom_data: bytes, index: int) -> str:
    """Walkability signature for one global TileSection index.

    `index` is a global section index (0..TILESECTION_COUNT-1); the bank is
    already baked into it (read_tilesection reads TILESECTION_BASE + index*32).
    Returns a 32-char bitstring ('1'=walkable, '0'=blocking) in row-major order
    over the section's 4 rows x 8 cols.
    """
    grid = get_tilesection_grid(read_tilesection(rom_data, index))
    tiles = [t for row in grid for t in row]
    return get_walkability_signature(tiles)


def all_tilesection_walkability(rom_data: bytes) -> dict:
    """Walkability signatures for every global section index 0..TILESECTION_COUNT-1.

    Returns {str(global_index): "<32-char signature>"}.
    """
    from ...core.constants import TILESECTION_COUNT

    return {
        str(g): tilesection_walkability(rom_data, g)
        for g in range(TILESECTION_COUNT)
    }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_tilesection_walkability.py -v`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/src/tmos_randomizer/validation/tiles/edges.py projects/TMOS_Randomizer_V2/tests/test_tilesection_walkability.py
git commit -m "feat(tiles): add tilesection walkability signature builders"
```

---

### Task 2: Walkability endpoint

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/server.py`
- Test: `projects/TMOS_Randomizer_V2/tests/test_tilesection_walkability_endpoint.py`

**Interfaces:**
- Consumes: `all_tilesection_walkability` (Task 1); module globals `_rom_data`, `app`.
- Produces: `GET /api/rom/tilesection-walkability` → `{"sections": {"0": "<32-char>", ...}}` (471 entries); `400` when no ROM. Cached per loaded ROM (keyed on `id(_rom_data)`).

- [ ] **Step 1: Write the failing test**

Create `projects/TMOS_Randomizer_V2/tests/test_tilesection_walkability_endpoint.py`:

```python
from fastapi.testclient import TestClient

import tmos_randomizer.api.server as server
from tmos_randomizer.validation.tiles.edges import TILESECTION_BASE
from tmos_randomizer.core.constants import TILESECTION_COUNT


def _fake_rom() -> bytes:
    size = TILESECTION_BASE + TILESECTION_COUNT * 32 + 32
    rom = bytearray(size)
    for i in range(32):
        rom[TILESECTION_BASE + i] = 0x5F  # section 0 walkable
    return bytes(rom)


def test_no_rom_returns_400():
    server._rom_data = None
    server._ts_walk_cache = None
    server._ts_walk_cache_key = None
    client = TestClient(server.app)
    assert client.get("/api/rom/tilesection-walkability").status_code == 400


def test_returns_all_section_signatures():
    server._rom_data = _fake_rom()
    server._ts_walk_cache = None
    server._ts_walk_cache_key = None
    client = TestClient(server.app)
    resp = client.get("/api/rom/tilesection-walkability")
    assert resp.status_code == 200
    sections = resp.json()["sections"]
    assert len(sections) == TILESECTION_COUNT
    assert sections["0"] == "1" * 32
    assert all(len(s) == 32 for s in sections.values())
    server._rom_data = None  # clean up shared global
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_tilesection_walkability_endpoint.py -v`
Expected: FAIL — `AttributeError: module ... has no attribute '_ts_walk_cache'` (or 404 on the route).

- [ ] **Step 3: Add the cache globals and endpoint**

In `api/server.py`, near the other module-level globals (where `_rom_data`/`_game_world` are declared), add:

```python
# Cache for the per-section walkability table (pure function of the loaded ROM).
_ts_walk_cache: dict | None = None
_ts_walk_cache_key: int | None = None
```

Then add the endpoint (next to the other `/api/rom/tilesection...` routes):

```python
@app.get("/api/rom/tilesection-walkability")
async def get_tilesection_walkability():
    """Intrinsic walkability signature for every global TileSection (0..470).

    Each value is a 32-char bitstring ('1'=walkable, '0'=blocking) over the
    section's 4 rows x 8 cols, row-major. Pure function of the ROM, cached.
    """
    global _ts_walk_cache, _ts_walk_cache_key
    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    key = id(_rom_data)
    if _ts_walk_cache is None or _ts_walk_cache_key != key:
        from ..validation.tiles.edges import all_tilesection_walkability
        _ts_walk_cache = all_tilesection_walkability(_rom_data)
        _ts_walk_cache_key = key

    return {"sections": _ts_walk_cache}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_tilesection_walkability_endpoint.py -v`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/server.py projects/TMOS_Randomizer_V2/tests/test_tilesection_walkability_endpoint.py
git commit -m "feat(api): add /api/rom/tilesection-walkability endpoint (cached)"
```

---

### Task 3: `tileFilter.ts` pure util

**Files:**
- Create: `projects/TMOS_Randomizer_V2/ui/src/components/screen/tileFilter.ts`
- Test: `projects/TMOS_Randomizer_V2/ui/src/components/screen/tileFilter.test.ts`

**Interfaces:**
- Produces:
  - types `Half = 'top'|'bottom'`, `WalkabilityTable = Record<string,string>`, `SectionPair = {top:string;bottom:string}`, `NeighborSigs = {up,down,left,right: SectionPair|null}`, `RankedSection = {globalIndex:number;mismatch:number}`, `SuggestedPair = {top:number;bottom:number;mismatch:number}`.
  - `rowSig(sig,r)`, `colSig(sig,c,rows)`, `mismatchCount(a,b)`, `sectionPair(table,topGlobal,bottomGlobal)`, `scoreCandidate(candidate,half,neighbors)`, `rankSections(table,half,neighbors,count)`, `internalSeam(topSig,bottomSig)`, `scorePair(topSig,bottomSig,neighbors)`, `suggestPairs(table,neighbors,count,k?,limit?)`.

- [ ] **Step 1: Write the failing test**

Create `projects/TMOS_Randomizer_V2/ui/src/components/screen/tileFilter.test.ts`:

```ts
import { describe, it, expect } from 'vitest';
import {
  rowSig, colSig, mismatchCount, sectionPair, scoreCandidate,
  rankSections, internalSeam, scorePair, suggestPairs,
  type NeighborSigs, type WalkabilityTable,
} from './tileFilter';

const WALK = '1'.repeat(32);
const BLOCK = '0'.repeat(32);
const NONE: NeighborSigs = { up: null, down: null, left: null, right: null };

describe('rowSig / colSig', () => {
  it('rowSig slices an 8-char row', () => {
    // row 1 of a sig whose row1 is all 0, rest 1
    const sig = '11111111' + '00000000' + '11111111' + '11111111';
    expect(rowSig(sig, 1)).toBe('00000000');
  });
  it('colSig reads a column over the given rows', () => {
    // col 0 of each row = first char of each 8-char row
    const sig = '0' + '1111111' + '1' + '1111111' + '0' + '1111111' + '1' + '1111111';
    expect(colSig(sig, 0, [0, 1, 2, 3])).toBe('0101');
  });
});

describe('mismatchCount', () => {
  it('counts per-position 1-vs-0 mismatches', () => {
    expect(mismatchCount('1111', '1111')).toBe(0);
    expect(mismatchCount('1111', '0000')).toBe(4);
    expect(mismatchCount('1010', '1100')).toBe(2);
  });
});

describe('sectionPair', () => {
  it('returns null when either section is missing', () => {
    const t: WalkabilityTable = { '0': WALK };
    expect(sectionPair(t, 0, 1)).toBeNull();
    expect(sectionPair(t, 0, 0)).toEqual({ top: WALK, bottom: WALK });
  });
});

describe('scoreCandidate', () => {
  it('top half matches up-neighbor bottom edge (section row 1)', () => {
    const up = { top: WALK, bottom: BLOCK }; // up bottom edge = row1 of BLOCK = 00000000
    const n: NeighborSigs = { ...NONE, up };
    expect(scoreCandidate(WALK, 'top', n)).toBe(8); // candidate row0 = 11111111 vs 00000000
    expect(scoreCandidate(BLOCK, 'top', n)).toBe(0);
  });
  it('bottom half matches down-neighbor top edge (section row 0)', () => {
    const down = { top: BLOCK, bottom: WALK }; // down top edge = row0 of BLOCK = 00000000
    const n: NeighborSigs = { ...NONE, down };
    expect(scoreCandidate(WALK, 'bottom', n)).toBe(8); // candidate row1 = 11111111
    expect(scoreCandidate(BLOCK, 'bottom', n)).toBe(0);
  });
  it('ignores neighbors irrelevant to the active half', () => {
    const down = { top: BLOCK, bottom: WALK };
    expect(scoreCandidate(WALK, 'top', { ...NONE, down })).toBe(0); // down ignored for top
  });
  it('skips absent neighbors', () => {
    expect(scoreCandidate(WALK, 'top', NONE)).toBe(0);
  });
});

describe('rankSections', () => {
  it('sorts ascending by mismatch, missing sigs last', () => {
    const table: WalkabilityTable = { '0': WALK, '1': BLOCK }; // index 2 missing
    const up = { top: WALK, bottom: WALK }; // up bottom edge = 11111111
    const ranked = rankSections(table, 'top', { ...NONE, up }, 3);
    expect(ranked[0]).toEqual({ globalIndex: 0, mismatch: 0 });
    expect(ranked[1]).toEqual({ globalIndex: 1, mismatch: 8 });
    expect(ranked[2].globalIndex).toBe(2);
    expect(ranked[2].mismatch).toBe(Infinity);
  });
});

describe('internalSeam / scorePair', () => {
  it('internalSeam compares top row3 vs bottom row0', () => {
    expect(internalSeam(WALK, BLOCK)).toBe(8);
    expect(internalSeam(WALK, WALK)).toBe(0);
  });
  it('scorePair sums both halves and the internal seam', () => {
    // no neighbors → only internal seam contributes
    expect(scorePair(WALK, BLOCK, NONE)).toBe(8);
    expect(scorePair(WALK, WALK, NONE)).toBe(0);
  });
});

describe('suggestPairs', () => {
  it('returns up to limit pairs, best first', () => {
    const table: WalkabilityTable = { '0': WALK, '1': BLOCK };
    const pairs = suggestPairs(table, NONE, 2, 40, 12);
    expect(pairs.length).toBeGreaterThan(0);
    expect(pairs.length).toBeLessThanOrEqual(12);
    // best pair has the lowest mismatch and is sorted first
    for (let i = 1; i < pairs.length; i++) {
      expect(pairs[i].mismatch).toBeGreaterThanOrEqual(pairs[i - 1].mismatch);
    }
    // WALK+WALK has a clean internal seam (0); WALK+BLOCK has 8
    expect(pairs[0].mismatch).toBe(0);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd projects/TMOS_Randomizer_V2/ui && npm test -- src/components/screen/tileFilter.test.ts`
Expected: FAIL — module `./tileFilter` not found.

- [ ] **Step 3: Implement the util**

Create `projects/TMOS_Randomizer_V2/ui/src/components/screen/tileFilter.ts`:

```ts
// Pure collision-filter logic for the tile-section picker.
//
// A "section signature" is a 32-char walkability bitstring ('1'=walkable,
// '0'=blocking) in row-major order over a section's 4 rows x 8 cols. The backend
// endpoint /api/rom/tilesection-walkability returns one per global section index.
//
// Screen layout: rows 0-3 come from the top section; rows 4-5 come from the
// bottom section's rows 0-1.

export type Half = 'top' | 'bottom';
export type WalkabilityTable = Record<string, string>;

export interface SectionPair {
  top: string;
  bottom: string;
}

export interface NeighborSigs {
  up: SectionPair | null;
  down: SectionPair | null;
  left: SectionPair | null;
  right: SectionPair | null;
}

export interface RankedSection {
  globalIndex: number;
  mismatch: number;
}

export interface SuggestedPair {
  top: number;
  bottom: number;
  mismatch: number;
}

const COLS = 8;

/** 8-char row r (0..3) of a 32-char section signature. */
export function rowSig(sig: string, r: number): string {
  return sig.slice(r * COLS, r * COLS + COLS);
}

/** Column c (0 or 7) over the given rows, as a bitstring. */
export function colSig(sig: string, c: number, rows: number[]): string {
  return rows.map((r) => sig[r * COLS + c] ?? '0').join('');
}

/** Per-position walkability mismatches between two bitstrings (walkable-vs-blocking). */
export function mismatchCount(a: string, b: string): number {
  const n = Math.min(a.length, b.length);
  let m = 0;
  for (let i = 0; i < n; i++) if (a[i] !== b[i]) m++;
  return m;
}

/** Resolve a neighbor's section pair from the table; null if either is missing. */
export function sectionPair(
  table: WalkabilityTable,
  topGlobal: number,
  bottomGlobal: number,
): SectionPair | null {
  const top = table[String(topGlobal)];
  const bottom = table[String(bottomGlobal)];
  if (top == null || bottom == null) return null;
  return { top, bottom };
}

/** Mismatch score of a candidate section used as `half`, vs the relevant neighbors. */
export function scoreCandidate(
  candidate: string,
  half: Half,
  neighbors: NeighborSigs,
): number {
  let score = 0;
  if (half === 'top') {
    // Candidate owns screen rows 0-3.
    if (neighbors.up) {
      // up neighbor's bottom edge = its bottom section row 1 (screen row 5).
      score += mismatchCount(rowSig(candidate, 0), rowSig(neighbors.up.bottom, 1));
    }
    if (neighbors.left) {
      // left neighbor's right edge, upper rows 0-3 (from its top section).
      score += mismatchCount(colSig(candidate, 0, [0, 1, 2, 3]), colSig(neighbors.left.top, 7, [0, 1, 2, 3]));
    }
    if (neighbors.right) {
      score += mismatchCount(colSig(candidate, 7, [0, 1, 2, 3]), colSig(neighbors.right.top, 0, [0, 1, 2, 3]));
    }
  } else {
    // Candidate owns screen rows 4-5 (= its section rows 0-1).
    if (neighbors.down) {
      // down neighbor's top edge = its top section row 0 (screen row 0).
      score += mismatchCount(rowSig(candidate, 1), rowSig(neighbors.down.top, 0));
    }
    if (neighbors.left) {
      // left neighbor's right edge, lower rows 4-5 (from its bottom section rows 0-1).
      score += mismatchCount(colSig(candidate, 0, [0, 1]), colSig(neighbors.left.bottom, 7, [0, 1]));
    }
    if (neighbors.right) {
      score += mismatchCount(colSig(candidate, 7, [0, 1]), colSig(neighbors.right.bottom, 0, [0, 1]));
    }
  }
  return score;
}

/** Rank all sections 0..count-1 for the active half (ascending mismatch, missing last). */
export function rankSections(
  table: WalkabilityTable,
  half: Half,
  neighbors: NeighborSigs,
  count: number,
): RankedSection[] {
  const out: RankedSection[] = [];
  for (let g = 0; g < count; g++) {
    const sig = table[String(g)];
    out.push({
      globalIndex: g,
      mismatch: sig == null ? Infinity : scoreCandidate(sig, half, neighbors),
    });
  }
  out.sort((a, b) => a.mismatch - b.mismatch || a.globalIndex - b.globalIndex);
  return out;
}

/** Internal mid-screen seam mismatch: top section row 3 vs bottom section row 0. */
export function internalSeam(topSig: string, bottomSig: string): number {
  return mismatchCount(rowSig(topSig, 3), rowSig(bottomSig, 0));
}

/** Total mismatch of a top+bottom pair: both halves vs neighbors + the internal seam. */
export function scorePair(
  topSig: string,
  bottomSig: string,
  neighbors: NeighborSigs,
): number {
  return (
    scoreCandidate(topSig, 'top', neighbors) +
    scoreCandidate(bottomSig, 'bottom', neighbors) +
    internalSeam(topSig, bottomSig)
  );
}

/**
 * Suggest the best top+bottom pairs. Bounds work by taking the K best tops and K
 * best bottoms by their own half score, then scoring the K×K combinations.
 */
export function suggestPairs(
  table: WalkabilityTable,
  neighbors: NeighborSigs,
  count: number,
  k = 40,
  limit = 12,
): SuggestedPair[] {
  const tops = rankSections(table, 'top', neighbors, count).slice(0, k);
  const bottoms = rankSections(table, 'bottom', neighbors, count).slice(0, k);
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

- [ ] **Step 4: Run test to verify it passes**

Run: `cd projects/TMOS_Randomizer_V2/ui && npm test -- src/components/screen/tileFilter.test.ts`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/tileFilter.ts projects/TMOS_Randomizer_V2/ui/src/components/screen/tileFilter.test.ts
git commit -m "feat(tiles): add pure tileFilter collision-ranking util"
```

---

### Task 4: Client method + store loader

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/api/client.ts`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/store/index.ts`

**Interfaces:**
- Produces: `api.getTileSectionWalkability(): Promise<TileSectionWalkabilityResponse>` where `TileSectionWalkabilityResponse = { sections: Record<string,string> }`; store fields `tileWalkability: Record<string,string> | null`, `tileWalkabilityLoading: boolean`, action `loadTileWalkability(): Promise<void>` (lazy, session-cached).

- [ ] **Step 1: Add the client method**

In `ui/src/api/client.ts`, add the response type near the other tile types (e.g. after `EdgeWalkabilityResponse`):

```ts
export interface TileSectionWalkabilityResponse {
  sections: Record<string, string>;  // global index -> 32-char walkability signature
}
```

And add this method inside the `ApiClient` class (next to `getObjectSetEnemies`):

```ts
  // Intrinsic walkability signatures for all 471 sections (read-only, cached server-side).
  async getTileSectionWalkability(): Promise<TileSectionWalkabilityResponse> {
    return this.fetch<TileSectionWalkabilityResponse>(`/api/rom/tilesection-walkability`);
  }
```

- [ ] **Step 2: Add store state + loader**

In `ui/src/store/index.ts`:

Add to the `RandomizerState` interface (near `selectedTileIndex`):

```ts
  tileWalkability: Record<string, string> | null;
  tileWalkabilityLoading: boolean;
```

Add to the actions section of the interface (near `loadTileBankData`):

```ts
  loadTileWalkability: () => Promise<void>;
```

Add to the initial state (near `tileBankData: null,`):

```ts
  tileWalkability: null,
  tileWalkabilityLoading: false,
```

Add the action implementation (near `loadTileBankData`):

```ts
  loadTileWalkability: async () => {
    if (get().tileWalkability || get().tileWalkabilityLoading) return;
    set({ tileWalkabilityLoading: true });
    try {
      const r = await api.getTileSectionWalkability();
      set({ tileWalkability: r.sections, tileWalkabilityLoading: false });
    } catch (e) {
      console.error('Failed to load tilesection walkability', e);
      set({ tileWalkabilityLoading: false });
    }
  },
```

- [ ] **Step 3: Typecheck + tests**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit && npm test`
Expected: 0 type errors; existing suites (incl. `tileFilter`) green.

- [ ] **Step 4: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/api/client.ts projects/TMOS_Randomizer_V2/ui/src/store/index.ts
git commit -m "feat(tiles): client + store for tilesection walkability table"
```

---

### Task 5: Collision filter UI in the modal (toggle + ranked/dimmed grid + summary)

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx`

**Interfaces:**
- Consumes: `tileFilter` (`rankSections`, `sectionPair`, `type NeighborSigs`, `type SectionPair`), store (`tileWalkability`, `loadTileWalkability`), existing `getBanks`, `TOTAL`, `SectionThumb`.
- Produces: extends `SectionThumb` with optional `dim?: boolean`, `badge?: number`, `perfect?: boolean`. (No prop-signature change to the modal in this task; the pair helper's `onPickPair` arrives in Task 6.)

- [ ] **Step 1: Add imports + load the table**

In `ScreenEditorModal.tsx`, add imports:

```ts
import { useRandomizerStore } from '../../store';
import {
  rankSections, sectionPair,
  type NeighborSigs, type SectionPair,
} from './tileFilter';
```

Inside the component (after the `currentGlobal` block, ~line 106), add:

```ts
  const tileWalkability = useRandomizerStore((s) => s.tileWalkability);
  const loadTileWalkability = useRandomizerStore((s) => s.loadTileWalkability);
  const [collisionFilter, setCollisionFilter] = useState(false);

  useEffect(() => {
    loadTileWalkability();
  }, [loadTileWalkability]);

  // Resolve the four neighbors' section signatures from the walkability table.
  const neighbors = useMemo<NeighborSigs>(() => {
    const table = tileWalkability;
    const resolve = (navVal: number): SectionPair | null => {
      if (!table) return null;
      const n = byIndex.get(navVal);
      if (!n) return null; // blocked (0xFF) / building (0xFE) / no such screen
      const nb = getBanks(n.datapointer);
      return sectionPair(table, nb.top * 256 + n.top_tiles, nb.bottom * 256 + n.bottom_tiles);
    };
    return {
      up: resolve(screen.nav_up),
      down: resolve(screen.nav_down),
      left: resolve(screen.nav_left),
      right: resolve(screen.nav_right),
    };
  }, [tileWalkability, byIndex, screen]);

  // Ordered list of {globalIndex, mismatch}. Filter off → natural 0..470 order.
  const filterOn = collisionFilter && tileWalkability != null;
  const ordered = useMemo(() => {
    if (filterOn) return rankSections(tileWalkability!, activeHalf, neighbors, TOTAL);
    return indices.map((g) => ({ globalIndex: g, mismatch: 0 }));
  }, [filterOn, tileWalkability, activeHalf, neighbors, indices]);

  // Which neighbor directions the active half is ranked against, split present/skipped.
  const summary = useMemo(() => {
    const dirs: { key: keyof NeighborSigs; label: string }[] =
      activeHalf === 'top'
        ? [{ key: 'up', label: '↑ up' }, { key: 'left', label: '← left' }, { key: 'right', label: '→ right' }]
        : [{ key: 'down', label: '↓ down' }, { key: 'left', label: '← left' }, { key: 'right', label: '→ right' }];
    const present = dirs.filter((d) => neighbors[d.key]).map((d) => d.label);
    const skipped = dirs.filter((d) => !neighbors[d.key]).map((d) => d.label);
    return { present, skipped };
  }, [activeHalf, neighbors]);
```

- [ ] **Step 2: Add the toggle + summary above the grid**

Replace the grid container opening (the `<div className="flex-1 overflow-y-auto p-3 grid ...">` block, lines ~234-249) so a header row precedes it. Insert this **immediately before** that grid `<div>`:

```tsx
        <div className="flex-1 flex flex-col min-w-0">
          <div className="flex items-center gap-3 px-3 pt-3 text-xs">
            <label className="flex items-center gap-1.5 text-slate-300 cursor-pointer">
              <input
                type="checkbox"
                checked={collisionFilter}
                disabled={tileWalkability == null}
                onChange={(e) => setCollisionFilter(e.target.checked)}
              />
              Filter: collision
            </label>
            {tileWalkability == null && <span className="text-slate-500">loading…</span>}
            {filterOn && (
              <span className="text-slate-500">
                Ranked vs {summary.present.join(', ') || '(no neighbors)'}
                {summary.skipped.length > 0 && ` — ${summary.skipped.join(', ')} skipped`}
                {' '}({activeHalf} half)
              </span>
            )}
          </div>
```

Then change the existing grid `<div>` to map `ordered` instead of `indices` and pass the new props:

```tsx
          <div
            className="flex-1 overflow-y-auto p-3 grid gap-2 content-start"
            style={{ gridTemplateColumns: 'repeat(auto-fill, 150px)', gridAutoRows: '75px' }}
          >
            {ordered.map(({ globalIndex: g, mismatch }) => (
              <SectionThumb
                key={g}
                globalIndex={g}
                chr={chr}
                selected={g === currentGlobal}
                crossBank={g >= 256}
                shadeBottomRows={activeHalf === 'bottom'}
                dim={filterOn && mismatch > 0}
                badge={filterOn && mismatch > 0 ? mismatch : undefined}
                perfect={filterOn && mismatch === 0}
                onClick={() => onTilePick(activeHalf, g)}
              />
            ))}
          </div>
        </div>
```

(The extra wrapping `<div className="flex-1 flex flex-col min-w-0">` replaces the grid's old `flex-1` so the header + grid stack; close it after the grid as shown.)

- [ ] **Step 3: Extend `SectionThumb`**

Update `SectionThumb`'s props and rendering. Change its signature to add the three optional props:

```tsx
function SectionThumb({
  globalIndex, chr, selected, crossBank, shadeBottomRows, dim, badge, perfect, onClick,
}: {
  globalIndex: number;
  chr: number;
  selected: boolean;
  crossBank: boolean;
  shadeBottomRows?: boolean;
  dim?: boolean;
  badge?: number;
  perfect?: boolean;
  onClick: () => void;
}) {
```

In its `<button>` className, add the perfect-fit ring and dimming. Replace the className expression with:

```tsx
      className={`relative rounded overflow-hidden border transition-all ${
        selected
          ? 'border-yellow-400 ring-2 ring-yellow-400'
          : perfect
          ? 'border-emerald-400 ring-1 ring-emerald-400'
          : 'border-slate-700 hover:border-blue-400'
      } ${dim ? 'opacity-40' : ''}`}
```

And add a mismatch badge next to the existing index label (after the `<span>` that shows `{globalIndex}{crossBank ? '*' : ''}`):

```tsx
      {badge !== undefined && (
        <span className="absolute top-0 right-0 bg-amber-600/90 text-white text-[8px] font-mono px-1">
          ⚠{badge}
        </span>
      )}
```

- [ ] **Step 4: Verify**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit && npm run lint && npm test`
Expected: 0 type errors; no new lint errors in `ScreenEditorModal.tsx`; tests green.

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx
git commit -m "feat(tiles): collision filter toggle + ranked/dimmed picker grid"
```

---

### Task 6: Pair helper panel + atomic apply

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx`
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/views/WorldView.tsx`

**Interfaces:**
- Consumes: `suggestPairs` (`tileFilter`), the `neighbors`/`tileWalkability` from Task 5, `api.getTileSectionPreviewUrl`.
- Produces: new modal prop `onPickPair?: (topGlobal: number, bottomGlobal: number) => void`; `WorldView` wires it to a single `updateScreenTiles(index, { top_tiles, bottom_tiles })` (one atomic PATCH, avoiding a two-call race).

- [ ] **Step 1: Add the `onPickPair` prop**

In `ScreenEditorModal.tsx`, add to `ScreenEditorModalProps` (after `onTilePick`):

```ts
  onPickPair?: (topGlobal: number, bottomGlobal: number) => void;
```

Add `onPickPair` to the destructured params, and import `suggestPairs`:

```ts
import {
  rankSections, sectionPair, suggestPairs,
  type NeighborSigs, type SectionPair,
} from './tileFilter';
```

Add pair state + computation (after the `summary` memo):

```ts
  const [showPairs, setShowPairs] = useState(false);
  const pairs = useMemo(() => {
    if (!showPairs || tileWalkability == null) return [];
    return suggestPairs(tileWalkability, neighbors, TOTAL);
  }, [showPairs, tileWalkability, neighbors]);
```

- [ ] **Step 2: Add the "Suggest pairs" button + panel**

In the toggle header row (Task 5, Step 2), add a button after the summary span:

```tsx
            <button
              type="button"
              disabled={tileWalkability == null}
              onClick={() => setShowPairs((v) => !v)}
              className="ml-auto px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 text-slate-200 disabled:opacity-40"
            >
              {showPairs ? 'Hide pairs' : 'Suggest pairs'}
            </button>
```

Add the panel directly below that header row (before the picker grid `<div>`):

```tsx
          {showPairs && (
            <div className="px-3 py-2 border-b border-slate-700 bg-slate-900/40">
              {pairs.length === 0 ? (
                <div className="text-xs text-slate-500">No suggestions available.</div>
              ) : (
                <div className="flex gap-2 overflow-x-auto">
                  {pairs.map((p) => (
                    <button
                      key={`${p.top}-${p.bottom}`}
                      type="button"
                      onClick={() => onPickPair?.(p.top, p.bottom)}
                      className="flex-shrink-0 rounded border border-slate-700 hover:border-emerald-400 p-1"
                      title={`Top ${p.top} + Bottom ${p.bottom} — ${p.mismatch} mismatches`}
                    >
                      <div className="flex flex-col w-[80px]">
                        <img src={api.getTileSectionPreviewUrl(p.top, chr, 2)} alt={`top ${p.top}`} className="w-full h-[40px] object-contain" />
                        <img src={api.getTileSectionPreviewUrl(p.bottom, chr, 2)} alt={`bottom ${p.bottom}`} className="w-full h-[20px] object-contain" />
                        <span className="text-[9px] text-center text-slate-400">⚠{p.mismatch}</span>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          )}
```

- [ ] **Step 3: Wire `onPickPair` in `WorldView`**

In `ui/src/components/views/WorldView.tsx`, on the `<ScreenEditorModal ... />` element, add (next to `onTilePick`):

```tsx
          onPickPair={(topGlobal, bottomGlobal) => {
            updateScreenTiles(editor.index, {
              top_tiles: topGlobal,
              bottom_tiles: bottomGlobal,
            }).catch(() => {
              // store surfaces the failure via apiError
            });
          }}
```

- [ ] **Step 4: Verify**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit && npm run build && npm run lint && npm test`
Expected: 0 type errors; build succeeds; no new lint errors; tests green.

- [ ] **Step 5: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx projects/TMOS_Randomizer_V2/ui/src/components/views/WorldView.tsx
git commit -m "feat(tiles): suggest-pairs panel with atomic both-halves apply"
```

---

### Task 7: Full verification

**Files:** none (verification only).

- [ ] **Step 1: Backend + frontend suites**

Run:
```bash
cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_tilesection_walkability.py tests/test_tilesection_walkability_endpoint.py -v
cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit && npm run build && npm run lint && npm test
```
Expected: backend tests pass; tsc 0 errors; build succeeds; tests green.

- [ ] **Step 2: Manual smoke test**

Start the backend (`tmos-randomize serve`) + `npm run dev`, load a ROM, open a screen's editor:
1. Filter off → grid is the natural 0..470 order (unchanged from today).
2. Toggle **Filter: collision** on → perfect-fit sections sort first with an emerald ring; incompatible ones are dimmed with a `⚠N` badge; the summary line names the matched/skipped directions.
3. Flip the active half (top↔bottom) → ranking switches to the down/lower neighbors and the summary updates.
4. Pick a dimmed section → still applies (nothing is blocked).
5. **Suggest pairs** → shows up to 12 top+bottom previews; clicking one applies both halves in a single update.
6. A screen with all-blocked neighbors still shows the full grid (never empty).

- [ ] **Step 3: Final commit (only if manual QA required tweaks)**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenEditorModal.tsx
git commit -m "fix(tiles): polish collision filter after manual QA"
```

---

## Self-Review Notes

- **Spec coverage:** precompute endpoint (Task 2) ✔; per-section grids not edges (Task 1/2) ✔; client+store table (Task 4) ✔; pure `tileFilter` with active-half edge model + per-position compat + rank/dim never-hide (Task 3/5) ✔; neighbor resolution via `getBanks` + skip 0xFF/0xFE (Task 5) ✔; summary line (Task 5) ✔; pair helper with internal seam + K-cap + atomic apply (Task 3/6) ✔; off-by-default + graceful loading (Task 5) ✔; reuse V2 primitives, no World-Editor import ✔.
- **Type consistency:** `NeighborSigs`/`SectionPair`/`RankedSection`/`SuggestedPair`, `rankSections`/`scoreCandidate`/`suggestPairs`/`sectionPair` signatures match between `tileFilter.ts` (Task 3) and its consumers (Tasks 5–6). `getTileSectionWalkability` response `{sections: Record<string,string>}` matches store + endpoint shape.
- **Honest gaps:** the filter aids collision/visual seams, not the randomizer's navigability graph (a picker aid, not a validator). Theme/biome coherence is deferred to Spec #3.
