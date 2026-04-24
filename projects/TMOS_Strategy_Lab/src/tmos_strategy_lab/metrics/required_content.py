"""§4.3 row 7 — Required-content reachability.

Mosques, bosses, and shops must have **at least one** incoming navigation
connection (either a navigation pointer or a stairway destination) — i.e.,
they are not pure orphans. This is the same lenient definition as the
``reachability`` metric: Lab v1 does not model engine-side building-entrance
tables, so we can't verify "reachable from screen 0" without over-flagging
the stock ROM.

Threshold: 100% of mosques, bosses, and shops connected.
"""
from __future__ import annotations

from .._v2_compat.parsers import relative_to_global
from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from ._shared import iter_candidate_chapters
from .base import baseline_passthrough, register_metric


@register_metric
class RequiredContentMetric:
    metric_id = "required_content"
    threshold_str = "100% of mosques, bosses, and shops connected"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        pt = baseline_passthrough(candidate, self.metric_id, self.threshold_str)
        if pt is not None:
            return pt
        failures: list[dict] = []
        total_required = 0
        reached_required = 0

        for ch_num, chapter in iter_candidate_chapters(candidate.chapters):
            if chapter.screen_count == 0:
                continue
            screens = list(chapter)
            incoming: dict[int, int] = {s.relative_index: 0 for s in screens}
            for s in screens:
                for nb in s.get_connected_screens():
                    if nb in incoming:
                        incoming[nb] += 1
                if s.is_stairway and s.stairway_destination is not None:
                    dst = s.stairway_destination
                    if dst in incoming:
                        incoming[dst] += 1

            for screen in screens:
                if not (screen.is_mosque or screen.is_boss_screen or screen.is_shop):
                    continue
                total_required += 1
                has_out = bool(screen.get_connected_screens())
                has_in = incoming[screen.relative_index] > 0
                if has_out or has_in:
                    reached_required += 1
                else:
                    kind = (
                        "mosque" if screen.is_mosque else
                        "boss" if screen.is_boss_screen else
                        "shop"
                    )
                    failures.append({
                        "reason": f"required {kind} screen is fully disconnected",
                        "screen_ids": [relative_to_global(ch_num, screen.relative_index)],
                        "rule": "required_content",
                    })

        value = (reached_required / total_required * 100.0) if total_required else 100.0
        status = MetricStatus.PASS if not failures else MetricStatus.FAIL
        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=value,
            threshold=self.threshold_str,
            failures=failures,
            details={"total_required": total_required, "connected_required": reached_required},
        )
