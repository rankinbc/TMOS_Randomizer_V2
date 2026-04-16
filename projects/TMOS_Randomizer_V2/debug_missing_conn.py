#!/usr/bin/env python3
"""Debug why inter-section connections are failing."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.testing.validators import run_all_chapter_validators, find_time_door_screens, IssueSeverity
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
world_navigation = phase5_navigation.rewrite_world_navigation(
    game_world, world_shape, world_connections, world_population, seed, rom_data=rom_data
)

# Find chapters with R-013 errors
for chapter_num in [2, 3, 4, 5]:
    chapter = game_world.chapters[chapter_num]
    chapter_plan = world_plan.get_chapter(chapter_num)
    chapter_pop = world_population.get_chapter(chapter_num)
    chapter_conn = world_connections.get_chapter(chapter_num)
    time_door_screens = find_time_door_screens(chapter)

    results = run_all_chapter_validators(
        chapter, chapter_plan, chapter_pop, chapter_conn,
        rom_data=rom_data, time_door_screens=time_door_screens
    )

    errors = [i for i in results if i.severity == IssueSeverity.ERROR and i.requirement == "R-013"]

    if not errors:
        continue

    print(f"\n--- Chapter {chapter_num}: {len(errors)} R-013 errors ---")

    for err in errors:
        # Parse section IDs from message
        msg = err.message
        print(f"\n{msg}")

        # Extract from/to sections
        parts = msg.replace("No navigation from section ", "").replace(" to section ", ",").split(",")
        from_section = int(parts[0])
        to_section = int(parts[1])

        from_screens = chapter_pop.screen_assignments.get(from_section, [])
        to_screens = chapter_pop.screen_assignments.get(to_section, [])

        print(f"  from_screens (section {from_section}): {len(from_screens)}")
        print(f"  to_screens (section {to_section}): {len(to_screens)}")

        if not from_screens or not to_screens:
            print(f"  >>> One section is EMPTY - shouldn't be an error!")
            continue

        # Check actual navigation between sections
        connected = False
        connections_found = []
        for screen_idx in from_screens:
            screen = chapter.get_screen(screen_idx)
            if screen is None:
                continue
            for direction in ["right", "left", "up", "down"]:
                nav_val = getattr(screen, f"screen_index_{direction}")
                if nav_val in set(to_screens):
                    connections_found.append((screen_idx, direction, nav_val))
                    connected = True

        if connected:
            print(f"  >>> Actually CONNECTED via: {connections_found[:3]}")
        else:
            # Show what navigation values exist
            print(f"  Navigation from first few screens:")
            for screen_idx in from_screens[:3]:
                screen = chapter.get_screen(screen_idx)
                if screen:
                    print(f"    Screen {screen_idx}: R={screen.screen_index_right}, L={screen.screen_index_left}, D={screen.screen_index_down}, U={screen.screen_index_up}")
