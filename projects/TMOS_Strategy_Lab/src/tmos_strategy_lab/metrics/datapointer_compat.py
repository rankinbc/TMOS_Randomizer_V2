"""§4.3 row 5 — DataPointer ↔ ObjectSet compatibility.

For each screen, the ObjectSet byte must appear in
``get_compatible_objectsets(datapointer)`` — the D-4 table (V2's
``OBJECTSET_COMPATIBILITY``).

V2's table covers the CHR banks the randomizer actually touches; unknown
CHR banks resolve to ``{0x00}`` — too strict for the stock ROM, which uses
banks outside the table for intro/special screens. The metric therefore
**only counts violations for CHR banks explicitly listed in the V2 table**;
unknowns are reported in ``details`` but don't affect pass/fail.

Threshold: 0 incompatible pairs (on known CHR banks).
"""
from __future__ import annotations

from .._v2_compat.objectset_compat import (
    OBJECTSET_COMPATIBILITY,
    get_chr_index,
    get_compatible_objectsets,
)
from .._v2_compat.parsers import relative_to_global
from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from ._shared import iter_candidate_chapters
from .base import baseline_passthrough, register_metric


@register_metric
class DataPointerCompatMetric:
    metric_id = "datapointer_compat"
    threshold_str = "0 DataPointer/ObjectSet mismatches on known CHR banks"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        pt = baseline_passthrough(candidate, self.metric_id, self.threshold_str)
        if pt is not None:
            return pt
        failures: list[dict] = []
        total = 0
        skipped_unknown_chr = 0
        for ch_num, chapter in iter_candidate_chapters(candidate.chapters):
            for screen in chapter:
                total += 1
                chr_idx = get_chr_index(screen.datapointer)
                if chr_idx not in OBJECTSET_COMPATIBILITY:
                    skipped_unknown_chr += 1
                    continue
                compatible = get_compatible_objectsets(screen.datapointer)
                if screen.objectset not in compatible:
                    failures.append({
                        "reason": (
                            f"ObjectSet 0x{screen.objectset:02X} incompatible with "
                            f"DataPointer 0x{screen.datapointer:02X} (CHR 0x{chr_idx:02X})"
                        ),
                        "screen_ids": [relative_to_global(ch_num, screen.relative_index)],
                        "rule": "datapointer_compat",
                    })
        status = MetricStatus.PASS if not failures else MetricStatus.FAIL
        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=float(len(failures)),
            threshold=self.threshold_str,
            failures=failures,
            details={
                "screens_checked": total,
                "skipped_unknown_chr": skipped_unknown_chr,
            },
        )
