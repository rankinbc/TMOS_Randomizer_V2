# Debug Tab + Change Diff + Validator Correctness — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a primary "Debug" tab that consolidates debug tooling, shows an authoritative ROM-vs-vanilla change diff, reports every validation problem, and corrects the validators so a pristine default ROM passes with zero errors.

**Architecture:** Three loosely-coupled units. (1) A frontend Debug tab shell hosting three sub-sections. (2) A backend `GET /api/debug/changes` endpoint that deep-diffs the working ROM against the vanilla snapshot via the existing per-system reader modules, plus a frontend panel. (3) Validator-correctness work driven by a ROM-gated regression test asserting zero validator errors on the vanilla ROM, fixed one validator at a time.

**Tech Stack:** Python 3.13, FastAPI, pytest (backend); React 18 + TypeScript + Vite + Zustand + Tailwind (frontend).

## Global Constraints

- **Shared working tree:** commit explicit paths only. NEVER `git add -A` / `git add .`. Stage only the files named in each task's commit step.
- **Commit trailer:** every commit message ends with `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- **Sacred files (do not modify):** `*.nes`/`*.rom`, `pyproject.toml`/`package.json`, `.gitignore`, `/.claude-system/`.
- **Single source of truth:** time-period / validation logic is authoritative in backend `core/enums.py` and `validation/*`. The UI must never re-derive it.
- **Ground truth for validators:** the unmodified default ROM (`TMOS_ORIGINAL.nes`) is a shipped, playable game. A correct validator MUST accept it. "Fix" means make vanilla pass WITHOUT neutering the check on randomized output.
- **Windows shell:** the Bash tool is POSIX sh. Do NOT use PowerShell here-strings (`@'...'@`) in Bash. Multi-line commit messages use `git commit -F <file>`.
- **Run backend tests from** `projects/TMOS_Randomizer_V2/` so `tmos_randomizer` resolves. Run frontend commands from `projects/TMOS_Randomizer_V2/ui/`.

---

## File Structure

**Backend (create):**
- `src/tmos_randomizer/api/debug_changes.py` — pure diff logic (no FastAPI imports): generic structured deep-diff + provider registry + `build_changes()`.
- `tests/test_api/test_debug_changes.py` — unit tests for the diff logic.
- `tests/test_validation/test_vanilla_baseline.py` — ROM-gated regression test: vanilla ROM yields zero validator errors.

**Backend (modify):**
- `src/tmos_randomizer/api/server.py` — add `GET /api/debug/changes` endpoint wiring the diff providers.
- `src/tmos_randomizer/validation/validators/edge_compatibility.py`, `edge_alignment.py`, `navigation_consistency.py`, `traversability.py`, `interior_exterior_segregation.py`, `time_period_isolation.py` — correctness fixes (Phase B).
- Possibly `src/tmos_randomizer/validation/config.py` — if a fix is expressed as a config default change.

**Frontend (create):**
- `ui/src/components/debug/DebugView.tsx` — the tab container with 3 sub-sections.
- `ui/src/components/debug/ChangesView.tsx` — ROM-vs-vanilla diff panel.
- `ui/src/components/debug/ValidationView.tsx` — report-all validation panel.

**Frontend (modify):**
- `ui/src/store/index.ts` — add `'debug'` to `TabType`.
- `ui/src/components/layout/MainContent.tsx` — add Debug tab to `TABS`, `GLOBAL_TABS`, and the content switch.
- `ui/src/api/client.ts` — add `getChanges()` + `validateRom()` methods and their types.
- `ui/src/components/debug/JsonDebugPanel.tsx` — remove its internal `validation` section/button (superseded by `ValidationView`); it becomes the "Inspector" sub-section.

---

# PHASE A — Tab, Change Diff, Report-All (low risk, ship first)

## Task A1: Diff core — generic structured deep-diff

**Files:**
- Create: `src/tmos_randomizer/api/debug_changes.py`
- Test: `tests/test_api/test_debug_changes.py`

**Interfaces:**
- Produces:
  - `diff_structured(current_obj: Any, vanilla_obj: Any) -> list[dict]` — each dict is `{"label": str, "vanilla": Any, "current": Any}`.
  - `build_changes(rom: bytes, vanilla: bytes, providers: list[tuple[str, Callable[[bytes], Any]]]) -> dict` — returns `{"total_changes": int, "groups": [{"system": str, "count": int, "entries": [...]}], "differing_bytes": int}`.

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_api/test_debug_changes.py
from tmos_randomizer.api.debug_changes import diff_structured, build_changes


def test_identical_structures_have_no_diff():
    obj = {"hp": [10, 20], "name": "x"}
    assert diff_structured(obj, dict(obj)) == []


def test_scalar_change_is_reported_with_path():
    cur = {"hp": [10, 99]}
    van = {"hp": [10, 20]}
    diffs = diff_structured(cur, van)
    assert diffs == [{"label": "hp[1]", "vanilla": 20, "current": 99}]


def test_nested_and_list_length_changes():
    cur = {"a": {"b": 2}, "list": [1, 2, 3]}
    van = {"a": {"b": 1}, "list": [1, 2]}
    diffs = diff_structured(cur, van)
    labels = {d["label"] for d in diffs}
    assert "a.b" in labels
    assert "list[2]" in labels  # extra element in current


def test_build_changes_groups_and_counts():
    rom = bytes([0, 1, 2, 9])
    van = bytes([0, 1, 2, 3])
    providers = [
        ("Hero", lambda b: {"last": b[3]}),
        ("Quiet", lambda b: {"const": 7}),
    ]
    out = build_changes(rom, van, providers)
    assert out["total_changes"] == 1
    assert out["differing_bytes"] == 1
    assert len(out["groups"]) == 1
    g = out["groups"][0]
    assert g["system"] == "Hero" and g["count"] == 1
    assert g["entries"][0] == {"label": "last", "vanilla": 3, "current": 9}


def test_provider_exception_does_not_kill_diff():
    rom, van = b"\x01", b"\x00"
    providers = [("Boom", lambda b: (_ for _ in ()).throw(ValueError("x"))),
                 ("Ok", lambda b: {"v": b[0]})]
    out = build_changes(rom, van, providers)
    systems = {g["system"] for g in out["groups"]}
    assert systems == {"Ok"}  # Boom swallowed, Ok still reported
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `python -m pytest tests/test_api/test_debug_changes.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'tmos_randomizer.api.debug_changes'`

- [ ] **Step 3: Write the implementation**

```python
# src/tmos_randomizer/api/debug_changes.py
"""ROM-vs-vanilla structured diff for the Debug tab.

Pure logic (no FastAPI imports). Compares the mutable working ROM against the
immutable vanilla snapshot and reports every differing field, grouped by system.
Derived from ROM state, so it is authoritative and refresh-proof — unlike the
session edit log.
"""
from __future__ import annotations

from typing import Any, Callable, List, Tuple

Provider = Tuple[str, Callable[[bytes], Any]]


def _walk(path: str, cur: Any, van: Any, out: List[dict]) -> None:
    if isinstance(cur, dict) and isinstance(van, dict):
        for key in sorted(set(cur) | set(van), key=str):
            child = f"{path}.{key}" if path else str(key)
            _walk(child, cur.get(key), van.get(key), out)
    elif isinstance(cur, list) and isinstance(van, list):
        for i in range(max(len(cur), len(van))):
            c = cur[i] if i < len(cur) else None
            v = van[i] if i < len(van) else None
            _walk(f"{path}[{i}]", c, v, out)
    elif cur != van:
        out.append({"label": path, "vanilla": van, "current": cur})


def diff_structured(current_obj: Any, vanilla_obj: Any) -> List[dict]:
    """Recursively diff two JSON-able structures; return leaf-level changes."""
    out: List[dict] = []
    _walk("", current_obj, vanilla_obj, out)
    return out


def build_changes(rom: bytes, vanilla: bytes, providers: List[Provider]) -> dict:
    """Diff `rom` vs `vanilla` through each provider; aggregate into groups.

    A provider that raises is skipped (a single broken reader must not blank the
    whole report). `differing_bytes` is the raw byte-level delta so the UI can
    flag when structured groups under-account for what actually changed.
    """
    groups: List[dict] = []
    total = 0
    for system, reader in providers:
        try:
            entries = diff_structured(reader(rom), reader(vanilla))
        except Exception:
            continue
        if entries:
            groups.append({"system": system, "count": len(entries), "entries": entries})
            total += len(entries)

    differing_bytes = sum(1 for a, b in zip(rom, vanilla) if a != b) + abs(len(rom) - len(vanilla))
    return {"total_changes": total, "groups": groups, "differing_bytes": differing_bytes}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `python -m pytest tests/test_api/test_debug_changes.py -v`
Expected: PASS (5 passed)

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/api/debug_changes.py tests/test_api/test_debug_changes.py
git commit -F <msgfile>
```
Message:
```
feat(debug): structured ROM-vs-vanilla diff core

Pure deep-diff + provider aggregation used by the Debug tab change log.
Provider failures are isolated; raw differing-byte count exposes any
regions the structured providers don't yet cover.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## Task A2: `GET /api/debug/changes` endpoint

**Files:**
- Modify: `src/tmos_randomizer/api/server.py` (add endpoint near the other `/api/debug/*` routes; reuse `_require_rom_pair()` at ~line 2630 and the temp-file `load_rom` pattern at ~lines 860-868)
- Test: `tests/test_api/test_debug_changes_endpoint.py` (create)

**Interfaces:**
- Consumes: `build_changes` (A1); `_require_rom_pair() -> (rom: bytes, vanilla: bytes)`; reader modules already imported in server.py: `_player_stats.read_player_stats`, `_inv_caps.read_caps`, `_exp_table.read_exp_table`.
- Produces: `GET /api/debug/changes` → the `build_changes` dict.

- [ ] **Step 1: Add a screens helper and provider list, then the route**

Add this helper above the route (parses ROM bytes into a JSON-able screen map using the same `load_rom` temp-file pattern `get_screen_vanilla` uses). If a `serialize_screen`-style dict builder already exists in server.py, reuse it instead of re-listing fields.

```python
def _screens_snapshot(buf: bytes) -> dict:
    """Parse ROM bytes into {ch -> {screen_index -> {field: value}}} for diffing."""
    import tempfile, os
    from ..io.rom_reader import load_rom
    tmp = tempfile.NamedTemporaryFile(suffix=".nes", delete=False)
    try:
        tmp.write(buf)
        tmp.close()
        world = load_rom(tmp.name)
    finally:
        os.unlink(tmp.name)

    out: dict = {}
    for chapter_num in range(1, 6):
        chapter = world.chapters.get(chapter_num)
        if chapter is None:
            continue
        ch_map: dict = {}
        for screen in chapter.screens:
            ch_map[f"0x{screen.relative_index:02X}"] = {
                "content": screen.content,
                "objectset": screen.objectset,
                "datapointer": screen.datapointer,
                "top_tiles": screen.top_tiles,
                "bottom_tiles": screen.bottom_tiles,
                "nav_right": screen.screen_index_right,
                "nav_left": screen.screen_index_left,
                "nav_down": screen.screen_index_down,
                "nav_up": screen.screen_index_up,
            }
        out[f"ch{chapter_num}"] = ch_map
    return out
```

```python
@app.get("/api/debug/changes")
async def debug_changes():
    """Authoritative ROM-vs-vanilla diff for the Debug tab change log."""
    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    from .debug_changes import build_changes
    rom, vanilla = _require_rom_pair()
    providers = [
        ("Screens", _screens_snapshot),
        ("Hero", _player_stats.read_player_stats),
        ("Inventory Caps", _inv_caps.read_caps),
        ("Experience Table", _exp_table.read_exp_table),
    ]
    return build_changes(rom, vanilla, providers)
```

> Note: confirm the reader attribute names (`_player_stats`, `_inv_caps`, `_exp_table`) and method names by grepping server.py imports near line 2630; use the exact names found. If a reader's signature differs, wrap it in a `lambda b: reader(b)` that matches `Callable[[bytes], Any]`.

- [ ] **Step 2: Write the endpoint test (uses the autoloaded default ROM)**

```python
# tests/test_api/test_debug_changes_endpoint.py
import pytest
from pathlib import Path
from fastapi.testclient import TestClient

ROM = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"
pytestmark = pytest.mark.skipif(not ROM.exists(), reason="default ROM not present")


@pytest.fixture
def client():
    from tmos_randomizer.api.server import app, _autoload_default_rom
    _autoload_default_rom()
    return TestClient(app)


def test_clean_rom_reports_no_changes(client):
    resp = client.get("/api/debug/changes")
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_changes"] == 0
    assert data["groups"] == []
    assert data["differing_bytes"] == 0
```

- [ ] **Step 3: Run the test**

Run: `python -m pytest tests/test_api/test_debug_changes_endpoint.py -v`
Expected: PASS (or SKIP if the ROM is absent in this checkout — then verify manually against the running server: `curl -s localhost:8000/api/debug/changes`).

- [ ] **Step 4: Commit**

```bash
git add src/tmos_randomizer/api/server.py tests/test_api/test_debug_changes_endpoint.py
git commit -F <msgfile>
```
Message:
```
feat(debug): GET /api/debug/changes endpoint

Wires the structured diff to the live ROM pair (screens, hero, inventory
caps, exp table) plus a raw differing-byte count. Clean default ROM
reports zero changes.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## Task A3: API client — `getChanges()` and `validateRom()`

**Files:**
- Modify: `ui/src/api/client.ts` (add types + two methods on `ApiClient`, following the existing `fetch<T>` pattern at line 532)

**Interfaces:**
- Produces (exported types + methods):
  - `interface ChangeEntry { label: string; vanilla: unknown; current: unknown; }`
  - `interface ChangeGroup { system: string; count: number; entries: ChangeEntry[]; }`
  - `interface ChangesResponse { total_changes: number; groups: ChangeGroup[]; differing_bytes: number; }`
  - `interface ValidationIssue { validator_id: string; severity: string; message: string; chapter_num: number | null; screen_index: number | null; category: string | null; }`
  - `interface ChapterValidation { chapter_num: number; total_screens: number; passed: boolean; errors: ValidationIssue[]; warnings: ValidationIssue[]; }`
  - `interface ValidateResponse { status: string; rom_filename: string | null; has_plan: boolean; chapters: ChapterValidation[]; summary: { total_errors: number; total_warnings: number; all_passed: boolean; error_breakdown: Record<string, number>; }; }`
  - `api.getChanges(): Promise<ChangesResponse>`
  - `api.validateRom(): Promise<ValidateResponse>`

> The backend `/api/debug/validate` currently serializes each error/warning as an issue object. The existing `JsonDebugPanel` typed them as `string[]`, which is wrong — these new types are the correct shape and `ValidationView` (A6) consumes them.

- [ ] **Step 1: Add the types** near the other response interfaces in `client.ts` (above the `ApiClient` class).

```typescript
export interface ChangeEntry { label: string; vanilla: unknown; current: unknown; }
export interface ChangeGroup { system: string; count: number; entries: ChangeEntry[]; }
export interface ChangesResponse { total_changes: number; groups: ChangeGroup[]; differing_bytes: number; }

export interface ValidationIssue {
  validator_id: string; severity: string; message: string;
  chapter_num: number | null; screen_index: number | null; category: string | null;
}
export interface ChapterValidation {
  chapter_num: number; total_screens: number; passed: boolean;
  errors: ValidationIssue[]; warnings: ValidationIssue[];
}
export interface ValidateResponse {
  status: string; rom_filename: string | null; has_plan: boolean;
  chapters: ChapterValidation[];
  summary: { total_errors: number; total_warnings: number; all_passed: boolean; error_breakdown: Record<string, number>; };
}
```

- [ ] **Step 2: Add the methods** inside the `ApiClient` class (e.g., after `getPlan`).

```typescript
  // Debug
  async getChanges(): Promise<ChangesResponse> {
    return this.fetch<ChangesResponse>('/api/debug/changes');
  }

  async validateRom(): Promise<ValidateResponse> {
    return this.fetch<ValidateResponse>('/api/debug/validate');
  }
```

- [ ] **Step 3: Type-check**

Run (from `ui/`): `npx tsc --noEmit`
Expected: no new errors.

- [ ] **Step 4: Commit**

```bash
git add ui/src/api/client.ts
git commit -F <msgfile>
```
Message:
```
feat(debug): API client getChanges() + validateRom() with typed issues

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## Task A4: `ChangesView` component

**Files:**
- Create: `ui/src/components/debug/ChangesView.tsx`

**Interfaces:**
- Consumes: `api.getChanges()`, `ChangesResponse` (A3).
- Produces: default-exported `ChangesView` React component (no required props).

- [ ] **Step 1: Implement the component**

```tsx
// ui/src/components/debug/ChangesView.tsx
import { useEffect, useState } from 'react';
import { api } from '../../api/client';
import type { ChangesResponse } from '../../api/client';

export function ChangesView() {
  const [data, setData] = useState<ChangesResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await api.getChanges());
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load changes');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  return (
    <div className="h-full overflow-auto p-4">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide">
          Changed Data (vs. vanilla)
        </h3>
        <button
          onClick={load}
          disabled={loading}
          className="px-3 py-1.5 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded disabled:opacity-50"
        >
          {loading ? 'Refreshing…' : 'Refresh'}
        </button>
      </div>

      {error && (
        <div className="p-3 bg-red-500/10 border border-red-500/20 rounded text-red-300 text-sm mb-3">{error}</div>
      )}

      {data && data.total_changes === 0 && (
        <div className="p-4 bg-green-500/10 border border-green-500/20 rounded text-green-300 text-sm">
          No changes — current ROM matches vanilla.
          {data.differing_bytes > 0 && (
            <span className="text-amber-300"> ({data.differing_bytes} raw bytes differ but aren’t categorized.)</span>
          )}
        </div>
      )}

      {data && data.total_changes > 0 && (
        <>
          <div className="text-sm text-slate-300 mb-3">
            <span className="text-blue-400 font-semibold">{data.total_changes}</span> changed field(s)
            {' · '}<span className="text-slate-400">{data.differing_bytes} raw bytes differ</span>
          </div>
          <div className="space-y-3">
            {data.groups.map((g) => (
              <div key={g.system} className="bg-slate-800 rounded-lg overflow-hidden">
                <div className="px-4 py-2 bg-slate-700 flex justify-between">
                  <span className="font-semibold text-slate-200">{g.system}</span>
                  <span className="text-slate-400 text-sm">{g.count}</span>
                </div>
                <table className="w-full text-xs">
                  <thead>
                    <tr className="text-slate-400">
                      <th className="px-3 py-1 text-left">Field</th>
                      <th className="px-3 py-1 text-right">Vanilla</th>
                      <th className="px-3 py-1 text-right">Current</th>
                    </tr>
                  </thead>
                  <tbody>
                    {g.entries.map((e, i) => (
                      <tr key={i} className="border-t border-slate-700/60">
                        <td className="px-3 py-1 font-mono text-slate-300">{e.label}</td>
                        <td className="px-3 py-1 text-right font-mono text-slate-500">{String(e.vanilla)}</td>
                        <td className="px-3 py-1 text-right font-mono text-blue-300">{String(e.current)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
```

- [ ] **Step 2: Type-check**

Run (from `ui/`): `npx tsc --noEmit`
Expected: no new errors.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/debug/ChangesView.tsx
git commit -F <msgfile>
```
Message:
```
feat(debug): ChangesView — ROM-vs-vanilla change log panel

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## Task A5: `ValidationView` component (report-all)

**Files:**
- Create: `ui/src/components/debug/ValidationView.tsx`

**Interfaces:**
- Consumes: `api.validateRom()`, `ValidateResponse`, `ValidationIssue` (A3).
- Produces: default-exported `ValidationView` React component (no required props).

- [ ] **Step 1: Implement the component**

```tsx
// ui/src/components/debug/ValidationView.tsx
import { useState } from 'react';
import { api } from '../../api/client';
import type { ValidateResponse, ValidationIssue } from '../../api/client';

function issueLine(i: ValidationIssue): string {
  const loc = [
    i.chapter_num != null ? `ch${i.chapter_num}` : null,
    i.screen_index != null ? `screen 0x${i.screen_index.toString(16).toUpperCase()}` : null,
  ].filter(Boolean).join(' ');
  return `[${i.validator_id}] ${loc ? loc + ': ' : ''}${i.message}`;
}

export function ValidationView() {
  const [result, setResult] = useState<ValidateResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const run = async () => {
    setLoading(true);
    setError(null);
    try {
      setResult(await api.validateRom());
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Validation failed');
    } finally {
      setLoading(false);
    }
  };

  const copyReport = async () => {
    if (!result) return;
    const lines: string[] = [];
    for (const ch of result.chapters) {
      for (const e of ch.errors) lines.push('ERROR  ' + issueLine(e));
      for (const w of ch.warnings) lines.push('WARN   ' + issueLine(w));
    }
    await navigator.clipboard.writeText(lines.join('\n'));
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="h-full overflow-auto p-4">
      <div className="flex items-center gap-2 mb-4">
        <button
          onClick={run}
          disabled={loading}
          className={`px-4 py-2 text-sm rounded ${loading ? 'bg-slate-600 text-slate-400' : 'bg-green-700 hover:bg-green-600 text-white'}`}
        >
          {loading ? 'Running…' : 'Validate ROM'}
        </button>
        {result && (
          <button onClick={copyReport} className="px-4 py-2 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded">
            {copied ? 'Copied!' : 'Copy full report'}
          </button>
        )}
      </div>

      {error && <div className="p-3 bg-red-500/10 border border-red-500/20 rounded text-red-300 text-sm mb-3">{error}</div>}

      {result && (
        <>
          <div className={`p-4 rounded mb-4 border ${result.summary.all_passed ? 'bg-green-500/10 border-green-500/20' : 'bg-red-500/10 border-red-500/20'}`}>
            <div className={`text-lg font-semibold ${result.summary.all_passed ? 'text-green-400' : 'text-red-400'}`}>
              {result.summary.all_passed ? '✓ ALL VALIDATORS PASSED' : '✗ VALIDATION FAILED'}
            </div>
            <div className="text-sm text-slate-300 mt-1">
              <span className="text-red-400">{result.summary.total_errors} errors</span>
              {' · '}<span className="text-amber-400">{result.summary.total_warnings} warnings</span>
              {result.has_plan && <span className="text-slate-400"> · plan applied</span>}
              {result.rom_filename && <span className="text-slate-400"> · {result.rom_filename}</span>}
            </div>
            {Object.keys(result.summary.error_breakdown).length > 0 && (
              <div className="mt-2 flex flex-wrap gap-2 text-xs">
                {Object.entries(result.summary.error_breakdown).map(([k, v]) => (
                  <span key={k} className="px-2 py-0.5 bg-slate-800 rounded font-mono text-slate-300">{k}: {v}</span>
                ))}
              </div>
            )}
          </div>

          <div className="space-y-3">
            {result.chapters.map((ch) => (
              <div key={ch.chapter_num} className={`bg-slate-800 rounded-lg overflow-hidden border ${ch.passed ? 'border-slate-700' : 'border-red-500/30'}`}>
                <div className={`px-4 py-2 flex justify-between ${ch.passed ? 'bg-slate-700' : 'bg-red-500/10'}`}>
                  <span className="font-semibold text-slate-200">
                    {ch.passed ? '✓' : '✗'} Chapter {ch.chapter_num}
                    <span className="text-slate-500 text-sm ml-2">({ch.total_screens} screens)</span>
                  </span>
                  <span className="text-xs text-slate-400">{ch.errors.length} err · {ch.warnings.length} warn</span>
                </div>
                <div className="px-4 py-2 text-xs space-y-0.5">
                  {ch.errors.map((e, i) => (
                    <div key={`e${i}`} className="text-red-300 font-mono">• {issueLine(e)}</div>
                  ))}
                  {ch.warnings.map((w, i) => (
                    <div key={`w${i}`} className="text-amber-300/80 font-mono">• {issueLine(w)}</div>
                  ))}
                  {ch.errors.length === 0 && ch.warnings.length === 0 && (
                    <div className="text-green-400">No issues.</div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
```

- [ ] **Step 2: Type-check** — Run (from `ui/`): `npx tsc --noEmit` → no new errors.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/debug/ValidationView.tsx
git commit -F <msgfile>
```
Message:
```
feat(debug): ValidationView — report every validation problem, untruncated

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## Task A6: Debug tab shell + nav wiring + move Inspector

**Files:**
- Create: `ui/src/components/debug/DebugView.tsx`
- Modify: `ui/src/store/index.ts` (TabType), `ui/src/components/layout/MainContent.tsx` (TABS, GLOBAL_TABS, content switch), `ui/src/components/debug/JsonDebugPanel.tsx` (remove internal validation section + its Run Validation button + the `validation` activeSection case and the `runValidation`/validation state)

**Interfaces:**
- Consumes: `ChangesView` (A4), `ValidationView` (A5), `JsonDebugPanel` (existing).
- Produces: `DebugView` default-exported component; `'debug'` member of `TabType`.

- [ ] **Step 1: Add `'debug'` to `TabType`** in `ui/src/store/index.ts` line 32.

```typescript
export type TabType = 'world' | 'enemies' | 'items' | 'hero' | 'allies' | 'graphics' | 'randomize' | 'expert' | 'debug';
```

- [ ] **Step 2: Create `DebugView`**

```tsx
// ui/src/components/debug/DebugView.tsx
import { useState } from 'react';
import { ChangesView } from './ChangesView';
import { ValidationView } from './ValidationView';
import { JsonDebugPanel } from './JsonDebugPanel';

type Section = 'changes' | 'validation' | 'inspector';

const SECTIONS: { id: Section; label: string }[] = [
  { id: 'changes', label: 'Changes' },
  { id: 'validation', label: 'Validation' },
  { id: 'inspector', label: 'Inspector' },
];

export function DebugView() {
  const [section, setSection] = useState<Section>('changes');
  return (
    <div className="h-full flex flex-col">
      <div className="flex-shrink-0 flex gap-2 p-3 border-b border-slate-700 bg-slate-800">
        {SECTIONS.map((s) => (
          <button
            key={s.id}
            onClick={() => setSection(s.id)}
            className={`px-3 py-1.5 text-sm rounded ${section === s.id ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'}`}
          >
            {s.label}
          </button>
        ))}
      </div>
      <div className="flex-1 overflow-hidden">
        {section === 'changes' && <ChangesView />}
        {section === 'validation' && <ValidationView />}
        {section === 'inspector' && <JsonDebugPanel />}
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Wire the tab into `MainContent.tsx`**

Add to `TABS` (after `expert`):
```typescript
  { id: 'expert', label: '⚠ Expert' },
  { id: 'debug', label: 'Debug' },
```
Add `'debug'` to `GLOBAL_TABS` (line 25):
```typescript
const GLOBAL_TABS = new Set<TabType>(['enemies', 'hero', 'graphics', 'expert', 'randomize', 'debug']);
```
Add the import (line 5 area):
```typescript
import { DebugView } from '../debug/DebugView';
```
Add to the content switch (after the `expert` line ~141):
```typescript
              {selectedTab === 'expert' && <ExpertView />}
              {selectedTab === 'debug' && <DebugView />}
```

- [ ] **Step 4: De-duplicate validation in `JsonDebugPanel.tsx`**

Remove the now-redundant validation UI so there is exactly one Validate button (in `ValidationView`):
- Delete the `validation` entry from the `activeSection` union (line 34) and its section button (lines 155-164).
- Delete `validationResult`, `validationLoading`, `validationError` state (lines 36-38), the `runValidation` function (lines 68-85), the `ValidationResult` interface (lines 4-30), the "Run Validation Tests" button (lines 175-185), and the entire `activeSection === 'validation'` block (lines 330-452).
- Keep everything else (chapter/plan/screens/sectionMap inspector + Copy JSON).

- [ ] **Step 5: Type-check and build**

Run (from `ui/`): `npx tsc --noEmit && npm run build`
Expected: build succeeds, no type errors.

- [ ] **Step 6: Manual smoke check**

Start the UI (`npm run dev`), confirm: a "Debug" primary tab appears; it shows Changes (empty-state on clean ROM), Validation (button runs, lists issues), Inspector (raw JSON). No second Validate button anywhere.

- [ ] **Step 7: Commit**

```bash
git add ui/src/store/index.ts ui/src/components/layout/MainContent.tsx ui/src/components/debug/DebugView.tsx ui/src/components/debug/JsonDebugPanel.tsx
git commit -F <msgfile>
```
Message:
```
feat(debug): primary Debug tab consolidating changes, validation, inspector

Adds a global Debug tab (Changes / Validation / Inspector sub-sections) and
removes the duplicate validation UI from JsonDebugPanel.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

# PHASE B — Validator Correctness (the substantive work)

**Premise:** the pristine default ROM produces 605 validator errors. The default ROM is ground truth; each error is a validator defect. Fix one validator at a time, worst-first, until vanilla is clean — without weakening detection on randomized output.

**Measured starting state (pristine `TMOS_ORIGINAL.nes`, no plan):**
`edge_compatibility`=252, `edge_alignment`=221, `navigation_consistency`=120, `screen_traversability`=9, `interior_exterior_segregation`=2, `time_period_isolation`=1.

## Task B1: Vanilla-baseline regression test (the gate)

**Files:**
- Create: `tests/test_validation/test_vanilla_baseline.py`

**Interfaces:**
- Produces: module-scoped fixture `vanilla_error_counts -> dict[str, int]`; a parametrized `test_vanilla_has_no_errors_from(vid)` (one case per validator) and `test_vanilla_passes_all_validators()`.

> This test is RED on creation (it documents the 605-error defect) and is the contract Phase B drives to GREEN. Because execution happens on a feature branch with review between tasks, committing it red — as the explicit driver — is intended. Each subsequent B-task flips one parametrized case green.

- [ ] **Step 1: Write the regression test**

```python
# tests/test_validation/test_vanilla_baseline.py
"""The pristine default ROM is a shipped, playable game; a correct validator
must accept it. This test is the contract for validator-correctness work:
zero ERROR-severity issues from any validator on the vanilla ROM.
"""
from pathlib import Path

import pytest

from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.validation.runner import ValidationRunner
from tmos_randomizer.validation.config import ValidationConfig
from tmos_randomizer.validation.base import ValidationPhase, Severity

ROM = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"
pytestmark = pytest.mark.skipif(not ROM.exists(), reason="default ROM not present")

VALIDATORS = [
    "edge_compatibility", "edge_alignment", "navigation_consistency",
    "screen_traversability", "interior_exterior_segregation", "time_period_isolation",
]


@pytest.fixture(scope="module")
def vanilla_error_counts() -> dict:
    world = load_rom(ROM)
    content = ROM.read_bytes()
    runner = ValidationRunner(ValidationConfig())
    ctx = {"rom_data": content}
    counts: dict = {}
    for chapter_num in range(1, 6):
        chapter = world.chapters.get(chapter_num)
        if chapter is None:
            continue
        result = runner.run_for_chapter(chapter, phase=ValidationPhase.FINAL, context=ctx)
        for issue in result.issues:
            if issue.severity == Severity.ERROR:
                counts[issue.validator_id] = counts.get(issue.validator_id, 0) + 1
    return counts


@pytest.mark.parametrize("vid", VALIDATORS)
def test_vanilla_has_no_errors_from(vid, vanilla_error_counts):
    n = vanilla_error_counts.get(vid, 0)
    assert n == 0, f"{vid} reports {n} ERROR(s) on the vanilla ROM (should be 0)"


def test_vanilla_passes_all_validators(vanilla_error_counts):
    total = sum(vanilla_error_counts.values())
    assert total == 0, f"vanilla ROM has {total} validator errors: {vanilla_error_counts}"
```

- [ ] **Step 2: Run it to capture the current (red) baseline**

Run: `python -m pytest tests/test_validation/test_vanilla_baseline.py -v`
Expected: FAIL — each case reports its starting count (e.g. `edge_compatibility reports 252`). Record the failing counts; they should match the measured starting state above.

- [ ] **Step 3: Commit the gate (intentionally red driver)**

```bash
git add tests/test_validation/test_vanilla_baseline.py
git commit -F <msgfile>
```
Message:
```
test(validation): vanilla-ROM zero-error regression gate (currently red)

Encodes the invariant that a correct validator accepts the shipped default
ROM. Drives the validator-correctness work to green, one validator at a time.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## Tasks B2–B7: Fix validators worst-first

Each task follows the **same loop** (the test code is shared from B1 — do not duplicate it). Process order: B2 `edge_compatibility` → B3 `edge_alignment` → B4 `navigation_consistency` → B5 `screen_traversability` → B6 `interior_exterior_segregation` → B7 `time_period_isolation`.

**Per-task loop:**

- [ ] **Step 1: Reproduce & diagnose.** Dump this validator's vanilla errors:

```bash
python - <<'PY'
from pathlib import Path
from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.validation.runner import ValidationRunner
from tmos_randomizer.validation.config import ValidationConfig
from tmos_randomizer.validation.base import ValidationPhase, Severity
VID = "edge_compatibility"   # <-- set per task
ROM = Path("TMOS_ORIGINAL.nes")
world = load_rom(ROM); content = ROM.read_bytes()
runner = ValidationRunner(ValidationConfig()); ctx = {"rom_data": content}
shown = 0
for cn in range(1,6):
    ch = world.chapters.get(cn)
    if not ch: continue
    for i in runner.run_for_chapter(ch, phase=ValidationPhase.FINAL, context=ctx).issues:
        if i.severity==Severity.ERROR and i.validator_id==VID and shown<25:
            print(f"ch{cn}", i.screen_index, i.direction, "|", i.message[:160]); shown+=1
PY
```
Inspect 15–25 examples. Cross-check 2–3 against the ROM/known-good behavior (e.g., load those screens in the running UI — they are reachable/playable in vanilla).

- [ ] **Step 2: Classify the defect** into one (or a mix) of:
  - **(a) Rule too strict** — the rule rejects a vanilla-shipped condition. Fix: recast as *relative to vanilla* (only flag a randomized edge if it is **worse** than the vanilla edge at that boundary), or correct the rule to match real engine semantics. Do NOT simply disable the check.
  - **(b) Decode bug** — the validator reads the wrong tiles/fields (e.g., `extract_edges` mis-decodes). Fix: correct the decode; vanilla then passes for the right reason.
  - **(c) Severity misclassified** — the finding is an observation, not a game-breaker. Fix: downgrade ERROR→WARNING/INFO in the validator (and/or its config default).
  - **(d) Scope error** — the validator checks edges/screens the engine never traverses on foot (warps, doors, one-way drops). Fix: exclude those from the check (as the existing Time-Door exclusion already does in `edge_alignment`).

  **Per-validator starting hypothesis (confirm in Step 1 before applying):**
  - **B2 `edge_compatibility` (252):** likely (a)/(d) — vanilla seams routinely fail a strict walkable-compatibility rule; many flagged edges are nav pointers the player never walks. Expect to scope out non-walked edges and/or recast to "no worse than vanilla."
  - **B3 `edge_alignment` (221):** likely (a)/(b) — `min_aligned_walkable=1` position-for-position alignment that vanilla doesn't obey, or `extract_edges` mis-decoding. Confirm decode against a known screen first.
  - **B4 `navigation_consistency` (120):** likely (d)/(a) — intentional vanilla one-way/asymmetric joins read as conflicts. This validator matters most for randomized output; preserve its conflict/connectivity detection — only stop flagging legitimate vanilla asymmetry.
  - **B5 `screen_traversability` (9):** likely (d) — a few vanilla screens reached only via warps/events the reachability walk doesn't model. Teach it those entry modes.
  - **B6 `interior_exterior_segregation` (2):** inspect both; likely (a) or (c).
  - **B7 `time_period_isolation` (1):** inspect the single case; likely (a) or (d).

- [ ] **Step 3: Add a regression guard for randomized input (anti-over-relaxation).** Before changing the validator, ensure a test proves it STILL fires on a genuinely broken case. Check `tests/test_validation/` for an existing unit test for this validator:
  - If one exists, confirm it covers a deliberately-broken input that must still produce an ERROR; if not, add that case.
  - If none exists, add `tests/test_validation/test_<validator>_guard.py` constructing a minimal broken input (reuse existing chapter/screen fixtures in `tests/test_validation/`) and asserting ≥1 ERROR.
  Run it — it must PASS both before and after the fix.

- [ ] **Step 4: Apply the minimal fix** in the validator module (and `validation/config.py` only if the fix is a config default). Keep the change as small as the diagnosis allows.

- [ ] **Step 5: Verify green for this validator + no regressions.**

```bash
python -m pytest "tests/test_validation/test_vanilla_baseline.py::test_vanilla_has_no_errors_from[<vid>]" -v
python -m pytest tests/test_validation/ -v
```
Expected: this validator's baseline case PASSES; the anti-over-relaxation guard PASSES; no other validation test regresses.

- [ ] **Step 6: Commit**

```bash
git add src/tmos_randomizer/validation/validators/<file>.py   # + config.py / guard test if changed
git commit -F <msgfile>
```
Message template:
```
fix(validation): <validator> accepts vanilla without losing detection

Diagnosis: <one line — which defect category and why vanilla failed>.
Fix: <one line>. Vanilla errors <N>→0; broken-input guard still fails.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## Task B8: Confirm the gate is fully green

**Files:** none (verification + final state).

- [ ] **Step 1: Full validation suite green**

Run: `python -m pytest tests/test_validation/test_vanilla_baseline.py tests/test_validation/ -v`
Expected: `test_vanilla_passes_all_validators` PASSES and all parametrized cases PASS.

- [ ] **Step 2: Full backend suite**

Run: `python -m pytest -q`
Expected: no regressions introduced by the validator changes.

- [ ] **Step 3: End-to-end sanity in the UI**

Restart the backend (`--reload`), open the Debug tab → Validation → "Validate ROM" on the clean default ROM. Expected: **✓ ALL VALIDATORS PASSED**, 0 errors. (Warnings may remain — they are not gated.)

- [ ] **Step 4: Commit (if any verification-only fixups were needed; otherwise skip)**

---

## Self-Review Notes (author)

- **Spec coverage:** Debug tab (A6) ✓; ROM-vs-vanilla diff (A1–A4) ✓; report-all Validate (A5) ✓; fix failing validators (B2–B7) ✓; zero-error acceptance criterion + regression test (B1, B8) ✓; over-relaxation guard (B-loop Step 3) ✓; phasing (Phase A / Phase B) ✓.
- **Known honest limit (Phase B):** the *exact* validator patch in each B-task's Step 4 cannot be pre-written — it is determined by the Step 1 diagnosis. Each task therefore specifies the diagnostic, the classification rule, a per-validator starting hypothesis, and the green/guard gates that define "done." This is deliberate, not a placeholder.
- **Type consistency:** `ChangesResponse`/`ChangeGroup`/`ChangeEntry` and `ValidateResponse`/`ChapterValidation`/`ValidationIssue` are defined once in A3 and consumed unchanged in A4/A5. `getChanges()`/`validateRom()` names match between client and components. `DebugView` section ids (`changes`/`validation`/`inspector`) are self-contained.
- **Open risk:** A2's reader attribute names (`_player_stats`/`_inv_caps`/`_exp_table`) must be confirmed by grep before use; the task says so explicitly.
