"""Static item-gated winnability DETECTOR for the TMOS map randomizer.

Physical reachability proves you can *walk* everywhere; this package adds the
orthogonal question of **item-gated winnability** — are the progression items
obtainable in the order the game requires, so the seed is actually completable?

Per project direction the bar is "flag problems for review", NOT "guarantee
100%". This is a DETECTOR/REPORTER: it produces a per-chapter
winnable / needs-review verdict plus the specific blocking gate, and feeds a
"playable %" metric. It NEVER fail-closes the generation pipeline.

Public surface:
- ``model``       — the hand-modelled gate-logic data (user-resolved, authoritative).
- ``reachability``— era-aware physical reachability (reuses the real edge logic).
- ``checker``     — fixed-point checker producing structured verdicts.
- ``validator``   — registered INFO-only validator wrapper.
"""

from .checker import (
    Blocker,
    ChapterItemVerdict,
    ItemGatingBaseline,
    WorldItemVerdict,
    build_baseline,
    check_chapter,
    check_world,
)
from .model import (
    GATING,
    Acquirable,
    ChapterGating,
    Era,
    WinRequirement,
    chapter_gating,
)
from .reachability import EraReachability, compute_era_reachability
from .validator import ItemGatingValidator

__all__ = [
    "Acquirable",
    "Blocker",
    "ChapterGating",
    "ChapterItemVerdict",
    "Era",
    "EraReachability",
    "GATING",
    "ItemGatingBaseline",
    "ItemGatingValidator",
    "WinRequirement",
    "WorldItemVerdict",
    "build_baseline",
    "chapter_gating",
    "check_chapter",
    "check_world",
    "compute_era_reachability",
]
