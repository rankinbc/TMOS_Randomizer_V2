<!--
  INITIAL.md — intent doc for /generate-prp.

  `tileshuffle` (the previous intent) is complete and archived at
  PRPs/archive/2026-04-24_tileshuffle.md. This file now describes the NEXT
  feature: a graph-mutation strategy.

  When adding the feature after this, edit this file in place and re-run /generate-prp.
-->

## FEATURE

Add a new Lab strategy named **`graph_mutate`**: a **graph-mutation**
randomizer that treats the stock navigation graph as the seed state and
evolves it via a sequence of **small, locally-verified mutations**. Each
iteration picks one mutation operator, applies it to one edge / one screen /
one pair, checks a cheap local invariant on the affected neighborhood, and
either **accepts** the mutation (keep it, move on) or **reverts** it (undo,
try another). After N iterations the accumulated mutations form the final
`Candidate`.

This is a deliberate counter-proposal to the V2 *plan → template → repair*
triangle and to `tileshuffle`'s graph-preserving content shuffle. Where
`tileshuffle` never touches the graph, `graph_mutate` **only** touches the
graph — every step is a graph edit, every step ends with a playable world.
No plan document. No template instantiation. No bulk repair pass. The world
is playable at t=0 (it's the stock ROM) and the mutation loop preserves that
invariant: after every single mutation, the world is playable again by
construction, not by post-hoc repair.

It exists to answer three Lab questions:

1. Can local invariant checks (bidirectionality, edge compatibility in the
   4-cell neighborhood of the affected screens) substitute for V2's global
   repair pass and still produce shape-varied, always-playable maps?
2. How much shape variance is reachable from the stock graph within 200
   iterations — measured by `variety` and a graph-edit-distance breadcrumb?
3. What is the accept/reject ratio per operator? Which operators are "free"
   (almost always accepted) and which are "expensive" (mostly rejected)?
   The ratio is the headline research result.


## DELIVERABLE

A new strategy subpackage, auto-registered at import time:

```
src/tmos_strategy_lab/strategies/graph_mutate/
├── SPEC.md       # algorithm, operator catalog, local invariants, known limitations (REQUIREMENTS §4.6)
├── __init__.py   # from .impl import GraphMutateStrategy  (side-effect register)
├── impl.py       # strategy class + mutation loop
└── operators.py  # the three operators + local invariant check
```

Registered by extending `src/tmos_strategy_lab/strategies/__init__.py`:

```python
from . import identity, organic_port, tileshuffle, graph_mutate  # noqa: F401
```

Plus a test module:

```
tests/test_strategy_graph_mutate.py
```

Per REQUIREMENTS.md §5, strategies are not required to be tested — but
`graph_mutate`'s entire value proposition is "every step keeps the world
playable", so the invariant tests below are non-optional.


## ALGORITHM

Given `ctx: LabContext` and `seed: int`:

1. **Require `ctx.rom_bytes is not None`** — fail loud with a
   `ValueError` if the harness was invoked with a snapshot input (match
   the pattern in `strategies/organic_port/impl.py` where the same
   requirement exists for the same reason). Tile walkability cannot be
   checked without the raw ROM; a `graph_mutate` run on snapshot input
   would silently accept tree-blocked edges and produce an invalid map.
   This must be a hard failure, not a warning.
2. `world = copy.deepcopy(ctx.game_world)` — never mutate context (shared
   under spawn; mutation leaks across seeds silently).
3. `rng = random.Random(seed)` — scoped RNG instance. Never touch
   module-level `random` (determinism landmine per REQUIREMENTS §6 N-1).
4. Initialize `accepted = 0`, `rejected = 0`, `op_stats: dict[str, dict[str, int]]`.
5. For `iteration in range(MAX_ITERATIONS)` (fixed at 200 for v0.1.0; documented in SPEC.md):
   - Pick operator `op` uniformly from `[swap_adjacent_screens, reroute_edge, prune_deadend]` via `rng.choice`.
   - `mutation = op.propose(world, rng)` — returns an undoable description of the change (`apply` closure + `undo` closure + `affected_screens` set), or `None` if the operator has nothing applicable this iteration.
   - If `mutation is None`: continue (not counted as accept or reject).
   - `mutation.apply(world)` — edit in place.
   - Run **local invariant check** on `affected_screens ∪ their 4-neighbors` (see "Local invariants" below).
   - If pass → `accepted += 1`, record in `op_stats[op.name]["accepts"]`, continue.
   - If fail → `mutation.undo(world)`, `rejected += 1`, record in `op_stats[op.name]["rejects"]`, continue.
6. Produce the `Candidate`:
   - `chapters = {n: [s.to_dict() for s in world.chapters[n].screens]}`.
   - `repairs = []` — `graph_mutate` **does not repair**. A mutation that would leave the neighborhood invalid was already reverted; there is nothing to report as a repair.
   - `breadcrumbs = {"source": ctx.source, "rom_md5": ctx.rom_md5, "graph_mutate_stats": {"accepted": ..., "rejected": ..., "operators": op_stats}}`.
   - **Do NOT set `preserves_baseline = True`** — `graph_mutate` produces a different graph by design.


## OPERATORS (v0.1.0 — three operators in `operators.py`)

Each operator exposes `propose(world, rng) -> Mutation | None` where a
`Mutation` is a `(apply, undo, affected_screens)` triple. Every operator
honors `DO_NOT_RANDOMIZE` via V2's set (imported through `_v2_compat`) —
any screen whose global index is in that set is skipped both as the operand
and as a new target.

### Non-edge sentinel bytes — treat as first-class, never as screen indices

The four `screen_index_*` bytes do not always hold a screen index. V2
defines two reserved byte values (import both via `_v2_compat` — never
hardcode, never treat either as an index):

- **`NAV_BLOCKED = 0xFF`** — "no exit in this direction" (wall).
- **`NAV_BUILDING_ENTRANCE = 0xFE`** — walking that direction triggers
  V2's Content behavior (stairway / interior transition). Not a flat-map
  edge. Overwriting `0xFE` with a screen index silently destroys a
  stairway, which `stairway_integrity` will eventually fail — but by then
  the mutation has already been accepted, so the damage is retroactive.
  Every operator must treat `0xFE` as off-limits for rewrites, the same
  way it treats `0xFF`.

Canonical rule used by all three operators:

> A direction byte `screen_index_D` **represents a real graph edge** if
> and only if `screen_index_D not in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE)`.
> Operators only pick from real graph edges as operands, and only ever
> write a valid in-chapter screen index to a direction byte — never
> `0xFF` / `0xFE`, and never any other byte equal to an existing sentinel.

Materialize this as a single helper (`is_real_edge(screen, direction)`) in
`operators.py` that all three operators call — so when V2 introduces a
third sentinel in a future version, there is one line to update.

1. **`swap_adjacent_screens`**: pick a real graph edge `(A, B)` — i.e. a
   `(screen, direction)` pair where `is_real_edge` is true — in a random
   chapter where A and B are not in `DO_NOT_RANDOMIZE` and share the same
   `section_type`. Swap A and B: the two screen objects at those list
   positions are physically swapped (so their tiles, datapointer, event,
   content all travel with the screen), AND every `screen_index_*` byte
   in the chapter is rewritten as follows — `idx(A)` → `idx(B)`, `idx(B)`
   → `idx(A)`, **any sentinel byte (0xFE, 0xFF) is left exactly as is**,
   any other index is left exactly as is. Affected = {A, B} ∪ {real-edge
   neighbors of A ∪ real-edge neighbors of B}. Note: with only 739
   screens total across 5 chapters, in-chapter indices never reach 0xFE
   / 0xFF in the stock ROM, so collision with a sentinel value is
   already impossible — the "leave sentinels alone" rule is a
   future-proofing invariant, not a currently-live concern. State it
   anyway so the constraint doesn't rot.

2. **`reroute_edge`**: pick a screen A in a random chapter and a direction
   D ∈ {right, left, up, down} where `is_real_edge(A, D)` is true. Pick a
   new target C of the same `section_type` as A's current D-neighbor,
   chapter-local, `DO_NOT_RANDOMIZE`-filtered. Set `A.screen_index_D =
   idx(C)` and, if the original edge was bidirectional (i.e.
   `is_real_edge(old_B, inv(D))` was true AND pointed back at A), also
   set `C.screen_index_{inv(D)} = idx(A)` and clear the old reverse edge
   on `old_B` by setting `old_B.screen_index_{inv(D)} = NAV_BLOCKED`.
   Never pick D where the current byte is `0xFE` — building-entrance
   bytes are not rerouteable without also rewriting the associated
   Content behavior, which is out of scope for v0.1.0. Affected =
   {A, old_B, C}.

3. **`prune_deadend`**: find a "one-way leaf" — a screen L that has
   exactly one incoming real edge (parent P, direction D from P's side)
   and zero outgoing real edges. Critically, "zero outgoing real edges"
   means all four of L's direction bytes are `NAV_BLOCKED` — a screen
   whose only non-wall exit is `NAV_BUILDING_ENTRANCE` is **not** a
   one-way leaf in graph terms (it exits via Content behavior), so
   `prune_deadend` must skip it. Seal the true leaf by setting
   `L.screen_index_{inv(D)} = idx(P)`, turning `NAV_BLOCKED` into a real
   edge. (Semantics of "prune": remove the softlock potential of a
   one-way leaf by giving the player a way back, not by deleting the
   leaf.) Affected = {L, P}.

### Local invariants (checked after apply, before accept)

Restricted to `affected_screens ∪ their 4-neighbors`:

- **Valid indices**: every `screen_index_*` byte either references an
  index that exists in that chapter's screen list, OR equals
  `NAV_BLOCKED`, OR equals `NAV_BUILDING_ENTRANCE`. No other values
  permitted on any affected screen after the mutation.
- **Sentinel preservation**: no direction byte that was `NAV_BUILDING_ENTRANCE`
  on input is anything other than `NAV_BUILDING_ENTRANCE` after the
  mutation. (`NAV_BLOCKED` bytes MAY change — `prune_deadend` is exactly
  the case where 0xFF → a real index is intended. Building-entrance bytes
  are sacred; they encode stairway semantics that v0.1.0 does not touch.)
- **Tile-level edge walkability**: this is the invariant that catches
  trees, walls, water, cliffs, and every other non-walkable tile on a
  touching edge. For every affected real edge `(S, D, T)`:
  - Compute `src_grid = build_walkability_grid(rom_bytes, S.top_tiles,
    S.bottom_tiles, S.datapointer)` and `dst_grid = build_walkability_grid(
    rom_bytes, T.top_tiles, T.bottom_tiles, T.datapointer)` via the helpers
    re-exported from `tmos_strategy_lab._v2_compat.pathfinding`.
  - Extract the touching edges:
    `src_walk = get_walkable_edge_positions(src_grid, D)` and
    `dst_walk = get_walkable_edge_positions(dst_grid, inv(D))`.
  - Require **both `len(src_walk) >= 1` AND `len(dst_walk) >= 1`**. Column
    alignment is NOT required — per the Lab's existing `edge_compatibility`
    metric (`src/tmos_strategy_lab/metrics/edge_compatibility.py`), the NES
    engine lets the player step off any walkable tile in the source edge
    row onto any walkable tile in the destination edge row. The check is
    "at least one walkable tile on each side", not "per-tile column match".

  The walkability grid derives from V2's `is_walkable(tile_id)` in
  `tmos_randomizer/validation/tiles/categories.py`, which is the canonical
  collision table covering trees, walls, water, bridges, and every other
  non-walkable tile type. When that table is updated in V2, `graph_mutate`
  inherits the change for free — no per-tile list maintained in the Lab.
  Cache the walkability grids by `(top_tiles, bottom_tiles, datapointer &
  0xFF)` key inside each mutation attempt; building the grid is the
  dominant cost per check.
- **Bidirectionality**: for every `(S, D)` in the affected set with
  `S.screen_index_D = T`, either `T.screen_index_{inv(D)} = idx(S)` OR the
  *original input graph* had the same asymmetry at that pair (we record
  pre-existing asymmetry at world-load and tolerate it; mutation-introduced
  asymmetry is what we reject).
- **Edge compatibility**: for every affected adjacency, walkable-tile
  columns/rows on the touching edge are compatible via V2's edge-compat
  helper (imported through `_v2_compat`).

**Global** invariants (reachability, required_content, softlock,
stairway_integrity) are NOT checked per-mutation — only once at the end via
the harness's 9-metric battery. The claim "local invariants suffice" is
itself the research hypothesis: if the final battery shows global failures
despite per-step local passes, v0.2.0 will fold more invariants into the
per-mutation check.


## CONSTRAINTS (non-negotiable, from CLAUDE.md + REQUIREMENTS)

- **V2 reuse, not fork**: V2 constants and helpers come in via `_v2_compat`
  only (`DO_NOT_RANDOMIZE`, `SectionType`, edge-compat helper). No
  copy-paste from `tmos_randomizer/`.
- **Determinism**: `random.Random(seed)` only. All iteration over
  dicts/sets is sorted (materialize to `list[int]` before RNG selection).
  Each operator consumes RNG in a documented fixed order (in SPEC.md —
  e.g., "`swap_adjacent_screens` draws chapter → edge index, in that order").
- **No silent failures**: a rejected mutation is counted and attributed to
  its operator. A mutation that would leave the neighborhood invalid is
  reverted, not "repaired". `RepairRecord`s are NOT produced in v0.1.0 —
  the design point is that repair is unnecessary.
- **No un-seeded dict/set iteration**: operator target pools (section_type
  buckets, edge lists, leaf candidates) are materialized to sorted
  `list[int]` before any `rng.choice` / `rng.choices` call.
- **`MAX_ITERATIONS` hardcoded at 200 for v0.1.0**, documented in `SPEC.md`.
  A knob would bury the v0.1.0 question of whether local invariants alone
  work — the knob comes in v0.2.0.
- **Strategy version**: `"0.1.0"`. Bump on any behavior change (operator
  added/removed, invariant set changed, loop count changed), not on
  bug-fix-only commits.


## TESTS (tests/test_strategy_graph_mutate.py)

1. **Determinism**: two calls with the same seed produce byte-identical
   `Candidate.to_json()` strings.
2. **Local invariant preservation**: for the resulting `Candidate`, every
   screen's outgoing edges reference valid in-chapter indices (or the
   no-exit sentinel), and every bidirectional edge is symmetric. (Global
   metrics are the harness's job; this test is the operator-level contract.)
3. **DO_NOT_RANDOMIZE untouched**: every screen whose global index is in
   V2's `DO_NOT_RANDOMIZE` has the same 16 bytes on input and output.
4. **Building-entrance bytes preserved**: for every screen and every
   direction D, if the input's `screen_index_D` was `NAV_BUILDING_ENTRANCE`
   (`0xFE`), the output's `screen_index_D` is also `NAV_BUILDING_ENTRANCE`.
   (v0.1.0 does not touch stairway semantics; silent rewrites of `0xFE`
   would break `stairway_integrity` globally and are the most important
   operator bug to catch.)
5. **Actual mutation happened**: at least one screen's nav bytes differ
   from the input's. If every candidate is identity, the operators are all
   rejecting — a regression.
6. **Rejection accounting consistency**: `accepted + rejected <= MAX_ITERATIONS`.
   (Operators that return `None` are neither accepted nor rejected.)
7. **Section-type discipline**: for every logged swap, the two swapped
   screens had the same `section_type` (no accidental cross-type swaps).
8. **Edge walkability end-to-end**: run the Lab's existing
   `EdgeCompatibilityMetric` against the resulting `Candidate` and assert
   it returns `MetricStatus.PASS` with zero failures. This is the closed
   loop between the per-mutation local walkability check and the global
   metric — it proves the local invariant actually prevents
   tree-on-the-touching-edge and wall-on-the-touching-edge mutations from
   slipping through. If this test ever fails, the local check is wrong
   (or V2's walkability table drifted); either way it's a hard bug, not
   a "known limitation".
9. **Snapshot input rejected**: constructing the strategy and calling
   `generate()` with a `LabContext` whose `rom_bytes is None` raises
   `ValueError`. (We cannot verify walkability without the ROM; the
   strategy must refuse rather than silently skip the check.)

Fixtures: reuse `LabContext.from_rom(data/rom/TMOS_ORIGINAL.nes)`; skip the
test module with `pytest.skip` when the ROM isn't staged (match the
existing pattern in `tests/test_context_snapshot.py`).


## INTEGRATION POINTS

- `src/tmos_strategy_lab/strategies/__init__.py`: add `graph_mutate` to the
  import list so the decorator fires at package load.
- `src/README.md`: add a one-line entry to the "shipped strategies" list.
- **No** harness / benchmark / visualizer changes — existing surfaces
  already support arbitrary registered strategies.
- **No** V2 changes — the V2 bridge already accepts Lab strategies.
  `tmos_randomizer/strategies/organic/` stays untouched.


## EXPECTED METRIC OUTCOMES (research hypothesis, validated by benchmark)

Running `graph_mutate` across 100 seeds on the stock ROM should produce:

| Metric              | Expected              | Why                                                                 |
|---------------------|-----------------------|---------------------------------------------------------------------|
| reachability        | ~100% PASS            | Research claim — local invariants aim to preserve global connectivity |
| edge_compatibility  | ~100% PASS            | Per-mutation local check enforces this                              |
| bidirectional       | ~100% PASS            | Per-mutation local check enforces this                              |
| stairway_integrity  | **VARIES**            | Not in the local-invariant set — known hole, want it measured       |
| datapointer_compat  | 100% PASS             | CHR banks untouched (datapointer moves with the screen in swap)     |
| softlock            | **VARIES**            | Global property; may emerge even with local invariants holding      |
| required_content    | **VARIES**            | Global property; same as above                                      |
| variety             | HIGHER than identity  | 200 mutations per seed produce real shape variance                  |
| generation_time     | < 5s                  | 200 iterations × local-neighborhood check (ms-scale each)           |

The **VARIES** rows are the research result. They tell us whether local
invariant checking is strong enough on its own, or whether global
invariants need to join the per-mutation loop in v0.2.0.


## VALIDATION GATES (what /execute-prp must run)

```bash
# Lint + tests
python -m ruff check src/ tests/
python -m pytest tests/ components/harness/tests/ components/benchmark/tests/ components/visualizer/tests/ -q

# New strategy registers cleanly
python -c "from tmos_strategy_lab import list_strategies; assert 'graph_mutate' in list_strategies()"

# Harness smoke — single seed, stock ROM
PYTHONHASHSEED=13 python -m harness run \
    --strategy graph_mutate --seed 13 \
    --input data/rom/TMOS_ORIGINAL.nes \
    --run-label graph_mutate_smoke

# Determinism — two runs produce byte-identical candidate.json
PYTHONHASHSEED=13 python -m harness run --strategy graph_mutate --seed 13 \
    --input data/rom/TMOS_ORIGINAL.nes --output-dir /tmp/gm_d1
PYTHONHASHSEED=13 python -m harness run --strategy graph_mutate --seed 13 \
    --input data/rom/TMOS_ORIGINAL.nes --output-dir /tmp/gm_d2
diff /tmp/gm_d1/candidate.json /tmp/gm_d2/candidate.json && echo "DETERMINISTIC"

# A/B benchmark vs identity + tileshuffle — 20 seeds, research hypothesis table
PYTHONHASHSEED=0 python components/benchmark/scripts/run.py \
    --strategy identity --strategy tileshuffle --strategy graph_mutate \
    --seeds 20 --workers 4 --run-label graph_mutate_research \
    --input data/rom/TMOS_ORIGINAL.nes

# Visualize — render one graph-mutated candidate to confirm topology actually moved
python -m visualizer render-map \
    output/harness/*_graph_mutate_smoke/candidate.json \
    --rom data/rom/TMOS_ORIGINAL.nes --run-label graph_mutate_viz
python -m visualizer diff \
    output/harness/*_graph_mutate_smoke/candidate.json \
    output/harness/*_identity_*/candidate.json \
    --rom data/rom/TMOS_ORIGINAL.nes --run-label graph_mutate_vs_identity
```


## OUT OF SCOPE (explicit non-goals — do NOT add these)

- **No V2 changes.** The V2 bridge already accepts Lab strategies. Don't
  touch `tmos_randomizer/strategies/organic/`, don't touch V2's validation
  runner, don't "upgrade" V2 to call `graph_mutate`. That integration is a
  separate downstream task, not part of this PRP.
- **No plan / template / repair triangle.** No `MapPlan`, no `Template`,
  no bulk `EdgeRepair` pass. If you feel one of those patterns emerging,
  stop and re-read this spec.
- **No content mutation** (`top_tiles`/`bottom_tiles`). That's
  `tileshuffle`'s territory. `graph_mutate` only moves graph bytes (edges,
  and in the case of `swap_adjacent_screens`, whole screens as units).
- **No cross-chapter mutation.** Each chapter is its own mutation universe.
- **No operator-configuration knobs.** `MAX_ITERATIONS = 200`, uniform
  operator choice, fixed operator set of 3. Knobs are v0.2.0 work.
- **No RESULTS.md** as a deliverable — that's generated from the benchmark
  run after execution.
- **No changes to the 9 metrics, harness, benchmark, or visualizer.** If a
  change feels necessary, stop and discuss.


## SHARED DOCUMENTATION

- `REQUIREMENTS.md` §4.2 (LabStrategy interface), §4.3 (metrics), §4.6
  (SPEC.md obligation), §5 (tests optional for strategies), §6 N-1
  (determinism), §6 N-2 (failure observability), §6 N-5 (RepairRecord
  contract).
- `src/README.md` — "add a new strategy in < 30 min" recipe.
- `CLAUDE.md` "Project-wide rules (non-negotiable)" — determinism, no
  silent failures, reuse V2 never fork.
- V2 constants (via `_v2_compat`): `DO_NOT_RANDOMIZE`, `SectionType`,
  `NAV_BLOCKED` (`0xFF`), `NAV_BUILDING_ENTRANCE` (`0xFE`),
  edge-compatibility helper. Never hardcode the sentinel byte values —
  import them, so a future V2 revision that redefines them only touches
  `_v2_compat`.
- Existing archived PRPs: `PRPs/archive/2026-04-24_tileshuffle.md`,
  `PRPs/archive/2026-04-24_tmos-strategy-lab.md`.


## OTHER CONSIDERATIONS

- `data/rom/TMOS_ORIGINAL.nes` must exist (MD5
  `b3236db14c87f375e5f24a5b9b79f071`) for the harness and benchmark gates.
- Keep `impl.py` under ~150 lines and `operators.py` under ~200 lines. If
  either grows past that, the mutation loop has accidentally gained a
  second axis — stop and re-read OPERATORS + "Local invariants" above.
- The benchmark A/B gate is the research result, not a pass/fail on the
  strategy's implementation. If `summary.md` shows stairway_integrity or
  softlock failing on >50% of seeds, that's *data* — it tells us v0.2.0
  needs those in the local invariant set. The PRP succeeds as long as the
  harness/benchmark/visualizer gates themselves run to completion AND the
  local invariants are honored (tests 2, 3, 5, 6).
- If the mutation loop reports `accepted == 0` after MAX_ITERATIONS for
  some seed, surface it as an explicit breadcrumb flag — don't silently
  emit an identity candidate pretending nothing happened.
