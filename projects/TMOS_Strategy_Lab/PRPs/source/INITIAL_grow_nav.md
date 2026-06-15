<!--
  INITIAL_grow_nav.md — intent doc for /generate-prp (sibling spec).

  Run:  /generate-prp PRPs/source/INITIAL_grow_nav.md
  Then: /execute-prp PRPs/<slug>.md

  This is a NEW feature distinct from the graph_mutate intent in INITIAL.md.
  It extends the existing `grow` strategy so its output is actually navigable.
  Context: this spec was authored from a cross-project diagnostic session in
  TMOS_Randomizer_V2 (2026-06-15). See that project's
  reports/2026-06-15_phase0-randomizer-diagnostic-baseline.md and
  .claude-system/CHANGELOG.md for the evidence behind it.
-->

## FEATURE

Extend the existing Lab **`grow`** strategy so its `Candidate` is **navigable**,
not just edge-satisfiable. Today `grow` (strategies/grow/impl.py) produces a
per-section grid `GrownSection.grid: {(x, y): screen_index}` where every
grid-adjacency is edge-valid by construction (broken_edges == 0), but its
`generate()` returns the chapters **unchanged** — the grown layout lives only in
the returned `ChapterGrowth`, never written to `screen_index_*` nav bytes (see the
explicit "nav bytes are NOT written" notice at impl.py ~line 920-938). So grow's
output is currently un-navigable: a downstream consumer that trusts its nav sees
the stock graph, not the grown one.

This feature writes the grown layout into the Candidate's nav bytes:

1. **Intra-section navigation** — for each `GrownSection`, wire grid-adjacent
   cells bidirectionally (`A` at `(x,y)`, `B` at `(x+1,y)` → `A.screen_index_right
   = idx(B)`, `B.screen_index_left = idx(A)`). Edges with no grid neighbor are set
   to `NAV_BLOCKED` (0xFF), **except** existing `NAV_BUILDING_ENTRANCE` (0xFE),
   which is preserved. Because grow guarantees aligned walkable edges between grid
   neighbors, this nav is physically valid by construction.
2. **Inter-section linking (HYBRID — matches how the ROM actually works)** — connect
   the grown sections so each chapter is a single reachable component, not islands.
   The original game uses THREE distinct mechanisms; grow must use all three, in the
   right proportion (verified against GameAnalysis2 ROM_VERIFIED data, see SHARED
   DOCUMENTATION):
   - **(a) Walk-across exits — the MAJORITY.** Most section-to-section connectivity
     is ordinary directional nav (exit bytes 4-7, values 0x00-0xFD) between
     edge-adjacent screens. These REQUIRE aligned walkable edges. So a boundary link
     is a frontier cell of section S whose outward neighbor hosts a frontier cell of
     section T **with a real aligned walkable edge** — verify with grow's existing
     `_candidate_fits` / `_edges_aligned`. (This is exactly what the v0.1.0 nav-write
     skipped, producing the 14 broken inter-section edges found 2026-06-15.)
   - **(b) Stairways — SPARSE, specific (dungeon/interior entrances).** Detect from
     the ROM: a screen is a stairway iff Event byte (offset 15) == 0x40; its Content
     byte (offset 2) is the chapter-relative destination. These WARP — no edge
     alignment needed. PRESERVE existing stairway pairs; do not invent or break them.
     One-way ("orphan") stairways are legitimate (Ch2 has 5, Ch5 has 6) — do NOT
     force bidirectionality on them.
   - **(c) Time doors — exactly 2 per chapter, PRESERVE.** Detect from the ROM:
     Content byte == 0xC0 (the ROM uses ONLY 0xC0 — variants 0xC7/0xD7 appear zero
     times despite being in V2's detection set). These cross PRESENT↔PAST. Never
     route ordinary walk-across nav across eras.
   Without (a) edge-verified, chapters keep the broken edges. Without (b)/(c)
   preserved, dungeons/eras become unreachable.
3. **Tile-swap application** — grow records tile swaps for some placements
   (`GrownSection.overrides` / swap records: `screen_idx → (new_top_tiles,
   new_bottom_tiles)`). These MUST be applied to the emitted screen dicts, or the
   edges won't align as grow computed them. A placement is only valid with its
   swap applied.

A reference implementation of the **intra-section nav rule** already exists and is
unit-tested in the V2 project at
`tmos_randomizer/strategies/grow_nav.py::apply_grid_navigation` (3 passing tests in
`tests/test_strategies/test_grow_nav.py`). Port the *logic* (do not import V2
strategies — Lab reuses V2 `core`/`io`/`validation` via `_v2_compat` only, never V2
strategies). The reference is the spec for the intra-section half; inter-section
linking is new design work for this PRP.

It exists to answer one Lab question: **does grow's by-construction edge validity,
once turned into real navigation plus section linking, yield worlds that are
reachable no-worse-than the stock ROM** — i.e. does it beat the organic strategy,
which regresses reachability (V2 baseline: organic 0/5, Ch2 66%→4-39%)?


## DELIVERABLE

Changes within the existing grow subpackage (keep files under the Lab's size
limits — impl.py guidance is ~150 lines per concern; split if a file balloons):

```
src/tmos_strategy_lab/strategies/grow/
├── SPEC.md        # UPDATE: document nav-writing, inter-section linking, tile-swap
│                  #   application, RNG order, and remaining known limitations
├── navwrite.py    # NEW: grid -> nav (intra-section) + inter-section linking +
│                  #   tile-swap application. Pure-ish; operates on the grown
│                  #   ChapterGrowth + the deepcopied world.
└── impl.py        # UPDATE: generate() calls navwrite to emit a navigable
                   #   Candidate; bump strategy_version (0.1.0 -> 0.2.0)
```

Plus a test module:

```
tests/test_strategy_grow_navwrite.py
```

Per REQUIREMENTS.md §5 strategies are not required to be tested, but — exactly as
with `graph_mutate` — grow's whole new value proposition is "navigable by
construction", so the invariant tests below are non-optional.


## ALGORITHM (additions to grow's existing generate())

After `grow_chapter(...)` returns a `ChapterGrowth` for a chapter (unchanged
upstream):

1. **Apply tile-swaps**: for every `GrownSection`, for each swapped placement in
   `section.overrides` (`screen_idx → (new_top, new_bottom)`), set the emitted
   screen dict's `top_tiles`/`bottom_tiles` accordingly. Native (non-swapped)
   placements keep their original tile bytes.
2. **Write intra-section nav** (port of `apply_grid_navigation`): for each section
   grid `{(x,y): idx}`, for each placed cell and each direction in a fixed order
   (`right, left, down, up` — document the order in SPEC.md for determinism):
   - neighbor cell present in grid → write that neighbor's index (bidirectional
     falls out because both cells are processed);
   - else → write `NAV_BLOCKED`, unless the current byte is `NAV_BUILDING_ENTRANCE`
     (preserve it).
3. **Link sections** (new, HYBRID): join the per-section blobs into one component
   using the three ROM mechanisms above:
   - **(a) Walk-across:** candidate boundary pair = a placed cell `c_S` in section S
     with an out-of-section grid direction whose target world position hosts a placed
     cell `c_T` of another section T, **AND a real aligned walkable edge exists**
     between them (reuse `_edges_aligned` / `_candidate_fits`). Write the boundary nav
     bidirectionally. This is the primary connector.
   - **(b) Preserve stairways:** before/while linking, identify stairway screens
     (Event offset-15 == 0x40) and keep their Content (offset-2) destination intact.
     Stairways count toward chapter connectivity WITHOUT needing a walkable edge.
     Treat them as fixed warp edges in the connectivity graph; never rewrite a 0x40
     screen's Content or repurpose it. One-way orphans are valid — don't force pairs.
   - **(c) Preserve time doors:** screens with Content == 0xC0 are time doors; keep
     them. They provide the PRESENT↔PAST link. Never write ordinary nav across eras
     (era via `PAST_SCREEN_INDICES`, step below).
   - Choose walk-across links (RNG, documented order) until the chapter's
     section-graph — counting stairway + time-door warp edges — is one component.
   - If full connectivity is unreachable, **surface `unlinked_sections` as a
     first-class breadcrumb** — never silently emit an islanded chapter (REQUIREMENTS
     §6 N-2).
4. **Era safety**: era is determined by `PAST_SCREEN_INDICES` (chapter-relative index
   sets, via `_v2_compat` from V2 `enums.py`) — **NOT `parent_world`** (deprecated;
   0x10/0x20/0x30/0x53/0x55/0x9F/0xD0/0xF0/0x69 are mixed-era zones). A walk-across or
   stairway link must never connect a PRESENT screen to a PAST screen except through a
   time-door (Content==0xC0) screen.
5. **Excluded / special screens**: screens whose global index is in V2's
   `DO_NOT_RANDOMIZE` (via `_v2_compat`) keep their stock bytes; never rewrite their
   nav. Preserve all `NAV_BUILDING_ENTRANCE` (0xFE), stairway (Event 0x40), and
   time-door (Content 0xC0) screens.
6. Emit the Candidate from the **mutated** world (`[s.to_dict() for s in
   world.chapters[n].screens]`), with breadcrumbs extended:
   `breadcrumbs["grow_nav"] = {"walkacross_links": ..., "stairways_preserved": ...,
   "time_doors_preserved": ..., "unlinked_sections": [...],
   "blocked_edges_written": ..., "swaps_applied": ...}`.


## CONSTRAINTS (non-negotiable, from CLAUDE.md + REQUIREMENTS)

- **Determinism is load-bearing**: same seed + same strategy version → identical
  bytes. Scoped `random.Random(seed)` only; materialize dict/set iteration to
  sorted `list` before any RNG draw; document each new RNG consumption order in
  SPEC.md. Bump `strategy_version` to `"0.2.0"` (behavior change).
- **V2 reuse, never fork**: sentinels (`NAV_BLOCKED` 0xFF, `NAV_BUILDING_ENTRANCE`
  0xFE), `DO_NOT_RANDOMIZE`, `SectionType`, walkability/edge helpers come in via
  `_v2_compat` only. Never hardcode the sentinel byte values. Never import V2
  *strategies* (only `core`/`io`/`validation` through `_v2_compat`).
- **No silent failures**: an unlinkable section is reported, not hidden. A swap
  that can't apply is a hard error, not a skip.
- **Require `ctx.rom_bytes is not None`** — fail loud with `ValueError` (same as
  graph_mutate / organic_port): edge/walkability checks need raw ROM.
- **`copy.deepcopy(ctx.game_world)`** — never mutate shared context (spawn safety).


## TESTS (tests/test_strategy_grow_navwrite.py; skip if ROM not staged)

1. **Determinism**: two calls, same seed → byte-identical `Candidate.to_json()`.
2. **Navigability written**: at least one screen's nav bytes differ from input
   (not an identity emit).
3. **Intra-section adjacency correct**: for a known grown section, grid neighbors
   are wired bidirectionally and non-neighbor edges are `NAV_BLOCKED` (or preserved
   `0xFE`). (Mirror the three V2 `test_grow_nav.py` cases.)
4. **Building entrances preserved**: every input `0xFE` direction byte is still
   `0xFE` on output.
5. **DO_NOT_RANDOMIZE untouched**: those screens' 16 bytes are identical in/out.
6. **Edge walkability end-to-end**: run the Lab's `EdgeCompatibilityMetric` on the
   Candidate → `PASS`, zero failures (closes the loop: grid edge-validity survives
   nav-writing).
7. **Chapter connectivity**: from screen 0, BFS over real (non-sentinel) nav edges
   reaches every section that the breadcrumb does NOT list as `unlinked` —
   i.e. linked sections are actually reachable.
8. **Reachability no-worse-than baseline**: per chapter, reachable-screen count
   (BFS from 0, excluding 0xFE/0xFF) is `>=` the stock world's count. This is the
   exact gate V2's `lab_adapter` and the V2 differential oracle enforce; grow must
   meet it to be shippable.
9. **Snapshot input rejected**: `rom_bytes is None` → `ValueError`.
10. **No new broken inter-section edges**: run the Lab `EdgeCompatibilityMetric`
    (test 6) AND assert broken-edge count is `<=` the stock ROM's count. The 14
    broken edges from v0.1.0 inter-section links must be gone (walk-across links now
    edge-verified).
11. **Stairways & time doors preserved**: every input screen with Event==0x40 keeps
    its Content destination byte; every input screen with Content==0xC0 still has
    Content==0xC0 on output. Cross-check the detected stairway pairs / time-door
    screens against the GameAnalysis2 authoritative extracts
    (`stairway_pairs.json`, `time_door_screens.json`) — counts and indices must match.
12. **Era isolation**: no walk-across or stairway link connects a PRESENT screen to a
    PAST screen (per `PAST_SCREEN_INDICES`) except via a Content==0xC0 time door.


## INTEGRATION POINTS

- `src/tmos_strategy_lab/strategies/__init__.py`: ensure `grow` is imported so its
  `@register_strategy` fires (the assessment found grow is self-registering but NOT
  in the package import list — add it). `list_strategies()` must include `grow`.
- `src/README.md`: update the grow entry to note it now emits navigable output.
- **V2 side (out of scope for THIS PRP, noted for the downstream task):** once grow
  emits nav, V2 needs only a ~3-line `GrowAdapter(LabAdapterStrategy)` with
  `lab_strategy_name = "grow"`; the existing `_stamp_candidate_onto_world` already
  copies `screen_index_*`, and `preview_plan`'s ≥-baseline reachability gate already
  guards it. Do not make V2 changes here.


## VALIDATION GATES (what /execute-prp must run)

```bash
python -m ruff check src/ tests/
python -m pytest tests/ -q
python -c "from tmos_strategy_lab import list_strategies; assert 'grow' in list_strategies()"

# Harness smoke + determinism (stock ROM)
PYTHONHASHSEED=42 python -m harness run --strategy grow --seed 42 \
    --input data/rom/TMOS_ORIGINAL.nes --run-label grow_nav_smoke
PYTHONHASHSEED=42 python -m harness run --strategy grow --seed 42 \
    --input data/rom/TMOS_ORIGINAL.nes --output-dir /tmp/grow_d1
PYTHONHASHSEED=42 python -m harness run --strategy grow --seed 42 \
    --input data/rom/TMOS_ORIGINAL.nes --output-dir /tmp/grow_d2
diff /tmp/grow_d1/candidate.json /tmp/grow_d2/candidate.json && echo DETERMINISTIC

# A/B benchmark vs organic_port + identity — does grow win on reachability?
PYTHONHASHSEED=0 python components/benchmark/scripts/run.py \
    --strategy identity --strategy organic_port --strategy grow \
    --seeds 20 --workers 4 --run-label grow_nav_research \
    --input data/rom/TMOS_ORIGINAL.nes
```


## OUT OF SCOPE (explicit non-goals)

- **No V2 changes** in this PRP. The V2 `GrowAdapter` is a separate downstream task.
- **No time-door (PAST↔PRESENT) wiring** beyond preserving stock 0xFE semantics —
  that's a follow-up; record reserved time-period bridges as breadcrumbs, don't
  invent them.
- **No new harness/benchmark/visualizer/metric changes.** Existing surfaces support
  any registered strategy.
- **No content randomization beyond grow's existing tile-swaps.** Nav + the swaps
  grow already decided; nothing more.


## SHARED DOCUMENTATION

- `REQUIREMENTS.md` §4.2 (LabStrategy interface), §4.3 (9 metrics), §4.6 (SPEC.md
  obligation), §6 N-1 (determinism), §6 N-2 (failure observability).
- `strategies/grow/SPEC.md` + `impl.py` (`GrownSection.grid` ~line 148,
  `ChapterGrowth.sections` ~line 159, `_edges_aligned`/`_candidate_fits`
  ~line 191-247, the "nav not written" notice ~line 920-938).
- Reference intra-section nav logic: V2
  `tmos_randomizer/strategies/grow_nav.py` (+ its 3 tests). Port logic, don't import.
- V2 constants via `_v2_compat`: `NAV_BLOCKED`, `NAV_BUILDING_ENTRANCE`,
  `DO_NOT_RANDOMIZE`, `SectionType`, `PAST_SCREEN_INDICES`, walkability/edge-compat helpers.
- Archived PRPs for shape: `PRPs/archive/2026-04-24_tileshuffle.md`.
- **AUTHORITATIVE warp data (ROM_VERIFIED)** — the main TMOS knowledge source at
  `C:\claude-workspace\GameAnalysis2\analysis_games\TMOS\`:
  - `game_specs/systems/world/navigation/README.md` — exit bytes, stairway system.
  - `game_specs/systems/world/time_travel/README.md` — time doors (all Content=0xC0;
    2/chapter), era-by-index (NOT parent_world), per-chapter stairway counts.
  - `game_specs/systems/world/map_layout/stairway_pairs.json` — extracted pairs +
    orphans (one-way) per chapter.
  - `game_specs/systems/world/map_layout/time_door_screens.json` — the 10 time-door
    screens with indices.
  - `game_specs/systems/world/map_layout/screen_exclusions.json` — DO_NOT_RANDOMIZE +
    `past_screen_indices`.
  Detect stairways/time-doors from the ROM at runtime (Event==0x40, Content==0xC0);
  use these JSONs only as the test oracle (test 11), not a runtime dependency.


## OTHER CONSIDERATIONS

- `data/rom/TMOS_ORIGINAL.nes` must exist (MD5 `b3236db14c87f375e5f24a5b9b79f071`).
- The benchmark A/B is the research result, not a pass/fail. The headline question:
  does grow's reachability (test 8) hold ≥ baseline across seeds where organic_port
  regresses? If grow passes test 8 broadly, it becomes the V2 production candidate.
- If inter-section linking can't connect a chapter for some seed, emit
  `unlinked_sections` and let the benchmark measure how often — that frequency is
  itself the signal for whether linking needs more operators in v0.3.0.
