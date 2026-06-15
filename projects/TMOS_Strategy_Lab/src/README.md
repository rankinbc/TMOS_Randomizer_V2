# src — `tmos_strategy_lab` shared library

Home for the shared Python package. Install editable from the project root:

```bash
pip install -e .
```

## Public surface

```python
import tmos_strategy_lab as t

ctx  = t.LabContext.from_rom("data/rom/TMOS_ORIGINAL.nes")
strat = t.get_strategy("identity")()
cand = strat.generate(ctx, seed=42)
# cand.repairs — first-class RepairRecord list (REQUIREMENTS.md §6 N-5)
```

## Add a new strategy in < 30 minutes

1. `src/tmos_strategy_lab/strategies/<name>/SPEC.md` — algorithm, constraints
   honored, known limitations (REQUIREMENTS.md §4.6).
2. `src/tmos_strategy_lab/strategies/<name>/impl.py`:

   ```python
   from ...context import LabContext
   from ...models import Candidate, RepairRecord
   from ...registry import register_strategy

   @register_strategy
   class MyStrategy:
       name = "my_strategy"
       description = "One-line elevator pitch."

       def generate(self, ctx: LabContext, seed: int) -> Candidate:
           import copy, random
           world = copy.deepcopy(ctx.game_world)
           rng = random.Random(seed)  # per-seed Random instance — no module state
           # ... mutate `world` here ...
           repairs: list[RepairRecord] = []  # populate if you self-repair
           chapters = {
               n: [s.to_dict() for s in world.chapters[n].screens]
               for n in sorted(world.chapters.keys())
           }
           return Candidate(
               strategy_id=f"{self.name}@local",
               strategy_version="0.1.0",
               seed=seed,
               chapters=chapters,
               repairs=repairs,
               breadcrumbs={"source": ctx.source},
           )
   ```
3. `src/tmos_strategy_lab/strategies/<name>/__init__.py`:

   ```python
   from .impl import MyStrategy  # noqa: F401
   ```
4. Register by importing your subpackage from `strategies/__init__.py`:

   ```python
   from . import my_strategy  # noqa: F401
   ```
5. Run it:

   ```bash
   PYTHONHASHSEED=42 python -m harness run --strategy my_strategy --seed 42 \
       --input data/rom/TMOS_ORIGINAL.nes
   ```

## Package layout

- `context.py` — `LabContext` wrapping a parsed `GameWorld` + rom bytes.
- `models.py` — `Candidate`, `ValidationReport`, `RepairRecord`, `MetricResult`.
- `registry.py` — `LabStrategy` Protocol + `register_strategy` decorator.
- `snapshot.py` — ROM ↔ JSON snapshot round-trip (`python -m tmos_strategy_lab.snapshot save …`).
- `_v2_compat/` — path-import adapters for V2 (parsers, pathfinding, renderer).
  **Never** copy-paste V2 code; always go through here.
- `metrics/` — the 9-metric battery from REQUIREMENTS.md §4.3.
- `strategies/` — shipped strategies (`identity`, `organic_port`, `graph_mutate`,
  `tileshuffle`, `grow`). `grow` (v0.3.0) is satisfiability-driven section growth
  that emits **era-safe, warp-aware navigable** output: the grown grid is written
  into WorldScreen nav bytes (intra-section + edge-verified **same-era** walk-across
  links), stairways (Event 0x40) and time doors (Content 0xC0) are preserved and used
  as connectivity warps, and tile-swaps are applied; requires `--input <rom.nes>`.
- `viz/` — rendering primitives consumed by the visualizer CLI.
- `report/` — Jinja2 templates + markdown rendering for ValidationReport.

## Invariants

- **Determinism** — integer seeds only; `PYTHONHASHSEED` enforced by CLI;
  multiprocessing uses `get_context('spawn')`, not fork.
- **No silent failures** — strategies that repair record `RepairRecord`s on
  the `Candidate`; metrics report `failures` with reason + screen_ids + rule.
- **V2 is a sibling, not a dependency** — adapter-only.

See `REQUIREMENTS.md` for the full spec; `CLAUDE.md` for project conventions.
