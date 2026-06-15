# Phase 1 — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the foundation for the entity-centric UI reorg — the new 8-tab information architecture shell, a data-driven 3-tier safety model, a field-metadata pipeline sourced from the in-repo authoritative enums, and the reusable guided-field UI building blocks.

**Architecture:** A Python module builds field metadata (descriptions, safety tier, enum/range, warnings, "used by") from the existing `core/enums.py` (the in-repo mirror of the GameAnalysis2 knowledgebase) — this is the single source of truth. A new FastAPI endpoint serves it. The React UI fetches it into the Zustand store and renders it through two new presentational components (`SafetyBadge`, `GuidedField`). The 11-tab bar is restructured into 7 entity tabs + 1 gated Expert tab; existing views are re-mounted under the new tab IDs as-is (deep editors come in later phases).

**Tech Stack:** Python 3.8+, FastAPI, pytest (backend); React 19 + TypeScript, Zustand 5, Tailwind 4, Vite 7, vitest (frontend).

**Scope note:** Phase 1 ships field metadata for the **WorldScreen** entity only (the 16 ROM bytes). Other entities' metadata are added in their own phases. This keeps Phase 1 self-contained and testable while giving Phase 2 (World tab) everything it needs.

**Working directory for all commands:** `projects/TMOS_Randomizer_V2`

---

## File Structure

**Backend (create):**
- `src/tmos_randomizer/core/field_metadata.py` — builds the field-metadata dict from enums; the single source of truth.
- `tools/generate_field_metadata.py` — CLI that writes the baked JSON artifact.
- `src/tmos_randomizer/data/field_metadata.json` — generated artifact (baked into the package).
- `tests/test_core/test_field_metadata.py` — tests for the builder.
- `tests/test_api/test_metadata_endpoint.py` — tests for the endpoint.

**Backend (modify):**
- `src/tmos_randomizer/core/enums.py` — add `CRASH_ENEMY_IDS` constant (referenced by the safety model; used fully in later phases).
- `src/tmos_randomizer/api/server.py` — add `GET /api/metadata/fields`.

**Frontend (create):**
- `ui/src/types/metadata.ts` — `SafetyTier`, `FieldMetadata`, `EntityMetadata`, `FieldMetadataResponse` types.
- `ui/src/components/shared/SafetyBadge.tsx` — tier badge (pure).
- `ui/src/components/shared/GuidedField.tsx` — guided field wrapper (pure).
- `ui/src/utils/safety.ts` — pure helpers (tier → styling, metadata lookup).
- `ui/src/utils/safety.test.ts` — vitest unit tests for the helpers.
- `ui/vitest.config.ts` — minimal vitest config.

**Frontend (modify):**
- `ui/package.json` — add vitest + `test` script.
- `ui/src/api/client.ts` — add `getFieldMetadata()`.
- `ui/src/store/index.ts` — extend `TabType`, add metadata state + `loadFieldMetadata` action.
- `ui/src/components/layout/MainContent.tsx` — new `TABS` array (8 tabs), route new tab IDs to existing views, update `GLOBAL_TABS`.

---

## Task 1: `CRASH_ENEMY_IDS` constant in enums

**Files:**
- Modify: `src/tmos_randomizer/core/enums.py` (near `SAFE_EVENTS`/`DANGEROUS_EVENTS`, around line 375-388)
- Test: `tests/test_core/test_enums_crash_ids.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_core/test_enums_crash_ids.py`:

```python
from tmos_randomizer.core.enums import CRASH_ENEMY_IDS, CONSERVATIVE_DANGER_ENEMY_IDS


def test_hard_crash_enemy_ids():
    # 0x0B and 0x0C hard-crash the game if loaded in an encounter.
    assert CRASH_ENEMY_IDS == {0x0B, 0x0C}


def test_conservative_danger_ids_superset_of_crash():
    # Unknown-status IDs are treated conservatively as dangerous.
    assert CRASH_ENEMY_IDS.issubset(CONSERVATIVE_DANGER_ENEMY_IDS)
    assert {0x0F, 0x17, 0x25}.issubset(CONSERVATIVE_DANGER_ENEMY_IDS)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_core/test_enums_crash_ids.py -v`
Expected: FAIL with `ImportError: cannot import name 'CRASH_ENEMY_IDS'`

- [ ] **Step 3: Add the constants**

In `src/tmos_randomizer/core/enums.py`, after the `DANGEROUS_EVENTS` definition (line ~378), add:

```python
# Turn-based enemy byte IDs that hard-crash the game if loaded into an
# encounter lineup. Source: GameAnalysis2 combat/enemies/README.md [ROM_VERIFIED].
CRASH_ENEMY_IDS: Set[int] = {0x0B, 0x0C}

# Crash IDs plus unknown-status IDs (0x0F, 0x17, 0x25) treated conservatively
# as dangerous — never offered as selectable enemy values in the UI.
CONSERVATIVE_DANGER_ENEMY_IDS: Set[int] = CRASH_ENEMY_IDS | {0x0F, 0x17, 0x25}
```

(`Set` is already imported in this module — confirm `from typing import Set` is present; if not, add it.)

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_core/test_enums_crash_ids.py -v`
Expected: PASS (2 passed)

- [ ] **Step 5: Commit**

```bash
git add tests/test_core/test_enums_crash_ids.py src/tmos_randomizer/core/enums.py
git commit -m "feat(core): add CRASH_ENEMY_IDS safety constants"
```

---

## Task 2: Field-metadata builder (WorldScreen)

Builds the metadata dict from enums. Tier classification per the spec: Safe = free edit, Caution = validated inline, Danger = Expert-tab-only.

**Files:**
- Create: `src/tmos_randomizer/core/field_metadata.py`
- Test: `tests/test_core/test_field_metadata.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_core/test_field_metadata.py`:

```python
from tmos_randomizer.core.field_metadata import build_field_metadata

VALID_TIERS = {"safe", "caution", "danger"}


def test_has_worldscreen_entity_with_16_fields():
    meta = build_field_metadata()
    ws = meta["entities"]["worldscreen"]
    assert ws["label"] == "World Screen"
    # All 16 ROM bytes are represented.
    assert len(ws["fields"]) == 16


def test_every_field_has_required_keys_and_valid_tier():
    meta = build_field_metadata()
    for field in meta["entities"]["worldscreen"]["fields"].values():
        assert {"label", "byte", "tier", "description"} <= field.keys()
        assert field["tier"] in VALID_TIERS
        assert isinstance(field["description"], str) and field["description"]


def test_tier_assignments_match_spec():
    fields = build_field_metadata()["entities"]["worldscreen"]["fields"]
    assert fields["top_tiles"]["tier"] == "safe"
    assert fields["worldscreen_color"]["tier"] == "safe"
    assert fields["content"]["tier"] == "caution"
    assert fields["parent_world"]["tier"] == "caution"
    # Crash/corruption-prone bytes are Danger (Expert-tab only).
    assert fields["objectset"]["tier"] == "danger"
    assert fields["datapointer"]["tier"] == "danger"
    assert fields["exit_position"]["tier"] == "danger"
    assert fields["event"]["tier"] == "danger"


def test_content_field_has_enum_and_chapter_warning():
    content = build_field_metadata()["entities"]["worldscreen"]["fields"]["content"]
    assert content["control"] == "enum"
    # Enum is non-empty list of {value,label}.
    assert content["enum"] and {"value", "label"} <= content["enum"][0].keys()
    # Chapter-specific NPC hazard surfaced as a warning.
    assert "chapter" in content["warning"].lower()


def test_version_and_source_present():
    meta = build_field_metadata()
    assert meta["version"]
    assert "enums" in meta["generated_from"]
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_core/test_field_metadata.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'tmos_randomizer.core.field_metadata'`

- [ ] **Step 3: Write the builder**

Create `src/tmos_randomizer/core/field_metadata.py`:

```python
"""Builds field metadata (descriptions, safety tier, enums, warnings) for the UI.

This module is the single source of truth for the 3-tier safety model and the
guided-editing metadata. Tiers and enums derive from core/enums.py, which mirrors
the authoritative GameAnalysis2 knowledgebase.

Tiers:
    safe    - edit freely on the entity tab.
    caution - editable inline, but validated; controls pre-filtered to valid values.
    danger  - never shown on entity tabs; only in the gated Expert tab.
"""

from __future__ import annotations

from typing import Any, Dict, List

from .enums import ContentType, EventType, ParentWorld

METADATA_VERSION = "1"


def _enum_options(enum_cls) -> List[Dict[str, Any]]:
    """Render an IntEnum as a list of {value, label} dicts, sorted by value."""
    return [
        {"value": int(member.value), "label": f"{member.name} (0x{int(member.value):02X})"}
        for member in sorted(enum_cls, key=lambda m: int(m.value))
    ]


def _worldscreen_fields() -> Dict[str, Dict[str, Any]]:
    return {
        "parent_world": {
            "label": "Parent World / Music", "byte": 0, "tier": "caution",
            "control": "enum", "enum": _enum_options(ParentWorld),
            "description": "Section type + background music for this screen.",
            "warning": "Must be a valid section-type value or audio/state may glitch.",
            "used_by": ["section classification", "music"],
        },
        "ambient_sound": {
            "label": "Ambient Sound", "byte": 1, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Ambient sound-effect ID played on the screen.",
            "warning": "", "used_by": [],
        },
        "content": {
            "label": "Content / Building", "byte": 2, "tier": "caution",
            "control": "enum", "enum": _enum_options(ContentType),
            "description": "Building, NPC, shop, boss stage, or time door on this screen.",
            "warning": "NPC values 0x80-0x8F summon a different character per chapter; "
                       "do not move such a screen across chapters.",
            "used_by": ["objectset spawn lookup", "NPC dialog"],
        },
        "objectset": {
            "label": "ObjectSet (enemy spawn set)", "byte": 3, "tier": "danger",
            "control": "number", "valid_range": [0, 255],
            "description": "Pointer into the per-chapter enemy spawn table.",
            "warning": "Out-of-range values crash on screen load.",
            "used_by": ["overworld enemy spawns"],
        },
        "screen_index_right": {
            "label": "Exit → Right", "byte": 4, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Destination screen when walking right (0xFE=building, 0xFF=blocked).",
            "warning": "Index must be < the chapter's screen count.",
            "used_by": ["navigation graph"],
        },
        "screen_index_left": {
            "label": "Exit → Left", "byte": 5, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Destination screen when walking left (0xFE=building, 0xFF=blocked).",
            "warning": "Index must be < the chapter's screen count.",
            "used_by": ["navigation graph"],
        },
        "screen_index_down": {
            "label": "Exit → Down", "byte": 6, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Destination screen when walking down (0xFE=building, 0xFF=blocked).",
            "warning": "Index must be < the chapter's screen count.",
            "used_by": ["navigation graph"],
        },
        "screen_index_up": {
            "label": "Exit → Up", "byte": 7, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Destination screen when walking up (0xFE=building, 0xFF=blocked).",
            "warning": "Index must be < the chapter's screen count.",
            "used_by": ["navigation graph"],
        },
        "datapointer": {
            "label": "DataPointer / CHR bank", "byte": 8, "tier": "danger",
            "control": "number", "valid_range": [0, 255],
            "description": "Selects CHR graphics bank (bits 0-5) and TileSection bank (bits 6-7).",
            "warning": "Invalid banks corrupt graphics; change only via tile-section swaps.",
            "used_by": ["tile rendering"],
        },
        "exit_position": {
            "label": "Exit Position", "byte": 9, "tier": "danger", "control": "number",
            "valid_range": [0, 255],
            "description": "Player spawn position when entering the screen.",
            "warning": "Bad values can spawn the player out of bounds.",
            "used_by": ["player spawn"],
        },
        "top_tiles": {
            "label": "Top TileSection", "byte": 10, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "TileSection index drawn in the top 4 rows.",
            "warning": "", "used_by": ["tile rendering"],
        },
        "bottom_tiles": {
            "label": "Bottom TileSection", "byte": 11, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "TileSection index drawn in the bottom rows.",
            "warning": "", "used_by": ["tile rendering"],
        },
        "worldscreen_color": {
            "label": "Background Palette", "byte": 12, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Background color palette selector.",
            "warning": "", "used_by": ["palette"],
        },
        "sprites_color": {
            "label": "Sprite Palette", "byte": 13, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Sprite color palette selector (0x12 = town).",
            "warning": "", "used_by": ["palette"],
        },
        "unknown": {
            "label": "Unknown (byte 14)", "byte": 14, "tier": "danger", "control": "number",
            "valid_range": [0, 255],
            "description": "Purpose not yet reverse-engineered.",
            "warning": "Unknown effect — do not modify.",
            "used_by": [],
        },
        "event": {
            "label": "Event byte", "byte": 15, "tier": "danger",
            "control": "enum", "enum": _enum_options(EventType),
            "description": "Dialog/door/transition trigger. Many values are story- or "
                           "navigation-critical.",
            "warning": "Most event values break story/navigation or crash; safe values are "
                       "only 0x00, 0x08, 0x22, 0x40.",
            "used_by": ["story scripting", "stairways", "maze logic"],
        },
    }


def build_field_metadata() -> Dict[str, Any]:
    """Return the full field-metadata document consumed by the UI."""
    return {
        "version": METADATA_VERSION,
        "generated_from": "tmos_randomizer.core.enums + curated descriptions",
        "entities": {
            "worldscreen": {
                "label": "World Screen",
                "fields": _worldscreen_fields(),
            },
        },
    }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_core/test_field_metadata.py -v`
Expected: PASS (5 passed)

- [ ] **Step 5: Commit**

```bash
git add tests/test_core/test_field_metadata.py src/tmos_randomizer/core/field_metadata.py
git commit -m "feat(core): field-metadata builder with 3-tier safety model (WorldScreen)"
```

---

## Task 3: Baked JSON artifact + generator CLI

**Files:**
- Create: `tools/generate_field_metadata.py`
- Create: `src/tmos_randomizer/data/field_metadata.json` (generated)
- Test: `tests/test_core/test_field_metadata_artifact.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_core/test_field_metadata_artifact.py`:

```python
import json
from pathlib import Path

from tmos_randomizer.core.field_metadata import build_field_metadata

ARTIFACT = (
    Path(__file__).resolve().parents[2]
    / "src" / "tmos_randomizer" / "data" / "field_metadata.json"
)


def test_artifact_exists_and_matches_builder():
    assert ARTIFACT.exists(), "Run: python tools/generate_field_metadata.py"
    on_disk = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    assert on_disk == build_field_metadata(), "Artifact stale — regenerate it."
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_core/test_field_metadata_artifact.py -v`
Expected: FAIL on the `assert ARTIFACT.exists()` assertion.

- [ ] **Step 3: Write the generator and run it**

Create `tools/generate_field_metadata.py`:

```python
"""Generate the baked field-metadata JSON artifact.

Usage:
    python tools/generate_field_metadata.py
"""

from __future__ import annotations

import json
from pathlib import Path

from tmos_randomizer.core.field_metadata import build_field_metadata

OUTPUT = (
    Path(__file__).resolve().parents[1]
    / "src" / "tmos_randomizer" / "data" / "field_metadata.json"
)


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(
        json.dumps(build_field_metadata(), indent=2) + "\n", encoding="utf-8"
    )
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
```

Then create the package data dir marker and generate the artifact:

```bash
python tools/generate_field_metadata.py
```

Expected output: `Wrote .../src/tmos_randomizer/data/field_metadata.json`

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_core/test_field_metadata_artifact.py -v`
Expected: PASS (1 passed)

- [ ] **Step 5: Commit**

```bash
git add tools/generate_field_metadata.py src/tmos_randomizer/data/field_metadata.json tests/test_core/test_field_metadata_artifact.py
git commit -m "feat(tools): generate baked field_metadata.json artifact"
```

---

## Task 4: `GET /api/metadata/fields` endpoint

**Files:**
- Modify: `src/tmos_randomizer/api/server.py` (add import near line 50-77; add route — place after the `get_items` route ~line 2628 for proximity to other metadata reads)
- Test: `tests/test_api/test_metadata_endpoint.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_api/test_metadata_endpoint.py`:

```python
from fastapi.testclient import TestClient

from tmos_randomizer.api.server import app

client = TestClient(app)


def test_metadata_endpoint_returns_worldscreen_fields():
    resp = client.get("/api/metadata/fields")
    assert resp.status_code == 200
    body = resp.json()
    assert body["version"]
    fields = body["entities"]["worldscreen"]["fields"]
    assert fields["content"]["tier"] == "caution"
    assert fields["objectset"]["tier"] == "danger"


def test_metadata_endpoint_needs_no_rom_loaded():
    # Metadata is static and must work before any ROM is uploaded.
    resp = client.get("/api/metadata/fields")
    assert resp.status_code == 200
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_api/test_metadata_endpoint.py -v`
Expected: FAIL with 404 (route not defined).

- [ ] **Step 3: Add the import and route**

In `src/tmos_randomizer/api/server.py`, add to the core imports block (after line 75, `from ..core import level_caps as _level_caps`):

```python
from ..core.field_metadata import build_field_metadata
```

Then add the route (after the `get_items` function, near line 2655):

```python
@app.get("/api/metadata/fields")
async def get_field_metadata():
    """Static field metadata: safety tiers, descriptions, enums, warnings.

    Drives the guided-editing UI and the 3-tier safety model. No ROM required.
    """
    return build_field_metadata()
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_api/test_metadata_endpoint.py -v`
Expected: PASS (2 passed). If `tests/test_api/` lacks `__init__.py` and collection fails, create an empty `tests/test_api/__init__.py`.

- [ ] **Step 5: Commit**

```bash
git add tests/test_api/test_metadata_endpoint.py src/tmos_randomizer/api/server.py
git commit -m "feat(api): GET /api/metadata/fields endpoint"
```

---

## Task 5: Frontend metadata types

**Files:**
- Create: `ui/src/types/metadata.ts`

- [ ] **Step 1: Write the types**

Create `ui/src/types/metadata.ts`:

```typescript
export type SafetyTier = 'safe' | 'caution' | 'danger';

export interface EnumOption {
  value: number;
  label: string;
}

export interface FieldMetadata {
  label: string;
  byte: number;
  tier: SafetyTier;
  description: string;
  control?: 'enum' | 'number';
  enum?: EnumOption[];
  valid_range?: [number, number];
  warning?: string;
  used_by?: string[];
}

export interface EntityMetadata {
  label: string;
  fields: Record<string, FieldMetadata>;
}

export interface FieldMetadataResponse {
  version: string;
  generated_from: string;
  entities: Record<string, EntityMetadata>;
}
```

- [ ] **Step 2: Verify it compiles**

Run (in `ui/`): `npx tsc --noEmit`
Expected: no errors referencing `metadata.ts`.

- [ ] **Step 3: Commit**

```bash
git add ui/src/types/metadata.ts
git commit -m "feat(ui): field-metadata types"
```

---

## Task 6: vitest setup + safety helpers (pure logic, TDD)

**Files:**
- Modify: `ui/package.json` (add devDeps + `test` script)
- Create: `ui/vitest.config.ts`
- Create: `ui/src/utils/safety.ts`
- Test: `ui/src/utils/safety.test.ts`

- [ ] **Step 1: Add vitest and the test script**

In `ui/package.json`, add to `scripts`:

```json
    "test": "vitest run"
```

Then install vitest:

Run (in `ui/`): `npm install -D vitest@^2`
Expected: vitest added to devDependencies.

- [ ] **Step 2: Add vitest config**

Create `ui/vitest.config.ts`:

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['src/**/*.test.ts'],
  },
});
```

- [ ] **Step 3: Write the failing test**

Create `ui/src/utils/safety.test.ts`:

```typescript
import { describe, it, expect } from 'vitest';
import { tierStyle, lookupField, isDanger } from './safety';
import type { FieldMetadataResponse } from '../types/metadata';

const META: FieldMetadataResponse = {
  version: '1',
  generated_from: 'test',
  entities: {
    worldscreen: {
      label: 'World Screen',
      fields: {
        content: { label: 'Content', byte: 2, tier: 'caution', description: 'x' },
        objectset: { label: 'ObjectSet', byte: 3, tier: 'danger', description: 'y' },
      },
    },
  },
};

describe('tierStyle', () => {
  it('maps each tier to distinct classes', () => {
    expect(tierStyle('safe').dot).toContain('green');
    expect(tierStyle('caution').dot).toContain('amber');
    expect(tierStyle('danger').dot).toContain('red');
  });
});

describe('lookupField', () => {
  it('finds a field by entity + field name', () => {
    expect(lookupField(META, 'worldscreen', 'content')?.tier).toBe('caution');
  });
  it('returns undefined for unknown fields', () => {
    expect(lookupField(META, 'worldscreen', 'nope')).toBeUndefined();
  });
});

describe('isDanger', () => {
  it('is true only for danger-tier fields', () => {
    expect(isDanger(META, 'worldscreen', 'objectset')).toBe(true);
    expect(isDanger(META, 'worldscreen', 'content')).toBe(false);
  });
});
```

- [ ] **Step 4: Run test to verify it fails**

Run (in `ui/`): `npm test`
Expected: FAIL — `safety.ts` not found / exports missing.

- [ ] **Step 5: Write the helpers**

Create `ui/src/utils/safety.ts`:

```typescript
import type { FieldMetadataResponse, FieldMetadata, SafetyTier } from '../types/metadata';

export interface TierStyle {
  dot: string;     // tailwind class for the status dot
  border: string;  // left-border accent
  label: string;   // human label
}

const STYLES: Record<SafetyTier, TierStyle> = {
  safe: { dot: 'bg-green-500', border: 'border-green-500', label: 'Safe' },
  caution: { dot: 'bg-amber-500', border: 'border-amber-500', label: 'Caution' },
  danger: { dot: 'bg-red-600', border: 'border-red-600', label: 'Danger' },
};

export function tierStyle(tier: SafetyTier): TierStyle {
  return STYLES[tier];
}

export function lookupField(
  meta: FieldMetadataResponse | null,
  entity: string,
  field: string,
): FieldMetadata | undefined {
  return meta?.entities[entity]?.fields[field];
}

export function isDanger(
  meta: FieldMetadataResponse | null,
  entity: string,
  field: string,
): boolean {
  return lookupField(meta, entity, field)?.tier === 'danger';
}
```

- [ ] **Step 6: Run test to verify it passes**

Run (in `ui/`): `npm test`
Expected: PASS (all safety.test.ts cases pass).

- [ ] **Step 7: Commit**

```bash
git add ui/package.json ui/package-lock.json ui/vitest.config.ts ui/src/utils/safety.ts ui/src/utils/safety.test.ts
git commit -m "feat(ui): vitest setup + safety-tier helpers"
```

---

## Task 7: `SafetyBadge` component

**Files:**
- Create: `ui/src/components/shared/SafetyBadge.tsx`

- [ ] **Step 1: Write the component**

Create `ui/src/components/shared/SafetyBadge.tsx`:

```tsx
import type { SafetyTier } from '../../types/metadata';
import { tierStyle } from '../../utils/safety';

const SYMBOL: Record<SafetyTier, string> = {
  safe: '●',     // ●
  caution: '▲',  // ▲
  danger: '⛔',   // ⛔
};

export function SafetyBadge({ tier }: { tier: SafetyTier }) {
  const style = tierStyle(tier);
  return (
    <span
      className={`inline-flex items-center gap-1 text-xs ${style.border} border rounded px-1`}
      title={`${style.label} field`}
    >
      <span className={`w-2 h-2 rounded-full ${style.dot}`} aria-hidden />
      {SYMBOL[tier]}
    </span>
  );
}
```

- [ ] **Step 2: Verify it compiles**

Run (in `ui/`): `npx tsc --noEmit`
Expected: no errors referencing `SafetyBadge.tsx`.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/shared/SafetyBadge.tsx
git commit -m "feat(ui): SafetyBadge component"
```

---

## Task 8: `GuidedField` component

Wraps a labeled control with vanilla value, changed marker, safety badge, ⓘ popover (description + warning + used-by). Presentational only — the actual input is passed as children so each editor supplies its own control.

**Files:**
- Create: `ui/src/components/shared/GuidedField.tsx`

- [ ] **Step 1: Write the component**

Create `ui/src/components/shared/GuidedField.tsx`:

```tsx
import { useState, type ReactNode } from 'react';
import type { FieldMetadata } from '../../types/metadata';
import { SafetyBadge } from './SafetyBadge';

interface GuidedFieldProps {
  meta: FieldMetadata;
  /** Current value, for the "changed vs vanilla" indicator. */
  value?: number | string;
  /** Vanilla value from ROM, if known. */
  vanilla?: number | string;
  children: ReactNode; // the input control
}

export function GuidedField({ meta, value, vanilla, children }: GuidedFieldProps) {
  const [showInfo, setShowInfo] = useState(false);
  const changed = vanilla !== undefined && value !== undefined && value !== vanilla;

  return (
    <div className="mb-3 text-sm">
      <div className="flex items-center gap-2 mb-1">
        <span className="text-slate-300 font-medium">{meta.label}</span>
        <SafetyBadge tier={meta.tier} />
        <button
          type="button"
          onClick={() => setShowInfo((s) => !s)}
          className="text-slate-500 hover:text-slate-300"
          title="Field info"
          aria-label={`Info about ${meta.label}`}
        >
          {'ⓘ'}
        </button>
      </div>

      {children}

      {vanilla !== undefined && (
        <div className="text-xs text-slate-500 mt-0.5">
          vanilla: <span className="text-slate-400">{String(vanilla)}</span>
          {changed && <span className="ml-1 text-amber-400">changed ✏</span>}
        </div>
      )}

      {showInfo && (
        <div className="mt-1 p-2 bg-slate-800 border border-dashed border-slate-600 rounded text-xs text-slate-300">
          <div>{meta.description}</div>
          {meta.warning && (
            <div className="mt-1 text-amber-400">{'⚠'} {meta.warning}</div>
          )}
          {meta.used_by && meta.used_by.length > 0 && (
            <div className="mt-1 text-slate-500">
              Used by: {meta.used_by.join(', ')}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
```

- [ ] **Step 2: Verify it compiles**

Run (in `ui/`): `npx tsc --noEmit`
Expected: no errors referencing `GuidedField.tsx`.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/shared/GuidedField.tsx
git commit -m "feat(ui): GuidedField component (vanilla/changed/info popover)"
```

---

## Task 9: API client + store wiring for metadata

**Files:**
- Modify: `ui/src/api/client.ts` (add method following the existing fetch pattern)
- Modify: `ui/src/store/index.ts` (add state + action; load on init)

- [ ] **Step 1: Add the client method**

In `ui/src/api/client.ts`, add an import at the top:

```typescript
import type { FieldMetadataResponse } from '../types/metadata';
```

Add this method to the `ApiClient` class (follow the existing `async`/fetch style used by other GET methods such as `getItems`):

```typescript
  async getFieldMetadata(): Promise<FieldMetadataResponse> {
    const res = await fetch(`${this.baseUrl}/api/metadata/fields`);
    if (!res.ok) throw new Error(`Failed to fetch field metadata: ${res.status}`);
    return res.json();
  }
```

(If the class references the base URL by another name, e.g. `this.base`, match it.)

- [ ] **Step 2: Add store state + action**

In `ui/src/store/index.ts`:

Add to the imports:

```typescript
import type { FieldMetadataResponse } from '../types/metadata';
```

Add to the state interface (near `selectedTab: TabType;`, line ~85):

```typescript
  fieldMetadata: FieldMetadataResponse | null;
```

Add to the actions interface (near `setSelectedTab`, line ~147):

```typescript
  loadFieldMetadata: () => Promise<void>;
```

Add the initial value in the store creator (near other initial state):

```typescript
  fieldMetadata: null,
```

Add the action implementation (near `setSelectedTab` impl):

```typescript
  loadFieldMetadata: async () => {
    try {
      const meta = await api.getFieldMetadata();
      set({ fieldMetadata: meta });
    } catch (e) {
      console.error('Failed to load field metadata', e);
    }
  },
```

(Use whatever the file already calls the `ApiClient` instance — search for `getItems(` to find the instance name, e.g. `api` or `apiClient`.)

- [ ] **Step 3: Load metadata on app init**

In `ui/src/store/index.ts`, find where `checkApiConnection` is defined/called on startup. In the success path of `checkApiConnection` (after the connection is confirmed), call:

```typescript
      get().loadFieldMetadata();
```

If `checkApiConnection` doesn't already use `get()`, the Zustand creator signature is `(set, get) => ({...})` — confirm `get` is in scope; it is used elsewhere in this 1325-line store.

- [ ] **Step 4: Verify it compiles**

Run (in `ui/`): `npm run build`
Expected: `tsc -b` passes with no type errors; Vite build completes.

- [ ] **Step 5: Commit**

```bash
git add ui/src/api/client.ts ui/src/store/index.ts
git commit -m "feat(ui): fetch field metadata into store on startup"
```

---

## Task 10: New 8-tab information architecture shell

Restructure the tab bar from 11 tabs to 7 entity tabs + 1 gated Expert tab. Existing views are re-mounted under the new tab IDs unchanged (deep editors arrive in later phases). The Expert tab gets a gated placeholder.

**Files:**
- Modify: `ui/src/store/index.ts` (extend `TabType`)
- Modify: `ui/src/components/layout/MainContent.tsx` (TABS array, routing, GLOBAL_TABS)
- Create: `ui/src/components/views/ExpertView.tsx`
- Modify: `ui/src/components/views/index.ts` (export ExpertView)

- [ ] **Step 1: Extend the TabType union**

In `ui/src/store/index.ts` line 29, replace:

```typescript
export type TabType = 'map' | 'flow' | 'tiles' | 'tilebank' | 'items' | 'stats' | 'enemies' | 'allies' | 'advanced' | 'validation' | 'debug';
```

with:

```typescript
// Entity-centric IA: 7 entity tabs + 1 gated Expert tab.
export type TabType = 'world' | 'enemies' | 'items' | 'hero' | 'allies' | 'graphics' | 'randomize' | 'expert';
```

Also update the initial `selectedTab` value in the store creator: search for `selectedTab:` initial assignment and set it to `'world'`.

- [ ] **Step 2: Create the gated Expert placeholder view**

Create `ui/src/components/views/ExpertView.tsx`:

```tsx
import { useState } from 'react';
import { AdvancedView } from './AdvancedView';
import { JsonDebugPanel } from '../debug/JsonDebugPanel';

export function ExpertView() {
  const [unlocked, setUnlocked] = useState(false);

  if (!unlocked) {
    return (
      <div className="flex items-center justify-center h-full p-8">
        <div className="max-w-md text-center">
          <div className="text-4xl mb-3">{'⚠'}</div>
          <h2 className="text-xl font-semibold text-red-400 mb-2">Danger Zone</h2>
          <p className="text-slate-400 mb-6">
            These controls edit raw ROM bytes and can crash or corrupt the game if
            set incorrectly. Only proceed if you understand the risk.
          </p>
          <button
            onClick={() => setUnlocked(true)}
            className="px-4 py-2 bg-red-700 hover:bg-red-600 text-white rounded font-medium"
          >
            I understand — unlock Expert controls
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full overflow-y-auto">
      <AdvancedView />
      <div className="border-t border-slate-700 mt-4">
        <JsonDebugPanel />
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Export ExpertView**

In `ui/src/components/views/index.ts`, add:

```typescript
export { ExpertView } from './ExpertView';
```

- [ ] **Step 4: Rewrite the tab bar + routing in MainContent**

In `ui/src/components/layout/MainContent.tsx`:

Replace the `TABS` array (lines 12-24) with:

```tsx
const TABS: { id: TabType; label: string }[] = [
  { id: 'world', label: 'World' },
  { id: 'enemies', label: 'Enemies' },
  { id: 'items', label: 'Items & Economy' },
  { id: 'hero', label: 'Hero' },
  { id: 'allies', label: 'Allies' },
  { id: 'graphics', label: 'Graphics' },
  { id: 'randomize', label: 'Randomize' },
  { id: 'expert', label: '⚠ Expert' },
];
```

Update the import on line 9 to include `ExpertView`:

```tsx
import { ItemsView, PlayerStatsView, EnemiesView, AlliesView, AdvancedView, ValidationView, MapView, ExpertView } from '../views';
```

Replace `GLOBAL_TABS` (line 33) — these tabs don't require a chapter-scoped `chapterData`:

```tsx
const GLOBAL_TABS = new Set<TabType>(['enemies', 'hero', 'graphics', 'expert', 'items', 'randomize']);
```

Update the view-mode switcher condition (line 83) from `selectedTab === 'map'` to `selectedTab === 'world'`.

Replace the entire content-routing block (lines 129-190, the `selectedTab === ...` conditionals) with the new mapping. The `world` tab keeps the existing map/grid/tiles views; `randomize` shows the plan flow + validation; the rest re-mount existing views:

```tsx
              {/* World: screen map/grid (Phase 2 will merge tiles + side-panel editing) */}
              {selectedTab === 'world' && viewMode === 'navigation' && chapterData && (
                <NavigationMapView
                  chapter={chapterData}
                  selectedScreen={selectedScreen}
                  onScreenSelect={setSelectedScreen}
                  tileSize={48}
                />
              )}
              {selectedTab === 'world' && viewMode === 'grid' && chapterData && (
                <ScreenGrid
                  screens={chapterData.screens}
                  selectedScreen={selectedScreen}
                  onScreenSelect={setSelectedScreen}
                  gridWidth={16}
                />
              )}

              {/* Randomize: plan flow graph + validation report */}
              {selectedTab === 'randomize' && planChapter && planChapter.sections.length > 0 && (
                <MapView chapter={planChapter} />
              )}
              {selectedTab === 'randomize' && (!planChapter || planChapter.sections.length === 0) && (
                <div className="flex items-center justify-center h-full">
                  <div className="text-center p-8">
                    <div className="text-4xl mb-4 opacity-50">{'\u{1F50D}'}</div>
                    <h3 className="text-lg font-medium text-slate-300 mb-2">No Plan Generated</h3>
                    <p className="text-sm text-slate-500 max-w-sm">
                      Click the Randomize button to generate a randomization plan.
                    </p>
                  </div>
                </div>
              )}

              {selectedTab === 'items' && planChapter && <ItemsView chapter={planChapter} />}
              {selectedTab === 'hero' && <PlayerStatsView />}
              {selectedTab === 'enemies' && <EnemiesView />}
              {selectedTab === 'allies' && planChapter && <AlliesView chapter={planChapter} />}
              {selectedTab === 'graphics' && <TileBankView />}
              {selectedTab === 'expert' && <ExpertView />}
```

Update the Screen Detail Panel condition (line 194) from `selectedTab === 'map'` to `selectedTab === 'world'`.

> Note: `TilesView`/`TileGridView` and `ValidationView` are intentionally not yet wired into the new tabs — they get merged into World (tiles) and Randomize (validation) in Phases 2 and 5. Leaving them out now is expected; their imports can stay for later use or be removed to satisfy lint (see Step 5).

- [ ] **Step 5: Verify build + lint**

Run (in `ui/`): `npm run build`
Expected: `tsc -b` passes. If lint flags unused imports (`TileGridView`, `ValidationView`, `JsonDebugPanel`, `AdvancedView` now only used inside ExpertView), remove the now-unused imports from `MainContent.tsx` until the build is clean.

Run (in `ui/`): `npm run lint`
Expected: no errors.

- [ ] **Step 6: Manual verification**

Start backend: `python -m tmos_randomizer serve --port 8000` (from `projects/TMOS_Randomizer_V2`)
Start UI: `npm run dev` (from `ui/`)
Open the dev URL. Confirm:
- 8 tabs render: World, Enemies, Items & Economy, Hero, Allies, Graphics, Randomize, ⚠ Expert.
- World tab shows the screen map/grid + the detail panel on screen select.
- Expert tab shows the Danger Zone gate; clicking unlock reveals the advanced panels.
- No console errors; `GET /api/metadata/fields` returns 200 in the network tab.

- [ ] **Step 7: Commit**

```bash
git add ui/src/store/index.ts ui/src/components/layout/MainContent.tsx ui/src/components/views/ExpertView.tsx ui/src/components/views/index.ts
git commit -m "feat(ui): entity-centric 8-tab IA shell + gated Expert tab"
```

---

## Self-Review

**Spec coverage (Phase 1 scope):**
- New IA shell (8 tabs, gated Expert) → Task 10. ✔
- 3-tier safety infrastructure → Tasks 1, 2, 6, 7 (constants, tiers in metadata, helpers, badge). ✔
- Field-metadata pipeline + endpoint (baked, from knowledgebase-mirroring enums) → Tasks 2, 3, 4, 9. ✔
- Guided-field component → Task 8. ✔
- Out of Phase 1 by design: per-entity deep editors (Phases 2-4), full validation system (Phase 5), metadata for non-WorldScreen entities (their phases). Stated in Scope note.

**Type consistency:** `SafetyTier`/`FieldMetadata`/`FieldMetadataResponse` defined in Task 5 are consumed unchanged in Tasks 6-9. `tierStyle`/`lookupField`/`isDanger` signatures match between Task 6 definition and usage. `build_field_metadata()` shape (`version`, `generated_from`, `entities.worldscreen.fields`) is consistent across Tasks 2, 3, 4 and the FE types. `getFieldMetadata()` return type matches the store action and endpoint payload.

**Placeholder scan:** No TBD/TODO; every code step shows complete code; commands include expected output.

---

## Notes for the Executor

- Run all Python commands from `projects/TMOS_Randomizer_V2` and all npm commands from `projects/TMOS_Randomizer_V2/ui`.
- The store (`index.ts`, 1325 lines) and `server.py` (1700+ lines) are large; use search to find exact insertion points rather than line numbers, which drift.
- This is the first work on branch `docs/ui-reorg-design` beyond the spec; if you prefer a clean feature branch, create `feat/phase1-foundation` off `master` before Task 1.
- Several existing views are deliberately re-mounted unchanged; do not refactor them in Phase 1.
