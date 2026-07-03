"""Pydantic request models for the TMOS Randomizer API.

Pure data shapes — no app state, no endpoint logic. Extracted from
server.py during the router split; import from here (server.py re-exports
for backward compatibility).
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from pydantic import BaseModel


class PlanRequest(BaseModel):
    """Request to create a randomization plan."""
    seed: Optional[int] = None
    config: Optional[Dict[str, Any]] = None


class ApplyRequest(BaseModel):
    """Request to apply randomization."""
    input_rom_path: str
    output_rom_path: str
    generate_spoiler: bool = True


class ConfigUpdate(BaseModel):
    """Partial config update."""
    topology: Optional[str] = None
    dungeon_last: Optional[bool] = None
    chapters: Optional[List[int]] = None
    difficulty_preset: Optional[str] = None


class NavigationUpdate(BaseModel):
    """Request to update screen navigation."""
    nav_right: Optional[int] = None  # Screen index or None to disconnect
    nav_left: Optional[int] = None
    nav_up: Optional[int] = None
    nav_down: Optional[int] = None
    bidirectional: bool = True  # If True, update neighbor's opposite direction too
    parent_world: Optional[int] = None  # Update parent_world if provided (0-255)


class TileSectionUpdate(BaseModel):
    """Update a screen's tile sections. Values are GLOBAL section indices 0-470."""
    top_tiles: Optional[int] = None
    bottom_tiles: Optional[int] = None


class ScreenFieldsUpdate(BaseModel):
    """Allowlisted editable WorldScreen fields for the editor modal.

    Covers every WorldScreen byte EXCEPT the 4 navigation pointers
    (screen_index_right/left/down/up), which are edited via map drag.
    """
    objectset: Optional[int] = None
    content: Optional[int] = None
    event: Optional[int] = None
    worldscreen_color: Optional[int] = None
    sprites_color: Optional[int] = None
    parent_world: Optional[int] = None
    ambient_sound: Optional[int] = None
    datapointer: Optional[int] = None
    exit_position: Optional[int] = None
    unknown: Optional[int] = None


class TileBankUpdate(BaseModel):
    """Request to update a tile's MiniTile IDs."""
    minitiles: List[int]  # [TL, TR, BL, BR], each 0-255


class InventoryCapUpdate(BaseModel):
    """Update one inventory cap slot at file 0xD544.

    The user-meaningful field is `max_cap` (byte 2 of the slot record).
    `ram_addr` retargets the slot to a different $03xx RAM variable
    (DANGEROUS — only valid if the new addr's high byte is 0x03).
    """
    max_cap: Optional[int] = None
    ram_addr: Optional[int] = None


class ExpEntryUpdate(BaseModel):
    """Update to one EXP table entry."""
    value: int


class IntValueUpdate(BaseModel):
    """Generic single-int update used by player-stats PATCH endpoints."""
    value: int


class PlayerStatsPresetRequest(BaseModel):
    name: str


class PlayerStatsTransformRequest(BaseModel):
    target: str           # 'hp' | 'sword_index' | 'rod_index' | 'damage_value'
    op: str               # 'scale' | 'offset' | 'set' | 'reset'
    params: Dict[str, Any] = {}
    range_start: Optional[int] = None
    range_end: Optional[int] = None


class LineupSlotUpdate(BaseModel):
    """Set one slot of a lineup to an enemy ID (0x00/0xFF for empty)."""
    enemy_id: int


class LineupStartByteUpdate(BaseModel):
    """Set the start_byte flag of a lineup (0x00 or 0x01)."""
    value: int


class EncounterGroupUpdate(BaseModel):
    """Partial update to an encounter group entry. Omitted fields untouched."""
    screen: Optional[int] = None
    monster_group: Optional[int] = None
    flag: Optional[int] = None


class EnemyStatUpdate(BaseModel):
    """Partial update to one enemy's stats (any of the 10 record bytes)."""
    ep: Optional[int] = None
    rupia: Optional[int] = None
    bribe: Optional[int] = None
    escape_trigger: Optional[int] = None
    action_prob: Optional[int] = None
    lineup_min: Optional[int] = None
    action_prob2: Optional[int] = None
    hp: Optional[int] = None
    atk: Optional[int] = None
    byte_9: Optional[int] = None


# --- Advanced page update models ---
class BossStatUpdate(BaseModel):
    """Set one boss byte field (field name + value). ROM_VERIFIED single bytes."""
    field: str
    value: int


class ShopSlotUpdate(BaseModel):
    """Partial update to one shop slot (item_code / base_price). Omitted untouched."""
    item_code: Optional[int] = None
    base_price: Optional[int] = None


class TrooperCostUpdate(BaseModel):
    """Set the trooper recruitment cost byte at file 0x4577."""
    cost: int


class OverworldHpUpdate(BaseModel):
    """Set overworld enemy HP: all 5 chapters (hp_by_chapter) or one (chapter+hp)."""
    hp_by_chapter: Optional[List[int]] = None
    chapter: Optional[int] = None
    hp: Optional[int] = None


class TbTableEntryUpdate(BaseModel):
    """Set one byte of a turn-based damage table (Expert)."""
    value: int


class EncounterRateUpdate(BaseModel):
    """Set one byte of an encounter ramp/curve table (Expert). allow_marker for ramp."""
    value: int
    allow_marker: bool = False


class WeaponDamageUpdate(BaseModel):
    """Set weapon_class (0-3) and/or damage_base (0-63) for an attack object (Expert)."""
    weapon_class: Optional[int] = None
    damage_base: Optional[int] = None


class MpEntryUpdate(BaseModel):
    """Set the Max-MP byte for one level (1-25)."""
    value: int
