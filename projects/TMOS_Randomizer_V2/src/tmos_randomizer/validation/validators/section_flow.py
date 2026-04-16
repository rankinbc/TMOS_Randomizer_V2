"""Section flow validator.

This validator ensures that the actual navigation structure matches
the planned section flow. It detects when sections become fragmented
or when inter-section connections are missing.

This is critical for ensuring the randomization actually follows
the designed world structure (OVERWORLD → TOWN → DUNGEON etc).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Set, TYPE_CHECKING

from ..base import (
    Validator,
    ValidatorRegistry,
    ValidationIssue,
    Severity,
    ValidationPhase,
)
from ..config import SectionFlowConfig
from ...logic.navigation import find_components_in_subset, find_connected_components

if TYPE_CHECKING:
    from ...core.chapter import Chapter
    from ...models.plan import ChapterPlan, SectionPlan
    from ...models.population import ChapterPopulation


@dataclass
class SectionAnalysis:
    """Analysis result for a single section."""

    section_id: int
    section_type: str
    planned_screens: int
    assigned_screens: int
    screen_indices: List[int]
    fragment_count: int
    fragment_sizes: List[int]
    is_unified: bool
    largest_fragment_ratio: float  # largest fragment / total screens


@dataclass
class ConnectionAnalysis:
    """Analysis result for an inter-section connection."""

    from_section_id: int
    to_section_id: int
    from_section_type: str
    to_section_type: str
    connected: bool
    connection_screen: Optional[int] = None
    connection_direction: Optional[str] = None


@dataclass
class SectionFlowAnalysis:
    """Complete analysis of section flow for a chapter."""

    chapter_num: int
    planned_sections: int
    actual_fragments: int
    sections: List[SectionAnalysis]
    connections: List[ConnectionAnalysis]
    issues: List[str]
    is_valid: bool

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization."""
        return {
            "chapter_num": self.chapter_num,
            "planned_sections": self.planned_sections,
            "actual_fragments": self.actual_fragments,
            "is_valid": self.is_valid,
            "sections": [
                {
                    "section_id": s.section_id,
                    "type": s.section_type,
                    "planned": s.planned_screens,
                    "assigned": s.assigned_screens,
                    "fragments": s.fragment_count,
                    "fragment_sizes": s.fragment_sizes,
                    "is_unified": s.is_unified,
                    "largest_ratio": f"{s.largest_fragment_ratio:.1%}",
                }
                for s in self.sections
            ],
            "connections": [
                {
                    "from": f"{c.from_section_id} ({c.from_section_type})",
                    "to": f"{c.to_section_id} ({c.to_section_type})",
                    "connected": c.connected,
                }
                for c in self.connections
            ],
            "issues": self.issues,
        }


@ValidatorRegistry.register
class SectionFlowValidator(Validator):
    """Validates that randomization follows the planned section flow.

    This validator checks:
    1. Each planned section's screens form a connected subgraph (not fragmented)
    2. Inter-section connections exist as planned
    3. The overall structure matches the designed flow

    This is THE critical check for ensuring the randomizer actually works.
    If this fails, the section flow diagram is meaningless.
    """

    VALIDATOR_ID = "section_flow"
    DEFAULT_SEVERITY = Severity.ERROR
    SUPPORTED_PHASES = {ValidationPhase.DURING_NAVIGATION, ValidationPhase.FINAL}

    def __init__(self, config=None):
        """Initialize with configuration.

        Args:
            config: Section flow validation settings
        """
        self._issues: List[ValidationIssue] = []
        if isinstance(config, SectionFlowConfig):
            self.config = config
        else:
            self.config = SectionFlowConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate section flow for a chapter.

        Args:
            chapter: Chapter to validate
            context: Validation context with world_plan, world_population, world_connections

        Returns:
            List of validation issues found
        """
        if not self.config.enabled:
            return []

        issues: List[ValidationIssue] = []

        # Get required context
        world_plan = context.get("world_plan")
        world_population = context.get("world_population")
        world_connections = context.get("world_connections")

        if not world_plan or not world_population:
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.WARNING,
                message="Missing world_plan or world_population in context - cannot validate section flow",
                screen_index=None,
                chapter_num=chapter.chapter_num,
            ))
            return issues

        # Get chapter-specific data
        chapter_plan = world_plan.get_chapter(chapter.chapter_num)
        chapter_pop = world_population.get_chapter(chapter.chapter_num)
        chapter_conn = world_connections.get_chapter(chapter.chapter_num) if world_connections else None

        if not chapter_plan or not chapter_pop:
            return issues

        # Perform analysis
        analysis = self.analyze_section_flow(chapter, chapter_plan, chapter_pop, chapter_conn)

        # Convert analysis to validation issues
        severity = Severity.from_string(self.config.severity)

        # Check section fragmentation
        for section in analysis.sections:
            if section.assigned_screens == 0:
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=severity,
                    message=(
                        f"Section {section.section_id} ({section.section_type}): "
                        f"No screens assigned (planned {section.planned_screens})"
                    ),
                    screen_index=None,
                    chapter_num=chapter.chapter_num,
                    details={
                        "section_id": section.section_id,
                        "section_type": section.section_type,
                        "planned_screens": section.planned_screens,
                    },
                ))
            elif not section.is_unified:
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=severity,
                    message=(
                        f"Section {section.section_id} ({section.section_type}): "
                        f"FRAGMENTED into {section.fragment_count} pieces "
                        f"(sizes: {section.fragment_sizes}). "
                        f"Largest fragment is only {section.largest_fragment_ratio:.0%} of section."
                    ),
                    screen_index=None,
                    chapter_num=chapter.chapter_num,
                    details={
                        "section_id": section.section_id,
                        "section_type": section.section_type,
                        "fragment_count": section.fragment_count,
                        "fragment_sizes": section.fragment_sizes,
                        "screen_indices": section.screen_indices,
                    },
                ))

        # Check inter-section connections
        if self.config.require_inter_section_connections:
            for conn in analysis.connections:
                if not conn.connected:
                    issues.append(ValidationIssue(
                        validator_id=self.VALIDATOR_ID,
                        severity=severity,
                        message=(
                            f"Missing connection: Section {conn.from_section_id} ({conn.from_section_type}) → "
                            f"Section {conn.to_section_id} ({conn.to_section_type})"
                        ),
                        screen_index=None,
                        chapter_num=chapter.chapter_num,
                        details={
                            "from_section": conn.from_section_id,
                            "to_section": conn.to_section_id,
                        },
                    ))

        # Summary issue if overall invalid
        if not analysis.is_valid:
            total_fragments = sum(s.fragment_count for s in analysis.sections if s.assigned_screens > 0)
            issues.insert(0, ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=severity,
                message=(
                    f"Chapter {chapter.chapter_num} section flow INVALID: "
                    f"Planned {analysis.planned_sections} sections but got {total_fragments} fragments. "
                    f"The section flow diagram is NOT being followed."
                ),
                screen_index=None,
                chapter_num=chapter.chapter_num,
                details=analysis.to_dict(),
            ))

        return issues

    def analyze_section_flow(
        self,
        chapter: "Chapter",
        chapter_plan: "ChapterPlan",
        chapter_pop: "ChapterPopulation",
        chapter_conn: Optional[Any] = None,
    ) -> SectionFlowAnalysis:
        """Perform detailed analysis of section flow.

        Args:
            chapter: The chapter data
            chapter_plan: Planned section structure
            chapter_pop: Actual screen assignments
            chapter_conn: Planned inter-section connections

        Returns:
            Detailed analysis results
        """
        sections: List[SectionAnalysis] = []
        connections: List[ConnectionAnalysis] = []
        issues: List[str] = []
        all_valid = True

        # Analyze each planned section
        for section_plan in chapter_plan.sections:
            section_id = section_plan.section_id
            section_type = section_plan.section_type.name
            planned_screens = section_plan.target_screen_count

            # Get assigned screens
            assigned_screens = chapter_pop.screen_assignments.get(section_id, [])
            assigned_count = len(assigned_screens)

            # Find connected components within this section
            screen_set = set(assigned_screens)
            if screen_set:
                internal_components = find_components_in_subset(chapter, screen_set)
                fragment_count = len(internal_components)
                fragment_sizes = sorted([len(c) for c in internal_components], reverse=True)
                largest_ratio = fragment_sizes[0] / assigned_count if assigned_count > 0 else 0.0
            else:
                fragment_count = 0
                fragment_sizes = []
                largest_ratio = 0.0

            # Determine if section is unified
            is_unified = fragment_count <= self.config.max_fragments_per_section

            if not is_unified:
                all_valid = False
                issues.append(
                    f"Section {section_id} ({section_type}) fragmented: "
                    f"{fragment_count} pieces, sizes {fragment_sizes}"
                )

            sections.append(SectionAnalysis(
                section_id=section_id,
                section_type=section_type,
                planned_screens=planned_screens,
                assigned_screens=assigned_count,
                screen_indices=list(assigned_screens),
                fragment_count=fragment_count,
                fragment_sizes=fragment_sizes,
                is_unified=is_unified,
                largest_fragment_ratio=largest_ratio,
            ))

        # Analyze inter-section connections
        if chapter_conn:
            for conn in chapter_conn.connections:
                from_section = conn.from_section_id
                to_section = conn.to_section_id

                # Get section types
                from_type = "UNKNOWN"
                to_type = "UNKNOWN"
                for s in sections:
                    if s.section_id == from_section:
                        from_type = s.section_type
                    if s.section_id == to_section:
                        to_type = s.section_type

                # Get screen sets
                from_screens = chapter_pop.screen_assignments.get(from_section, [])
                to_screens = chapter_pop.screen_assignments.get(to_section, [])

                # Check if any connection exists
                connected = False
                conn_screen = None
                conn_direction = None

                for from_idx in from_screens:
                    screen = chapter.get_screen(from_idx)
                    if screen is None:
                        continue

                    for direction in ["right", "left", "down", "up"]:
                        attr = f"screen_index_{direction}"
                        target = getattr(screen, attr, None)
                        if target in to_screens:
                            connected = True
                            conn_screen = from_idx
                            conn_direction = direction
                            break
                    if connected:
                        break

                if not connected and from_screens and to_screens:
                    all_valid = False
                    issues.append(
                        f"Missing connection: {from_section} ({from_type}) → {to_section} ({to_type})"
                    )

                connections.append(ConnectionAnalysis(
                    from_section_id=from_section,
                    to_section_id=to_section,
                    from_section_type=from_type,
                    to_section_type=to_type,
                    connected=connected,
                    connection_screen=conn_screen,
                    connection_direction=conn_direction,
                ))

        # Calculate total fragments
        total_fragments = sum(s.fragment_count for s in sections if s.assigned_screens > 0)

        return SectionFlowAnalysis(
            chapter_num=chapter.chapter_num,
            planned_sections=len(chapter_plan.sections),
            actual_fragments=total_fragments,
            sections=sections,
            connections=connections,
            issues=issues,
            is_valid=all_valid,
        )

    def validate_world(
        self,
        game_world: Any,
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate section flow across all chapters.

        Args:
            game_world: Game world with chapters
            context: Validation context

        Returns:
            List of all validation issues
        """
        issues: List[ValidationIssue] = []

        for chapter in game_world:
            chapter_issues = self.validate_chapter(chapter, context)
            issues.extend(chapter_issues)

        return issues
