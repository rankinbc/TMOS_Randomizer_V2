"""Player progression endpoints: EXP table, player stats, MP table, level caps."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException

from .. import state
from ..deps import _require_rom_pair
from ..schemas import (
    ExpEntryUpdate,
    IntValueUpdate,
    MpEntryUpdate,
    PlayerStatsPresetRequest,
    PlayerStatsTransformRequest,
)
from ...core import exp_table as _exp_table
from ...core import player_stats as _player_stats
from ...core import mp_table as _mp_table
from ...core import level_caps as _level_caps

router = APIRouter()


# =============================================================================
# API Endpoints - EXP Tier Table (editable)
# =============================================================================

@router.get("/api/rom/exp-table")
async def get_exp_table():
    rom, vanilla = _require_rom_pair()
    return {
        "entry_count": _exp_table.EXP_TABLE_COUNT,
        "rom_offset": f"0x{_exp_table.EXP_TABLE_OFFSET:05X}",
        "stride": _exp_table.EXP_TABLE_STRIDE,
        "entries": _exp_table.read_exp_table(rom),
        "vanilla": _exp_table.read_exp_table(vanilla),
        "labels": _exp_table.EXP_TIER_LABELS,
    }


@router.get("/api/rom/exp-table/usage")
async def get_exp_usage():
    """Static map of tier_index -> list of (chapter, screen_hex) using it."""
    return {"usage": _exp_table.EXP_USAGE}


@router.patch("/api/rom/exp-table/{index}")
async def update_exp_entry(index: int, update: ExpEntryUpdate):
    rom, vanilla = _require_rom_pair()

    rom_array = bytearray(rom)
    try:
        new_entry = _exp_table.write_exp_entry(rom_array, index, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)

    return {
        "status": "updated",
        "entry": new_entry,
        "vanilla": _exp_table.read_exp_entry(vanilla, index),
    }


# =============================================================================
# API Endpoints - Player Stats (editable)
# =============================================================================

@router.get("/api/rom/player-stats")
async def get_player_stats():
    """Full player-stats dump: HP curve, sword/rod indices, damage value lookup,
    plus the vanilla snapshot for diff display."""
    rom, vanilla = _require_rom_pair()
    return {
        "current": _player_stats.read_player_stats(rom),
        "vanilla": _player_stats.read_player_stats(vanilla),
        "level_count": _player_stats.LEVEL_COUNT,
        "damage_value_count": _player_stats.DMG_VALUE_COUNT,
        "nibble_max": _player_stats.NIBBLE_MAX,
    }


@router.get("/api/rom/player-stats/preview/{level}")
async def get_player_stats_preview(level: int):
    """Resolved damage values + enemy hit-counts for the given level (1..25).

    Hit counts use estimated overworld enemy HP (no ROM-verified source exists yet).
    Boss damage uses a different code path and is not represented here.
    """
    rom, vanilla = _require_rom_pair()
    try:
        return _player_stats.compute_preview(rom, vanilla, level)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/api/rom/player-stats/presets")
async def get_player_stats_presets():
    return {"presets": _player_stats.list_presets()}


@router.get("/api/rom/player-stats/damage-index/{index}/usage")
async def get_damage_index_usage(index: int):
    """Returns the levels (split by weapon) that currently resolve to this damage index."""
    rom, _ = _require_rom_pair()
    if not 0 <= index <= _player_stats.NIBBLE_MAX:
        raise HTTPException(status_code=400, detail=f"index must be 0..{_player_stats.NIBBLE_MAX}")
    return {"index": index, "usage": _player_stats.levels_using_damage_index(rom, index)}


@router.patch("/api/rom/player-stats/hp/{level}")
async def patch_player_hp(level: int, update: IntValueUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        new_value = _player_stats.write_hp(rom_array, level, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "field": "hp", "level": level, "value": new_value}


@router.patch("/api/rom/player-stats/sword-index/{level}")
async def patch_sword_index(level: int, update: IntValueUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        new_value = _player_stats.write_sword_index(rom_array, level, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "field": "sword_index", "level": level, "value": new_value}


@router.patch("/api/rom/player-stats/rod-index/{level}")
async def patch_rod_index(level: int, update: IntValueUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        new_value = _player_stats.write_rod_index(rom_array, level, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "field": "rod_index", "level": level, "value": new_value}


@router.patch("/api/rom/player-stats/damage-value/{index}")
async def patch_damage_value(index: int, update: IntValueUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        new_value = _player_stats.write_damage_value(rom_array, index, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {
        "status": "updated",
        "field": "damage_value",
        "index": index,
        "value": new_value,
        "cascade": _player_stats.levels_using_damage_index(state._rom_data, index),
    }


@router.post("/api/rom/player-stats/preset")
async def apply_player_stats_preset(req: PlayerStatsPresetRequest):
    rom, vanilla = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        _player_stats.apply_preset(rom_array, vanilla, req.name)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "applied", "preset": req.name, "current": _player_stats.read_player_stats(state._rom_data)}


@router.post("/api/rom/player-stats/transform")
async def apply_player_stats_transform(req: PlayerStatsTransformRequest):
    rom, vanilla = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        _player_stats.apply_transform(
            rom_array, vanilla,
            target=req.target, op=req.op, params=req.params,
            range_start=req.range_start, range_end=req.range_end,
        )
    except (ValueError, KeyError) as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "applied", "current": _player_stats.read_player_stats(state._rom_data)}


# --- Max-MP-per-level table (safe) ---
@router.get("/api/rom/mp-table")
async def get_mp_table():
    rom, vanilla = _require_rom_pair()
    return {
        "level_count": _mp_table.LEVEL_COUNT,
        "rom_offset": f"0x{_mp_table.MP_TABLE_OFFSET:05X}",
        "stride": _mp_table.MP_TABLE_STRIDE,
        "entries": _mp_table.read_mp_table(rom),
        "vanilla": _mp_table.read_mp_table(vanilla),
    }


@router.patch("/api/rom/mp-table/{level}")
async def patch_mp_entry(level: int, update: MpEntryUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _mp_table.write_mp_entry(rom_array, level, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "entry": result}


@router.get("/api/rom/level-caps")
async def get_level_caps():
    rom, vanilla = _require_rom_pair()
    return {
        "caps": _level_caps.read_all_level_caps(rom),
        "vanilla": _level_caps.read_all_level_caps(vanilla),
        "chapter_range": [_level_caps.CHAPTER_FIRST, _level_caps.CHAPTER_LAST],
        "tier": _level_caps.TIER,
        "editable": False,
        "_note": (
            "Per-chapter level cap is GUIDE_SOURCED with no confirmed ROM write "
            "target (6:$97EC is the EXP threshold table) — display-only."
        ),
    }
