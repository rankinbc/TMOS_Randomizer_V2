# TMOS Randomizer - Navigation System Implementation

## Project Overview

This is a map randomizer for "The Magic of Scheherazade" (NES). The randomizer reassigns screens to different sections and rewrites navigation so players explore a different world layout each run.

## Your Task

Implement the navigation system across Phases 4 and 5, and ensure the UI displays section data correctly.

## How the Randomizer Works

### Phase 1 (Planning) - DONE
Creates a plan with ~8 sections per chapter:
- Overworld, Town, Town, Dungeon, Maze, Boss, Victory, Special
- Each section has `section_id`, `section_type`, `is_past` (time period), `target_screen_count`

### Phase 2 (Shaping) - DONE
Creates abstract grid layouts for each section. Each screen gets a unique (x, y) grid position.

### Phase 3 (Connection) - DONE
Decides which sections connect to which (the section flow graph).

### Phase 4 (Population) - NEEDS WORK
Assigns real screen indices to sections. Must:
1. Assign screens to sections based on section type and time period
2. Store grid position for each assigned screen
3. Update screen's ParentWorld byte to match section type
4. Ensure all screens in a section are in the SAME time period (PRESENT or PAST)

### Phase 5 (Navigation) - NEEDS WORK
Rewrites navigation bytes (up/down/left/right) so screens connect properly. Must:
1. Connect screens within a section based on grid adjacency
2. If screen A is at (0,0) and screen B is at (1,0), then A.nav_right = B and B.nav_left = A
3. If an edge is blocked (all collision tiles), nav must be 0xFF
4. Never connect PRESENT screens to PAST screens (except via Time Door)

### UI - NEEDS WORK
The Navigation Map must display sections from the plan, not derived from ROM data.

## Key Requirements

Read `knowledge/systems/randomization-validation-criteria.md` for all 22 requirements. Critical ones:

| Req | Description |
|-----|-------------|
| R-002 | No PRESENT↔PAST navigation except via Time Door |
| R-012 | All screens in a section must be same time period |
| R-016 | No two screens at same grid position |
| R-017 | Blocked edges must have nav=0xFF |
| R-018 | Navigation must match grid adjacency |
| R-019 | UI section count must match plan section count |

## Time Period Rules

- Time period is determined by SCREEN INDEX, not ParentWorld
- See `PAST_SCREEN_INDICES` in `core/enums.py` for which screens are PAST
- Sections have `is_past` flag - only assign screens matching that time period
- PRESENT and PAST are connected ONLY via Time Door (Content=0xC0)

## Data Flow

```
Plan (Phase 1)
  └── sections: [{section_id: 1, type: OVERWORLD, is_past: false, target: 38}, ...]

Shape (Phase 2)
  └── section_shapes: [{section_id: 1, screens: [{local_id: 0, position: (0,0)}, ...]}, ...]

Population (Phase 4)
  └── screen_assignments: {1: [0,1,2,3...], 2: [45,46,47...], ...}
  └── section_grid_positions: {1: {(0,0): 0, (1,0): 1, ...}, ...}

Navigation (Phase 5)
  └── Updates screen.nav_right, nav_left, nav_up, nav_down based on grid positions
```

## Validation

Run `GET /api/debug/validate` to check all requirements. Returns structured errors with requirement IDs.

## Files

```
src/tmos_randomizer/
├── phases/
│   ├── phase4_population.py   # Screen assignment
│   └── phase5_navigation.py   # Navigation rewriting
├── core/
│   ├── enums.py               # PAST_SCREEN_INDICES, SectionType
│   └── worldscreen.py         # Screen data structure
└── testing/
    └── validators.py          # All validation functions

ui/src/components/
├── MapView.tsx                # Navigation map display
└── ScreenDetailPanel.tsx      # Screen details
```

## Success Criteria

1. Each chapter has exactly 8 sections (matching the plan)
2. Each section's screens form a connected component
3. No PRESENT↔PAST connections except Time Doors
4. Screens have unique grid positions within their section
5. Navigation values match grid adjacency
6. UI shows same number of sections as the plan
