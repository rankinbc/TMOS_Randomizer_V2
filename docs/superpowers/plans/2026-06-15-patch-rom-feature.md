# Patch ROM Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Patch ROM" action that downloads an edited `.nes` containing every modification made in the session (table edits + screen/navigation/randomization edits), plus an optional human-readable edit-log `.txt`.

**Architecture:** Approach B — flush-on-edit. Make the server's `_rom_data` buffer the single source of truth: every WorldScreen mutation is serialized into `_rom_data` immediately via one helper, so the new `POST /api/rom/patch` endpoint simply streams `_rom_data` as a download (with a defensive reconcile and a non-blocking navigability check). The React UI gets an `api.patchRom()` call, a `PatchRomModal`, and a fixed Header button.

**Tech Stack:** Python 3.13, FastAPI, pytest + `fastapi.testclient.TestClient`; React + TypeScript + Zustand, Tailwind.

**Reference spec:** `docs/superpowers/specs/2026-06-15-patch-rom-feature-design.md`

**Working directory for all paths:** `projects/TMOS_Randomizer_V2/`

---

## Background the engineer needs

- `src/tmos_randomizer/api/server.py` holds module-level globals: `_rom_data: bytes` (mutable working copy), `_rom_vanilla: bytes` (immutable snapshot), `_game_world: GameWorld` (parsed WorldScreen objects), `_rom_filename: str`.
- Table-edit endpoints (tile bank, EXP, player stats, enemy stats, encounters, inventory caps) already write into `_rom_data` using the pattern `rom_array = bytearray(_rom_data); ...; _rom_data = bytes(rom_array)`.
- **Screen edits do NOT touch `_rom_data` today** — they only mutate WorldScreen objects in `_game_world`. The three mutation sites are the functions `update_screen_navigation`, `update_screen_tiles`, and `apply_plan_preview`.
- `_require_rom_pair() -> tuple[bytes, bytes]` raises `HTTPException(400, "No ROM loaded")` if `_rom_data is None`. Use it as the ROM guard.
- A `WorldScreen` has `.chapter` (int 1–5), `.relative_index` (int), `.to_bytes() -> bytes` (16 bytes), `.is_modified` (bool), `.mark_modified()`.
- `GameWorld` is iterable yielding chapters; each chapter has `.screens`. The idiom `for ch in _game_world for s in ch.screens if s.is_modified` already appears in the file.
- Constants: `CHAPTER_BASES: dict[int,int]` and `WORLDSCREEN_SIZE = 16` live in `src/tmos_randomizer/core/constants.py`. A screen's file offset is `CHAPTER_BASES[chapter] + relative_index * WORLDSCREEN_SIZE`.
- Tests use a module-scoped `TestClient(server.app)` fixture that `POST`s `/api/rom/load-default` and skips if it returns non-200. See `tests/test_integration/test_tilesection_endpoints.py` for the exact pattern.
- Relevant routes: `PATCH /api/rom/screen/{chapter}/{index}/navigation` (body `NavigationUpdate`, e.g. `{"parent_world": 7}`), `PATCH /api/rom/tilebank/{tile_index}` (body `{"minitiles":[TL,TR,BL,BR]}`, writes 4 bytes at `TILE_TABLE_ADDR + tile_index*4`), `GET /api/rom/exp-table`.
- `TILE_TABLE_ADDR` is already imported into `server.py`.

---

## File Structure

- **Modify** `src/tmos_randomizer/api/server.py`
  - Add `CHAPTER_BASES, WORLDSCREEN_SIZE` to the constants import.
  - Add module helper `_flush_screens(screens) -> int`.
  - Call `_flush_screens(...)` at the three mutation sites.
  - Add `POST /api/rom/patch` endpoint.
- **Create** `tests/test_integration/test_patch_rom.py` — backend tests.
- **Modify** `ui/src/api/client.ts` — add `patchRom()`.
- **Create** `ui/src/components/modals/PatchRomModal.tsx` — the patch dialog.
- **Modify** `ui/src/App.tsx` — mount `<PatchRomModal />`.
- **Modify** `ui/src/components/layout/Header.tsx` — wire the existing button.

---

## Task 1: Flush-on-edit — `_rom_data` becomes single source of truth

**Files:**
- Modify: `src/tmos_randomizer/api/server.py` (constants import; new `_flush_screens`; three call sites)
- Test: `tests/test_integration/test_patch_rom.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_integration/test_patch_rom.py`:

```python
"""Endpoint tests for the Patch ROM feature (flush-on-edit + /api/rom/patch).

Drives the real FastAPI app. Loads the default ROM and skips if unavailable,
matching the project's asset-dependent test pattern.
"""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server
from tmos_randomizer.core.constants import CHAPTER_BASES, WORLDSCREEN_SIZE


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    resp = c.post("/api/rom/load-default")
    if resp.status_code != 200:
        pytest.skip("default ROM not available")
    return c


def test_navigation_edit_flushes_into_rom_data(client):
    """After a screen edit, _rom_data must contain the new screen bytes."""
    # Edit chapter 1, screen 0: set parent_world to a known value.
    resp = client.patch(
        "/api/rom/screen/1/0/navigation", json={"parent_world": 7}
    )
    assert resp.status_code == 200

    screen = server._game_world.chapters[1].get_screen(0)
    assert screen.parent_world == 7

    off = CHAPTER_BASES[1] + 0 * WORLDSCREEN_SIZE
    assert server._rom_data[off:off + WORLDSCREEN_SIZE] == screen.to_bytes()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_integration/test_patch_rom.py::test_navigation_edit_flushes_into_rom_data -v`
Expected: FAIL — `_rom_data` slice still holds the vanilla screen bytes (the assertion `== screen.to_bytes()` fails), because navigation edits are not yet flushed.

- [ ] **Step 3: Add the constants import**

In `src/tmos_randomizer/api/server.py`, find the existing line:

```python
from ..core.constants import get_chr_index, TILE_TABLE_ADDR, TILE_COUNT, TILE_SIZE
```

Replace it with:

```python
from ..core.constants import (
    get_chr_index,
    TILE_TABLE_ADDR,
    TILE_COUNT,
    TILE_SIZE,
    CHAPTER_BASES,
    WORLDSCREEN_SIZE,
)
```

- [ ] **Step 4: Add the `_flush_screens` helper**

In `src/tmos_randomizer/api/server.py`, immediately after the `_require_rom_pair` function definition, add:

```python
def _flush_screens(screens) -> int:
    """Serialize modified WorldScreen objects into the live _rom_data buffer.

    This keeps _rom_data the single source of truth: every screen mutation is
    written back to its WorldScreen file offset so /api/rom/patch can stream
    _rom_data directly. Returns the number of screens written.
    """
    global _rom_data
    if _rom_data is None:
        return 0
    rom_array = bytearray(_rom_data)
    count = 0
    for s in screens:
        off = CHAPTER_BASES[s.chapter] + s.relative_index * WORLDSCREEN_SIZE
        rom_array[off:off + WORLDSCREEN_SIZE] = s.to_bytes()
        count += 1
    _rom_data = bytes(rom_array)
    return count
```

- [ ] **Step 5: Flush in `update_screen_navigation`**

In `update_screen_navigation`, find where the modified-screens set is finalized — just before the `result = []` line that builds the response (after the `for direction, target_index in directions_to_update:` loop). Insert:

```python
    # Flush edited screens into _rom_data (single source of truth).
    _flush_screens(s for i in modified_screens if (s := chapter.get_screen(i)))

```

(`modified_screens` is the existing set of touched indices, including the bidirectional neighbor.)

- [ ] **Step 6: Flush in `update_screen_tiles`**

In `update_screen_tiles`, immediately after the `screen.mark_modified()` line and before the `return {` statement, insert:

```python
    _flush_screens([screen])
```

- [ ] **Step 7: Flush in `apply_plan_preview`**

In `apply_plan_preview`, after `modified_count` has been computed and before the `return {` that reports `"status": "applied"`, insert:

```python
        # Flush all randomized/edited screens into _rom_data so a later
        # /api/rom/patch captures the applied plan.
        _flush_screens(s for ch in _game_world for s in ch.screens if s.is_modified)

```

- [ ] **Step 8: Run the test to verify it passes**

Run: `pytest tests/test_integration/test_patch_rom.py::test_navigation_edit_flushes_into_rom_data -v`
Expected: PASS.

- [ ] **Step 9: Run the existing integration tests to check for regressions**

Run: `pytest tests/test_integration/ -v`
Expected: PASS (or pre-existing skips for missing assets), no new failures.

- [ ] **Step 10: Commit**

```bash
git add src/tmos_randomizer/api/server.py tests/test_integration/test_patch_rom.py
git commit -m "feat(v2/api): flush screen edits into _rom_data (single source of truth)"
```

---

## Task 2: `POST /api/rom/patch` endpoint

**Files:**
- Modify: `src/tmos_randomizer/api/server.py` (new endpoint)
- Test: `tests/test_integration/test_patch_rom.py`

- [ ] **Step 1: Write the failing tests**

Append to `tests/test_integration/test_patch_rom.py`:

```python
def test_patch_streams_edited_rom(client):
    """Patch returns a full-length ROM reflecting both screen and table edits."""
    vanilla = bytes(server._rom_vanilla)

    # A screen edit (chapter 1, screen 1).
    client.patch("/api/rom/screen/1/1/navigation", json={"parent_world": 9})
    screen = server._game_world.chapters[1].get_screen(1)

    # A table edit: tile 0 minitiles -> [1, 2, 3, 4] (4 bytes at TILE_TABLE_ADDR).
    client.patch("/api/rom/tilebank/0", json={"minitiles": [1, 2, 3, 4]})

    resp = client.post("/api/rom/patch")
    assert resp.status_code == 200
    assert resp.headers["content-type"] == "application/octet-stream"
    assert "attachment" in resp.headers["content-disposition"]
    assert "X-Patch-Warnings" in resp.headers
    assert "X-Screens-Modified" in resp.headers

    patched = resp.content
    # Full ROM, header + length preserved.
    assert len(patched) == len(vanilla)
    assert patched[:16] == vanilla[:16]

    # Screen edit present at the WorldScreen offset.
    off = CHAPTER_BASES[1] + 1 * WORLDSCREEN_SIZE
    assert patched[off:off + WORLDSCREEN_SIZE] == screen.to_bytes()

    # Table edit present at the tile-table offset.
    from tmos_randomizer.core.constants import TILE_TABLE_ADDR
    assert patched[TILE_TABLE_ADDR:TILE_TABLE_ADDR + 4] == bytes([1, 2, 3, 4])

    # Something actually changed vs vanilla.
    assert patched != vanilla


def test_patch_custom_filename(client):
    resp = client.post("/api/rom/patch", params={"filename": "myhack.nes"})
    assert resp.status_code == 200
    assert 'filename="myhack.nes"' in resp.headers["content-disposition"]


def test_patch_filename_sanitized(client):
    """Path separators are stripped from the requested filename."""
    resp = client.post("/api/rom/patch", params={"filename": "../../evil.nes"})
    assert resp.status_code == 200
    cd = resp.headers["content-disposition"]
    assert "/" not in cd.split('filename="', 1)[1]
    assert "\\\\" not in cd


def test_patch_after_randomization(client):
    """Applying a randomization plan then patching reflects the applied screens."""
    vanilla = bytes(server._rom_vanilla)

    plan_resp = client.post("/api/plan", json={"seed": 12345, "config": {}})
    if plan_resp.status_code != 200:
        pytest.skip("plan creation unavailable")
    preview = client.post("/api/plan/apply-preview")
    if preview.status_code != 200:
        pytest.skip("apply-preview unavailable")

    resp = client.post("/api/rom/patch")
    assert resp.status_code == 200
    # The applied plan flushed modified screens into _rom_data.
    assert int(resp.headers["X-Screens-Modified"]) >= 1
    assert resp.content != vanilla


def test_patch_requires_rom():
    """With no ROM loaded, patch returns 400."""
    saved = (server._rom_data, server._game_world, server._rom_vanilla)
    server._rom_data = None
    server._game_world = None
    server._rom_vanilla = None
    try:
        c = TestClient(server.app)
        assert c.post("/api/rom/patch").status_code == 400
    finally:
        server._rom_data, server._game_world, server._rom_vanilla = saved
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `pytest tests/test_integration/test_patch_rom.py -v -k patch`
Expected: FAIL — the four `patch` tests get 404/405 because `POST /api/rom/patch` does not exist yet (`test_patch_requires_rom` will not get 400).

- [ ] **Step 3: Implement the endpoint**

In `src/tmos_randomizer/api/server.py`, add (place it near the other `/api/rom/...` endpoints, e.g. right after `apply_plan_preview` or after the tile-bank endpoints):

```python
@app.post("/api/rom/patch")
async def patch_rom(filename: Optional[str] = Query(default=None)):
    """Stream the fully-edited ROM as a browser download.

    _rom_data is the single source of truth (table edits write to it directly;
    screen edits are flushed via _flush_screens). A defensive reconcile flushes
    any still-dirty screens so a forgotten flush site cannot drop edits.
    Runs a non-blocking navigability check and reports the count via a header.
    """
    _require_rom_pair()  # raises HTTPException(400) if no ROM loaded
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    # Defensive reconcile: capture any dirty screens not yet flushed.
    # _flush_screens rebuilds the _rom_data buffer in place.
    _flush_screens(s for ch in _game_world for s in ch.screens if s.is_modified)
    modified_count = sum(
        1 for ch in _game_world for s in ch.screens if s.is_modified
    )

    # Non-blocking navigability check: count chapters with unreachable screens.
    report = _check_world_connectivity(_game_world)
    warning_count = sum(1 for r in report if not r["fully_reachable"])

    # Resolve a safe download filename.
    if filename:
        name = Path(filename).name  # strip any path components
    elif _rom_filename:
        name = f"{Path(_rom_filename).stem}-edited.nes"
    else:
        name = "edited.nes"

    return Response(
        content=_rom_data,
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f'attachment; filename="{name}"',
            "X-Patch-Warnings": str(warning_count),
            "X-Screens-Modified": str(modified_count),
            "Access-Control-Expose-Headers":
                "X-Patch-Warnings, X-Screens-Modified, Content-Disposition",
        },
    )
```

(`Query`, `Response`, `Optional`, `Path`, and `_check_world_connectivity` are already imported/defined in this module.)

- [ ] **Step 4: Run the tests to verify they pass**

Run: `pytest tests/test_integration/test_patch_rom.py -v`
Expected: PASS for all tests in the file.

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/api/server.py tests/test_integration/test_patch_rom.py
git commit -m "feat(v2/api): add POST /api/rom/patch to stream edited ROM"
```

---

## Task 3: Frontend API client — `patchRom()`

**Files:**
- Modify: `ui/src/api/client.ts`

- [ ] **Step 1: Add the `patchRom` method**

In `ui/src/api/client.ts`, inside the `ApiClient` class (e.g. right after the `applyRandomization` method), add:

```ts
  // Patch — stream the fully-edited ROM as a download blob.
  async patchRom(filename?: string): Promise<{
    blob: Blob;
    filename: string;
    warnings: number;
    screensModified: number;
  }> {
    const qs = filename ? `?filename=${encodeURIComponent(filename)}` : '';
    const response = await fetch(`${this.baseUrl}/api/rom/patch${qs}`, {
      method: 'POST',
    });
    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ detail: `HTTP ${response.status}` }));
      throw new Error(error.detail || `HTTP ${response.status}`);
    }

    const blob = await response.blob();
    const cd = response.headers.get('Content-Disposition') ?? '';
    const match = cd.match(/filename="([^"]+)"/);
    return {
      blob,
      filename: match?.[1] ?? filename ?? 'edited.nes',
      warnings: Number(response.headers.get('X-Patch-Warnings') ?? '0'),
      screensModified: Number(response.headers.get('X-Screens-Modified') ?? '0'),
    };
  }
```

- [ ] **Step 2: Type-check the UI**

Run: `cd ui && npm run build`
Expected: Build succeeds with no TypeScript errors. (If the project exposes a faster `tsc --noEmit`/`npm run lint`, that is acceptable too.)

- [ ] **Step 3: Commit**

```bash
git add ui/src/api/client.ts
git commit -m "feat(v2/ui): add api.patchRom() client method"
```

---

## Task 4: `PatchRomModal`, App mount, and Header button

**Files:**
- Create: `ui/src/components/modals/PatchRomModal.tsx`
- Modify: `ui/src/App.tsx`
- Modify: `ui/src/components/layout/Header.tsx`

- [ ] **Step 1: Create the modal component**

Create `ui/src/components/modals/PatchRomModal.tsx`:

```tsx
import { useState } from 'react';
import { api } from '../../api/client';
import { useRandomizerStore } from '../../store';

function triggerDownload(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

function buildEditLogText(
  editLog: ReturnType<typeof useRandomizerStore.getState>['editLog'],
): string {
  if (editLog.length === 0) return 'No edits recorded this session.\n';
  const lines = editLog.map((e) => {
    const when = new Date(e.ts).toISOString();
    const base = `${when}  ${e.field}  ${e.rom_offset}  ${e.before} -> ${e.after}`;
    return e.cascade ? `${base}  (${e.cascade})` : base;
  });
  return `TMOS edit log (${editLog.length} entries)\n\n${lines.join('\n')}\n`;
}

export function PatchRomModal() {
  const { modalOpen, setModalOpen, romFilename, editLog } = useRandomizerStore();

  const defaultName = romFilename
    ? `${romFilename.replace(/\.nes$/i, '')}-edited.nes`
    : 'edited.nes';

  const [filename, setFilename] = useState(defaultName);
  const [includeLog, setIncludeLog] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<{ warnings: number; screens: number } | null>(null);

  if (modalOpen !== 'export') return null;

  const handlePatch = async () => {
    setBusy(true);
    setError(null);
    setResult(null);
    try {
      const name = filename.trim() || defaultName;
      const { blob, filename: outName, warnings, screensModified } =
        await api.patchRom(name);
      triggerDownload(blob, outName);

      if (includeLog) {
        const logBlob = new Blob([buildEditLogText(editLog)], {
          type: 'text/plain',
        });
        triggerDownload(logBlob, outName.replace(/\.nes$/i, '') + '-edits.txt');
      }

      setResult({ warnings, screens: screensModified });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Patch failed');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
      <div className="w-full max-w-md rounded-lg border border-slate-700 bg-slate-800 p-6 shadow-xl">
        <h2 className="mb-4 text-lg font-semibold text-white">Patch ROM</h2>

        <label className="mb-1 block text-sm text-slate-400">Output filename</label>
        <input
          type="text"
          value={filename}
          onChange={(e) => setFilename(e.target.value)}
          className="mb-4 w-full rounded border border-slate-600 bg-slate-900 px-3 py-1.5 text-sm text-slate-100"
        />

        <label className="mb-4 flex items-center gap-2 text-sm text-slate-300">
          <input
            type="checkbox"
            checked={includeLog}
            onChange={(e) => setIncludeLog(e.target.checked)}
          />
          Download edit log too (.txt)
        </label>

        {result && (
          <div className="mb-4 rounded border border-slate-600 bg-slate-900 p-3 text-sm">
            <div className="text-green-400">
              Saved &mdash; {result.screens} screen(s) modified.
            </div>
            {result.warnings > 0 && (
              <div className="mt-1 text-amber-400">
                &#9888; {result.warnings} chapter(s) have unreachable screens. ROM
                still saved.
              </div>
            )}
          </div>
        )}

        {error && <div className="mb-4 text-sm text-red-400">{error}</div>}

        <div className="flex justify-end gap-2">
          <button
            onClick={() => setModalOpen(null)}
            className="rounded bg-slate-700 px-3 py-1.5 text-sm text-white hover:bg-slate-600"
          >
            Close
          </button>
          <button
            onClick={handlePatch}
            disabled={busy}
            className="rounded bg-green-600 px-3 py-1.5 text-sm text-white hover:bg-green-500 disabled:bg-slate-600"
          >
            {busy ? 'Patching…' : 'Patch ROM'}
          </button>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Mount the modal in `App.tsx`**

In `ui/src/App.tsx`, add the import alongside the existing `RandomizeModal` import:

```tsx
import { PatchRomModal } from './components/modals/PatchRomModal';
```

And render it next to `<RandomizeModal />`:

```tsx
      <RandomizeModal />
      <PatchRomModal />
```

- [ ] **Step 3: Wire the Header button**

In `ui/src/components/layout/Header.tsx`, replace the existing "Patch ROM" button block (currently `disabled={!romLoaded || !plan}` with `onClick={() => alert('Patch ROM - Not yet implemented')}`) with:

```tsx
          {/* Patch ROM Button */}
          <button
            disabled={!romLoaded}
            onClick={() => setModalOpen('export')}
            className={`px-3 py-1.5 text-white text-sm rounded transition-colors flex items-center gap-2 ${
              romLoaded
                ? 'bg-green-600 hover:bg-green-500'
                : 'bg-slate-600 cursor-not-allowed'
            }`}
          >
            <span>&#128190;</span>
            Patch ROM
          </button>
```

(`romLoaded` and `setModalOpen` are already destructured from the store in this component; `plan` may now be unused — remove it from the destructure if the linter flags it.)

- [ ] **Step 4: Build the UI**

Run: `cd ui && npm run build`
Expected: Build succeeds, no TypeScript/lint errors.

- [ ] **Step 5: Manual verification**

Start the backend (`python -m tmos_randomizer serve --port 8000`) and the UI dev server. Load the default ROM, make an edit (e.g. change a screen's tiles or an enemy stat), click **Patch ROM**, confirm:
- the dialog opens with a prefilled filename,
- clicking **Patch ROM** downloads `<name>-edited.nes` and `<name>-edits.txt`,
- the success line shows the modified-screen count (and a warning line if any chapter is not fully reachable).

- [ ] **Step 6: Commit**

```bash
git add ui/src/components/modals/PatchRomModal.tsx ui/src/App.tsx ui/src/components/layout/Header.tsx
git commit -m "feat(v2/ui): PatchRomModal + wire Patch ROM button to download edited ROM"
```

---

## Final verification

- [ ] Run the full backend suite: `pytest tests/ -v` — expected: no new failures (asset-dependent tests may skip).
- [ ] Run the UI build: `cd ui && npm run build` — expected: clean.
- [ ] Confirm the spec's out-of-scope items were NOT added (no IPS/BPS, no server-side path writing, no zip/spoiler bundling).
```
