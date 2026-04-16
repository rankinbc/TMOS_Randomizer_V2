#!/usr/bin/env python3
"""Run full validation across all chapters."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.testing.validators import run_all_chapter_validators, find_time_door_screens, IssueSeverity
from tmos_randomizer.io.rom_reader import ROMReader, load_rom
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases import phase1_planning, phase2_shaping, phase3_connection, phase4_population, phase5_navigation

import logging
from collections import Counter

logging.basicConfig(level=logging.WARNING, format='%(name)s:%(levelname)s: %(message)s')

rom_reader = ROMReader('TMOS_ORIGINAL.nes')
game_world = rom_reader.read_all_chapters()
rom_data = rom_reader.data

seed = 12345
config = get_default_config()

print("Running randomization phases...")

# Phase 1
world_plan = phase1_planning.plan_randomization(config, seed)

# Phase 2
world_shape = phase2_shaping.shape_world(world_plan)

# Phase 3
world_connections = phase3_connection.connect_world(world_plan, world_shape)

# Phase 4
world_population = phase4_population.populate_world(game_world, world_plan, world_shape, seed)

# Phase 5
world_navigation = phase5_navigation.rewrite_world_navigation(
    game_world, world_shape, world_connections, world_population, seed, rom_data=rom_data
)

print("\n" + "="*60)
print("VALIDATION RESULTS")
print("="*60)

total_errors = 0
total_warnings = 0
all_errors = []
all_warnings = []

for chapter_num in range(1, 6):
    chapter = game_world.chapters[chapter_num]
    chapter_plan = world_plan.get_chapter(chapter_num)
    chapter_population = world_population.get_chapter(chapter_num)
    chapter_connections = world_connections.get_chapter(chapter_num)
    time_door_screens = find_time_door_screens(chapter)

    results = run_all_chapter_validators(
        chapter, chapter_plan, chapter_population, chapter_connections,
        rom_data=rom_data,
        time_door_screens=time_door_screens
    )

    errors = [i for i in results if i.severity == IssueSeverity.ERROR]
    warnings = [i for i in results if i.severity == IssueSeverity.WARNING]

    print(f"\nChapter {chapter_num}: {len(errors)} errors, {len(warnings)} warnings")

    if errors:
        req_counts = Counter(i.requirement or 'unknown' for i in errors)
        for req, count in sorted(req_counts.items()):
            print(f"  {req}: {count} errors")

    total_errors += len(errors)
    total_warnings += len(warnings)
    all_errors.extend(errors)
    all_warnings.extend(warnings)

print("\n" + "="*60)
print("SUMMARY")
print("="*60)
print(f"Total errors: {total_errors}")
print(f"Total warnings: {total_warnings}")

if total_errors == 0:
    print("\n✓ ALL VALIDATION REQUIREMENTS PASS!")
else:
    print("\n✗ Validation failed with errors")

    # Show error breakdown
    req_counts = Counter(i.requirement or 'unknown' for i in all_errors)
    print("\nError breakdown:")
    for req, count in sorted(req_counts.items()):
        print(f"  {req}: {count}")

# Show warning breakdown
if all_warnings:
    warn_req_counts = Counter(w.requirement or 'unknown' for w in all_warnings)
    print("\nWarning breakdown:")
    for req, count in sorted(warn_req_counts.items()):
        print(f"  {req}: {count}")
