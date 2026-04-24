"""§4.3 row 3 — Bidirectional violations.

A→B without B→A. Exemptions:
- MAZE section screens (intentional maze asymmetry).
- Screens that fire an engine event (``event != 0``) — the engine handles
  traversal for these (stairways, Oprin doors, etc.), so the pointer-level
  asymmetry is expected.
- Stairway destinations on either side are handled via ``Event=0x40`` rather
  than walk-through pointers.

Threshold: 0 violations.
"""
from __future__ import annotations

from .._v2_compat.parsers import SectionType, relative_to_global
from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from ._shared import iter_candidate_chapters
from .base import baseline_passthrough, register_metric

_OPPOSITE = {"up": "down", "down": "up", "left": "right", "right": "left"}


def _is_exempt(screen) -> bool:
    if screen.section_type == SectionType.MAZE:
        return True
    if screen.event != 0:
        return True
    return False


@register_metric
class BidirectionalMetric:
    metric_id = "bidirectional"
    threshold_str = "0 A→B without B→A (excluding MAZE, event-bearing, and stairway screens)"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        pt = baseline_passthrough(candidate, self.metric_id, self.threshold_str)
        if pt is not None:
            return pt
        failures: list[dict] = []
        directed_edges = 0

        for ch_num, chapter in iter_candidate_chapters(candidate.chapters):
            screens = list(chapter)
            by_idx = {s.relative_index: s for s in screens}
            for src in screens:
                if _is_exempt(src):
                    continue
                for direction in ("up", "down", "left", "right"):
                    nbr_idx = src.get_neighbor(direction)
                    if nbr_idx is None:
                        continue
                    dst = by_idx.get(nbr_idx)
                    if dst is None or _is_exempt(dst):
                        continue
                    directed_edges += 1
                    back = dst.get_neighbor(_OPPOSITE[direction])
                    if back != src.relative_index:
                        failures.append({
                            "reason": f"A→B on {direction} with missing reverse",
                            "screen_ids": [
                                relative_to_global(ch_num, src.relative_index),
                                relative_to_global(ch_num, dst.relative_index),
                            ],
                            "rule": "bidirectional",
                        })

        status = MetricStatus.PASS if not failures else MetricStatus.FAIL
        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=float(len(failures)),
            threshold=self.threshold_str,
            failures=failures,
            details={"directed_edges_checked": directed_edges},
        )
