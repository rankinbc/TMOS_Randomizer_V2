# Entity-Centric UI Reorganization & ROM Customization — Design

**Date:** 2026-06-15
**Project:** TMOS Randomizer V2 (`projects/TMOS_Randomizer_V2`)
**Status:** Approved design — ready for implementation planning

## Goals

1. Get more game information and ROM-customization capability into the UI.
2. Make the UI organized and easy to use, with helpful inline guidance.
3. Improve randomization validation (and make it honest + self-enforcing).
4. Keep crash-risky controls where they can't be changed by mistake.

**Design principle:** entity-centric. You edit everything about a world screen from the World tab and everything about an enemy from the Enemies tab. Usability over slick visuals; compact where it makes sense.

## Non-Goals (YAGNI)

- No redesign of the randomization engine (phases 1–7 / strategies stay as-is).
- No shop *randomization* — blocked on Bank 2 bytecode RE (currently `NotImplementedError`). Shop *table* editing at ROM `$C4D1` is in scope only where the existing read path already supports it; otherwise flagged "investigate."
- Cosmetic/visual polish is deprioritized.

## Authoritative Knowledge Source

Game truth lives in `C:\claude-workspace\GameAnalysis2\analysis_games\TMOS` (ROM-verified specs + disassembly), **not** the in-repo `/knowledge` folder. Key machine-readable sources:
- `game_specs/systems/world/map_layout/screen_graph.json` — all 739 screens + exit pointers
- `game_specs/systems/world/tilesections/tilesection_data.json` — 512 TileSections
- `game_specs/systems/world/navigation/objectset_catalog.json` — per-chapter spawn sets
- `game_specs/systems/world/content_types.md` — Content/Event byte enums, safe vs dangerous values
- `game_specs/systems/combat/enemies/README.md` — turn-based roster + **crash IDs 0x0B/0x0C**
- `game_specs/entities/*.json`, combat/bosses, magic, balance READMEs

---

## 1. Information Architecture

Replace the current 11 tabs (Flow, Screens, Tiles, Tile Bank, Items, Player Stats, Enemies, Allies, Advanced[11 sub-tabs], Validation, Debug) with **7 entity tabs + 1 gated Expert tab**.

| Tab | Absorbs | Holds |
|---|---|---|
| **World** | Flow + Screens + Tiles | Screen map/grid + side panel: navigation, tile sections (top/bottom), content/NPC, palette, enemies-that-spawn-here, ParentWorld/music |
| **Enemies** | Enemies + Advanced (enemy/boss/overworld/TB-formula/encounter-rate/weapon — *safe parts only*) | Turn-based roster & stats, encounter lineups, encounter groups, overworld enemies, bosses |
| **Items & Economy** | Items + Advanced (economy/caps) | Item registry, shops, EXP table, inventory caps |
| **Hero** | Player Stats + Advanced (MP table, level caps) | HP/attack curves, MP table, level caps |
| **Allies** | Allies | Ally editor (now editable, not read-only) |
| **Graphics** | Tile Bank + Tiles rendering | Tile bank (MiniTile composition), tile sections, palettes |
| **Randomize** | Flow plan + Validation + randomize modal | Strategy/config, plan graph, oracle/validation report |
| **⚠ Expert** | Debug + all Danger-tier byte controls | Gated tab: raw event byte, objectset pointer, CHR bank/DataPointer, exit position, and any other byte-level danger controls |

Danger-tier portions of the old Advanced expert panels (TB combat formulas, weapon damage tables, encounter-rate curves, raw boss bytes) move into the **Expert** tab; their safe-to-edit summaries stay on the relevant entity tab.

## 2. Editing Model (consistent across all entity tabs)

- **Layout:** list/map (left) + **persistent side panel** (right). The panel stays put while you click between entities, enabling rapid iteration.
- **Right-click context menu** on the map/list for quick actions: Connect to…, Swap tiles, Copy / Paste, Mark preserved, Jump to Expert bytes, Edit.
- **Live edits:** optimistic update → PATCH endpoint → reconcile with server response (the existing Zustand + `ApiClient` pattern). Edit log continues to track ROM offset + cascade effects.

## 3. Safety Model (3 tiers, data-driven)

Each editable field carries a safety tier sourced from the field-metadata file (§4):

- **● Safe (green):** edit freely, live preview, no friction. (navigation, tile sections, palette, enemy HP/EXP/Rupia, player curves, MP table)
- **▲ Caution (amber):** editable inline, but validated; dropdowns/inputs pre-filtered to valid values; inline warnings. (content/NPC byte — chapter-specific, stairway pairing, one-way exits, ParentWorld)
- **⛔ Danger (red):** never shown on entity tabs. Only in the **Expert** tab, behind an explicit "I understand this can crash the game" unlock. (raw Event byte, objectset pointer, CHR bank/DataPointer, exit position)

**Hard rule:** known hard-crash enemy IDs `0x0B` and `0x0C` are never selectable in any control anywhere (excluded from all enemy dropdowns/lineups). Unknown-status IDs `{0x0F, 0x17, 0x25}` are treated conservatively as Danger.

## 4. Guided Fields + Metadata Pipeline

**Metadata pipeline:** a build/generation step produces `field_metadata.json` from the GameAnalysis2 knowledgebase. Per field it records:
- one-line description ("what it does")
- valid range / enum (drives pre-filtered controls)
- vanilla value
- safety tier (Safe / Caution / Danger)
- "used by" references (cross-entity links)
- contextual warnings (e.g., "NPC values 0x80–0x8F differ per chapter")

This is the **single source of truth** for guidance and tiers, baked into the randomizer (self-contained, versioned). Served to the UI via an endpoint (e.g. `GET /api/metadata/fields`) and/or bundled into the build.

**Guided field rendering:** every field shows live value · **vanilla value** + "changed" marker · pre-filtered control · one-line description · ⚠ warnings · "used by" links, with heavy detail behind an **ⓘ** popover so the panel stays compact.

## 5. Validation System (all four; runtime-toggleable via Settings)

A **shared rule engine** defines "valid" once, consumed by both live (UI) and batch (oracle) validation so they never drift.

1. **Hard self-validation gate** — every generated plan auto-runs the oracle; a ROM that fails navigability/reachability cannot be exported/patched. On failure, auto-retry/repair rather than prompting the user. Removes any faked `navigability_ok: True` / hardcoded passes.
2. **Crash-safety validator** — whole-ROM scan over **both** manual edits and randomized output; fails on any Danger-tier violation (crash enemy IDs in lineups, dangerous Event bytes, out-of-range objectset/tilesection/exit indices, invalid CHR bank).
3. **Live in-editor validation** — Caution-tier guardrails run as you edit (cross-chapter NPC, broken stairway pairs, one-way exits), wired to the shared rule engine.
4. **Transparent oracle report** — the Randomize tab shows the full baseline diff: per-chapter reachability vs vanilla, biome clustering, new errors/warnings, with plain-language reasons. No hidden pass/fail.

**Settings panel:** each of the four is individually toggleable at runtime. Safe defaults; the self-validation gate is ON by default. Re-run the oracle on every strategy change.

## 6. Backend Changes

- Extend safe-field PATCH endpoints to cover all Safe/Caution fields exposed by the new editors.
- Add **ally editing** endpoints (currently display-only). Investigate **shop-table editing** at `$C4D1`; full where the read path supports it, partial + "investigate" flag otherwise.
- Add **field-metadata generation script** + serving endpoint.
- Implement the **shared rule engine**; wire validation + Settings into the plan and `/api/rom/patch` flow so the export gate is enforced server-side.
- Move Danger-tier controls' endpoints behind the Expert-tab gating contract (no behavioral change server-side beyond clear labeling/validation).

## 7. Phasing

Each phase becomes its own implementation plan (spec → plan → execute):

1. **Foundation** — new IA shell (tab restructure), safety-tier infrastructure, field-metadata pipeline + endpoint, guided-field component.
2. **World tab** — flagship screen editor: map + persistent side panel + right-click context menu; navigation/tiles/content/palette/enemies-here; Expert byte controls routed to Expert tab.
3. **Enemies tab + Expert tab** — consolidate roster/lineups/groups/overworld/bosses; stand up the gated Expert tab and migrate Danger controls.
4. **Remaining entity tabs** — Items & Economy, Hero, Allies (new editing), Graphics.
5. **Validation system + Settings** — shared rule engine, four validation features, Settings toggles, honest export gate.

Phase order can flex; export-gate pieces of phase 5 may land earlier if convenient.

## Open Items Resolved

- **Allies/shop editing depth:** full where RE supports it, partial + "investigate" flags otherwise. ✔
- **Phasing order:** accepted as listed. ✔
- **Debug tab:** folds into the Expert tab.

## Key Crash-Risk Reference (for the metadata + validators)

- Turn-based enemy IDs `0x0B`, `0x0C` → hard crash; never selectable. `0x0F/0x17/0x25` → conservative Danger.
- WorldScreen byte 15 (Event) dangerous values: `0x01,0x03,0x09,0x10,0x20,0x47,0x48,0x60,0x62,0x80,0xC0`. Safe: `0x00,0x08,0x22,0x40`.
- Exit bytes 4–7: `0xFE` = building entrance, `0xFF` = blocked, `0x00–0x7D` = chapter-relative index (must be < chapter screen count). Boss→victory chains must stay intact.
- Content byte (2): `0x80–0x8F` are chapter-specific NPCs — block cross-chapter moves.
- ObjectSet (3), TileSections (10–11), DataPointer/CHR bank (8): must stay within valid per-chapter/global bounds.
