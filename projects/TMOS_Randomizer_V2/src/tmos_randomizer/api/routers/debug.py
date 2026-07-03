"""Debug endpoints: validation, navigation dump, section validation, spatial
analysis, and the ROM-vs-vanilla structured change log."""

from __future__ import annotations

from typing import Dict, List

from fastapi import APIRouter, HTTPException

from .. import state
from ..deps import _require_rom, _require_rom_pair
from ...io.rom_reader import load_rom
from ...core import inventory_caps as _inv_caps
from ...core import exp_table as _exp_table
from ...core import player_stats as _player_stats

router = APIRouter()


def _analyze_full_reachability(chapter) -> dict:
    """Analyze reachability including stairways and time doors.

    Returns dict with reachability stats accounting for all connection types.
    """
    from collections import deque

    screen_count = len(chapter)

    # Build adjacency including stairways
    adjacency: dict[int, set[int]] = {i: set() for i in range(screen_count)}
    stairway_count = 0

    for screen in chapter:
        idx = screen.relative_index

        # Direct navigation
        for nav in [screen.screen_index_up, screen.screen_index_down,
                    screen.screen_index_left, screen.screen_index_right]:
            if nav < screen_count:  # Valid screen index (not 0xFF or 0xFE)
                adjacency[idx].add(nav)

        # Stairway connections (Event=0x40, Content=destination)
        if screen.event == 0x40 and screen.content < screen_count:
            adjacency[idx].add(screen.content)
            adjacency[screen.content].add(idx)  # Bidirectional
            stairway_count += 1

        # Time door connections (Content=0xC0)
        # Time doors connect to the other time door in the chapter
        if screen.content == 0xC0:
            # Find the other time door
            for other in chapter:
                if other.content == 0xC0 and other.relative_index != idx:
                    adjacency[idx].add(other.relative_index)
                    break

    # BFS from screen 0 with full connections
    visited = set()
    queue = deque([0])
    visited.add(0)

    while queue:
        current = queue.popleft()
        for neighbor in adjacency[current]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    # Find connected components (full graph)
    all_visited = set()
    full_components = 0
    for start in range(screen_count):
        if start in all_visited:
            continue
        full_components += 1
        comp_queue = deque([start])
        all_visited.add(start)
        while comp_queue:
            current = comp_queue.popleft()
            for neighbor in adjacency[current]:
                if neighbor not in all_visited:
                    all_visited.add(neighbor)
                    comp_queue.append(neighbor)

    # Count nav-only components for comparison
    from ...logic.navigation import find_connected_components
    nav_components = len(find_connected_components(chapter))

    return {
        "reachable_count": len(visited),
        "total_count": screen_count,
        "percent": 100.0 * len(visited) / screen_count if screen_count > 0 else 0,
        "nav_components": nav_components,
        "full_components": full_components,
        "stairway_count": stairway_count,
    }


@router.get("/api/debug/validate")
async def debug_validate_rom():
    """Run comprehensive validation tests on the current ROM state.

    This runs ALL validators from the validation criteria document:
    - R-001: Navigation integrity
    - R-002: Time period boundaries
    - R-003: Reachability
    - R-004: World connectivity
    - R-010-R-022: Post-randomization validators (if plan applied)

    Returns detailed structured results for each chapter.
    """
    _require_rom()

    # Sourced from the modern validation framework (validation/runner.py +
    # validation/validators/*) instead of the retired testing.validators module.
    # The ValidationRunner runs every registered validator per chapter; we map
    # each ValidationIssue back onto the legacy per-requirement response shape
    # the frontend (JsonDebugPanel ValidationView) consumes.
    from ...validation.runner import ValidationRunner
    from ...validation.config import ValidationConfig
    from ...validation.base import ValidationPhase, Severity
    from ...core.enums import PAST_SCREEN_INDICES

    def _find_time_door_screens(chapter) -> set:
        """Screens whose Content byte marks a time door (0xC0/0xC7/0xD7)."""
        time_door_contents = {0xC0, 0xC7, 0xD7}
        return {
            screen.relative_index
            for screen in chapter
            if screen.content in time_door_contents
        }

    # Map modern validator IDs onto the legacy R-xxx requirement codes the
    # frontend's error_breakdown keys on. Unknown IDs fall back to the raw id.
    validator_requirement_map = {
        "navigation_consistency": "R-001",
        "time_period_isolation": "R-002",
        "screen_traversability": "R-003",
        "section_flow": "R-004",
        "edge_compatibility": "R-010",
        "edge_alignment": "R-011",
        "spatial_consistency": "R-016",
        "datapointer_objectset": "R-020",
    }

    runner = ValidationRunner(ValidationConfig())
    validation_context = {"rom_data": state._rom_data}

    results = {
        "status": "completed",
        "rom_filename": state._rom_filename,
        "has_plan": state._current_plan is not None,
        "chapters": [],
        "summary": {
            "total_errors": 0,
            "total_warnings": 0,
            "all_passed": True,
            "error_breakdown": {},  # requirement -> count
        },
    }

    for chapter_num in range(1, 6):
        chapter = state._game_world.chapters.get(chapter_num)
        if chapter is None:
            continue

        chapter_result = {
            "chapter_num": chapter_num,
            "total_screens": len(chapter),
            "errors": [],  # List of issue dicts
            "warnings": [],  # List of issue dicts
            "passed": True,
            "metrics": {},
        }

        # Run every registered validator for this chapter via the modern
        # framework. This covers both pre- and post-randomization state — the
        # validators read the live `chapter` (which reflects any applied plan)
        # plus rom_data from the context.
        chapter_validation = runner.run_for_chapter(
            chapter,
            phase=ValidationPhase.FINAL,
            context=validation_context,
        )
        all_issues = chapter_validation.issues

        # If a plan is applied, surface the same section-count metrics as before.
        if state._current_plan is not None:
            chapter_plan = state._current_plan.world_plan.get_chapter(chapter_num)
            chapter_population = getattr(state._current_plan, 'world_population', None)
            chapter_pop = (
                chapter_population.get_chapter(chapter_num)
                if chapter_population else None
            )
            if chapter_plan and chapter_pop:
                chapter_result["metrics"]["section_count_planned"] = len(chapter_plan.sections)
                chapter_result["metrics"]["section_count_assigned"] = len([
                    s for s in chapter_plan.sections
                    if len(chapter_pop.screen_assignments.get(s.section_id, [])) > 0
                ])

        # Categorize issues into the legacy per-requirement response shape.
        for issue in all_issues:
            requirement = validator_requirement_map.get(
                issue.validator_id, issue.validator_id
            )
            issue_dict = issue.to_dict()
            # Backward-compat: the legacy shape carried a top-level `requirement`.
            issue_dict["requirement"] = requirement

            if issue.severity == Severity.ERROR:
                chapter_result["errors"].append(issue_dict)
                # Track error breakdown by requirement
                if requirement not in results["summary"]["error_breakdown"]:
                    results["summary"]["error_breakdown"][requirement] = 0
                results["summary"]["error_breakdown"][requirement] += 1
            else:
                chapter_result["warnings"].append(issue_dict)

        # Enhanced reachability analysis
        reachability = _analyze_full_reachability(chapter)
        chapter_result["reachability"] = reachability
        chapter_result["metrics"]["reachability_percent"] = reachability["percent"]
        chapter_result["nav_components"] = reachability["nav_components"]
        chapter_result["full_components"] = reachability["full_components"]

        if reachability["percent"] < 95.0:
            chapter_result["warnings"].append({
                "severity": "warning",
                "category": "reachability",
                "message": f"Low reachability: {reachability['percent']:.1f}%",
                "requirement": "R-003",
            })

        if reachability["full_components"] > 1:
            chapter_result["errors"].append({
                "severity": "error",
                "category": "connectivity",
                "message": f"World fragmented into {reachability['full_components']} regions",
                "requirement": "R-004",
            })

        # Time period stats
        time_doors = _find_time_door_screens(chapter)
        past_screens = PAST_SCREEN_INDICES.get(chapter_num, set())
        chapter_result["time_period"] = {
            "past_count": len(past_screens),
            "present_count": len(chapter) - len(past_screens),
            "time_doors": sorted(time_doors),
        }

        chapter_result["stairways"] = reachability["stairway_count"]

        # Count time period violations in metrics
        time_violations = [e for e in chapter_result["errors"]
                          if e.get("requirement") == "R-002" or e.get("category") == "time_period_violation"]
        chapter_result["metrics"]["time_period_violations"] = len(time_violations)

        # Count grid overlaps in metrics
        grid_overlaps = [e for e in chapter_result["errors"]
                        if e.get("requirement") == "R-016" or e.get("category") == "grid_overlap"]
        chapter_result["metrics"]["grid_overlap_count"] = len(grid_overlaps)

        # Determine pass/fail
        chapter_result["passed"] = len(chapter_result["errors"]) == 0

        # Update summary
        results["summary"]["total_errors"] += len(chapter_result["errors"])
        results["summary"]["total_warnings"] += len(chapter_result["warnings"])
        if not chapter_result["passed"]:
            results["summary"]["all_passed"] = False

        results["chapters"].append(chapter_result)

    return results


@router.get("/api/debug/navigation/{chapter_num}")
async def debug_navigation(chapter_num: int):
    """Debug endpoint: Dump complete navigation state for a chapter.

    Shows all screens with their current navigation values.
    Useful for debugging navigation issues.
    """
    _require_rom()

    chapter = state._game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screens_data = []
    connected_count = 0
    isolated_count = 0

    for screen in chapter:
        nav_right = screen.screen_index_right
        nav_left = screen.screen_index_left
        nav_down = screen.screen_index_down
        nav_up = screen.screen_index_up

        # Count connections (not blocked, not building entrance)
        connections = []
        for direction, nav_val in [("right", nav_right), ("left", nav_left), ("down", nav_down), ("up", nav_up)]:
            if nav_val != 0xFF and nav_val != 0xFE:
                connections.append({"direction": direction, "target": nav_val})

        is_isolated = len(connections) == 0

        screens_data.append({
            "index": screen.relative_index,
            "nav_right": f"{nav_right:02X}" if nav_right >= 0xFE else nav_right,
            "nav_left": f"{nav_left:02X}" if nav_left >= 0xFE else nav_left,
            "nav_down": f"{nav_down:02X}" if nav_down >= 0xFE else nav_down,
            "nav_up": f"{nav_up:02X}" if nav_up >= 0xFE else nav_up,
            "connection_count": len(connections),
            "connections": connections,
            "is_isolated": is_isolated,
            "parent_world": screen.parent_world,
        })

        if is_isolated:
            isolated_count += 1
        else:
            connected_count += 1

    # Find connected components
    from ...logic.navigation import find_connected_components
    components = find_connected_components(chapter)

    return {
        "chapter_num": chapter_num,
        "screen_count": chapter.screen_count,
        "connected_screens": connected_count,
        "isolated_screens": isolated_count,
        "component_count": len(components),
        "component_sizes": [len(c) for c in components],
        "screens": screens_data,
    }


@router.get("/api/debug/section-validation/{chapter_num}")
async def debug_section_validation(chapter_num: int):
    """Validate that randomization output matches the plan.

    Compares:
    - Planned sections vs actual screen assignments
    - Intra-section connectivity (screens within a section should be connected)
    - Inter-section connectivity (sections should be connected as planned)

    This is the KEY diagnostic tool for debugging randomization issues.
    """
    _require_rom()

    if state._current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created. Call POST /api/plan first.")

    if state._current_plan.world_population is None:
        raise HTTPException(status_code=400, detail="Plan not applied. Call POST /api/plan/apply-preview first.")

    chapter = state._game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    # Get plan, population, and connections data
    chapter_plan = state._current_plan.world_plan.get_chapter(chapter_num)
    chapter_pop = state._current_plan.world_population.get_chapter(chapter_num)
    chapter_conn = state._current_plan.world_connections.get_chapter(chapter_num)

    if chapter_plan is None or chapter_pop is None:
        raise HTTPException(status_code=400, detail="Plan data missing for this chapter")

    # Import helper function
    from ...logic.navigation import find_components_in_subset

    issues = []
    section_details = []

    # Analyze each planned section
    for section_plan in chapter_plan.sections:
        section_id = section_plan.section_id
        section_type = section_plan.section_type.name
        planned_screens = section_plan.target_screen_count

        # Get assigned screens from population
        assigned_screens = chapter_pop.screen_assignments.get(section_id, [])
        assigned_count = len(assigned_screens)

        # Find connected components WITHIN this section's screens
        screen_set = set(assigned_screens)
        internal_components = find_components_in_subset(chapter, screen_set)
        component_count = len(internal_components)
        component_sizes = sorted([len(c) for c in internal_components], reverse=True)

        # Determine status
        if assigned_count == 0:
            status = "EMPTY"
            issues.append(f"Section {section_id} ({section_type}): No screens assigned")
        elif component_count > 1:
            status = "FRAGMENTED"
            issues.append(f"Section {section_id} ({section_type}): Fragmented into {component_count} components {component_sizes}")
        else:
            status = "OK"

        section_details.append({
            "section_id": section_id,
            "type": section_type,
            "planned_screens": planned_screens,
            "assigned_screens": assigned_count,
            "screen_indices": assigned_screens[:20],  # Limit for readability
            "internal_components": component_count,
            "component_sizes": component_sizes,
            "status": status,
        })

    # Analyze inter-section connections
    connection_details = []
    if chapter_conn:
        for conn in chapter_conn.connections:
            from_section = conn.from_section_id
            to_section = conn.to_section_id

            # Get the actual screens used for this connection
            from_screens = chapter_pop.screen_assignments.get(from_section, [])
            to_screens = chapter_pop.screen_assignments.get(to_section, [])

            # Check if ANY screen from from_section connects to ANY screen in to_section
            connected = False
            connecting_screen = None
            target_screen = None
            direction_used = None

            for from_idx in from_screens:
                screen = chapter.get_screen(from_idx)
                if screen is None:
                    continue

                for direction in ["right", "left", "down", "up"]:
                    attr = f"screen_index_{direction}"
                    target = getattr(screen, attr)
                    if target in to_screens:
                        connected = True
                        connecting_screen = from_idx
                        target_screen = target
                        direction_used = direction
                        break
                if connected:
                    break

            status = "OK" if connected else "MISSING"
            if not connected:
                issues.append(f"Connection Section {from_section} -> Section {to_section}: No navigation path found")

            connection_details.append({
                "from_section": from_section,
                "to_section": to_section,
                "expected": True,
                "actual": connected,
                "from_screen": connecting_screen,
                "to_screen": target_screen,
                "direction": direction_used,
                "status": status,
            })

    # Overall status
    overall_status = "PASS" if not issues else "FAIL"

    return {
        "chapter_num": chapter_num,
        "plan_summary": {
            "planned_sections": len(chapter_plan.sections),
            "total_planned_screens": chapter_plan.planned_screens,
        },
        "population_summary": {
            "sections_with_assignments": len(chapter_pop.screen_assignments),
            "total_assigned_screens": len(chapter_pop.assignments),
        },
        "section_details": section_details,
        "connection_details": connection_details,
        "overall_status": overall_status,
        "issues": issues,
    }


@router.get("/api/debug/spatial-analysis/{chapter_num}")
async def debug_spatial_analysis(chapter_num: int):
    """Analyze spatial layout of screens and detect grid conflicts.

    Builds a coordinate grid via BFS from the start screen, assigning
    (x, y) positions based on navigation direction. Detects when multiple
    screens from different sections occupy the same grid position.

    Returns:
        - screen_positions: Map of screen_idx -> (x, y)
        - position_screens: Map of (x, y) -> [screen_indices]
        - conflicts: Positions with multiple screens
        - section_grids: Per-section grid data for visualization
    """
    _require_rom()

    chapter = state._game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    # Import spatial analysis from validator
    from ...validation.validators.spatial_consistency import (
        SpatialConsistencyValidator,
        SpatialConsistencyConfig,
    )

    # Build screen -> section mapping
    screen_to_section: Dict[int, int] = {}
    section_screens: Dict[int, List[int]] = {}

    if state._current_plan and state._current_plan.world_population:
        chapter_pop = state._current_plan.world_population.get_chapter(chapter_num)
        if chapter_pop:
            for section_id, screens in chapter_pop.screen_assignments.items():
                section_screens[section_id] = list(screens)
                for screen_idx in screens:
                    screen_to_section[screen_idx] = section_id

    # Run spatial analysis
    validator = SpatialConsistencyValidator(SpatialConsistencyConfig())
    analysis = validator.analyze_spatial_layout(chapter, screen_to_section)

    # Build per-section grid data for UI visualization
    section_grids = {}
    for section_id, screens in section_screens.items():
        section_positions = []
        for screen_idx in screens:
            if screen_idx in analysis.screen_positions:
                x, y = analysis.screen_positions[screen_idx]
                section_positions.append({
                    "screen_idx": screen_idx,
                    "x": x,
                    "y": y,
                })
        section_grids[section_id] = {
            "screen_count": len(screens),
            "positions": section_positions,
        }

    # Convert position_screens for JSON (tuple keys not allowed)
    position_screens_list = [
        {
            "position": [x, y],
            "screens": screens,
            "sections": list(set(screen_to_section.get(s, -1) for s in screens)),
            "is_conflict": len(screens) > 1 and len(set(screen_to_section.get(s, -1) for s in screens)) > 1,
        }
        for (x, y), screens in analysis.position_screens.items()
    ]

    # Convert screen_positions for JSON
    screen_positions_list = [
        {"screen_idx": idx, "x": pos[0], "y": pos[1], "section": screen_to_section.get(idx, -1)}
        for idx, pos in analysis.screen_positions.items()
    ]

    return {
        "chapter_num": chapter_num,
        "total_screens_mapped": analysis.total_screens_mapped,
        "grid_bounds": {
            "min_x": analysis.grid_bounds[0],
            "min_y": analysis.grid_bounds[1],
            "max_x": analysis.grid_bounds[2],
            "max_y": analysis.grid_bounds[3],
            "width": analysis.grid_bounds[2] - analysis.grid_bounds[0] + 1,
            "height": analysis.grid_bounds[3] - analysis.grid_bounds[1] + 1,
        },
        "screen_positions": screen_positions_list,
        "position_screens": position_screens_list,
        "conflicts": [
            {
                "position": [c.x, c.y],
                "screens": c.screens,
                "sections": c.sections,
            }
            for c in analysis.conflicts
        ],
        "conflict_count": len(analysis.conflicts),
        "section_grids": section_grids,
    }


# =============================================================================
# API Endpoints - Debug Changes (ROM-vs-vanilla structured diff)
# =============================================================================

def _screens_snapshot(buf: bytes) -> dict:
    """Parse ROM bytes into {ch -> {screen_index -> {field: value}}} for diffing."""
    import tempfile
    import os
    tmp = tempfile.NamedTemporaryFile(suffix=".nes", delete=False)
    try:
        tmp.write(buf)
        tmp.close()
        world = load_rom(tmp.name)
    finally:
        os.unlink(tmp.name)

    out: dict = {}
    for chapter_num in range(1, 6):
        chapter = world.chapters.get(chapter_num)
        if chapter is None:
            continue
        ch_map: dict = {}
        for screen in chapter.screens:
            ch_map[f"0x{screen.relative_index:02X}"] = {
                "content": screen.content,
                "objectset": screen.objectset,
                "datapointer": screen.datapointer,
                "top_tiles": screen.top_tiles,
                "bottom_tiles": screen.bottom_tiles,
                "nav_right": screen.screen_index_right,
                "nav_left": screen.screen_index_left,
                "nav_down": screen.screen_index_down,
                "nav_up": screen.screen_index_up,
            }
        out[f"ch{chapter_num}"] = ch_map
    return out


@router.get("/api/debug/changes")
async def debug_changes():
    """Authoritative ROM-vs-vanilla diff for the Debug tab change log."""
    from ..debug_changes import build_changes
    rom, vanilla = _require_rom_pair()
    providers = [
        ("Screens", _screens_snapshot),
        ("Hero", _player_stats.read_player_stats),
        ("Inventory Caps", _inv_caps.read_caps),
        ("Experience Table", _exp_table.read_exp_table),
    ]
    return build_changes(rom, vanilla, providers)
