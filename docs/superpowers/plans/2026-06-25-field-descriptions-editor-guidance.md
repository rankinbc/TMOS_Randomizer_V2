# Richer Field Descriptions & Editor Guidance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Document all 10 battle-enemy record bytes (and enrich the thin worldscreen fields) in `field_metadata.py`, generalize the enemy write path so every byte is editable, make the roster editor data-driven from metadata, surface `valid_range` in the shared guided-field info box, and correct the stale Expert-era tier docstrings.

**Architecture:** `core/field_metadata.py` is the single source of guidance (content). `core/enemy_stats.py` + `api/server.py` carry the read/write path, keyed by one shared `FIELD_OFFSETS` map and semantic field names. The frontend client/store widen to those names, and `BattleRosterEditor` renders its fields from metadata instead of a hardcoded 3-key list. `valid_range` lands in the shared `GuidedField` so the hint appears app-wide from one edit.

**Tech Stack:** Python (FastAPI, pydantic, pytest) backend; React 19 + TypeScript + zustand frontend; Vitest + tsc + ESLint.

## Global Constraints

- **Source of truth:** `core/field_metadata.py`. After editing it, regenerate the artifact with `python tools/generate_field_metadata.py`; `tests/test_core/test_field_metadata_artifact.py` (asserts JSON == builder output) must stay green.
- **Authoritative byte semantics** come from GameAnalysis2 (byte 2 = bribe price, byte 8 = ATK, bytes 3–6 = RNG/probability classes, byte 9 = unknown constant). This supersedes the older in-repo `enemy_stats.py` docstring.
- **The 10 enemy field keys → record offsets (verbatim):** `ep=0, rupia=1, bribe=2, escape_trigger=3, action_prob=4, lineup_min=5, action_prob2=6, hp=7, atk=8, byte_9=9`.
- **Tiers:** `safe` = `ep, rupia, bribe, hp, atk`; `caution` = `escape_trigger, action_prob, lineup_min, action_prob2, byte_9`. Every enemy field has `valid_range: [0, 255]` and `control: "number"`.
- **`METADATA_VERSION` bumps `"1" → "2"`.**
- **Crash IDs `0x0B`/`0x0C`** are never selectable; danger-listed enemies (`DANGER_ENEMY_IDS`) stay **read-only** in the roster editor (across all 10 fields now).
- **Backend tests:** `pytest` with the worktree `src` on `PYTHONPATH` (the package is editable-installed against the main tree). ROM-dependent tests skip if the default ROM is absent — that is acceptable (they run in CI/local with the ROM present).
- **Frontend gate (per repo convention):** `npm run build` (tsc + vite) must pass clean — the primary gate. For lint, run **scoped** `npx eslint <changed files>` requiring 0 errors; **do NOT** run whole-tree `npm run lint` (the baseline carries 32 pre-existing errors in unrelated files). Existing Vitest suites must stay green (`npm test`). Frontend commands run from `<worktree>/projects/TMOS_Randomizer_V2/ui`.
- **Shared working tree:** stage only each task's own files by explicit path; never `git add -A`.
- **`valid_range` is already in the `FieldMetadata` TS type** (`ui/src/types/metadata.ts:15`) — no type change needed, only rendering.

---

### Task 1: Enemy + worldscreen metadata content

Pure content + docstring in the metadata builder, plus the regenerated artifact. No runtime-behavior code.

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/field_metadata.py` (module docstring lines 1–11; `_worldscreen_fields()` thin fields; replace `_enemy_fields()` lines 146–175; `METADATA_VERSION` line 20)
- Modify (regenerate): `projects/TMOS_Randomizer_V2/src/tmos_randomizer/data/field_metadata.json`
- Test: `projects/TMOS_Randomizer_V2/tests/test_core/test_field_metadata.py`

**Interfaces:**
- Produces: `build_field_metadata()["entities"]["enemy"]["fields"]` now has 10 fields keyed `ep, rupia, bribe, escape_trigger, action_prob, lineup_min, action_prob2, hp, atk, byte_9`, each with `byte`, `tier`, `control`, `valid_range`, `description`, `warning`, `used_by`. `build_field_metadata()["version"] == "2"`. (Consumed by Task 4's editor and the metadata endpoint.)

- [ ] **Step 1: Write the failing tests**

Append to `projects/TMOS_Randomizer_V2/tests/test_core/test_field_metadata.py`:

```python
from tmos_randomizer.core.field_metadata import build_field_metadata


def test_enemy_entity_documents_all_ten_bytes():
    fields = build_field_metadata()["entities"]["enemy"]["fields"]
    assert set(fields) == {
        "ep", "rupia", "bribe", "escape_trigger", "action_prob",
        "lineup_min", "action_prob2", "hp", "atk", "byte_9",
    }
    # Byte offsets are exactly 0..9, one per field.
    assert sorted(f["byte"] for f in fields.values()) == list(range(10))
    assert fields["bribe"]["byte"] == 2
    assert fields["atk"]["byte"] == 8
    for f in fields.values():
        assert f["tier"] in {"safe", "caution", "danger"}
        assert f["valid_range"] == [0, 255]
        assert f["description"]


def test_enemy_tier_assignment():
    fields = build_field_metadata()["entities"]["enemy"]["fields"]
    assert fields["bribe"]["tier"] == "safe"
    assert fields["atk"]["tier"] == "safe"
    assert fields["escape_trigger"]["tier"] == "caution"
    assert fields["byte_9"]["tier"] == "caution"


def test_metadata_version_is_two():
    assert build_field_metadata()["version"] == "2"
```

- [ ] **Step 2: Run the tests to verify they fail**

Run (from `projects/TMOS_Randomizer_V2`, `PYTHONPATH` = worktree `src`): `pytest tests/test_core/test_field_metadata.py -v`
Expected: the three new tests FAIL (only 3 enemy fields exist; version is `"1"`).

- [ ] **Step 3: Bump the metadata version**

In `field_metadata.py` line 20, change:

```python
METADATA_VERSION = "1"
```
to:
```python
METADATA_VERSION = "2"
```

- [ ] **Step 4: Rewrite the module docstring tier model**

Replace the `Tiers:` block (lines 7–11) with:

```python
Tiers (the Expert tab was retired; danger fields are no longer hidden):
    safe    - edit freely on the entity tab.
    caution - editable inline, but validated/warned; controls pre-filtered to valid values.
    danger  - editable inline as well, shown with a prominent warning badge because the
              value is high-risk (can crash or corrupt). No longer gated/hidden.
```

- [ ] **Step 5: Replace `_enemy_fields()` with all 10 bytes**

Replace the entire `_enemy_fields()` function (lines 146–175) with:

```python
def _enemy_fields() -> Dict[str, Dict[str, Any]]:
    """Field metadata for the 10-byte turn-based enemy record (ROM 0xC351).

    Byte semantics are from the GameAnalysis2 TMOS disassembly (authoritative).
    All 10 bytes are editable; the obscure RNG/probability bytes and the unknown
    byte 9 use the `caution` tier (editable but warned), not `danger`.
    """
    crash = "Enemy IDs 0x0B and 0x0C hard-crash the game and are never selectable."
    prob = (" Probability classes are MEDIUM-confidence; extreme values can make "
            "battles unwinnable or trivial.")
    return {
        "ep": {
            "label": "EXP reward", "byte": 0, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Experience awarded when this enemy is defeated.",
            "warning": crash, "used_by": ["levelling"],
        },
        "rupia": {
            "label": "Rupia reward", "byte": 1, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Currency dropped when this enemy is defeated.",
            "warning": crash, "used_by": ["economy"],
        },
        "bribe": {
            "label": "Bribe price", "byte": 2, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Rupia required to bribe/negotiate past this enemy. "
                           "0 = refuses all bribes.",
            "warning": crash, "used_by": ["negotiation"],
        },
        "escape_trigger": {
            "label": "Escape/Trigger chance", "byte": 3, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Probability class gating escape / action triggers. "
                           "0xFF means it (near-)never triggers.",
            "warning": crash + prob, "used_by": ["battle RNG"],
        },
        "action_prob": {
            "label": "Special-action chance", "byte": 4, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Probability class gating this enemy's special actions.",
            "warning": crash + prob, "used_by": ["battle RNG"],
        },
        "lineup_min": {
            "label": "Lineup minimum", "byte": 5, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Lineup-minimum probability class. Vanilla constant 1 across the roster.",
            "warning": crash + " MEDIUM-confidence; vanilla never varies this (constant 1) — "
                       "effects of changing it are unverified.",
            "used_by": ["battle RNG"],
        },
        "action_prob2": {
            "label": "Special-action chance (2)", "byte": 6, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Second action-probability byte, paired with byte 4 in the RNG gate.",
            "warning": crash + prob, "used_by": ["battle RNG"],
        },
        "hp": {
            "label": "HP (hit points)", "byte": 7, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Hit points in turn-based battle.",
            "warning": crash, "used_by": ["combat"],
        },
        "atk": {
            "label": "Attack power", "byte": 8, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Attack value used for this enemy's special-action damage.",
            "warning": crash, "used_by": ["combat"],
        },
        "byte_9": {
            "label": "Unknown (byte 9)", "byte": 9, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Purpose not located in the disassembly. Vanilla constant 2 across the roster.",
            "warning": crash + " Effect unknown — editing may do nothing or destabilize battles.",
            "used_by": [],
        },
    }
```

- [ ] **Step 6: Enrich the thin worldscreen field descriptions**

In `_worldscreen_fields()`, make these four `description` (and `ambient_sound` `used_by`) replacements. Replace the `ambient_sound` entry (lines 40–45) with:

```python
        "ambient_sound": {
            "label": "Ambient Sound", "byte": 1, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Background ambient sound-effect ID looped on this screen "
                           "(wind, water, town bustle, etc.). Cosmetic — safe to change; "
                           "0 is silence.",
            "warning": "", "used_by": ["ambient audio"],
        },
```

Change `top_tiles`'s `description` (line 106) to:

```python
            "description": "Index of the TileSection drawn across the top half of the "
                           "screen. Best changed via the Edit-modal tile picker, which keeps "
                           "collision seams and biome/theme coherent — blind index entry can "
                           "mismatch the bottom half.",
```

Change `bottom_tiles`'s `description` (line 112) to:

```python
            "description": "Index of the TileSection drawn across the bottom half of the "
                           "screen. Best changed via the Edit-modal tile picker (collision/"
                           "theme-aware) rather than raw index entry.",
```

Change `worldscreen_color`'s `description` (line 118) to:

```python
            "description": "Background color-palette selector for the screen. Also editable "
                           "visually via Graphics → Cosmetic.",
```

Change `sprites_color`'s `description` (line 124) to:

```python
            "description": "Sprite color-palette selector (e.g. 0x12 ≈ town sprites). Also "
                           "editable visually via Graphics → Cosmetic.",
```

- [ ] **Step 7: Regenerate the JSON artifact**

Run (from `projects/TMOS_Randomizer_V2`): `python tools/generate_field_metadata.py`
Expected: `data/field_metadata.json` rewritten (now version `"2"` with 10 enemy fields).

- [ ] **Step 8: Run the tests to verify they pass**

Run: `pytest tests/test_core/test_field_metadata.py tests/test_core/test_field_metadata_artifact.py -v`
Expected: all PASS (new content tests green; the artifact sync test confirms JSON matches the builder).

- [ ] **Step 9: Commit**

```bash
git add projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/field_metadata.py projects/TMOS_Randomizer_V2/src/tmos_randomizer/data/field_metadata.json projects/TMOS_Randomizer_V2/tests/test_core/test_field_metadata.py
git commit -m "feat(metadata): document all 10 enemy bytes + enrich worldscreen fields"
```

---

### Task 2: Generalized enemy write path (backend)

One shared offset map drives read and write; the write path accepts all 10 byte fields by semantic name; the DTO and the three enemy endpoints follow.

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/enemy_stats.py` (whole module)
- Modify: `projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/server.py` (`EnemyStatUpdate` lines 251–255; `get_enemies` serialization lines 3060–3074; `patch_enemy_stat` lines 3112–3115)
- Test: `projects/TMOS_Randomizer_V2/tests/test_core/test_enemy_stats.py` (append)
- Test: `projects/TMOS_Randomizer_V2/tests/test_api/test_enemy_stats_endpoint.py` (new)

**Interfaces:**
- Consumes: nothing from Task 1 (independent — both edit the same backend area but different files).
- Produces: `enemy_stats.FIELD_OFFSETS: dict[str,int]`; `write_enemy_stat(rom: bytearray, enemy_id: int, **fields: int|None) -> EnemyStatDTO`; `EnemyStatDTO` with semantic keys (`ep, rupia, bribe, escape_trigger, action_prob, lineup_min, action_prob2, hp, atk, byte_9` + `enemy_id, enemy_id_hex, rom_offset`). `GET /api/rom/enemies` returns each enemy with those 10 keys flat (no `raw_bytes`); `PATCH /api/rom/enemy-stats/{id}` accepts any of the 10 optional keys. (Consumed by Task 3.)

- [ ] **Step 1: Write the failing unit tests**

Append to `projects/TMOS_Randomizer_V2/tests/test_core/test_enemy_stats.py`:

```python
def test_write_new_bytes_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    es.write_enemy_stat(rom, 0x0D, bribe=42, atk=21, byte_9=9)
    s = es.read_enemy_stat(bytes(rom), 0x0D)
    assert s["bribe"] == 42
    assert s["atk"] == 21
    assert s["byte_9"] == 9
    # Unrelated bytes preserved.
    assert s["ep"] == 7 and s["rupia"] == 5


def test_dto_has_semantic_keys(vanilla_rom):
    s = es.read_enemy_stat(vanilla_rom, 0x0D)
    for k in ("ep", "rupia", "bribe", "escape_trigger", "action_prob",
              "lineup_min", "action_prob2", "hp", "atk", "byte_9"):
        assert k in s
    assert "raw_byte_2" not in s


@pytest.mark.parametrize("field,bad", [("bribe", 256), ("atk", -1), ("byte_9", 300)])
def test_new_field_bounds(vanilla_rom, field, bad):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError):
        es.write_enemy_stat(rom, 0x0D, **{field: bad})


def test_unknown_field_rejected(vanilla_rom):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="unknown enemy stat field"):
        es.write_enemy_stat(rom, 0x0D, nonsense=1)
```

- [ ] **Step 2: Run the unit tests to verify they fail**

Run: `pytest tests/test_core/test_enemy_stats.py -v`
Expected: the 4 new tests FAIL (`write_enemy_stat` has no `bribe`/`atk`/`byte_9` kwargs; DTO lacks those keys).

- [ ] **Step 3: Rewrite `enemy_stats.py`**

Replace the module's docstring, the `EnemyStatDTO`, `_read`, and `write_enemy_stat` with the following (keep `ENEMY_STAT_TABLE`, `ENEMY_STAT_RECORD_SIZE`, `ENEMY_STAT_COUNT`, `ENEMY_ID_FIRST`, `ENEMY_ID_LAST`, `_slot_offset`, `_check_id`, `read_enemy_stat`, `read_all_enemy_stats` as they are):

Module docstring (lines 1–15) →

```python
"""Enemy stat table at file 0xC351 (Bank 3 $8341).

29 entries x 10 bytes, IDs 0x0D..0x29. Byte semantics from the GameAnalysis2
TMOS disassembly (authoritative):
  byte 0 = ep (EXP reward)        byte 5 = lineup_min (probability class)
  byte 1 = rupia (Rupia reward)   byte 6 = action_prob2 (action probability)
  byte 2 = bribe (bribe price)    byte 7 = hp
  byte 3 = escape_trigger (prob)  byte 8 = atk (special-action attack)
  byte 4 = action_prob (prob)     byte 9 = unknown (vanilla constant 2)

All 10 bytes are read and writable by semantic name via FIELD_OFFSETS.
"""
```

`EnemyStatDTO` (replace lines 28–41) →

```python
class EnemyStatDTO(TypedDict):
    enemy_id: int
    enemy_id_hex: str
    rom_offset: str
    ep: int
    rupia: int
    bribe: int
    escape_trigger: int
    action_prob: int
    lineup_min: int
    action_prob2: int
    hp: int
    atk: int
    byte_9: int


FIELD_OFFSETS: dict[str, int] = {
    "ep": 0, "rupia": 1, "bribe": 2, "escape_trigger": 3, "action_prob": 4,
    "lineup_min": 5, "action_prob2": 6, "hp": 7, "atk": 8, "byte_9": 9,
}
```

`_read` (replace lines 56–73) →

```python
def _read(rom: bytes, enemy_id: int) -> EnemyStatDTO:
    _check_id(enemy_id)
    off = _slot_offset(enemy_id)
    dto: dict = {
        "enemy_id": enemy_id,
        "enemy_id_hex": f"0x{enemy_id:02X}",
        "rom_offset": f"0x{off:05X}",
    }
    for key, delta in FIELD_OFFSETS.items():
        dto[key] = rom[off + delta]
    return dto  # type: ignore[return-value]
```

`write_enemy_stat` (replace lines 84–107) →

```python
def write_enemy_stat(
    rom: bytearray, enemy_id: int, **fields: Optional[int]
) -> EnemyStatDTO:
    """Mutate any of the 10 enemy record bytes by semantic name.

    Only the provided (non-None) fields are written; the rest are untouched.
    """
    _check_id(enemy_id)
    off = _slot_offset(enemy_id)
    for key, value in fields.items():
        if key not in FIELD_OFFSETS:
            raise ValueError(f"unknown enemy stat field: {key!r}")
        if value is None:
            continue
        if not 0 <= value <= 255:
            raise ValueError(f"{key} must be 0..255, got {value}")
        rom[off + FIELD_OFFSETS[key]] = value
    return _read(bytes(rom), enemy_id)
```

- [ ] **Step 4: Run the unit tests to verify they pass**

Run: `pytest tests/test_core/test_enemy_stats.py -v`
Expected: all PASS (existing hp/ep/rupia keyword-arg tests still pass — `**fields` accepts them; new tests pass).

- [ ] **Step 5: Widen the pydantic model + endpoints in `server.py`**

Replace `EnemyStatUpdate` (lines 251–255) with:

```python
class EnemyStatUpdate(BaseModel):
    """Partial update to one enemy's stats (any of the 10 record bytes)."""
    ep: Optional[int] = None
    rupia: Optional[int] = None
    bribe: Optional[int] = None
    escape_trigger: Optional[int] = None
    action_prob: Optional[int] = None
    lineup_min: Optional[int] = None
    action_prob2: Optional[int] = None
    hp: Optional[int] = None
    atk: Optional[int] = None
    byte_9: Optional[int] = None
```

In `get_enemies`, replace the per-enemy dict body (lines 3060–3074, the `enriched.append({...})` block) with:

```python
        enriched.append({
            **meta,
            "enemy_id": eid,
            "enemy_id_hex": s["enemy_id_hex"],
            "rom_offset": s["rom_offset"],
            "ep": s["ep"], "rupia": s["rupia"], "bribe": s["bribe"],
            "escape_trigger": s["escape_trigger"], "action_prob": s["action_prob"],
            "lineup_min": s["lineup_min"], "action_prob2": s["action_prob2"],
            "hp": s["hp"], "atk": s["atk"], "byte_9": s["byte_9"],
        })
```

In `patch_enemy_stat`, replace the `write_enemy_stat(...)` call (lines 3112–3115) with:

```python
        result = _enemy_stats.write_enemy_stat(
            rom_array, enemy_id, **update.model_dump(exclude_none=True)
        )
```

- [ ] **Step 6: Write the endpoint test**

Create `projects/TMOS_Randomizer_V2/tests/test_api/test_enemy_stats_endpoint.py`:

```python
"""Endpoint tests for the generalized enemy-stats read/write path."""
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


def test_enemies_expose_semantic_bytes(client):
    body = client.get("/api/rom/enemies").json()
    e = next(x for x in body["enemies"] if x["enemy_id"] == 0x0D)
    for k in ("bribe", "escape_trigger", "action_prob", "lineup_min",
              "action_prob2", "atk", "byte_9"):
        assert k in e
    assert "raw_bytes" not in e


def test_patch_new_byte_persists(client):
    r = client.patch("/api/rom/enemy-stats/13", json={"bribe": 77})  # 13 = 0x0D
    assert r.status_code == 200
    assert r.json()["stat"]["bribe"] == 77


def test_patch_out_of_range_rejected(client):
    r = client.patch("/api/rom/enemy-stats/13", json={"hp": 256})
    assert r.status_code == 400
```

- [ ] **Step 7: Run the endpoint + full enemy tests**

Run: `pytest tests/test_api/test_enemy_stats_endpoint.py tests/test_core/test_enemy_stats.py tests/test_api/test_metadata_endpoint.py -v`
Expected: all PASS (or skip if the default ROM is unavailable, for the ROM-dependent ones).

- [ ] **Step 8: Commit**

```bash
git add projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/enemy_stats.py projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/server.py projects/TMOS_Randomizer_V2/tests/test_core/test_enemy_stats.py projects/TMOS_Randomizer_V2/tests/test_api/test_enemy_stats_endpoint.py
git commit -m "feat(enemies): generalize enemy write path to all 10 bytes (semantic keys)"
```

---

### Task 3: Frontend client types + store generalization

Widen the client types to the semantic 10-byte shape and make the store's optimistic write generic.

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/api/client.ts` (`BattleEnemy` lines 382–395; `EnemyStat` lines 397–406; `EnemyStatPatch` lines 408–412)
- Modify: `projects/TMOS_Randomizer_V2/ui/src/store/index.ts` (`updateEnemyStat` lines 1369–1408)

**Interfaces:**
- Consumes: Task 2's endpoint shapes (enemies expose the 10 semantic keys; patch accepts them).
- Produces: `EnemyStatPatch` with 10 optional keys; `BattleEnemy`/`EnemyStat` carrying the semantic keys (no `raw_bytes`). (Consumed by Task 4.)

- [ ] **Step 1: Widen `EnemyStatPatch`**

In `client.ts`, replace `EnemyStatPatch` (lines 408–412) with:

```ts
export interface EnemyStatPatch {
  ep?: number;
  rupia?: number;
  bribe?: number;
  escape_trigger?: number;
  action_prob?: number;
  lineup_min?: number;
  action_prob2?: number;
  hp?: number;
  atk?: number;
  byte_9?: number;
}
```

- [ ] **Step 2: Replace `BattleEnemy.raw_bytes` with flat semantic keys**

In `client.ts`, replace `BattleEnemy` (lines 382–395) with:

```ts
export interface BattleEnemy {
  enemy_id: number;
  enemy_id_hex: string;
  name: string;
  hp: number | null;          // live ROM read from $8341 byte 7
  ep?: number;                // byte 0
  rupia?: number;             // byte 1
  bribe?: number;             // byte 2
  escape_trigger?: number;    // byte 3
  action_prob?: number;       // byte 4
  lineup_min?: number;        // byte 5
  action_prob2?: number;      // byte 6
  atk?: number;               // byte 8
  byte_9?: number;            // byte 9
  rom_offset?: string;
  image: string | null;
  notes: string;
  confidence: 'high' | 'medium' | 'low';
  chapter_first_seen: number | null;
}
```

- [ ] **Step 3: Replace `EnemyStat` with semantic keys**

In `client.ts`, replace `EnemyStat` (lines 397–406) with:

```ts
export interface EnemyStat {
  enemy_id: number;
  enemy_id_hex: string;
  rom_offset: string;
  ep: number;
  rupia: number;
  bribe: number;
  escape_trigger: number;
  action_prob: number;
  lineup_min: number;
  action_prob2: number;
  hp: number;
  atk: number;
  byte_9: number;
}
```

- [ ] **Step 4: Make the store's optimistic write generic**

In `store/index.ts`, replace `updateEnemyStat` (lines 1369–1408) with:

```ts
  updateEnemyStat: async (enemyId, patch) => {
    const state = get();
    if (!state.battleEnemies) return;
    const prev = state.battleEnemies;
    // Optimistic merge: patch keys are a subset of BattleEnemy's byte keys.
    const optimistic = prev.map((e) =>
      e.enemy_id === enemyId ? { ...e, ...patch } : e
    );
    set({ battleEnemies: optimistic, enemiesError: null });
    try {
      const resp = await api.patchEnemyStat(enemyId, patch);
      const stat = resp.stat;
      // Reconcile every byte from the server-confirmed record.
      const confirmed = optimistic.map((e) =>
        e.enemy_id === enemyId
          ? {
              ...e,
              ep: stat.ep, rupia: stat.rupia, bribe: stat.bribe,
              escape_trigger: stat.escape_trigger, action_prob: stat.action_prob,
              lineup_min: stat.lineup_min, action_prob2: stat.action_prob2,
              hp: stat.hp, atk: stat.atk, byte_9: stat.byte_9,
            }
          : e
      );
      set({ battleEnemies: confirmed });
      get().pushEditLog({
        ts: Date.now(),
        field: `Enemy 0x${enemyId.toString(16).toUpperCase().padStart(2, '0')} stats`,
        rom_offset: resp.stat.rom_offset,
        before: 0, after: 0,
        cascade: JSON.stringify(patch),
      });
    } catch (error) {
      set({
        battleEnemies: prev,
        enemiesError: error instanceof Error ? error.message : 'Enemy stat update failed',
      });
      throw error;
    }
  },
```

- [ ] **Step 5: Typecheck + scoped lint + test**

Run (from `<worktree>/projects/TMOS_Randomizer_V2/ui`):

```bash
npm run build
npx eslint src/api/client.ts src/store/index.ts
npm test
```

Expected: `npm run build` exit 0; scoped eslint 0 errors on the two files; Vitest suites all green (including `src/store/index.test.ts`). Do NOT run whole-tree `npm run lint`. (`BattleRosterEditor` still compiles: it reads `enemy.hp/ep/rupia`, which remain on `BattleEnemy`, and its narrow `onPatch` type is a subset of the widened `EnemyStatPatch`.)

- [ ] **Step 6: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/api/client.ts projects/TMOS_Randomizer_V2/ui/src/store/index.ts
git commit -m "feat(ui): widen enemy stat client types + generic optimistic update"
```

---

### Task 4: Data-driven roster editor + valid_range UX

Render the roster editor's fields from metadata (3 → 10, byte order) and show `valid_range` in the shared guided-field info box.

**Files:**
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/shared/GuidedField.tsx` (info box, lines 45–57)
- Modify: `projects/TMOS_Randomizer_V2/ui/src/components/enemies/BattleRosterEditor.tsx` (`StatKey`/`STAT_KEYS` lines 9–10; `fallbackMeta` lines 12–20; `EnemyPanelProps` + `EnemyPanel` lines 154–277)

**Interfaces:**
- Consumes: Task 1's 10-field enemy metadata; Task 3's `BattleEnemy`/`EnemyStat`/`EnemyStatPatch` semantic shapes.
- Produces: (terminal — no later task consumes this.)

- [ ] **Step 1: Render `valid_range` in `GuidedField`**

In `GuidedField.tsx`, inside the `showInfo` block, add a range line right after the description `<div>` (between lines 47 and 48):

```tsx
          <div>{meta.description}</div>
          {meta.valid_range && (
            <div className="mt-1 text-slate-500">
              Range: {meta.valid_range[0]}–{meta.valid_range[1]}
            </div>
          )}
          {meta.warning && (
            <div className="mt-1 text-amber-400"><span aria-hidden>{'⚠'}</span> {meta.warning}</div>
          )}
```

(The `meta.warning` block is shown for context — keep the existing `used_by` block below it unchanged.)

- [ ] **Step 2: Make `BattleRosterEditor` field list + types generic**

In `BattleRosterEditor.tsx`:

(a) Update the imports (lines 3, 6) to add the two new client types:

```tsx
import type { BattleEnemy, EnemyStat, EnemyStatPatch } from '../../api/client';
```

(b) Delete the `StatKey` type alias and `STAT_KEYS` const (lines 9–10), and replace `fallbackMeta` (lines 12–20) with a string-keyed version:

```tsx
/** Fallback metadata if the backend hasn't populated entities.enemy.fields.* */
function fallbackMeta(key: string): FieldMetadata {
  return {
    label: key.toUpperCase(),
    byte: 0,
    tier: 'caution',
    description: `Turn-based enemy ${key} byte (live ROM value).`,
    valid_range: [0, 255],
  };
}
```

- [ ] **Step 3: Rewrite `EnemyPanelProps` + `EnemyPanel` to be metadata-driven**

Replace `EnemyPanelProps` (lines 154–161) and the `EnemyPanel` function (lines 163–277) with:

```tsx
interface EnemyPanelProps {
  enemy: BattleEnemy;
  vanilla?: EnemyStat;
  fieldMetadata: ReturnType<typeof useRandomizerStore.getState>['fieldMetadata'];
  isDanger: boolean;
  appearsIn: { chapter: number; lineupIndex: number; slot: number }[];
  onPatch: (patch: EnemyStatPatch) => Promise<void>;
}

function EnemyPanel({ enemy, vanilla, fieldMetadata, isDanger, appearsIn, onPatch }: EnemyPanelProps) {
  const imgUrl = enemy.image ? `/assets/enemies/${enemy.image}` : null;

  const enemyFields = fieldMetadata?.entities?.enemy?.fields;
  // Render fields in ROM byte order, driven entirely by metadata.
  const orderedKeys = useMemo(
    () =>
      enemyFields
        ? Object.keys(enemyFields).sort((a, b) => enemyFields[a].byte - enemyFields[b].byte)
        : [],
    [enemyFields]
  );
  const liveValue = (key: string): number =>
    ((enemy as Record<string, unknown>)[key] as number | null | undefined) ?? 0;
  const vanillaValue = (key: string): number | undefined =>
    vanilla ? (vanilla as unknown as Record<string, number>)[key] : undefined;

  return (
    <div className="space-y-4">
      {/* Identity */}
      <div className="flex items-start gap-3">
        <div className="w-20 h-20 flex-shrink-0 flex items-center justify-center bg-slate-900 rounded overflow-hidden border border-slate-700">
          {imgUrl ? (
            <img
              src={imgUrl}
              alt={enemy.name}
              className="max-w-full max-h-full object-contain"
              style={{ imageRendering: 'pixelated' }}
              onError={(e) => {
                (e.target as HTMLImageElement).style.display = 'none';
              }}
            />
          ) : (
            <span className="text-slate-600 text-xs">?</span>
          )}
        </div>
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <h3 className="text-base font-semibold text-slate-100 truncate">{enemy.name}</h3>
            {isDanger && <SafetyBadge tier="danger" />}
          </div>
          <div className="text-xs font-mono text-slate-500 mt-0.5">
            {enemy.enemy_id_hex}
            {enemy.rom_offset && <span> · ROM ${enemy.rom_offset}</span>}
          </div>
          <div className="text-xs text-slate-500 mt-0.5">
            confidence: <span className="text-slate-300">{enemy.confidence}</span>
            {enemy.chapter_first_seen !== null && (
              <span> · first seen Ch {enemy.chapter_first_seen}</span>
            )}
          </div>
          {enemy.notes && (
            <div className="text-xs text-slate-400 mt-1 leading-snug">{enemy.notes}</div>
          )}
        </div>
      </div>

      {/* Editable stats — or read-only warning for danger IDs */}
      <div className="border-t border-slate-800 pt-3">
        {isDanger ? (
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-xs text-red-400">
              <SafetyBadge tier="danger" />
              <span>
                This enemy ID is on the crash/danger list and cannot be edited safely.
                Stats are shown read-only.
              </span>
            </div>
            <div className="grid grid-cols-2 gap-2 text-xs">
              {orderedKeys.map((key) => (
                <div key={key} className="bg-slate-900/60 rounded px-2 py-1.5 border border-slate-700">
                  <div className="text-slate-500 uppercase text-[10px]">
                    {enemyFields?.[key]?.label ?? key}
                  </div>
                  <div className="font-mono text-slate-300">{liveValue(key)}</div>
                  {vanillaValue(key) !== undefined && (
                    <div className="text-[10px] text-slate-600">vanilla {vanillaValue(key)}</div>
                  )}
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-4">
            {orderedKeys.map((key) => {
              const meta = enemyFields?.[key] ?? fallbackMeta(key);
              return (
                <GuidedNumberField
                  key={key}
                  meta={meta}
                  value={liveValue(key)}
                  vanilla={vanillaValue(key)}
                  onChange={(v) => {
                    if (v !== liveValue(key)) {
                      // Optimistic update + patch + reconcile + rollback live in the
                      // store's updateEnemyStat action (mirrors the World-tab pattern).
                      void onPatch({ [key]: v });
                    }
                  }}
                />
              );
            })}
          </div>
        )}
      </div>

      {/* APPEARS IN — only when lineups are loaded and there are references */}
      {appearsIn.length > 0 && (
        <div className="border-t border-slate-800 pt-3">
          <div className="text-xs font-semibold text-slate-300 mb-1">Appears in</div>
          <ul className="flex flex-wrap gap-1.5">
            {appearsIn.map((r, i) => (
              <li
                key={`${r.chapter}-${r.lineupIndex}-${r.slot}-${i}`}
                className="text-[11px] font-mono bg-slate-800 text-slate-300 rounded px-1.5 py-0.5"
              >
                Ch{r.chapter} · L{r.lineupIndex} · slot {r.slot}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
```

- [ ] **Step 4: Typecheck + scoped lint + test**

Run (from `<worktree>/projects/TMOS_Randomizer_V2/ui`):

```bash
npm run build
npx eslint src/components/shared/GuidedField.tsx src/components/enemies/BattleRosterEditor.tsx
npm test
```

Expected: `npm run build` exit 0; scoped eslint 0 errors on the two files; Vitest green. Do NOT run whole-tree `npm run lint`.

- [ ] **Step 5: Manual check**

`npm run dev`, load a ROM, open Enemies → Roster. Expected: each editable enemy shows **10** number fields in byte order (EXP / Rupia / Bribe / Escape-Trigger / Special-action / Lineup-min / Special-action 2 / HP / Attack / Unknown) in a 2-column grid; safe vs. caution badges render per field; the ⓘ box shows `Range: 0–255`; editing **Bribe** or **Attack** persists and survives a reload; a crash enemy (e.g. 0x0B/0x0C if listed, or any `DANGER_ENEMY_IDS` member) shows all 10 read-only. Open the World Edit modal on any screen and confirm a thin field (e.g. Sprite Palette) now shows its enriched description + `Range: 0–255` in the ⓘ box.

- [ ] **Step 6: Commit**

```bash
git add projects/TMOS_Randomizer_V2/ui/src/components/shared/GuidedField.tsx projects/TMOS_Randomizer_V2/ui/src/components/enemies/BattleRosterEditor.tsx
git commit -m "feat(ui): data-driven 10-byte roster editor + valid_range in guided fields"
```

---

## Self-Review

**Spec coverage:**
- §1 metadata content (10 enemy bytes + worldscreen enrichment + version bump) → Task 1. ✔
- §2 generalized write path (FIELD_OFFSETS, `write_enemy_stat(**fields)`, semantic DTO, endpoint + pydantic widen) → Task 2. ✔
- §3 data-driven editor + `valid_range` → Task 4; the client/store type widening it depends on → Task 3. ✔
- §4 stale cleanup: `field_metadata.py` tier docstring → Task 1 Step 4; `enemy_stats.py` record docstring → Task 2 Step 3; `ExpertDisclosure` kept (no task, by design); provenance comments left (no task). ✔
- Testing (backend unit + endpoint + artifact sync; frontend build/scoped-lint/manual) → present in every task. ✔

**Placeholder scan:** No TBD/TODO/"handle edge cases"/"similar to Task N". Every code step has complete code. ✔

**Type consistency:** The 10 field keys (`ep, rupia, bribe, escape_trigger, action_prob, lineup_min, action_prob2, hp, atk, byte_9`) and offsets are identical across `FIELD_OFFSETS` (Task 2), `EnemyStatDTO` (Task 2), `EnemyStatUpdate` (Task 2), `EnemyStatPatch`/`EnemyStat`/`BattleEnemy` (Task 3), the store reconcile (Task 3), and the metadata keys (Task 1, consumed by Task 4's `orderedKeys`). `valid_range` is already typed on `FieldMetadata` (no Task touches `metadata.ts`), rendered in Task 4. `write_enemy_stat`'s `**fields` keeps the existing `hp=/ep=/rupia=` test call sites valid. ✔
