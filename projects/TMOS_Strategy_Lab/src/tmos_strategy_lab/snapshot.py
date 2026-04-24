"""Snapshot CLI: ROM → cached JSON and back.

Usage:
    python -m tmos_strategy_lab.snapshot save <rom-path> <json-path>
    python -m tmos_strategy_lab.snapshot load <json-path>    # prints summary
"""
from __future__ import annotations

import hashlib
import json
import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from ._v2_compat.parsers import GameWorld, ROMReader


def save_snapshot(rom_path: Path | str, json_path: Path | str) -> dict[str, Any]:
    rom_path = Path(rom_path)
    json_path = Path(json_path)
    reader = ROMReader(rom_path)
    game_world = reader.read_all_chapters()
    rom_bytes = reader.data
    payload = {
        "schema_version": 1,
        "rom_md5": hashlib.md5(rom_bytes).hexdigest(),
        "rom_size": len(rom_bytes),
        "created_utc": datetime.now(UTC).isoformat(),
        "meta": {"rom_path": str(rom_path), "total_screens": game_world.total_screens},
        "game_world": game_world.to_dict(),
    }
    json_path.parent.mkdir(parents=True, exist_ok=True)
    json_path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")
    return payload


def load_snapshot(json_path: Path | str) -> GameWorld:
    payload = json.loads(Path(json_path).read_text(encoding="utf-8"))
    world_data = payload.get("game_world") or payload
    return GameWorld.from_dict(world_data)


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if not argv or argv[0] in {"-h", "--help"}:
        print(__doc__, file=sys.stderr)
        return 1
    verb = argv[0]
    if verb == "save":
        if len(argv) != 3:
            print("save requires <rom-path> <json-path>", file=sys.stderr)
            return 2
        payload = save_snapshot(argv[1], argv[2])
        print(f"Snapshot written: {argv[2]}  md5={payload['rom_md5']}")
        return 0
    if verb == "load":
        if len(argv) != 2:
            print("load requires <json-path>", file=sys.stderr)
            return 2
        world = load_snapshot(argv[1])
        print(world.summary())
        return 0
    print(f"Unknown verb: {verb!r}; expected save | load", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
