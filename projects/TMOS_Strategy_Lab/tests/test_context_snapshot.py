"""Snapshot round-trip: ROM-loaded GameWorld == snapshot-loaded GameWorld."""
from __future__ import annotations

from pathlib import Path

import pytest

from tmos_strategy_lab.context import LabContext
from tmos_strategy_lab.snapshot import load_snapshot, save_snapshot

PROJECT_ROOT = Path(__file__).resolve().parents[1]
ROM = PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"


pytestmark = pytest.mark.skipif(
    not ROM.exists(),
    reason="Stock ROM not staged.",
)


def test_snapshot_roundtrip_preserves_screens(tmp_path):
    json_path = tmp_path / "snapshot.json"
    save_snapshot(ROM, json_path)
    world = load_snapshot(json_path)
    ctx_rom = LabContext.from_rom(ROM)
    assert world.total_screens == ctx_rom.game_world.total_screens
    for ch in (1, 2, 3, 4, 5):
        rom_chapter = ctx_rom.game_world.chapters[ch]
        snap_chapter = world.chapters[ch]
        assert len(rom_chapter.screens) == len(snap_chapter.screens)
        for r_scr, s_scr in zip(rom_chapter.screens, snap_chapter.screens, strict=True):
            assert r_scr.to_bytes() == s_scr.to_bytes()


def test_context_from_snapshot_has_no_rom_bytes(tmp_path):
    json_path = tmp_path / "snapshot.json"
    save_snapshot(ROM, json_path)
    ctx = LabContext.from_snapshot(json_path)
    assert ctx.rom_bytes is None
    assert ctx.source.startswith("snapshot:")


def test_context_from_rom_computes_md5(tmp_path):
    ctx = LabContext.from_rom(ROM)
    # Stock ROM's known MD5.
    assert ctx.rom_md5 == "b3236db14c87f375e5f24a5b9b79f071"
    assert ctx.rom_bytes is not None
    assert ctx.source == "rom:TMOS_ORIGINAL.nes"
