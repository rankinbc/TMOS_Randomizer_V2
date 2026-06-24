# Design — Debug Tab, ROM-vs-Vanilla Change Diff, and Validator Correctness

**Date:** 2026-06-24
**Status:** Approved (design); pending implementation plan
**Scope:** TMOS_Randomizer_V2 (FastAPI backend + React/TypeScript frontend)

---

## 1. Problem & Goals

Three related improvements to the randomizer's developer/debug experience:

1. **Consolidate debug functionality** into a single primary "Debug" tab. Today the
   `JsonDebugPanel` component exists but is not wired into the main navigation, and
   the edit log lives only inside the Enemies/Hero views.
2. **Add a "log of all changed data"** — an authoritative view of how the current ROM
   state differs from the as-loaded vanilla ROM.
3. **Improve the Validate button** so it reports *all* validation problems, and — the
   core of this effort — **fix the validators** so that a pristine, unmodified default
   ROM passes with zero errors.

### Ground-truth finding (baseline measurement)

Running the modern validation framework (`validation/runner.py` + `validation/validators/*`)
against the **pristine default ROM** (`TMOS_ORIGINAL.nes`, no randomization plan applied)
produces **605 errors and 426 warnings** across the 5 chapters.

The default ROM is the shipped, fully-playable game. Therefore **every error on the
default ROM is a validator defect, not a ROM defect.** Breakdown of the 605 errors:

| Validator | Requirement | Errors | Likely defect category |
|---|---|---|---|
| `edge_compatibility` | R-010 | 252 | Rule too strict — vanilla seams violate it everywhere |
| `edge_alignment` | R-011 | 221 | "≥1 aligned walkable tile" rule vanilla does not obey |
| `navigation_consistency` | R-001 | 120 | Misreads intentional vanilla one-way/asymmetric joins as conflicts |
| `screen_traversability` | R-003 | 9 | A few vanilla screens deemed unreachable |
| `interior_exterior_segregation` | — | 2 | TBD during investigation |
| `time_period_isolation` | R-002 | 1 | TBD during investigation |

473 of 605 errors come from the two edge validators.

### Success criteria

- A new primary **Debug** tab consolidates all debug functionality.
- The Debug tab includes an authoritative **ROM-vs-vanilla change diff**.
- The Validate button reports **every** error and warning, untruncated.
- **A pristine default ROM validates with zero errors** (the acceptance criterion for
  the validator-correctness work), enforced by an automated regression test.

### Non-goals

- No new validation *rules* are added; this effort corrects existing ones.
- The in-context `EditLog` usages in Enemies/Hero views are not removed or changed.
- No undo/redo system; the change diff is read-only.

---

## 2. Architecture Overview

Three independent units, each testable on its own:

1. **Debug tab shell** (frontend) — a new primary tab routing to `DebugView`, which hosts
   three internal sub-sections. Pure consolidation/navigation; no business logic.
2. **Change diff** (backend endpoint + frontend panel) — derives differences from ROM
   state, not from a session log.
3. **Validator correctness** (backend) — recalibrates validators against the vanilla
   baseline, plus a reporting improvement in the existing validation UI, plus a
   regression test.

Units 1–3 are loosely coupled: the tab shell renders whatever the diff and validation
panels expose; the diff and validation endpoints are independent of each other.

---

## 3. Section 1 — New Primary "Debug" Tab

### Changes
- `ui/src/store/index.ts`: add `'debug'` to the `TabType` union; add `'debug'` to the
  `GLOBAL_TABS` set (the Debug tab needs no chapter selection).
- `ui/src/components/layout/MainContent.tsx`: add `{ id: 'debug', label: 'Debug' }` to
  the `TABS` array; add `{selectedTab === 'debug' && <DebugView />}` to the content
  switch.
- New `ui/src/components/debug/DebugView.tsx`: a container with three internal sub-tabs:
  1. **Changes** — renders `ChangesView` (Section 2).
  2. **Validation** — renders the improved validation panel (Section 3).
  3. **Inspector** — renders the existing `JsonDebugPanel` content (chapter / plan /
     screens / sectionMap raw JSON) moved here verbatim.

### Behavior
- The existing `JsonDebugPanel` is reused as-is inside the Inspector sub-section (moved,
  not rewritten). Its internal `validation` section is superseded by the new Validation
  sub-section; the redundant internal validation view is removed from `JsonDebugPanel`
  to avoid two Validate buttons.
- The `EditLog.tsx` usages in Enemies/Hero views remain unchanged.

### Interface
`DebugView` takes no required props (global tab). Sub-section state is local component
state.

---

## 4. Section 2 — "Changes" = ROM-vs-Vanilla Diff

### Backend
New endpoint **`GET /api/debug/changes`** in `api/server.py`.

The server already holds both buffers:
- `_rom_vanilla` — the as-loaded vanilla bytes.
- `_rom_data` — the mutable working copy reflecting all applied edits.

Algorithm:
1. For each known editable region (using the same offset maps the existing edit
   endpoints already use — screens, enemy stats, hero stats, tile bank, encounters,
   shops, etc.), decode the field from both `_rom_vanilla` and `_rom_data`.
2. Emit an entry only where they differ:
   `{ system, label, rom_offset, vanilla, current }`.
3. Group entries by `system` (Screens, Enemies, Hero, Tiles, …) with a per-group count
   and a grand total.
4. Compute a raw-byte fallback: count differing bytes **not** covered by any known region,
   and surface that count so nothing is silently hidden.

Response shape:
```json
{
  "total_changes": 0,
  "groups": [
    { "system": "Screens", "count": 0, "entries": [
      { "label": "Ch2 screen 0x12 objectset", "rom_offset": "$...", "vanilla": 0, "current": 0 }
    ]}
  ],
  "uncategorized_byte_count": 0
}
```

### Frontend
- `ui/src/api/client.ts`: add `async getChanges(): Promise<ChangesResponse>` plus the
  `ChangesResponse` / `ChangeGroup` / `ChangeEntry` types.
- New `ui/src/components/debug/ChangesView.tsx`: fetches on mount + a manual Refresh
  button; renders grouped, collapsible lists with counts. On a clean default ROM it
  shows "No changes — matches vanilla." Surfaces `uncategorized_byte_count` when > 0.

### Rationale
Derived from ROM state, so it is authoritative and survives page refresh, unlike the
session `editLog`. The session log remains a separate, complementary chronological view.

---

## 5. Section 3 — Validate Button: Report-All + Validator Correctness

### 5a. Reporting (UI + endpoint)
The `GET /api/debug/validate` endpoint already returns every issue. The improvement is
presentation, in the new Validation sub-section:
- Top-line PASS/FAIL banner.
- By-validator and by-chapter breakdown (counts).
- The **complete**, scrollable list of every error and warning: validator id, severity,
  chapter, screen index, message. Nothing truncated.
- A "Copy full report" button (plain-text dump of all issues).

### 5b. Validator correctness (the core work)
**Acceptance criterion: a pristine default ROM yields zero validator errors.**

For each of the 6 failing validators, investigate which defect category applies and fix
accordingly. The vanilla ROM is the ground truth a correct validator must accept.

- **Rule too strict** (expected for `edge_compatibility` and `edge_alignment`): recast
  the check as *relative to vanilla* — a randomized seam is an error only if it is worse
  than what vanilla shipped at an equivalent boundary — or correct the underlying rule.
  Vanilla seams must pass.
- **Severity misclassified**: if the finding is an observation rather than a game-breaker,
  downgrade ERROR → warning/info.
- **Logic bug** (suspected for `navigation_consistency`): it misreads intentional vanilla
  asymmetry/one-way joins as conflicts; fix the detection so legitimate vanilla
  topology passes.

Each validator is handled in its own investigate → fix → re-run-baseline loop. The
implementation plan decomposes this per validator, biggest first
(`edge_compatibility` → `edge_alignment` → `navigation_consistency` → the rest).

The corrected validators must remain meaningful on **randomized** output: the goal is to
stop flagging vanilla-equivalent conditions, not to disable the checks. Where a rule is
recast as "relative to vanilla," a deliberately-broken randomized seam must still fail.

### 5c. Regression test
Add a pytest (ROM-gated, consistent with existing ROM-gated tests) that loads the
pristine default ROM, runs the full validation framework over all 5 chapters, and
asserts **zero errors**. This locks in the invariant so a future validator change that
reintroduces vanilla false-positives is caught immediately.

---

## 6. Phasing (for the implementation plan)

The validator work is large (605 errors, 6 validators). Suggested ordering so value lands
incrementally and the risky part is isolated:

1. **Phase A — Tab + diff + reporting** (low risk, immediately useful): Debug tab shell,
   `GET /api/debug/changes` + `ChangesView`, validation report-all UI.
2. **Phase B — Validator correctness** (the substantive work): the regression test
   harness first (so it goes red→green), then one validator at a time, biggest first,
   re-running the baseline after each until the default ROM reaches zero errors.

---

## 7. Testing Strategy

- **Change diff:** unit test that a vanilla-vs-vanilla diff is empty; that a single
  known edit produces exactly one entry in the correct group with correct
  vanilla/current values.
- **Validators:** the zero-error baseline regression test (5c); plus, for each recast
  validator, a targeted test that a deliberately-broken randomized seam/topology still
  fails (guards against over-relaxation).
- **Frontend:** the Debug tab renders all three sub-sections; ChangesView shows the
  empty-state on a clean ROM.

---

## 8. Risks & Open Questions

- **Over-relaxation:** loosening the edge validators could let genuinely-broken
  randomized seams pass. Mitigation: the "still-fails-on-broken-input" tests in §7.
- **`navigation_consistency` 120 errors on vanilla** is the most concerning, since the
  randomizer relies on this validator most. Investigation must distinguish genuine
  vanilla asymmetry (intended) from cases the validator simply mishandles.
- **`uncategorized_byte_count` > 0 on a known edit** would reveal an offset map the diff
  doesn't yet cover; treated as a follow-up, not a blocker.
