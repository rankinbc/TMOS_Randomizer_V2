"""Core dataclasses for the TMOS Strategy Lab.

Every dataclass round-trips to JSON via ``dataclasses.asdict`` + ``from_dict``.
The ValidationReport JSON round-trip is the canonical field-parity check between
the Markdown and JSON renderings (both consume the same asdict() dict).
"""
from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field, is_dataclass
from enum import Enum
from typing import Any


class MetricStatus(Enum):
    PASS = "pass"
    FAIL = "fail"


@dataclass(frozen=True)
class RepairRecord:
    """First-class repair output (REQUIREMENTS.md §6 N-5).

    If a strategy self-repairs a candidate, the repair is recorded here and
    surfaced prominently in the report. Never silent.
    """
    what: str
    why: str
    screen_ids: list[int]
    rule: str

    def to_dict(self) -> dict[str, Any]:
        return {"what": self.what, "why": self.why, "screen_ids": list(self.screen_ids), "rule": self.rule}

    @classmethod
    def from_dict(cls, d: dict[str, Any]) -> RepairRecord:
        return cls(what=d["what"], why=d["why"], screen_ids=list(d["screen_ids"]), rule=d["rule"])


@dataclass
class MetricResult:
    """One metric's output.

    ``failures`` carries ``{reason, screen_ids, rule}`` triples so every failure
    is observable per REQUIREMENTS.md §6 N-2.
    """
    metric_id: str
    status: MetricStatus
    value: float
    threshold: str
    failures: list[dict[str, Any]] = field(default_factory=list)
    details: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return {
            "metric_id": self.metric_id,
            "status": self.status.value,
            "value": self.value,
            "threshold": self.threshold,
            "failures": list(self.failures),
            "details": dict(self.details),
        }

    @classmethod
    def from_dict(cls, d: dict[str, Any]) -> MetricResult:
        return cls(
            metric_id=d["metric_id"],
            status=MetricStatus(d["status"]),
            value=d["value"],
            threshold=d["threshold"],
            failures=list(d.get("failures", [])),
            details=dict(d.get("details", {})),
        )


@dataclass
class Candidate:
    """In-memory randomization output produced by a strategy.

    Not a ROM. Serialized as JSON for downstream tools (benchmark, visualizer).
    ``chapters`` maps chapter_num (as int) to a list of screen dicts (WorldScreen.to_dict()).
    """
    strategy_id: str
    strategy_version: str
    seed: int
    chapters: dict[int, list[dict[str, Any]]]
    repairs: list[RepairRecord] = field(default_factory=list)
    breadcrumbs: dict[str, Any] = field(default_factory=dict)

    # Breadcrumb keys that record wall-clock measurements — excluded from
    # JSON serialization to keep same-seed reruns byte-identical.
    _RUNTIME_ONLY_BREADCRUMBS = frozenset({
        "strategy_generation_time_s",
        "metrics_compute_time_s",
    })

    def to_json_dict(self) -> dict[str, Any]:
        breadcrumbs = {
            k: v for k, v in self.breadcrumbs.items()
            if k not in self._RUNTIME_ONLY_BREADCRUMBS
        }
        return {
            "strategy_id": self.strategy_id,
            "strategy_version": self.strategy_version,
            "seed": self.seed,
            "chapters": {str(k): list(v) for k, v in sorted(self.chapters.items())},
            "repairs": [r.to_dict() for r in self.repairs],
            "breadcrumbs": breadcrumbs,
        }

    @classmethod
    def from_json_dict(cls, d: dict[str, Any]) -> Candidate:
        chapters_raw = d.get("chapters", {})
        chapters: dict[int, list[dict[str, Any]]] = {}
        for k, screens in chapters_raw.items():
            chapters[int(k)] = list(screens)
        return cls(
            strategy_id=d["strategy_id"],
            strategy_version=d["strategy_version"],
            seed=d["seed"],
            chapters=chapters,
            repairs=[RepairRecord.from_dict(r) for r in d.get("repairs", [])],
            breadcrumbs=dict(d.get("breadcrumbs", {})),
        )

    def to_json(self) -> str:
        return json.dumps(self.to_json_dict(), indent=2, sort_keys=True)


def _maybe_strip_timing(metric_dict: dict[str, Any], include_timing: bool) -> dict[str, Any]:
    """Zero out wall-clock value fields for deterministic JSON serialization."""
    if include_timing:
        return metric_dict
    if metric_dict.get("metric_id") == "generation_time":
        md = dict(metric_dict)
        md["value"] = 0.0
        # Drop any timing-specific details that carry wall-clock.
        md["details"] = {}
        return md
    return metric_dict


@dataclass
class ValidationReport:
    """The harness output.

    Markdown and JSON render from the same ``to_dict()`` dict — divergence is
    a data-integrity bug caught by ``tests/test_models.py``.
    """
    strategy_id: str
    seed: int
    generation_time_s: float
    metrics: list[MetricResult]
    repairs: list[RepairRecord]
    candidate_summary: dict[str, Any]

    @property
    def passed(self) -> bool:
        return all(m.status == MetricStatus.PASS for m in self.metrics)

    # Candidate-summary keys with runtime values (excluded from JSON / Markdown
    # generation time is shown in a separate human-facing note).
    _RUNTIME_ONLY_SUMMARY_KEYS = frozenset({
        "strategy_generation_time_s",
        "metrics_compute_time_s",
    })

    def to_dict(self, *, include_timing: bool = False) -> dict[str, Any]:
        """Serialize to dict.

        ``include_timing=False`` (default) drops wall-clock measurements so
        two runs with the same seed produce byte-identical JSON. The Markdown
        renderer opts in via ``include_timing=True`` — timing is displayed to
        users even though it is non-deterministic.
        """
        summary = {
            k: v for k, v in self.candidate_summary.items()
            if include_timing or k not in self._RUNTIME_ONLY_SUMMARY_KEYS
        }
        return {
            "strategy_id": self.strategy_id,
            "seed": self.seed,
            "generation_time_s": self.generation_time_s if include_timing else None,
            "passed": self.passed,
            "metrics": [_maybe_strip_timing(m.to_dict(), include_timing) for m in self.metrics],
            "repairs": [r.to_dict() for r in self.repairs],
            "candidate_summary": summary,
        }

    @classmethod
    def from_dict(cls, d: dict[str, Any]) -> ValidationReport:
        return cls(
            strategy_id=d["strategy_id"],
            seed=d["seed"],
            generation_time_s=d.get("generation_time_s") or 0.0,
            metrics=[MetricResult.from_dict(m) for m in d.get("metrics", [])],
            repairs=[RepairRecord.from_dict(r) for r in d.get("repairs", [])],
            candidate_summary=dict(d.get("candidate_summary", {})),
        )

    def to_json(self) -> str:
        return json.dumps(self.to_dict(include_timing=False), indent=2, sort_keys=True)

    def to_markdown(self) -> str:
        from .report.markdown import render_report
        return render_report(self.to_dict(include_timing=True))


# Safety helper used by tests and callers constructing dicts from arbitrary
# dataclass trees.
def dataclass_to_dict(obj: Any) -> Any:
    if is_dataclass(obj):
        return asdict(obj)
    return obj
