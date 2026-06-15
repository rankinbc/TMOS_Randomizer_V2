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

## Why ch2/4/5 regress (hypotheses for v0.4.0)

Directed reachability is lost two ways, not yet disentangled:

1. **Unlinked PRESENT sections.** Walk-across requires a free boundary edge with ≥1
   aligned walkable tile between two same-era sections. Sections with no such viable
   pair stay islanded (visible in `unlinked_sections`, e.g. Ch5 leaves many sections
   unlinked on seed 42). Stock connects these via hand-authored nav that grow's strict
   alignment filter rejects.
2. **Directed dead-ends.** Preserved 0xFE building entrances make some intra-section
   adjacencies one-way, so a directed BFS can enter but not leave a subtree even within
   a linked component (undirected reachability is materially higher — see test 7).

**Candidate v0.4.0 operators:** allow a stairway to act as a *directional* connector (not
just a connectivity warp) so warp-linked sections become directionally reachable; add a
"repair" link pass that connects an islanded PRESENT section through its nearest
edge-compatible boundary even at lower alignment; bias section planning toward fewer,
larger PRESENT sections in ch2/4/5.

## Verdict

The hybrid nav-writing is **complete and correct**. The reachability gate (test 8) is
intentionally marked `xfail(strict=True)` to track this negative result: it will XPASS
(and fail loudly, prompting removal of the marker) the moment a future linking change
closes the gap. Until then, grow is a research result — *edge-valid and era-safe, but not
reachability-competitive with the stock map* — not a V2 promotion candidate.
