# Richer Field Descriptions & Editor Guidance — Design

**Date:** 2026-06-25
**Status:** Approved (design); ready for implementation plan
**Area:** `projects/TMOS_Randomizer_V2` (Python backend `core`/`api` + React/TS frontend `ui`)
**Scope:** Sub-project #2 of the batch from "add more information and improve the editor for things that have very little descriptions; make allies editable." This spec covers **descriptions + editor guidance** only. Making allies editable is sub-project #3 (separate spec).

## Problem

Field-level guidance is uneven. The advanced panels (Magic, Encounter Rates, TB Formulas, …) are already well-documented, but two surfaces are thin:

1. **Battle-enemy records.** Each turn-based enemy is a 10-byte record (`core/enemy_stats.py`, ROM `0xC351`). Only **3** bytes are described and editable today (EP, Rupia, HP); the other 7 are exposed as opaque `raw_byte_N` values with no meaning. The authoritative GameAnalysis2 disassembly actually documents most of them (byte 2 = bribe price, byte 8 = ATK, bytes 3–6 = RNG/probability classes, byte 9 = an unknown constant).
2. **Sparse "safe" worldscreen fields.** `ambient_sound`, `top_tiles`/`bottom_tiles`, and the two palette bytes have one-line descriptions, empty `warning`, and empty/short `used_by`.

Separately, the metadata's tier-model documentation is **stale** after the just-completed Expert-tab dissolution: `core/field_metadata.py`'s docstring still says danger fields are "only in the gated Expert tab," and `enemy_stats.py`'s docstring still calls bytes 2–6/8–9 undocumented and the non-HP/EP/Rupia bytes read-only.

## Goal

Make `core/field_metadata.py` the single source of guidance for **all 10 enemy bytes** (documented, with tiers and ranges) and for the enriched worldscreen fields; make the enemy roster editor render **all 10 bytes editable** and **data-driven from that metadata**; surface `valid_range` in the shared guided-field info box (lifting guidance app-wide); and correct the stale Expert-era docstrings.

## Non-Goals

- **No allies editing** — that's sub-project #3.
- **No advanced-panel redesign.** The `ExpertDisclosure` in-panel collapsibles stay (they are progressive disclosure for raw byte tables, not the removed tab-level gate). Only stale *wording* is corrected.
- **No new cross-link widgets.** Palette/tile cross-references are richer description *text*; the clickable palette→Graphics→Cosmetic jump already exists via the Spec-#5 screen link.
- **No new ROM reverse-engineering.** Byte semantics come from the existing GameAnalysis2 knowledge base; byte 9 stays documented-as-unknown.

## Authoritative enemy record (GameAnalysis2 disassembly)

10 bytes/record, 29 records, IDs `0x0D..0x29`, base ROM `0xC351`, stride 10. This supersedes `enemy_stats.py`'s vaguer in-repo docstring (per the project's "GameAnalysis2 is authoritative" rule).

| Byte | key | Label | Tier | Description | Conf. |
|---|---|---|---|---|---|
| 0 | `ep` | EXP reward | safe | Experience awarded when defeated. | HIGH |
| 1 | `rupia` | Rupia reward | safe | Currency dropped when defeated. | HIGH |
| 2 | `bribe` | Bribe price | safe | Rupia needed to bribe/negotiate past this enemy; **0 = refuses bribes**. | HIGH |
| 3 | `escape_trigger` | Escape/Trigger chance | caution | Probability class gating escape / action triggers; **0xFF ≈ never triggers**. | MEDIUM |
| 4 | `action_prob` | Special-action chance | caution | Probability class gating the enemy's special actions. | MEDIUM |
| 5 | `lineup_min` | Lineup minimum | caution | Lineup-minimum probability class; **vanilla constant 1**. | MEDIUM |
| 6 | `action_prob2` | Special-action chance (2) | caution | Second action-probability byte, paired with byte 4 in the RNG gate. | MEDIUM |
| 7 | `hp` | HP | safe | Hit points in turn-based battle. | HIGH |
| 8 | `atk` | Attack power | safe | Attack value used for the enemy's special-action damage. | HIGH |
| 9 | `byte_9` | Unknown (byte 9) | caution | Purpose not located in the disassembly; **vanilla constant 2** — editing may have no effect or destabilize battles. | LOW |

All 10 keep the existing crash-ID warning (enemy IDs `0x0B`/`0x0C` hard-crash and are never selectable) and `valid_range: [0, 255]`. The `danger` tier is intentionally not used for enemy fields — with the Expert gate gone, the obscure bytes use `caution` (editable + warned) so they remain visible and editable per the "all 10 editable" decision.

## Architecture

Source of truth = `core/field_metadata.py`. Content is added there, regenerated into the JSON artifact, served live; the editor and write-path are small surgical changes around it.

### 1. Metadata content (`core/field_metadata.py`)

- Replace `_enemy_fields()` (3 fields) with the 10 fields above — each with `label`, `byte` (= record offset), `tier`, `control: "number"`, `valid_range: [0,255]`, `description`, `warning` (the crash-ID note; plus the specific cautions for bytes 3–6/9), `used_by`.
- Enrich the thin worldscreen fields in `_worldscreen_fields()`:
  - `ambient_sound` — second sentence on what the SFX ID controls + that it is cosmetic/safe; keep `used_by: []`.
  - `top_tiles` / `bottom_tiles` — note these are best changed via the Edit-modal tile picker (collision/theme-aware, Specs #2/#3) rather than blind byte entry; `used_by: ["tile rendering"]`.
  - `worldscreen_color` / `sprites_color` — what palette index ranges mean (e.g. `0x12` ≈ town) and that the palette is also reachable via Graphics → Cosmetic; `used_by: ["palette"]`.
- Bump `METADATA_VERSION` `"1" → "2"`. Regenerate `data/field_metadata.json` via `python tools/generate_field_metadata.py` so `tests/test_core/test_field_metadata_artifact.py` (asserts JSON == builder output) stays green.

### 2. Generalized enemy write path

The read side already returns all 10 bytes; the write side is generalized so read/write share one offset map.

- **`core/enemy_stats.py`:** add `FIELD_OFFSETS = {"ep":0,"rupia":1,"bribe":2,"escape_trigger":3,"action_prob":4,"lineup_min":5,"action_prob2":6,"hp":7,"atk":8,"byte_9":9}`. `_read` and `write_enemy_stat` both derive offsets from it (removing the per-byte boilerplate). `write_enemy_stat` accepts an optional value per field key, validates each `0..255`, writes only provided keys. `EnemyStatDTO` exposes all 10 by **semantic name** — the `raw_byte_2..9` keys are renamed to `bribe / escape_trigger / action_prob / lineup_min / action_prob2 / atk / byte_9`; `ep`/`rupia`/`hp` keys are unchanged. The module + record-layout docstring is corrected to GameAnalysis2 semantics (also satisfies §4).
- **`api/server.py`:** `PATCH /api/rom/enemy-stats/{id}` forwards the widened patch (all 10 optional keys) to `write_enemy_stat`. No route change; only the accepted body widens.
- **Client (`ui/src/api/client.ts`):** `EnemyStatPatch` gains the 7 new optional keys; `BattleEnemy` and `EnemyStat` replace the `raw_bytes`/`raw_byte_N` shape with the 10 named keys, so every byte is addressable by the same key the metadata uses.
- **Store (`ui/src/store/index.ts`):** `updateEnemyStat(enemyId, patch)` already does optimistic write + rollback; it writes the patched key(s) into `battleEnemies` generically (no per-field special-casing). The `EnemyStatPatch` type widens.

### 3. Data-driven editor + `valid_range` UX

- **`ui/src/components/enemies/BattleRosterEditor.tsx`:** drop the hardcoded `STAT_KEYS = ['hp','ep','rupia']`. Derive the field list from the `enemy` metadata (the 10 keys in byte order) and render one `GuidedNumberField` per field, reading each value from the enemy DTO by key and committing `updateEnemyStat(id, { [key]: next })`. The 10 inputs lay out in a responsive byte-order grid (e.g. 2-up). The existing crash-ID path (`DANGER_ENEMY_IDS` → read-only) still applies, now across all 10 fields. Per-field tier (safe/caution) + warnings are already rendered by `GuidedField`'s `SafetyBadge`, so the obscure bytes self-flag.
- **`ui/src/types/metadata.ts`:** add `valid_range?: [number, number]` to `FieldMetadata` (currently untyped).
- **`ui/src/components/shared/GuidedField.tsx`:** in the ⓘ info box, render one line for `valid_range` when present (`Range: <min>–<max>`). Because every guided field uses this one component, the range hint appears on worldscreen and enemy fields alike from a single edit.

### 4. Stale Expert-era cleanup (wording only)

- **`core/field_metadata.py` module docstring:** rewrite the tier model — **safe** = edit freely; **caution** = editable, validated/warned; **danger** = editable but high-risk, shown inline with a prominent warning (no longer "only in the gated Expert tab," which no longer exists).
- **`core/enemy_stats.py` docstring:** corrected as part of §2 (GameAnalysis2 semantics; drop the "only hp/ep/rupia editable, other 7 read-only" line).
- **`ExpertDisclosure` (`ui/src/components/advanced/panelHelpers.tsx`) — kept.** It is in-panel progressive disclosure for raw byte tables, distinct from the removed tab gate; its summary text references "expert values," not an "Expert tab," so nothing there is literally stale. No change.
- **View-wrapper provenance comments** ("re-homed from the retired Expert tab") are left as-is — they accurately describe history.

## Files Touched

- `src/tmos_randomizer/core/field_metadata.py` — 10 enemy fields; worldscreen enrichment; version bump; tier-model docstring.
- `src/tmos_randomizer/core/enemy_stats.py` — `FIELD_OFFSETS`; generalized `write_enemy_stat`; semantic `EnemyStatDTO`; corrected docstring.
- `src/tmos_randomizer/api/server.py` — widen the `enemy-stats` PATCH body handling.
- `src/tmos_randomizer/data/field_metadata.json` — regenerated artifact.
- `ui/src/api/client.ts` — `EnemyStatPatch`, `BattleEnemy`, `EnemyStat` shapes.
- `ui/src/store/index.ts` — `EnemyStatPatch` widening; generic optimistic write.
- `ui/src/types/metadata.ts` — `valid_range` on `FieldMetadata`.
- `ui/src/components/shared/GuidedField.tsx` — render `valid_range`.
- `ui/src/components/enemies/BattleRosterEditor.tsx` — data-driven 10-field editor.
- `tests/test_core/test_enemy_stats.py` — write/read round-trip for new bytes; range rejection; untouched-field guarantee; endpoint persists a new key.
- `tests/test_core/test_field_metadata.py` — enemy entity has 10 fields, each with valid tier + `valid_range`.

## Testing

- **Backend (pytest, `PYTHONPATH=src`):**
  - `test_enemy_stats.py`: `write_enemy_stat` round-trips `bribe`, `atk`, `byte_9` (write → read back equal); `256` raises `ValueError`; writing one field leaves the others unchanged (read full record before/after). TestClient: `PATCH /api/rom/enemy-stats/{id}` with `{"bribe": N}` returns 200 and the echoed DTO shows `bribe == N`; no-ROM → the existing error path.
  - `test_field_metadata.py`: `build_field_metadata()["entities"]["enemy"]["fields"]` has all 10 keys; every field has a tier in `{safe,caution,danger}` and a `valid_range` of `[0,255]`; `version == "2"`.
  - `test_field_metadata_artifact.py` (existing) guarantees the regenerated JSON matches the builder.
- **Frontend:** the `.tsx`/type changes (editor, `GuidedField`, `client.ts`, store, `metadata.ts`) are verified by `npm run build` (tsc) + **scoped** `eslint` on changed files + manual checks (repo convention; the repo baseline carries 32 pre-existing whole-tree lint errors unrelated to this work, so the gate is build-clean + scoped-lint-clean, never whole-tree `npm run lint`). Existing Vitest suites must stay green.
- **Manual:** Enemies → Roster shows 10 editable fields per enemy in byte order, each with a tier badge; editing `bribe`/`atk` persists and round-trips; the ⓘ box shows `Range: 0–255`; crash enemies (0x0B/0x0C) remain read-only; a thin worldscreen field (e.g. `sprites_color`) now shows its enriched description + range in the Edit modal.

## Risks / Open Notes

- **DTO rename ripple.** Replacing `raw_byte_N` with semantic keys touches every `BattleEnemy`/`EnemyStat` consumer. `ep`/`rupia`/`hp` keys are preserved (e.g. `LineupEditor` total-HP), so only the `raw_bytes` readers change; the implementation plan must enumerate them and `tsc` will surface any missed reference.
- **Byte 2/8 source conflict.** `enemy_stats.py`'s current docstring lumps bytes 2–6 as undocumented and 8–9 as unknown, conflicting with GameAnalysis2 (byte 2 = bribe, byte 8 = ATK). The design trusts GameAnalysis2 (authoritative) and corrects the docstring. If a future test ever pins the old labels, it must be updated alongside.
- **`caution`-tier rendering.** Enemy fields previously only used `safe`; introducing `caution` enemy fields assumes `GuidedField`/`SafetyBadge` render the `caution` tier correctly (they already do for worldscreen caution fields). The plan verifies this in the manual check.
- **Editing obscure bytes can hurt seeds.** Bytes 3–6/9 are MEDIUM/LOW confidence; their warnings make the risk explicit, consistent with the project goal (most seeds playable, user review acceptable) rather than a hard gate.
