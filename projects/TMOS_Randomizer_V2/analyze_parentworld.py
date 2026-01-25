#!/usr/bin/env python
"""Analyze ParentWorld values across all chapters to identify time periods."""

import sys
from pathlib import Path
from collections import defaultdict

# Add project to path
project_path = Path(__file__).parent / "src"
sys.path.insert(0, str(project_path))

from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.core.constants import CHAPTER_OFFSETS


def main():
    rom_path = Path("TMOS_ORIGINAL.nes")
    if not rom_path.exists():
        print(f"ROM not found: {rom_path}")
        return

    game_world = load_rom(rom_path)

    print("=" * 80)
    print("PARENTWORLD VALUE ANALYSIS")
    print("=" * 80)

    # Collect all unique ParentWorld values per chapter
    all_parent_worlds = set()

    for chapter_num in range(1, 6):
        chapter = game_world[chapter_num]

        print(f"\n{'=' * 80}")
        print(f"CHAPTER {chapter_num}")
        print("=" * 80)

        # Group screens by ParentWorld
        by_pw = defaultdict(list)
        for screen in chapter:
            by_pw[screen.parent_world].append(screen.relative_index)
            all_parent_worlds.add(screen.parent_world)

        # Print sorted by ParentWorld value
        print(f"\n{'ParentWorld':<14} {'Count':<8} {'Screen Range':<30} {'Hex Range'}")
        print("-" * 70)

        for pw in sorted(by_pw.keys()):
            screens = sorted(by_pw[pw])
            count = len(screens)

            # Show first few and last few screens
            if len(screens) <= 6:
                screen_str = str(screens)
            else:
                screen_str = f"[{screens[0]}, {screens[1]}, {screens[2]}, ..., {screens[-2]}, {screens[-1]}]"

            # Truncate if too long
            if len(screen_str) > 28:
                screen_str = screen_str[:25] + "..."

            print(f"0x{pw:02X}          {count:<8} {screen_str:<30}")

    # Summary of all unique ParentWorld values
    print(f"\n{'=' * 80}")
    print("ALL UNIQUE PARENTWORLD VALUES (across all chapters)")
    print("=" * 80)

    for pw in sorted(all_parent_worlds):
        # Determine which chapters have this value
        chapters_with = []
        for chapter_num in range(1, 6):
            chapter = game_world[chapter_num]
            if any(s.parent_world == pw for s in chapter):
                chapters_with.append(chapter_num)

        chapters_str = ", ".join(map(str, chapters_with))
        print(f"0x{pw:02X}  - Chapters: {chapters_str}")

    # Analyze patterns
    print(f"\n{'=' * 80}")
    print("PATTERN ANALYSIS")
    print("=" * 80)

    # Group by high nibble
    by_high_nibble = defaultdict(set)
    for pw in all_parent_worlds:
        high = (pw >> 4) & 0x0F
        by_high_nibble[high].add(pw)

    print("\nGrouped by high nibble:")
    for high in sorted(by_high_nibble.keys()):
        values = sorted(by_high_nibble[high])
        values_str = ", ".join(f"0x{v:02X}" for v in values)
        print(f"  0x{high:X}0-0x{high:X}F: {values_str}")


if __name__ == "__main__":
    main()
