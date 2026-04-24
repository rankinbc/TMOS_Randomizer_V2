"""graph_mutate — local-invariant graph mutation strategy.

For each of ``MAX_ITERATIONS`` iterations, pick one of three operators
(swap / reroute / prune), propose a mutation, apply it, check local
invariants on the affected neighborhood, and either commit (accept) or
roll back (reject). The final ``Candidate`` is the accumulation of all
accepted mutations.

See ``SPEC.md`` for the algorithm + operator catalog, and
``PRPs/archive/<date>_graph_mutate.md`` for the full gotcha list.
"""
from __future__ import annotations

import copy
import random
from typing import Any

from ..._v2_compat.pathfinding import PATHFINDING_AVAILABLE
from ...context import LabContext
from ...models import Candidate
from ...registry import register_strategy
from .operators import (
    OPERATORS,
    build_baseline_asymmetry,
    check_local_invariants,
)


@register_strategy
class GraphMutateStrategy:
    name = "graph_mutate"
    description = (
        "Local-invariant graph mutation: bounded iterations of swap / reroute "
        "/ prune with per-step walkability + bidirectionality checks; each "
        "proposal is either accepted or reverted."
    )
    strategy_version = "0.1.0"
    MAX_ITERATIONS = 200

    def generate(self, ctx: LabContext, seed: int) -> Candidate:
        # GOTCHA 1 — graph_mutate needs the raw ROM for walkability checks.
        if ctx.rom_bytes is None:
            raise ValueError(
                "graph_mutate requires --input <rom.nes> (rom_bytes). "
                "Snapshots do not carry the raw ROM bytes needed by V2's "
                "walkability helpers."
            )
        # GOTCHA 11 — the local invariant check IS a walkability check.
        if not PATHFINDING_AVAILABLE:
            raise RuntimeError(
                "graph_mutate requires V2 tile pathfinding "
                "(TMOS_Randomizer_V2/validation/tiles/pathfinding.py). "
                "The V2 sibling must be reachable."
            )

        # GOTCHA 2 — deepcopy; never mutate ctx.game_world (shared under spawn).
        world = copy.deepcopy(ctx.game_world)
        # GOTCHA 3 — scoped RNG; no module-level random.
        rng = random.Random(seed)
        # GOTCHA 9 — baseline asymmetry snapshot tolerates stock-ROM one-way edges.
        baseline_asymmetry = build_baseline_asymmetry(world)
        # GOTCHA 10 — walkability grid cache shared for the whole call.
        grid_cache: dict = {}

        op_names = [name for name, _ in OPERATORS]  # already sorted by operators.py
        op_by_name = dict(OPERATORS)
        op_stats: dict[str, dict[str, int]] = {
            name: {"attempts": 0, "accepts": 0, "rejects": 0, "no_op": 0}
            for name in op_names
        }
        accepted = 0
        rejected = 0

        for _ in range(self.MAX_ITERATIONS):
            op_name = rng.choice(op_names)
            op_stats[op_name]["attempts"] += 1
            mutation = op_by_name[op_name](world, rng)
            if mutation is None:
                op_stats[op_name]["no_op"] += 1
                continue
            mutation.apply()
            if check_local_invariants(
                world, mutation.ch_num, mutation.affected,
                baseline_asymmetry, ctx.rom_bytes, grid_cache,
            ):
                op_stats[op_name]["accepts"] += 1
                accepted += 1
            else:
                mutation.undo()
                op_stats[op_name]["rejects"] += 1
                rejected += 1

        # GOTCHA 12 — to_dict() reads current state; call AFTER the loop.
        chapters_out: dict[int, list[dict[str, Any]]] = {}
        for ch_num in sorted(world.chapters.keys()):
            chapters_out[ch_num] = [
                s.to_dict() for s in world.chapters[ch_num].screens
            ]

        return Candidate(
            strategy_id=f"{self.name}@local",
            strategy_version=self.strategy_version,
            seed=seed,
            chapters=chapters_out,
            repairs=[],  # v0.1.0 never produces a RepairRecord — by design.
            breadcrumbs={
                "source": ctx.source,
                "rom_md5": ctx.rom_md5,
                "graph_mutate_stats": {
                    "accepted": accepted,
                    "rejected": rejected,
                    "operators": op_stats,
                },
            },
        )


__all__ = ["GraphMutateStrategy"]
