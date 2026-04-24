# TMOS Strategy Lab — Requirements

**Status**: Draft, pre-implementation
**Owner**: TMOS_AI project
**Relates to**: `/projects/TMOS_Randomizer_V2` (production consumer), `/knowledge/systems/randomization-strategy.md` (authoritative rulebook)
**Last Updated**: 2026-04-23

---

## 1. Purpose

A dedicated research sandbox for **inventing, prototyping, and evaluating map randomization strategies** for The Magic of Scheherazade — decoupled from the production randomizer.

TMOS_Randomizer_V2 is about *shipping a working randomizer*. TMOS_Strategy_Lab is about *figuring out what the randomizer should actually do*. Strategies that prove themselves in the Lab get promoted to V2 via a documented handoff — nothing else.

---

## 2. Why It Must Be Separate

Mixing research and production has already shown friction:

| Concern | V2 (production) | Lab (research) |
|---------|-----------------|----------------|
| Code quality bar | Typed, tested, lint-clean | "Good enough to measure" |
| Dependency on ROM patching | Required | Not required |
| UI/CLI surface | Required | Optional |
| Experimentation speed | Slow (regression risk) | Fast (throwaway welcome) |
| Output | Patched ROMs for players | Data, charts, reports for humans |
| Failure tolerance | Low | High (the point is to fail fast) |

Keeping them apart means V2 stays stable while the Lab stays nimble.

---

## 3. Scope

### 3.1 In Scope

- Strategy invention: brainstorm, prototype, iterate on new randomization algorithms
- Evaluation harness: run a strategy N times, score its outputs, aggregate stats
- Comparative benchmarking: A/B multiple strategies on the same metrics
- Map generation only — producing in-memory `GameWorld` candidates, not patched ROMs
- Visualization: render maps, distribution charts, reachability heatmaps
- Documentation of *why* a strategy works or doesn't (post-mortems)

### 3.2 Out of Scope

- ROM patching (V2 owns byte-level writing)
- UI for end users (V2 owns the web/CLI surface)
- Backwards compatibility guarantees (research code may be rewritten weekly)
- Production-grade error handling (clear traceback > graceful degradation)
- Cross-chapter/meta-game features (chapter scoping only)

---

## 4. Core Requirements

### 4.1 Data Access

| # | Requirement | Source |
|---|-------------|--------|
| D-1 | Read raw ROM bytes from `/rom-files/` | Shared path |
| D-2 | Parse WorldScreens, TileSections, ObjectSets, DataPointers | Reuse V2's `core/` and `io/` modules — vendor via path, do not fork |
| D-3 | Access the full tile collision table (walkable / collidable / hazard) | `/knowledge/systems/randomization-strategy.md` Part 2 |
| D-4 | Access DataPointer↔ObjectSet compatibility tables | `/knowledge/systems/datapointer-objectset.md` |
| D-5 | Access stairway pair registry | `/knowledge/systems/navigation.md` §Stairway |

**Must not**: duplicate the V2 parser. Import or symlink; never copy-paste.

### 4.2 Strategy Plugin Interface

Lightweight, research-friendly — *not* V2's production strategy interface.

```python
class LabStrategy(Protocol):
    name: str
    description: str

    def generate(self, ctx: LabContext, seed: int) -> Candidate:
        """Produce one candidate map. May mutate nothing outside the returned Candidate."""
```

Where:
- `LabContext` wraps the parsed ROM and knowledge-base constants
- `Candidate` carries: per-chapter screen assignments, navigation graph, TileSection choices, stairway pairs, and whatever diagnostic breadcrumbs the strategy wants to expose

**Must**: Strategies can be added without modifying the harness. Discovery via entry-points or a simple registry.

### 4.3 Evaluation Harness

Run a strategy against the ROM and score the result. Required metrics:

| Metric | Description | Pass Condition |
|--------|-------------|----------------|
| Reachability | % of intended screens reachable from chapter start | 100% for v1 |
| Edge-compat violations | Count of adjacent screen pairs with mismatched walkability | 0 |
| Bidirectional violations | A→B without B→A (excluding intentional maze asymmetry) | 0 |
| Stairway integrity | All Event=0x40 pairs point at each other | 0 broken |
| DataPointer compatibility | Screens using ObjectSet incompatible with their DataPointer | 0 |
| Softlock count | Rooms the player can enter but not leave | 0 |
| Required-content reachability | Mosques, bosses, shops reachable from start | 100% |
| Variety | Distribution spread across sections (entropy-based) | Strategy-defined target |
| Generation time | Wall-clock per seed | < 2s for v1 |

This directly implements the self-validation directive from user memory: every candidate passes navigability rules before being reported as a success.

### 4.4 Benchmark Runner

| # | Requirement |
|---|-------------|
| B-1 | Run a strategy across N seeds (default 100), collect per-seed metrics |
| B-2 | Emit a summary report (Markdown + JSON) with aggregates, failure modes, seed examples |
| B-3 | Support side-by-side comparison of 2+ strategies on the same seed set |
| B-4 | Reproducible: same seed + same strategy version → identical output |
| B-5 | Parallelizable: seeds run independently, fan out across cores |

### 4.5 Visualization

| # | Requirement |
|---|-------------|
| V-1 | Render a candidate map as an image (per-chapter grid with tile art) — reuse V2's renderer if feasible |
| V-2 | Plot metric distributions across a seed sweep (histogram / CDF) |
| V-3 | Diff visualization: two candidates side-by-side with coloring on differences |
| V-4 | Optional: reachability heatmap overlay |

### 4.6 Documentation Obligations per Strategy

Every strategy lives in `strategies/[name]/` with:

- `SPEC.md` — algorithmic description, constraints honored, known limitations
- `impl.py` (or equivalent) — the implementation
- `RESULTS.md` — benchmark output, generated or hand-updated, dated
- `NOTES.md` (optional) — post-mortem, dead-ends, what to try next

No undocumented strategies. If it's not specced, it doesn't count.

---

## 5. Proposed Structure

```
/projects/TMOS_Strategy_Lab/
├── REQUIREMENTS.md            # This file
├── README.md                  # Quickstart for researchers
├── pyproject.toml             # Own deps; depends on V2 as editable install or path import
├── src/tmos_strategy_lab/
│   ├── context.py             # LabContext (ROM + knowledge loader)
│   ├── candidate.py           # Candidate dataclass
│   ├── registry.py            # Strategy discovery
│   ├── harness.py             # Single-seed runner + validation
│   ├── bench.py               # Multi-seed/comparative runner
│   ├── metrics/               # Metric implementations (one per file)
│   ├── viz/                   # Rendering + charting
│   └── strategies/            # Shipped strategies
│       └── [name]/
│           ├── SPEC.md
│           ├── impl.py
│           └── RESULTS.md
├── notebooks/                 # Jupyter for exploratory work (gitignored outputs)
├── reports/                   # Benchmark outputs (timestamped, read-only)
└── tests/                     # Harness/metric tests (strategies NOT required to be tested)
```

---

## 6. Non-Functional Requirements

| # | Requirement |
|---|-------------|
| N-1 | **Deterministic**: identical seed + version → identical bytes, always |
| N-2 | **Observable**: every validation failure includes the reason, the screen IDs, and the rule violated |
| N-3 | **Fast iteration**: adding a new strategy should take < 30 min of boilerplate |
| N-4 | **No silent failures**: a strategy that generates an invalid map *must* surface, not silently repair |
| N-5 | **Repair is a first-class strategy output, not a hidden step** — if the strategy repairs, `Candidate` records what was repaired and why |

N-4/N-5 are direct consequences of the production self-validation rule: repairs must be visible, logged, and measurable — never invisible.

---

## 7. Integration with V2 (Promotion Path)

When a Lab strategy is ready to ship:

1. Lab strategy reaches target metrics across ≥ 500 seed benchmark
2. `SPEC.md` is frozen and moved/copied to `/knowledge/systems/strategies/[name].md`
3. V2 team (or the same developer wearing V2 hat) ports to `projects/TMOS_Randomizer_V2/src/tmos_randomizer/strategies/[name]/`
4. Production port wraps the algorithm in V2's strategy interface, adds ROM patching, adds tests
5. Lab version stays as the reference implementation — it must continue to produce bit-identical `Candidate`s for the same seed

**Anti-pattern**: porting a strategy from Lab → V2 by rewriting it from scratch. The Lab version is the spec; the V2 version is the integration layer around it.

---

## 8. Open Questions (resolve before implementation starts)

1. **Reuse V2 parsers how?** — Path import, editable install, or vendored copy? (Path import preferred.)
2. **Python-only or allow other languages?** — Python-only for v1; revisit if hot loops need speedups.
3. **Does the Lab need the ROM file, or can it work from a pre-parsed JSON snapshot?** — JSON snapshot would decouple from V2 parser changes and speed up CI. Recommend producing a snapshot as a cached artifact.
4. **How are strategies versioned?** — Git SHA suffices if we record it in `RESULTS.md`. Semantic versioning is overkill for research code.
5. **Who/what runs the benchmarks?** — Local CLI only for v1. CI/nightly deferred.
6. **Notebooks in git or not?** — Committed with stripped outputs (nbstripout pre-commit).

---

## 9. v1 Milestone Definition

The Lab is "v1 ready" when:

- [ ] Project scaffolded per §5
- [ ] `LabContext` can load a ROM and expose parsed chapters
- [ ] One baseline strategy ported from V2 (`classic` or `organic`) as reference
- [ ] Harness runs a single seed end-to-end and produces a `Candidate` + validation report
- [ ] All metrics in §4.3 implemented, with tests on known-good / known-bad fixtures
- [ ] Benchmark runner produces Markdown + JSON report for a 100-seed sweep
- [ ] One visualization available: candidate map render
- [ ] README explains how to add a new strategy in < 30 minutes

Anything beyond that (novel strategies, advanced viz, cross-strategy comparisons) is v1.1+.

---

## 10. What This Document Does NOT Specify

- Actual randomization algorithms (that's what the Lab produces)
- Which baseline strategy to port first (decide at implementation kickoff)
- UI or packaging for end users (out of scope — V2 owns that)
- ROM format details (already covered exhaustively in `/knowledge/`)

---

## Changelog

| Date | Change |
|------|--------|
| 2026-04-23 | Initial draft |
