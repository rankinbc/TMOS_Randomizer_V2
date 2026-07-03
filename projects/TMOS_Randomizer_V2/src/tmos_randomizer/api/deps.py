"""Shared helpers for the TMOS Randomizer API routers.

State guards, canonical serializers, and startup configuration. All mutable
app state is read/written via attribute access on ``state`` (see state.py).
"""

from __future__ import annotations

import logging
import os
import tempfile
from pathlib import Path
from typing import Any, Dict, Optional

from fastapi import HTTPException

from . import state
from ..core import items as _items
from ..core.constants import (
    get_chr_index,
    CHAPTER_BASES,
    WORLDSCREEN_SIZE,
)
from ..core.enums import is_past_screen_index

# Module-level logger.
logger = logging.getLogger(__name__)


def configure_logging() -> None:
    """Set up app logging. Called from the startup event, not at import time,
    so importing this module (tests, tooling) has no side effects and does not
    truncate the navigation log of a running server."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    )
    # Navigation phase logs at DEBUG to a temp file for diagnosis.
    nav_logger = logging.getLogger('tmos_randomizer.phases.phase5_navigation')
    nav_logger.setLevel(logging.DEBUG)
    nav_log_path = os.path.join(tempfile.gettempdir(), 'tmos_navigation.log')
    if not any(
        isinstance(h, logging.FileHandler) and h.baseFilename == nav_log_path
        for h in nav_logger.handlers
    ):
        handler = logging.FileHandler(nav_log_path, mode='w')
        handler.setLevel(logging.DEBUG)
        handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
        nav_logger.addHandler(handler)
    logger.info("Navigation logs will be written to: %s", nav_log_path)


def _require_rom():
    """Return the loaded GameWorld or raise the canonical 400."""
    if state._game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    return state._game_world


def _require_rom_data() -> bytes:
    """Return the live ROM bytes or raise the canonical 400."""
    if state._rom_data is None:
        raise HTTPException(status_code=400, detail="ROM data not available")
    return state._rom_data


def _require_rom_pair() -> tuple[bytes, bytes]:
    """Return (current_rom, vanilla_rom). Lazily initializes the vanilla
    snapshot from current rom data if it wasn't captured at upload time
    (e.g., the server was reloaded after my upload-handler change).
    Raises HTTPException(400) if no ROM is loaded at all."""
    _require_rom_data()
    if state._rom_vanilla is None:
        state._rom_vanilla = state._rom_data
    return state._rom_data, state._rom_vanilla


def _screen_api_dict(chapter_num: int, screen) -> dict:
    """Canonical WorldScreen -> API JSON shape (single source of truth).

    Every screen-returning endpoint uses this superset; do not hand-roll
    per-endpoint subsets (they drift).
    """
    return {
        "index": screen.relative_index,
        "modified": screen.is_modified,
        "global_index": screen.global_index,
        "is_past": is_past_screen_index(chapter_num, screen.relative_index),
        "datapointer": screen.datapointer,
        "chr_index": get_chr_index(screen.datapointer),
        "top_tiles": screen.top_tiles,
        "bottom_tiles": screen.bottom_tiles,
        "objectset": screen.objectset,
        "parent_world": screen.parent_world,
        "ambient_sound": screen.ambient_sound,
        "event": screen.event,
        "content": screen.content,
        "nav_right": screen.screen_index_right,
        "nav_left": screen.screen_index_left,
        "nav_down": screen.screen_index_down,
        "nav_up": screen.screen_index_up,
        "worldscreen_color": screen.worldscreen_color,
        "sprites_color": screen.sprites_color,
        "exit_position": screen.exit_position,
        "unknown": screen.unknown,
    }


def _flush_screens(screens) -> int:
    """Serialize modified WorldScreen objects into the live _rom_data buffer.

    This keeps _rom_data the single source of truth: every screen mutation is
    written back to its WorldScreen file offset so /api/rom/patch can stream
    _rom_data directly. Returns the number of screens written.
    """
    if state._rom_data is None:
        return 0
    rom_array = bytearray(state._rom_data)
    count = 0
    for s in screens:
        off = CHAPTER_BASES[s.chapter] + s.relative_index * WORLDSCREEN_SIZE
        rom_array[off:off + WORLDSCREEN_SIZE] = s.to_bytes()
        count += 1
    state._rom_data = bytes(rom_array)
    return count


def configure_asset_paths(
    sprites_dir: Optional[Path] = None,
    tiles_dir: Optional[Path] = None,
    maps_dir: Optional[Path] = None,
):
    """Configure paths to game assets."""
    # Default paths relative to extracted-data.
    # __file__ = .../TMOS_AI/projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/deps.py
    # 6 parents up = .../TMOS_AI/
    base = Path(__file__).parent.parent.parent.parent.parent.parent / "extracted-data"

    state.ASSET_PATHS["sprites"] = sprites_dir or (base / "images" / "sprites")
    state.ASSET_PATHS["maps"] = maps_dir or (base / "images" / "maps")
    state.ASSET_PATHS["enemies"] = base / "images" / "EncounterEnemyImages"
    state.ASSET_PATHS["overworld_enemies"] = base / "images" / "OverworldEnemyImages"
    state.ASSET_PATHS["bosses"] = base / "images" / "DemonImages"

    # Tiles for the renderer ship INSIDE the package (src/tmos_randomizer/data/
    # tile_images, 165 hex-named PNGs 00.png..FF.png) so they are present wherever
    # the backend runs — the Azure App Service deploy zip ships src/ but NOT
    # extracted-data. Resolve package-relative first; fall back to the repo's
    # extracted-data copy for dev checkouts that haven't built the package data.
    #
    # (A missing tiles dir is not a hard error: the renderer fills every metatile
    # with the WorldScreen ground color, producing blank solid-green screens —
    # that was the "screens don't render" symptom both locally and on Azure.)
    _packaged_tiles = Path(__file__).resolve().parent.parent / "data" / "tile_images"
    if tiles_dir:
        state.ASSET_PATHS["tiles"] = tiles_dir
    elif _packaged_tiles.exists():
        state.ASSET_PATHS["tiles"] = _packaged_tiles
    else:
        state.ASSET_PATHS["tiles"] = base / "images" / "TileImages"


def _serialize_gameplay_item(item: _items.GameplayItem) -> Dict[str, Any]:
    """Serialize a GameplayItem, formatting ram_address as $XXXX."""
    return {
        "id": item.id,
        "name": item.name,
        "category": item.category.value,
        "effect": item.effect,
        "max_count": item.max_count,
        "ram_address": f"${item.ram_address:04X}" if item.ram_address is not None else None,
        "chapter": item.chapter,
    }


def _serialize_battle_item(item: _items.BattleItem) -> Dict[str, Any]:
    """Serialize a BattleItem, formatting addresses as $XXXX."""
    return {
        "id": item.id,
        "name": item.name,
        "pickup_sound": item.pickup_sound,
        "flags": item.flags,
        "handler_addr": f"${item.handler_addr:04X}" if item.handler_addr is not None else None,
        "count_addr": f"${item.count_addr:04X}" if item.count_addr is not None else None,
        "notes": item.notes,
    }
