"""§4.3 row 6 — Softlock detection.

A softlock is a randomizable screen the player can enter but not leave:
≥1 incoming edge and 0 outgoing non-blocked, non-building-entrance edges,
and no Event byte set that would trigger an engine transition (stairway,
Oprin door, etc.).

Threshold: 0 softlocks.
"""
from __future__ import annotations

from .._v2_compat.parsers import DO_NOT_RANDOMIZE, SectionType, relative_to_global
from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from ._shared import iter_candidate_chapters
from .base import baseline_passthrough, register_metric


@register_metric
class SoftlockMetric:
    metric_id = "softlock"
    threshold_str = "0 randomizable dead-end rooms"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        pt = baseline_passthrough(candidate, self.metric_id, self.threshold_str)
        if pt is not None:
            return pt
        failures: list[dict] = []
        total = 0
        for ch_num, chapter in iter_candidate_chapters(candidate.chapters):
            screens = list(chapter)
            total += len(screens)

            incoming: dict[int, int] = {s.relative_index: 0 for s in screens}
            for s in screens:
                for nbr in s.get_connected_screens():
                    if nbr in incoming:
                        incoming[nbr] += 1

            for s in screens:
                gidx = relative_to_global(ch_num, s.relative_index)
                if gidx in DO_NOT_RANDOMIZE:
                    continue
                # BOSS / VICTORY / MINI_DUNGEON screens are legitimate
                # terminal areas in stock; they're not softlocks even if
                # they only exit via an event.
                if s.section_type in {
                    SectionType.BOSS,
                    SectionType.VICTORY,
                    SectionType.MINI_DUNGEON,
                    SectionType.SPECIAL,
                }:
                    continue
                if s.event != 0:
                    # Event-bearing screens have engine transitions (stairway,
                    # time door, wizard battle) — not true dead-ends.
                    continue
                has_exit = bool(s.get_connected_screens())
                if incoming[s.relative_index] > 0 and not has_exit:
                    failures.append({
                        "reason": "screen has incoming edges but no outgoing edges",
                        "screen_ids": [gidx],
                        "rule": "softlock",
                    })
        status = MetricStatus.PASS if not failures else MetricStatus.FAIL
        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=float(len(failures)),
            threshold=self.threshold_str,
            failures=failures,
            details={"screens_checked": total},
        )
