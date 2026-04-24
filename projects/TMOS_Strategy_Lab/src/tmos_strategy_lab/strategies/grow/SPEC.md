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

## What this prototype does NOT do (yet)

- Inter-section connections (stairways / edge links).
- Time-door placement / wiring the PAST↔PRESENT bridge.
- Nav-byte writing.

The goal of this first cut is to **prove the core satisfiability-driven
growth loop produces zero-broken-edge, zero-era-leak sections** on the real
ROM. Everything else is layered on top once those invariants hold.

## Output signal

Headline metric: `broken_edges_total`. Must be **0** for every chapter.
If it isn't, the growth filter has a bug — it should be literally impossible
for a broken edge to appear in the output.

Secondary: per-chapter `(planned_size, grown_size)` pairs. Big gaps mean the
pool can't support the plan — tune targets down or widen filters.
