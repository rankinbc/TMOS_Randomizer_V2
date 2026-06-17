# Phase 0 — Diagnostic & Baseline: World-Map Randomizer

**Date:** 2026-06-15
**ROM:** `rom-files/TMOS_ORIGINAL.nes` (MD5 `b3236db14c87f375e5f24a5b9b79f071` ✓ canonical)
**Goal:** Before building an autonomous self-verifying loop, classify *how* the
generator fails over a real seed sweep. Answer the user's stated symptom
("the generator visibly fails") with evidence.

---

## TL;DR

| Path | Pass rate | Speed | Verdict |
|------|-----------|-------|---------|
| **Tester default (organic)** | "30/30 PASS" | 3 ms/seed | ❌ **FALSE PASS** — validated 0 chapters, reported success |
| **Classic (run properly)** | 0/30 | 118 ms/seed | ❌ Catastrophic — ~1% reachability, total fragmentation |
| **Organic (production path)** | 0/5 | ~75 s/seed | ⚠️ Fails on **ONE** issue: edge-alignment non-convergence |

**Three findings, in priority order:**

1. **The oracle lies (fails open).** The headless tester is hardcoded to the
   *classic* pipeline, but the default strategy is *organic*. Organic leaves
   `world_plan.get_chapter(n) == None`, so the tester's guard
   `if not all([chapter, chapter_plan, chapter_pop]): continue` skips **every
   chapter**, finds zero errors, and reports **PASS**. A green light from this
   harness currently means nothing. *This is why manual eyeballing never stopped.*

2. **Classic is a dead end.** Run with a real (classic) plan, 0/30 seeds pass:
   mean reachability **~1.0%**, navigation shattered into many components, towns
   fragmented (419 errors across 30 seeds), SPECIAL/MAZE sections left empty.
   Do not invest here.

3. **Organic is the right horse with ONE dominant, well-defined bug.** 0/5 seeds
   pass, but ~300 errors/seed are nearly all the *same category*:
   `Misaligned edges: ... 0 aligned walkable tile(s)`. The repair loop
   (`organic/repair.py`) is meant to fix exactly this (screen_swap / pool_pull)
   but burns its full budget (~75 s/seed) without converging.

---

## Detail

### Finding 1 — False-open verifier (CRITICAL)
- `testing/tester.py:194` calls `populate_world(...)` (classic Phase 4) on a plan
  whose `world_plan` chapters are `None` under organic.
- Result: `pop.get_chapter(n)` is `None` for all chapters → `chapter_results == []`
  → `passed = True`.
- Confirmed: all 30 seeds returned `chapters: []` yet `passed: True`.
- **Implication:** No autonomous loop can be built on this. Step one is a
  **fail-closed, strategy-correct oracle** ("validated 0 chapters" = FAIL).

### Finding 2 — Classic pipeline failure taxonomy (30 seeds)
```
 419  Section (TOWN): fragmented into N components
 300  Section (OVERWORLD): fragmented
 150  Reachability below threshold      (mean reachability ~1.0%)
 150  Navigation fragmented into N components
 150  Section (DUNGEON): fragmented
  77  Section (SPECIAL): empty
  73  Section (SPECIAL): fragmented
  50  Section (MAZE): empty
  37  Section (MAZE): fragmented
```
Also emits heavy `print()` debug noise (`NO SCREENS assigned to section N!`,
`SKIPPING: empty from_screens or to_screens`) — the generator routinely
under-fills sections.

### Finding 3 — Organic pipeline (5 seeds, production path)
- 0/5 pass. Errors/seed: 299, 323, 293, 304, 353. Warnings: ~180–215.
- **~95% of errors are a single type:** edge misalignment — two connected,
  grid-adjacent screens whose walkable openings don't line up
  (e.g. `A walkable at [1,3,4,6], B walkable at []`). Player walks into a wall.
- Many cases are "one side has walkable, the other is a solid wall (`[]`)" —
  i.e. screens placed adjacent whose borders don't physically meet.
- ~75 s/seed: the repair loop runs to budget then accepts the failures.

---

## Why this is encouraging

The failure is **not** vague chaos — it's **one geometric constraint**
(edge-walkability alignment) that the organic repair loop doesn't converge on.
That's a focused, fixable target. And it ties directly to the **coherence**
requirement: placement that respects edge/biome compatibility avoids creating
these mismatches in the first place — serving *both* playability and the
"organic world, just rearranged" goal.

---

## Revised priorities (feeds the plan)

1. **Fix the oracle first — make it fail-closed and strategy-correct.** Test the
   *organic* production path; treat "0 chapters validated" as FAIL. Without this,
   nothing downstream can be trusted or automated.
2. **Target organic edge-alignment convergence** (the real generator bug) —
   improve repair/placement so misaligned edges trend to zero. This is the
   single highest-leverage fix.
3. **Then** layer coherence scoring (biomes/towns) and the emulator playability
   oracle on top, and wrap the whole thing in the unattended batch loop.

## Reproduction
- Classic baseline: `RandomizationTester(rom, config(strategy='classic')).test_seeds(range(1,31))`
- Organic baseline: `Randomizer(cfg, strategy='organic').create_plan(s)` → `.apply(rom, out, plan)` → `result.success`
- Raw data: `/tmp/phase0/` (scratch, not committed)

---

## Step 1 Outcome (same day) — Trustworthy Oracle built (TDD)

New module `testing/oracle.py` (+ `tests/test_validation/test_oracle.py`, 3 tests, all green;
full 21-test validation suite green). The oracle:

- **Fail-closed** — empty world OR missing baseline can never PASS (kills the false-open bug).
- **Strategy-agnostic** — validates the *actual output ROM artifact* via `ValidationRunner`,
  not the generator's self-report.
- **Differential** — TDD revealed the static validators reject even vanilla (≈35-66%
  "reachable", 281 "errors") because they don't model stairways/time-doors. So the oracle
  judges "**no worse than vanilla**": reachability ≥ vanilla per chapter, no new errors.
  Vanilla passes itself; regressions are caught.

**True organic pass rate under the corrected oracle: 0/5.** Reasons are now honest:
organic emits *fewer* raw errors than vanilla (198–249 vs 281) but **regresses
reachability** sharply (e.g. Ch2 66%→4–39%, Ch4 42%→12–25%). The dominant problem is
navigational connectivity loss, not just edge cosmetics.

**Proof the old suite was complicit:** `test_integration/test_randomization.py::
test_seed_produces_valid_randomization` was *passing* on empty (0-chapter) output, while
`test_result_has_all_chapters` failed catching the same emptiness. P1 must re-wire
`tester.py`/CLI to delegate to `oracle.py`.

Caveat: `analyze_reachability` follows nav-pointers from screen 0 only (no stairways/
time-doors) — which is why the user's "yes" to a headless **emulator oracle** (P4) matters:
it's the only way to measure *true* in-game reachability. The differential metric partially
controls for this by comparing like-for-like against vanilla.
