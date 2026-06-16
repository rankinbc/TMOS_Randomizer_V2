"""Interior/exterior segregation validator -- Coherence oracle, Layer 2, Slice 1.

Coherence Law 2 (reverse-engineered from the original chapter maps): overworld
(exterior) screens are overwhelmingly segregated from dungeon-interior screens --
interiors are separate connected components reached by stairways or building
entrances, not by the directional navigation pointers. A randomization that lets
the player walk straight off a grass field into a dungeon room is the most
viscerally wrong "salad" failure.

Vanilla is NOT zero, though: Ch4 has 2 intentional exterior<->interior walkable
edges (the cave mouths you step straight into). This is exactly why the oracle is
DIFFERENTIAL, not absolute -- the vanilla baseline absorbs those intrinsic edges
and the gate fires only on edges introduced *beyond* vanilla. Reports ERROR
severity so it flows into the oracle's "no new errors vs vanilla" comparison.

Scope (Slice 1, deliberately conservative to avoid vanilla false positives):
  EXTERIOR = {OVERWORLD}
  INTERIOR = {DUNGEON, MINI_DUNGEON, MAZE}
All other classes (TOWN, SPECIAL, BOSS, VICTORY, UNKNOWN) are neutral and never
flagged. Future slices add clustering, seams, placement, hydrology, budget.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional, Set, Tuple, TYPE_CHECKING

from ..base import (
    Validator,
    ValidatorRegistry,
    ValidationIssue,
    Severity,
    ValidationPhase,
)
from ...core.enums import SectionType

if TYPE_CHECKING:
    from ...core.chapter import Chapter

_DIRECTIONS = ("up", "down", "left", "right")

EXTERIOR_CLASSES: Set[SectionType] = {SectionType.OVERWORLD}
INTERIOR_CLASSES: Set[SectionType] = {
    SectionType.DUNGEON,
    SectionType.MINI_DUNGEON,
    SectionType.MAZE,
}


def _class_of(screen: Any) -> Optional[str]:
    """Return 'exterior', 'interior', or None (neutral) for a screen."""
    st = screen.section_type
    if st in EXTERIOR_CLASSES:
        return "exterior"
    if st in INTERIOR_CLASSES:
        return "interior"
    return None


@ValidatorRegistry.register
class InteriorExteriorSegregationValidator(Validator):
    """Flags walkable adjacencies between overworld and dungeon-interior screens."""

    VALIDATOR_ID = "interior_exterior_segregation"
    DISPLAY_NAME = "Interior/Exterior Segregation"
    DESCRIPTION = (
        "Coherence L2: overworld screens must not be walkable-adjacent to "
        "dungeon-interior screens (vanilla links them via stairways only)."
    )
    DEFAULT_SEVERITY = Severity.ERROR
    SUPPORTED_PHASES = {ValidationPhase.FINAL}

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Optional[Dict[str, Any]] = None,
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        seen_edges: Set[Tuple[int, int]] = set()

        for screen in chapter:
            src_class = _class_of(screen)
            if src_class is None:
                continue

            for direction in _DIRECTIONS:
                neighbor_idx = screen.get_neighbor(direction)
                if neighbor_idx is None:  # blocked / building entrance / not walkable
                    continue

                neighbor = chapter.get_screen(neighbor_idx)
                if neighbor is None:
                    continue

                dst_class = _class_of(neighbor)
                if dst_class is None or dst_class == src_class:
                    continue

                # Mismatch: one side exterior, the other interior. Count once.
                edge = (
                    min(screen.relative_index, neighbor.relative_index),
                    max(screen.relative_index, neighbor.relative_index),
                )
                if edge in seen_edges:
                    continue
                seen_edges.add(edge)

                ext_idx, int_idx = (
                    (screen.relative_index, neighbor.relative_index)
                    if src_class == "exterior"
                    else (neighbor.relative_index, screen.relative_index)
                )
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=self.effective_severity,
                    message=(
                        f"Overworld screen {ext_idx} is walkable-adjacent to "
                        f"dungeon-interior screen {int_idx} "
                        f"({screen.section_type.name} {direction} "
                        f"{neighbor.section_type.name})"
                    ),
                    screen_index=ext_idx,
                    chapter_num=chapter.chapter_num,
                    direction=direction,
                    category="segregation",
                    details={
                        "exterior_screen": ext_idx,
                        "interior_screen": int_idx,
                        "exterior_section": screen.section_type.name
                        if src_class == "exterior" else neighbor.section_type.name,
                        "interior_section": neighbor.section_type.name
                        if dst_class == "interior" else screen.section_type.name,
                    },
                ))

        return issues
