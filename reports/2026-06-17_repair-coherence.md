# Repair Coherence Measurement — does reachability-repair cause "biome salad"?

**Date:** 2026-06-17
**Branch:** `wave1/b-repair-coherence`
**Author:** Claude (TMOS_AI)
**Question:** The reachability-repair pass adds ~73–81 edits/seed to grow output
(open-in-place / ts-swap walk links plus, as a last resort, warp-link teleport
stairways). Does it trade navigability for visual incoherence — fragmenting the
biome blobs the P3 coherence oracle measures?

---

## Method

For each seed: generate raw grow output (no navigability retry), measure the P3
coherence channel — `coherence.same_biome_adjacency_ratio` per chapter, the *same*
function the differential oracle reads in `testing/oracle.py` — then run
`repair_reachability` and re-measure. The same-biome adjacency ratio is the
fraction of walkable edges whose two screens share a biome
(`biome_key = (section_type, worldscreen_color)`). Higher = more clustered = more
coherent.

Tool: `util/measure-repair-coherence.py` (mirrors the repair invocation in
`strategies/lab_adapter.py::preview_plan` exactly — same `_stamp_candidate_onto_world`
+ `repair_reachability` path the live pipeline uses).

```
python util/measure-repair-coherence.py --count 10
```

ROM: `rom-files/TMOS_ORIGINAL.nes` (MD5 `b3236db14c87f375e5f24a5b9b79f071`).

---

## Results — same-biome adjacency ratio, before → after [delta], seeds 1–10

| seed | C1 | C2 | C3 | C4 | C5 |
|-----:|----|----|----|----|----|
| 1 | 0.831→0.804 [-0.027] | 0.835→0.830 [-0.005] | 0.819→0.776 [-0.043] | 0.497→0.473 [-0.024] | 0.765→0.680 [-0.085] |
| 2 | 0.837→0.810 [-0.026] | 0.827→0.822 [-0.005] | 0.802→0.757 [-0.045] | 0.550→0.524 [-0.026] | 0.750→0.669 [-0.081] |
| 3 | 0.853→0.809 [-0.044] | 0.827→0.822 [-0.005] | 0.775→0.743 [-0.032] | 0.503→0.478 [-0.025] | 0.804→0.714 [-0.090] |
| 4 | 0.836→0.816 [-0.020] | 0.797→0.792 [-0.005] | 0.794→0.751 [-0.042] | 0.526→0.495 [-0.031] | 0.758→0.663 [-0.095] |
| 5 | 0.844→0.811 [-0.033] | 0.800→0.795 [-0.005] | 0.785→0.732 [-0.053] | 0.520→0.495 [-0.025] | 0.734→0.657 [-0.077] |
| 6 | 0.831→0.799 [-0.032] | 0.846→0.841 [-0.005] | 0.794→0.756 [-0.038] | 0.534→0.505 [-0.029] | 0.757→0.678 [-0.078] |
| 7 | 0.830→0.797 [-0.033] | 0.811→0.806 [-0.005] | 0.794→0.757 [-0.036] | 0.515→0.475 [-0.039] | 0.775→0.688 [-0.087] |
| 8 | 0.847→0.820 [-0.027] | 0.839→0.828 [-0.010] | 0.810→0.756 [-0.054] | 0.500→0.478 [-0.022] | 0.774→0.683 [-0.090] |
| 9 | 0.840→0.801 [-0.039] | 0.825→0.820 [-0.005] | 0.790→0.757 [-0.033] | 0.535→0.508 [-0.027] | 0.760→0.669 [-0.092] |
| 10 | 0.844→0.812 [-0.032] | 0.835→0.830 [-0.005] | 0.792→0.746 [-0.047] | 0.545→0.516 [-0.029] | 0.786→0.704 [-0.082] |

**Worst per-chapter delta across all seeds:** **-0.0953** (Chapter 5, seed 4).
**Lowest after-repair ratio across all seeds:** **0.4731** (Chapter 4, seed 1).

---

## Verdict — repair does NOT meaningfully degrade coherence

1. **The high-coherence chapters stay coherent.** C1/C2/C3 sit at ~0.78–0.85 and
   stay ~0.74–0.82 after repair. C2 is essentially untouched (Δ ≈ -0.005, often a
   single edge). These are the visually obvious "biomes are blobs" chapters and
   repair leaves them clearly clustered.

2. **The lowest absolute number (C4 ≈ 0.47–0.55) is grow's, not repair's.** C4
   starts low *in raw grow* (before repair runs at all). Repair only removes
   0.02–0.04 from it. So the low absolute coherence in C4 is a pre-existing grow
   layout characteristic, NOT something the repair pass introduced.

3. **The largest repair-attributable drop is ~0.095** (C5), under the oracle's own
   `_CLUSTER_EPS = 0.10` regression threshold (`testing/oracle.py`). Repaired grow
   worlds therefore would **not** trip the oracle's "biome blobs fragmenting into
   salad" gate against vanilla on the repair contribution alone. C5 is the most
   sensitive chapter (consistently the biggest drop) and even it stays within
   tolerance.

4. **Why the drops are small and consistent:** each seed adds ~73–81 edits across
   ~739 screens. Most are open-in-place / ts-swap walk links between *already
   adjacent grid neighbours* (which tend to share a biome anyway); the warp-link
   lever — the one that could teleport across biomes — is a last resort used for a
   handful of stranded screens. The number of cross-biome edges introduced is tiny
   relative to each chapter's edge count, so the ratio barely moves.

**Conclusion: repair preserves navigability without trading it for incoherence.**

---

## Decision — repair lever-selection logic was NOT changed

The task brief: bias lever selection toward same-biome links *only if* the data
shows repair meaningfully degrades coherence. **It does not** (worst -0.095, within
the oracle's 0.10 tolerance; high-coherence chapters stay ~0.80). Per the brief and
project rule "don't delete or overwrite existing code without instruction," I made
**no change** to `repair/reachability_repair.py`. The four repair invariants and
0xFE SAFE-FIRST preservation are untouched, and the oracle was re-run (multiseed
verify still exits 0 — see below) to confirm no stale PASS.

Had a bias been warranted, the cheapest place would be `_try_open_in_place` /
`_try_warp_link`: among equally-cheap acceptable partners `r`, prefer those whose
`biome_key` matches `u`'s, while keeping the cheapest *lever* dominant overall. This
is recorded as the intended approach if a future lever change shifts the numbers.

---

## Regression guard

`projects/TMOS_Randomizer_V2/tests/test_validation/test_repair_coherence.py`
asserts, on the repaired grow world (seeds 1–3):

- **Absolute floor** — every chapter's post-repair ratio ≥ **0.40** (margin below
  the observed worst of 0.473): catches a real collapse into confetti.
- **Differential floor** — repair drops no chapter by more than **0.15** (margin
  above the observed worst of 0.095): catches repair *itself* becoming the cause of
  a coherence drop, e.g. if a future lever started stitching unrelated biomes.

These thresholds carry deliberate margin over the measured worst case so the test
flags a genuine regression, not seed-to-seed jitter.

---

## Reproduce

```bash
# Coherence before/after across N seeds
python util/measure-repair-coherence.py --count 10
python util/measure-repair-coherence.py 42 100 777   # explicit seeds
python util/measure-repair-coherence.py --count 10 --json   # machine-readable

# Regression test (ROM-gated; skips if ROM absent)
cd projects/TMOS_Randomizer_V2 && python -m pytest tests/test_validation/test_repair_coherence.py -q

# Reachability still 100% + 0xFE preserved (the oracle re-run)
python util/verify-repair-multiseed.py --count 10
```
