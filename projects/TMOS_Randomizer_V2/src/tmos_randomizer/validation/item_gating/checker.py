"""Item-gated winnability CHECKER.

Given a chapter (vanilla or randomized), this performs the fixed-point
item-gating analysis:

1. Era-aware physical reachability from the chapter entry (``reachability.py``):
   directional + stairway edges, with Time Doors unlocking the opposite era.
2. Token acquisition: an acquirable is *obtainable* iff its era region is
   reachable. Traversal abilities (WATER/LAVA) follow from the acquirables that
   grant them — and, conservatively, a terrain ability only counts as "held" if
   its granting acquirable is obtainable.
3. Win evaluation: the goal era must be reachable AND every required token must
   be obtainable AND every required traversal ability must be held.

Conservatism & the differential contract
-----------------------------------------
The static directional/stairway graph under-reaches the *vanilla* game (the
engine warps via building entrances and one-way drops this model can't see), so
an *absolute* "is the goal reachable" test would wrongly fail vanilla. Following
the established oracle pattern, winnability is judged **differentially**: a
chapter is ``winnable`` unless it is **strictly worse than the vanilla baseline**
— i.e. it loses a required token's region, an era, or the goal region that the
vanilla ROM had. With no baseline, the checker is conservative and reports
``needs_review`` rather than guessing a pass.

This module is a DETECTOR/REPORTER. It returns structured verdicts; it never
raises to fail-close a pipeline.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

from ...core.chapter import Chapter, GameWorld
from .model import (
    Era,
    ChapterGating,
    chapter_gating,
)
from .reachability import EraReachability, compute_era_reachability


# =============================================================================
# Verdict types
# =============================================================================


@dataclass
class Blocker:
    """A single thing blocking winnability (or flagged for review)."""

    kind: str  # "token" | "ability" | "goal" | "unmodelled"
    requirement: str  # token id / ability id / goal name
    reason: str

    def to_dict(self) -> Dict[str, Any]:
        return {"kind": self.kind, "requirement": self.requirement, "reason": self.reason}


@dataclass
class ChapterItemVerdict:
    """Item-gating verdict for a single chapter.

    ``winnable`` is True only when nothing is blocking. ``needs_review`` is the
    conservative middle state: the model could not confirm winnability (a region
    the vanilla ROM reached is now unreachable, or no baseline was available).
    The two are mutually exclusive; a chapter is winnable XOR needs_review.
    """

    chapter: int
    winnable: bool
    needs_review: bool
    goal: str
    tokens_obtained: List[str] = field(default_factory=list)
    tokens_missing: List[str] = field(default_factory=list)
    abilities_held: List[str] = field(default_factory=list)
    blocking: List[Blocker] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter": self.chapter,
            "winnable": self.winnable,
            "needs_review": self.needs_review,
            "goal": self.goal,
            "tokens_obtained": self.tokens_obtained,
            "tokens_missing": self.tokens_missing,
            "abilities_held": self.abilities_held,
            "blocking": [b.to_dict() for b in self.blocking],
        }


@dataclass
class WorldItemVerdict:
    """Aggregate item-gating verdict across all chapters + playable%."""

    chapters: List[ChapterItemVerdict] = field(default_factory=list)

    @property
    def winnable_count(self) -> int:
        return sum(1 for c in self.chapters if c.winnable)

    @property
    def needs_review_count(self) -> int:
        return sum(1 for c in self.chapters if c.needs_review)

    @property
    def all_winnable(self) -> bool:
        return bool(self.chapters) and all(c.winnable for c in self.chapters)

    @property
    def playable_pct(self) -> float:
        """Percentage of modelled chapters judged winnable (0..100)."""
        if not self.chapters:
            return 0.0
        return round(100.0 * self.winnable_count / len(self.chapters), 1)

    def chapter(self, num: int) -> Optional[ChapterItemVerdict]:
        for c in self.chapters:
            if c.chapter == num:
                return c
        return None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "all_winnable": self.all_winnable,
            "winnable_count": self.winnable_count,
            "needs_review_count": self.needs_review_count,
            "playable_pct": self.playable_pct,
            "chapters": [c.to_dict() for c in self.chapters],
        }


# =============================================================================
# Baseline (token reachability of the vanilla ROM, for the differential)
# =============================================================================


@dataclass
class ItemGatingBaseline:
    """What progression the *vanilla* ROM physically affords per chapter.

    For each chapter we record which required tokens, abilities and the goal era
    the vanilla static model could reach. A randomized seed is judged against
    this: it must not LOSE any of these. (Vanilla judged against itself never
    loses anything, so it is always winnable — the required acceptance result.)
    """

    # chapter -> set of token ids the vanilla model found obtainable
    tokens: Dict[int, set] = field(default_factory=dict)
    # chapter -> set of ability ids the vanilla model found held
    abilities: Dict[int, set] = field(default_factory=dict)
    # chapter -> bool: vanilla reached the goal era
    goal_reached: Dict[int, bool] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "tokens": {k: sorted(v) for k, v in self.tokens.items()},
            "abilities": {k: sorted(v) for k, v in self.abilities.items()},
            "goal_reached": self.goal_reached,
        }


def _obtained(cg: ChapterGating, reach: EraReachability) -> tuple[set, set, bool]:
    """Compute (obtained_tokens, held_abilities, goal_reached) for a chapter.

    Goal-reached is anchored to the chapter's concrete boss screen(s) when known
    (``win.goal_screens``): any goal screen physically reachable counts. This
    makes "lost the path to the boss" detectable differentially. If no concrete
    goal screens are modelled, it falls back to the goal era being reachable.
    """
    obtained_tokens: set = set()
    held_abilities: set = set()

    for acq in cg.acquirables:
        if reach.era_reachable(acq.era):
            obtained_tokens.add(acq.token)
            held_abilities.update(acq.grants)

    if cg.win.goal_screens:
        goal_reached = any(g in reach.reachable for g in cg.win.goal_screens)
    else:
        goal_reached = reach.era_reachable(cg.win.goal_era)
    return obtained_tokens, held_abilities, goal_reached


def build_baseline(world: GameWorld) -> ItemGatingBaseline:
    """Build the item-gating baseline from the (vanilla) game world."""
    baseline = ItemGatingBaseline()
    for chapter in world:
        cg = chapter_gating(chapter.chapter_num)
        if cg is None:
            continue
        reach = compute_era_reachability(chapter, cg.entry_screen)
        tokens, abilities, goal = _obtained(cg, reach)
        baseline.tokens[chapter.chapter_num] = tokens
        baseline.abilities[chapter.chapter_num] = abilities
        baseline.goal_reached[chapter.chapter_num] = goal
    return baseline


# =============================================================================
# Checker
# =============================================================================


def check_chapter(
    chapter: Chapter,
    baseline: Optional[ItemGatingBaseline] = None,
) -> ChapterItemVerdict:
    """Produce an item-gating verdict for one chapter.

    Differential: if a ``baseline`` is supplied, the chapter is winnable iff it is
    no worse than vanilla (loses no required token region, ability or goal era).
    Without a baseline, the checker is conservative: it reports ``needs_review``
    unless the absolute analysis already finds everything reachable.
    """
    cg = chapter_gating(chapter.chapter_num)
    if cg is None:
        # Unmodelled chapter — conservatively flag for review (never silent pass).
        return ChapterItemVerdict(
            chapter=chapter.chapter_num,
            winnable=False,
            needs_review=True,
            goal="(unmodelled)",
            blocking=[Blocker("unmodelled", str(chapter.chapter_num),
                              "no item-gating model for this chapter")],
        )

    reach = compute_era_reachability(chapter, cg.entry_screen)
    obtained, abilities, goal_reached = _obtained(cg, reach)

    required_tokens = set(cg.win.required_tokens)
    required_abilities = set(cg.win.required_abilities)

    missing_tokens = sorted(required_tokens - obtained)
    missing_abilities = sorted(required_abilities - abilities)

    verdict = ChapterItemVerdict(
        chapter=chapter.chapter_num,
        winnable=False,
        needs_review=False,
        goal=cg.win.goal_name,
        tokens_obtained=sorted(obtained),
        tokens_missing=missing_tokens,
        abilities_held=sorted(abilities),
    )

    if baseline is not None:
        # --- Differential: judged against vanilla, only flag regressions. ---
        base_tokens = baseline.tokens.get(chapter.chapter_num, set())
        base_abilities = baseline.abilities.get(chapter.chapter_num, set())
        base_goal = baseline.goal_reached.get(chapter.chapter_num, False)

        # A regression is losing a REQUIRED token/ability/goal that vanilla had.
        lost_tokens = sorted((required_tokens & base_tokens) - obtained)
        lost_abilities = sorted((required_abilities & base_abilities) - abilities)
        lost_goal = base_goal and not goal_reached

        for tok in lost_tokens:
            acq = cg.acquirable(tok)
            name = acq.name if acq else tok
            verdict.blocking.append(Blocker(
                "token", tok,
                f"{name} ({acq.era.value if acq else '?'}) region reachable in vanilla "
                f"but not in this seed",
            ))
        for ab in lost_abilities:
            verdict.blocking.append(Blocker(
                "ability", ab,
                f"traversal ability '{ab}' available in vanilla but its source "
                f"region is unreachable in this seed",
            ))
        if lost_goal:
            verdict.blocking.append(Blocker(
                "goal", cg.win.goal_name,
                f"goal region ({cg.win.goal_era.value}) reachable in vanilla but "
                f"not in this seed",
            ))

        verdict.winnable = not verdict.blocking
        verdict.needs_review = not verdict.winnable
        return verdict

    # --- No baseline: absolute, conservative. ---
    if missing_tokens or missing_abilities or not goal_reached:
        for tok in missing_tokens:
            acq = cg.acquirable(tok)
            name = acq.name if acq else tok
            verdict.blocking.append(Blocker(
                "token", tok, f"{name} region not reachable (no baseline to compare)",
            ))
        for ab in missing_abilities:
            verdict.blocking.append(Blocker(
                "ability", ab, f"traversal ability '{ab}' not held (no baseline)",
            ))
        if not goal_reached:
            verdict.blocking.append(Blocker(
                "goal", cg.win.goal_name,
                f"goal region ({cg.win.goal_era.value}) not reachable (no baseline)",
            ))
        verdict.needs_review = True
        verdict.winnable = False
    else:
        verdict.winnable = True
        verdict.needs_review = False
    return verdict


def check_world(
    world: GameWorld,
    baseline: Optional[ItemGatingBaseline] = None,
) -> WorldItemVerdict:
    """Item-gating verdict for the whole world (+ playable% aggregate)."""
    result = WorldItemVerdict()
    for chapter in world:
        result.chapters.append(check_chapter(chapter, baseline))
    return result
