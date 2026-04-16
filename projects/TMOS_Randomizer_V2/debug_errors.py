#!/usr/bin/env python3
"""Debug specific errors found in validation."""

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

# Run phases
world_plan = phase1_planning.plan_randomization(config, seed)
world_shape = phase2_shaping.shape_world(world_plan)
world_connections = phase3_connection.connect_world(world_plan, world_shape)
world_population = phase4_population.populate_world(game_world, world_plan, world_shape, seed)
world_navigation = phase5_navigation.rewrite_world_navigation(
    game_world, world_shape, world_connections, world_population, seed, rom_data=rom_data
)

print("="*60)
print("DEBUGGING ERRORS")
print("="*60)

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

    if errors:
        print(f"\n--- Chapter {chapter_num} Errors ({len(errors)}) ---")
        for err in errors:
            print(f"\nRequirement: {err.requirement or 'unknown'}")
            print(f"Category: {err.category}")
            print(f"Message: {err.message}")
            print(f"Screen: {err.screen_index}")
            if err.details:
                print(f"Details: {err.details}")
