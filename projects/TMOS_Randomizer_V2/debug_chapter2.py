#!/usr/bin/env python3
"""Trace Chapter 2 connections precisely."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.io.rom_reader import ROMReader
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases import phase1_planning, phase2_shaping, phase3_connection, phase4_population

rom_reader = ROMReader('TMOS_ORIGINAL.nes')
game_world = rom_reader.read_all_chapters()

seed = 12345
config = get_default_config()

# Run phases 1-3
world_plan = phase1_planning.plan_randomization(config, seed)
world_shape = phase2_shaping.shape_world(world_plan)
world_connections = phase3_connection.connect_world(world_plan, world_shape)

print("="*60)
print("CHAPTER 2 CONNECTIONS AFTER PHASE 3 (before Phase 4)")
print("="*60)
chapter2_conn = world_connections.get_chapter(2)
for conn in chapter2_conn.connections:
    print(f"  {conn.from_section_id} -> {conn.to_section_id}")

print("\n" + "="*60)
print("NOW RUNNING PHASE 4")
print("="*60)
world_population = phase4_population.populate_world(game_world, world_plan, world_shape, seed)

print("\n" + "="*60)
print("CHAPTER 2 CONNECTIONS AFTER PHASE 4")
print("="*60)
# Check if connections have changed
chapter2_conn = world_connections.get_chapter(2)
for conn in chapter2_conn.connections:
    print(f"  {conn.from_section_id} -> {conn.to_section_id}")

# Also check section assignments
chapter2_pop = world_population.get_chapter(2)
print("\n" + "="*60)
print("CHAPTER 2 SECTION ASSIGNMENTS")
print("="*60)
for section_id in sorted(chapter2_pop.screen_assignments.keys()):
    screens = chapter2_pop.screen_assignments[section_id]
    print(f"  Section {section_id}: {len(screens)} screens")
