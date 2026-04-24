# organic_port — Lab port of V2's organic strategy

## Purpose

Drive V2's `OrganicStrategy.preview_plan()` pipeline against a
deep-copied `GameWorld` + `rom_bytes` (no ROM patching), then package the
mutated world into a `Candidate`. Repairs surfaced by V2's organic
pipeline (blob merges, section consolidations, fallback relocations) are
captured as first-class `RepairRecord`s on the Candidate — visibility is
contractual (REQUIREMENTS.md §6 N-5).

## Algorithm (via V2)

V2 supplies the full organic pipeline:
1. **Plan**: `plan_randomization` → abstract per-section plan
2. **Shape**: `shape_world` → section shape grids
3. **Connect**: `connect_world` → inter-section connection hints
4. **Template extraction**: `extract_world_templates` — per-section grids from the pristine ROM
5. **Placement**: `plan_placement` — fit randomized content into templates
6. **Repair loop**: `run_world_repair` (up to `max_iterations` passes)
7. **Consolidation + aggressive merge**: `apply_section_consolidation`, `aggressive_blob_merge`
8. **Failure detection**: `detect_world_failures` (retry if critical > 0)
9. **Navigation rewrite**: `write_world_navigation` mutates `GameWorld` in place

All of the above lives in V2. The Lab's job is to:
- Deep-copy the input `GameWorld` so mutations don't leak across runs.
- Construct a minimal `RandomizerConfig` + `ValidationConfig` + `ValidationRunner`
  (V2's abstract base requires them).
- Invoke `OrganicStrategy.preview_plan(plan, world, rom_data)`.
- Extract `_last_repair_reports`, `_last_failure_reports`, and
  `_last_aggressive_stats` from the strategy instance and surface any
  actual-repair events as `RepairRecord`s.

## Constraints honored

- **Deterministic**: seed threads into V2's `plan_randomization(seed=seed)` and
  all internal RNGs. V2's organic is deterministic per seed by construction.
- **No silent failures**: V2 raises on fatal input; non-fatal repairs surface
  via the extracted breadcrumbs and Lab `RepairRecord`s.
- **ROM required**: `ctx.rom_bytes is None` → `ValueError`. Snapshot input
  works *only* if the snapshot carried `rom_bytes` (it doesn't today), so
  organic_port on a snapshot is rejected cleanly.

## Known limitations

- The v1 port may produce Candidates that fail reachability / edge metrics —
  that's informational, not a Lab bug. It means V2's organic pipeline produced
  a playable map with a known compromise. Those seeds get logged as failure
  exemplars in the benchmark summary.
- V2's internal API evolves faster than this spec. When V2 refactors and
  breaks `OrganicStrategy.preview_plan()`'s call chain, the Lab's adapter at
  `impl.py` updates — V2 stays untouched.
