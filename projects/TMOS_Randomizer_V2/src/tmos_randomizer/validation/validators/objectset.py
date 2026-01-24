"""DataPointer-ObjectSet compatibility validator.

This validator ensures that ObjectSets assigned to screens are compatible
with the screen's CHR bank (sprite graphics). Incompatible assignments
would cause graphical glitches or crashes.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional, Set, TYPE_CHECKING

from ..base import (
    Validator,
    ValidatorRegistry,
    ValidationIssue,
    Severity,
    ValidationPhase,
)
from ..config import DataPointerObjectSetConfig

if TYPE_CHECKING:
    from ...core.chapter import Chapter
    from ...core.worldscreen import WorldScreen
    from ...core.objectset_registry import ObjectSetRegistry


def get_chr_index(datapointer: int) -> int:
    """Extract CHR bank index from DataPointer value.

    The lower 6 bits of DataPointer specify the CHR bank index.

    Args:
        datapointer: DataPointer byte value

    Returns:
        CHR bank index (0-63)
    """
    return datapointer & 0x3F


@ValidatorRegistry.register
class DataPointerObjectSetValidator(Validator):
    """Validates ObjectSet compatibility with screen CHR banks.

    Each screen has a DataPointer that specifies which CHR bank
    (sprite graphics) to use. ObjectSets must be compatible with
    this CHR bank or sprites will display incorrectly.
    """

    VALIDATOR_ID = "datapointer_objectset"
    DEFAULT_SEVERITY = Severity.ERROR
    SUPPORTED_PHASES = {ValidationPhase.DURING_POPULATION, ValidationPhase.FINAL}

    def __init__(self, config: Optional[DataPointerObjectSetConfig] = None):
        """Initialize with configuration.

        Args:
            config: ObjectSet validation settings
        """
        self.config = config or DataPointerObjectSetConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate ObjectSet compatibility for all screens in a chapter.

        Args:
            chapter: Chapter to validate
            context: Validation context with optional objectset_registry

        Returns:
            List of validation issues found
        """
        if not self.config.enabled:
            return []

        issues: List[ValidationIssue] = []
        registry = context.get("objectset_registry")

        for screen in chapter.screens:
            screen_issues = self._validate_screen(
                screen,
                chapter.chapter_number,
                registry,
            )
            issues.extend(screen_issues)

            # Check max issues limit
            if len(issues) >= self.config.max_issues:
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=Severity.INFO,
                    message=f"Stopped after {self.config.max_issues} issues (limit reached)",
                    screen_index=None,
                    chapter_num=chapter.chapter_number,
                ))
                break

        return issues

    def _validate_screen(
        self,
        screen: "WorldScreen",
        chapter_num: int,
        registry: Optional["ObjectSetRegistry"],
    ) -> List[ValidationIssue]:
        """Validate ObjectSet compatibility for a single screen.

        Args:
            screen: Screen to validate
            chapter_num: Chapter number for issue reporting
            registry: Optional ObjectSetRegistry for detailed compatibility checking

        Returns:
            List of validation issues
        """
        issues: List[ValidationIssue] = []

        # Get CHR index from DataPointer
        chr_index = get_chr_index(screen.datapointer)

        # Get the screen's ObjectSet
        objectset = screen.objectset

        # Skip screens without ObjectSet (empty screens)
        if objectset is None or objectset == 0:
            return issues

        # If we have a registry, do detailed compatibility check
        if registry is not None:
            objectset_info = registry.get(chapter_num, objectset)

            if objectset_info is not None:
                # Check if this ObjectSet is compatible with the CHR index
                if chr_index not in objectset_info.chr_indices:
                    severity = Severity.from_string(self.config.severity)

                    issues.append(ValidationIssue(
                        validator_id=self.VALIDATOR_ID,
                        severity=severity,
                        message=(
                            f"Screen {screen.relative_index}: ObjectSet {objectset:#04x} "
                            f"incompatible with CHR bank {chr_index:#04x}. "
                            f"Compatible CHR banks: {sorted(objectset_info.chr_indices)}"
                        ),
                        screen_index=screen.relative_index,
                        chapter_num=chapter_num,
                        details={
                            "objectset": objectset,
                            "chr_index": chr_index,
                            "datapointer": screen.datapointer,
                            "compatible_chr_indices": list(objectset_info.chr_indices),
                            "objectset_category": objectset_info.category,
                            "objectset_difficulty": objectset_info.difficulty_tier.name,
                        },
                    ))
            elif self.config.strict_mode:
                # ObjectSet not in registry (strict mode = error)
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=Severity.WARNING,
                    message=(
                        f"Screen {screen.relative_index}: ObjectSet {objectset:#04x} "
                        f"not found in registry (cannot verify compatibility)"
                    ),
                    screen_index=screen.relative_index,
                    chapter_num=chapter_num,
                    details={
                        "objectset": objectset,
                        "chr_index": chr_index,
                        "datapointer": screen.datapointer,
                    },
                ))
        else:
            # No registry available - use heuristic validation
            issues.extend(self._validate_without_registry(
                screen,
                chr_index,
                objectset,
                chapter_num,
            ))

        return issues

    def _validate_without_registry(
        self,
        screen: "WorldScreen",
        chr_index: int,
        objectset: int,
        chapter_num: int,
    ) -> List[ValidationIssue]:
        """Validate ObjectSet using heuristic rules when no registry available.

        This provides basic sanity checks without detailed compatibility data.

        Args:
            screen: Screen to validate
            chr_index: CHR bank index
            objectset: ObjectSet ID
            chapter_num: Chapter number

        Returns:
            List of validation issues
        """
        issues: List[ValidationIssue] = []

        # Heuristic: Town screens (certain DataPointer ranges) shouldn't have enemy ObjectSets
        # This is a rough heuristic and may not be 100% accurate
        is_likely_town = screen.datapointer >= 0xC0

        # ObjectSets 0x00-0x10 are typically town NPCs
        is_town_objectset = objectset <= 0x10

        if is_likely_town and not is_town_objectset:
            if self.config.strict_mode:
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=Severity.WARNING,
                    message=(
                        f"Screen {screen.relative_index}: Possible mismatch - "
                        f"town screen (DataPointer {screen.datapointer:#04x}) "
                        f"with non-town ObjectSet {objectset:#04x}"
                    ),
                    screen_index=screen.relative_index,
                    chapter_num=chapter_num,
                    details={
                        "objectset": objectset,
                        "chr_index": chr_index,
                        "datapointer": screen.datapointer,
                        "heuristic": "town_screen_with_enemy_objectset",
                    },
                ))

        # Heuristic: Very high ObjectSet IDs are often unused/invalid
        if objectset >= 0xF0 and not self.config.allow_unknown_chr:
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.WARNING,
                message=(
                    f"Screen {screen.relative_index}: Unusually high ObjectSet ID "
                    f"{objectset:#04x} (may be invalid)"
                ),
                screen_index=screen.relative_index,
                chapter_num=chapter_num,
                details={
                    "objectset": objectset,
                    "chr_index": chr_index,
                    "datapointer": screen.datapointer,
                    "heuristic": "high_objectset_id",
                },
            ))

        return issues

    def validate_world(
        self,
        game_world: Any,
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate ObjectSet compatibility across all chapters.

        Args:
            game_world: Game world with chapters
            context: Validation context

        Returns:
            List of all validation issues
        """
        issues: List[ValidationIssue] = []

        for chapter in game_world.chapters:
            chapter_issues = self.validate_chapter(chapter, context)
            issues.extend(chapter_issues)

        return issues


# =============================================================================
# CHR Compatibility Tables (for reference)
# =============================================================================

# Known CHR bank groupings for common screen types
# These are approximate and may need refinement based on actual ROM data

CHR_BANK_DESCRIPTIONS: Dict[int, str] = {
    0x00: "Standard overworld sprites",
    0x01: "Overworld variant 1",
    0x02: "Overworld variant 2",
    0x10: "Dungeon sprites set A",
    0x11: "Dungeon sprites set B",
    0x20: "Town/building sprites",
    0x30: "Special area sprites",
}


def get_chr_bank_description(chr_index: int) -> str:
    """Get human-readable description of a CHR bank.

    Args:
        chr_index: CHR bank index

    Returns:
        Description string
    """
    return CHR_BANK_DESCRIPTIONS.get(chr_index, f"Unknown CHR bank {chr_index:#04x}")
