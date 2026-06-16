---
stepsCompleted: [1]
session_topic: 'Autonomous, self-verifying, repeatable world-map randomization'
session_goals: 'Remove the human from the debug loop; AI iterates a randomizer against an objective verifier until correct; repeatable across many seeds'
selected_approach: 'analyst-led (codebase-grounded) → planning → implementation'
techniques_used: ['first-principles', 'assumption-reversal', 'reference-image-grounding', 'systematic-debugging', 'ground-truth-validation']
session_continued: true
continuation_date: '2026-06-15'
note: 'Recreated 2026-06-15 after an uncommitted-WIP loss (branch switch to master wiped feat/patch-rom). Code recovered + committed on feat/coherence-and-repair (cf1ab04). Findings also preserved in auto-memory.'
---

# Brainstorming Session Results — Autonomous self-verifying randomization

**Facilitator:** Claude (TMOS_AI) · **Date:** 2026-06-15

## Goal
Push the grind onto the AI: closed-loop generate → verify → repair/retry, runnable
unattended and repeatably, producing a *coherent* (not chaotic) world. Make the
**verifier the source of truth** and wrap any generator in an autonomous loop against it.

## Architecture — three-layer oracle
- **L1 Structural** (exists): reachability, section connectivity, walkability, edge
  alignment, time-period isolation. Hard pass/fail, differential vs vanilla.
- **L2 Coherence** (built this session): biome classification + adjacency/placement scoring.
- **L3 Playability** (P4, future): headless NES emulator boots ROM, drives movement via the
  ~210-addr RAM map to confirm REAL in-game reachability. The only true playability check.

## P3 Coherence — 7 laws from the original maps (reverse-engineered)
1. Biomes form contiguous blobs, never confetti. (clustering — primary soft channel)
2. **Interior↔Exterior hard segregation** (overworld never walk-adjacent to dungeon
   interior; classified by section_type/CHR, not tile colors). FIRST HARD GATE.
3. Water = connective tissue + boundary; bridges are functional.
4. Towns/castles in traversable, safe, land-reachable terrain.
5. Biome identity = palette (NOT chr+palette — see correction below).
6. Per-chapter biome budget ("same feel" is chapter-specific).
7. Gradual tile seams (no hard grass|lava).

## P3 implementation (SHIPPED, committed cf1ab04)
- **Slice 1 — segregation hard gate** (`validation/validators/interior_exterior_segregation.py`):
  EXTERIOR={OVERWORLD} vs INTERIOR={DUNGEON,MINI_DUNGEON,MAZE}; ERROR severity; rides the
  oracle's error_count differential. **Empirical:** vanilla is NOT zero — Ch4 has 2
  intentional cave-mouth edges; the differential absorbs them. 5 tests.
- **Slice 2 — clustering soft channel** (`validation/coherence.py` + oracle wiring):
  same-biome adjacency ratio per chapter, differential vs vanilla (`_CLUSTER_EPS=0.10`,
  provisional). **Law 5 CORRECTED empirically:** biome = `(section_type, worldscreen_color)`
  (vanilla clusters 0.78–0.91); CHR-bank *fragments* it (0.55–0.81); TileSection is
  per-screen noise (~0). 10 tests. Verdict is now a 2-channel vector (reachability + clustering).

## P5 controller — design (RESOLVED, not yet built)
Fixed-priority knob order (hard gates → clustering → seams → hydrology); **advance-seed by
default, re-weight only on systematic multi-seed failure** (kills thrash); layered K/M/N stop
conditions that always terminate in a report. It's batch.py + a thin policy layer + a streak
detector. The coherence vector IS its tuning surface.

## The grow saga (the session's core discovery)
- Doc claimed "P2 COMPLETE — grow 13/13 PASS." Running the loop end-to-end revealed grow
  produces **no passing ROM**: it fails its own reachability gate on Ch2/4/5 every reseed.
- **Root cause (commit b1a2af2 + RESULTS.md): the 13/13 was a cross-era cheat.** grow v0.2.0
  inflated reachability with physically-illegal PRESENT↔PAST walk links; v0.3.0's era-safety
  correctly forbade them, exposing honest (lower) reachability. The oracle is RIGHT.
- **Dominant fixable cause:** one-way edges from preserved `0xFE` building entrances
  (Ch2 13 dead-end cells, Ch4 11; undirected reach ≈ vanilla → connected but one-way). Ch5
  also has 9 genuinely-islanded cells.

## Fixes done this session
- **Gate unified** (`lab_adapter._reach_counts` → oracle's stairway-aware reachability):
  removed the "gate stricter than oracle" inconsistency. 2 tests.
- **grow v0.4.0 — L2 filter-growth** (`grow/impl.py` `_entrance_blocks_adjacency`, all 4
  placement sites): never grow across a stock 0xFE (no one-way traps), entrances preserved
  (safe-first). 18 grow tests pass / 1 xfail; 4 L2 unit tests. Effect SMALL (Ch2 85→87,
  Ch4 67→68, Ch5 42→44) — the safe lever's coverage cost, as RESULTS.md warned.
- **Reachability-repair pass** (`repair/reachability_repair.py`, generic V2 post-pass):
  warp-aware `compute_reachable` + open-in-place `repair_chapter` (preserve 0xFE,
  edge-aligned, same-era, deterministic, RepairRecords). 8 tests. TS-swap / warp-link /
  world-wrapper / pipeline integration still TODO.

## Time-door gate — ATTEMPTED then REVERTED
Adding time-door credit to the gate lifted VANILLA to 98–123 while grow stayed 68–87 —
a more-warp-truthful metric makes grow look WORSE, and the clique pairing was unvalidated.
Reverted (don't ship an untrustworthy gate).

## VALIDATION against GameAnalysis2 ROM_VERIFIED (the decisive finding)
- Time-door pairing CONFIRMED: 2 screens/chapter (present `is_past:false` + past `is_past:true`,
  content 0xC0). Source: `GameAnalysis2/.../world/map_layout/time_door_screens.json`.
- **Reachability is PROGRESSION-GATED** (Faruk→Horen, Supica→desert, OPRIN→time door,
  Holy Robe→Lava Cape). So EVERY static reachability BFS is a PROXY that over-counts
  playability. The reachability gate cannot prove playability — only the P4 emulator can.
- grow's deficiency is REAL: under the fullest validated metric, grow reaches ~70% of vanilla
  even assuming all items. Not a metric artifact.

## Strategy chosen for "make it work" (user decisions on record)
- SAFE-FIRST: never remove a building entrance to gain reachability (could silently make the
  game unwinnable; static oracle can't detect lost access).
- The user proposed a **repair/fallback pass**; refined into: prefer "open in place" over
  "move it" (relocation cascades); repair hierarchy (open-in-place → TS-swap → warp → relocate);
  4 invariants (preserve 0xFE, edge-align, same-era, deterministic); reframe the GOAL from
  "≥ vanilla" to absolute "100% reachable (all-items)"; build it generic so it fixes organic too.
  Scope decision: generic V2 post-pass.

## Repair pass — open-in-place measured on grow seed 42 (2026-06-16)
Warp-aware reachable, 0xFE preserved 79→79. Ch1 68→121, Ch2 87→88, Ch3 78→83, Ch4 68→72,
Ch5 44→110. **Pattern:** huge gains where unreachable regions are connected blobs with one
alignable boundary (Ch1/Ch5 — a few links cascade through whole components); ~no help where
screens are stranded with no edge-aligned free port (Ch2/3/4). **265 screens still
unrepaired, ~211 for lack of an aligned port.** → next lever = TS-swap-then-open (make an
edge alignable), then warp-link for islanded components.

## Status & next
- Working on **grow** (lab_grow), not organic. Both currently fail the (proxy) gate.
- Repair pass v1 foundation shipped (compute_reachable + open-in-place). NEXT increments:
  TS-swap-then-open, warp-link for islanded sections, world-level wrapper, real edges_provider
  (extract_edges), pipeline integration (run after generation, before oracle), end-to-end
  verification on grow seed 42 (does repair reach 100%?).
- P4 emulator remains the validated way to settle true playability.

## Lessons banked (memory)
- Re-run the oracle on EVERY strategy change (the 13/13 was stale because nothing re-verified).
- Reachability is progression-gated → static gate is a proxy; P4 is the real validator.
- **Commit verified work immediately** — this doc + a day's code were lost to an uncommitted
  branch switch and had to be recreated. Isolate WIP before any branch/subagent operation.
