"""Enemy endpoints: battle roster, stats, bosses, overworld stats, damage
tables, encounter rates, weapon damage, lineups, and per-screen groups."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException

from .. import state
from ..deps import _require_rom_pair
from ..schemas import (
    BossStatUpdate,
    EncounterGroupUpdate,
    EncounterRateUpdate,
    EnemyStatUpdate,
    LineupSlotUpdate,
    LineupStartByteUpdate,
    OverworldHpUpdate,
    TbTableEntryUpdate,
    WeaponDamageUpdate,
)
from ...core import enemies as _enemies
from ...core import enemy_selection as _enemy_selection
from ...core import enemy_stats as _enemy_stats
from ...core import encounter_lineups as _encounter_lineups
from ...core import encounter_groups as _encounter_groups
from ...core import enemy_appearances as _enemy_appearances
from ...core import boss_stats as _boss_stats
from ...core import overworld_enemy_stats as _overworld_enemy_stats
from ...core import tb_damage_tables as _tb_damage_tables
from ...core import encounter_rates as _encounter_rates
from ...core import weapon_damage as _weapon_damage

router = APIRouter()


@router.get("/api/rom/enemies")
async def get_enemies():
    """Battle-enemy roster — static (name, image) + live ROM stats (HP/EP/Rupia).

    HP/EP/Rupia are read from $8341 in Bank 3 per the RE answer doc. These
    OVERRIDE the static `hp` field in core/enemies.py for the in-game range
    (IDs 0x0D-0x29). For IDs outside that range (e.g. MedusaGlitch 0x18 — wait,
    0x18 is in range — anything truly outside, the static value is preserved).
    """
    rom, vanilla = _require_rom_pair()
    static = {e["enemy_id"]: e for e in _enemies.list_battle_enemies()}
    enriched: list[dict] = []
    for s in _enemy_stats.read_all_enemy_stats(rom):
        eid = s["enemy_id"]
        meta = static.get(eid, {})
        enriched.append({
            **meta,
            "enemy_id": eid,
            "enemy_id_hex": s["enemy_id_hex"],
            "rom_offset": s["rom_offset"],
            "ep": s["ep"], "rupia": s["rupia"], "bribe": s["bribe"],
            "escape_trigger": s["escape_trigger"], "action_prob": s["action_prob"],
            "lineup_min": s["lineup_min"], "action_prob2": s["action_prob2"],
            "hp": s["hp"], "atk": s["atk"], "byte_9": s["byte_9"],
        })
    vanilla_stats = {v["enemy_id"]: v for v in _enemy_stats.read_all_enemy_stats(vanilla)}
    return {
        "enemies": enriched,
        "vanilla": vanilla_stats,
        "_note": "All 10 enemy record bytes are live ROM reads from $8341 (Bank 3).",
    }


@router.get("/api/rom/enemies/selectable")
async def get_selectable_enemies():
    """Canonical list of turn-based enemy IDs safe to offer in UI dropdowns.

    Returns every enemy from the static roster that is NOT in
    CONSERVATIVE_DANGER_ENEMY_IDS (excludes crash IDs 0x0B, 0x0C and
    dangerous/unknown variants 0x0F, 0x17, 0x25).  Does not require a loaded
    ROM — derived from the static enemy roster only.
    """
    return {"enemies": _enemy_selection.selectable_enemy_ids()}


@router.get("/api/rom/enemies/{enemy_id}/appearances")
async def get_enemy_appearances(enemy_id: int):
    """Return all world-screens where *enemy_id* can spawn in a random encounter.

    Chains three tables: encounter lineups (which enemies are in each lineup),
    encounter groups (which screen maps to which lineup), and the enemy roster.
    Result is deduplicated by (chapter, screen_index, lineup_index).
    """
    if not 0 <= enemy_id <= 0xFF:
        raise HTTPException(status_code=400, detail="enemy_id must be 0..255")
    rom, _ = _require_rom_pair()
    appearances = _enemy_appearances.get_enemy_appearances(rom, enemy_id)
    return {
        "enemy_id": enemy_id,
        "enemy_id_hex": f"0x{enemy_id:02X}",
        "appearances": appearances,
    }


@router.get("/api/rom/enemy-stats")
async def get_enemy_stats():
    rom, vanilla = _require_rom_pair()
    return {
        "stats": _enemy_stats.read_all_enemy_stats(rom),
        "vanilla": _enemy_stats.read_all_enemy_stats(vanilla),
        "id_range": [_enemy_stats.ENEMY_ID_FIRST, _enemy_stats.ENEMY_ID_LAST],
        "rom_offset": f"0x{_enemy_stats.ENEMY_STAT_TABLE:05X}",
    }


@router.patch("/api/rom/enemy-stats/{enemy_id}")
async def patch_enemy_stat(enemy_id: int, update: EnemyStatUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _enemy_stats.write_enemy_stat(
            rom_array, enemy_id, **update.model_dump(exclude_none=True)
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "stat": result}


# --- Bosses (ROM_VERIFIED, safe) ---
@router.get("/api/rom/boss-stats")
async def get_boss_stats():
    rom, vanilla = _require_rom_pair()
    return {
        "stats": _boss_stats.read_all_boss_stats(rom),
        "vanilla": _boss_stats.read_all_boss_stats(vanilla),
        "boss_ids": list(_boss_stats.BOSS_IDS),
    }


@router.patch("/api/rom/boss-stats/{boss_id}")
async def patch_boss_stat(boss_id: str, update: BossStatUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _boss_stats.write_boss_stat(rom_array, boss_id, update.field, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "stat": result}


# --- Overworld (real-time) enemy stats (HP editable, expert) ---
@router.get("/api/rom/overworld-enemy-stats")
async def get_overworld_enemy_stats():
    rom, vanilla = _require_rom_pair()
    return {
        "stats": _overworld_enemy_stats.read_all_overworld_enemy_stats(rom),
        "vanilla": _overworld_enemy_stats.read_all_overworld_enemy_stats(vanilla),
        "type_range": [_overworld_enemy_stats.TYPE_FIRST, _overworld_enemy_stats.TYPE_LAST],
        "chapter_count": _overworld_enemy_stats.CHAPTER_COUNT,
        "rom_offset": f"0x{_overworld_enemy_stats.OVERWORLD_HP_TABLE:05X}",
    }


@router.patch("/api/rom/overworld-enemy-stats/{enemy_type}")
async def patch_overworld_enemy_stat(enemy_type: int, update: OverworldHpUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        if update.hp_by_chapter is not None:
            result = _overworld_enemy_stats.write_overworld_enemy_stat(
                rom_array, enemy_type, hp_by_chapter=update.hp_by_chapter,
            )
        elif update.chapter is not None and update.hp is not None:
            result = _overworld_enemy_stats.write_overworld_enemy_hp(
                rom_array, enemy_type, chapter=update.chapter, hp=update.hp,
            )
        else:
            raise HTTPException(status_code=400, detail="Provide hp_by_chapter or chapter+hp")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "stat": result}


# --- Turn-based combat damage tables (Expert) ---
@router.get("/api/rom/tb-damage-tables")
async def get_tb_damage_tables():
    rom, vanilla = _require_rom_pair()
    return {
        "tables": _tb_damage_tables.read_all_tables(rom),
        "vanilla": _tb_damage_tables.read_all_tables(vanilla),
        "tier": _tb_damage_tables.TIER,
    }


@router.patch("/api/rom/tb-damage-tables/{which}/{index}")
async def patch_tb_damage_entry(which: str, index: int, update: TbTableEntryUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _tb_damage_tables.write_table_entry(rom_array, which, index, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "table": result}


# --- Encounter rate tables (ramp + curve, Expert) ---
@router.get("/api/rom/encounter-rates")
async def get_encounter_rates():
    rom, vanilla = _require_rom_pair()
    return {
        "current": _encounter_rates.read_encounter_rates(rom),
        "vanilla": _encounter_rates.read_encounter_rates(vanilla),
        "tier": _encounter_rates.TIER,
    }


@router.patch("/api/rom/encounter-rates/{table}/{index}")
async def patch_encounter_rate(table: str, index: int, update: EncounterRateUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        if table == "ramp":
            result = _encounter_rates.write_encounter_ramp_byte(
                rom_array, index, update.value, allow_marker=update.allow_marker,
            )
        elif table == "curve":
            result = _encounter_rates.write_encounter_curve_byte(rom_array, index, update.value)
        else:
            raise HTTPException(status_code=400, detail="table must be 'ramp' or 'curve'")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "table": result}


# --- Weapon vs attack-object damage table (Expert) ---
@router.get("/api/rom/weapon-damage")
async def get_weapon_damage():
    rom, vanilla = _require_rom_pair()
    return {
        "table": _weapon_damage.read_table(rom),
        "vanilla": _weapon_damage.read_table(vanilla),
        "id_range": [_weapon_damage.ATTACK_ID_FIRST, _weapon_damage.ATTACK_ID_LAST],
        "writable_range": [_weapon_damage.WRITABLE_ID_FIRST, _weapon_damage.WRITABLE_ID_LAST],
        "rom_offset": f"0x{_weapon_damage.WEAPON_DAMAGE_TABLE:05X}",
    }


@router.patch("/api/rom/weapon-damage/{attack_id}")
async def patch_weapon_damage(attack_id: int, update: WeaponDamageUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _weapon_damage.write_table_entry(
            rom_array, attack_id,
            weapon_class=update.weapon_class, damage_base=update.damage_base,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "entry": result}


@router.get("/api/rom/encounter-lineups")
async def get_all_encounter_lineups():
    rom, vanilla = _require_rom_pair()
    return {
        "current": _encounter_lineups.read_all_lineups(rom),
        "vanilla": _encounter_lineups.read_all_lineups(vanilla),
    }


@router.get("/api/rom/encounter-lineups/{chapter}")
async def get_chapter_encounter_lineups(chapter: int):
    rom, vanilla = _require_rom_pair()
    try:
        return {
            "current": _encounter_lineups.read_chapter_lineups(rom, chapter),
            "vanilla": _encounter_lineups.read_chapter_lineups(vanilla, chapter),
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.patch("/api/rom/encounter-lineups/{chapter}/{lineup_idx}/slots/{slot}")
async def patch_lineup_slot(chapter: int, lineup_idx: int, slot: int, update: LineupSlotUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _encounter_lineups.write_lineup_slot(
            rom_array, chapter, lineup_idx, slot, update.enemy_id
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "chapter": chapter, "lineup_index": lineup_idx, "result": result}


@router.patch("/api/rom/encounter-lineups/{chapter}/{lineup_idx}/start-byte")
async def patch_lineup_start_byte(chapter: int, lineup_idx: int, update: LineupStartByteUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _encounter_lineups.write_lineup_start_byte(rom_array, chapter, lineup_idx, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "start_byte": result}


@router.get("/api/rom/encounter-groups")
async def get_all_encounter_groups():
    rom, vanilla = _require_rom_pair()
    return {
        "current": _encounter_groups.read_all_groups(rom),
        "vanilla": _encounter_groups.read_all_groups(vanilla),
    }


@router.get("/api/rom/encounter-groups/{chapter}")
async def get_chapter_encounter_groups(chapter: int):
    rom, vanilla = _require_rom_pair()
    try:
        return {
            "current": _encounter_groups.read_chapter_groups(rom, chapter),
            "vanilla": _encounter_groups.read_chapter_groups(vanilla, chapter),
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/api/rom/encounter-groups/screen/{chapter}/{screen_index}")
async def get_encounter_groups_by_screen(chapter: int, screen_index: int):
    """Return all encounter group entries for a specific screen, with lineups resolved.

    Response shape::

        {
            "chapter": int,
            "screen_index": int,
            "groups": [
                {
                    "entry_index": int,
                    "monster_group": int,
                    "flag": int,
                    "lineup_index": int,   # monster_group & 0x7F
                    "lineup": {            # None if lineup_index exceeds table size
                        "lineup_index": int,
                        "start_byte": int,
                        "slots": [{"slot": int, "enemy_id": int, "enemy_name": str|None, "is_empty": bool}],
                        "total_hp": int
                    }
                }
            ]
        }

    Returns groups: [] when no encounter entry is mapped to this screen.
    """
    rom, _ = _require_rom_pair()
    try:
        return _encounter_groups.get_screen_encounter_groups(rom, chapter, screen_index)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.patch("/api/rom/encounter-groups/{chapter}/{entry_index}")
async def patch_encounter_group(chapter: int, entry_index: int, update: EncounterGroupUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _encounter_groups.write_group_entry(
            rom_array, chapter, entry_index,
            screen=update.screen, monster_group=update.monster_group, flag=update.flag,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "result": result}
