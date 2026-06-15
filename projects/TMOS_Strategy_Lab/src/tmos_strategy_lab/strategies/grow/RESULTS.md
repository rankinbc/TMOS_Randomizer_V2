# grow — Results

**Strategy version:** 0.3.0 (era-safe, warp-aware nav-writing)
**Date:** 2026-06-15
**ROM:** `data/rom/TMOS_ORIGINAL.nes` (MD5 `b3236db14c87f375e5f24a5b9b79f071`)
**Reachability model:** directed BFS from chapter-relative screen 0 over `screen_index_*`,
excluding `NAV_BUILDING_ENTRANCE` (0xFE) and `NAV_BLOCKED` (0xFF) — identical to V2's
shippability gate `lab_adapter._reach_counts` (does **not** count stairway / time-door
traversal). This is the exact yardstick V2 retries against.

---

## Headline finding (negative)

**grow's by-construction edge validity does NOT translate into directed reachability ≥
the stock ROM.** With correct era-safety (v0.3.0), grow reaches *no-worse-than* stock on
**ch1 and ch3** but **structurally regresses on ch2, ch4, ch5 across every sampled seed.**

> The v0.2.0 nav-writing *appeared* to win reachability handily (104–140 reachable
> screens/chapter vs stock's 51–91). That was an **artifact**: v0.2.0's inter-section
> linker was not era-guarded, so it wrote ordinary walk-across edges between PRESENT and
> PAST sections. A directed BFS then "reached" PAST screens by walking across the era
> boundary — which is **physically impossible** in the actual game (the only legal
> PRESENT↔PAST transition is a Content=0xC0 time door, handled by the engine, not by
> directional nav). Once v0.3.0 forbids cross-era walk-across links, the inflated count
> collapses to the honest PRESENT-only reachable set, and the regression is exposed.

Because no seed meets the gate on ch2/4/5, V2's retry-until-no-worse-than-baseline
adapter would **never** find a shippable seed. **grow v0.3.0 is correct but not yet
promotable to V2.**

## Seed sweep (seeds 0–19, directed reachability)

| Chapter | stock baseline | grow range | seeds ≥ baseline |
|---------|----------------|------------|------------------|
| ch1     | 51             | 61–70      | **20 / 20** ✓    |
| ch2     | 91             | 74–81      | 0 / 20 ✗         |
| ch3     | 53             | 56–76      | **20 / 20** ✓    |
| ch4     | 70             | 57–68      | 0 / 20 ✗         |
| ch5     | 55             | 35–44      | 0 / 20 ✗         |

No seed in the sample passes all five chapters. ch4 is the closest miss (typically 2–13
screens short); ch5 is the widest (11–20 short).

Reproduce:

```bash
PYTHONHASHSEED=0 python components/benchmark/scripts/run.py \
    --strategy identity --strategy organic_port --strategy grow \
    --seeds 20 --workers 4 --run-label grow_nav_hybrid_research \
    --input data/rom/TMOS_ORIGINAL.nes
```

## What IS confirmed working (v0.3.0)

- **Determinism** — same seed + version → byte-identical `Candidate.to_json()`.
- **Era safety** — no walk-across or stairway link crosses PRESENT↔PAST (test 12).
- **Warp preservation** — every stock stairway (Event 0x40) keeps its content+event;
  every time door (Content 0xC0) stays 0xC0 (test 11). Detected counts match the
  GameAnalysis2 ROM_VERIFIED oracle exactly: **27 stairway screens** (Ch1 2, Ch2 5,
  Ch3 2, Ch4 4, Ch5 14) and **10 time doors** (2/chapter, all 0xC0).
- **Edge compatibility** — zero new broken inter-section edges vs stock; the 14 broken
  edges from the pre-era v0.1.0 linker stay gone (tests 6, 10).
- **Building entrances / DO_NOT_RANDOMIZE** — preserved untouched (tests 4, 5).
- **Warp-aware connectivity** — union-find seeded by stairway + time-door warps; sections
  that can't be joined to screen 0's component are reported in
  `breadcrumbs.grow_nav.unlinked_sections`, never silently islanded (test 7).

## Why ch2/4/5 regress — measured decomposition (seed 42)

The gap was decomposed by comparing grow's **directed** reachable count (the gate),
grow's **undirected** count (same edges, ignore direction), and the PRESENT cells in
**unlinked** sections:

| Ch | stock_dir | grow_dir | grow_undir | gap | unlinked PRESENT cells | dead-end PRESENT cells (undir−dir) |
|----|-----------|----------|------------|-----|------------------------|------------------------------------|
| 2  | 91        | 77       | **90**     | 14  | 0                      | **13**                             |
| 4  | 70        | 67       | **78**     | 3   | 0                      | **11**                             |
| 5  | 55        | 38       | 48         | 17  | **9**                  | **10**                             |

**Verdict — the dominant cause is directional dead-ends, not unlinked sections.**

- **ch2 & ch4 are connected, just one-way.** grow's *undirected* reachability already
  matches/exceeds stock (90≈91; 78>70). All ~14 / ~3 missing screens are reachable if
  edge direction is ignored — i.e. they sit behind one-way edges. **No PRESENT section
  is islanded.**
- **ch5 has both:** ~10 dead-end cells **plus** ~9 cells in genuinely unlinked PRESENT
  sections (no edge-aligned walk-across partner), so even undirected (48) < stock (55).

**Root cause of the one-wayness:** preserved `NAV_BUILDING_ENTRANCE` (0xFE). When a placed
cell's edge toward a grid neighbor is a stock 0xFE, navwrite preserves the entrance
(documented in `apply_grid_navigation`): the neighbor points back, but the cell's own
0xFE blocks the forward step, so the adjacency is one-way and a directed BFS can enter a
subtree but not traverse out of it. Stairways/time-doors compound this — they connect the
world richly (undirected+warp reaches 134/161/144) but the gate counts no warp traversal,
so warp-only-reachable regions score zero.

**Candidate v0.4.0 levers (with the tradeoff each carries):**
1. **Relax 0xFE preservation where it breaks a grid adjacency** — overwrite the entrance
   with the neighbor index. Highest leverage (would likely flip ch2 & ch4 green), but
   *sacrifices a building entrance* — violates the current "preserve 0xFE everywhere"
   invariant; needs an explicit decision.
2. **Filter growth** so a screen is not placed where a needed adjacency direction is a
   stock 0xFE (treat 0xFE directions as non-growable). Preserves entrances; cost is
   smaller sections / lower coverage.
3. **ch5 linking** — a repair link pass connecting islanded PRESENT sections through the
   nearest edge-compatible boundary (only ~9 cells; secondary to the 0xFE issue).
4. **Reconsider the gate** — V2's `_reach_counts` gives no credit for stairway/time-door
   traversal, which the real game uses; grow leans on warps far more than the hand-built
   stock map, so the gate arguably under-credits grow's true playability. Out of scope
   here; a question for the V2 owner.

## Verdict

The hybrid nav-writing is **complete and correct**. The reachability gate (test 8) is
intentionally marked `xfail(strict=True)` to track this negative result: it will XPASS
(and fail loudly, prompting removal of the marker) the moment a future linking change
closes the gap. Until then, grow is a research result — *edge-valid and era-safe, but not
reachability-competitive with the stock map* — not a V2 promotion candidate.
