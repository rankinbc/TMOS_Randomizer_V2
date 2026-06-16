# Phase 3 — Enemies Tab (Entity-Centric) + Gated Expert Tab — Design

**Date:** 2026-06-16
**Project:** TMOS Randomizer V2 (`projects/TMOS_Randomizer_V2`)
**Status:** Approved design — ready for implementation planning
**Parent spec:** `docs/superpowers/specs/2026-06-15-entity-centric-ui-reorg-design.md` (§1, §3, §7 phase 3)

## Goal

Make the Enemies tab the entity-centric home for **safe** enemy/boss/encounter editing, and stand up the Expert tab as a **gated** home for danger-tier byte-level controls. No redundancy: each panel lives in exactly one tab.

## Context (current state, already scaffolded)

- `TabType` already includes all 8 tabs; `MainContent.tsx` renders `<EnemiesView/>` (enemies) and `<ExpertView/>`→`<AdvancedView/>` (expert).
- `EnemiesView.tsx` already renders Battle Roster + Encounter Lineups + Encounter Groups — but **roster stats are display-only** even though `PATCH /api/rom/enemy-stats/{id}` exists.
- `AdvancedView.tsx` has 11 sub-tabs incl. `BossesPanel`, `OverworldPanel`, `TbFormulasPanel`, `EncounterRatesPanel`, `WeaponDamagePanel` — all already built with `PanelFrame`/`ExpertDisclosure`/`useRomResource`.
- Phase-1 reusables exist: `SafetyBadge`, `GuidedField`, `GuidedNumberField`, `safety.ts`, `metadata.ts`, `field_metadata.py` + `GET /api/metadata/fields` (worldscreen only today).
- `core/enums.py` already defines `CRASH_ENEMY_IDS = {0x0B, 0x0C}` and `CONSERVATIVE_DANGER_ENEMY_IDS = CRASH_ENEMY_IDS | {0x0F, 0x17, 0x25}`.

So Phase 3 is **consolidation + making safe things editable + gating danger**, not greenfield construction.

## 1. Enemies tab — safe, entity-centric editing

Reworked into four labeled sections via a segmented control. All editable fields use the Phase-1 guided-field + safety-badge + vanilla-diff components.

### A · Battle Roster (entity-centric core)
- Layout mirrors the World tab: enemy list (left) + **persistent** detail/edit panel (right).
- **HP / EP / Rupia editable** via `GuidedNumberField` (backend `PATCH /api/rom/enemy-stats/{id}` already exists), with safety badge (safe) + vanilla "changed" diff.
- Panel also shows: enemy image, notes, confidence, first-seen chapter, and a computed **"Appears in"** list (which chapter lineups reference this enemy ID).
- Undocumented combat bytes (record bytes 2–6, 8–9) remain **read-only** (caution tier, shown for reference, not editable).
- Crash IDs `0x0B/0x0C` and conservative-danger IDs `0x0F/0x17/0x25` are visibly flagged and never offered as a selectable value anywhere.

### B · Encounters
- Existing lineup editors (7 slots) + encounter-group (screen→lineup) editors, retained.
- **Hard rule enforcement:** every enemy-selection dropdown excludes `CONSERVATIVE_DANGER_ENEMY_IDS` from a **single shared source of truth** (see §3).

### C · Bosses (safe)
- Per-boss **safe-tier** fields (HP) editable inline (reuse `BossesPanel`'s safe fields).
- Expert-tier boss fields are **not** rendered here; show a "→ Expert tab" pointer instead (no duplication).

### D · Overworld enemies (safe)
- Per-chapter HP editable (reuse `OverworldPanel`'s safe HP fields).
- Derived fields (contact damage, EXP reward, emergence damage) remain read-only.

## 2. Expert tab — gated danger zone

- **One-time session unlock:** the Expert tab first shows a warning screen + an **"I understand this can crash the game"** button. Clicking it sets a store flag (`expertUnlocked`) that stays unlocked for the session. Until unlocked, the danger panels are not shown.
- **Holds the danger byte-tables:** `TbFormulasPanel`, `WeaponDamagePanel`, `EncounterRatesPanel`, expert-tier boss fields, and Debug.
- **Encounter Rates stays in Expert** (raw probability curve, danger tier) — not in the Enemies "Encounters" section.
- Each panel lives in exactly one tab. Bosses/Overworld **safe** fields live in Enemies; their **danger** parts live in Expert.

## 3. Backend / metadata

- Add an **`enemy` entity** to `core/field_metadata.py`: `hp`, `ep`, `rupia` = safe with `valid_range` + one-line descriptions; document crash/danger IDs in field warnings. The read-only combat bytes get caution-tier entries.
- Regenerate the baked `data/field_metadata.json` via the existing generator CLI; the staleness test must stay green.
- Expose **one canonical "selectable enemy IDs" list** (full roster minus `CONSERVATIVE_DANGER_ENEMY_IDS`, each with id/name) so every dropdown filters identically. Surface it either through the metadata response or a small dedicated endpoint (`GET /api/rom/enemies/selectable`) — implementer picks the lower-friction option that the FE can consume from one place.
- The enemy-stat PATCH endpoint already exists; no new write endpoint needed for roster stats.

## 4. Safety model (per parent spec §3)

- **Hard rule:** crash IDs `0x0B/0x0C` never selectable anywhere; `0x0F/0x17/0x25` treated as Danger and excluded from selection. Enforced via the single shared source (§3) and validated by the crash-safety check.
- Safe tier: roster HP/EP/Rupia, boss HP, overworld HP — free inline edit.
- Caution tier: undocumented combat bytes — shown read-only.
- Danger tier: TB formulas, weapon damage, encounter-rate curves, expert boss bytes — Expert tab only, behind the unlock.

## 5. Out of scope (deferred to Phase 4/5)

- Non-enemy Advanced panels (Economy, Magic, Caps, Cosmetic, Player progression) stay in their current location; they migrate to entity tabs in **Phase 4**.
- The shared validation rule engine + Settings toggles are **Phase 5**. Phase 3 only enforces the existing crash-ID exclusion at the dropdown/source level.
- No changes to the randomization engine.

## 6. Testing

- **Backend:** unit test that `build_field_metadata()` includes the `enemy` entity with hp/ep/rupia safe fields + valid ranges; staleness test for the baked artifact stays green; test that the selectable-enemy-IDs source excludes all of `CONSERVATIVE_DANGER_ENEMY_IDS`.
- **Frontend:** vitest for the selectable-IDs filter helper (excludes crash/danger IDs); existing safety.ts tests stay green.
- **Live verification:** browser pass — edit a roster stat (persists + shows changed/vanilla), confirm crash IDs absent from a lineup dropdown, confirm Expert tab gate blocks then unlocks, confirm no panel appears in two tabs.

## 7. Decisions locked

- Encounter Rates → Expert (not Enemies). ✔
- Expert unlock is session-scoped (not persisted to disk). ✔
- Per-panel routing (not per-field splitting) except Bosses/Overworld where safe fields surface in Enemies and danger fields stay in Expert. ✔
- No new randomizer/engine work. ✔
