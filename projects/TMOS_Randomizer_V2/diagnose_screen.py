#!/usr/bin/env python
"""Diagnostic tool to inspect individual screens and verify validator accuracy.

Usage:
    python diagnose_screen.py --chapter 1 --screen 26
    python diagnose_screen.py --chapter 1 --screen 26 --neighbors
    python diagnose_screen.py --chapter 1 --all-time-doors
    python diagnose_screen.py --chapter 1 --validate-sample
"""

import argparse
from pathlib import Path
import sys

# Add project to path
project_path = Path(__file__).parent / "src"
sys.path.insert(0, str(project_path))

from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.core.enums import (
    get_time_period_for_screen,
    TimePeriod,
    PAST_SCREEN_INDICES,
)
from tmos_randomizer.testing.validators import (
    find_time_door_screens,
    INTENTIONAL_CROSS_TIME_EXITS,
)


def dump_screen(chapter, screen_idx: int, show_neighbors: bool = False):
    """Dump all data for a single screen."""
    screen = chapter.get_screen(screen_idx)
    if screen is None:
        print(f"Screen {screen_idx} not found in chapter {chapter.chapter_num}")
        return

    ch_num = chapter.chapter_num
    period = get_time_period_for_screen(ch_num, screen_idx)
    is_past = screen_idx in PAST_SCREEN_INDICES.get(ch_num, set())

    print(f"\n{'=' * 60}")
    print(f"CHAPTER {ch_num} - SCREEN {screen_idx} (0x{screen_idx:02X})")
    print(f"{'=' * 60}")
    print(f"Time Period: {period.name} (in PAST_SCREEN_INDICES: {is_past})")
    print()
    print("Raw 16-byte data:")
    print(f"  ParentWorld:    0x{screen.parent_world:02X}")
    print(f"  AmbientSound:   0x{screen.ambient_sound:02X}")
    print(f"  Content:        0x{screen.content:02X}")
    print(f"  ObjectSet:      0x{screen.objectset:02X}")
    print(f"  NavRight:       {screen.screen_index_right} (0x{screen.screen_index_right:02X})")
    print(f"  NavLeft:        {screen.screen_index_left} (0x{screen.screen_index_left:02X})")
    print(f"  NavDown:        {screen.screen_index_down} (0x{screen.screen_index_down:02X})")
    print(f"  NavUp:          {screen.screen_index_up} (0x{screen.screen_index_up:02X})")
    print(f"  DataPointer:    0x{screen.datapointer:02X}")
    print(f"  ExitPosition:   0x{screen.exit_position:02X}")
    print(f"  TopTiles:       0x{screen.top_tiles:02X}")
    print(f"  BottomTiles:    0x{screen.bottom_tiles:02X}")
    print(f"  WorldScreenColor: 0x{screen.worldscreen_color:02X}")
    print(f"  SpritesColor:   0x{screen.sprites_color:02X}")
    print(f"  Unknown:        0x{screen.unknown:02X}")
    print(f"  Event:          0x{screen.event.value if hasattr(screen.event, 'value') else screen.event:02X}")

    # Check special values
    print()
    print("Interpretation:")
    if screen.content == 0xC0:
        print("  ** THIS IS A TIME DOOR (Content=0xC0) **")
    if screen.content in (0xC7, 0xD7):
        print(f"  ** TIME DOOR EXIT (Content=0x{screen.content:02X}) **")
    if screen.sprites_color == 0x12:
        print("  ** TOWN SCREEN (SpritesColor=0x12) **")
    if screen.content >= 0x21 and screen.content <= 0x2A:
        print(f"  ** BOSS SCREEN (Content=0x{screen.content:02X}) **")
    if screen.content == 0x01:
        print("  ** WIZARD SCREEN (Content=0x01) **")

    if show_neighbors:
        print()
        print("Navigation targets and their time periods:")
        for direction, attr in [("Up", "screen_index_up"), ("Down", "screen_index_down"),
                                ("Left", "screen_index_left"), ("Right", "screen_index_right")]:
            nav = getattr(screen, attr)
            if nav == 0xFF:
                print(f"  {direction}: BLOCKED (0xFF)")
            elif nav == 0xFE:
                print(f"  {direction}: BUILDING ENTRANCE (0xFE)")
            elif nav >= len(chapter):
                print(f"  {direction}: INVALID ({nav} >= {len(chapter)} screens)")
            else:
                target_period = get_time_period_for_screen(ch_num, nav)
                cross = " ** CROSS-TIME! **" if period != target_period else ""
                print(f"  {direction}: Screen {nav} ({target_period.name}){cross}")


def show_time_doors(chapter):
    """Show all time doors in a chapter."""
    ch_num = chapter.chapter_num
    time_doors = find_time_door_screens(chapter)

    print(f"\n{'=' * 60}")
    print(f"CHAPTER {ch_num} - TIME DOORS")
    print(f"{'=' * 60}")
    print(f"Found {len(time_doors)} time door(s): {sorted(time_doors)}")

    for idx in sorted(time_doors):
        screen = chapter.get_screen(idx)
        period = get_time_period_for_screen(ch_num, idx)
        print(f"\n  Screen {idx} (0x{idx:02X}):")
        print(f"    Content: 0x{screen.content:02X}")
        print(f"    Time Period: {period.name}")
        print(f"    ParentWorld: 0x{screen.parent_world:02X}")


def validate_sample(chapter):
    """Validate a sample of screens and show detailed results."""
    ch_num = chapter.chapter_num
    time_doors = find_time_door_screens(chapter)
    past_screens = PAST_SCREEN_INDICES.get(ch_num, set())

    print(f"\n{'=' * 60}")
    print(f"CHAPTER {ch_num} - VALIDATION SAMPLE")
    print(f"{'=' * 60}")
    print(f"Total screens: {len(chapter)}")
    print(f"PAST screens (from list): {len(past_screens)}")
    print(f"PRESENT screens: {len(chapter) - len(past_screens)}")
    print(f"Time doors: {sorted(time_doors)}")

    # Find cross-time violations
    print("\nCross-time violations (first 10):")
    violations = []
    intentional_exits = INTENTIONAL_CROSS_TIME_EXITS.get(ch_num, set())
    for screen in chapter:
        if screen.relative_index in time_doors:
            continue
        src_period = get_time_period_for_screen(ch_num, screen.relative_index)
        for direction, attr in [("up", "screen_index_up"), ("down", "screen_index_down"),
                                ("left", "screen_index_left"), ("right", "screen_index_right")]:
            nav = getattr(screen, attr)
            if nav >= len(chapter) or nav == 0xFF or nav == 0xFE:
                continue
            tgt_period = get_time_period_for_screen(ch_num, nav)
            if src_period != tgt_period:
                # Skip known intentional cross-time exits
                if (screen.relative_index, nav, direction) in intentional_exits:
                    continue
                violations.append((screen.relative_index, nav, direction, src_period, tgt_period))

    if not violations:
        print("  None found!")
    else:
        for i, (src, tgt, direction, src_p, tgt_p) in enumerate(violations[:10]):
            print(f"  {src} -> {tgt} (nav_{direction}): {src_p.name} -> {tgt_p.name}")
        if len(violations) > 10:
            print(f"  ... and {len(violations) - 10} more")

    print(f"\nTotal violations: {len(violations)}")


def main():
    parser = argparse.ArgumentParser(description="Diagnose screen data for validation")
    parser.add_argument("--rom", type=Path, default=Path("../../rom-files/TMOS_ORIGINAL.nes"),
                        help="Path to ROM file")
    parser.add_argument("--chapter", type=int, required=True, choices=[1, 2, 3, 4, 5],
                        help="Chapter number")
    parser.add_argument("--screen", type=int, help="Screen index to inspect")
    parser.add_argument("--neighbors", action="store_true",
                        help="Show navigation targets and their time periods")
    parser.add_argument("--all-time-doors", action="store_true",
                        help="Show all time doors in chapter")
    parser.add_argument("--validate-sample", action="store_true",
                        help="Run validation and show detailed results")

    args = parser.parse_args()

    if not args.rom.exists():
        print(f"ROM not found: {args.rom}")
        return 1

    game_world = load_rom(args.rom)
    chapter = game_world.chapters[args.chapter]

    if args.screen is not None:
        dump_screen(chapter, args.screen, args.neighbors)
    elif args.all_time_doors:
        show_time_doors(chapter)
    elif args.validate_sample:
        validate_sample(chapter)
    else:
        parser.print_help()

    return 0


if __name__ == "__main__":
    sys.exit(main())
