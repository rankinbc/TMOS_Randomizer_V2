#!/usr/bin/env python3
"""Run Phase 5 for Chapter 2 only and trace connections."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.io.rom_reader import ROMReader
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases import phase1_planning, phase2_shaping, phase3_connection, phase4_population, phase5_navigation

import logging
logging.basicConfig(level=logging.DEBUG, format='%(name)s: %(message)s')
# Show all phase5 logs
logging.getLogger('tmos_randomizer.phases.phase5_navigation').setLevel(logging.DEBUG)

rom_reader = ROMReader('TMOS_ORIGINAL.nes')
game_world = rom_reader.read_all_chapters()
rom_data = rom_reader.data

seed = 12345
config = get_default_config()

# Run phases 1-4
world_plan = phase1_planning.plan_randomization(config, seed)
world_shape = phase2_shaping.shape_world(world_plan)
world_connections = phase3_connection.connect_world(world_plan, world_shape)
world_population = phase4_population.populate_world(game_world, world_plan, world_shape, seed)

print("="*60)
print("CHAPTER 2 - CONNECTIONS PLANNED")
print("="*60)
chapter2_conn = world_connections.get_chapter(2)
chapter2_pop = world_population.get_chapter(2)
for conn in chapter2_conn.connections:
    from_count = len(chapter2_pop.screen_assignments.get(conn.from_section_id, []))
    to_count = len(chapter2_pop.screen_assignments.get(conn.to_section_id, []))
    print(f"  {conn.from_section_id} -> {conn.to_section_id}: from={from_count}, to={to_count}")

print("\n" + "="*60)
print("RUNNING PHASE 5 - CHAPTER 2 ONLY")
print("="*60 + "\n")

# Get chapter 2 specific data
chapter = game_world.chapters[2]
chapter_shape = next((c for c in world_shape.chapters if c.chapter_num == 2), None)

# Run phase 5 for chapter 2
import random
rng = random.Random(seed)
chapter_nav = phase5_navigation.rewrite_chapter_navigation(
    chapter,
    chapter_shape,
    chapter2_conn,
    chapter2_pop,
    rng,
    preserve_buildings=True,
    rom_data=rom_data,
)

print("\n" + "="*60)
print("CHECKING INTER-SECTION CONNECTIONS AFTER PHASE 5")
print("="*60)

# Check if connections were made
for conn in chapter2_conn.connections:
    from_screens = chapter2_pop.screen_assignments.get(conn.from_section_id, [])
    to_screens = set(chapter2_pop.screen_assignments.get(conn.to_section_id, []))

    if not from_screens or not to_screens:
        print(f"  {conn.from_section_id} -> {conn.to_section_id}: SKIPPED (empty section)")
        continue

    # Check if any screen connects
    connected = False
    for screen_idx in from_screens:
        screen = chapter.get_screen(screen_idx)
        if screen:
            for direction in ["right", "left", "up", "down"]:
                nav_val = getattr(screen, f"screen_index_{direction}")
                if nav_val in to_screens:
                    connected = True
                    print(f"  {conn.from_section_id} -> {conn.to_section_id}: CONNECTED via screen {screen_idx}.{direction} = {nav_val}")
                    break
        if connected:
            break

    if not connected:
        print(f"  {conn.from_section_id} -> {conn.to_section_id}: NOT CONNECTED <<<")
