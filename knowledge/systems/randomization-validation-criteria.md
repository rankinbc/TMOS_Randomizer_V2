# TMOS Randomizer Validation Criteria

**Purpose**: This document specifies ALL validation criteria for testing randomized ROMs. An AI system can use this document to implement automated validation tests.

**Scope**: The Magic of Scheherazade (NES) map randomizer validation.

**IMPORTANT FOR AI IMPLEMENTERS**: This document is the authoritative specification. If the code does not match these requirements, THE CODE IS WRONG.

---

## Table of Contents

1. [Core Concepts](#1-core-concepts)
2. [Data Structures](#2-data-structures)
3. [Constants and Enumerations](#3-constants-and-enumerations)
4. [Validation Requirements](#4-validation-requirements)
5. [Test Implementation Guide](#5-test-implementation-guide)
6. [Known Failures and Their Causes](#6-known-failures-and-their-causes)

---

## 1. Core Concepts

### 1.1 What the Randomizer Does

The randomizer works in phases:
1. **Phase 1 (Planning)**: Decide how many sections (Overworld, Town, Dungeon, etc.) each chapter will have
2. **Phase 2 (Shaping)**: Create abstract grid layouts for each section (each screen gets a unique x,y position)
3. **Phase 3 (Connection)**: Decide which sections connect to which (section flow)
4. **Phase 4 (Population)**: Assign real screen indices to the abstract grid positions
5. **Phase 5 (Navigation)**: Rewrite the navigation bytes so screens connect according to grid adjacency

### 1.2 Critical Invariants

These rules MUST be maintained at all times:

| Invariant | Description |
|-----------|-------------|
| **I-1** | Each screen belongs to EXACTLY ONE planned section |
| **I-2** | Each screen belongs to EXACTLY ONE time period (PRESENT or PAST) |
| **I-3** | Navigation can only cross time periods via Time Door |
| **I-4** | Screens in a section must form a single connected component |
| **I-5** | Each screen in a section has a unique grid position (no overlap) |
| **I-6** | Navigation values must match grid adjacency |
| **I-7** | All planned sections must be reachable |

### 1.3 What "Section" Means

**CRITICAL DISTINCTION**:

| Term | Meaning |
|------|---------|
| **Planned Section** | A section created by the randomizer in Phase 1 (e.g., "Section 1: Overworld, 38 screens") |
| **ParentWorld Section** | A grouping in the ROM based on ParentWorld byte (NOT what the randomizer uses) |

The randomizer creates **8-10 planned sections per chapter**. The UI's "Section Flow" tab should show these planned sections. The UI's "Screens" tab historically showed ParentWorld-derived sections (40+ per chapter), which is WRONG.

**The Screens tab showing 40+ sections when the plan has 8 sections is a BUG.**

### 1.4 Time Periods

Each chapter has TWO time periods: PRESENT and PAST.

| Property | PRESENT | PAST |
|----------|---------|------|
| Access | Starting area | Through Time Door |
| Suffix in UI | (none) | (TD) |
| Screen determination | NOT in PAST_SCREEN_INDICES | IN PAST_SCREEN_INDICES |

**CRITICAL**: ParentWorld does NOT determine time period. The same ParentWorld value (e.g., 0x10 for Town) can appear in BOTH PRESENT and PAST. Time period is determined ONLY by screen index.

---

## 2. Data Structures

### 2.1 WorldScreen (16 bytes per screen)

Each screen in the game is represented by a 16-byte structure:

| Offset | Name | Description |
|--------|------|-------------|
| 0 | parent_world | Area type identifier (affects music, visuals) |
| 1 | ambient_sound | Background sound effect |
| 2 | content | Building type, boss stage, or special content |
| 3 | objectset | Enemy/object set |
| 4 | nav_right | Screen index when moving RIGHT (or 0xFF/0xFE) |
| 5 | nav_left | Screen index when moving LEFT (or 0xFF/0xFE) |
| 6 | nav_down | Screen index when moving DOWN (or 0xFF/0xFE) |
| 7 | nav_up | Screen index when moving UP (or 0xFF/0xFE) |
| 8 | datapointer | Tile data pointer |
| 9 | exit_position | Player spawn position on screen entry |
| 10 | top_tiles | Top half tile reference |
| 11 | bottom_tiles | Bottom half tile reference |
| 12 | worldscreen_color | Color palette |
| 13 | sprites_color | Sprite palette (0x12 = town) |
| 14 | unknown | Reserved |
| 15 | event | Event trigger (0x40 = stairway) |

### 2.2 Chapter Structure

| Chapter | Screen Count | Global Offset |
|---------|--------------|---------------|
| 1 | 131 | 0 |
| 2 | 137 | 131 |
| 3 | 153 | 268 |
| 4 | 164 | 421 |
| 5 | 154 | 585 |
| **Total** | **739** | - |

### 2.3 Navigation Special Values

| Value | Name | Meaning |
|-------|------|---------|
| 0xFF | NAV_BLOCKED | Cannot move in this direction |
| 0xFE | NAV_BUILDING | Enters a building (special transition) |
| 0x00-0xFD | Screen index | Valid destination screen |

### 2.4 Planned Section Structure (Post-Phase 1)

```
SectionPlan:
  section_id: int          # Unique ID within chapter (1, 2, 3, ...)
  section_type: enum       # OVERWORLD, TOWN, DUNGEON, MAZE, BOSS, VICTORY, SPECIAL
  target_screen_count: int # How many screens this section should have
  is_past: bool            # TRUE if this section is in PAST time period
  preserve_original: bool  # TRUE for BOSS, VICTORY, MAZE (keep original navigation)
```

### 2.5 Screen Assignment (Post-Phase 4)

```
ScreenAssignment:
  screen_index: int           # Real screen index in the chapter
  section_id: int             # Which planned section this belongs to
  grid_position: (x, y)       # Position in the section's abstract grid
```

**CRITICAL**: Each screen must have ONE assignment, ONE section, ONE grid position.

---

## 3. Constants and Enumerations

### 3.1 Time Period Detection

**CRITICAL**: Time period is determined by **SCREEN INDEX**, not ParentWorld.

```python
def get_time_period(chapter_num: int, screen_index: int) -> str:
    if screen_index in PAST_SCREEN_INDICES[chapter_num]:
        return "PAST"
    return "PRESENT"
```

#### PAST Screen Indices (Complete Lists)

```
Chapter 1 PAST screens (47 total):
0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E,
0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38,
0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42,
0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x69, 0x6A,
0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71

Chapter 2 PAST screens (44 total):
0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41,
0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B,
0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55,
0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x70, 0x78,
0x79, 0x7A, 0x7B, 0x7C

Chapter 3 PAST screens (48 total):
0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C,
0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46,
0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50,
0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A,
0x8C, 0x8D, 0x8E, 0x8F, 0x90, 0x91, 0x92, 0x93

Chapter 4 PAST screens (84 total):
0x1F, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D,
0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x51,
0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B,
0x5C, 0x5D, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F,
0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79,
0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F, 0x80, 0x81, 0x82, 0x83,
0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8C, 0x8E, 0x99,
0x9A, 0x9B, 0x9C, 0x9D, 0x9E

Chapter 5 PAST screens (27 total):
0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71,
0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B,
0x7C, 0x7D, 0x7E, 0x7F, 0x80, 0x81, 0x82
```

**All screens NOT in these lists are PRESENT.**

### 3.2 Time Door Detection

A screen is a Time Door when `content` is one of: `0xC0`, `0xC7`, `0xD7`

| Chapter | PRESENT Door | PAST Door |
|---------|--------------|-----------|
| 1 | Screen 26 (0x1A) | Screen 64 (0x40) |
| 2 | Screen 1 (0x01) | Screen 79 (0x4F) |
| 3 | Screen 50 (0x32) | Screen 75 (0x4B) |
| 4 | Screen 2 (0x02) | Screen 56 (0x38) |
| 5 | Screen 52 (0x34) | Screen 104 (0x68) |

### 3.3 Stairway Detection

A screen is a stairway when `event == 0x40`. The `content` byte is the destination screen index.

### 3.4 Known Intentional Cross-Time Exceptions

These cross-time connections exist in the original ROM by design and MUST be excluded from validation:

| Chapter | Source Screen | Target Screen | Direction | Reason |
|---------|---------------|---------------|-----------|--------|
| 4 | 53 (0x35) | 31 (0x1F) | LEFT | PAST dungeon exit → PRESENT overworld |

---

## 4. Validation Requirements

### Severity Levels

- **ERROR**: Test MUST fail if this condition is violated
- **WARNING**: Test should report but not fail
- **INFO**: Informational only

---

### R-001: Navigation Value Validity

**Severity**: ERROR

**Rule**:
```
FOR EACH screen IN chapter:
  FOR EACH direction IN [up, down, left, right]:
    nav_value = screen.nav_{direction}

    PASS IF: nav_value == 0xFF (blocked)
    PASS IF: nav_value == 0xFE (building entrance)
    PASS IF: nav_value < chapter.screen_count (valid screen index)
    FAIL IF: nav_value >= chapter.screen_count AND nav_value < 0xFE
```

**Failure Message**: `"Screen {idx} nav_{direction} = {value} is invalid (chapter has {count} screens)"`

---

### R-002: Time Period Boundary Integrity

**Severity**: ERROR

**Description**: Navigation must not cross time periods except via time doors.

**Rule**:
```
FOR EACH screen IN chapter:
  IF is_time_door(screen):
    SKIP

  IF (chapter_num, screen.index, target, direction) IN INTENTIONAL_EXCEPTIONS:
    SKIP

  source_period = get_time_period(chapter_num, screen.index)

  FOR EACH direction IN [up, down, left, right]:
    target = screen.nav_{direction}
    IF target < chapter.screen_count:
      target_period = get_time_period(chapter_num, target)
      FAIL IF: source_period != target_period
```

**Failure Message**: `"Screen {source} ({source_period}) -> Screen {target} ({target_period}) via {direction}: Cross-time navigation without time door"`

---

### R-003: Reachability from Entry Point

**Severity**: WARNING (< 95%), ERROR (< 50%)

**Rule**:
```
reachable = BFS_with_all_connections(chapter, start=0)

connections include:
  - Direct navigation (up/down/left/right)
  - Stairways (event == 0x40, bidirectional)
  - Time doors (content in {0xC0, 0xC7, 0xD7}, connect to other time door)

percent = len(reachable) / chapter.screen_count * 100

WARN IF: percent < 95%
FAIL IF: percent < 50%
```

**Failure Message**: `"Reachability {percent:.1f}% ({reachable}/{total} screens)"`

---

### R-004: World Connectivity

**Severity**: ERROR

**Rule**:
```
components = find_connected_components(chapter, include_stairways=True, include_time_doors=True)

FAIL IF: len(components) > 1
```

**Failure Message**: `"World fragmented into {count} disconnected regions"`

---

### R-005: Time Door Count

**Severity**: ERROR

**Rule**:
```
time_doors = [s for s in chapter if is_time_door(s)]

FAIL IF: len(time_doors) != 2
FAIL IF: count_in_present(time_doors) != 1
FAIL IF: count_in_past(time_doors) != 1
```

**Failure Message**: `"Expected 2 time doors (1 PRESENT, 1 PAST), found {count}"`

---

### R-006: Building Entrance Preservation

**Severity**: ERROR

**Rule**: Building entrances (0xFE) in original ROM must not be changed.

---

### R-007: Stairway Destination Validity

**Severity**: ERROR

**Rule**:
```
FOR EACH screen IN chapter:
  IF screen.event == 0x40:
    FAIL IF: screen.content >= chapter.screen_count
```

**Failure Message**: `"Stairway at screen {idx} has invalid destination {dest}"`

---

### R-008: Boss Screen Accessibility

**Severity**: ERROR

---

### R-009: Wizard Screen Accessibility

**Severity**: ERROR

---

### R-010: Section Screen Count Matches Plan

**Severity**: ERROR

**Description**: Each planned section must have screens assigned equal to or close to the target.

**Rule**:
```
FOR EACH section IN chapter_plan.sections:
  IF section.preserve_original:
    SKIP

  assigned = len(section.assigned_screens)
  target = section.target_screen_count

  FAIL IF: assigned == 0 AND section.is_required
  WARN IF: abs(assigned - target) > target * 0.5
```

**Failure Message**: `"Section {id} ({type}): assigned {assigned} screens, planned {target}"`

---

### R-011: Section Internal Connectivity

**Severity**: ERROR

**Description**: Non-preserved sections should form single connected components.

**Rule**:
```
FOR EACH section IN chapter_plan.sections:
  IF section.preserve_original:
    SKIP

  assigned = section.assigned_screens
  IF len(assigned) == 0:
    SKIP

  components = find_components_in_subset(chapter, assigned)
  FAIL IF: len(components) > 1
```

**Failure Message**: `"Section {id} ({type}) fragmented into {count} components: {sizes}"`

---

### R-012: Section Time Period Consistency

**Severity**: ERROR

**Description**: All screens assigned to a section must be in the SAME time period as the section's is_past flag.

**Rule**:
```
FOR EACH section IN chapter_plan.sections:
  expected_period = "PAST" IF section.is_past ELSE "PRESENT"

  FOR EACH screen_idx IN section.assigned_screens:
    actual_period = get_time_period(chapter_num, screen_idx)
    FAIL IF: actual_period != expected_period
```

**Failure Message**: `"Section {id} is {expected_period} but contains screen {screen_idx} which is {actual_period}"`

---

### R-013: Inter-Section Connectivity

**Severity**: ERROR

**Description**: Planned connections between sections must exist.

---

### R-014: Boss Connects to Victory

**Severity**: ERROR

---

### R-015: Edge Walkability Compatibility

**Severity**: WARNING

---

### R-016: No Screen Overlap in Grid Layout

**Severity**: ERROR

**Description**: Screens within the same section cannot occupy the same grid position.

**Rule**:
```
FOR EACH section IN chapter_plan.sections:
  positions_used = {}  # (x, y) -> screen_index

  FOR EACH assignment IN section.screen_assignments:
    pos = assignment.grid_position

    IF pos IN positions_used:
      FAIL: "Screen {assignment.screen_index} and screen {positions_used[pos]} both at grid position {pos}"

    positions_used[pos] = assignment.screen_index
```

**Failure Message**: `"Section {id}: Screen {a} and screen {b} overlap at grid position ({x}, {y})"`

---

### R-017: Navigation Must Respect Edge Passability

**Severity**: ERROR

**Description**: If a screen edge is completely blocked by collidable tiles, nav MUST be 0xFF.

**Rule**:
```
FOR EACH screen IN chapter:
  FOR EACH direction IN [right, left, down, up]:
    edge_tiles = get_edge_tiles(screen, direction)
    walkable_count = count(tile for tile in edge_tiles if is_walkable(tile))

    IF walkable_count == 0:
      FAIL IF: screen.nav_{direction} != 0xFF
```

**Failure Message**: `"Screen {idx} has blocked {direction} edge but nav_{direction} = {value} (should be 0xFF)"`

---

### R-018: Grid Navigation Consistency

**Severity**: ERROR

**Description**: Navigation values must match grid positions. If screen A is at (0,0) and screen B is at (1,0), then A.nav_right should equal B.

**Rule**:
```
FOR EACH section IN chapter_plan.sections:
  position_to_screen = {assignment.grid_position: assignment.screen_index for assignment in section}

  FOR EACH (pos, screen_idx) IN position_to_screen:
    screen = chapter.get_screen(screen_idx)
    x, y = pos

    # Check right neighbor
    right_pos = (x + 1, y)
    IF right_pos IN position_to_screen:
      expected = position_to_screen[right_pos]
      IF screen.nav_right != expected AND screen.nav_right != 0xFF:
        FAIL: "Screen {screen_idx} at ({x},{y}) nav_right = {actual}, expected {expected} (grid neighbor at ({x+1},{y}))"

    # Similar for left, up, down
```

**Failure Message**: `"Screen {idx} nav_{direction} = {actual}, expected {expected} based on grid position"`

---

### R-019: Section Count Matches Plan (CRITICAL)

**Severity**: ERROR

**Description**: The number of sections displayed in the UI Navigation Map MUST equal the number of sections in the Section Flow diagram. If Section Flow shows 8 sections, the Navigation Map MUST show exactly 8 section buttons - NOT 55, NOT based on ParentWorld, NOT based on any other ROM data.

**THIS IS THE MOST COMMON BUG**: The UI derives sections from ParentWorld byte values instead of using the planned sections from the randomizer.

**Rule**:
```
section_flow_count = len(chapter_plan.sections)  # From Phase 1 planning
navigation_map_sections = count of section buttons in UI

FAIL IF: navigation_map_sections != section_flow_count

# The UI MUST use chapter_population.screen_assignments to determine which
# section each screen belongs to, NOT the ParentWorld byte.
```

**Root Cause of Bug**:
- The UI code reads `screen.parent_world` from the ROM
- It groups screens by ParentWorld value (e.g., 0x10, 0x20, 0x40, etc.)
- This creates 40-55 "sections" because ParentWorld has many values
- **WRONG**: Sections should come from `chapter_population.screen_assignments`

**Correct Implementation**:
```typescript
// WRONG - DO NOT DO THIS
const sections = groupBy(screens, s => s.parent_world);

// CORRECT - Use planned section assignments
const sections = chapter_population.screen_assignments;
// This gives you: {1: [screen_indices], 2: [screen_indices], ...}
// Where 1, 2, etc. are the section IDs from the plan
```

**Failure Message**: `"UI shows {ui_count} sections but plan has {plan_count} sections"`

---

### R-020: Section Time Period Display

**Severity**: INFO (for UI)

**Description**: Sections in PAST time period should display with "(TD)" suffix in UI.

**Rule**:
```
FOR EACH section IN chapter_plan.sections:
  IF section.is_past:
    display_name = section.type + " (TD)"
  ELSE:
    display_name = section.type
```

---

### R-021: No Direct Town-to-Town Connection

**Severity**: WARNING

**Description**: Towns should not connect directly to other towns; they should be separated by other section types.

---

### R-022: Screens Only Assigned Once

**Severity**: ERROR

**Description**: Each screen can only be assigned to one section.

**Rule**:
```
all_assigned = []
FOR EACH section IN chapter_plan.sections:
  all_assigned.extend(section.assigned_screens)

FAIL IF: len(all_assigned) != len(set(all_assigned))
```

**Failure Message**: `"Screen {idx} assigned to multiple sections"`

---

## 5. Test Implementation Guide

### 5.1 Validation API Response Format

```json
{
  "status": "completed",
  "rom_filename": "...",
  "chapters": [
    {
      "chapter_num": 1,
      "total_screens": 131,
      "errors": [
        {
          "requirement": "R-002",
          "message": "Screen 5 (PRESENT) -> Screen 42 (PAST): Cross-time navigation",
          "details": {
            "source_screen": 5,
            "target_screen": 42,
            "direction": "down",
            "source_period": "PRESENT",
            "target_period": "PAST"
          }
        }
      ],
      "warnings": [...],
      "passed": false,
      "metrics": {
        "reachability_percent": 85.5,
        "section_count_planned": 8,
        "section_count_active": 8,
        "fragmented_sections": [],
        "time_period_violations": 12,
        "grid_overlap_count": 22
      }
    }
  ],
  "summary": {
    "total_errors": 15,
    "total_warnings": 5,
    "all_passed": false,
    "error_breakdown": {
      "R-002": 12,
      "R-016": 22,
      "R-018": 45
    }
  }
}
```

### 5.2 Required Validator Functions

```python
def validate_navigation_integrity(chapter) -> List[ValidationIssue]:
    """R-001: Check all nav values are valid"""

def validate_time_period_boundaries(chapter, chapter_num) -> List[ValidationIssue]:
    """R-002: Check no cross-time navigation except time doors"""

def validate_reachability(chapter) -> ValidationIssue:
    """R-003: Check reachability from screen 0"""

def validate_connectivity(chapter) -> ValidationIssue:
    """R-004: Check world is one connected component"""

def validate_time_doors(chapter, chapter_num) -> List[ValidationIssue]:
    """R-005: Check exactly 2 time doors, 1 each period"""

def validate_section_assignments(chapter_plan, chapter_pop) -> List[ValidationIssue]:
    """R-010, R-011, R-012, R-019, R-022: Section assignment validation"""

def validate_grid_positions(chapter_pop) -> List[ValidationIssue]:
    """R-016: Check no grid overlap"""

def validate_grid_navigation(chapter, chapter_pop) -> List[ValidationIssue]:
    """R-017, R-018: Check nav matches grid"""
```

### 5.3 Test Execution Order

1. R-001 (Navigation validity) - MUST pass before others
2. R-007 (Stairway validity)
3. R-005 (Time door count)
4. R-002 (Time period boundaries)
5. R-003 (Reachability)
6. R-004 (Connectivity)
7. R-010 through R-022 (Post-randomization)

---

## 6. Known Failures and Their Causes

### 6.1 "55 sections shown but plan has 8" (CRITICAL - MOST COMMON BUG)

**Symptom**:
- Section Flow tab shows 8 sections (correct)
- Navigation Map tab shows 55 section buttons (WRONG)

**Cause**: UI code is grouping screens by `screen.parent_world` (raw ROM byte) instead of using the planned section assignments.

**Where the Bug Is**: `ui/src/components/MapView.tsx` or similar component that renders section buttons.

**WRONG CODE** (what causes this bug):
```typescript
// Grouping by ParentWorld creates 40-55 sections
const sections = screens.reduce((acc, screen) => {
  const key = screen.parent_world;  // WRONG - this is raw ROM data
  ...
}, {});
```

**CORRECT CODE** (the fix):
```typescript
// Use planned section assignments - creates exactly 8 sections
const sections = plan.world_population.chapters[chapterNum].screen_assignments;
// Returns: {"1": [screen_indices], "2": [screen_indices], ...}
```

**Why ParentWorld Is Wrong For Grouping**:
- ParentWorld is a byte in the ROM (0x10, 0x20, 0x40, 0x53, 0x61, etc.)
- There are 40+ unique ParentWorld values across a chapter
- ParentWorld indicates area TYPE (town, dungeon, etc.) NOT which planned section
- The same ParentWorld can appear in BOTH PRESENT and PAST sections

**Note**: When assigning screens to sections, the backend SHOULD update each screen's ParentWorld to match its assigned section type. This is expected behavior - a screen assigned to a Town section should have a Town ParentWorld value. But the UI must still use `screen_assignments` for grouping, not ParentWorld, because:
1. ParentWorld update may not have happened yet
2. Section IDs (1, 2, 3...) don't map 1:1 to ParentWorld values

**API Data to Use**:
```
GET /api/plan returns:
  plan.world_population.chapters[N].screen_assignments = {
    "1": [0, 1, 2, 3, ...],    // Screens in planned section 1
    "2": [45, 46, 47, ...],    // Screens in planned section 2
    ...                         // Exactly 8 sections
  }
```

### 6.2 "22 screens stacked on same position"

**Cause**: Phase 4 (Population) is not storing grid positions, or Phase 5 (Navigation) is not using them.

**Fix**:
1. `ScreenAssignment` must include `grid_position: (x, y)`
2. Phase 4 must assign unique positions from shape
3. Phase 5 must use grid positions for navigation

### 6.3 "PRESENT screens linked to PAST screens"

**Cause**: Navigation is being set without checking time period consistency.

**Fix**:
1. Phase 4 must only assign screens to sections matching `is_past`
2. Phase 5 must only connect screens in same time period

### 6.4 "No (TD) suffix on PAST sections"

**Cause**: UI flow diagram not reading `is_past` from section plan.

**Fix**: MapView.tsx must check `section.is_past` and append " (TD)" to label.

### 6.5 "Sections fragmented into multiple components"

**Cause**: Navigation not properly connecting all screens in a section.

**Fix**: Phase 5 must build spanning tree connecting all screens in each section.

---

## Version History

| Date | Changes |
|------|---------|
| 2026-01-25 | Major rewrite: Added Core Concepts, Known Failures, structured error format |
| 2026-01-25 | Added R-019 through R-022 for comprehensive validation |
| 2026-01-25 | Added Section 6: Known Failures and Their Causes |
| 2026-01-25 | Reorganized into numbered requirements for AI testing |
| 2026-01-24 | Initial document created |
