# Expert Tab Dissolution — Design

**Date:** 2026-06-25
**Status:** Approved (design); ready for implementation plan
**Area:** `projects/TMOS_Randomizer_V2/ui` (React/TypeScript frontend; no backend changes)
**Scope:** Sub-project #1 of a 3-part batch from the request "move the Expert tab items in with their appropriate sections, just have a warning next to them; add more information / improve sparse editors; make allies editable." This spec covers **only** the Expert-tab dissolution. The other two sub-projects (improve sparse field descriptions; make allies editable) are deferred to their own spec → plan → implementation cycles.

## Problem

The Expert tab is a catch-all wall. Today every advanced ROM editor lives behind a single `⚠ Expert` tab that:

1. Forces a full-page "I understand this can crash the game" gate (`ExpertView`) before *any* advanced panel is reachable — even the safe, ROM-verified ones (Magic/MP table, Economy, Caps).
2. Buries editors far from the entity they belong to. Weapon damage and the MP table are Hero concerns but live under Expert; boss bytes and encounter rates are Enemies concerns but live under Expert; the economy and palette editors belong with Items and Graphics.
3. Renders `JsonDebugPanel` a second time at the bottom of `ExpertView`, even though the Debug tab already exposes it (`DebugView.tsx:33`, "Inspector" section).

The result is that genuinely safe edits are gated like dangerous ones, and related edits are scattered across two tabs. The user wants advanced controls folded into the tab they conceptually belong to, with danger conveyed by an inline warning rather than a separate page.

## Goal

Retire the Expert tab entirely. Re-home each of its panels into the entity tab it belongs to (using each tab's segmented sub-tab bar), drop the unlock wall, and mark dangerous panels with a single inline amber badge instead of a gate. No editable field appears in two tabs.

## Non-Goals

- **No panel rewrites.** The eight advanced panel components (`MpTablePanel`, `WeaponDamagePanel`, `LevelCapsPanel`, `BossesPanel`, `EncounterRatesPanel`, `TbFormulasPanel`, `EconomyPanel`, `PalettePanel`) are reused **as-is**, including their internal `TierBadge`/`SafetyBadge` markup. This spec only changes where they are mounted and how they are reached.
- **No new backend work.** Pure frontend IA refactor.
- **No change to what is editable.** Danger panels were already editable once unlocked; they remain editable. We remove the *gate*, not any field's writability. (Display-only fields inside the panels stay display-only — that is the panels' own concern.)
- **No tile/world editor changes.** Specs #1–#3 (Selected World Screen panel, collision filter, theme filter) are shipped and untouched here, except for the two cross-link repoints in Section 3.

## Current State (verified)

- `MainContent.tsx` — `TABS` array includes `{ id: 'expert', label: '⚠ Expert' }` (line 16); `GLOBAL_TABS` includes `'expert'` (line 27); routes `selectedTab === 'expert'` → `<ExpertView />` (line 143).
- `ExpertView.tsx` — reads `expertUnlocked`/`unlockExpert`; renders the full-page gate, then `<AdvancedView />` + a redundant `<JsonDebugPanel />`.
- `AdvancedView.tsx` — a local-`useState` sub-tab router with nine sub-tabs: `progression` (→ `PlayerStatsView`), `magic` (→ `MpTablePanel`), `bosses` (→ `BossesPanel tierFilter={tier!=='safe'}`), `encounters` (→ `EncounterRatesPanel`), `tbformulas` (→ `TbFormulasPanel`), `weapons` (→ `WeaponDamagePanel`), `economy` (→ `EconomyPanel`), `caps` (→ `LevelCapsPanel`), `cosmetic` (→ `PalettePanel`). It consumes `focusTarget` where `tab === 'expert'` to deep-link to a sub-tab.
- `store/index.ts` — `TabType` (line 35) includes `'expert'`; `EnemiesSection` (line 32) = `roster | encounters | bosses | overworld`; `expertUnlocked` state (line 176, init `false` line 407); `unlockExpert` action (line 272 decl, line 1412 impl). `focusTarget`/`setFocusTarget`/`consumeFocusTarget` stay.
- `screenLinks.ts` — shop link calls `unlockExpert()` then `setFocusTarget({ tab: 'expert', section: 'economy' })`; palette link calls `unlockExpert()` then `setFocusTarget({ tab: 'expert', section: 'cosmetic' })`; `ScreenLinkActions` includes `unlockExpert`.
- `DebugView.tsx` — already has an "Inspector" section that renders `JsonDebugPanel`. **The Debug tab needs no new wiring.**
- `EnemiesView.tsx`, `DebugView.tsx` are the reference pattern: a segmented sub-tab bar driving a section state (store-backed for Enemies, local for Debug).

## Architecture

Five edits, each independent enough to be its own task:

### 1. Re-home the advanced panels into entity tabs

Each destination tab gains (or extends) a segmented sub-tab bar — the `EnemiesView` pattern. The panel components are mounted unchanged. The danger marker is the panel's own inline badge plus an amber "expert" tag on its sub-tab button (the same `t.expert` tag `AdvancedView` already renders), per the approved "inline warning badge, no gate" decision.

| Destination tab | Sub-tabs (default first) | Source |
|---|---|---|
| **Hero** (`PlayerStatsView`) | Progression & Combat *(default, = current PlayerStatsView)* · Magic & Spells · Weapon Damage ⚠ · Caps & Limits | `PlayerStatsView`, `MpTablePanel`, `WeaponDamagePanel`, `LevelCapsPanel` |
| **Enemies** (`EnemiesView`) | Roster *(default)* · Encounters · Bosses · Overworld · **Boss Bytes ⚠** · **Encounter Rates ⚠** · **TB Formulas ⚠** | existing four + `BossesPanel tierFilter={tier!=='safe'}`, `EncounterRatesPanel`, `TbFormulasPanel` |
| **Items & Economy** (`ItemsView`) | Items *(default, = current ItemsView)* · Economy & Shops | `ItemsView` body, `EconomyPanel` |
| **Graphics** (`TileBankView`) | Tiles *(default, = current TileBankView)* · Cosmetic | `TileBankView` body, `PalettePanel` |
| **Debug** (`DebugView`) | *(unchanged — already hosts `JsonDebugPanel`)* | — |

Notes:
- **Hero** wraps the existing `PlayerStatsView` content as the default "Progression & Combat" sub-tab and adds three sibling sub-tabs. Hero has no deep-link, so a **local `useState`** section (the `DebugView`/`AdvancedView` pattern) is sufficient — no store field needed.
- **Enemies** extends the existing store-backed `EnemiesSection` union with `bossbytes | encrates | tbformulas` and appends three buttons to its `SECTIONS` array. The `BossesPanel` keeps `tierFilter={(tier) => tier !== 'safe'}` so safe boss fields (already in the existing "Bosses" section) never appear twice.
- **Items** and **Graphics** each gain a **local `useState`** section plus a `focusTarget` consumer effect (mirroring `AdvancedView`) so the shop/palette deep-links land on the right sub-tab. Their existing content becomes the default sub-tab.
- The `BossesPanel`/`EncounterRatesPanel`/`TbFormulasPanel`/`WeaponDamagePanel` sub-tab buttons render the amber "expert" tag exactly as `AdvancedView`'s `t.expert` buttons do today.

### 2. Remove the gate and the Expert tab

- Delete `expertUnlocked` (state + init) and `unlockExpert` (decl + impl) from `store/index.ts`.
- Narrow `TabType` to drop `'expert'`. This is the safety net: `tsc` will flag every dangling reference to the removed tab.
- In `MainContent.tsx`: remove the `'expert'` entry from `TABS`, remove `'expert'` from `GLOBAL_TABS`, and remove the `selectedTab === 'expert'` route.
- Delete `ExpertView.tsx` and `AdvancedView.tsx` (their panels are now mounted by the entity tabs; the redundant `JsonDebugPanel` render is simply dropped because Debug already hosts it).
- Danger panels are now always editable, marked only by their inline `TierBadge` and the amber sub-tab tag.

### 3. Repoint cross-links (Spec #1 `screenLinks.ts`)

- Shop link → `setFocusTarget({ tab: 'items', section: 'economy' })`; remove the `unlockExpert()` call.
- Palette link → `setFocusTarget({ tab: 'graphics', section: 'cosmetic' })`; remove the `unlockExpert()` call.
- Remove `unlockExpert` from the `ScreenLinkActions` interface, and from the `linkActions` bundle assembled in `WorldView.tsx`.
- Move the `focusTarget` sub-tab consumer **out of** the deleted `AdvancedView` and **into** `ItemsView` (consumes `section: 'economy'`) and the Graphics view (consumes `section: 'cosmetic'`). The existing Enemies and Allies `focusTarget` consumers (Spec #1) are unchanged.
- Repo-wide sweep for any remaining `expert` / `unlockExpert` / `expertUnlocked` / `ExpertView` / `AdvancedView` / `tab: 'expert'` references and clean them up (tsc-driven).

### 4. Tests

- Update `screenLinks.test.ts`: shop expectation → `{ tab: 'items', section: 'economy' }`, palette expectation → `{ tab: 'graphics', section: 'cosmetic' }`, and assert no link calls `unlockExpert` (the action no longer exists on `ScreenLinkActions`).
- Everything else is verified by `tsc` (the `TabType` narrowing surfaces all dangling refs), `eslint`, and a manual checklist. The panel components are unchanged, so no panel-level tests change.

## Files Touched

- `ui/src/store/index.ts` — remove `expertUnlocked`/`unlockExpert`; narrow `TabType`; extend `EnemiesSection` with `bossbytes | encrates | tbformulas`.
- `ui/src/components/layout/MainContent.tsx` — drop the `expert` tab entry, `GLOBAL_TABS` member, and route.
- `ui/src/components/views/PlayerStatsView.tsx` (Hero) — wrap existing content as default sub-tab; add Magic/Weapon Damage/Caps sub-tabs via a local section. **(Or a thin new `HeroView` wrapper if `PlayerStatsView` is cleaner left intact — implementer's call during planning; the existing content must remain the default sub-tab either way.)**
- `ui/src/components/views/EnemiesView.tsx` — append three sub-tabs + mount the three panels.
- `ui/src/components/views/ItemsView.tsx` — wrap existing content as default sub-tab; add Economy sub-tab + `focusTarget` consumer.
- `ui/src/components/tilebank/TileBankView.tsx` (Graphics) — wrap existing content as default sub-tab; add Cosmetic sub-tab + `focusTarget` consumer.
- `ui/src/components/screen/screenLinks.ts` — repoint shop/palette links; drop `unlockExpert` from `ScreenLinkActions`.
- `ui/src/components/screen/screenLinks.test.ts` — update shop/palette expectations; assert no `unlockExpert`.
- `ui/src/components/views/WorldView.tsx` — drop `unlockExpert` from the `linkActions` bundle.
- **Delete:** `ui/src/components/views/ExpertView.tsx`, `ui/src/components/views/AdvancedView.tsx`.
- `ui/src/components/views/index.ts` (barrel) — drop `ExpertView`/`AdvancedView` exports if present.

## Testing

- **Unit (vitest, node-env):** `screenLinks.test.ts` — shop → `items/economy`, palette → `graphics/cosmetic`, no `unlockExpert`.
- **Type/lint:** `tsc --noEmit` and `eslint` must pass; the `TabType` narrowing is the completeness check for dangling Expert references.
- **Manual checklist:**
  - The `⚠ Expert` tab is gone; no full-page unlock wall anywhere.
  - Hero shows Progression (default) / Magic / Weapon Damage ⚠ / Caps; each renders its panel.
  - Enemies shows Roster (default) / Encounters / Bosses / Overworld / Boss Bytes ⚠ / Encounter Rates ⚠ / TB Formulas ⚠.
  - Items shows Items (default) / Economy; Graphics shows Tiles (default) / Cosmetic.
  - From a World screen detail panel: the shop link opens Items → Economy; the palette link opens Graphics → Cosmetic.
  - Danger panels are editable immediately, marked by their inline badge + amber sub-tab tag. No field is editable in two tabs (safe boss fields only under Enemies → Bosses; advanced boss bytes only under Enemies → Boss Bytes).
  - Debug tab still shows Changes / Validation / Inspector (Inspector = the JSON panel).

## Risks / Open Notes

- **`PlayerStatsView` wrapping:** whether to add the sub-tab bar inside `PlayerStatsView` or introduce a thin `HeroView` wrapper is an implementation-plan decision; the constraint is that the current Progression content stays the default sub-tab. Same pattern question for `ItemsView`/`TileBankView` — wrap in place vs. thin wrapper.
- **`EnemiesSection` extension vs. local state:** Enemies already uses a store-backed section, so the three new sub-tabs extend that union for consistency. Items/Graphics/Hero use local state because their only cross-view need is the `focusTarget` deep-link (Items/Graphics) or nothing (Hero).
- **No editable field duplicated:** the `BossesPanel tierFilter={tier!=='safe'}` split is the one place this could regress; the manual checklist explicitly verifies safe boss fields appear only under the existing "Bosses" section.
- **Deep-link section strings:** `FocusTarget.section` is a free `string`, so repointing the shop/palette links to `items`/`graphics` needs no type change — only the consuming view must recognize the section id.
