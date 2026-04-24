"""LabContext — the immutable input to every strategy.

Wraps a parsed V2 ``GameWorld`` plus the raw ROM bytes. Strategies that need
ROM-level data (e.g. organic_port) consume ``rom_bytes``; pure-graph strategies
(e.g. identity) only touch ``game_world``.

LabContext is picklable under spawn — it holds a GameWorld dataclass tree and
a bytes blob, nothing that owns file handles.
"""
from __future__ import annotations

import hashlib
import json
import logging
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

_log = logging.getLogger(__name__)

EXPECTED_ROM_MD5 = "b3236db14c87f375e5f24a5b9b79f071"


@dataclass
class LabContext:
    game_world: Any  # tmos_randomizer.core.chapter.GameWorld
    rom_bytes: bytes | None
    source: str  # "rom:<path>" or "snapshot:<path>"
    rom_md5: str | None
    meta: dict[str, Any] = field(default_factory=dict)

    @classmethod
    def from_rom(cls, path: Path | str) -> LabContext:
        from ._v2_compat.parsers import ROMReader

        p = Path(path)
        reader = ROMReader(p)
        game_world = reader.read_all_chapters()
        rom_bytes = reader.data
        md5 = hashlib.md5(rom_bytes).hexdigest()
        if md5 != EXPECTED_ROM_MD5:
            _log.warning(
                "ROM MD5 mismatch: got %s, expected %s — continuing anyway "
                "(modded ROMs are allowed but metric baselines may differ).",
                md5,
                EXPECTED_ROM_MD5,
            )
        return cls(
            game_world=game_world,
            rom_bytes=rom_bytes,
            source=f"rom:{p.name}",
            rom_md5=md5,
            meta={"rom_path": str(p)},
        )

    @classmethod
    def from_snapshot(cls, path: Path | str) -> LabContext:
        from ._v2_compat.parsers import GameWorld

        p = Path(path)
        payload = json.loads(p.read_text(encoding="utf-8"))
        world_data = payload.get("game_world") or payload
        game_world = GameWorld.from_dict(world_data)
        md5 = payload.get("rom_md5")
        return cls(
            game_world=game_world,
            rom_bytes=None,
            source=f"snapshot:{p.name}",
            rom_md5=md5,
            meta={"snapshot_path": str(p), **payload.get("meta", {})},
        )

    def chapter(self, n: int) -> Any:
        return self.game_world.chapters[n]

    def summary(self) -> dict[str, Any]:
        return {
            "source": self.source,
            "rom_md5": self.rom_md5,
            "has_rom_bytes": self.rom_bytes is not None,
            "total_screens": self.game_world.total_screens,
            "chapters_loaded": sorted(self.game_world.chapters.keys()),
        }


__all__ = ["LabContext", "EXPECTED_ROM_MD5"]
