"""Trustworthy, fail-closed, *differential* verdict engine for randomized worlds.

The oracle validates the *actual artifact* (a randomized GameWorld, or a ROM on
disk) independently of which strategy produced it. Two design principles:

1. **Fail-closed.** If it cannot actually validate chapters — or has no vanilla
   baseline to judge against — the verdict is FAIL, never a vacuous PASS. This
   replaces the old ``tester.py`` behavior, which was hardcoded to the classic
   pipeline and silently reported PASS while validating zero chapters under the
   (default) organic strategy.

2. **Differential, not absolute.** The static validators do not model stairways,
   time-doors, building warps, or intended one-way drops, so they reject even the
   *vanilla* game (≈35-66% "reachable", ~281 "errors"). Absolute thresholds are
   therefore meaningless. Instead the oracle judges a randomization against the
   vanilla **baseline**: it passes iff it is **no worse than the original**
   (reachability ≥ vanilla per chapter, and no new errors). Vanilla trivially
   passes itself; regressions are caught. (Precedent: the ``lab_adapter`` strategy
   already gates on "reachability ≥ pristine".)
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Union

from ..io.rom_reader import load_rom
from ..phases.phase6_validation import analyze_reachability
from ..validation.runner import ValidationRunner
from ..validation.config import ValidationConfig
from ..validation.item_gating import (
    ItemGatingBaseline,
    build_baseline as build_item_gating_baseline,
    check_world as check_item_gating,
)
from .success_criteria import SuccessCriteria, DEFAULT_CRITERIA

# Float tolerance when comparing reachability percentages.
_REACH_EPS = 0.05


@dataclass
class Baseline:
    """Reference metrics from the vanilla (unmodified) ROM."""

    chapters: List[int] = field(default_factory=list)
    reachability: Dict[int, float] = field(default_factory=dict)
    error_count: int = 0
    # Item-gating winnability baseline (what progression the vanilla ROM affords).
    # Informational channel — never affects the physical PASS/FAIL verdict.
    item_gating: Optional[ItemGatingBaseline] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapters": self.chapters,
            "reachability": self.reachability,
            "error_count": self.error_count,
            "item_gating": self.item_gating.to_dict() if self.item_gating else None,
        }


@dataclass
class WorldVerdict:
    """The oracle's verdict on a single world/artifact.

    The ``passed`` field reflects ONLY physical reachability (the hard gate). The
    item-gating fields are an *informational* channel: a static item-gated
    winnability read that flags chapters for review and feeds a playable%. They
    deliberately do NOT influence ``passed`` — item-gating is a detector, not a
    gate, and must never fail-close generation.
    """

    passed: bool
    chapters_validated: int
    error_count: int = 0
    warning_count: int = 0
    reachability: Dict[int, float] = field(default_factory=dict)
    reasons: List[str] = field(default_factory=list)
    validators_run: List[str] = field(default_factory=list)

    # --- Item-gating channel (informational only) ---
    item_gating_all_winnable: Optional[bool] = None
    item_gating_playable_pct: Optional[float] = None
    item_gating: Optional[Dict[str, Any]] = None  # full WorldItemVerdict.to_dict()

    def to_dict(self) -> Dict[str, Any]:
        return {
            "passed": self.passed,
            "chapters_validated": self.chapters_validated,
            "error_count": self.error_count,
            "warning_count": self.warning_count,
            "reachability": self.reachability,
            "reasons": self.reasons,
            "validators_run": self.validators_run,
            "item_gating_all_winnable": self.item_gating_all_winnable,
            "item_gating_playable_pct": self.item_gating_playable_pct,
            "item_gating": self.item_gating,
        }


def _run_framework(game_world: Any, rom_data: bytes):
    """Run all enabled validators against the artifact."""
    runner = ValidationRunner(ValidationConfig())
    return runner.run_all(game_world, {"rom_data": rom_data})


def _chapter_reachability(chapters: Dict[int, Any]) -> Dict[int, float]:
    reach: Dict[int, float] = {}
    for num, chapter in chapters.items():
        rr = analyze_reachability(chapter, starting_screen=0)
        reach[num] = round(rr.reachable_percentage, 2)
    return reach


def baseline_from_rom(rom_path: Union[str, Path]) -> Baseline:
    """Compute the vanilla reference baseline from an unmodified ROM."""
    rom_path = Path(rom_path)
    game_world = load_rom(rom_path)
    rom_data = rom_path.read_bytes()
    chapters = dict(getattr(game_world, "chapters", {}) or {})
    result = _run_framework(game_world, rom_data)
    return Baseline(
        chapters=sorted(chapters.keys()),
        reachability=_chapter_reachability(chapters),
        error_count=result.error_count,
        item_gating=build_item_gating_baseline(game_world),
    )


def evaluate_world(
    game_world: Any,
    rom_data: bytes,
    baseline: Optional[Baseline],
    criteria: Optional[SuccessCriteria] = None,
) -> WorldVerdict:
    """Evaluate an (already randomized) game world against the vanilla baseline.

    Fail-closed: an empty world, or a missing baseline, can never PASS.

    Args:
        game_world: GameWorld whose chapters reflect the randomized state.
        rom_data: ROM bytes (for tile/edge validators).
        baseline: Vanilla reference metrics. Required for a PASS.
        criteria: Reserved for future tightening (currently informational).
    """
    criteria = criteria or DEFAULT_CRITERIA
    chapters = dict(getattr(game_world, "chapters", {}) or {})

    # --- Fail-closed guard #1: nothing to validate => FAIL, never a vacuous PASS.
    if len(chapters) == 0:
        return WorldVerdict(
            passed=False,
            chapters_validated=0,
            reasons=["fail-closed: no chapters available to validate"],
        )

    reasons: List[str] = []

    # --- Fail-closed guard #2: no baseline => cannot judge 'no worse than vanilla'.
    if baseline is None:
        reasons.append("fail-closed: no vanilla baseline provided")

    # --- Independent validation of the artifact.
    result = _run_framework(game_world, rom_data)
    if not result.validators_run:
        reasons.append("fail-closed: no validators ran")

    reachability = _chapter_reachability(chapters)

    # --- Differential comparison against the vanilla baseline.
    if baseline is not None:
        if sorted(chapters.keys()) != sorted(baseline.chapters):
            reasons.append(
                f"chapter set {sorted(chapters.keys())} != baseline {sorted(baseline.chapters)}"
            )
        for num, pct in reachability.items():
            base_pct = baseline.reachability.get(num)
            if base_pct is not None and pct < base_pct - _REACH_EPS:
                reasons.append(
                    f"Ch{num} reachability {pct:.1f}% < vanilla {base_pct:.1f}%"
                )
        if result.error_count > baseline.error_count:
            reasons.append(
                f"{result.error_count - baseline.error_count} new error(s) vs vanilla "
                f"({result.error_count} > {baseline.error_count})"
            )

    passed = (
        len(chapters) > 0
        and baseline is not None
        and bool(result.validators_run)
        and len(reasons) == 0
    )

    # --- Item-gating channel (informational; does NOT affect `passed`). ---
    item_gating_all_winnable: Optional[bool] = None
    item_gating_pct: Optional[float] = None
    item_gating_dict: Optional[Dict[str, Any]] = None
    try:
        ig_baseline = baseline.item_gating if baseline is not None else None
        ig_verdict = check_item_gating(game_world, ig_baseline)
        item_gating_all_winnable = ig_verdict.all_winnable
        item_gating_pct = ig_verdict.playable_pct
        item_gating_dict = ig_verdict.to_dict()
    except Exception:
        # The detector must never break the oracle; swallow and leave fields None.
        pass

    return WorldVerdict(
        passed=passed,
        chapters_validated=len(chapters),
        error_count=result.error_count,
        warning_count=result.warning_count,
        reachability=reachability,
        reasons=reasons,
        validators_run=list(result.validators_run),
        item_gating_all_winnable=item_gating_all_winnable,
        item_gating_playable_pct=item_gating_pct,
        item_gating=item_gating_dict,
    )


def evaluate_rom(
    rom_path: Union[str, Path],
    baseline: Optional[Baseline],
    criteria: Optional[SuccessCriteria] = None,
) -> WorldVerdict:
    """Evaluate a ROM file on disk against the vanilla baseline."""
    rom_path = Path(rom_path)
    game_world = load_rom(rom_path)
    rom_data = rom_path.read_bytes()
    return evaluate_world(game_world, rom_data, baseline, criteria)
