# graph_mutate — local-invariant graph mutation

## Purpose

Treat the stock navigation graph as the starting state. For each of
`MAX_ITERATIONS = 200` iterations, pick one of three mutation operators
uniformly at random, propose a small, locally-scoped change, and either
accept (commit) or revert (undo) the change based on a per-iteration local
invariant check. The accumulated accepted mutations form the output
`Candidate`. No plan, no template, no bulk repair pass: the world is
playable at t=0 and stays playable by construction after every single
accepted step.

## Why it exists

1. **Test whether local invariants can replace V2's global repair pass.**
   V2's `organic` strategy runs a `plan → template → repair` triangle.
   `graph_mutate` is the counter-bet: if every step preserves
   carefully-chosen *local* invariants, the result is globally playable
   without any repair pass. The benchmark quantifies whether that bet
   holds for the in-scope metrics (edge compatibility, bidirectionality,
   reachability) and how badly it misses on the out-of-scope ones
   (stairway integrity, softlock, required content).

2. **Give the Lab its first genuine shape-varying strategy.** `identity`
   is a baseline, `tileshuffle` only permutes content, `organic_port`
   wraps V2's pipeline. `graph_mutate` is the first Lab strategy whose
   output can legitimately surprise a player: screen-to-screen edges move.

3. **Produce the Lab's first "zero repairs" Candidate by design.**
   `graph_mutate` never emits a `RepairRecord`. Where other strategies
   fix broken mutations post-hoc, `graph_mutate` reverts the broken
   proposal and tries another. Any run with a non-empty `repairs` list
   is a bug.

## Algorithm

1. If `ctx.rom_bytes is None` → raise `ValueError` (snapshot input cannot
   be walkability-checked; see `GraphMutateStrategy.generate`).
2. If V2 tile pathfinding is unreachable (`PATHFINDING_AVAILABLE = False`)
   → raise `RuntimeError`.
3. `world = copy.deepcopy(ctx.game_world)` — never mutate the context.
4. `rng = random.Random(seed)` — scoped RNG instance; no module-level
   `random`.
5. `baseline_asymmetry = build_baseline_asymmetry(world)` — snapshot the
   set of pre-existing asymmetric edges in the stock graph (rivers,
   cliffs, forced story gates). Tolerated during invariant checks;
   mutation-introduced asymmetry is the only kind rejected.
6. `grid_cache = {}` — walkability-grid cache keyed by
   `(top_tiles, bottom_tiles, datapointer & 0xFF)`. Mutations never
   touch those bytes, so grids cached on first request stay valid for
   the entire run.
7. For each iteration in `range(MAX_ITERATIONS)`:
   - `op_name = rng.choice(op_names)` — uniform over
     `["prune_deadend", "reroute_edge", "swap_adjacent_screens"]` in
     sorted name order (stable RNG consumption).
   - `mutation = operators[op_name](world, rng)` — returns
     `Mutation(apply, undo, ch_num, affected)` or `None` if the operator
     has nothing applicable.
   - If `None`: record as a `no_op` for that operator.
   - Otherwise: `mutation.apply()`, check local invariants on
     `affected ∪ 4-neighbors`. If pass → commit (accept count bumps). If
     fail → `mutation.undo()` (reject count bumps).
8. Build the `Candidate`: `chapters` via `WorldScreen.to_dict()` on the
   mutated world, `repairs=[]`, `breadcrumbs` containing
   `graph_mutate_stats` with `accepted`, `rejected`, and per-operator
   attempts / accepts / rejects / no_op counts.

## Operators (v0.1.0)

### `swap_adjacent_screens`

Pick a real graph edge `(A, D, B)` where A and B are in the same chapter,
share the same `section_type`, and neither is in `DO_NOT_RANDOMIZE`. Swap
the two screen objects between positions `idx(A)` and `idx(B)`, and
rewrite every `screen_index_*` byte in the chapter so references to
`idx(A)` become `idx(B)` and vice versa. Sentinel bytes (`NAV_BLOCKED`,
`NAV_BUILDING_ENTRANCE`) are NEVER rewritten. Affected set: `{A, B}` plus
every screen whose nav bytes contained `idx(A)` or `idx(B)` before the
swap.

### `reroute_edge`

Pick a screen `A` with a real outgoing edge in direction `D` to an
existing neighbor `old_B`. Pick a new target `C` of the same
`section_type` as `old_B`, chapter-local, `DO_NOT_RANDOMIZE`-filtered,
distinct from `A` and `old_B`. Set `A.screen_index_D = idx(C)`. If the
original edge was bidirectional, also set `C.screen_index_{inv(D)} =
idx(A)` and clear the stale reverse edge on `old_B` with `NAV_BLOCKED`.
Directions where the current byte is `NAV_BUILDING_ENTRANCE` are never
picked (those encode stairway semantics, out of scope for v0.1.0).

### `prune_deadend`

Find a "one-way leaf" L: a screen with all four `screen_index_*` bytes
equal to `NAV_BLOCKED` (strict — `NAV_BUILDING_ENTRANCE` disqualifies,
since the screen exits via V2's Content behavior) and exactly one
incoming real edge from a parent `P` via direction `D`. Set
`L.screen_index_{inv(D)} = idx(P)` so the leaf becomes bidirectional
with its parent. Semantics: "prune" = remove the softlock potential by
giving the player a return path, not by deleting the screen.

## Local invariants (checked after apply, before accept)

Restricted to `affected_screens ∪ their 4-neighbors`:

1. **Valid indices**: every `screen_index_*` byte references a valid
   in-chapter index OR equals `NAV_BLOCKED` OR equals
   `NAV_BUILDING_ENTRANCE`.
2. **Bidirectionality with baseline tolerance**: every real edge `S→D→T`
   either has `T.screen_index_{inv(D)} = idx(S)` OR matches an entry in
   `baseline_asymmetry` (pre-existing stock-ROM asymmetry).
   Mutation-introduced asymmetry is rejected.
3. **Tile-level walkability**: every affected real edge passes V2's
   walkability helper — both sides of the touching edge have ≥1
   walkable tile. This is the invariant that catches trees, walls,
   water, cliffs, and every other non-walkable tile on a shared edge.
   Backed by `is_walkable(tile_id)` from V2's canonical collision table.

(Sentinel preservation — no `NAV_BUILDING_ENTRANCE` byte is ever
overwritten — is enforced structurally by the operators, not re-checked
per iteration. Test #4 in the strategy's test module is the end-to-end
safety net.)

## Constraints honored

- **Determinism** (REQUIREMENTS §6 N-1): integer seed,
  `random.Random(seed)` only, all target pools materialized as sorted
  `list[int]` before any `rng.choice`. Operator names iterated in
  sorted order. Two runs with the same `(seed, strategy_version)`
  produce byte-identical `candidate.json`.
- **DO_NOT_RANDOMIZE honored**: screens in V2's exclusion set are never
  picked as operands and never written as new targets. All 16 of their
  ROM bytes are preserved end-to-end.
- **Building-entrance bytes are sacred**: any direction byte that is
  `NAV_BUILDING_ENTRANCE` (`0xFE`) on input stays `NAV_BUILDING_ENTRANCE`
  on output. Stairway semantics are out of scope for v0.1.0.
- **V2 reuse, not fork**: `NAV_BLOCKED`, `NAV_BUILDING_ENTRANCE`,
  `DO_NOT_RANDOMIZE`, `SectionType`, `build_walkability_grid`, and
  `get_walkable_edge_positions` all come in via the pre-existing
  `tmos_strategy_lab._v2_compat` adapter. No new symbols added. No V2
  code copy-pasted.
- **No silent failures** (REQUIREMENTS §6 N-2/N-5): rejected mutations
  are counted and attributed to the operator that proposed them.
  `RepairRecord`s are NEVER emitted; broken proposals are reverted.

## RNG consumption order (documented for determinism)

Each `generate()` call consumes RNG tokens in this fixed sequence:

1. For each of `MAX_ITERATIONS` iterations: one `rng.choice(op_names)` to
   pick the operator.
2. Then, within the operator's `propose`, operator-specific draws:
   - `swap_adjacent_screens`: one `rng.choice(candidates)` where
     `candidates` is the sorted list of all `(ch_num, src_rel,
     direction)` triples with a qualifying edge.
   - `reroute_edge`: one `rng.choice(candidates)` for the source edge,
     then one `rng.choice(targets)` for the new neighbor.
   - `prune_deadend`: one `rng.choice(candidates)` where `candidates` is
     the sorted list of `(ch_num, L_rel, P_rel, direction_from_parent)`
     quads.

Any reordering of operator-internal draws bumps `strategy_version`.

## Known limitations

- **Swaps involving pre-existing asymmetric screens are always rejected.**
  `baseline_asymmetry` is keyed by `(chapter, source_relative_index,
  direction)`. Swapping moves the screen to a new position, so its
  pre-existing asymmetry no longer matches the baseline key — the
  invariant check rejects the swap. This is conservative: swaps that
  would merely relocate pre-existing asymmetry are rejected rather than
  tolerated. Safe, but reduces the swap accept rate.

- **Global invariants not enforced per-step.** `stairway_integrity`,
  `softlock`, `required_content`, `reachability` are all global
  properties checked only by the final harness metric battery. The
  research question is exactly *how often* these fail on `graph_mutate`
  output — that's the data v0.2.0 would use to decide which global
  invariants to promote into the per-mutation loop.

- **No operator-configuration knobs in v0.1.0.** `MAX_ITERATIONS = 200`,
  uniform operator choice, fixed 3-operator set. Knobs are v0.2.0
  research.

- **Cross-chapter mutations are out of scope.** Each chapter is its own
  mutation universe. Cross-chapter shape exchange is a separate
  research direction.

## Promotion readiness

Per REQUIREMENTS §7, a Lab strategy is ready for V2 promotion when it
reaches target metrics across ≥500-seed benchmarks. `graph_mutate` is a
research strategy — its v0.1.0 is designed to *produce data about where
local invariants are insufficient*, not to ship as a production
randomizer. Promotion is likely only after v0.2.0+ folds more global
invariants into the per-mutation loop.
