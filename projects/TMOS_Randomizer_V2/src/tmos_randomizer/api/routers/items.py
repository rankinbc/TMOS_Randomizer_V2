"""Inventory caps, item registry, and static field metadata endpoints."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException

from .. import state
from ..deps import _require_rom_pair, _serialize_gameplay_item, _serialize_battle_item
from ..schemas import InventoryCapUpdate
from ...core import inventory_caps as _inv_caps
from ...core import items as _items
from ...core.field_metadata import build_field_metadata

router = APIRouter()


@router.get("/api/rom/inventory-caps")
async def get_inventory_caps():
    """Return the 8 inventory cap entries at file 0xD544.

    Each entry targets a $03xx RAM variable and has an editable max-cap byte.
    This was previously misinterpreted as a "shop slot table" — see
    TMOS_AI/docs/human/items-economy-re-answers.md for the full correction.
    """
    rom, vanilla = _require_rom_pair()
    return {
        "slot_count": 8,
        "slots": _inv_caps.read_caps(rom),
        "vanilla": _inv_caps.read_caps(vanilla),
        "_note": (
            "Inventory cap table at Bank 3 $9534 / file 0xD544. "
            "Used by chest/drop pickup handler at Bank 3 $94B0. "
            "Editing byte 2 (max_cap) raises/lowers stack limits for the "
            "targeted $03xx RAM variable."
        ),
    }


@router.patch("/api/rom/inventory-caps/{slot_index}")
async def update_inventory_cap(slot_index: int, update: InventoryCapUpdate):
    """Patch one inventory cap slot. Most edits target max_cap (byte 2)."""
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        if update.max_cap is not None:
            result = _inv_caps.write_cap(rom_array, slot_index, update.max_cap)
        elif update.ram_addr is not None:
            result = _inv_caps.write_ram_addr(rom_array, slot_index, update.ram_addr)
        else:
            raise HTTPException(status_code=400, detail="No fields to update")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "slot": result}


@router.get("/api/rom/items")
async def get_items():
    """Return item metadata in two namespaces.

    TMOS uses two different item-ID spaces: the menu/HUD gameplay space
    (what players see) and the Bank 6 $98E8 battle/equipment table. IDs
    in one namespace do NOT match IDs in the other. See core/items.py for
    the rationale.
    """
    return {
        "gameplay_items": [
            _serialize_gameplay_item(item)
            for item in sorted(_items.GAMEPLAY_ITEMS.values(), key=lambda i: i.id)
        ],
        "battle_items": [
            _serialize_battle_item(item)
            for item in sorted(_items.BATTLE_ITEMS.values(), key=lambda i: i.id)
        ],
        "_note": (
            "Two independent ID namespaces. gameplay_items = menu/HUD IDs (0-29). "
            "battle_items = Bank 6 $98E8 table (0-29). IDs do NOT cross-reference."
        ),
    }


@router.get("/api/metadata/fields")
async def get_field_metadata():
    """Static field metadata: safety tiers, descriptions, enums, warnings.

    Drives the guided-editing UI and the 3-tier safety model. No ROM required.
    """
    return build_field_metadata()
