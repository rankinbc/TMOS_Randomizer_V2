"""Static item-gating data model for the TMOS winnability detector.

This module encodes — as structured data — the *logical* progression gates that
the physical-reachability machinery cannot see. Physical reachability proves you
can walk to a screen; item-gating proves the progression items are obtainable in
the order the game requires, so the seed is actually completable.

Authority & scope
------------------
The gate logic here is the user's RESOLVED gate logic (which overrides any open
questions in the merged spec ``docs/ai/AI_item-gating-logic-spec.md``):

- **Time Doors** (Content 0xC0 / 0xC7 / 0xD7) join PRESENT<->PAST freely. There
  is NO scarce-item gate on any time door. A screen's era is decided strictly by
  ``PAST_SCREEN_INDICES`` (authoritative), not by ParentWorld.
- **Supica / desert is NOT a gate.** No desert-maze gate is modelled and Supica
  is not a required ally.
- **Ch1** — Faruk (recruited in the PAST, reached via a time door) grants WATER
  traversal, required to reach the Aqua Palace / Gilga. Win = reach Gilga with
  water access.
- **Ch2** — win = reach Curly. No desert gate. Only allies the spec marks
  mandatory are modelled (Epin).
- **Ch3** — win requires BOTH Pukin (lights the dark maze via the Cimaron Rod)
  AND Mustafa (needed to beat the Troll).
- **Ch4** — Holy Robe (from Gubibi, Fire Palace) grants LAVA traversal, required
  to cross the Lava Cape to reach Salamander. Win = reach Salamander with lava
  access + Rainy + Crystal Rod.
- **Ch5** — win requires Legend Sword AND Armor of Light AND Isfa Rod (all
  REQUIRED) to reach / defeat GoraGora.
- **Class-change stranding (B4)** and **runtime exit-byte modification (B8)** are
  unverified: handled CONSERVATIVELY — if a required token's region can't be
  confirmed reachable, the chapter is flagged *needs-review*, never silently
  passed.

Granularity
-----------
Because the merged spec's exact per-item screen indices are not available to this
build, acquirables are located at **era granularity** (PRESENT vs PAST) plus an
optional section-type hint. This is deliberately conservative: a token is
"obtainable" only when its acquisition *region* is reachable in the seed under
the same era-unlock rules the engine uses (time doors join eras). The checker is
**differential** against the vanilla baseline (see ``checker.py``), so vanilla —
whose static graph under-reaches just like every other seed — is always judged
winnable, and a seed is only flagged when it loses progression the vanilla ROM
had.

Nothing here is a hard gate: the detector is a REPORTER. See ``validator.py`` and
the oracle channel — both are informational and never fail-close generation.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Dict, List, Optional, Tuple


class Era(Enum):
    """Time period a screen / acquisition region belongs to.

    Mirrors ``core.enums.TimePeriod`` but kept local and hashable-by-value so the
    gating data is a self-contained, easily-portable description.
    """

    PRESENT = "present"
    PAST = "past"


# Traversal-ability tokens. Granted by acquiring the corresponding ally/item.
# These are the abilities that physically gate terrain in the resolved logic.
WATER = "water_traversal"   # Faruk (Ch1)
LAVA = "lava_traversal"     # Holy Robe / Gubibi (Ch4)


@dataclass(frozen=True)
class Acquirable:
    """A progression item or ally the player can obtain.

    Attributes:
        token: Stable identifier the win requirement / gates reference.
        name: Human-readable name.
        era: The time period the acquisition region lives in.
        grants: Traversal-ability tokens this acquirable unlocks (may be empty;
            an ally/item can be required purely as a "have it" flag).
        section_hint: Optional section-type name (e.g. "DUNGEON") used only as a
            soft hint for region location; never a hard requirement.
        note: Free-form provenance / rationale.
    """

    token: str
    name: str
    era: Era
    grants: Tuple[str, ...] = ()
    section_hint: Optional[str] = None
    note: str = ""


@dataclass(frozen=True)
class WinRequirement:
    """What a chapter needs for the goal to be reachable & the boss beatable.

    Attributes:
        goal_name: Human-readable goal (boss / location).
        goal_era: The era the goal screen lives in (region the player must reach).
        goal_screens: Concrete relative screen indices of the goal (the chapter's
            boss arena). "Goal reached" = any of these is physically reachable.
            These anchor the differential check to a real location so losing the
            path to the boss that vanilla had is detectable. From
            ``core.enums.BOSS_SCREENS_BY_CHAPTER``.
        required_tokens: Acquirable tokens that must all be obtainable.
        required_abilities: Traversal abilities that must all be granted (these
            are normally implied by required_tokens but listed explicitly so the
            blocking reason can name the *terrain* gate, e.g. WATER/LAVA).
    """

    goal_name: str
    goal_era: Era
    goal_screens: Tuple[int, ...] = ()
    required_tokens: Tuple[str, ...] = ()
    required_abilities: Tuple[str, ...] = ()


@dataclass(frozen=True)
class ChapterGating:
    """All item-gating data for one chapter."""

    chapter: int
    entry_screen: int
    acquirables: Tuple[Acquirable, ...]
    win: WinRequirement

    def acquirable(self, token: str) -> Optional[Acquirable]:
        for a in self.acquirables:
            if a.token == token:
                return a
        return None


# =============================================================================
# The encoded gate logic (user-resolved; authoritative).
# =============================================================================

GATING: Dict[int, ChapterGating] = {
    1: ChapterGating(
        chapter=1,
        entry_screen=0,
        acquirables=(
            Acquirable(
                token="faruk",
                name="Faruk",
                era=Era.PAST,
                grants=(WATER,),
                note="Recruited in past Horen (reached via time door); grants water traversal.",
            ),
        ),
        win=WinRequirement(
            goal_name="Gilga (Aqua Palace)",
            goal_era=Era.PRESENT,
            goal_screens=(127, 128),
            required_tokens=("faruk",),
            required_abilities=(WATER,),
        ),
    ),
    2: ChapterGating(
        chapter=2,
        entry_screen=0,
        acquirables=(
            Acquirable(
                token="epin",
                name="Epin",
                era=Era.PRESENT,
                note="Spec-mandatory ally for the Curly fight.",
            ),
        ),
        win=WinRequirement(
            goal_name="Curly",
            goal_era=Era.PRESENT,
            goal_screens=(133, 134),
            required_tokens=("epin",),
        ),
    ),
    3: ChapterGating(
        chapter=3,
        entry_screen=0,
        acquirables=(
            Acquirable(
                token="pukin",
                name="Pukin",
                era=Era.PAST,
                note="Lights the dark maze via the Cimaron Rod; required to traverse it.",
            ),
            Acquirable(
                token="mustafa",
                name="Mustafa",
                era=Era.PRESENT,
                note="Required to beat the Troll.",
            ),
        ),
        win=WinRequirement(
            goal_name="Troll",
            goal_era=Era.PRESENT,
            goal_screens=(133, 134),
            required_tokens=("pukin", "mustafa"),
        ),
    ),
    4: ChapterGating(
        chapter=4,
        entry_screen=0,
        acquirables=(
            Acquirable(
                token="gubibi_holy_robe",
                name="Holy Robe (Gubibi)",
                era=Era.PAST,
                grants=(LAVA,),
                note="From Gubibi in the Fire Palace; grants lava traversal across the Lava Cape.",
            ),
            Acquirable(
                token="rainy",
                name="Rainy",
                era=Era.PRESENT,
                note="Spec-required ally for the Salamander fight.",
            ),
            Acquirable(
                token="crystal_rod",
                name="Crystal Rod",
                era=Era.PRESENT,
                note="Spec-required item for the Salamander fight.",
            ),
        ),
        win=WinRequirement(
            goal_name="Salamander",
            goal_era=Era.PRESENT,
            goal_screens=(139, 140),
            required_tokens=("gubibi_holy_robe", "rainy", "crystal_rod"),
            required_abilities=(LAVA,),
        ),
    ),
    5: ChapterGating(
        chapter=5,
        entry_screen=0,
        acquirables=(
            Acquirable(
                token="legend_sword",
                name="Legend Sword",
                era=Era.PRESENT,
                note="Required to reach / defeat GoraGora.",
            ),
            Acquirable(
                token="armor_of_light",
                name="Armor of Light",
                era=Era.PRESENT,
                note="Required to reach / defeat GoraGora.",
            ),
            Acquirable(
                token="isfa_rod",
                name="Isfa Rod",
                era=Era.PRESENT,
                note="Required to reach / defeat GoraGora.",
            ),
        ),
        win=WinRequirement(
            goal_name="GoraGora",
            goal_era=Era.PRESENT,
            goal_screens=(153,),
            required_tokens=("legend_sword", "armor_of_light", "isfa_rod"),
        ),
    ),
}


def chapter_gating(chapter: int) -> Optional[ChapterGating]:
    """Return the gating data for a chapter, or None if not modelled."""
    return GATING.get(chapter)


def all_required_tokens(chapter: int) -> List[str]:
    """All acquirable tokens required to win the chapter (empty if unmodelled)."""
    cg = GATING.get(chapter)
    if cg is None:
        return []
    return list(cg.win.required_tokens)
