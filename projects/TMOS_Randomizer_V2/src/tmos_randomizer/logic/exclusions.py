"""Screen exclusion logic for randomization.

Defines which screens should NOT be randomized to preserve game functionality.
Data sourced from: docs/planning/exclusion-list.md
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet, Optional, Set

from ..core.worldscreen import WorldScreen
from ..core.chapter import Chapter
from ..core.enums import (
    DO_NOT_RANDOMIZE,
    BOSS_SCREENS,
    VICTORY_SCREENS,
    WIZARD_SCREENS,
    SPECIAL_EVENT_SCREENS,
    ENEMY_DOOR_PAIRS,
)


# =============================================================================
# Exclusion Categories
# =============================================================================

@dataclass(frozen=True)
class ExclusionReason:
    """Reason why a screen is excluded from randomization."""

    category: str
    description: str
    can_override: bool = False


# Pre-defined exclusion reasons
REASON_BOSS = ExclusionReason("boss", "Boss encounter screen", False)
REASON_VICTORY = ExclusionReason("victory", "Post-boss victory screen", False)
REASON_WIZARD = ExclusionReason("wizard", "Wizard battle trigger", False)
REASON_SPECIAL_EVENT = ExclusionReason("special_event", "Story/dialog trigger", True)
REASON_ENEMY_DOOR = ExclusionReason("enemy_door", "Enemy door screen", True)
REASON_DANGEROUS_EVENT = ExclusionReason("dangerous_event", "Non-standard Event byte", True)


# =============================================================================
# Core Exclusion Data
# =============================================================================

# Boss screens by chapter (relative indices)
BOSS_SCREENS_BY_CHAPTER: dict[int, FrozenSet[int]] = {
    1: frozenset({118, 127, 128}),
    2: frozenset({133, 134}),  # 264-131, 265-131
    3: frozenset({133, 134}),  # 401-268, 402-268
    4: frozenset({139, 140}),  # 560-421, 561-421
    5: frozenset({47, 55, 65, 152, 153}),  # 632-585, 640-585, 650-585, 737-585, 738-585
}

# Victory screens by chapter (relative indices)
VICTORY_SCREENS_BY_CHAPTER: dict[int, FrozenSet[int]] = {
    1: frozenset({129}),
    2: frozenset({135}),  # 266-131
    3: frozenset({135}),  # 403-268
    4: frozenset({141}),  # 562-421
    5: frozenset(),  # No victory screen in Ch5
}

# Safe Event bytes that can be randomized
SAFE_EVENTS: FrozenSet[int] = frozenset({0x00, 0x08, 0x22, 0x40})

# Dangerous Event bytes that should not be randomized
DANGEROUS_EVENTS: FrozenSet[int] = frozenset({
    0x01, 0x03, 0x09, 0x10, 0x20, 0x47, 0x48, 0x60, 0x62, 0x80, 0xC0
})


# =============================================================================
# Exclusion Checking Functions
# =============================================================================

def is_excluded(screen: WorldScreen) -> bool:
    """Check if a screen should be excluded from randomization.

    Uses the pre-computed global exclusion set for speed.

    Args:
        screen: WorldScreen to check

    Returns:
        True if screen should be excluded
    """
    return screen.global_index in DO_NOT_RANDOMIZE


def get_exclusion_reason(screen: WorldScreen) -> Optional[ExclusionReason]:
    """Get the reason why a screen is excluded.

    Args:
        screen: WorldScreen to check

    Returns:
        ExclusionReason if excluded, None if safe to randomize
    """
    global_idx = screen.global_index

    # Check each category
    if global_idx in BOSS_SCREENS:
        return REASON_BOSS

    if global_idx in VICTORY_SCREENS:
        return REASON_VICTORY

    if global_idx in WIZARD_SCREENS:
        return REASON_WIZARD

    if global_idx in SPECIAL_EVENT_SCREENS:
        return REASON_SPECIAL_EVENT

    if screen.is_enemy_door_screen:
        return REASON_ENEMY_DOOR

    if screen.event not in SAFE_EVENTS and screen.event != 0:
        return REASON_DANGEROUS_EVENT

    return None


def is_boss_screen(screen: WorldScreen) -> bool:
    """Check if screen is a boss encounter screen."""
    return screen.global_index in BOSS_SCREENS


def is_victory_screen(screen: WorldScreen) -> bool:
    """Check if screen is a post-boss victory screen."""
    return screen.global_index in VICTORY_SCREENS


def is_wizard_screen(screen: WorldScreen) -> bool:
    """Check if screen triggers a wizard battle."""
    return screen.global_index in WIZARD_SCREENS


def has_dangerous_event(screen: WorldScreen) -> bool:
    """Check if screen has a dangerous/unknown Event byte."""
    return screen.event in DANGEROUS_EVENTS


def is_enemy_door_screen(screen: WorldScreen) -> bool:
    """Check if screen is an enemy door screen."""
    return (screen.parent_world, screen.objectset) in ENEMY_DOOR_PAIRS


# =============================================================================
# Chapter-Level Exclusion Functions
# =============================================================================

def get_excluded_screens(chapter: Chapter) -> list[WorldScreen]:
    """Get all excluded screens in a chapter.

    Args:
        chapter: Chapter to check

    Returns:
        List of excluded WorldScreens
    """
    return [s for s in chapter if is_excluded(s)]


def get_randomizable_screens(chapter: Chapter) -> list[WorldScreen]:
    """Get all screens that can be safely randomized.

    Args:
        chapter: Chapter to check

    Returns:
        List of randomizable WorldScreens
    """
    return [s for s in chapter if not is_excluded(s)]


def get_exclusion_breakdown(chapter: Chapter) -> dict[str, list[int]]:
    """Get breakdown of excluded screens by category.

    Args:
        chapter: Chapter to analyze

    Returns:
        Dict mapping category name to list of relative indices
    """
    breakdown: dict[str, list[int]] = {
        "boss": [],
        "victory": [],
        "wizard": [],
        "special_event": [],
        "enemy_door": [],
        "dangerous_event": [],
    }

    for screen in chapter:
        reason = get_exclusion_reason(screen)
        if reason:
            breakdown[reason.category].append(screen.relative_index)

    return breakdown


def get_chapter_exclusion_stats(chapter: Chapter) -> dict[str, int]:
    """Get exclusion statistics for a chapter.

    Args:
        chapter: Chapter to analyze

    Returns:
        Dict with total, excluded, randomizable counts and percentage
    """
    excluded = len(get_excluded_screens(chapter))
    total = chapter.screen_count

    return {
        "total": total,
        "excluded": excluded,
        "randomizable": total - excluded,
        "excluded_percent": round(100 * excluded / total, 1) if total > 0 else 0,
    }


# =============================================================================
# Configurable Exclusion System
# =============================================================================

@dataclass
class ExclusionConfig:
    """Configuration for which screens to exclude.

    Allows overriding default exclusions for advanced users.
    """

    # Always exclude (required for game function)
    exclude_boss: bool = True
    exclude_victory: bool = True

    # Recommended exclude
    exclude_wizard: bool = True

    # Optional (may break story but game playable)
    exclude_special_events: bool = True
    exclude_enemy_doors: bool = True
    exclude_dangerous_events: bool = True

    # Custom additions (global indices)
    custom_exclude: Set[int] = None

    # Force include (override exclusions - use at own risk)
    force_include: Set[int] = None

    def __post_init__(self):
        if self.custom_exclude is None:
            self.custom_exclude = set()
        if self.force_include is None:
            self.force_include = set()


def build_exclusion_set(config: ExclusionConfig) -> FrozenSet[int]:
    """Build the set of excluded global indices based on config.

    Args:
        config: ExclusionConfig with exclusion settings

    Returns:
        FrozenSet of global indices to exclude
    """
    excluded: Set[int] = set()

    if config.exclude_boss:
        excluded |= BOSS_SCREENS
    if config.exclude_victory:
        excluded |= VICTORY_SCREENS
    if config.exclude_wizard:
        excluded |= WIZARD_SCREENS
    if config.exclude_special_events:
        excluded |= SPECIAL_EVENT_SCREENS

    # Add custom exclusions
    excluded |= config.custom_exclude

    # Remove force includes
    excluded -= config.force_include

    return frozenset(excluded)


def is_excluded_with_config(
    screen: WorldScreen,
    config: ExclusionConfig,
) -> bool:
    """Check if screen is excluded using custom config.

    Args:
        screen: WorldScreen to check
        config: ExclusionConfig with custom settings

    Returns:
        True if screen should be excluded
    """
    # Force include overrides everything
    if screen.global_index in config.force_include:
        return False

    # Custom exclude
    if screen.global_index in config.custom_exclude:
        return True

    # Check configured categories
    if config.exclude_boss and screen.global_index in BOSS_SCREENS:
        return True
    if config.exclude_victory and screen.global_index in VICTORY_SCREENS:
        return True
    if config.exclude_wizard and screen.global_index in WIZARD_SCREENS:
        return True
    if config.exclude_special_events and screen.global_index in SPECIAL_EVENT_SCREENS:
        return True
    if config.exclude_enemy_doors and screen.is_enemy_door_screen:
        return True
    if config.exclude_dangerous_events and has_dangerous_event(screen):
        return True

    return False


# =============================================================================
# Validation
# =============================================================================

def validate_exclusions(chapter: Chapter) -> list[str]:
    """Validate that exclusions are consistent.

    Checks that excluded screens form valid groups (e.g., boss pairs).

    Args:
        chapter: Chapter to validate

    Returns:
        List of warning messages (empty if valid)
    """
    warnings = []

    # Check that boss screens are paired
    boss_screens = [s for s in chapter if is_boss_screen(s)]
    if len(boss_screens) % 2 != 0:
        warnings.append(
            f"Chapter {chapter.chapter_num}: Odd number of boss screens ({len(boss_screens)})"
        )

    # Check that excluded screens don't have critical connections to non-excluded
    excluded_indices = {s.relative_index for s in chapter if is_excluded(s)}
    for screen in chapter:
        if is_excluded(screen):
            continue
        # Check if non-excluded screen connects to excluded
        for neighbor in screen.get_connected_screens():
            if neighbor in excluded_indices:
                # This is expected for boss entrances, but warn for others
                pass  # Future: more sophisticated validation

    return warnings
