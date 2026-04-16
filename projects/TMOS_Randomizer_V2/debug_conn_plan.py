#!/usr/bin/env python3
"""Debug connection plan vs what Phase 5 processes."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.io.rom_reader import ROMReader
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases import phase1_planning, phase2_shaping, phase3_connection, phase4_population

rom_reader = ROMReader('TMOS_ORIGINAL.nes')
game_world = rom_reader.read_all_chapters()

seed = 12345
config = get_default_config()

# Run phases 1-4
world_plan = phase1_planning.plan_randomization(config, seed)
world_shape = phase2_shaping.shape_world(world_plan)
world_connections = phase3_connection.connect_world(world_plan, world_shape)
world_population = phase4_population.populate_world(game_world, world_plan, world_shape, seed)

print("="*60)
print("CONNECTION PLANS BY CHAPTER")
print("="*60)

for chapter_num in [1, 2, 3, 4, 5]:
    chapter_conn = world_connections.get_chapter(chapter_num)
    chapter_pop = world_population.get_chapter(chapter_num)

    print(f"\n--- Chapter {chapter_num} ---")
    print(f"Planned connections (from Phase 3):")
    for conn in chapter_conn.connections:
        from_screens = len(chapter_pop.screen_assignments.get(conn.from_section_id, []))
        to_screens = len(chapter_pop.screen_assignments.get(conn.to_section_id, []))
        print(f"  {conn.from_section_id} -> {conn.to_section_id} (method={conn.method}, from={from_screens}, to={to_screens})")

    # Check section types
    chapter_plan = world_plan.get_chapter(chapter_num)
    print(f"\nSections (from Phase 1):")
    for section in chapter_plan.sections:
        assigned = len(chapter_pop.screen_assignments.get(section.section_id, []))
        print(f"  {section.section_id}: {section.section_type.name} (target={section.target_screen_count}, assigned={assigned}, preserved={section.preserve_original})")
