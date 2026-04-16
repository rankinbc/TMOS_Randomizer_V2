#!/usr/bin/env python3
"""Run validation to check for R-018 errors."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.testing.validators import run_all_chapter_validators, find_time_door_screens
from tmos_randomizer.io.rom_reader import ROMReader, load_rom
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases import phase1_planning, phase2_shaping, phase3_connection, phase4_population, phase5_navigation

import logging
logging.basicConfig(level=logging.INFO, format='%(name)s:%(levelname)s: %(message)s')

rom_reader = ROMReader('TMOS_ORIGINAL.nes')
game_world = rom_reader.read_all_chapters()
rom_data = rom_reader.data

seed = 12345
config = get_default_config()

# Phase 1
world_plan = phase1_planning.plan_randomization(config, seed)

# Phase 2
world_shape = phase2_shaping.shape_world(world_plan)

# Phase 3
world_connections = phase3_connection.connect_world(world_plan, world_shape)

# Phase 4
world_population = phase4_population.populate_world(game_world, world_plan, world_shape, seed)

# Debug BEFORE Phase 5
chapter_before = game_world.chapters[1]
screen_79_before = chapter_before.get_screen(79)
print(f"\n=== BEFORE Phase 5: Screen 79 ===")
print(f"  nav_right: {screen_79_before.screen_index_right}")
print(f"  nav_left: {screen_79_before.screen_index_left}")

# Phase 5
world_navigation = phase5_navigation.rewrite_world_navigation(
    game_world, world_shape, world_connections, world_population, seed, rom_data=rom_data
)

# Debug AFTER Phase 5
chapter_after = game_world.chapters[1]
screen_79_after = chapter_after.get_screen(79)
print(f"\n=== AFTER Phase 5: Screen 79 ===")
print(f"  nav_right: {screen_79_after.screen_index_right}")
print(f"  nav_left: {screen_79_after.screen_index_left}")
print(f"  Same chapter object: {chapter_before is chapter_after}")
print(f"  Same screen object: {screen_79_before is screen_79_after}")

# Run validation
chapter = game_world.chapters[1]
chapter_plan = world_plan.get_chapter(1)
chapter_population = world_population.get_chapter(1)
chapter_connections = world_connections.get_chapter(1)
time_door_screens = find_time_door_screens(chapter)

results = run_all_chapter_validators(
    chapter, chapter_plan, chapter_population, chapter_connections,
    rom_data=rom_data,
    time_door_screens=time_door_screens
)

# Debug: Check actual navigation values on screen 79
screen_79 = chapter.get_screen(79)
print(f"\n=== Debug: Screen 79 navigation ===")
print(f"  nav_right: {screen_79.screen_index_right}")
print(f"  nav_left: {screen_79.screen_index_left}")
print(f"  nav_down: {screen_79.screen_index_down}")
print(f"  nav_up: {screen_79.screen_index_up}")

# Check DO_NOT_RANDOMIZE for screen 75
from tmos_randomizer.core.constants import relative_to_global
from tmos_randomizer.core.enums import DO_NOT_RANDOMIZE
global_75 = relative_to_global(1, 75)
global_2 = relative_to_global(1, 2)
print(f"  Global 75 (from screen 79 left): {global_75}, in DO_NOT_RANDOMIZE: {global_75 in DO_NOT_RANDOMIZE}")
print(f"  Global 2: {global_2}, in DO_NOT_RANDOMIZE: {global_2 in DO_NOT_RANDOMIZE}")

# Debug: Check grid positions
print("\n=== Debug: Grid Positions ===")
for section_id, grid in chapter_population.section_grid_positions.items():
    print(f"Section {section_id}: {len(grid)} positions")
    for pos, screen_idx in list(grid.items())[:3]:
        print(f"  {pos} -> screen {screen_idx}")

# Debug: Check screen_to_position
print(f"\nscreen_to_position: {len(chapter_population.screen_to_position)} entries")
for screen_idx, pos in list(chapter_population.screen_to_position.items())[:5]:
    print(f"  screen {screen_idx} -> {pos}")

# Count errors by requirement
from collections import Counter
from tmos_randomizer.testing.validators import IssueSeverity

error_issues = [issue for issue in results if issue.severity == IssueSeverity.ERROR]
warning_issues = [issue for issue in results if issue.severity == IssueSeverity.WARNING]
print(f'\nTotal results: {len(results)} (errors: {len(error_issues)}, warnings: {len(warning_issues)})')
req_counts = Counter(issue.requirement or 'unknown' for issue in error_issues)
print('Error counts by requirement:')
for req, count in sorted(req_counts.items(), key=lambda x: (x[0] is None, x[0])):
    print(f'  {req}: {count}')
print(f'Total errors: {sum(req_counts.values())}')

# Show some R-018 examples
r018_errors = [i for i in error_issues if i.requirement == 'R-018']
print(f'\nR-018 examples (first 5):')
for err in r018_errors[:5]:
    print(f'  {err.message}')
    print(f'    Details: {err.details}')

# Show R-011 errors
r011_errors = [i for i in error_issues if i.requirement == 'R-011']
print(f'\nR-011 examples (first 5):')
for err in r011_errors[:5]:
    print(f'  {err.message}')
    print(f'    Details: {err.details}')

# Show unknown errors
unknown_errors = [i for i in error_issues if i.requirement is None]
print(f'\nUnknown requirement errors ({len(unknown_errors)} total, first 10):')
for err in unknown_errors[:10]:
    print(f'  Category: {err.category}')
    print(f'  Message: {err.message}')
    print(f'  Screen: {err.screen_index}')
    if err.details:
        print(f'  Details: {err.details}')

# Count by category
cat_counts = Counter(err.category for err in error_issues)
print(f'\nError counts by category:')
for cat, count in cat_counts.most_common():
    print(f'  {cat}: {count}')

# Warning counts
print(f'\nWarning counts by requirement:')
warn_req_counts = Counter(w.requirement or 'unknown' for w in warning_issues)
for req, count in sorted(warn_req_counts.items(), key=lambda x: (x[0] is None, x[0])):
    print(f'  {req}: {count}')
