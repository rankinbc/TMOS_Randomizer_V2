"""§4.3 row 2 — Edge-compatibility violations.

For every directed edge A→B the shared edge must have **at least one**
walkable tile on each side — column alignment is not required (the NES
engine lets the player step off any walkable tile in the source edge row
and onto any walkable tile in the destination edge row).

Skipped (informational only) when V2 tile pathfinding is unavailable or
``rom_bytes`` is ``None`` (snapshot input).
"""
from __future__ import annotations

from .._v2_compat.parsers import relative_to_global
from .._v2_compat.pathfinding import (
    PATHFINDING_AVAILABLE,
    build_walkability_grid,
    get_walkable_edge_positions,
)
from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from ._shared import iter_candidate_chapters
from .base import baseline_passthrough, register_metric

_OPPOSITE = {"up": "down", "down": "up", "left": "right", "right": "left"}


@register_metric
class EdgeCompatibilityMetric:
    metric_id = "edge_compatibility"
    threshold_str = "0 adjacent pairs with both edges fully unwalkable"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        pt = baseline_passthrough(candidate, self.metric_id, self.threshold_str)
        if pt is not None:
            return pt
        rom = ctx.rom_bytes
        if not PATHFINDING_AVAILABLE or rom is None:
            return MetricResult(
                metric_id=self.metric_id,
                status=MetricStatus.PASS,
                value=0.0,
                threshold=self.threshold_str,
                failures=[],
                details={"skipped": True, "reason": "V2 pathfinding / rom_bytes unavailable"},
            )

        failures: list[dict] = []
        grid_cache: dict[tuple, list[list[bool]]] = {}

        def grid_for(screen) -> list[list[bool]]:
            key = (screen.top_tiles, screen.bottom_tiles, screen.datapointer & 0xFF)
            if key not in grid_cache:
                grid_cache[key] = build_walkability_grid(
                    rom, screen.top_tiles, screen.bottom_tiles, screen.datapointer
                )
            return grid_cache[key]

        considered = 0
        for ch_num, chapter in iter_candidate_chapters(candidate.chapters):
            screens = list(chapter)
            by_idx = {s.relative_index: s for s in screens}
            for src in screens:
                for direction in ("up", "down", "left", "right"):
                    nbr_idx = src.get_neighbor(direction)
                    if nbr_idx is None:
                        continue
                    dst = by_idx.get(nbr_idx)
                    if dst is None:
                        continue
                    considered += 1
                    src_grid = grid_for(src)
                    dst_grid = grid_for(dst)
                    src_walkable = get_walkable_edge_positions(src_grid, direction)
                    dst_walkable = get_walkable_edge_positions(dst_grid, _OPPOSITE[direction])
                    if not src_walkable or not dst_walkable:
                        failures.append({
                            "reason": (
                                f"edge {direction}: source has "
                                f"{len(src_walkable)} walkable tiles, destination has "
                                f"{len(dst_walkable)} — both need ≥ 1"
                            ),
                            "screen_ids": [
                                relative_to_global(ch_num, src.relative_index),
                                relative_to_global(ch_num, dst.relative_index),
                            ],
                            "rule": "edge_compatibility",
                        })

        status = MetricStatus.PASS if not failures else MetricStatus.FAIL
        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=float(len(failures)),
            threshold=self.threshold_str,
            failures=failures,
            details={"directed_edges_checked": considered},
        )
