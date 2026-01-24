"""CLI entry point for TMOS Randomizer.

Usage:
    tmos-randomize preview [--seed SEED] [--config CONFIG]
    tmos-randomize randomize INPUT OUTPUT [--seed SEED] [--config CONFIG]
    tmos-randomize serve [--host HOST] [--port PORT]
    tmos-randomize --help
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Optional


def cmd_preview(args: argparse.Namespace) -> int:
    """Preview randomization without modifying ROM."""
    from .randomizer import preview_randomization
    from .io.config_loader import load_config

    config = load_config(args.config) if args.config else None

    print(f"Creating randomization preview...")
    plan = preview_randomization(config=config, seed=args.seed)

    print(f"\n{'='*60}")
    print(f"Randomization Preview (Seed: {plan.seed})")
    print(f"{'='*60}")

    if plan.validation_errors:
        print(f"\nErrors:")
        for error in plan.validation_errors:
            print(f"  - {error}")

    if plan.validation_warnings:
        print(f"\nWarnings:")
        for warning in plan.validation_warnings:
            print(f"  - {warning}")

    print(f"\nChapters:")
    for chapter_plan in plan.world_plan.chapters:
        print(f"\n  Chapter {chapter_plan.chapter_num}:")
        print(f"    Total screens: {chapter_plan.total_screens}")
        print(f"    Sections: {len(chapter_plan.sections)}")
        for section in chapter_plan.sections:
            preserved = " (preserved)" if section.preserve_original else ""
            print(f"      - {section.section_type.name}: {section.target_screen_count} screens, {section.shape}{preserved}")

    print(f"\nConnectivity:")
    for chapter_conn in plan.world_connections.chapters:
        print(f"\n  Chapter {chapter_conn.chapter_num}:")
        print(f"    Section order: {chapter_conn.section_order}")
        print(f"    Connections: {len(chapter_conn.connections)}")

    print(f"\n{'='*60}")
    print(f"Plan is {'VALID' if plan.is_valid else 'INVALID'}")
    print(f"{'='*60}")

    if args.output_json:
        with open(args.output_json, "w") as f:
            json.dump(plan.to_dict(), f, indent=2)
        print(f"\nPlan saved to: {args.output_json}")

    return 0 if plan.is_valid else 1


def cmd_randomize(args: argparse.Namespace) -> int:
    """Randomize a ROM."""
    from .randomizer import randomize
    from .io.config_loader import load_config

    input_path = Path(args.input)
    output_path = Path(args.output)

    if not input_path.exists():
        print(f"Error: Input ROM not found: {input_path}", file=sys.stderr)
        return 1

    config = load_config(args.config) if args.config else None

    print(f"Randomizing {input_path.name}...")
    result = randomize(
        input_rom=input_path,
        output_rom=output_path,
        config=config,
        seed=args.seed,
    )

    if result.success:
        print(f"\nSuccess!")
        print(f"  Output ROM: {result.output_rom_path}")
        print(f"  Seed: {result.seed}")
        print(f"  SHA256: {result.rom_sha256[:16]}...")
        if result.spoiler_text_path:
            print(f"  Spoiler: {result.spoiler_text_path}")
        if result.stats:
            print(f"  Modified screens: {result.stats.get('screens_modified', 0)}")
        return 0
    else:
        print(f"\nFailed!", file=sys.stderr)
        for error in result.errors:
            print(f"  Error: {error}", file=sys.stderr)
        return 1


def cmd_serve(args: argparse.Namespace) -> int:
    """Start the API server."""
    try:
        import uvicorn
    except ImportError:
        print("Error: uvicorn not installed. Run: pip install uvicorn fastapi", file=sys.stderr)
        return 1

    from .api.server import app, configure_asset_paths

    # Configure asset paths
    configure_asset_paths()

    print(f"Starting TMOS Randomizer API server...")
    print(f"  URL: http://{args.host}:{args.port}")
    print(f"  Docs: http://{args.host}:{args.port}/docs")
    print(f"\nPress Ctrl+C to stop")

    uvicorn.run(app, host=args.host, port=args.port)
    return 0


def main(argv: Optional[list[str]] = None) -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        prog="tmos-randomize",
        description="TMOS Map Randomizer - Randomize The Magic of Scheherazade",
    )
    parser.add_argument("--version", action="version", version="%(prog)s 2.0.0")

    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Preview command
    preview_parser = subparsers.add_parser(
        "preview",
        help="Preview randomization without modifying ROM",
    )
    preview_parser.add_argument(
        "--seed", "-s",
        type=int,
        default=None,
        help="Random seed (generates one if not specified)",
    )
    preview_parser.add_argument(
        "--config", "-c",
        type=str,
        default=None,
        help="Path to config YAML file",
    )
    preview_parser.add_argument(
        "--output-json", "-o",
        type=str,
        default=None,
        help="Output plan as JSON file",
    )

    # Randomize command
    randomize_parser = subparsers.add_parser(
        "randomize",
        help="Randomize a ROM file",
    )
    randomize_parser.add_argument(
        "input",
        help="Input ROM file path",
    )
    randomize_parser.add_argument(
        "output",
        help="Output ROM file path",
    )
    randomize_parser.add_argument(
        "--seed", "-s",
        type=int,
        default=None,
        help="Random seed (generates one if not specified)",
    )
    randomize_parser.add_argument(
        "--config", "-c",
        type=str,
        default=None,
        help="Path to config YAML file",
    )

    # Serve command
    serve_parser = subparsers.add_parser(
        "serve",
        help="Start the API server for UI",
    )
    serve_parser.add_argument(
        "--host",
        type=str,
        default="127.0.0.1",
        help="Host to bind to (default: 127.0.0.1)",
    )
    serve_parser.add_argument(
        "--port", "-p",
        type=int,
        default=8000,
        help="Port to bind to (default: 8000)",
    )

    args = parser.parse_args(argv)

    if args.command is None:
        parser.print_help()
        return 0

    if args.command == "preview":
        return cmd_preview(args)
    elif args.command == "randomize":
        return cmd_randomize(args)
    elif args.command == "serve":
        return cmd_serve(args)
    else:
        parser.print_help()
        return 1


if __name__ == "__main__":
    sys.exit(main())
