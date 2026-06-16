<!--
  ⚠️ STATUS (2026-06-15) — READ FIRST:
  - L2 (filter-growth) is ALREADY SHIPPED as grow v0.4.0 (impl._entrance_blocks_adjacency
    at all 4 placement sites; grow suite 18 passed / 1 xfailed; 4 L2 unit tests; invariants
    green). It only marginally improved directed reachability (Ch2 85->87, Ch4 67->68,
    Ch5 42->44). Committed on branch feat/coherence-and-repair (cf1ab04).
  - VALIDATION (GameAnalysis2 ROM_VERIFIED): the static reachability gate is a
    PROGRESSION-BLIND PROXY (Faruk->Horen, Supica->desert, OPRIN->time door, Holy Robe->
    Lava Cape). grow reaches ~70% of vanilla even assuming all items. Only the P4 emulator
    can prove playability.
  - A generic V2 reachability-REPAIR pass is now the chosen direction (repair/
    reachability_repair.py): open-in-place + TS-swap + warp links, goal = "100% reachable
    (all-items)", preserve 0xFE. That may supersede chasing grow-side L3 on the static metric.
  - L3 (Ch5 islanded-section repair) below is NOT done. Re-evaluate its premise vs the
    generic repair pass before executing.
  - Full context: TMOS_Randomizer_V2/docs/brainstorming/brainstorming-session-2026-06-15.md

  INITIAL_grow_v04_reachability.md — intent doc for /generate-prp.
  Decision on record: SAFE-FIRST — never remove a building/shop/dungeon entrance for reach.
-->

## FEATURE

Raise grow's reachability to no-worse-than-vanilla WITHOUT overwriting any building
entrance (0xFE). Root cause is decomposed in `strategies/grow/RESULTS.md`: one-way edges
from preserved 0xFE (Ch2/Ch4) + 9 genuinely-unlinked PRESENT cells (Ch5).

## CONSTRAINTS (non-negotiable)
- SAFE-FIRST: never remove a building entrance. 0xFE count per chapter must be invariant
  (add a test). Do NOT implement RESULTS.md lever 1 (overwrite 0xFE).
- Preserve determinism, era-safety (no PRESENT↔PAST walk), warp preservation (27 stairways /
  10 time doors), zero new broken edges. Keep tests 10/11/12 + determinism green.

## APPROACH
1. L2 — filter growth away from one-way 0xFE adjacencies. **DONE (v0.4.0).**
2. L3 — Ch5 unlinked-section repair pass: link each islanded PRESENT section to the main
   component via nearest edge-compatible boundary (reuse link_sections / _edges_aligned).
   Record each as a RepairRecord. **NOT done — and possibly superseded by the generic V2
   reachability-repair pass; decide before building.**

## ACCEPTANCE
- Seed sweep (directed _reach_counts): ch1/ch3 stay ≥ vanilla; ch4 ≥ vanilla on most seeds;
  ch2/ch5 gaps shrink (document residual honestly — ch2 is structurally capped near vanilla−1).
- 0xFE count unchanged (new test); invariant tests green; strategy_version -> done at 0.4.0
  for L2; RESULTS.md updated.

## COMPANION (V2, separate)
Generic reachability-repair post-pass (already started in V2 repair/) is the broader,
generator-agnostic answer and reframes the goal to absolute "100% reachable (all-items)".
