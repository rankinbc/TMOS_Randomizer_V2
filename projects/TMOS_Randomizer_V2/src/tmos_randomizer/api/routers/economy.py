"""Economy endpoints: shops, trooper cost, allies/troopers roster, palette colors."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException

from .. import state
from ..deps import _require_rom_pair
from ..schemas import ShopSlotUpdate, TrooperCostUpdate
from ...core import shop_economy as _shop_economy
from ...core import palette_colors as _palette_colors
from ...core import allies as _allies

router = APIRouter()


# --- Economy & Shops (shop slots = expert/DISASSEMBLY; trooper cost = safe) ---
@router.get("/api/rom/shop-economy")
async def get_shop_economy():
    rom, vanilla = _require_rom_pair()
    return {
        "shops": _shop_economy.read_all_shops(rom),
        "vanilla": _shop_economy.read_all_shops(vanilla),
        "shop_count": _shop_economy.SHOP_COUNT,
        "slots_per_shop": _shop_economy.SHOP_SLOTS,
        "shop_table_offset": f"0x{_shop_economy.SHOP_TABLE:05X}",
        "trooper_cost": _shop_economy.read_trooper_cost(rom),
        "trooper_vanilla": _shop_economy.read_trooper_cost(vanilla),
    }


@router.patch("/api/rom/shop-economy/{shop_index}/{slot_index}")
async def patch_shop_slot(shop_index: int, slot_index: int, update: ShopSlotUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _shop_economy.write_shop_slot(
            rom_array, shop_index, slot_index,
            item_code=update.item_code, base_price=update.base_price,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "slot": result}


@router.patch("/api/rom/trooper-cost")
async def patch_trooper_cost(update: TrooperCostUpdate):
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _shop_economy.write_trooper_cost(rom_array, update.cost)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    state._rom_data = bytes(rom_array)
    return {"status": "updated", "trooper": result}


# --- Allies + Troopers roster (read-only) ---

@router.get("/api/rom/allies")
async def get_allies_roster():
    """Return the full ally roster with computed screen locations (read-only).

    Static metadata is ported from AlliesView.tsx KNOWN_ALLIES.  Screen
    locations are computed by scanning each ally's home chapter for screens
    whose content byte matches the ally's ContentType value.

    No ROM is strictly required: if no ROM is loaded the locations list for
    every ally will be empty but the static metadata is still returned.
    """
    return {"allies": _allies.get_allies(state._game_world)}


@router.get("/api/rom/troopers")
async def get_troopers_roster():
    """Return trooper info with recruitment cost and screen locations (read-only).

    Trooper cost is read from the ROM (file offset 0x4577, vanilla = 100).
    Screen locations are the set of screens in any chapter whose content byte
    equals 0x7F (ContentType.TROOPERS).
    The cost is editable via the existing PATCH /api/rom/trooper-cost; this
    endpoint is read-only aggregation.
    """
    return _allies.get_troopers(state._rom_data, state._game_world)


# --- Display-only systems (no confirmed ROM write target; GET only) ---
@router.get("/api/rom/palette-colors")
async def get_palette_colors():
    return {
        "tier": _palette_colors.TIER,
        "editable": False,
        "shadow_page": f"0x{_palette_colors.PALETTE_SHADOW_BASE:04X}",
        "fields": _palette_colors.palette_color_fields(),
        "_note": (
            "Environment/menu colors live in the $04A0 palette shadow RAM page "
            "(uploaded to PPU $3F00 each frame), not a ROM data table — display-only."
        ),
    }
