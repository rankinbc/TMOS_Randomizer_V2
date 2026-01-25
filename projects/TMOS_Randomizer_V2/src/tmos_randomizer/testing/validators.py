"""Modular validators for randomization testing.

Each validator is a separate function that checks a specific aspect of randomization.
Validators return lists of issues (errors or warnings).

Based on knowledge/systems/randomization-validation-criteria.md
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any, Dict, List, Optional, Set, TYPE_CHECKING

if TYPE_CHECKING:
    from ..core.chapter import Chapter
    from ..core.worldscreen import WorldScreen


class IssueSeverity(Enum):
    """Severity level for validation issues."""
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"


@dataclass
class ValidationIssue:
    """A single validation issue."""
    severity: IssueSeverity
    category: str
    message: str
    screen_index: Optional[int] = None
    section_id: Optional[int] = None
    requirement: Optional[str] = None  # e.g., "R-002", "R-016"
    details: Optional[Dict[str, Any]] = None  # Additional structured details

    def __str__(self) -> str:
        prefix = f"[{self.severity.value.upper()}]"
        req = f" ({self.requirement})" if self.requirement else ""
        if self.screen_index is not None:
            return f"{prefix}{req} Screen {self.screen_index}: {self.message}"
        if self.section_id is not None:
            return f"{prefix}{req} Section {self.section_id}: {self.message}"
        return f"{prefix}{req} {self.message}"

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        result = {
            "severity": self.severity.value,
            "category": self.category,
            "message": self.message,
        }
        if self.requirement:
            result["requirement"] = self.requirement
        if self.screen_index is not None:
            result["screen_index"] = self.screen_index
        if self.section_id is not None:
            result["section_id"] = self.section_id
        if self.details:
            result["details"] = self.details
        return result


# =============================================================================
# Category 1: Section Fragmentation
# =============================================================================

def validate_section_fragmentation(
    chapter: "Chapter",
    section_id: int,
    section_type: str,
    assigned_screens: List[int],
    is_preserved: bool,
) -> List[ValidationIssue]:
    """Check if a section is fragmented into multiple components.

    FAIL IF: find_components_in_subset(section_screens) returns more than 1 component
             AND section is NOT marked preserve_original=True

    Args:
        chapter: Chapter object
        section_id: Section identifier
        section_type: Type name (e.g., "OVERWORLD", "DUNGEON")
        assigned_screens: List of screen indices assigned to this section
        is_preserved: Whether this section is preserved (original structure)

    Returns:
        List of ValidationIssue (empty if valid)
    """
    from ..logic.navigation import find_components_in_subset

    issues = []

    # Skip preserved sections - they keep original structure
    if is_preserved:
        return issues

    # Skip empty sections (handled by validate_empty_sections)
    if not assigned_screens:
        return issues

    screen_set = set(assigned_screens)
    components = find_components_in_subset(chapter, screen_set)

    if len(components) > 1:
        component_sizes = sorted([len(c) for c in components], reverse=True)
        issues.append(ValidationIssue(
            severity=IssueSeverity.ERROR,
            category="fragmentation",
            message=f"Section {section_id} ({section_type}): Fragmented into "
                    f"{len(components)} components {component_sizes}",
            section_id=section_id,
            requirement="R-011",
        ))

    return issues


# =============================================================================
# Category 2: Empty Sections
# =============================================================================

def validate_empty_sections(
    section_id: int,
    section_type: str,
    assigned_screens: List[int],
    is_preserved: bool,
    is_required: bool = True,
) -> List[ValidationIssue]:
    """Check if a non-preserved section has zero screens assigned.

    FAIL IF: len(screen_assignments[section_id]) == 0
             AND section.preserve_original == False
             AND section is required

    Args:
        section_id: Section identifier
        section_type: Type name
        assigned_screens: List of assigned screen indices
        is_preserved: Whether section is preserved
        is_required: Whether section is required (OVERWORLD, TOWN, DUNGEON)

    Returns:
        List of ValidationIssue
    """
    issues = []

    # Preserved sections can legitimately be empty
    if is_preserved:
        return issues

    if len(assigned_screens) == 0:
        severity = IssueSeverity.ERROR if is_required else IssueSeverity.WARNING
        issues.append(ValidationIssue(
            severity=severity,
            category="empty_section",
            message=f"Section {section_id} ({section_type}): No screens assigned",
            section_id=section_id,
            requirement="R-010",
        ))

    return issues


# =============================================================================
# Category 5: Navigation Integrity
# =============================================================================

def validate_navigation_integrity(
    chapter: "Chapter",
) -> List[ValidationIssue]:
    """Check that all navigation values are valid.

    FAIL IF: screen.nav_X points to screen index >= chapter.screen_count
             AND screen.nav_X is not a special value (0xFF, 0xFE)

    Args:
        chapter: Chapter to validate

    Returns:
        List of ValidationIssue
    """
    issues = []
    screen_count = len(chapter)

    NAV_BLOCKED = 0xFF
    NAV_BUILDING = 0xFE

    for screen in chapter:
        for direction in ["up", "down", "left", "right"]:
            attr = f"screen_index_{direction}"
            nav_value = getattr(screen, attr)

            # Special values are valid
            if nav_value in (NAV_BLOCKED, NAV_BUILDING):
                continue

            # Check if nav points to valid screen
            if nav_value >= screen_count:
                issues.append(ValidationIssue(
                    severity=IssueSeverity.ERROR,
                    category="navigation_integrity",
                    message=f"nav_{direction}={nav_value} exceeds screen count {screen_count}",
                    screen_index=screen.relative_index,
                    requirement="R-001",
                ))

    return issues


# =============================================================================
# Category 4: Excluded Screen Disconnection
# =============================================================================

def validate_excluded_screen_connectivity(
    chapter: "Chapter",
    excluded_screens: Set[int],
) -> List[ValidationIssue]:
    """Check that excluded screens (wizard, boss, special events) remain reachable.

    FAIL IF: screen is in DO_NOT_RANDOMIZE
             AND screen had incoming navigation in original ROM
             AND no screen now points to it

    Args:
        chapter: Chapter to validate
        excluded_screens: Set of relative indices that must remain reachable

    Returns:
        List of ValidationIssue
    """
    issues = []

    # Build set of all screens that have incoming connections
    screens_with_incoming: Set[int] = set()
    for screen in chapter:
        for direction in ["up", "down", "left", "right"]:
            attr = f"screen_index_{direction}"
            nav_value = getattr(screen, attr)
            if nav_value < len(chapter):
                screens_with_incoming.add(nav_value)

    # Check each excluded screen
    for excluded_idx in excluded_screens:
        if excluded_idx >= len(chapter):
            continue  # Skip if not in this chapter

        if excluded_idx not in screens_with_incoming:
            # Check if it's the entry point (screen 0 often has no incoming)
            if excluded_idx == 0:
                continue

            screen = chapter.get_screen(excluded_idx)
            if screen is None:
                continue

            issues.append(ValidationIssue(
                severity=IssueSeverity.ERROR,
                category="excluded_disconnection",
                message=f"Excluded screen has no incoming connections",
                screen_index=excluded_idx,
            ))

    return issues


# =============================================================================
# Category 8: Building Entrance Corruption
# =============================================================================

def validate_building_entrances(
    chapter: "Chapter",
    original_building_entrances: Dict[int, Set[str]],
) -> List[ValidationIssue]:
    """Check that building entrance navigation (0xFE) was preserved.

    FAIL IF: screen.nav_X == 0xFE (building entrance) in original
             AND screen.nav_X != 0xFE after randomization

    Args:
        chapter: Chapter to validate
        original_building_entrances: Dict mapping screen_idx -> set of directions
                                     that had 0xFE in original ROM

    Returns:
        List of ValidationIssue
    """
    issues = []
    NAV_BUILDING = 0xFE

    for screen_idx, original_directions in original_building_entrances.items():
        screen = chapter.get_screen(screen_idx)
        if screen is None:
            continue

        for direction in original_directions:
            attr = f"screen_index_{direction}"
            current_value = getattr(screen, attr)

            if current_value != NAV_BUILDING:
                issues.append(ValidationIssue(
                    severity=IssueSeverity.ERROR,
                    category="building_corruption",
                    message=f"Building entrance nav_{direction} changed from 0xFE to 0x{current_value:02X}",
                    screen_index=screen_idx,
                ))

    return issues


# =============================================================================
# Category 12: Time Period Violation
# =============================================================================

# Known intentional cross-time exits in original ROM
# These are dungeon exits that transition the player between time periods
# Format: {chapter_num: {(source_screen, target_screen, direction), ...}}
INTENTIONAL_CROSS_TIME_EXITS: Dict[int, Set[tuple]] = {
    4: {(53, 31, "left")},  # PAST dungeon exit -> PRESENT overworld
}


def find_time_door_screens(chapter: "Chapter") -> Set[int]:
    """Find all time door screens in a chapter.

    Time doors are identified by Content byte:
    - 0xC0: Time Door Enter
    - 0xC7: Time Door Exit (variant 1)
    - 0xD7: Time Door Exit (variant 2)

    They come in pairs - enter door links to exit door.

    Args:
        chapter: Chapter to search

    Returns:
        Set of screen indices that are time doors
    """
    TIME_DOOR_CONTENTS = {0xC0, 0xC7, 0xD7}
    time_doors = set()

    for screen in chapter:
        if screen.content in TIME_DOOR_CONTENTS:
            time_doors.add(screen.relative_index)

    return time_doors


def validate_time_period_boundaries(
    chapter: "Chapter",
    time_door_screens: Optional[Set[int]] = None,
) -> List[ValidationIssue]:
    """Check that screens don't cross time periods except via time doors.

    Time period is determined by screen INDEX, not ParentWorld.
    Uses hardcoded PAST_SCREEN_INDICES from TMOS_Romhack1.

    FAIL IF: screen_A is in PRESENT time period
             AND screen_B is in PAST time period
             AND screen_A navigates directly to screen_B
             AND screen_A is NOT a Time Door

    Args:
        chapter: Chapter to validate
        time_door_screens: Optional set of time door screen indices.
                          If None, auto-detected from Content == 0xC0.

    Returns:
        List of ValidationIssue
    """
    from ..core.enums import get_time_period_for_screen, TimePeriod

    issues = []
    chapter_num = chapter.chapter_num

    # Auto-detect time doors if not provided
    if time_door_screens is None:
        time_door_screens = find_time_door_screens(chapter)

    for screen in chapter:
        screen_idx = screen.relative_index
        screen_period = get_time_period_for_screen(chapter_num, screen_idx)

        # Time doors can connect any periods
        if screen_idx in time_door_screens:
            continue

        for direction in ["up", "down", "left", "right"]:
            attr = f"screen_index_{direction}"
            nav_value = getattr(screen, attr)

            # Skip special values (blocked, building entrance, out of range)
            if nav_value >= len(chapter):
                continue

            target_period = get_time_period_for_screen(chapter_num, nav_value)

            # Check for cross-period violation
            if screen_period != target_period:
                # Check if this is a known intentional exception
                intentional_exits = INTENTIONAL_CROSS_TIME_EXITS.get(chapter_num, set())
                if (screen_idx, nav_value, direction) in intentional_exits:
                    continue  # Skip known intentional cross-time exits

                issues.append(ValidationIssue(
                    severity=IssueSeverity.ERROR,
                    category="time_period_violation",
                    message=f"Cross-time navigation: {screen_period.name} -> {target_period.name} "
                            f"(nav_{direction}={nav_value})",
                    screen_index=screen_idx,
                    requirement="R-002",
                    details={
                        "source_screen": screen_idx,
                        "target_screen": nav_value,
                        "direction": direction,
                        "source_period": screen_period.name,
                        "target_period": target_period.name,
                    },
                ))

    return issues


# =============================================================================
# Category 6: Orphaned Screens
# =============================================================================

def validate_orphaned_screens(
    chapter: "Chapter",
    assigned_screens: Set[int],
) -> List[ValidationIssue]:
    """Check for screens with no incoming connections and all outgoing blocked.

    FAIL IF: screen is assigned to a section
             AND no other screen's navigation points to this screen
             AND this screen's navigation all points to 0xFF or invalid

    Args:
        chapter: Chapter to validate
        assigned_screens: Set of all screens assigned to sections

    Returns:
        List of ValidationIssue
    """
    issues = []
    NAV_BLOCKED = 0xFF
    NAV_BUILDING = 0xFE

    # Build incoming connection map
    incoming_connections: Dict[int, int] = {}  # screen -> count of incoming
    for screen in chapter:
        for direction in ["up", "down", "left", "right"]:
            attr = f"screen_index_{direction}"
            nav_value = getattr(screen, attr)
            if nav_value < len(chapter):
                incoming_connections[nav_value] = incoming_connections.get(nav_value, 0) + 1

    # Check each assigned screen
    for screen_idx in assigned_screens:
        # Skip entry point
        if screen_idx == 0:
            continue

        screen = chapter.get_screen(screen_idx)
        if screen is None:
            continue

        # Check if screen has any incoming
        if incoming_connections.get(screen_idx, 0) > 0:
            continue

        # Check if screen has any outgoing (non-blocked)
        has_outgoing = False
        for direction in ["up", "down", "left", "right"]:
            attr = f"screen_index_{direction}"
            nav_value = getattr(screen, attr)
            if nav_value not in (NAV_BLOCKED, NAV_BUILDING) and nav_value < len(chapter):
                has_outgoing = True
                break

        if not has_outgoing:
            issues.append(ValidationIssue(
                severity=IssueSeverity.ERROR,
                category="orphaned_screen",
                message="Screen is orphaned: no incoming connections, all outgoing blocked",
                screen_index=screen_idx,
            ))

    return issues


# =============================================================================
# Category 10: Edge Compatibility (Warning)
# =============================================================================

def validate_edge_compatibility(
    chapter: "Chapter",
    rom_data: bytes,
    sample_size: int = 20,
) -> List[ValidationIssue]:
    """Check if connected screen edges have compatible walkability.

    WARN IF: screen_A.nav_right = screen_B
             AND screen_A.right_edge has walkable tiles at positions
             AND screen_B.left_edge has blocking tiles at same positions

    This is a warning, not an error.

    Args:
        chapter: Chapter to validate
        rom_data: ROM bytes for tile lookups
        sample_size: Maximum number of edge pairs to check (for performance)

    Returns:
        List of ValidationIssue (warnings)
    """
    issues = []

    try:
        from ..validation.tiles.edges import extract_edges
        from ..validation.tiles.categories import is_walkable
    except ImportError:
        # Tile validation not available
        return issues

    checked = 0
    direction_pairs = [
        ("right", "left"),
        ("down", "up"),
    ]

    for screen in chapter:
        if checked >= sample_size:
            break

        for our_dir, their_dir in direction_pairs:
            attr = f"screen_index_{our_dir}"
            nav_value = getattr(screen, attr)

            if nav_value >= len(chapter):
                continue

            target = chapter.get_screen(nav_value)
            if target is None:
                continue

            try:
                our_edges = extract_edges(
                    rom_data, screen.relative_index,
                    screen.top_tiles, screen.bottom_tiles, screen.datapointer
                )
                their_edges = extract_edges(
                    rom_data, target.relative_index,
                    target.top_tiles, target.bottom_tiles, target.datapointer
                )

                our_edge = our_edges.get_edge(our_dir)
                their_edge = their_edges.get_edge(their_dir)

                # Count walkable overlap
                our_walkable = [is_walkable(t) for t in our_edge]
                their_walkable = [is_walkable(t) for t in their_edge]

                # Find mismatches where one is walkable and other is blocking
                mismatches = []
                for i, (o, t) in enumerate(zip(our_walkable, their_walkable)):
                    if o and not t:
                        mismatches.append(i)

                if len(mismatches) > len(our_edge) // 2:
                    issues.append(ValidationIssue(
                        severity=IssueSeverity.WARNING,
                        category="edge_compatibility",
                        message=f"Edge mismatch {our_dir} -> screen {nav_value}: "
                                f"{len(mismatches)}/{len(our_edge)} positions blocked on target",
                        screen_index=screen.relative_index,
                    ))

                checked += 1

            except Exception:
                # Skip if edge extraction fails
                continue

    return issues


# =============================================================================
# Category 3: Missing Inter-Section Connections
# =============================================================================

def validate_inter_section_connections(
    chapter: "Chapter",
    section_assignments: Dict[int, List[int]],
    planned_connections: List[tuple],
    preserved_sections: Set[int],
) -> List[ValidationIssue]:
    """Check that planned connections between sections exist.

    FAIL IF: connection(section_A -> section_B) is planned
             AND no screen in section_A has navigation pointing to any screen in section_B
             AND section_A is NOT preserve_original=True

    Args:
        chapter: Chapter to validate
        section_assignments: Dict mapping section_id -> list of screen indices
        planned_connections: List of (from_section_id, to_section_id) tuples
        preserved_sections: Set of section IDs that are preserved

    Returns:
        List of ValidationIssue
    """
    issues = []

    for from_section, to_section in planned_connections:
        # Skip connections FROM preserved sections
        if from_section in preserved_sections:
            continue

        from_screens = section_assignments.get(from_section, [])
        to_screens = set(section_assignments.get(to_section, []))

        # Skip if either section is empty
        if not from_screens or not to_screens:
            continue

        # Check if any screen in from_section connects to any screen in to_section
        connected = False
        for screen_idx in from_screens:
            screen = chapter.get_screen(screen_idx)
            if screen is None:
                continue

            for direction in ["up", "down", "left", "right"]:
                attr = f"screen_index_{direction}"
                nav_value = getattr(screen, attr)
                if nav_value in to_screens:
                    connected = True
                    break

            if connected:
                break

        if not connected:
            issues.append(ValidationIssue(
                severity=IssueSeverity.ERROR,
                category="missing_connection",
                message=f"No navigation from section {from_section} to section {to_section}",
            ))

    return issues


# =============================================================================
# Category 12b: Section Time Period Consistency
# =============================================================================

def validate_section_time_period_consistency(
    chapter_num: int,
    section_id: int,
    section_type: str,
    is_past: bool,
    assigned_screens: List[int],
) -> List[ValidationIssue]:
    """Check that all screens in a section match the section's time period.

    R-012: All screens assigned to a section must be in the SAME time period
    as the section's is_past flag.

    Args:
        chapter_num: Chapter number
        section_id: Section identifier
        section_type: Type name
        is_past: Whether section is marked as PAST
        assigned_screens: List of assigned screen indices

    Returns:
        List of ValidationIssue
    """
    from ..core.enums import get_time_period_for_screen, TimePeriod

    issues = []
    expected_period = TimePeriod.PAST if is_past else TimePeriod.PRESENT

    for screen_idx in assigned_screens:
        actual_period = get_time_period_for_screen(chapter_num, screen_idx)
        if actual_period != expected_period:
            issues.append(ValidationIssue(
                severity=IssueSeverity.ERROR,
                category="section_time_mismatch",
                message=f"Section {section_id} ({section_type}) is {expected_period.name} "
                        f"but contains screen {screen_idx} which is {actual_period.name}",
                section_id=section_id,
                screen_index=screen_idx,
                requirement="R-012",
                details={
                    "expected_period": expected_period.name,
                    "actual_period": actual_period.name,
                },
            ))

    return issues


# =============================================================================
# Category 16: Grid Position Overlap
# =============================================================================

def validate_grid_positions(
    section_id: int,
    section_type: str,
    grid_positions: Dict[tuple, int],
) -> List[ValidationIssue]:
    """Check that no two screens share the same grid position.

    R-016: Screens within the same section cannot occupy the same grid position.

    Args:
        section_id: Section identifier
        section_type: Type name
        grid_positions: Dict mapping (x, y) -> screen_index

    Returns:
        List of ValidationIssue
    """
    issues = []

    # Check for duplicate positions by counting
    position_counts: Dict[tuple, List[int]] = {}
    for pos, screen_idx in grid_positions.items():
        if pos not in position_counts:
            position_counts[pos] = []
        position_counts[pos].append(screen_idx)

    for pos, screens in position_counts.items():
        if len(screens) > 1:
            issues.append(ValidationIssue(
                severity=IssueSeverity.ERROR,
                category="grid_overlap",
                message=f"Section {section_id} ({section_type}): Screens {screens} "
                        f"all at grid position {pos}",
                section_id=section_id,
                requirement="R-016",
                details={"position": pos, "screens": screens},
            ))

    return issues


# =============================================================================
# Category 17: Edge Passability
# =============================================================================

def validate_edge_passability(
    chapter: "Chapter",
    rom_data: bytes,
) -> List[ValidationIssue]:
    """Check that blocked edges have nav = 0xFF.

    R-017: If a screen edge is completely blocked by collidable tiles,
    nav MUST be 0xFF, and nothing should connect TO this screen from that direction.

    Args:
        chapter: Chapter to validate
        rom_data: ROM bytes for tile lookups

    Returns:
        List of ValidationIssue
    """
    issues = []

    try:
        from ..validation.tiles.edges import extract_edges
        from ..validation.tiles.categories import is_walkable
        from ..core.constants import get_chr_index
    except ImportError:
        return issues

    NAV_BLOCKED = 0xFF
    NAV_BUILDING = 0xFE
    screen_count = len(chapter)

    # Build map of which edges are blocked for each screen
    blocked_edges: Dict[int, Set[str]] = {}  # screen_idx -> set of blocked directions

    for screen in chapter:
        try:
            chr_index = get_chr_index(chapter.chapter_num, screen.relative_index)
            edges = extract_edges(
                rom_data,
                screen.top_tiles,
                screen.bottom_tiles,
                screen.datapointer,
            )

            for direction in ["right", "left", "down", "up"]:
                edge_tiles = getattr(edges, direction, [])
                if not edge_tiles:
                    continue

                walkable_count = sum(1 for tile in edge_tiles if is_walkable(tile))

                if walkable_count == 0:
                    # Edge is completely blocked
                    if screen.relative_index not in blocked_edges:
                        blocked_edges[screen.relative_index] = set()
                    blocked_edges[screen.relative_index].add(direction)

                    # Check nav value
                    attr = f"screen_index_{direction}"
                    nav_value = getattr(screen, attr)

                    if nav_value != NAV_BLOCKED and nav_value != NAV_BUILDING:
                        issues.append(ValidationIssue(
                            severity=IssueSeverity.ERROR,
                            category="blocked_edge_nav",
                            message=f"Screen has blocked {direction} edge but "
                                    f"nav_{direction}={nav_value} (should be 0xFF)",
                            screen_index=screen.relative_index,
                            requirement="R-017",
                            details={"direction": direction, "nav_value": nav_value},
                        ))
        except Exception:
            continue

    # Check for connections TO blocked edges
    opposite_dirs = {"right": "left", "left": "right", "up": "down", "down": "up"}

    for screen in chapter:
        for direction in ["right", "left", "down", "up"]:
            attr = f"screen_index_{direction}"
            nav_value = getattr(screen, attr)

            if nav_value >= screen_count:
                continue

            # Check if target screen has blocked opposite edge
            target_blocked = blocked_edges.get(nav_value, set())
            opposite = opposite_dirs[direction]

            if opposite in target_blocked:
                issues.append(ValidationIssue(
                    severity=IssueSeverity.ERROR,
                    category="connects_to_blocked",
                    message=f"Screen connects {direction} to screen {nav_value} "
                            f"which has blocked {opposite} edge",
                    screen_index=screen.relative_index,
                    requirement="R-017",
                    details={
                        "direction": direction,
                        "target_screen": nav_value,
                        "blocked_edge": opposite,
                    },
                ))

    return issues


# =============================================================================
# Category 18: Grid Navigation Consistency
# =============================================================================

def validate_grid_navigation(
    chapter: "Chapter",
    section_id: int,
    section_type: str,
    grid_positions: Dict[tuple, int],
    screen_to_position: Dict[int, tuple],
) -> List[ValidationIssue]:
    """Check that navigation values match grid positions.

    R-018: If screen A is at (0,0) and screen B is at (1,0), then
    A.nav_right should equal B's index and B.nav_left should equal A's index.

    Args:
        chapter: Chapter to validate
        section_id: Section identifier
        section_type: Type name
        grid_positions: Dict mapping (x, y) -> screen_index
        screen_to_position: Dict mapping screen_index -> (x, y)

    Returns:
        List of ValidationIssue
    """
    issues = []
    NAV_BLOCKED = 0xFF
    NAV_BUILDING = 0xFE

    direction_offsets = {
        "right": (1, 0),
        "left": (-1, 0),
        "down": (0, 1),
        "up": (0, -1),
    }

    for screen_idx, pos in screen_to_position.items():
        screen = chapter.get_screen(screen_idx)
        if screen is None:
            continue

        x, y = pos

        for direction, (dx, dy) in direction_offsets.items():
            neighbor_pos = (x + dx, y + dy)

            if neighbor_pos in grid_positions:
                expected_neighbor = grid_positions[neighbor_pos]
                attr = f"screen_index_{direction}"
                actual_nav = getattr(screen, attr)

                # Nav should point to the grid neighbor OR be blocked (0xFF)
                if actual_nav != expected_neighbor and actual_nav != NAV_BLOCKED:
                    issues.append(ValidationIssue(
                        severity=IssueSeverity.ERROR,
                        category="grid_nav_mismatch",
                        message=f"Section {section_id}: Screen {screen_idx} at {pos} "
                                f"nav_{direction}={actual_nav}, expected {expected_neighbor} "
                                f"(grid neighbor at {neighbor_pos})",
                        section_id=section_id,
                        screen_index=screen_idx,
                        requirement="R-018",
                        details={
                            "position": pos,
                            "direction": direction,
                            "actual_nav": actual_nav,
                            "expected_nav": expected_neighbor,
                            "neighbor_position": neighbor_pos,
                        },
                    ))

    return issues


# =============================================================================
# Category 22: Duplicate Screen Assignment
# =============================================================================

def validate_no_duplicate_assignments(
    section_assignments: Dict[int, List[int]],
) -> List[ValidationIssue]:
    """Check that each screen is assigned to only one section.

    R-022: Each screen can only be assigned to one section.

    Args:
        section_assignments: Dict mapping section_id -> list of screen indices

    Returns:
        List of ValidationIssue
    """
    issues = []

    screen_to_sections: Dict[int, List[int]] = {}

    for section_id, screens in section_assignments.items():
        for screen_idx in screens:
            if screen_idx not in screen_to_sections:
                screen_to_sections[screen_idx] = []
            screen_to_sections[screen_idx].append(section_id)

    for screen_idx, sections in screen_to_sections.items():
        if len(sections) > 1:
            issues.append(ValidationIssue(
                severity=IssueSeverity.ERROR,
                category="duplicate_assignment",
                message=f"Screen {screen_idx} assigned to multiple sections: {sections}",
                screen_index=screen_idx,
                requirement="R-022",
                details={"sections": sections},
            ))

    return issues


# =============================================================================
# Aggregate Validators
# =============================================================================

def run_all_chapter_validators(
    chapter: "Chapter",
    chapter_plan: Any,
    chapter_population: Any,
    chapter_connections: Any,
    rom_data: Optional[bytes] = None,
    excluded_screens: Optional[Set[int]] = None,
    time_door_screens: Optional[Set[int]] = None,
    original_building_entrances: Optional[Dict[int, Set[str]]] = None,
) -> List[ValidationIssue]:
    """Run all validators on a chapter.

    Args:
        chapter: Chapter to validate
        chapter_plan: ChapterPlan from Phase 1
        chapter_population: ChapterPopulation from Phase 4
        chapter_connections: ChapterConnections from Phase 3
        rom_data: Optional ROM bytes for tile validation
        excluded_screens: Set of DO_NOT_RANDOMIZE screen indices
        time_door_screens: Set of time door screen indices
        original_building_entrances: Dict of original building entrance locations

    Returns:
        List of all ValidationIssues found
    """
    issues = []

    # Build helper data
    preserved_sections = {
        sp.section_id for sp in chapter_plan.sections if sp.preserve_original
    }
    required_types = {"OVERWORLD", "TOWN", "DUNGEON"}
    all_assigned_screens: Set[int] = set()

    # Validate each section
    for section_plan in chapter_plan.sections:
        section_id = section_plan.section_id
        section_type = section_plan.section_type.name
        is_preserved = section_plan.preserve_original
        is_required = section_type in required_types

        assigned = chapter_population.screen_assignments.get(section_id, [])
        all_assigned_screens.update(assigned)

        # Category 1: Fragmentation
        issues.extend(validate_section_fragmentation(
            chapter, section_id, section_type, assigned, is_preserved
        ))

        # Category 2: Empty sections
        issues.extend(validate_empty_sections(
            section_id, section_type, assigned, is_preserved, is_required
        ))

        # Category 12b: Section time period consistency (R-012)
        is_past = getattr(section_plan, 'is_past', False)
        if assigned and not is_preserved:
            issues.extend(validate_section_time_period_consistency(
                chapter.chapter_num, section_id, section_type, is_past, assigned
            ))

        # Category 16: Grid position overlap (R-016)
        section_grid = chapter_population.section_grid_positions.get(section_id, {})
        if section_grid and not is_preserved:
            issues.extend(validate_grid_positions(section_id, section_type, section_grid))

        # Category 18: Grid navigation consistency (R-018)
        if section_grid and not is_preserved:
            screen_to_pos = {v: k for k, v in section_grid.items()}
            issues.extend(validate_grid_navigation(
                chapter, section_id, section_type, section_grid, screen_to_pos
            ))

    # Category 22: Duplicate screen assignments (R-022)
    issues.extend(validate_no_duplicate_assignments(chapter_population.screen_assignments))

    # Category 5: Navigation integrity
    issues.extend(validate_navigation_integrity(chapter))

    # Category 6: Orphaned screens
    issues.extend(validate_orphaned_screens(chapter, all_assigned_screens))

    # Category 4: Excluded screen connectivity
    if excluded_screens:
        issues.extend(validate_excluded_screen_connectivity(chapter, excluded_screens))

    # Category 8: Building entrances
    if original_building_entrances:
        issues.extend(validate_building_entrances(chapter, original_building_entrances))

    # Category 12: Time period boundaries
    if time_door_screens is not None:
        issues.extend(validate_time_period_boundaries(chapter, time_door_screens))

    # Category 3: Inter-section connections
    if chapter_connections:
        planned_conns = [
            (conn.from_section_id, conn.to_section_id)
            for conn in chapter_connections.connections
        ]
        issues.extend(validate_inter_section_connections(
            chapter,
            chapter_population.screen_assignments,
            planned_conns,
            preserved_sections,
        ))

    # Category 10: Edge compatibility (warning, only if ROM data available)
    if rom_data:
        issues.extend(validate_edge_compatibility(chapter, rom_data))

    # Category 17: Edge passability (R-017)
    if rom_data:
        issues.extend(validate_edge_passability(chapter, rom_data))

    return issues
