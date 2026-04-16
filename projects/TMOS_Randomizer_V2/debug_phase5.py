#!/usr/bin/env python3
"""Debug Phase 5 inter-section connection creation."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.io.rom_reader import ROMReader
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases import phase1_planning, phase2_shaping, phase3_connection, phase4_population, phase5_navigation

import logging
logging.basicConfig(level=logging.INFO, format='%(name)s:%(levelname)s: %(message)s')

# Enable DEBUG for phase5
logging.getLogger('tmos_randomizer.phases.phase5_navigation').setLevel(logging.DEBUG)

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

# Run just phase 5 for chapter 2 to see detailed logs
print("\n" + "="*60)
print("RUNNING PHASE 5 FOR CHAPTER 2")
print("="*60 + "\n")

# Get chapter 2 data
chapter = game_world.chapters[2]
chapter_shape = next((c for c in world_shape.chapters if c.chapter_num == 2), None)
chapter_connections = world_connections.get_chapter(2)
chapter_population = world_population.get_chapter(2)

print(f"Chapter 2 connections planned:")
for conn in chapter_connections.connections:
    from_screens = chapter_population.screen_assignments.get(conn.from_section_id, [])
    to_screens = chapter_population.screen_assignments.get(conn.to_section_id, [])
    print(f"  {conn.from_section_id} -> {conn.to_section_id}: method={conn.method}, from_count={len(from_screens)}, to_count={len(to_screens)}")

# Run phase 5
world_navigation = phase5_navigation.rewrite_world_navigation(
    game_world, world_shape, world_connections, world_population, seed, rom_data=rom_data
)

print("\n" + "="*60)
print("AFTER PHASE 5: Check Section 2 -> Section 4 connection")
print("="*60 + "\n")

# Check if connection was made
from_screens = chapter_population.screen_assignments.get(2, [])
to_screens = set(chapter_population.screen_assignments.get(4, []))

print(f"Section 2 screens: {from_screens}")
print(f"Section 4 screens: {to_screens}")

for screen_idx in from_screens:
    screen = chapter.get_screen(screen_idx)
    if screen:
        for direction in ["right", "left", "up", "down"]:
            nav_val = getattr(screen, f"screen_index_{direction}")
            if nav_val in to_screens:
                print(f"  FOUND: Screen {screen_idx} connects {direction} to {nav_val} (section 4)")
