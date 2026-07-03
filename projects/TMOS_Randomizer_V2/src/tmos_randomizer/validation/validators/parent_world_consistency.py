"""ParentWorld (WorldScreen byte 0) consistency validator.

RE round-2 (knowledge/systems/screen-relocation-constraints.md): ParentWorld
is cosmetic + time-period only — music variant, palette tint, past-area flag
(hi4 >= $E), RING-teleport lookup ($AAE7 indexed by lo4), ambient SFX. It
never drives enemy spawns, so "biome salad" is mechanically safe. Two cheap
consistency rules remain worth checking:

1. Past-flag: a screen whose ParentWorld hi4 >= $E marks itself as a PAST
   area (bank 4 $8335 selects past-area music from it). This must agree with
   the screen's index-based time period, or the player gets past presentation
   on a present screen (and vice versa).
2. RING-teleport lo4: the RING teleport indexes the $AAE7 table with
   ParentWorld lo4. If randomization leaves a different lo4 at a slot than
   vanilla had, RING teleports from that screen resolve through a different
   table entry. The $AAE7 contents are not yet decoded, so the cheap rule is
   drift detection against the vanilla ROM byte at the same slot.

Both are cosmetic-to-mild, hence WARNING by default.
"""

from __future__ import annotations

from typing import Any, Dict, List, TYPE_CHECKING

from ...core.constants import get_worldscreen_address
from ...core.enums import is_past_screen_index
from ..base import (
    Severity,
    ValidationIssue,
    ValidationPhase,
    Validator,
    ValidatorRegistry,
)
from ..config import ParentWorldConsistencyConfig

if TYPE_CHECKING:
    from ...core.chapter import Chapter


@ValidatorRegistry.register
class ParentWorldConsistencyValidator(Validator):
    """Flag ParentWorld bytes inconsistent with a screen's slot."""

    VALIDATOR_ID = "parent_world_consistency"
    DISPLAY_NAME = "ParentWorld Consistency"
    DESCRIPTION = (
        "Checks the ParentWorld past-flag (hi4 >= $E) agrees with each "
        "screen's index-based time period, and that RING-teleport lo4 "
        "values did not drift from vanilla."
    )
    DEFAULT_SEVERITY = Severity.WARNING
    SUPPORTED_PHASES = {ValidationPhase.FINAL}

    def __init__(self, config=None):
        self._issues: List[ValidationIssue] = []
        if isinstance(config, ParentWorldConsistencyConfig):
            self.config = config
        else:
            self.config = ParentWorldConsistencyConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        if not self.config.enabled:
            return []

        issues: List[ValidationIssue] = []
        severity = Severity.from_string(self.config.severity)
        chapter_num = chapter.chapter_num
        rom_data = (context or {}).get("rom_data")

        for screen in chapter.screens:
            if self.config.check_past_flag:
                flag_past = (screen.parent_world >> 4) >= 0xE
                slot_past = is_past_screen_index(chapter_num, screen.relative_index)
                if flag_past != slot_past:
                    issues.append(ValidationIssue(
                        validator_id=self.VALIDATOR_ID,
                        severity=severity,
                        message=(
                            f"Screen {screen.relative_index}: ParentWorld "
                            f"0x{screen.parent_world:02X} marks "
                            f"{'PAST' if flag_past else 'PRESENT'} but the slot is "
                            f"{'PAST' if slot_past else 'PRESENT'} "
                            "(wrong music/palette in-game)"
                        ),
                        screen_index=screen.relative_index,
                        chapter_num=chapter_num,
                        category="past_flag_mismatch",
                        details={
                            "parent_world": screen.parent_world,
                            "flag_past": flag_past,
                            "slot_past": slot_past,
                        },
                    ))
                    if len(issues) >= self.config.max_issues:
                        return issues

            if self.config.check_ring_lo4 and rom_data is not None:
                offset = get_worldscreen_address(chapter_num, screen.relative_index)
                vanilla_lo4 = rom_data[offset] & 0x0F
                new_lo4 = screen.parent_world & 0x0F
                if vanilla_lo4 != new_lo4:
                    issues.append(ValidationIssue(
                        validator_id=self.VALIDATOR_ID,
                        severity=severity,
                        message=(
                            f"Screen {screen.relative_index}: ParentWorld lo4 "
                            f"changed 0x{vanilla_lo4:X} -> 0x{new_lo4:X} "
                            "(RING teleport resolves through a different "
                            "$AAE7 entry)"
                        ),
                        screen_index=screen.relative_index,
                        chapter_num=chapter_num,
                        category="ring_lo4_drift",
                        details={
                            "vanilla_lo4": vanilla_lo4,
                            "new_lo4": new_lo4,
                            "parent_world": screen.parent_world,
                        },
                    ))
                    if len(issues) >= self.config.max_issues:
                        return issues

        return issues
