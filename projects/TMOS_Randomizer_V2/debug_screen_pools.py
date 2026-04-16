#!/usr/bin/env python3
"""Debug screen pool categorization."""

import sys
sys.path.insert(0, "src")

from tmos_randomizer.io.rom_reader import ROMReader
from tmos_randomizer.core.enums import PARENTWORLD_TO_SECTION, SectionType, is_past_screen_index
from tmos_randomizer.logic.exclusions import is_excluded

rom_reader = ROMReader('TMOS_ORIGINAL.nes')
game_world = rom_reader.read_all_chapters()

print("="*60)
print("SCREEN POOL ANALYSIS")
print("="*60)

for chapter_num in [3, 4]:  # Chapters with most issues
    print(f"\n--- Chapter {chapter_num} ---")
    chapter = game_world.chapters[chapter_num]

    # Group screens by section type
    pools = {}
    excluded_count = 0
    for screen in chapter:
        if is_excluded(screen):
            excluded_count += 1
            continue

        section_type = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)
        is_past = is_past_screen_index(chapter_num, screen.relative_index)
        period = "PAST" if is_past else "PRESENT"
        key = f"{section_type.name} ({period})"

        if key not in pools:
            pools[key] = []
        pools[key].append(screen.relative_index)

    print(f"Total screens: {len(chapter)}")
    print(f"Excluded: {excluded_count}")
    print(f"Available for assignment: {len(chapter) - excluded_count}")

    print(f"\nScreen pools by type and time period:")
    for key in sorted(pools.keys()):
        screens = pools[key]
        print(f"  {key}: {len(screens)} screens")
        if "MAZE" in key or "SPECIAL" in key:
            print(f"    Indices: {screens[:10]}{'...' if len(screens) > 10 else ''}")

    # Check what MAZE/SPECIAL screens exist
    print(f"\nSearching for MAZE/SPECIAL types in ParentWorld:")
    maze_pw = set()
    special_pw = set()
    for screen in chapter:
        if is_excluded(screen):
            continue
        st = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)
        if st == SectionType.MAZE:
            maze_pw.add(screen.parent_world)
        if st == SectionType.SPECIAL:
            special_pw.add(screen.parent_world)
    print(f"  MAZE parent_worlds used: {[hex(x) for x in maze_pw]}")
    print(f"  SPECIAL parent_worlds used: {[hex(x) for x in special_pw]}")
