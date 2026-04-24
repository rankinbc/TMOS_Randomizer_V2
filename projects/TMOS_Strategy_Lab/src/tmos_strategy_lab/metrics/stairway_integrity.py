"""§4.3 row 4 — Stairway integrity.

Every Event=0x40 (stairway) screen must point at another stairway whose
destination points back at it. ``Chapter.get_stairway_pairs()`` already returns
valid bidirectional pairs; anything NOT in a returned pair is broken.

Threshold: 0 broken pairs.
"""
from __future__ import annotations

from .._v2_compat.parsers import relative_to_global
from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from ._shared import iter_candidate_chapters
from .base import baseline_passthrough, register_metric


@register_metric
class StairwayIntegrityMetric:
    metric_id = "stairway_integrity"
    threshold_str = "0 broken stairway pairs"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        pt = baseline_passthrough(candidate, self.metric_id, self.threshold_str)
        if pt is not None:
            return pt
        failures: list[dict] = []
        total_stairways = 0
        paired_stairways = 0

        for ch_num, chapter in iter_candidate_chapters(candidate.chapters):
            stairways = [s for s in chapter if s.is_stairway]
            total_stairways += len(stairways)

            paired: set[int] = set()
            for a, b in chapter.get_stairway_pairs():
                paired.add(a.relative_index)
                paired.add(b.relative_index)

            paired_stairways += len(paired)

            for s in stairways:
                if s.relative_index in paired:
                    continue
                failures.append({
                    "reason": f"stairway on screen {s.relative_index} "
                              f"does not have a reciprocal partner",
                    "screen_ids": [relative_to_global(ch_num, s.relative_index)],
                    "rule": "stairway_integrity",
                })

        status = MetricStatus.PASS if not failures else MetricStatus.FAIL
        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=float(len(failures)),
            threshold=self.threshold_str,
            failures=failures,
            details={"stairways_total": total_stairways, "stairways_paired": paired_stairways},
        )
