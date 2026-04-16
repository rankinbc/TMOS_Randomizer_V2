#!/usr/bin/env python3
"""Debug section assignments and connections."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.io.rom_reader import ROMReader
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases import phase1_planning, phase2_shaping, phase3_connection, phase4_population, phase5_navigation

import logging
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

print("="*60)
print("SECTION AND CONNECTION ANALYSIS")
print("="*60)

for chapter_num in [2, 3, 4, 5]:  # Chapters with errors
    print(f"\n--- Chapter {chapter_num} ---")

    chapter_plan = world_plan.get_chapter(chapter_num)
    chapter_pop = world_population.get_chapter(chapter_num)
    chapter_conn = world_connections.get_chapter(chapter_num)

    # Print section assignments
    print(f"Sections and assignments:")
    for section in chapter_plan.sections:
        assigned = chapter_pop.screen_assignments.get(section.section_id, [])
        print(f"  Section {section.section_id}: {section.section_type.name} "
              f"(target={section.target_screen_count}, assigned={len(assigned)}, preserved={section.preserve_original})")
        if len(assigned) == 0 and not section.preserve_original:
            print(f"    >>> EMPTY NON-PRESERVED SECTION!")

    # Print connections
    print(f"\nPlanned connections:")
    for conn in chapter_conn.connections:
        from_screens = chapter_pop.screen_assignments.get(conn.from_section_id, [])
        to_screens = chapter_pop.screen_assignments.get(conn.to_section_id, [])
        status = "OK" if from_screens and to_screens else "MISSING SCREENS"
        print(f"  Section {conn.from_section_id} -> Section {conn.to_section_id}: "
              f"from_count={len(from_screens)}, to_count={len(to_screens)} [{status}]")
