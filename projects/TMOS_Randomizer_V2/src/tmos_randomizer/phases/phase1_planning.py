"""Phase 1: Section Planning - Determine section counts and sizes per chapter.

This phase determines:
- How many of each section type (overworld, town, dungeon, maze) per chapter
- Target screen counts for each section
- Ensures required sections exist (at least one town, one dungeon per chapter)
"""

from __future__ import annotations

import random
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

from ..core.constants import CHAPTER_OFFSETS
from ..core.enums import SectionType
from ..io.config_loader import RandomizerConfig


# =============================================================================
# Planning Data Structures
# =============================================================================

@dataclass
class SectionPlan:
    """Plan for a single section within a chapter."""

    section_type: SectionType
    section_id: int  # Unique ID within chapter (e.g., "town_1", "town_2")
    target_screen_count: int
    min_screens: int = 1
    max_screens: int = 50
    shape: str = "blob"  # blob, linear, branching, grid
    is_required: bool = False
    preserve_original: bool = False  # For mazes, boss areas

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "section_type": self.section_type.name,
            "section_id": self.section_id,
            "target_screen_count": self.target_screen_count,
            "min_screens": self.min_screens,
            "max_screens": self.max_screens,
            "shape": self.shape,
            "is_required": self.is_required,
            "preserve_original": self.preserve_original,
        }


@dataclass
class ChapterPlan:
    """Complete section plan for a chapter."""

    chapter_num: int
    total_screens: int
    sections: List[SectionPlan] = field(default_factory=list)
    reserved_screens: int = 0  # Screens reserved for excluded areas (boss, etc.)

    @property
    def planned_screens(self) -> int:
        """Total screens planned across all sections."""
        return sum(s.target_screen_count for s in self.sections)

    @property
    def remaining_screens(self) -> int:
        """Screens not yet allocated to sections."""
        return self.total_screens - self.planned_screens - self.reserved_screens

    def get_sections_by_type(self, section_type: SectionType) -> List[SectionPlan]:
        """Get all sections of a specific type."""
        return [s for s in self.sections if s.section_type == section_type]

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "chapter_num": self.chapter_num,
            "total_screens": self.total_screens,
            "sections": [s.to_dict() for s in self.sections],
            "reserved_screens": self.reserved_screens,
            "planned_screens": self.planned_screens,
            "remaining_screens": self.remaining_screens,
        }


@dataclass
class WorldPlan:
    """Complete section plan for all chapters."""

    chapters: List[ChapterPlan] = field(default_factory=list)
    seed: int = 0

    def get_chapter(self, chapter_num: int) -> Optional[ChapterPlan]:
        """Get plan for a specific chapter."""
        for chapter in self.chapters:
            if chapter.chapter_num == chapter_num:
                return chapter
        return None

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "seed": self.seed,
            "chapters": [c.to_dict() for c in self.chapters],
        }


# =============================================================================
# Default Section Requirements
# =============================================================================

# Minimum and default screen counts per section type
SECTION_DEFAULTS: Dict[str, Dict[str, int]] = {
    "overworld": {"min": 15, "default": 30, "max": 60},
    "town": {"min": 4, "default": 6, "max": 12},
    "dungeon": {"min": 8, "default": 20, "max": 40},
    "maze": {"min": 4, "default": 10, "max": 20},
    "special": {"min": 2, "default": 5, "max": 15},
}

# Required sections per chapter (minimum counts)
REQUIRED_SECTIONS: Dict[SectionType, int] = {
    SectionType.OVERWORLD: 1,
    SectionType.TOWN: 2,
    SectionType.DUNGEON: 1,
}

# Reserved screens per chapter (boss, victory, etc.)
RESERVED_SCREENS_PER_CHAPTER: Dict[int, int] = {
    1: 12,  # Boss area + victory + special events
    2: 10,
    3: 15,  # Chapter 3 has more special events
    4: 12,
    5: 20,  # Chapter 5 has multiple boss areas
}


# =============================================================================
# Planning Functions
# =============================================================================

def create_chapter_plan(
    chapter_num: int,
    config: RandomizerConfig,
    rng: random.Random,
) -> ChapterPlan:
    """Create a section plan for a single chapter.

    Args:
        chapter_num: Chapter number (1-5)
        config: Randomizer configuration
        rng: Random number generator

    Returns:
        ChapterPlan with section allocations
    """
    _, screen_count = CHAPTER_OFFSETS[chapter_num]
    reserved = RESERVED_SCREENS_PER_CHAPTER.get(chapter_num, 10)

    plan = ChapterPlan(
        chapter_num=chapter_num,
        total_screens=screen_count,
        reserved_screens=reserved,
    )

    # Available screens for section allocation
    available = screen_count - reserved

    # Step 1: Add required sections
    _add_required_sections(plan, config, rng)

    # Step 2: Allocate remaining screens based on config percentages
    _allocate_remaining_screens(plan, available, config, rng)

    return plan


def _add_required_sections(
    plan: ChapterPlan,
    config: RandomizerConfig,
    rng: random.Random,
) -> None:
    """Add required sections (minimum one of each type) to the plan."""
    section_id = 0

    # Add required overworld sections
    overworld_count = REQUIRED_SECTIONS.get(SectionType.OVERWORLD, 1)
    for i in range(overworld_count):
        defaults = SECTION_DEFAULTS["overworld"]
        section_id += 1
        plan.sections.append(SectionPlan(
            section_type=SectionType.OVERWORLD,
            section_id=section_id,
            target_screen_count=defaults["min"],
            min_screens=defaults["min"],
            max_screens=defaults["max"],
            shape=_get_shape_for_section(SectionType.OVERWORLD, config),
            is_required=True,
        ))

    # Add required town sections
    town_count = REQUIRED_SECTIONS.get(SectionType.TOWN, 2)
    for i in range(town_count):
        defaults = SECTION_DEFAULTS["town"]
        section_id += 1
        plan.sections.append(SectionPlan(
            section_type=SectionType.TOWN,
            section_id=section_id,
            target_screen_count=defaults["min"],
            min_screens=defaults["min"],
            max_screens=defaults["max"],
            shape="linear",
            is_required=True,
        ))

    # Add required dungeon section
    dungeon_count = REQUIRED_SECTIONS.get(SectionType.DUNGEON, 1)
    for i in range(dungeon_count):
        defaults = SECTION_DEFAULTS["dungeon"]
        section_id += 1
        plan.sections.append(SectionPlan(
            section_type=SectionType.DUNGEON,
            section_id=section_id,
            target_screen_count=defaults["min"],
            min_screens=defaults["min"],
            max_screens=defaults["max"],
            shape=_get_shape_for_section(SectionType.DUNGEON, config),
            is_required=True,
        ))

    # Add maze section (preserved by default)
    maze_enabled = config.shuffling.get("mazes", None)
    if maze_enabled is None or not maze_enabled.enabled:
        defaults = SECTION_DEFAULTS["maze"]
        section_id += 1
        plan.sections.append(SectionPlan(
            section_type=SectionType.MAZE,
            section_id=section_id,
            target_screen_count=defaults["default"],
            min_screens=defaults["min"],
            max_screens=defaults["max"],
            shape="maze",
            preserve_original=True,
        ))


def _allocate_remaining_screens(
    plan: ChapterPlan,
    available: int,
    config: RandomizerConfig,
    rng: random.Random,
) -> None:
    """Allocate remaining screens to sections based on config percentages."""
    remaining = available - plan.planned_screens

    if remaining <= 0:
        return

    # Get target percentages from config (sections.percentages)
    percentages = config.get("sections.percentages", {
        "overworld": 30,
        "dungeon": 20,
        "maze": 15,
        "town": 10,
        "special": 20,
        "boss": 5,  # Already reserved
    })

    # Calculate target screens for each type
    type_targets: Dict[str, int] = {}
    total_percent = sum(v for k, v in percentages.items() if k != "boss")

    for section_name, percent in percentages.items():
        if section_name == "boss":
            continue  # Already reserved
        type_targets[section_name] = int(remaining * percent / total_percent)

    # Distribute to existing sections first
    for section in plan.sections:
        type_name = section.section_type.name.lower()
        target = type_targets.get(type_name, 0)

        if target > 0:
            additional = min(target, section.max_screens - section.target_screen_count)
            section.target_screen_count += additional
            type_targets[type_name] -= additional

    # Add new sections if we have significant remaining allocation
    section_id = max(s.section_id for s in plan.sections) if plan.sections else 0

    for type_name, target in type_targets.items():
        if target < SECTION_DEFAULTS.get(type_name, {}).get("min", 3):
            continue

        section_type = _name_to_section_type(type_name)
        if section_type is None:
            continue

        defaults = SECTION_DEFAULTS.get(type_name, {})
        section_id += 1

        plan.sections.append(SectionPlan(
            section_type=section_type,
            section_id=section_id,
            target_screen_count=target,
            min_screens=defaults.get("min", 2),
            max_screens=defaults.get("max", 30),
            shape=_get_shape_for_section(section_type, config),
        ))


def _get_shape_for_section(section_type: SectionType, config: RandomizerConfig) -> str:
    """Get the shape configuration for a section type."""
    type_name = section_type.name.lower()

    # Check if there's a shuffling config for this type
    if type_name in config.shuffling:
        return config.shuffling[type_name].shape

    # Defaults
    shape_defaults = {
        SectionType.OVERWORLD: "blob",
        SectionType.TOWN: "linear",
        SectionType.DUNGEON: "branching",
        SectionType.MAZE: "maze",
        SectionType.SPECIAL: "branching",
    }
    return shape_defaults.get(section_type, "blob")


def _name_to_section_type(name: str) -> Optional[SectionType]:
    """Convert section name string to SectionType enum."""
    name_map = {
        "overworld": SectionType.OVERWORLD,
        "town": SectionType.TOWN,
        "dungeon": SectionType.DUNGEON,
        "maze": SectionType.MAZE,
        "special": SectionType.SPECIAL,
        "boss": SectionType.BOSS,
    }
    return name_map.get(name.lower())


# =============================================================================
# Main Planning Function
# =============================================================================

def plan_randomization(
    config: RandomizerConfig,
    seed: Optional[int] = None,
) -> WorldPlan:
    """Create a complete randomization plan for all chapters.

    Args:
        config: Randomizer configuration
        seed: Optional seed for randomization (uses config.general.seed if None)

    Returns:
        WorldPlan with section allocations for all chapters
    """
    # Get seed
    actual_seed = seed if seed is not None else config.general.seed
    if actual_seed == 0:
        actual_seed = random.randint(1, 2**31 - 1)

    rng = random.Random(actual_seed)

    world_plan = WorldPlan(seed=actual_seed)

    # Plan each chapter
    for chapter_num in config.general.chapters:
        chapter_plan = create_chapter_plan(chapter_num, config, rng)
        world_plan.chapters.append(chapter_plan)

    return world_plan


def validate_plan(plan: WorldPlan) -> List[str]:
    """Validate a randomization plan for consistency.

    Args:
        plan: WorldPlan to validate

    Returns:
        List of error messages (empty if valid)
    """
    errors = []

    for chapter_plan in plan.chapters:
        chapter_num = chapter_plan.chapter_num

        # Check total screens don't exceed chapter limit
        if chapter_plan.planned_screens > chapter_plan.total_screens:
            errors.append(
                f"Chapter {chapter_num}: Planned {chapter_plan.planned_screens} screens "
                f"exceeds total {chapter_plan.total_screens}"
            )

        # Check required sections exist
        for section_type, required_count in REQUIRED_SECTIONS.items():
            actual = len(chapter_plan.get_sections_by_type(section_type))
            if actual < required_count:
                errors.append(
                    f"Chapter {chapter_num}: Missing required {section_type.name} sections "
                    f"(have {actual}, need {required_count})"
                )

        # Check section sizes are valid
        for section in chapter_plan.sections:
            if section.target_screen_count < section.min_screens:
                errors.append(
                    f"Chapter {chapter_num}: Section {section.section_id} "
                    f"({section.section_type.name}) has {section.target_screen_count} screens "
                    f"but minimum is {section.min_screens}"
                )

    return errors
