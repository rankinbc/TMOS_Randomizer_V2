"""randomization_lab — batch experiment runner.

Pipeline (see CLAUDE.md for gotchas):
  1. Parse ROM -> pristine World (once)
  2. Validate pristine (once, cached)
  3. For each selected strategy:
       a. deepcopy(pristine) -> world_copy
       b. strategy(world_copy, seed)  (seed *inside* strategy — never at import)
       c. render_world_overview(...) -> screenshot.png ; close + gc
       d. world_to_json -> world.json
       e. validate_world -> validation_report.json
       f. diff_validation vs pristine -> diff_vs_pristine.json
  4. summary.md + run_manifest.json
"""
from __future__ import annotations

import argparse
import copy
import gc
import hashlib
import json
import sys
from dataclasses import asdict
from pathlib import Path
from typing import Any

_COMPONENT_DIR = Path(__file__).resolve().parent
_PROJECT_ROOT = _COMPONENT_DIR.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

DEFAULT_ROM = _PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="randomization_lab batch runner")
    p.add_argument("--dry-run", action="store_true", help="Load registry only; skip ROM.")
    p.add_argument("--rom", type=Path, default=DEFAULT_ROM, help="Path to ROM file.")
    p.add_argument("--desc", default="run", help="Run description for output folder name.")
    p.add_argument(
        "--strategies",
        default="",
        help="Comma-separated strategy names (empty = all registered).",
    )
    return p.parse_args(argv)


def _rom_md5(path: Path) -> str:
    return hashlib.md5(path.read_bytes()).hexdigest()


def _issues_to_json(issues):
    return [asdict(iss) for iss in issues]


def _failures_by_chapter(issues) -> dict[int, int]:
    out: dict[int, int] = {}
    for iss in issues:
        if iss.severity != "ERROR":
            continue
        out[iss.chapter_num] = out.get(iss.chapter_num, 0) + 1
    return out


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)

    # Import registry — strategies self-register as their modules import.
    from components.randomization_lab.strategies import REGISTRY

    selected_names = [n.strip() for n in args.strategies.split(",") if n.strip()] or list(REGISTRY)
    unknown = [n for n in selected_names if n not in REGISTRY]
    if unknown:
        print(f"Unknown strategies: {unknown}. Registered: {list(REGISTRY)}", file=sys.stderr)
        return 2

    if args.dry_run:
        print("randomization_lab --dry-run")
        print(f"  Registered strategies: {list(REGISTRY.keys())}")
        print(f"  Selected:              {selected_names}")
        return 0

    if not args.rom.exists():
        print(f"ROM not found at {args.rom}", file=sys.stderr)
        return 2

    from components.randomization_lab.diff import diff_validation
    from components.randomization_lab.run_writer import RunWriter
    from components.randomization_lab.summary import build_summary_markdown
    from src.tmos_world.rendering import render_world_overview
    from src.tmos_world.rom import parse_rom
    from src.tmos_world.serialization import world_to_json
    from src.tmos_world.validation import validate_world

    rom_md5 = _rom_md5(args.rom)
    pristine = parse_rom(str(args.rom))
    pristine_issues = validate_world(pristine)

    writer = RunWriter(args.desc)
    writer.run_dir.mkdir(parents=True, exist_ok=True)

    strategy_results: list[dict[str, Any]] = []
    manifest_strategies: list[dict[str, Any]] = []

    for name in selected_names:
        fn = REGISTRY[name]
        seed = getattr(getattr(fn, "meta", None), "default_seed", 0)
        world_copy = copy.deepcopy(pristine)
        world_out = fn(world_copy, seed) if _accepts_seed(fn) else fn(world_copy)
        if world_out is None:
            world_out = world_copy  # strategies that mutate in place

        s_dir = writer.strategy_dir(name)

        img = render_world_overview(world_out)
        try:
            img.save(s_dir / "screenshot.png")
        finally:
            img.close()
            gc.collect()

        (s_dir / "world.json").write_text(
            json.dumps(world_to_json(world_out), indent=2), encoding="utf-8"
        )

        post_issues = validate_world(world_out)
        (s_dir / "validation_report.json").write_text(
            json.dumps({"issues": _issues_to_json(post_issues)}, indent=2),
            encoding="utf-8",
        )

        diff = diff_validation(pristine_issues, post_issues)
        (s_dir / "diff_vs_pristine.json").write_text(
            json.dumps(diff, indent=2), encoding="utf-8"
        )

        strategy_results.append(
            {
                "name": name,
                "seed": seed,
                "total_failures": sum(
                    1 for i in post_issues if i.severity == "ERROR"
                ),
                "new_vs_pristine": diff["summary"]["new_count"],
                "failures_by_chapter": _failures_by_chapter(post_issues),
            }
        )
        manifest_strategies.append(
            {"name": name, "seed": seed, "version": getattr(getattr(fn, "meta", None), "version", "")}
        )

    (writer.run_dir / "run_manifest.json").write_text(
        json.dumps(
            {
                "desc": args.desc,
                "rom_path": str(args.rom),
                "rom_md5": rom_md5,
                "strategies": manifest_strategies,
                "pristine_total_issues": len(pristine_issues),
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    (writer.run_dir / "summary.md").write_text(
        build_summary_markdown(args.desc, rom_md5, strategy_results),
        encoding="utf-8",
    )

    try:
        rel = writer.run_dir.relative_to(_PROJECT_ROOT)
    except ValueError:
        rel = writer.run_dir
    print(f"Run complete. Output: {rel}")
    return 0


def _accepts_seed(fn) -> bool:
    """True if fn takes a seed kwarg or positional after the world arg."""
    import inspect

    try:
        sig = inspect.signature(fn)
    except (TypeError, ValueError):
        return False
    return len(sig.parameters) >= 2


if __name__ == "__main__":
    sys.exit(main())
