#!/usr/bin/env python
"""Analyze past screens to find ParentWorld patterns for time periods.

The screen indices from TMOS_Romhack1 are GLOBAL WorldScreen indices.
We need to convert them to chapter-relative and analyze ParentWorld patterns.
"""

import sys
from pathlib import Path
from collections import defaultdict

# Add project to path
project_path = Path(__file__).parent / "src"
sys.path.insert(0, str(project_path))

from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.core.constants import CHAPTER_OFFSETS

# Past screen indices from TMOS_Romhack1
# Despite being called "global", these appear to be RELATIVE indices within each chapter
# (w2 has values like 0x4F=79, but Ch2 starts at global 131, so they must be relative)
PAST_SCREENS = {
    1: [0x40, 0x44, 0x43, 0x3F, 0x3A, 0x39, 0x3E, 0x3D, 0x38, 0x35, 0x2F, 0x30,
        0x31, 0x32, 0x29, 0x2A, 0x2B, 0x2C, 0x25, 0x26, 0x27, 0x28, 0x2E, 0x2D,
        0x33, 0x34, 0x36, 0x37, 0x3B, 0x3C, 0x41, 0x42, 0x6B, 0x69, 0x6A, 0x6C,
        0x4A, 0x48, 0x46, 0x45, 0x47, 0x49, 0x6F, 0x6E, 0x6D, 0x70, 0x71],

    2: [0x4F, 0x50, 0x51, 0x4B, 0x4C, 0x48, 0x47, 0x43, 0x44, 0x40, 0x3F, 0x3B,
        0x3A, 0x3E, 0x42, 0x43, 0x46, 0x4A, 0x4E, 0x4D, 0x49, 0x45, 0x41, 0x3D,
        0x39, 0x38, 0x3C, 0x70, 0x78, 0x79, 0x7C, 0x7B, 0x7A, 0x57, 0x5B, 0x58,
        0x54, 0x5C, 0x5D, 0x5A, 0x56, 0x53, 0x52, 0x55, 0x59],

    3: [0x4B, 0x4A, 0x4D, 0x4E, 0x52, 0x53, 0x57, 0x58, 0x59, 0x5A, 0x33, 0x56,
        0x55, 0x51, 0x50, 0x4F, 0x54, 0x4C, 0x49, 0x48, 0x47, 0x45, 0x44, 0x46,
        0x41, 0x3D, 0x3E, 0x3F, 0x42, 0x43, 0x40, 0x3C, 0x3B, 0x39, 0x38, 0x37,
        0x36, 0x3A, 0x34, 0x35, 0x8D, 0x8C, 0x8E, 0x8F, 0x91, 0x90, 0x92, 0x93],

    4: [0x38, 0x9A, 0x99, 0x9B, 0x9C, 0x9E, 0x9D, 0x37, 0x36, 0x35, 0x39, 0x3A,
        0x3B, 0x3C, 0x3D, 0x40, 0x3F, 0x3E, 0x44, 0x43, 0x42, 0x41, 0x4A, 0x49,
        0x48, 0x47, 0x46, 0x45, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52,
        0x59, 0x58, 0x57, 0x56, 0x55, 0x54, 0x53, 0x5A, 0x5B, 0x5C, 0x5D, 0x68,
        0x69, 0x6A, 0x6C, 0x6D, 0x6B, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x7A,
        0x7B, 0x7C, 0x79, 0x78, 0x77, 0x74, 0x75, 0x76, 0x89, 0x8A, 0x86, 0x85,
        0x81, 0x7D, 0x7E, 0x82, 0x83, 0x87, 0x88, 0x87, 0x7F, 0x84, 0x88, 0x84],

    5: [0x68, 0x6F, 0x76, 0x7D, 0x81, 0x7E, 0x77, 0x70, 0x69, 0x6A, 0x6B, 0x72,
        0x71, 0x78, 0x79, 0x80, 0x7F, 0x7E, 0x81, 0x82, 0x7A, 0x73, 0x6C, 0x6D,
        0x6E, 0x75, 0x7C, 0x7B, 0x74],
}



def main():
    rom_path = Path("TMOS_ORIGINAL.nes")
    if not rom_path.exists():
        print(f"ROM not found: {rom_path}")
        return

    game_world = load_rom(rom_path)

    print("=" * 80)
    print("TIME PERIOD ANALYSIS - ParentWorld patterns for PAST screens")
    print("=" * 80)

    # For each chapter, analyze which ParentWorld values are in PAST vs PRESENT
    for chapter_num in range(1, 6):
        chapter = game_world[chapter_num]
        past_indices = set(PAST_SCREENS.get(chapter_num, []))

        print(f"\n{'=' * 80}")
        print(f"CHAPTER {chapter_num}")
        print(f"Past screen count: {len(past_indices)}")
        print("=" * 80)

        # Count ParentWorld values for PAST vs PRESENT screens
        past_pw_counts = defaultdict(int)
        present_pw_counts = defaultdict(int)

        for screen in chapter:
            pw = screen.parent_world
            if screen.relative_index in past_indices:
                past_pw_counts[pw] += 1
            else:
                present_pw_counts[pw] += 1

        # Get all ParentWorld values
        all_pws = set(past_pw_counts.keys()) | set(present_pw_counts.keys())

        print(f"\n{'ParentWorld':<14} {'PAST':<10} {'PRESENT':<10} {'Time Period'}")
        print("-" * 50)

        for pw in sorted(all_pws):
            past_count = past_pw_counts.get(pw, 0)
            present_count = present_pw_counts.get(pw, 0)

            # Determine likely time period
            if past_count > 0 and present_count == 0:
                period = "PAST ONLY"
            elif present_count > 0 and past_count == 0:
                period = "PRESENT ONLY"
            elif past_count > present_count:
                period = f"MIXED (mostly PAST)"
            elif present_count > past_count:
                period = f"MIXED (mostly PRESENT)"
            else:
                period = "MIXED (equal)"

            print(f"0x{pw:02X}          {past_count:<10} {present_count:<10} {period}")

    # Summary: Find ParentWorld values that are EXCLUSIVELY past or present
    print(f"\n{'=' * 80}")
    print("SUMMARY: ParentWorld -> Time Period Mapping")
    print("=" * 80)

    # Aggregate across all chapters
    global_past = defaultdict(int)
    global_present = defaultdict(int)

    for chapter_num in range(1, 6):
        chapter = game_world[chapter_num]
        past_indices = set(PAST_SCREENS.get(chapter_num, []))

        for screen in chapter:
            pw = screen.parent_world
            if screen.relative_index in past_indices:
                global_past[pw] += 1
            else:
                global_present[pw] += 1

    all_pws = set(global_past.keys()) | set(global_present.keys())

    print(f"\n{'ParentWorld':<14} {'Total PAST':<12} {'Total PRESENT':<14} {'Conclusion'}")
    print("-" * 60)

    past_only = []
    present_only = []
    mixed = []

    for pw in sorted(all_pws):
        past_count = global_past.get(pw, 0)
        present_count = global_present.get(pw, 0)

        if past_count > 0 and present_count == 0:
            conclusion = "==> PAST"
            past_only.append(pw)
        elif present_count > 0 and past_count == 0:
            conclusion = "==> PRESENT"
            present_only.append(pw)
        else:
            pct_past = 100 * past_count / (past_count + present_count)
            conclusion = f"MIXED ({pct_past:.0f}% past)"
            mixed.append((pw, pct_past))

        print(f"0x{pw:02X}          {past_count:<12} {present_count:<14} {conclusion}")

    print(f"\n{'=' * 80}")
    print("FINAL CLASSIFICATION")
    print("=" * 80)

    print("\nPAST/FUTURE ParentWorld values:")
    for pw in sorted(past_only):
        print(f"  0x{pw:02X}")

    print("\nPRESENT ParentWorld values:")
    for pw in sorted(present_only):
        print(f"  0x{pw:02X}")

    print("\nMIXED ParentWorld values (needs investigation):")
    for pw, pct in sorted(mixed, key=lambda x: -x[1]):
        print(f"  0x{pw:02X} ({pct:.0f}% past)")


if __name__ == "__main__":
    main()
