"""§4.3 row 1 — Reachability.

A randomizable screen is considered "reachable" for Lab v1 purposes if it
has at least one navigation or building-entrance connection (incoming or
outgoing). Pure orphans — randomizable screens whose navigation is entirely
``NAV_BLOCKED`` and which nothing points at — fail.

This is deliberately looser than "connected-component-contains-screen-0":
the stock ROM has multi-component chapters (building interiors are their own
components, reached via the engine's 0xFE lookup tables which the Lab does
not model). A randomizer that fragments the graph further by stranding a
screen still trips this metric; sub-world structure inherited from the stock
ROM does not.
"""
from __future__ import annotations

from .._v2_compat.parsers import (
    DO_NOT_RANDOMIZE,
    NAV_BLOCKED,
    relative_to_global,
)
from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from ._shared import iter_candidate_chapters
from .base import baseline_passthrough, register_metric


def _has_any_connection(screen) -> bool:
    for direction in ("up", "down", "left", "right"):
        nav_map = {
            "up": screen.screen_index_up,
            "down": screen.screen_index_down,
            "left": screen.screen_index_left,
            "right": screen.screen_index_right,
        }
        val = nav_map[direction]
        if val != NAV_BLOCKED:
            # NAV_BUILDING_ENTRANCE counts — the screen has a door to a
            # building interior handled by engine tables outside nav bytes.
            return True
    return False


@register_metric
class ReachabilityMetric:
    metric_id = "reachability"
    threshold_str = "100% of randomizable screens non-orphan"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        pt = baseline_passthrough(candidate, self.metric_id, self.threshold_str)
        if pt is not None:
            return pt
        failures: list[dict] = []
        total = 0
        reachable_count = 0

        for ch_num, chapter in iter_candidate_chapters(candidate.chapters):
            if chapter.screen_count == 0:
                continue
            screens = list(chapter)
            incoming: dict[int, int] = {s.relative_index: 0 for s in screens}
            for s in screens:
                for nb in s.get_connected_screens():
                    if nb in incoming:
                        incoming[nb] += 1
                # Screens with is_stairway have a destination that also counts
                # as inbound connectivity for the target.
                if s.is_stairway and s.stairway_destination is not None:
                    dst = s.stairway_destination
                    if dst in incoming:
                        incoming[dst] += 1

            for screen in screens:
                gidx = relative_to_global(ch_num, screen.relative_index)
                if gidx in DO_NOT_RANDOMIZE:
                    continue
                total += 1
                has_out = _has_any_connection(screen)
                has_in = incoming[screen.relative_index] > 0
                if has_out or has_in:
                    reachable_count += 1
                else:
                    failures.append({
                        "reason": (
                            "screen is fully disconnected: all nav bytes are "
                            "NAV_BLOCKED (0xFF) and no screen points at it"
                        ),
                        "screen_ids": [gidx],
                        "rule": "reachability",
                    })

        value = (reachable_count / total * 100.0) if total else 100.0
        status = MetricStatus.PASS if not failures else MetricStatus.FAIL
        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=value,
            threshold=self.threshold_str,
            failures=failures,
            details={"total_randomizable": total, "non_orphan": reachable_count},
        )


__all__ = ["ReachabilityMetric", "_has_any_connection"]
