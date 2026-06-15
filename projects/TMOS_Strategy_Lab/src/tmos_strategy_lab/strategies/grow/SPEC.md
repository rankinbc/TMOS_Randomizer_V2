# grow — satisfiability-driven section growth

## Purpose

Generate a new world per chapter by **growing each section organically from a
seed screen**, only placing candidates whose edges already align with every
grid-adjacent neighbor. Shape, size, and membership emerge from what the
screen pool can actually satisfy. No late-stage repair, no
plan-vs-reality consolidation.

## Why it exists

The V2 `organic` strategy separates shape (Phases 1–3) from population
(Phase 4) and reconciles the two via a repair + consolidation cascade
(`run_world_repair`, `apply_section_consolidation`, `aggressive_blob_merge`).
On most seeds this produces 100+ edge/nav/fragmentation errors because the
abstract shape makes promises the screen pool can't keep, and downstream
passes try to cover the gap.

`grow` proves a different bet: **fuse shape and population into one step**.
At every placement the edge constraints are checked up front, so no broken
edge ever enters the output in the first place. If the pool runs out of
candidates for the next frontier cell, the section stops growing — target
sizes are soft suggestions, not contracts.

## Algorithm

Per chapter:

1. **Plan sections.** Decide count, `(section_type, is_past)`, and target
   size per section. Keep it loose — if the pool under-supplies, actual
   size will be smaller.
2. **Build pools.** For each `(section_type, is_past)` bucket, collect every
   non-excluded screen in the chapter as a candidate.
3. **Grow.** For each planned section:
   a. Pick a seed grid position and a seed screen from the bucket.
   b. Loop until target size or frontier exhaustion:
      - Enumerate the **frontier** — unoccupied grid cells adjacent to placed
        cells.
      - For each frontier cell, find pool members whose edges align with
        every already-placed grid-neighbor (at the cell's border with that
        neighbor).
      - Pick the first frontier cell that has ≥1 viable candidate; place a
        random candidate there, remove from pool.
      - If no frontier cell has any candidate, stop growing (accept partial
        section).

At the end, every section is a single walkably-connected blob by
construction, and no two grid-adjacent placed screens have broken edges.

## Hard rules (enforced by construction)

1. **PAST and PRESENT screens never share a section.** The pool is
   bucketed on `(section_type, is_past)`; growth only ever draws from the
   matching bucket. A section's `is_past` flag equals every placed
   screen's era.
2. **The only legal PAST↔PRESENT bridge is the time-door screen.** Screens
   whose content byte is `0xC0`, `0xC7`, or `0xD7` are excluded from the
   growth pool entirely. They are reserved for the dedicated TD bridge
   wired in a later phase.
3. **Adjacent-edge walkability.** Before placing a candidate, the
   candidate's edge in every direction pointing at a placed grid-neighbor
   must have ≥1 aligned walkable tile with that neighbor's opposite edge.
   Non-satisfying candidates are filtered out of consideration.

## Backtracking

When the frontier stalls (no frontier cell has any viable candidate), the
loop undoes the most recent non-seed placement, blacklists that
`(cell, screen)` pair so we don't repeat the dead-end, and retries.
Budget: `2 * target_size` rewinds per section. The seed is never rewound.

## Navigation writing (v0.2.0)

As of v0.2.0 grow writes its grown layout into WorldScreen nav bytes
(`navwrite.py`) so the emitted `Candidate` is **navigable**, not just
edge-satisfiable. Pipeline per chapter, after `grow_chapter`:

1. **Tile-swap application.** For each section's `overrides {rel_idx:
   (new_top, new_bot)}`, set `top_tiles`/`bottom_tiles` on the WorldScreen.
   Native placements keep original bytes. A swap whose target index is out of
   range is a hard `ValueError` — never skipped (REQUIREMENTS §6 N-2). This
   runs first so the post-swap tiles are what later edge extraction sees.
2. **Intra-section nav** (port of V2 `strategies/grow_nav.apply_grid_navigation`
   — logic ported, not imported). For each section grid, for each placed cell,
   in fixed direction order **right, left, down, up**: an existing
   `NAV_BUILDING_ENTRANCE` (0xFE) byte is preserved unconditionally (this is a
   stricter rule than V2's port, mandated by "preserve 0xFE everywhere" — grow
   is blind to nav bytes, so a placed grid neighbor can land on a stock building
   entrance; the entrance wins and the adjacency is one-way); otherwise grid
   neighbor present → write its relative index (the reverse pointer falls out
   because both cells are processed); else → `NAV_BLOCKED` (0xFF). No RNG.
3. **Inter-section linking.** Per-section blobs are joined into one component
   via edge-verified boundary links: a *free edge* (post-intra `0xFF`, non-`0xFE`)
   on section S paired with the opposite free edge on section T, requiring
   `_edges_aligned` (≥1 aligned walkable position) — the same rule grow uses
   internally, so links are valid by construction. nav bytes are an abstract
   directed graph (no shared spatial frame between sections); physical validity
   is "the player can cross the shared border", which is exactly what
   `EdgeCompatibilityMetric` checks. Union-find spanning. Sections left
   unconnected to chapter-relative screen 0's component are reported in
   `breadcrumbs.grow_nav.unlinked_sections` — never silently islanded.

Breadcrumb: `breadcrumbs.grow_nav = {links_written, unlinked_sections:
[{chapter, section_ids}], blocked_edges_written, swaps_applied}`.

### RNG consumption order (v0.2.0)

- `generate()`: main `rng = Random(seed)`; per chapter `chapter_rng =
  Random(rng.randrange(2**31))` (consumed by `grow_chapter`), **then**
  `nav_rng = Random(rng.randrange(2**31))` (linking). This extra per-chapter
  draw is the behavior change that bumps 0.1.0 → 0.2.0.
- Linking draws: for each unconnected section pair in `sorted(viable.keys())`
  order, `nav_rng.randrange(len(candidates))` over the pre-sorted,
  port-filtered viable list. Sections are sorted by `section_id`, free edges
  by `(rel_idx, dir_rank)`, candidate links lexicographically — every iteration
  surface is materialized to a sorted list before any RNG draw.

### Requires ROM bytes

`generate()` raises `ValueError` when `ctx.rom_bytes is None` (snapshot input):
the edge/walkability checks need raw ROM. Same fail-loud contract as
`graph_mutate` / `organic_port`.

## Hybrid linking (v0.3.0)

v0.3.0 makes the inter-section linking **era-safe** and **warp-aware**. The tile-swap
pass and intra-section pass are unchanged from v0.2.0; linking gains three rules:

1. **Era safety.** Walk-across links are only formed between sections of the *same*
   era (`section.spec.is_past`, equivalently `PAST_SCREEN_INDICES` membership — never
   `parent_world`, which is deprecated and mixed-era). This enforces hard-rule #2
   *at link time*, not just via pool bucketing: ordinary directional nav never
   straddles PRESENT↔PAST. (In v0.2.0 the linker could connect a PRESENT section to a
   PAST one; directed reachability over that graph was physically invalid.)
2. **Warp preservation.** Stairway screens (Event 0x40, detected via
   `WorldScreen.is_stairway`) and time-door screens (Content 0xC0,
   `ContentType.TIME_DOOR`) are never rewritten — navwrite only writes `screen_index_*`
   and tile bytes, so their `content`/`event` survive untouched. Time doors are
   pool-excluded (orphans); stairways are NOT pool-excluded and may be ordinary placed
   cells (their warp bytes are still preserved). Both are counted in the breadcrumb
   (`stairways_preserved`, `time_doors_preserved`).
3. **Warp-aware connectivity.** Before walk-across spanning, the section union-find is
   seeded with warp edges: each stairway pair `(W, Content-dest)` and the chapter's
   time-door pair bridge the sections their endpoints anchor on (a placed warp anchors
   on its own section; an orphan warp anchors on the section its stock directional exit
   lands in). Warps need no edge alignment. The time door is the ONLY legal
   PRESENT↔PAST bridge, so it is the only way a PAST section joins the PRESENT
   component. Sections still not joined to chapter-relative screen 0's component are
   reported in `breadcrumbs.grow_nav.unlinked_sections` — never silently islanded.

Breadcrumb (v0.3.0): `breadcrumbs.grow_nav = {walkacross_links, warp_links,
stairways_preserved, time_doors_preserved, unlinked_sections: [{chapter, section_ids}],
blocked_edges_written, swaps_applied}`.

### RNG consumption order (v0.3.0 — unchanged draw count vs v0.2.0)

The era guard only *filters* the walk-across candidate set; warp seeding is fully
deterministic (warps are fixed ROM facts, iterated over sorted indices) and consumes no
RNG. The single RNG draw remains `nav_rng.randrange(len(candidates))` per unconnected
**same-era** pair, over a pre-sorted, port-filtered list. Byte output differs from
v0.2.0 only via the new (era-safe, warp-seeded) link topology and the enriched
breadcrumb — hence the 0.2.0 → 0.3.0 bump.

## What this strategy does NOT do (yet)

- Invent new time-door or stairway warps. Stock warps (Content 0xC0, Event 0x40) are
  preserved and used for connectivity, but none are created or relocated. A PAST section
  only joins the chapter component if a stock time door's directional exit happens to
  land on a placed cell on each side; otherwise it is reported `unlinked` (the benchmark
  measures how often — the signal for whether v0.4.0 needs richer warp/link operators).
- Rewrite unplaced randomizable screens (`pool_remaining > 0`) or
  `DO_NOT_RANDOMIZE` screens — those keep stock nav and may remain orphans.
  Surfaced indirectly via `growth.pool_remaining`.
- Guarantee full per-chapter connectivity. When linking can't connect a chapter
  with valid edges, `unlinked_sections` records the leftovers; the benchmark
  measures how often, which is the signal for whether v0.3.0 needs more link
  operators.
- Guarantee *directed* reachability of every cell, or reach **no-worse-than the stock
  baseline** per chapter. Linking is union-find — it guarantees an undirected connected
  *component*, but a directed BFS from screen 0 (V2's shippability model,
  `lab_adapter._reach_counts`) follows only `screen_index_*` and counts neither stairway
  nor time-door traversal. **Measured result (v0.3.0, seeds 0–19):** grow reaches
  ≥ stock on ch1 & ch3 (20/20) but **regresses on ch2, ch4, ch5 (0/20)** — see
  `RESULTS.md`. This is the headline negative finding: by-construction edge validity does
  NOT translate to directed reachability. (v0.2.0 appeared to win only because its
  un-era-guarded links let the BFS walk PRESENT→PAST — physically illegal.) grow is
  therefore **not yet shippable** to V2; closing the ch2/4/5 gap is v0.4.0 work.

The original first-cut goal — **prove the satisfiability-driven growth loop
produces zero-broken-edge, zero-era-leak sections** — now extends to **prove
that turning that edge validity into real navigation yields worlds reachable
no-worse-than the stock ROM**.

## Output signal

Headline metric: `broken_edges_total`. Must be **0** for every chapter.
If it isn't, the growth filter has a bug — it should be literally impossible
for a broken edge to appear in the output.

Secondary: per-chapter `(planned_size, grown_size)` pairs. Big gaps mean the
pool can't support the plan — tune targets down or widen filters.
