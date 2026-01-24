#!/usr/bin/env python3
"""TMOS Randomizer V2 - Command Line Interface.

Usage:
    python -m main randomize <input_rom> [options]
    python -m main preview [options]
    python -m main info <rom_file>

Examples:
    # Basic randomization with random seed
    python -m main randomize "TMOS.nes"

    # Specific seed
    python -m main randomize "TMOS.nes" --seed 12345

    # Custom output path
    python -m main randomize "TMOS.nes" -o "TMOS_Randomized.nes"

    # Use config file
    python -m main randomize "TMOS.nes" --config hard.yaml

    # Preview without modifying ROM
    python -m main preview --seed 12345

    # Show ROM info
    python -m main info "TMOS.nes"
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Optional

# Add src to path for direct execution
if __name__ == "__main__":
    src_path = Path(__file__).parent
    if str(src_path) not in sys.path:
        sys.path.insert(0, str(src_path))

from tmos_randomizer import __version__
from tmos_randomizer.io import get_default_config, load_config, ROMReader
from tmos_randomizer.randomizer import Randomizer, preview_randomization, randomize


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        prog="tmos-randomizer",
        description="The Magic of Scheherazade - Map Randomizer V2",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--version", "-V",
        action="version",
        version=f"%(prog)s {__version__}",
    )

    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Randomize command
    randomize_parser = subparsers.add_parser(
        "randomize",
        help="Randomize a ROM file",
        description="Apply randomization to a TMOS ROM file.",
    )
    randomize_parser.add_argument(
        "input_rom",
        type=Path,
        help="Path to input ROM file",
    )
    randomize_parser.add_argument(
        "-o", "--output",
        type=Path,
        default=None,
        help="Output ROM path (default: <input>_randomized.nes)",
    )
    randomize_parser.add_argument(
        "-s", "--seed",
        type=int,
        default=None,
        help="Random seed (generates one if not specified)",
    )
    randomize_parser.add_argument(
        "-c", "--config",
        type=Path,
        default=None,
        help="Path to YAML config file",
    )
    randomize_parser.add_argument(
        "--no-spoiler",
        action="store_true",
        help="Don't generate spoiler log",
    )
    randomize_parser.add_argument(
        "-q", "--quiet",
        action="store_true",
        help="Minimal output",
    )
    randomize_parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output",
    )

    # Preview command
    preview_parser = subparsers.add_parser(
        "preview",
        help="Preview randomization without modifying ROM",
        description="Generate and display a randomization plan without creating a ROM.",
    )
    preview_parser.add_argument(
        "-s", "--seed",
        type=int,
        default=None,
        help="Random seed",
    )
    preview_parser.add_argument(
        "-c", "--config",
        type=Path,
        default=None,
        help="Path to YAML config file",
    )
    preview_parser.add_argument(
        "--json",
        action="store_true",
        help="Output plan as JSON",
    )

    # Info command
    info_parser = subparsers.add_parser(
        "info",
        help="Display ROM information",
        description="Show information about a ROM file.",
    )
    info_parser.add_argument(
        "rom_file",
        type=Path,
        help="Path to ROM file",
    )
    info_parser.add_argument(
        "--json",
        action="store_true",
        help="Output as JSON",
    )

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        return 0

    try:
        if args.command == "randomize":
            return cmd_randomize(args)
        elif args.command == "preview":
            return cmd_preview(args)
        elif args.command == "info":
            return cmd_info(args)
    except KeyboardInterrupt:
        print("\nInterrupted.")
        return 130
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

    return 0


def cmd_randomize(args) -> int:
    """Handle randomize command."""
    input_rom = args.input_rom

    if not input_rom.exists():
        print(f"Error: ROM file not found: {input_rom}", file=sys.stderr)
        return 1

    # Determine output path
    if args.output:
        output_rom = args.output
    else:
        output_rom = input_rom.parent / f"{input_rom.stem}_randomized{input_rom.suffix}"

    # Load config
    if args.config:
        if not args.config.exists():
            print(f"Error: Config file not found: {args.config}", file=sys.stderr)
            return 1
        config = load_config(args.config)
    else:
        config = get_default_config()

    if not args.quiet:
        print(f"TMOS Randomizer V{__version__}")
        print(f"Input:  {input_rom}")
        print(f"Output: {output_rom}")
        if args.seed:
            print(f"Seed:   {args.seed}")
        print()

    # Create randomizer
    randomizer = Randomizer(config)

    # Create plan
    if not args.quiet:
        print("Creating randomization plan...")
    plan = randomizer.create_plan(args.seed)

    if args.verbose:
        print(f"  Seed: {plan.seed}")
        for chapter in plan.world_plan.chapters:
            print(f"  Chapter {chapter.chapter_num}: {len(chapter.sections)} sections, {chapter.planned_screens} screens")

    if not plan.is_valid:
        print("Error: Invalid randomization plan:", file=sys.stderr)
        for error in plan.validation_errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    # Apply randomization
    if not args.quiet:
        print("Applying randomization...")
    result = randomizer.apply(
        input_rom,
        output_rom,
        plan,
        generate_spoiler=not args.no_spoiler,
    )

    if not result.success:
        print("Error: Randomization failed:", file=sys.stderr)
        for error in result.errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    if not args.quiet:
        print()
        print("Randomization complete!")
        print(f"  Seed: {result.seed}")
        print(f"  Output: {result.output_rom_path}")
        if result.spoiler_text_path:
            print(f"  Spoiler (text): {result.spoiler_text_path}")
        if result.spoiler_json_path:
            print(f"  Spoiler (JSON): {result.spoiler_json_path}")
        print(f"  SHA256: {result.rom_sha256[:16]}...")

    return 0


def cmd_preview(args) -> int:
    """Handle preview command."""
    # Load config
    if args.config:
        if not args.config.exists():
            print(f"Error: Config file not found: {args.config}", file=sys.stderr)
            return 1
        config = load_config(args.config)
    else:
        config = get_default_config()

    # Create plan
    plan = preview_randomization(config, args.seed)

    if args.json:
        print(json.dumps(plan.to_dict(), indent=2))
    else:
        print(f"TMOS Randomizer V{__version__} - Preview")
        print(f"Seed: {plan.seed}")
        print()

        for chapter in plan.world_plan.chapters:
            print(f"Chapter {chapter.chapter_num}:")
            print(f"  Total screens: {chapter.total_screens}")
            print(f"  Reserved: {chapter.reserved_screens}")
            print(f"  Planned: {chapter.planned_screens}")
            print(f"  Sections:")
            for section in chapter.sections:
                preserved = " (preserved)" if section.preserve_original else ""
                print(f"    - {section.section_type.name}: {section.target_screen_count} screens ({section.shape}){preserved}")

            # Show connections
            chapter_conn = plan.world_connections.get_chapter(chapter.chapter_num)
            if chapter_conn:
                print(f"  Section order: {chapter_conn.section_order}")
                print(f"  Connections: {len(chapter_conn.connections)}")

            print()

        if plan.validation_errors:
            print("Validation Errors:")
            for error in plan.validation_errors:
                print(f"  - {error}")
        elif plan.validation_warnings:
            print("Validation Warnings:")
            for warning in plan.validation_warnings:
                print(f"  - {warning}")
        else:
            print("Validation: OK")

    return 0


def cmd_info(args) -> int:
    """Handle info command."""
    rom_file = args.rom_file

    if not rom_file.exists():
        print(f"Error: ROM file not found: {rom_file}", file=sys.stderr)
        return 1

    try:
        reader = ROMReader(rom_file)
        info = reader.get_rom_info()
        rom_hash = reader.get_rom_hash()
    except Exception as e:
        print(f"Error reading ROM: {e}", file=sys.stderr)
        return 1

    if args.json:
        data = {
            "file": str(rom_file),
            "size": info["size"],
            "has_ines_header": info["has_ines_header"],
            "sha256": rom_hash,
        }
        print(json.dumps(data, indent=2))
    else:
        print(f"ROM File: {rom_file}")
        print(f"Size: {info['size']} bytes")
        print(f"iNES Header: {'Yes' if info['has_ines_header'] else 'No'}")
        print(f"SHA256: {rom_hash}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
