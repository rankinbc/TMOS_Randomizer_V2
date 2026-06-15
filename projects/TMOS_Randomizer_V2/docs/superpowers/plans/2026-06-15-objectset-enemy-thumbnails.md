# ObjectSet Enemy Thumbnails (Stage B) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** In the World Screen editor's ObjectSet field, show the enemies a given ObjectSet spawns as sprite thumbnails, so the user knows what they are choosing.

**Architecture:** A read-only backend module parses an ObjectSet's spawn table from the raw ROM (per-chapter pointer table → spawn address → 3-byte header → `[type][x][y]` entries until a `0x00` terminator) and maps each enemy type byte to a name + sprite filename. One additive `GET` endpoint returns the enemy list. The frontend enhances the INTERNALS of the existing `ObjectSetField` seam (from Stage A) — fetching the list when `value`/`chapterNum` change and rendering a thumbnail strip — without changing the component's props or the modal.

**Tech Stack:** Python 3.13 / FastAPI (backend), React 19 + TypeScript + Vite (frontend). Backend tested with pytest (synthetic ROM unit test + skip-graceful `TestClient` endpoint test). Frontend verified live via Playwright.

**Parallel sibling:** `2026-06-15-world-screen-editor-modal.md` (Stage A) creates `ObjectSetField.tsx` with the locked contract `{ value, chapterNum, chr, onChange }`. This plan only adds to that component's body. The two share `server.py` and `client.ts` additively (different routes/methods), integrated by merging the two worktrees.

---

## The one real risk — spawn-data header (spike FIRST)

`knowledge/structures/objectset.md` documents the header as "variable, often 3 bytes," but all three worked examples in the doc use a **3-byte header**:
- ObjectSet `0x03` (Ch1): header `8A 00 00`, then four `11 ..` Robber entries.
- ObjectSet `0x05` (Ch1): spawn @ `0x38B55`, header `20 4D 00`, then four `11 ..` entries, then `00` terminator.
- ObjectSet `0x0B` (Ch1): spawn @ `0x38BA3`, header `24 7E 00`, then four `1C ..` Crab entries.

Task 1 is a read-only spike that dumps the real bytes and confirms the header length empirically before the parser is written. If the spike shows 3 bytes is correct for the sampled sets, the parser hard-codes a 3-byte header skip. The parser is defensive: it returns `[]` on out-of-range pointers or malformed data rather than guessing.

---

## File Structure

| File | Create/Modify | Responsibility |
|------|---------------|----------------|
| `tests/test_validation/test_objectset_enemies_spike.py` | Create (temporary) | Read-only spike that prints/asserts the spawn-header layout for known sets |
| `src/tmos_randomizer/core/overworld_enemies.py` | Create | `OVERWORLD_ENEMY_IMAGES`, `OBJECTSET_POINTER_TABLES`, `OBJECTSET_BASE`, `parse_objectset_enemy_types()` |
| `tests/test_validation/test_overworld_enemies.py` | Create | Unit test for `parse_objectset_enemy_types` on a synthetic ROM |
| `src/tmos_randomizer/api/server.py` | Modify | Add `GET /api/rom/objectset/{ch}/{objectset_id}/enemies` |
| `tests/test_integration/test_objectset_enemies_endpoint.py` | Create | TestClient endpoint test (skip-graceful) |
| `ui/src/api/client.ts` | Modify | `ObjectSetEnemiesResponse` type + `getObjectSetEnemies()` + `objectSetImageUrl()` |
| `ui/src/components/screen/ObjectSetField.tsx` | Modify | Fetch the enemy list and render a thumbnail strip (internals only) |

**Image assets:** sprite GIFs are already at `ui/public/sprites/OverworldEnemyImages/*.gif` (Vite-served at `/sprites/OverworldEnemyImages/<file>`). Confirmed filenames include: `gargoyle.gif`, `barzil.gif`, `mardul.gif`, `changral.gif`, `wasp.gif`, `flower.gif`, `grimreaper.gif`, `centipede.gif`, `boulder.gif`, `log.gif`, `eviltree.gif`, `djinni.gif`, `pirahna.gif`, `fish.gif`, `thief1.gif`, `vampirethief.gif`, `sandbeast.gif`, `reddragon.gif`, `antlion.gif`, `kibra.gif`, `camel1.gif`, `skeleton1.gif`.

---

## Task 1: Spike — confirm the spawn-data header length (read-only)

**Files:**
- Create: `tests/test_validation/test_objectset_enemies_spike.py` (temporary — deleted in Task 2 step 5)

- [ ] **Step 1: Write the spike**

Create `tests/test_validation/test_objectset_enemies_spike.py`:

```python
"""SPIKE (read-only, temporary): confirm the ObjectSet spawn-data header length.

Loads the default ROM if present; prints the raw bytes at the spawn addresses for
known World-1 ObjectSets and asserts the documented 3-byte-header / [type][x][y]
layout. Delete after the parser lands.

Per knowledge/structures/objectset.md:
  Ch1 pointer table @ 0x38933, base 0x37000, pointers little-endian.
  ObjectSet 0x05 spawn @ 0x38B55, header 20 4D 00, then 11.. x4, then 00.
  ObjectSet 0x0B spawn @ 0x38BA3, header 24 7E 00, then 1C.. x4.
"""
import pytest

from tmos_randomizer.api import server

PTR_TABLE_CH1 = 0x38933
BASE = 0x37000


def _rom():
    # Reuse the server's load path so we exercise the same bytes the endpoint will.
    from fastapi.testclient import TestClient
    c = TestClient(server.app)
    if c.post("/api/rom/load-default").status_code != 200:
        pytest.skip("default ROM not available")
    rom = server._rom_data
    if rom is None:
        pytest.skip("ROM bytes not available on server module")
    return rom


def _spawn_addr(rom, objectset_id):
    p = PTR_TABLE_CH1 + objectset_id * 2
    ptr = rom[p] | (rom[p + 1] << 8)
    return BASE + ptr


def test_spike_header_is_three_bytes():
    rom = _rom()
    for osid, first_type in ((0x05, 0x11), (0x0B, 0x1C)):
        addr = _spawn_addr(rom, osid)
        window = bytes(rom[addr:addr + 16])
        print(f"ObjectSet 0x{osid:02X} @ 0x{addr:05X}: {window.hex(' ')}")
        # With a 3-byte header, byte index 3 is the first enemy type.
        assert window[3] == first_type, (
            f"Expected first entry type 0x{first_type:02X} at offset 3, "
            f"got 0x{window[3]:02X} (header may not be 3 bytes)"
        )
        # Entries are 3-byte stride: next type at offset 6 should be the same enemy.
        assert window[6] == first_type
```

- [ ] **Step 2: Run the spike**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_validation/test_objectset_enemies_spike.py -v -s`
Expected: PASS (prints the byte windows), or skip if no ROM. **Read the printed bytes.** Confirm the header is 3 bytes. If the assertion fails, STOP and investigate the real layout (switch to systematic-debugging) before writing the parser — do not guess.

- [ ] **Step 3: Commit the spike result as a note**

```bash
git add tests/test_validation/test_objectset_enemies_spike.py
git commit -m "test(spike): confirm ObjectSet spawn header is 3 bytes (Stage B)"
```

---

## Task 2: Backend parser module

**Files:**
- Create: `src/tmos_randomizer/core/overworld_enemies.py`
- Test: `tests/test_validation/test_overworld_enemies.py`
- Delete: `tests/test_validation/test_objectset_enemies_spike.py` (no longer needed once the parser is covered)

- [ ] **Step 1: Write the failing unit test**

Create `tests/test_validation/test_overworld_enemies.py`:

```python
"""Unit tests for parse_objectset_enemy_types on a synthetic ROM."""
from tmos_randomizer.core.overworld_enemies import (
    parse_objectset_enemy_types,
    OBJECTSET_POINTER_TABLES,
    OBJECTSET_BASE,
    OVERWORLD_ENEMY_IMAGES,
)


def _build_rom(objectset_id, spawn_rel, header, entries):
    """Build a sparse ROM (bytearray) with one pointer-table entry + spawn block."""
    rom = bytearray(0x40000)
    ptr_table = OBJECTSET_POINTER_TABLES[1]
    p = ptr_table + objectset_id * 2
    rom[p] = spawn_rel & 0xFF
    rom[p + 1] = (spawn_rel >> 8) & 0xFF
    addr = OBJECTSET_BASE + spawn_rel
    block = bytes(header) + bytes(entries) + b"\x00"  # terminator
    rom[addr:addr + len(block)] = block
    return bytes(rom)


def test_parses_three_byte_header_and_entries():
    # Header 20 4D 00, then four Robber (0x11) entries, then terminator.
    entries = [0x11, 0x20, 0x24, 0x11, 0x10, 0xA4, 0x11, 0x10, 0xA8, 0x11, 0x10, 0x6C]
    rom = _build_rom(0x05, 0x1B55, [0x20, 0x4D, 0x00], entries)
    types = parse_objectset_enemy_types(rom, chapter=1, objectset_id=0x05)
    assert types == [0x11, 0x11, 0x11, 0x11]


def test_terminator_stops_reading():
    entries = [0x18, 0x40, 0x40]  # one Gargoyle
    rom = _build_rom(0x03, 0x1B3B, [0x8A, 0x00, 0x00], entries)
    types = parse_objectset_enemy_types(rom, chapter=1, objectset_id=0x03)
    assert types == [0x18]


def test_out_of_range_pointer_returns_empty():
    rom = bytes(0x40000)  # all zero → pointer 0 → spawn at BASE, type 0x00 → []
    types = parse_objectset_enemy_types(rom, chapter=1, objectset_id=0x05)
    assert types == []


def test_short_rom_returns_empty():
    types = parse_objectset_enemy_types(b"\x00" * 16, chapter=1, objectset_id=0x05)
    assert types == []


def test_image_map_filenames_are_known():
    # Every mapped image must be one of the real sprite filenames (sanity).
    for entry in OVERWORLD_ENEMY_IMAGES.values():
        assert "name" in entry and "image" in entry
        if entry["image"] is not None:
            assert entry["image"].endswith(".gif")
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_validation/test_overworld_enemies.py -v`
Expected: FAIL with `ModuleNotFoundError: tmos_randomizer.core.overworld_enemies`.

- [ ] **Step 3: Write the module**

Create `src/tmos_randomizer/core/overworld_enemies.py`:

```python
"""Read-only parsing of ObjectSet enemy spawn data + enemy-type → sprite map.

Source: knowledge/structures/objectset.md (ROM_VERIFIED). Per-chapter pointer
tables index spawn data at OBJECTSET_BASE; each spawn block is a 3-byte header
followed by 3-byte [type][x][y] entries terminated by type 0x00.
"""
from __future__ import annotations

# Per-chapter ObjectSet pointer tables (ROM offsets) and the shared base address.
OBJECTSET_POINTER_TABLES: dict[int, int] = {
    1: 0x38933,
    2: 0x389A9,
    3: 0x38A1F,
    4: 0x38A95,
    5: 0x38B0B,
}
OBJECTSET_BASE = 0x37000

# Spawn-block header length, confirmed by the Task 1 spike.
_HEADER_LEN = 3
# Defensive cap on entries read (a spawn block is small).
_MAX_ENTRIES = 16

# Enemy type byte → display name + sprite filename (under
# ui/public/sprites/OverworldEnemyImages/). Names from objectset.md / enemies.md;
# filenames cross-referenced with the actual asset directory. Types without a
# confident sprite match map image=None (the UI shows a name chip instead).
OVERWORLD_ENEMY_IMAGES: dict[int, dict] = {
    0x11: {"name": "Robber/Thief", "image": "thief1.gif"},
    0x13: {"name": "MazeThings", "image": None},
    0x14: {"name": "KillerFlower", "image": "flower.gif"},
    0x15: {"name": "DesertCrab", "image": "sandbeast.gif"},
    0x16: {"name": "SineWave", "image": None},
    0x17: {"name": "WormHouse", "image": None},
    0x18: {"name": "Gargoyle", "image": "gargoyle.gif"},
    0x19: {"name": "SwampSplitter", "image": None},
    0x1A: {"name": "JumpAttacker", "image": None},
    0x1C: {"name": "Crab", "image": "sandbeast.gif"},
    0x1D: {"name": "Bee/GiantWasp", "image": "wasp.gif"},
    0x20: {"name": "RedGrimReaper", "image": "grimreaper.gif"},
    0x28: {"name": "Changarl", "image": "changral.gif"},
    0x30: {"name": "Mardul", "image": "mardul.gif"},
    0x31: {"name": "Barzil", "image": "barzil.gif"},
    0x34: {"name": "Spawner", "image": None},
    0x35: {"name": "SlowMover", "image": None},
    0x36: {"name": "CenterBigThing", "image": None},
    0x37: {"name": "ScreenMoves", "image": None},
    0x39: {"name": "ScreenFireballs", "image": "fireball.gif"},
}


def enemy_info(type_byte: int) -> dict:
    """Return {name, image} for a type byte; unknown types get a hex name + None."""
    info = OVERWORLD_ENEMY_IMAGES.get(type_byte)
    if info is not None:
        return info
    return {"name": f"Type 0x{type_byte:02X}", "image": None}


def parse_objectset_enemy_types(rom: bytes, chapter: int, objectset_id: int) -> list[int]:
    """Return the list of enemy type bytes spawned by an ObjectSet.

    Defensive: returns [] on unknown chapter, out-of-range pointer, or truncated
    ROM rather than raising.
    """
    table = OBJECTSET_POINTER_TABLES.get(chapter)
    if table is None:
        return []
    if not (0 <= objectset_id <= 255):
        return []

    p = table + objectset_id * 2
    if p + 1 >= len(rom):
        return []
    ptr = rom[p] | (rom[p + 1] << 8)
    addr = OBJECTSET_BASE + ptr + _HEADER_LEN

    types: list[int] = []
    for _ in range(_MAX_ENTRIES):
        if addr + 2 >= len(rom):
            break
        type_byte = rom[addr]
        if type_byte == 0x00:
            break
        types.append(type_byte)
        addr += 3
    return types
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_validation/test_overworld_enemies.py -v`
Expected: PASS (5 tests).

- [ ] **Step 5: Remove the now-redundant spike and commit**

```bash
git rm tests/test_validation/test_objectset_enemies_spike.py
git add src/tmos_randomizer/core/overworld_enemies.py tests/test_validation/test_overworld_enemies.py
git commit -m "feat(core): parse ObjectSet enemy spawn types + sprite map (Stage B)"
```

---

## Task 3: Backend endpoint

**Files:**
- Modify: `src/tmos_randomizer/api/server.py` (add the endpoint near the other `/api/rom/screen` / tilesection routes, e.g. after the tilesection render endpoint ~line 815)
- Test: `tests/test_integration/test_objectset_enemies_endpoint.py`

- [ ] **Step 1: Write the failing endpoint test**

Create `tests/test_integration/test_objectset_enemies_endpoint.py`:

```python
"""Endpoint test for the ObjectSet enemies API (Stage B). Skip-graceful."""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    if c.post("/api/rom/load-default").status_code != 200:
        pytest.skip("default ROM not available")
    return c


def test_objectset_enemies_ok(client):
    # World 1 ObjectSet 0x05 = four Robbers per objectset.md.
    resp = client.get("/api/rom/objectset/1/5/enemies")
    assert resp.status_code == 200
    body = resp.json()
    assert body["chapter"] == 1
    assert body["objectset_id"] == 5
    assert isinstance(body["enemies"], list)
    assert len(body["enemies"]) >= 1
    first = body["enemies"][0]
    assert {"type", "name", "image"} <= set(first.keys())


def test_objectset_enemies_out_of_range(client):
    resp = client.get("/api/rom/objectset/1/999/enemies")
    assert resp.status_code == 400


def test_objectset_enemies_bad_chapter(client):
    resp = client.get("/api/rom/objectset/9/5/enemies")
    # Unknown chapter → empty list (parser returns []), still 200.
    assert resp.status_code == 200
    assert resp.json()["enemies"] == []
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_integration/test_objectset_enemies_endpoint.py -v`
Expected: FAIL (404 route missing) or skip if no ROM.

- [ ] **Step 3: Add the endpoint**

In `src/tmos_randomizer/api/server.py`, after the tilesection render endpoint (~line 815), add:

```python
@app.get("/api/rom/objectset/{chapter_num}/{objectset_id}/enemies")
async def get_objectset_enemies(chapter_num: int, objectset_id: int):
    """Return the enemies an ObjectSet spawns, with sprite filenames (read-only)."""
    from ..core.overworld_enemies import parse_objectset_enemy_types, enemy_info

    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    if objectset_id < 0 or objectset_id > 255:
        raise HTTPException(status_code=400, detail="objectset_id must be 0-255")

    types = parse_objectset_enemy_types(_rom_data, chapter_num, objectset_id)
    enemies = []
    for t in types:
        info = enemy_info(t)
        enemies.append({"type": t, "name": info["name"], "image": info["image"]})
    return {"chapter": chapter_num, "objectset_id": objectset_id, "enemies": enemies}
```

Note: `_rom_data` is the module-level working-copy ROM bytes (set in the upload/load-default handlers). It is the correct source for raw-offset parsing.

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_integration/test_objectset_enemies_endpoint.py -v`
Expected: PASS (or skip if no ROM — confirm no import/collection errors).

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/api/server.py tests/test_integration/test_objectset_enemies_endpoint.py
git commit -m "feat(api): add GET objectset enemies endpoint (Stage B)"
```

---

## Task 4: Frontend client method + image URL helper

**Files:**
- Modify: `ui/src/api/client.ts`

- [ ] **Step 1: Add the response type**

In `ui/src/api/client.ts`, after the `ScreenTilesUpdateResponse` interface (line 140), add:

```typescript
export interface ObjectSetEnemy {
  type: number;
  name: string;
  image: string | null;   // bare filename under /sprites/OverworldEnemyImages/, or null
}

export interface ObjectSetEnemiesResponse {
  chapter: number;
  objectset_id: number;
  enemies: ObjectSetEnemy[];
}
```

- [ ] **Step 2: Add the method + URL helper**

In `ui/src/api/client.ts`, after the `getTileSectionPreviewUrl` method (line 716), add inside the `ApiClient` class:

```typescript
  // ObjectSet enemy spawns (read-only).
  async getObjectSetEnemies(
    chapterNum: number,
    objectsetId: number
  ): Promise<ObjectSetEnemiesResponse> {
    return this.fetch<ObjectSetEnemiesResponse>(
      `/api/rom/objectset/${chapterNum}/${objectsetId}/enemies`
    );
  }

  // Vite-served overworld enemy sprite (public/sprites/...). Not under baseUrl.
  objectSetImageUrl(file: string): string {
    return `/sprites/OverworldEnemyImages/${file}`;
  }
```

- [ ] **Step 3: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond the pre-existing baseline (8 errors).

- [ ] **Step 4: Commit**

```bash
git add ui/src/api/client.ts
git commit -m "feat(ui): add getObjectSetEnemies client method + sprite URL helper"
```

---

## Task 5: Enhance `ObjectSetField` with a thumbnail strip

**Files:**
- Modify: `ui/src/components/screen/ObjectSetField.tsx` (created by Stage A — this layers fetch + strip into its body; props unchanged)

**Integration note:** this task depends on Stage A's `ObjectSetField.tsx` existing. When merging the two worktrees, Stage A's version is the base; apply this task's changes on top.

- [ ] **Step 1: Add fetch state and the thumbnail strip**

Edit `ui/src/components/screen/ObjectSetField.tsx`. Add imports at the top:

```tsx
import { useEffect, useState } from 'react';
import { api } from '../../api/client';
import type { ObjectSetEnemy } from '../../api/client';
```

Inside the `ObjectSetField` function, after the existing `const hex = ...` line and before the `return`, add the fetch effect:

```tsx
  const [enemies, setEnemies] = useState<ObjectSetEnemy[]>([]);

  useEffect(() => {
    let cancelled = false;
    // Debounce rapid value changes (number-input typing) by a short delay.
    const handle = setTimeout(() => {
      api
        .getObjectSetEnemies(chapterNum, value)
        .then((r) => { if (!cancelled) setEnemies(r.enemies); })
        .catch(() => { if (!cancelled) setEnemies([]); });
    }, 150);
    return () => { cancelled = true; clearTimeout(handle); };
  }, [chapterNum, value]);
```

Then remove the `void chapterNum; void chr;` lines (Stage A added them so the seam compiled without consumers — Stage B now consumes `chapterNum`; `chr` remains reserved, so keep a single `void chr;`).

- [ ] **Step 2: Render the strip below the select/input**

Wrap the existing returned row so the strip renders beneath it. Replace the outer `return ( <div className="flex items-center justify-between ...">...</div> )` with a vertical container that keeps the original row, then adds the strip:

```tsx
  return (
    <div className="space-y-1">
      <div className="flex items-center justify-between gap-2 text-sm">
        {/* ...the existing label + select + number input, unchanged... */}
      </div>
      {enemies.length > 0 && (
        <div className="flex flex-wrap gap-1 pl-1">
          {enemies.map((e, i) => (
            <div key={`${e.type}-${i}`} title={`${e.name} (0x${e.type.toString(16).toUpperCase()})`} className="flex flex-col items-center">
              {e.image ? (
                <img
                  src={api.objectSetImageUrl(e.image)}
                  alt={e.name}
                  className="w-7 h-7 object-contain"
                  style={{ imageRendering: 'pixelated' }}
                  onError={(ev) => { ev.currentTarget.style.display = 'none'; }}
                />
              ) : (
                <span className="text-[8px] text-slate-400 px-1 py-0.5 bg-slate-700 rounded">
                  {e.name}
                </span>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
```

Keep the inner label/select/input markup exactly as Stage A wrote it (move it verbatim into the inner `<div className="flex items-center justify-between ...">`).

- [ ] **Step 3: Typecheck**

Run: `cd projects/TMOS_Randomizer_V2/ui && npx tsc -b --noEmit`
Expected: No new errors beyond baseline.

- [ ] **Step 4: Commit**

```bash
git add ui/src/components/screen/ObjectSetField.tsx
git commit -m "feat(ui): show enemy sprite thumbnails in ObjectSetField (Stage B)"
```

---

## Task 6: Live verification (Playwright)

**Files:** none (verification only). Use the `verify` skill.

- [ ] **Step 1: Start throwaway backend + UI on fresh ports (load default ROM)**

Backend (background): `cd projects/TMOS_Randomizer_V2 && python -m uvicorn tmos_randomizer.api.server:app --port 8101`
Load ROM: `curl -s -X POST http://localhost:8101/api/rom/load-default` → expect 200.
UI (background): `cd projects/TMOS_Randomizer_V2/ui && VITE_API_URL=http://localhost:8101 npx vite --port 5101`

- [ ] **Step 2: Sanity-check the endpoint directly**

Run: `curl -s http://localhost:8101/api/rom/objectset/1/5/enemies`
Expected: JSON with `enemies` containing ≥1 entry, each `{type,name,image}`. Capture the output.

- [ ] **Step 3: Drive the UI and capture evidence**

Open `http://localhost:5101`, select a Chapter-1 screen whose ObjectSet is a known overworld set (e.g. 0x05 "4 Robbers"), open the editor (Stage A modal), and confirm the ObjectSet field shows a thumbnail strip. Screenshot it. Then change the ObjectSet number input to another value (e.g. 0x0B Crabs) and confirm the strip updates.

- [ ] **Step 4: Probe edge cases**

- ObjectSet `0x00` (Empty) → no thumbnails, field still usable.
- An ObjectSet whose types have no sprite (image=None) → name chips render instead of broken images.
- A missing image file → the `<img>` onError hides it (no broken-image icon).

- [ ] **Step 5: Report**

Produce a verification report (PASS/FAIL) with the endpoint JSON + screenshots inline. On failure, switch to systematic-debugging.

---

## Self-Review (completed during planning)

- **Spec coverage:** read-only spike first (Task 1), `overworld_enemies.py` with the three required exports + parser (Task 2), `GET .../enemies` endpoint returning `{chapter, objectset_id, enemies:[{type,name,image}]}` (Task 3), `getObjectSetEnemies` + `objectSetImageUrl` (Task 4), thumbnail strip inside `ObjectSetField` with props unchanged + graceful empty/missing handling (Task 5). ✓
- **Type consistency:** `ObjectSetEnemy`/`ObjectSetEnemiesResponse` defined in Task 4, imported in Task 5. Backend `enemy_info`/`parse_objectset_enemy_types` names match between Task 2 (definition) and Task 3 (import). `_rom_data` is the raw-bytes source (matches server.py globals). ✓
- **Seam safety:** Task 5 changes only `ObjectSetField` internals; the `{value, chapterNum, chr, onChange}` contract is untouched, so the Stage A modal is unaffected. ✓
- **Risk handling:** parser is defensive (returns `[]`), header length is spike-confirmed before use, UI degrades gracefully on empty/error. ✓
