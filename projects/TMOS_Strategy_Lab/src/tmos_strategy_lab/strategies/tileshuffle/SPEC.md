# tileshuffle — graph-preserving TileSection shuffle

## Purpose

Shuffle each screen's `(top_tiles, bottom_tiles)` pair within buckets of
`(chapter, section_type, datapointer)`. Every other byte on every screen —
navigation pointers, event, content, parent_world, objectset, datapointer,
colors, etc. — stays byte-identical to the input. The player sees the same
map topology with its tile art reshuffled.

## Why it exists

1. **Validate the 30-minute strategy template**: this is the first research
   strategy written end-to-end from `src/README.md`'s recipe. If friction hits
   here, the recipe gets revised.
2. **Exercise the metric battery on real randomization output**: `identity`
   trips the `preserves_baseline` shortcut and `organic_port` mutates the
   navigation graph, confounding tile-level and graph-level signals.
   `tileshuffle` isolates a single axis of change (tiles only) so the metrics
   produce a clean, interpretable signal.
3. **Research question: how often does naive tile shuffling break
   `edge_compatibility`?** After a shuffle, adjacent screens' walkability
   grids change; their shared edge may lose walkable overlap. The A/B
   benchmark vs `identity` quantifies that rate. A low rate ⇒ naive shuffle
   is a viable randomization mode. A high rate ⇒ justifies a future
   `tileshuffle_repaired` sibling that skips edge-breaking swaps and records
   `RepairRecord`s.

## Algorithm

1. `world = copy.deepcopy(ctx.game_world)` — never mutate the context.
2. `rng = random.Random(seed)` — scoped RNG instance; no module-level `random`.
3. For each chapter (sorted):
   - Build `buckets: dict[(section_type, datapointer), list[relative_index]]`.
   - Exclude screens whose global index is in `DO_NOT_RANDOMIZE`.
   - Sort bucket keys and bucket contents before shuffling (determinism).
4. For each bucket with ≥ 2 screens:
   - Collect `(top_tiles, bottom_tiles)` pairs in index order.
   - `rng.shuffle(pairs)`.
   - Reassign shuffled pairs back to the same indices.
5. Return a `Candidate` with `chapters` built via `WorldScreen.to_dict()` on
   the mutated world, `repairs=[]` (v1 is naive), and a `bucket_stats`
   breadcrumb summarizing per-chapter work.

## Constraints honored

- **Determinism** (REQUIREMENTS §6 N-1): integer seed, `random.Random(seed)`
  only, sorted dict iteration, sorted bucket contents. Two runs with the same
  `(seed, strategy_version)` produce byte-identical `candidate.json`.
- **Graph preservation**: the 14 non-tile ROM bytes on every screen remain
  equal to the input's. Only `top_tiles` and `bottom_tiles` move.
- **DO_NOT_RANDOMIZE honored**: screens in V2's exclusion set are neither
  source nor destination of any swap. Their tile pair stays untouched.
- **CHR safety**: bucketing by full `datapointer` (not `chr_index`) means the
  TileSection indices resolve to the same ROM addresses for every screen in
  a bucket — `get_bank_offset` (V2 renderer) uses datapointer value ranges,
  not the low 6 bits alone, so `chr_index` equality is insufficient.
- **No silent failures** (REQUIREMENTS §6 N-4/N-5): v1 never skips swaps
  silently. If a future variant adds repairs, each skipped swap becomes a
  `RepairRecord(what, why, screen_ids, rule)` on the Candidate.

## Known limitations

- **Edge compatibility may break**: swapping tiles can produce adjacent
  screens whose shared edge loses walkable overlap. Whether and how often
  this happens is the research question — v1 reports failures honestly
  instead of repairing them.
- **Singleton buckets don't shuffle**: under the safer
  `(section_type, datapointer)` bucketing, some buckets have only 1 screen
  and skip the shuffle. That's expected; those screens retain their original
  tile pair.
- **Visual incongruity within a single datapointer**: two screens sharing a
  datapointer could still have subtly different intended palettes
  (`worldscreen_color`, `sprites_color`). We don't touch those bytes, so the
  palette-vs-tile mismatch is possible. In practice this is cosmetic, not a
  playability bug.
- **`objectset` not randomized**: enemies stay on their original screens.
  That's deliberate for v1 — mixing tile and objectset shuffling would
  confound research signals. A future `tileshuffle+objectshuffle` combo can
  stack the two once both are individually understood.

## Promotion readiness

Per REQUIREMENTS §7, a Lab strategy is ready for V2 promotion when it
reaches target metrics across ≥500-seed benchmarks. `tileshuffle` is a
research strategy; it's unlikely to be promoted as-is (V2 already has
richer randomization via `classic` and `organic`). Its value is as a
baseline + research tool within the Lab, not a production candidate.
