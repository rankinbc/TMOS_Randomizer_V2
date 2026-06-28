"""FastAPI server for TMOS Randomizer UI backend.

Provides REST API endpoints for:
- Creating and previewing randomization plans
- Applying randomization to ROMs
- Serving game assets (sprites, tiles, maps)

Usage:
    uvicorn tmos_randomizer.api.server:app --reload --port 8000

Or via CLI:
    python -m tmos_randomizer serve --port 8000
"""

from __future__ import annotations

import asyncio
import logging
import os
import re
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional

import tempfile
from fastapi import FastAPI, HTTPException, UploadFile, File, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse, Response
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

# Configure logging for the randomizer modules
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
)
# Set navigation phase to DEBUG for detailed logging
nav_logger = logging.getLogger('tmos_randomizer.phases.phase5_navigation')
nav_logger.setLevel(logging.DEBUG)
# Add file handler to capture navigation logs
_nav_log_path = os.path.join(tempfile.gettempdir(), 'tmos_navigation.log')
_nav_file_handler = logging.FileHandler(_nav_log_path, mode='w')
_nav_file_handler.setLevel(logging.DEBUG)
_nav_file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
nav_logger.addHandler(_nav_file_handler)
print(f"Navigation logs will be written to: {_nav_log_path}")

# Module-level logger (defined early so endpoints declared above the later
# `logger = ...` assignment can still log at runtime).
logger = logging.getLogger(__name__)

from ..randomizer import Randomizer, RandomizationPlan, RandomizationResult, preview_randomization
from ..io.config_loader import RandomizerConfig, get_default_config
from ..io.rom_reader import ROMReader, load_rom
from ..core.chapter import Chapter, GameWorld
from ..core.constants import (
    get_chr_index,
    TILE_TABLE_ADDR,
    TILE_COUNT,
    TILE_SIZE,
    CHAPTER_BASES,
    WORLDSCREEN_SIZE,
)
from ..core import inventory_caps as _inv_caps
from ..core import exp_table as _exp_table
from ..core import player_stats as _player_stats
from ..core import enemies as _enemies
from ..core import enemy_selection as _enemy_selection
from ..core import enemy_stats as _enemy_stats
from ..core import encounter_lineups as _encounter_lineups
from ..core import encounter_groups as _encounter_groups
from ..core import enemy_appearances as _enemy_appearances
from ..core import items as _items
# Advanced page systems (built + verified vs GameAnalysis2 ROM knowledge base)
from ..core import boss_stats as _boss_stats
from ..core import shop_economy as _shop_economy
from ..core import overworld_enemy_stats as _overworld_enemy_stats
from ..core import tb_damage_tables as _tb_damage_tables
from ..core import encounter_rates as _encounter_rates
from ..core import weapon_damage as _weapon_damage
from ..core import mp_table as _mp_table
from ..core import palette_colors as _palette_colors
from ..core import level_caps as _level_caps
from ..core import allies as _allies
from ..core.field_metadata import build_field_metadata
from ..core.enums import NAV_BLOCKED, NAV_BUILDING_ENTRANCE, is_past_screen_index
from ..logic.navigation import connect_screens, disconnect_screens, OPPOSITE_DIRECTIONS

# Import rendering module (optional - gracefully handle if PIL not installed)
try:
    from ..rendering import ScreenRenderer
    from ..rendering.screen_renderer import build_screen_tile_grid
    RENDERING_AVAILABLE = True
except ImportError:
    ScreenRenderer = None
    build_screen_tile_grid = None
    RENDERING_AVAILABLE = False


# =============================================================================
# FastAPI App
# =============================================================================

app = FastAPI(
    title="TMOS Randomizer API",
    description="Backend API for The Magic of Scheherazade Map Randomizer",
    version="2.0.0",
)

# CORS: localhost for dev + any explicit origins in ALLOWED_ORIGINS env var (comma-separated).
# In production set ALLOWED_ORIGINS=https://your-app.azurestaticapps.net in App Service config.
_extra_origins = [o.strip() for o in os.environ.get("ALLOWED_ORIGINS", "").split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=_extra_origins,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global state
_current_plan: Optional[RandomizationPlan] = None
_randomizer: Optional[Randomizer] = None
_game_world: Optional[GameWorld] = None
_rom_path: Optional[Path] = None
_rom_filename: Optional[str] = None
_rom_data: Optional[bytes] = None  # Raw ROM bytes for rendering (mutated by edits)
_rom_vanilla: Optional[bytes] = None  # Snapshot of ROM as uploaded (never mutated)
_screen_renderer: Optional[Any] = None  # ScreenRenderer instance

# Cache for the per-section walkability table (pure function of the loaded ROM).
_ts_walk_cache: dict | None = None
_ts_walk_cache_key: int | None = None

# Cache for the per-section theme table (pure function of the loaded ROM).
_ts_theme_cache: dict | None = None
_ts_theme_cache_key: int | None = None


# =============================================================================
# Pydantic Models
# =============================================================================

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


# =============================================================================
# API Endpoints - Randomization
# =============================================================================

@app.get("/")
async def root():
    """API root - returns status."""
    return {
        "name": "TMOS Randomizer API",
        "version": "2.0.0",
        "status": "running",
        "has_plan": _current_plan is not None,
        "rom_loaded": _game_world is not None,
        "rom_filename": _rom_filename,
    }


# =============================================================================
# API Endpoints - ROM Loading
# =============================================================================

@app.post("/api/rom/upload")
async def upload_rom(file: UploadFile = File(...)):
    """Upload a ROM file for editing/randomization."""
    global _game_world, _rom_path, _rom_filename, _rom_data, _rom_vanilla, _screen_renderer

    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided")

    # Save to temp file
    temp_dir = Path(tempfile.gettempdir()) / "tmos_randomizer"
    temp_dir.mkdir(exist_ok=True)
    temp_path = temp_dir / file.filename

    try:
        content = await file.read()
        with open(temp_path, "wb") as f:
            f.write(content)

        # Load the ROM
        _game_world = load_rom(temp_path)
        _rom_path = temp_path
        _rom_filename = file.filename
        _rom_data = content  # Mutable working copy
        _rom_vanilla = content  # Immutable snapshot for diff comparisons

        # Initialize screen renderer if available
        if RENDERING_AVAILABLE and ASSET_PATHS.get("tiles"):
            tiles_txt = ASSET_PATHS.get("tiles").parent / "DataFiles" / "tiles.txt"
            _screen_renderer = ScreenRenderer(
                _rom_data,
                str(ASSET_PATHS["tiles"]),
                str(tiles_txt) if tiles_txt.exists() else None
            )

        # Get ROM info
        reader = ROMReader(temp_path)
        rom_hash = reader.get_rom_hash()

        return {
            "status": "loaded",
            "filename": file.filename,
            "size": len(content),
            "checksum": rom_hash[:16] + "...",
            "chapters": [
                {
                    "chapter_num": ch.chapter_num,
                    "screen_count": ch.screen_count,
                }
                for ch in _game_world
            ],
            "rendering_available": RENDERING_AVAILABLE and _screen_renderer is not None,
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to load ROM: {str(e)}")


@app.get("/api/rom/status")
async def get_rom_status():
    """Get current ROM loading status."""
    if _game_world is None:
        return {
            "loaded": False,
            "filename": None,
            "chapters": [],
        }

    return {
        "loaded": True,
        "filename": _rom_filename,
        "chapters": [
            {
                "chapter_num": ch.chapter_num,
                "screen_count": ch.screen_count,
            }
            for ch in _game_world
        ],
    }


@app.get("/api/rom/chapter/{chapter_num}")
async def get_chapter_data(chapter_num: int):
    """Get all screen data for a chapter."""
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screens = []
    for screen in chapter:
        screens.append({
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
        })

    return {
        "chapter_num": chapter_num,
        "screen_count": chapter.screen_count,
        "screens": screens,
    }


@app.get("/api/rom/screen/{chapter_num}/{screen_index}")
async def get_screen_data(chapter_num: int, screen_index: int):
    """Get detailed data for a single screen."""
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found")

    return {
        "index": screen.relative_index,
        "modified": screen.is_modified,
        "global_index": screen.global_index,
        "chapter_num": chapter_num,
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
        "unknown": screen.unknown,
        "worldscreen_color": screen.worldscreen_color,
        "sprites_color": screen.sprites_color,
        "navigation": {
            "right": screen.screen_index_right,
            "left": screen.screen_index_left,
            "down": screen.screen_index_down,
            "up": screen.screen_index_up,
        },
        "colors": {
            "worldscreen": screen.worldscreen_color,
            "sprites": screen.sprites_color,
        },
        "exit_position": screen.exit_position,
        "section_type": screen.section_type.name if hasattr(screen, 'section_type') else None,
        "is_stairway": screen.is_stairway,
        "is_town": screen.is_town,
        "has_building_entrance": screen.has_building_entrance,
    }


@app.get("/api/rom/navigation/{chapter_num}")
async def get_chapter_navigation(chapter_num: int):
    """Get navigation graph for a chapter."""
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    # Build navigation graph
    nodes = []
    edges = []

    for screen in chapter:
        idx = screen.relative_index
        nodes.append({
            "id": idx,
            "parent_world": screen.parent_world,
            "event": screen.event,
        })

        # Add edges for valid navigation
        for direction, nav_idx in [
            ("right", screen.screen_index_right),
            ("down", screen.screen_index_down),
        ]:
            if nav_idx < 0xFF and nav_idx < chapter.screen_count:
                edges.append({
                    "from": idx,
                    "to": nav_idx,
                    "direction": direction,
                })

        # Add stairway connections
        if screen.is_stairway and screen.content < chapter.screen_count:
            edges.append({
                "from": idx,
                "to": screen.content,
                "direction": "stairway",
            })

    return {
        "chapter_num": chapter_num,
        "nodes": nodes,
        "edges": edges,
    }


@app.get("/api/rom/chapter/{chapter_num}/edge-walkability")
async def get_chapter_edge_walkability(chapter_num: int):
    """Per-screen booleans flagging which edges are fully non-walkable.

    For each screen, returns whether each of its 4 edges (top/bottom/left/right)
    consists entirely of non-walkable tiles (collidable or deadly). True means
    the player cannot exit through that edge.
    """
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    if _rom_data is None:
        raise HTTPException(status_code=400, detail="ROM data not available")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    from ..validation.tiles.edges import extract_edges
    from ..validation.tiles.categories import is_walkable

    screens: dict[str, dict[str, bool]] = {}
    for screen in chapter:
        try:
            edges = extract_edges(
                _rom_data,
                screen.relative_index,
                screen.top_tiles,
                screen.bottom_tiles,
                screen.datapointer,
            )
            screens[str(screen.relative_index)] = {
                "top": all(not is_walkable(t) for t in edges.top),
                "bottom": all(not is_walkable(t) for t in edges.bottom),
                "left": all(not is_walkable(t) for t in edges.left),
                "right": all(not is_walkable(t) for t in edges.right),
            }
        except Exception:
            # Don't fail the whole chapter for one bad screen
            screens[str(screen.relative_index)] = {
                "top": False, "bottom": False, "left": False, "right": False,
            }

    return {"chapter_num": chapter_num, "screens": screens}


@app.patch("/api/rom/screen/{chapter_num}/{screen_index}/navigation")
async def update_screen_navigation(
    chapter_num: int,
    screen_index: int,
    update: NavigationUpdate,
):
    """Update navigation connections for a screen.

    This modifies the in-memory screen navigation data. Use bidirectional=True
    to also update the neighbor screen's opposite direction.

    Args:
        chapter_num: Chapter number (1-5)
        screen_index: Screen index within chapter
        update: Navigation update with new values (null = disconnect)

    Returns:
        List of modified screen data
    """
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found")

    modified_screens = {screen_index}
    directions_to_update = []

    # Update parent_world if provided
    if update.parent_world is not None:
        if update.parent_world < 0 or update.parent_world > 255:
            raise HTTPException(
                status_code=400,
                detail=f"parent_world must be 0-255, got {update.parent_world}"
            )
        screen.parent_world = update.parent_world
        screen.mark_modified()

    # Collect which directions need updating
    if update.nav_right is not None or update.nav_right == -1:
        directions_to_update.append(("right", update.nav_right))
    if update.nav_left is not None or update.nav_left == -1:
        directions_to_update.append(("left", update.nav_left))
    if update.nav_up is not None or update.nav_up == -1:
        directions_to_update.append(("up", update.nav_up))
    if update.nav_down is not None or update.nav_down == -1:
        directions_to_update.append(("down", update.nav_down))

    # Apply updates
    for direction, target_index in directions_to_update:
        if target_index is None or target_index == -1:
            # Disconnect this direction
            disconnect_screens(screen, direction)
        else:
            # Connect to target screen
            target_screen = chapter.get_screen(target_index)
            if target_screen is None:
                raise HTTPException(
                    status_code=400,
                    detail=f"Target screen {target_index} not found"
                )
            connect_screens(screen, target_screen, direction, bidirectional=update.bidirectional)
            if update.bidirectional:
                modified_screens.add(target_index)

    # Flush edited screens into _rom_data (single source of truth).
    _flush_screens(s for i in modified_screens if (s := chapter.get_screen(i)))

    # Return updated screen data for all modified screens
    result = []
    for idx in modified_screens:
        s = chapter.get_screen(idx)
        if s:
            result.append({
                "index": s.relative_index,
                "modified": s.is_modified,
                "global_index": s.global_index,
                "datapointer": s.datapointer,
                "chr_index": get_chr_index(s.datapointer),
                "top_tiles": s.top_tiles,
                "bottom_tiles": s.bottom_tiles,
                "objectset": s.objectset,
                "parent_world": s.parent_world,
                "event": s.event,
                "content": s.content,
                "nav_right": s.screen_index_right,
                "nav_left": s.screen_index_left,
                "nav_down": s.screen_index_down,
                "nav_up": s.screen_index_up,
                "worldscreen_color": s.worldscreen_color,
                "sprites_color": s.sprites_color,
                "exit_position": s.exit_position,
            })

    return {
        "status": "updated",
        "modified_count": len(modified_screens),
        "screens": result,
    }


@app.patch("/api/rom/screen/{chapter_num}/{screen_index}/tiles")
async def update_screen_tiles(
    chapter_num: int,
    screen_index: int,
    update: TileSectionUpdate,
):
    """Update a screen's Top/Bottom TileSection (live, in-memory).

    `top_tiles`/`bottom_tiles` are GLOBAL section indices (0..470). The backend
    splits each into (byte, bank) and rewrites the DataPointer so the renderer
    selects the right bank, preserving CHR where the bank rules allow.
    """
    from ..core.constants import TILESECTION_COUNT, get_chr_index
    from ..logic.tilesection_bank import resolve_tile_update

    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")
    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found")

    if update.top_tiles is None and update.bottom_tiles is None:
        raise HTTPException(status_code=400, detail="Provide top_tiles and/or bottom_tiles")
    for label, val in (("top_tiles", update.top_tiles), ("bottom_tiles", update.bottom_tiles)):
        if val is not None and (val < 0 or val >= TILESECTION_COUNT):
            raise HTTPException(
                status_code=400,
                detail=f"{label} must be 0-{TILESECTION_COUNT - 1}, got {val}",
            )

    resolved = resolve_tile_update(
        current_datapointer=screen.datapointer,
        top_index=update.top_tiles,
        bottom_index=update.bottom_tiles,
    )
    screen.set_tiles(top=resolved["top_tiles"], bottom=resolved["bottom_tiles"])
    screen.datapointer = resolved["datapointer"]
    screen.mark_modified()
    _flush_screens([screen])

    return {
        "status": "updated",
        "datapointer_changed": resolved["datapointer_changed"],
        "chr_changed": resolved["chr_changed"],
        "screen": {
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
            "event": screen.event,
            "content": screen.content,
            "nav_right": screen.screen_index_right,
            "nav_left": screen.screen_index_left,
            "nav_down": screen.screen_index_down,
            "nav_up": screen.screen_index_up,
            "worldscreen_color": screen.worldscreen_color,
            "sprites_color": screen.sprites_color,
            "exit_position": screen.exit_position,
        },
    }


@app.patch("/api/rom/screen/{chapter_num}/{screen_index}/fields")
async def update_screen_fields(
    chapter_num: int,
    screen_index: int,
    update: ScreenFieldsUpdate,
):
    """Update a screen's editable fields (live, in-memory).

    Allowlist: every WorldScreen byte except the 4 navigation pointers —
    objectset, content, event, worldscreen_color, sprites_color, parent_world,
    ambient_sound, datapointer, exit_position, unknown.
    Each provided value must be 0-255. Mirrors the tiles PATCH guard order.
    """
    from ..core.constants import get_chr_index

    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")
    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found")

    # Allowlist: explicit so excluded fields (nav pointers) can never be set here.
    fields = {
        "objectset": update.objectset,
        "content": update.content,
        "event": update.event,
        "worldscreen_color": update.worldscreen_color,
        "sprites_color": update.sprites_color,
        "parent_world": update.parent_world,
        "ambient_sound": update.ambient_sound,
        "datapointer": update.datapointer,
        "exit_position": update.exit_position,
        "unknown": update.unknown,
    }
    provided = {k: v for k, v in fields.items() if v is not None}
    if not provided:
        raise HTTPException(
            status_code=400,
            detail=(
                "Provide at least one of: objectset, content, event, "
                "worldscreen_color, sprites_color, parent_world, ambient_sound, "
                "datapointer, exit_position, unknown"
            ),
        )
    for label, val in provided.items():
        if val < 0 or val > 255:
            raise HTTPException(status_code=400, detail=f"{label} must be 0-255, got {val}")

    for label, val in provided.items():
        setattr(screen, label, val)
    screen.mark_modified()

    return {
        "status": "updated",
        "screen": {
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
        },
    }


@app.get("/api/rom/screen/{chapter_num}/{screen_index}/vanilla")
async def get_screen_vanilla(chapter_num: int, screen_index: int):
    """Return a screen's original (as-uploaded) field values, for change comparison.

    Returns the screen's original field values (the same ~18 keys as the live
    screen endpoint, including ``index`` and ``global_index``), parsed from the
    pristine ROM rather than the (possibly mutated) live world.
    """
    if _rom_vanilla is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    # Parse the pristine snapshot independently of the (mutated) live world.
    # Edits only ever touch the in-memory _game_world/_rom_data; the file at
    # _rom_path is the as-uploaded ROM and is never mutated, so re-parsing it
    # yields pristine data (same established pattern as _baseline_reachability).
    if _rom_path is not None and Path(_rom_path).exists():
        vanilla_world = load_rom(_rom_path)
    else:
        # Fallback: _rom_path is gone; load from the immutable bytes snapshot
        # via a unique temp file that is always cleaned up.
        tmp = tempfile.NamedTemporaryFile(suffix=".nes", delete=False)
        try:
            tmp.write(_rom_vanilla)
            tmp.close()
            vanilla_world = load_rom(tmp.name)
        finally:
            os.unlink(tmp.name)

    chapter = vanilla_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")
    s = chapter.get_screen(screen_index)
    if s is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found")
    return {
        "index": s.relative_index, "global_index": s.global_index,
        "modified": s.is_modified,
        "parent_world": s.parent_world, "ambient_sound": s.ambient_sound,
        "content": s.content, "objectset": s.objectset,
        "datapointer": s.datapointer, "exit_position": s.exit_position,
        "top_tiles": s.top_tiles, "bottom_tiles": s.bottom_tiles,
        "worldscreen_color": s.worldscreen_color, "sprites_color": s.sprites_color,
        "unknown": s.unknown, "event": s.event,
        "nav_right": s.screen_index_right, "nav_left": s.screen_index_left,
        "nav_down": s.screen_index_down, "nav_up": s.screen_index_up,
    }


# =============================================================================
# API Endpoints - Screen Rendering
# =============================================================================

@app.get("/api/rom/render/{chapter_num}/{screen_index}")
async def render_screen(
    chapter_num: int,
    screen_index: int,
    scale: int = Query(default=4, ge=1, le=8),
    ws_color: Optional[int] = Query(default=None, ge=0, le=255),
):
    """
    Render a screen image from ROM data.

    Args:
        chapter_num: Chapter number (1-5)
        screen_index: Screen index within chapter
        scale: Scale factor (1-8, default 4 = 256x224 pixels)

    Returns:
        PNG image of the rendered screen
    """
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    if not RENDERING_AVAILABLE:
        raise HTTPException(status_code=501, detail="Rendering not available. Install Pillow: pip install Pillow")

    if _screen_renderer is None:
        # Renderer is initialized at ROM-load time. If it's missing here the
        # practical cause is the same as "no ROM loaded" — surface it as the
        # same clean 400 the _game_world guard returns, not an opaque 500.
        raise HTTPException(status_code=400, detail="No ROM loaded")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found in chapter {chapter_num}")

    try:
        # If the client didn't pass ws_color, fall back to the actual screen's value
        effective_ws_color = ws_color if ws_color is not None else screen.worldscreen_color
        # Render the screen
        image_bytes = _screen_renderer.render_screen_to_bytes(
            top_tiles=screen.top_tiles,
            bottom_tiles=screen.bottom_tiles,
            datapointer=screen.datapointer,
            scale=scale,
            format='PNG',
            ws_color=effective_ws_color,
        )

        return Response(
            content=image_bytes,
            media_type="image/png",
            headers={
                "Cache-Control": "public, max-age=3600",  # Cache for 1 hour
                "X-Screen-Index": str(screen_index),
                "X-Top-Tiles": hex(screen.top_tiles),
                "X-Bottom-Tiles": hex(screen.bottom_tiles),
            }
        )
    except Exception as e:
        # Log the full traceback BEFORE raising so the next live 500 shows the
        # cause instead of being swallowed behind a one-line detail string.
        logger.exception(
            "render_screen failed (chapter=%s screen=%s scale=%s ws_color=%s)",
            chapter_num, screen_index, scale, ws_color,
        )
        raise HTTPException(status_code=500, detail=f"Rendering failed: {str(e)}")


@app.get("/api/rom/tilesection/{index}")
async def render_tilesection(
    index: int,
    chr: int = Query(default=0, ge=0, le=63),
    scale: int = Query(default=4, ge=1, le=8),
    ws_color: Optional[int] = Query(default=None, ge=0, le=255),
):
    """Render a single TileSection (8x4 tiles) in isolation as a PNG.

    `index` is a global section index (0..470). Decoupled from any screen's
    DataPointer — bank selection is already baked into the global index.
    """
    from ..core.constants import TILESECTION_COUNT

    if not RENDERING_AVAILABLE or _screen_renderer is None:
        raise HTTPException(status_code=501, detail="Rendering not available")
    if index < 0 or index >= TILESECTION_COUNT:
        raise HTTPException(
            status_code=400,
            detail=f"section index must be 0-{TILESECTION_COUNT - 1}, got {index}",
        )
    try:
        image_bytes = _screen_renderer.render_tilesection_to_bytes(
            index, chr_bank=chr, scale=scale, format='PNG', ws_color=ws_color
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Rendering failed: {e}")

    return Response(
        content=image_bytes,
        media_type="image/png",
        headers={"Cache-Control": "public, max-age=3600", "X-Section-Index": str(index)},
    )


@app.get("/api/rom/tilesection-walkability")
async def get_tilesection_walkability():
    """Intrinsic walkability signature for every global TileSection (0..470).

    Each value is a 32-char bitstring ('1'=walkable, '0'=blocking) over the
    section's 4 rows x 8 cols, row-major. Pure function of the ROM, cached.
    """
    global _ts_walk_cache, _ts_walk_cache_key
    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    key = id(_rom_data)
    if _ts_walk_cache is None or _ts_walk_cache_key != key:
        from ..validation.tiles.edges import all_tilesection_walkability
        _ts_walk_cache = all_tilesection_walkability(_rom_data)
        _ts_walk_cache_key = key

    return {"sections": _ts_walk_cache}


@app.get("/api/rom/tilesection-themes")
async def get_tilesection_themes():
    """Biome ('overworld'/'town'/'dungeon'/'maze'/'special') for every global
    TileSection (0..470). Pure function of the loaded ROM, cached.
    """
    global _ts_theme_cache, _ts_theme_cache_key
    if _rom_data is None or _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    key = id(_rom_data)
    if _ts_theme_cache is None or _ts_theme_cache_key != key:
        from ..validation.tiles.themes import compute_section_themes
        _ts_theme_cache = compute_section_themes(_game_world, _rom_data)
        _ts_theme_cache_key = key

    return {"themes": _ts_theme_cache}


@app.get("/api/rom/objectset/{chapter_num}/{objectset_id}/enemies")
async def get_objectset_enemies(chapter_num: int, objectset_id: int):
    """Return the enemies an ObjectSet spawns, with sprite filenames (read-only)."""
    from ..core.overworld_enemies import parse_objectset_enemy_types, enemy_info

    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    if objectset_id < 0 or objectset_id > 255:
        raise HTTPException(status_code=400, detail="objectset_id must be 0-255")

    types = parse_objectset_enemy_types(_rom_data, chapter_num, objectset_id)
    enemies = []
    for t in types:
        info = enemy_info(t)
        enemies.append({"type": t, "name": info["name"], "image": info["image"]})
    return {"chapter": chapter_num, "objectset_id": objectset_id, "enemies": enemies}


@app.get("/api/rom/render/status")
async def get_render_status():
    """Check if screen rendering is available."""
    return {
        "rendering_available": RENDERING_AVAILABLE,
        "renderer_initialized": _screen_renderer is not None,
        "rom_loaded": _rom_data is not None,
        "tile_images_path": str(ASSET_PATHS.get("tiles")) if ASSET_PATHS.get("tiles") else None,
    }


@app.get("/api/rom/tiles/{chapter_num}/{screen_index}")
async def get_screen_tile_grid(chapter_num: int, screen_index: int):
    """
    Get the 8x6 tile grid for a screen.

    Returns the tile IDs that compose the screen visual.

    Args:
        chapter_num: Chapter number (1-5)
        screen_index: Screen index within chapter

    Returns:
        JSON with 8x6 grid of tile IDs
    """
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    if _rom_data is None:
        raise HTTPException(status_code=400, detail="ROM data not available")

    if build_screen_tile_grid is None:
        raise HTTPException(status_code=501, detail="Tile grid function not available. Install rendering module.")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found in chapter {chapter_num}")

    try:
        # Build the 8x6 tile grid
        tile_grid = build_screen_tile_grid(
            _rom_data,
            screen.top_tiles,
            screen.bottom_tiles,
            screen.datapointer
        )

        return {
            "chapter_num": chapter_num,
            "screen_index": screen_index,
            "grid": tile_grid,
            "grid_width": 8,
            "grid_height": 6,
            "top_tiles": screen.top_tiles,
            "bottom_tiles": screen.bottom_tiles,
            "datapointer": screen.datapointer,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to build tile grid: {str(e)}")


@app.get("/api/strategies")
async def get_strategies():
    """List registered randomization strategies, in display order.

    Built-in strategies come first (classic, organic), then adapters for
    strategies imported from the TMOS Strategy Lab (prefixed ``lab_``).
    """
    from ..strategies import get_strategy, list_strategies

    names = list_strategies()
    builtins = [n for n in names if not n.startswith("lab_")]
    lab_adapted = [n for n in names if n.startswith("lab_")]

    def describe(name: str) -> dict:
        cls = get_strategy(name)
        return {
            "name": name,
            "description": getattr(cls, "description", "") or "",
            "source": "lab" if name.startswith("lab_") else "built-in",
        }

    return {
        "strategies": [describe(n) for n in builtins + lab_adapted],
    }


@app.get("/api/config")
async def get_config():
    """Get current configuration."""
    config = get_default_config()
    return {
        "general": {
            "mode": config.general.mode,
            "chapters": config.general.chapters,
            "seed": config.general.seed,
        },
        "connectivity": {
            "topology": config.connectivity.topology,
            "dungeon_last": config.connectivity.dungeon_last,
            "order_randomization": config.connectivity.order_randomization,
        },
        "difficulty": {
            "preset": config.difficulty.preset,
        },
        "shuffling": config.shuffling,
    }


@app.post("/api/config")
async def update_config(update: ConfigUpdate):
    """Update configuration."""
    global _randomizer

    config = get_default_config()

    if update.topology is not None:
        config.connectivity.topology = update.topology
    if update.dungeon_last is not None:
        config.connectivity.dungeon_last = update.dungeon_last
    if update.chapters is not None:
        config.general.chapters = update.chapters
    if update.difficulty_preset is not None:
        config.difficulty.preset = update.difficulty_preset

    _randomizer = Randomizer(config)

    return {"status": "updated", "config": await get_config()}


@app.post("/api/plan")
async def create_plan(request: PlanRequest):
    """Create a new randomization plan."""
    global _current_plan, _randomizer

    # Build config from request or use defaults
    config = get_default_config()

    if request.config:
        # Apply shuffling settings
        if "shuffling" in request.config:
            shuffling = request.config["shuffling"]
            if "overworld" in shuffling:
                config.shuffling["shuffle_overworld"] = shuffling["overworld"]
            if "towns" in shuffling:
                config.shuffling["shuffle_towns"] = shuffling["towns"]
            if "dungeons" in shuffling:
                config.shuffling["shuffle_dungeons"] = shuffling["dungeons"]
            if "mazes" in shuffling:
                config.shuffling["randomize_mazes"] = shuffling["mazes"]

        # Apply difficulty settings
        if "difficulty" in request.config:
            difficulty = request.config["difficulty"]
            if "preset" in difficulty:
                config.difficulty.preset = difficulty["preset"]

        # Apply connectivity settings
        if "connectivity" in request.config:
            connectivity = request.config["connectivity"]
            if "topology" in connectivity:
                config.connectivity.topology = connectivity["topology"]
            if "dungeon_last" in connectivity:
                config.connectivity.dungeon_last = connectivity["dungeon_last"]

        # Strategy override — accepts either top-level `strategy` or
        # `general.strategy`. Without this the UI button silently fell
        # through to whatever the default is.
        strategy_name = request.config.get("strategy")
        if strategy_name is None:
            general_cfg = request.config.get("general") or {}
            strategy_name = general_cfg.get("strategy")
        if strategy_name:
            config.general.strategy = strategy_name

    _randomizer = Randomizer(config)

    try:
        _current_plan = _randomizer.create_plan(seed=request.seed)
        return {
            "status": "created",
            "seed": _current_plan.seed,
            "is_valid": _current_plan.is_valid,
            "errors": _current_plan.validation_errors,
            "warnings": _current_plan.validation_warnings,
            "plan": _current_plan.to_dict(),
            "config_applied": {
                "shuffling": config.shuffling,
                "difficulty": config.difficulty.preset if hasattr(config.difficulty, 'preset') else None,
                "topology": config.connectivity.topology if hasattr(config.connectivity, 'topology') else None,
            },
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/plan")
async def get_plan():
    """Get current randomization plan."""
    if _current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    return {
        "seed": _current_plan.seed,
        "is_valid": _current_plan.is_valid,
        "errors": _current_plan.validation_errors,
        "warnings": _current_plan.validation_warnings,
        "plan": _current_plan.to_dict(),
    }


# ── Async apply-preview job registry ───────────────────────────────────────
# apply-preview is CPU-bound and can run for minutes on small cloud tiers,
# where a single synchronous request looks hung and risks gateway timeouts.
# The async endpoint runs the same work in a background thread and exposes a
# pollable status, so the request returns immediately and never times out.
# Single-process, in-memory; this is a single-user editing tool.
_preview_jobs: Dict[str, Dict[str, Any]] = {}
_PREVIEW_JOBS_MAX = 12


def _prune_preview_jobs() -> None:
    """Keep the job registry small — drop the oldest finished jobs."""
    if len(_preview_jobs) <= _PREVIEW_JOBS_MAX:
        return
    finished = sorted(
        (jid for jid, j in _preview_jobs.items() if j["status"] != "running"),
        key=lambda jid: _preview_jobs[jid]["started_at"],
    )
    for jid in finished[: len(_preview_jobs) - _PREVIEW_JOBS_MAX]:
        _preview_jobs.pop(jid, None)


def _apply_preview_compute() -> Dict[str, Any]:
    """Synchronous core of apply-preview.

    Mutates module state (_game_world, _current_plan, _randomizer) and returns
    the result dict. Assumes preconditions (plan created, ROM loaded) were
    already checked by the caller. Raises on internal failure; callers map that
    to an HTTP 500 (sync endpoint) or a job error (async endpoint).
    """
    global _current_plan, _game_world, _randomizer

    if _randomizer is None:
        _randomizer = Randomizer(get_default_config())

    logger.info(f"Plan seed: {_current_plan.seed}")
    logger.info(f"World plan chapters: {len(_current_plan.world_plan.chapters)}")
    logger.info(f"World shape chapters: {len(_current_plan.world_shape.chapters)}")
    logger.info(f"World connections chapters: {len(_current_plan.world_connections.chapters)}")

    # Log plan details
    for chapter_plan in _current_plan.world_plan.chapters:
        logger.info(f"  Chapter {chapter_plan.chapter_num}: {len(chapter_plan.sections)} sections, {chapter_plan.total_screens} total screens")
        for section in chapter_plan.sections:
            logger.info(f"    Section {section.section_id}: {section.section_type.name}, {section.target_screen_count} screens, preserve={section.preserve_original}")

    # Log shape details
    for chapter_shape in _current_plan.world_shape.chapters:
        logger.info(f"  Chapter {chapter_shape.chapter_num} shape: {len(chapter_shape.sections)} sections with shapes")
        for section_shape in chapter_shape.sections:
            logger.info(f"    Section {section_shape.section_id}: {len(section_shape.screens)} screens in shape")

    try:
        # Dispatch through the active strategy so organic / classic / custom
        # strategies all route their own in-memory randomization. Falls back
        # to the legacy phase4+phase5 flow if the strategy hasn't implemented
        # preview_plan (for backwards compatibility with third-party strategies).
        strategy = _randomizer.strategy
        logger.info(f"Dispatching preview through strategy: {strategy.name}")

        try:
            strategy.preview_plan(
                plan=_current_plan,
                game_world=_game_world,
                rom_data=_rom_data or b"",
            )
        except NotImplementedError:
            # Legacy path for any strategy that hasn't adopted preview_plan.
            from ..phases.phase4_population import populate_world
            from ..phases.phase5_navigation import rewrite_world_navigation

            world_population = populate_world(
                game_world=_game_world,
                world_plan=_current_plan.world_plan,
                world_shape=_current_plan.world_shape,
                seed=_current_plan.seed,
            )
            _current_plan.world_population = world_population
            world_navigation = rewrite_world_navigation(
                game_world=_game_world,
                world_shape=_current_plan.world_shape,
                world_connections=_current_plan.world_connections,
                world_population=world_population,
                seed=_current_plan.seed,
                preserve_buildings=True,
            )
            _current_plan.world_navigation = world_navigation

        world_navigation = _current_plan.world_navigation
        modified_count = 0
        if world_navigation is not None:
            for chapter_nav in world_navigation.chapters:
                modified_screens = set()
                for change in chapter_nav.navigation_changes:
                    modified_screens.add(change.screen_index)
                for stairway in chapter_nav.stairway_changes:
                    modified_screens.add(stairway.screen_a)
                    modified_screens.add(stairway.screen_b)
                modified_count += len(modified_screens)

        # Fallback for strategies (like the lab adapters) that mutate screen
        # bytes directly without populating world_navigation. The WorldScreen
        # _modified flag is the ground truth for "byte-level change".
        if modified_count == 0:
            modified_count = sum(
                1 for ch in _game_world for s in ch.screens if s.is_modified
            )

        # Navigability gate (soft). The organic strategy is iterating toward
        # full spatial reachability but still produces seeds with some
        # unreachable screens. We report them as warnings and let the UI
        # render the rest — blocking the preview here would hide the
        # Flow/Screens views from the user entirely.
        connectivity_report = _check_world_connectivity(_game_world)
        all_connected = all(r["fully_reachable"] for r in connectivity_report)
        if not all_connected:
            failing = [
                f"Ch{r['chapter_num']}: {r['reachable_from_0']}/{r['screen_count']} reachable"
                for r in connectivity_report if not r["fully_reachable"]
            ]
            logger.warning(f"Navigability incomplete (soft): {failing}")

        # Honest navigability check. Directed BFS understates reachability (even
        # the stock ROM isn't 100% by it because most screens connect via
        # warps), so we judge "fragmented" RELATIVE to the stock baseline using
        # warp-aware reachability per chapter — not against an absolute bar.
        baseline = _baseline_reachability()
        nav_chapters = []
        nav_ok = True
        for ch in _game_world:
            r = _analyze_full_reachability(ch)
            base = baseline.get(ch.chapter_num, {})
            base_comp = base.get("full_components")
            base_pct = base.get("percent")
            fragmented = False
            if base_comp is not None and base_pct is not None:
                # More disconnected pieces than stock, or notably less reachable.
                fragmented = (
                    r["full_components"] > base_comp
                    or r["percent"] < base_pct - 5.0
                )
            if fragmented:
                nav_ok = False
            nav_chapters.append({
                "chapter_num": ch.chapter_num,
                "reachable_percent": round(r["percent"], 1),
                "components": r["full_components"],
                "baseline_percent": round(base_pct, 1) if base_pct is not None else None,
                "baseline_components": base_comp,
                "fragmented": fragmented,
            })
        if not nav_ok:
            frag = [c["chapter_num"] for c in nav_chapters if c["fragmented"]]
            logger.warning(
                f"Navigability gate: world more fragmented than stock in "
                f"chapters {frag}"
            )

        # Flush all randomized/edited screens into _rom_data so a later
        # /api/rom/patch captures the applied plan.
        _flush_screens(s for ch in _game_world for s in ch.screens if s.is_modified)

        return {
            "status": "applied",
            "seed": _current_plan.seed,
            "strategy": strategy.name,
            "screens_modified": modified_count,
            "navigability_ok": nav_ok,
            "navigability": {
                "ok": nav_ok,
                "fragmented_chapters": [
                    c["chapter_num"] for c in nav_chapters if c["fragmented"]
                ],
                "chapters": nav_chapters,
            },
            "connectivity": connectivity_report,
            "chapters": [
                {
                    "chapter_num": ch.chapter_num,
                    "screen_count": ch.screen_count,
                }
                for ch in _game_world
            ],
        }
    except HTTPException:
        raise
    except Exception:
        # Let callers decide how to surface this (HTTP 500 for the sync
        # endpoint, a job error for the async one). Re-raise the original.
        logger.exception("apply-preview compute failed")
        raise


@app.post("/api/plan/apply-preview")
async def apply_plan_preview():
    """Apply the current plan to the in-memory game world for preview (sync).

    Modifies in-memory ROM data so /api/rom/chapter endpoints return the
    randomized world. Does NOT write to disk. This blocks for the full
    randomization; prefer /api/plan/apply-preview-async on slow tiers.
    """
    if _current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created yet")
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    try:
        return _apply_preview_compute()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to apply preview: {str(e)}")


@app.post("/api/plan/apply-preview-async")
async def apply_plan_preview_async():
    """Start apply-preview as a background job; returns a pollable job id.

    The heavy, CPU-bound randomization runs in a worker thread so this request
    returns immediately and the long compute can't hit a gateway/request
    timeout. Poll /api/plan/apply-preview-status/{job_id} for the result.
    """
    if _current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created yet")
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    job_id = uuid.uuid4().hex
    _preview_jobs[job_id] = {
        "status": "running",
        "result": None,
        "error": None,
        "started_at": time.time(),
    }
    _prune_preview_jobs()

    def _run() -> None:
        try:
            res = _apply_preview_compute()
            job = _preview_jobs.get(job_id)
            if job is not None:
                job["status"] = "done"
                job["result"] = res
        except Exception as e:  # noqa: BLE001 — surfaced to the client as job error
            job = _preview_jobs.get(job_id)
            if job is not None:
                job["status"] = "error"
                job["error"] = str(e) or e.__class__.__name__

    # Schedule on the default thread pool; CPython preemptively releases the
    # GIL (~5ms) so status polls are still served while compute runs.
    asyncio.get_running_loop().run_in_executor(None, _run)
    return {"job_id": job_id, "status": "running"}


@app.get("/api/plan/apply-preview-status/{job_id}")
async def apply_plan_preview_status(job_id: str):
    """Poll the status/result of an async apply-preview job."""
    job = _preview_jobs.get(job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Unknown job id")
    return {
        "status": job["status"],
        "result": job["result"],
        "error": job["error"],
        "elapsed_seconds": round(time.time() - job["started_at"], 1),
    }


@app.post("/api/rom/patch")
async def patch_rom(filename: Optional[str] = Query(default=None)):
    """Stream the fully-edited ROM as a browser download.

    _rom_data is the single source of truth (table edits write to it directly;
    screen edits are flushed via _flush_screens). A defensive reconcile flushes
    any still-dirty screens so a forgotten flush site cannot drop edits.
    Runs a non-blocking navigability check and reports the count via a header.
    """
    _require_rom_pair()  # raises HTTPException(400) if no ROM loaded
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    # Defensive reconcile: capture any dirty screens not yet flushed.
    # _flush_screens rebuilds the _rom_data buffer in place.
    _flush_screens(s for ch in _game_world for s in ch.screens if s.is_modified)
    modified_count = sum(
        1 for ch in _game_world for s in ch.screens if s.is_modified
    )

    # Non-blocking navigability check: count chapters with unreachable screens.
    report = _check_world_connectivity(_game_world)
    warning_count = sum(1 for r in report if not r["fully_reachable"])

    # Resolve a safe download filename: strip path components, then remove
    # characters that could break or inject into the Content-Disposition header
    # (double-quote and CR/LF). Fall back to the default if nothing usable remains.
    if filename:
        name = re.sub(r'[\r\n"]', "", Path(filename).name).strip()
    else:
        name = ""
    if not name:
        if _rom_filename:
            name = f"{Path(_rom_filename).stem}-edited.nes"
        else:
            name = "edited.nes"

    return Response(
        content=_rom_data,
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f'attachment; filename="{name}"',
            "X-Patch-Warnings": str(warning_count),
            "X-Screens-Modified": str(modified_count),
            "Access-Control-Expose-Headers":
                "X-Patch-Warnings, X-Screens-Modified, Content-Disposition",
        },
    )


_baseline_reach_cache: tuple = (None, {})


def _baseline_reachability() -> Dict[int, Dict[str, float]]:
    """Per-chapter warp-aware reachability of the PRISTINE (stock) ROM, cached.

    The stock ROM file at ``_rom_path`` is never mutated (edits live in memory),
    so re-parsing it yields the stock baseline. Used to judge whether a
    randomized world is more fragmented than the real game. Cached by ROM path,
    so it recomputes automatically when a different ROM is loaded.
    """
    global _baseline_reach_cache
    key = str(_rom_path) if _rom_path else None
    if key is not None and _baseline_reach_cache[0] == key:
        return _baseline_reach_cache[1]
    result: Dict[int, Dict[str, float]] = {}
    try:
        if _rom_path and Path(_rom_path).exists():
            stock = load_rom(_rom_path)
            for ch in stock:
                r = _analyze_full_reachability(ch)
                result[ch.chapter_num] = {
                    "percent": r["percent"],
                    "full_components": r["full_components"],
                }
    except Exception:
        logger.exception("baseline reachability computation failed")
        result = {}
    _baseline_reach_cache = (key, result)
    return result


def _check_world_connectivity(game_world) -> List[Dict[str, Any]]:
    """Per-chapter directed reachability from screen 0 (ignoring 0xFE/0xFF)."""
    from collections import deque as _deque
    from ..logic.navigation import DIRECTIONS as _DIRS

    reports: List[Dict[str, Any]] = []
    for chapter in game_world:
        total = chapter.screen_count
        if total == 0:
            reports.append({
                "chapter_num": chapter.chapter_num,
                "screen_count": 0,
                "reachable_from_0": 0,
                "subworld_count": 0,
                "unreachable": [],
                "fully_reachable": True,
            })
            continue
        reached = {0}
        q = _deque([0])
        while q:
            idx = q.popleft()
            scr = chapter.get_screen(idx)
            if scr is None:
                continue
            for d in _DIRS:
                t = getattr(scr, f"screen_index_{d}")
                if t in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                    continue
                if t < 0 or t >= total:
                    continue
                if t in reached:
                    continue
                reached.add(t)
                q.append(t)
        unreachable_all = [i for i in range(total) if i not in reached]
        subworld = set()
        for i in unreachable_all:
            scr = chapter.get_screen(i)
            if scr is not None and scr.content in {0xC0, 0xC7, 0xD7}:
                subworld.add(i)
        unreachable_play = [i for i in unreachable_all if i not in subworld]
        reports.append({
            "chapter_num": chapter.chapter_num,
            "screen_count": total,
            "reachable_from_0": len(reached),
            "subworld_count": len(subworld),
            "unreachable": unreachable_play,
            "fully_reachable": len(unreachable_play) == 0,
        })
    return reports


@app.get("/api/plan/chapters")
async def get_plan_chapters():
    """Get chapter summaries from current plan."""
    if _current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    chapters = []
    for chapter_plan in _current_plan.world_plan.chapters:
        chapters.append({
            "chapter_num": chapter_plan.chapter_num,
            "total_screens": chapter_plan.total_screens,
            "section_count": len(chapter_plan.sections),
            "sections": [
                {
                    "section_id": s.section_id,
                    "type": s.section_type.name,
                    "screen_count": s.target_screen_count,
                    "shape": s.shape,
                    "preserved": s.preserve_original,
                }
                for s in chapter_plan.sections
            ],
        })

    return {"chapters": chapters}


@app.get("/api/plan/chapter/{chapter_num}")
async def get_chapter_detail(chapter_num: int):
    """Get detailed plan for a specific chapter."""
    if _current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    chapter_plan = _current_plan.world_plan.get_chapter(chapter_num)
    if chapter_plan is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not in plan")

    # Get shape data
    chapter_shape = None
    for shape in _current_plan.world_shape.chapters:
        if shape.chapter_num == chapter_num:
            chapter_shape = shape.to_dict()
            break

    # Get connection data
    chapter_connections = None
    for conn in _current_plan.world_connections.chapters:
        if conn.chapter_num == chapter_num:
            chapter_connections = conn.to_dict()
            break

    return {
        "plan": chapter_plan.to_dict(),
        "shape": chapter_shape,
        "connections": chapter_connections,
    }


@app.get("/api/plan/section-map")
async def get_section_map():
    """Get mapping of screen index → section for current plan.

    Returns a per-chapter mapping of screen indices to their section assignments.
    This uses the world_population data from Phase 4 (after apply-preview is called).
    """
    if _current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    if _current_plan.world_population is None:
        # Plan exists but hasn't been applied yet - return empty map
        return {
            "applied": False,
            "chapters": {},
            "note": "Call /api/plan/apply-preview first to populate section assignments"
        }

    chapters_map = {}
    for chapter_pop in _current_plan.world_population.chapters:
        chapter_num = chapter_pop.chapter_num
        screen_sections = {}

        # Get section plan to retrieve is_past flag
        chapter_plan = _current_plan.world_plan.get_chapter(chapter_num)
        section_is_past = {}
        if chapter_plan:
            for section in chapter_plan.sections:
                section_is_past[section.section_id] = section.is_past

        for assignment in chapter_pop.assignments:
            entry = {
                "section_id": assignment.section_id,
                "local_id": assignment.local_id,
                "section_type": assignment.original_section_type.name if hasattr(assignment.original_section_type, 'name') else str(assignment.original_section_type),
                "is_past": section_is_past.get(assignment.section_id, False),
            }
            if assignment.grid_position is not None:
                entry["grid_x"] = assignment.grid_position[0]
                entry["grid_y"] = assignment.grid_position[1]
            screen_sections[assignment.real_screen_index] = entry

        chapters_map[chapter_num] = {
            "screen_count": len(chapter_pop.assignments),
            "section_count": len(set(a.section_id for a in chapter_pop.assignments)),
            "screens": screen_sections,
        }

    return {
        "applied": True,
        "seed": _current_plan.seed,
        "chapters": chapters_map,
    }


@app.get("/api/plan/section-map/{chapter_num}")
async def get_chapter_section_map(chapter_num: int):
    """Get section map for a specific chapter.

    Groups screens by section for easy visualization.
    """
    if _current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    if _current_plan.world_population is None:
        raise HTTPException(
            status_code=400,
            detail="Plan not applied. Call /api/plan/apply-preview first."
        )

    # Find the chapter population data
    chapter_pop = None
    for cp in _current_plan.world_population.chapters:
        if cp.chapter_num == chapter_num:
            chapter_pop = cp
            break

    if chapter_pop is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not in plan")

    # Get section plan to retrieve is_past flag
    chapter_plan = _current_plan.world_plan.get_chapter(chapter_num)
    section_is_past = {}
    if chapter_plan:
        for section in chapter_plan.sections:
            section_is_past[section.section_id] = section.is_past

    # Group screens by section
    sections = {}
    for assignment in chapter_pop.assignments:
        section_id = assignment.section_id
        if section_id not in sections:
            sections[section_id] = {
                "section_id": section_id,
                "section_type": assignment.original_section_type.name if hasattr(assignment.original_section_type, 'name') else str(assignment.original_section_type),
                "is_past": section_is_past.get(section_id, False),
                "screens": [],
            }
        sections[section_id]["screens"].append({
            "screen_index": assignment.real_screen_index,
            "local_id": assignment.local_id,
        })

    # Also get parent_world info from the loaded ROM if available
    if _game_world is not None:
        chapter = _game_world.chapters.get(chapter_num)
        if chapter:
            for section_data in sections.values():
                parent_worlds = set()
                for screen_info in section_data["screens"]:
                    screen = chapter.get_screen(screen_info["screen_index"])
                    if screen:
                        parent_worlds.add(screen.parent_world)
                        screen_info["parent_world"] = screen.parent_world
                section_data["parent_worlds"] = list(parent_worlds)

    return {
        "chapter_num": chapter_num,
        "section_count": len(sections),
        "total_screens": len(chapter_pop.assignments),
        "sections": list(sections.values()),
    }


@app.get("/api/debug/validate")
async def debug_validate_rom():
    """Run comprehensive validation tests on the current ROM state.

    This runs ALL validators from the validation criteria document:
    - R-001: Navigation integrity
    - R-002: Time period boundaries
    - R-003: Reachability
    - R-004: World connectivity
    - R-010-R-022: Post-randomization validators (if plan applied)

    Returns detailed structured results for each chapter.
    """
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    # Sourced from the modern validation framework (validation/runner.py +
    # validation/validators/*) instead of the retired testing.validators module.
    # The ValidationRunner runs every registered validator per chapter; we map
    # each ValidationIssue back onto the legacy per-requirement response shape
    # the frontend (JsonDebugPanel ValidationView) consumes.
    from ..validation.runner import ValidationRunner
    from ..validation.config import ValidationConfig
    from ..validation.base import ValidationPhase, Severity
    from ..core.enums import PAST_SCREEN_INDICES

    def _find_time_door_screens(chapter) -> set:
        """Screens whose Content byte marks a time door (0xC0/0xC7/0xD7)."""
        time_door_contents = {0xC0, 0xC7, 0xD7}
        return {
            screen.relative_index
            for screen in chapter
            if screen.content in time_door_contents
        }

    # Map modern validator IDs onto the legacy R-xxx requirement codes the
    # frontend's error_breakdown keys on. Unknown IDs fall back to the raw id.
    validator_requirement_map = {
        "navigation_consistency": "R-001",
        "time_period_isolation": "R-002",
        "screen_traversability": "R-003",
        "section_flow": "R-004",
        "edge_compatibility": "R-010",
        "edge_alignment": "R-011",
        "spatial_consistency": "R-016",
        "datapointer_objectset": "R-020",
    }

    runner = ValidationRunner(ValidationConfig())
    validation_context = {"rom_data": _rom_data}

    results = {
        "status": "completed",
        "rom_filename": _rom_filename,
        "has_plan": _current_plan is not None,
        "chapters": [],
        "summary": {
            "total_errors": 0,
            "total_warnings": 0,
            "all_passed": True,
            "error_breakdown": {},  # requirement -> count
        },
    }

    for chapter_num in range(1, 6):
        chapter = _game_world.chapters.get(chapter_num)
        if chapter is None:
            continue

        chapter_result = {
            "chapter_num": chapter_num,
            "total_screens": len(chapter),
            "errors": [],  # List of issue dicts
            "warnings": [],  # List of issue dicts
            "passed": True,
            "metrics": {},
        }

        # Run every registered validator for this chapter via the modern
        # framework. This covers both pre- and post-randomization state — the
        # validators read the live `chapter` (which reflects any applied plan)
        # plus rom_data from the context.
        chapter_validation = runner.run_for_chapter(
            chapter,
            phase=ValidationPhase.FINAL,
            context=validation_context,
        )
        all_issues = chapter_validation.issues

        # If a plan is applied, surface the same section-count metrics as before.
        if _current_plan is not None:
            chapter_plan = _current_plan.world_plan.get_chapter(chapter_num)
            chapter_population = getattr(_current_plan, 'world_population', None)
            chapter_pop = (
                chapter_population.get_chapter(chapter_num)
                if chapter_population else None
            )
            if chapter_plan and chapter_pop:
                chapter_result["metrics"]["section_count_planned"] = len(chapter_plan.sections)
                chapter_result["metrics"]["section_count_assigned"] = len([
                    s for s in chapter_plan.sections
                    if len(chapter_pop.screen_assignments.get(s.section_id, [])) > 0
                ])

        # Categorize issues into the legacy per-requirement response shape.
        for issue in all_issues:
            requirement = validator_requirement_map.get(
                issue.validator_id, issue.validator_id
            )
            issue_dict = issue.to_dict()
            # Backward-compat: the legacy shape carried a top-level `requirement`.
            issue_dict["requirement"] = requirement

            if issue.severity == Severity.ERROR:
                chapter_result["errors"].append(issue_dict)
                # Track error breakdown by requirement
                if requirement not in results["summary"]["error_breakdown"]:
                    results["summary"]["error_breakdown"][requirement] = 0
                results["summary"]["error_breakdown"][requirement] += 1
            else:
                chapter_result["warnings"].append(issue_dict)

        # Enhanced reachability analysis
        reachability = _analyze_full_reachability(chapter)
        chapter_result["reachability"] = reachability
        chapter_result["metrics"]["reachability_percent"] = reachability["percent"]
        chapter_result["nav_components"] = reachability["nav_components"]
        chapter_result["full_components"] = reachability["full_components"]

        if reachability["percent"] < 95.0:
            chapter_result["warnings"].append({
                "severity": "warning",
                "category": "reachability",
                "message": f"Low reachability: {reachability['percent']:.1f}%",
                "requirement": "R-003",
            })

        if reachability["full_components"] > 1:
            chapter_result["errors"].append({
                "severity": "error",
                "category": "connectivity",
                "message": f"World fragmented into {reachability['full_components']} regions",
                "requirement": "R-004",
            })

        # Time period stats
        time_doors = _find_time_door_screens(chapter)
        past_screens = PAST_SCREEN_INDICES.get(chapter_num, set())
        chapter_result["time_period"] = {
            "past_count": len(past_screens),
            "present_count": len(chapter) - len(past_screens),
            "time_doors": sorted(time_doors),
        }

        chapter_result["stairways"] = reachability["stairway_count"]

        # Count time period violations in metrics
        time_violations = [e for e in chapter_result["errors"]
                          if e.get("requirement") == "R-002" or e.get("category") == "time_period_violation"]
        chapter_result["metrics"]["time_period_violations"] = len(time_violations)

        # Count grid overlaps in metrics
        grid_overlaps = [e for e in chapter_result["errors"]
                        if e.get("requirement") == "R-016" or e.get("category") == "grid_overlap"]
        chapter_result["metrics"]["grid_overlap_count"] = len(grid_overlaps)

        # Determine pass/fail
        chapter_result["passed"] = len(chapter_result["errors"]) == 0

        # Update summary
        results["summary"]["total_errors"] += len(chapter_result["errors"])
        results["summary"]["total_warnings"] += len(chapter_result["warnings"])
        if not chapter_result["passed"]:
            results["summary"]["all_passed"] = False

        results["chapters"].append(chapter_result)

    return results


def _analyze_full_reachability(chapter) -> dict:
    """Analyze reachability including stairways and time doors.

    Returns dict with reachability stats accounting for all connection types.
    """
    from collections import deque

    screen_count = len(chapter)

    # Build adjacency including stairways
    adjacency: dict[int, set[int]] = {i: set() for i in range(screen_count)}
    stairway_count = 0

    for screen in chapter:
        idx = screen.relative_index

        # Direct navigation
        for nav in [screen.screen_index_up, screen.screen_index_down,
                    screen.screen_index_left, screen.screen_index_right]:
            if nav < screen_count:  # Valid screen index (not 0xFF or 0xFE)
                adjacency[idx].add(nav)

        # Stairway connections (Event=0x40, Content=destination)
        if screen.event == 0x40 and screen.content < screen_count:
            adjacency[idx].add(screen.content)
            adjacency[screen.content].add(idx)  # Bidirectional
            stairway_count += 1

        # Time door connections (Content=0xC0)
        # Time doors connect to the other time door in the chapter
        if screen.content == 0xC0:
            # Find the other time door
            for other in chapter:
                if other.content == 0xC0 and other.relative_index != idx:
                    adjacency[idx].add(other.relative_index)
                    break

    # BFS from screen 0 with full connections
    visited = set()
    queue = deque([0])
    visited.add(0)

    while queue:
        current = queue.popleft()
        for neighbor in adjacency[current]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    # Find connected components (full graph)
    all_visited = set()
    full_components = 0
    for start in range(screen_count):
        if start in all_visited:
            continue
        full_components += 1
        comp_queue = deque([start])
        all_visited.add(start)
        while comp_queue:
            current = comp_queue.popleft()
            for neighbor in adjacency[current]:
                if neighbor not in all_visited:
                    all_visited.add(neighbor)
                    comp_queue.append(neighbor)

    # Count nav-only components for comparison
    from ..logic.navigation import find_connected_components
    nav_components = len(find_connected_components(chapter))

    return {
        "reachable_count": len(visited),
        "total_count": screen_count,
        "percent": 100.0 * len(visited) / screen_count if screen_count > 0 else 0,
        "nav_components": nav_components,
        "full_components": full_components,
        "stairway_count": stairway_count,
    }


@app.get("/api/debug/navigation/{chapter_num}")
async def debug_navigation(chapter_num: int):
    """Debug endpoint: Dump complete navigation state for a chapter.

    Shows all screens with their current navigation values.
    Useful for debugging navigation issues.
    """
    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screens_data = []
    connected_count = 0
    isolated_count = 0

    for screen in chapter:
        nav_right = screen.screen_index_right
        nav_left = screen.screen_index_left
        nav_down = screen.screen_index_down
        nav_up = screen.screen_index_up

        # Count connections (not blocked, not building entrance)
        connections = []
        for direction, nav_val in [("right", nav_right), ("left", nav_left), ("down", nav_down), ("up", nav_up)]:
            if nav_val != 0xFF and nav_val != 0xFE:
                connections.append({"direction": direction, "target": nav_val})

        is_isolated = len(connections) == 0

        screens_data.append({
            "index": screen.relative_index,
            "nav_right": f"{nav_right:02X}" if nav_right >= 0xFE else nav_right,
            "nav_left": f"{nav_left:02X}" if nav_left >= 0xFE else nav_left,
            "nav_down": f"{nav_down:02X}" if nav_down >= 0xFE else nav_down,
            "nav_up": f"{nav_up:02X}" if nav_up >= 0xFE else nav_up,
            "connection_count": len(connections),
            "connections": connections,
            "is_isolated": is_isolated,
            "parent_world": screen.parent_world,
        })

        if is_isolated:
            isolated_count += 1
        else:
            connected_count += 1

    # Find connected components
    from ..logic.navigation import find_connected_components
    components = find_connected_components(chapter)

    return {
        "chapter_num": chapter_num,
        "screen_count": chapter.screen_count,
        "connected_screens": connected_count,
        "isolated_screens": isolated_count,
        "component_count": len(components),
        "component_sizes": [len(c) for c in components],
        "screens": screens_data,
    }


@app.get("/api/debug/section-validation/{chapter_num}")
async def debug_section_validation(chapter_num: int):
    """Validate that randomization output matches the plan.

    Compares:
    - Planned sections vs actual screen assignments
    - Intra-section connectivity (screens within a section should be connected)
    - Inter-section connectivity (sections should be connected as planned)

    This is the KEY diagnostic tool for debugging randomization issues.
    """
    global _current_plan, _game_world

    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    if _current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created. Call POST /api/plan first.")

    if _current_plan.world_population is None:
        raise HTTPException(status_code=400, detail="Plan not applied. Call POST /api/plan/apply-preview first.")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    # Get plan, population, and connections data
    chapter_plan = _current_plan.world_plan.get_chapter(chapter_num)
    chapter_pop = _current_plan.world_population.get_chapter(chapter_num)
    chapter_conn = _current_plan.world_connections.get_chapter(chapter_num)

    if chapter_plan is None or chapter_pop is None:
        raise HTTPException(status_code=400, detail="Plan data missing for this chapter")

    # Import helper function
    from ..logic.navigation import find_components_in_subset

    issues = []
    section_details = []

    # Analyze each planned section
    for section_plan in chapter_plan.sections:
        section_id = section_plan.section_id
        section_type = section_plan.section_type.name
        planned_screens = section_plan.target_screen_count

        # Get assigned screens from population
        assigned_screens = chapter_pop.screen_assignments.get(section_id, [])
        assigned_count = len(assigned_screens)

        # Find connected components WITHIN this section's screens
        screen_set = set(assigned_screens)
        internal_components = find_components_in_subset(chapter, screen_set)
        component_count = len(internal_components)
        component_sizes = sorted([len(c) for c in internal_components], reverse=True)

        # Determine status
        if assigned_count == 0:
            status = "EMPTY"
            issues.append(f"Section {section_id} ({section_type}): No screens assigned")
        elif component_count > 1:
            status = "FRAGMENTED"
            issues.append(f"Section {section_id} ({section_type}): Fragmented into {component_count} components {component_sizes}")
        else:
            status = "OK"

        section_details.append({
            "section_id": section_id,
            "type": section_type,
            "planned_screens": planned_screens,
            "assigned_screens": assigned_count,
            "screen_indices": assigned_screens[:20],  # Limit for readability
            "internal_components": component_count,
            "component_sizes": component_sizes,
            "status": status,
        })

    # Analyze inter-section connections
    connection_details = []
    if chapter_conn:
        for conn in chapter_conn.connections:
            from_section = conn.from_section_id
            to_section = conn.to_section_id

            # Get the actual screens used for this connection
            from_screens = chapter_pop.screen_assignments.get(from_section, [])
            to_screens = chapter_pop.screen_assignments.get(to_section, [])

            # Check if ANY screen from from_section connects to ANY screen in to_section
            connected = False
            connecting_screen = None
            target_screen = None
            direction_used = None

            for from_idx in from_screens:
                screen = chapter.get_screen(from_idx)
                if screen is None:
                    continue

                for direction in ["right", "left", "down", "up"]:
                    attr = f"screen_index_{direction}"
                    target = getattr(screen, attr)
                    if target in to_screens:
                        connected = True
                        connecting_screen = from_idx
                        target_screen = target
                        direction_used = direction
                        break
                if connected:
                    break

            status = "OK" if connected else "MISSING"
            if not connected:
                issues.append(f"Connection Section {from_section} -> Section {to_section}: No navigation path found")

            connection_details.append({
                "from_section": from_section,
                "to_section": to_section,
                "expected": True,
                "actual": connected,
                "from_screen": connecting_screen,
                "to_screen": target_screen,
                "direction": direction_used,
                "status": status,
            })

    # Overall status
    overall_status = "PASS" if not issues else "FAIL"

    return {
        "chapter_num": chapter_num,
        "plan_summary": {
            "planned_sections": len(chapter_plan.sections),
            "total_planned_screens": chapter_plan.planned_screens,
        },
        "population_summary": {
            "sections_with_assignments": len(chapter_pop.screen_assignments),
            "total_assigned_screens": len(chapter_pop.assignments),
        },
        "section_details": section_details,
        "connection_details": connection_details,
        "overall_status": overall_status,
        "issues": issues,
    }


@app.get("/api/debug/spatial-analysis/{chapter_num}")
async def debug_spatial_analysis(chapter_num: int):
    """Analyze spatial layout of screens and detect grid conflicts.

    Builds a coordinate grid via BFS from the start screen, assigning
    (x, y) positions based on navigation direction. Detects when multiple
    screens from different sections occupy the same grid position.

    Returns:
        - screen_positions: Map of screen_idx -> (x, y)
        - position_screens: Map of (x, y) -> [screen_indices]
        - conflicts: Positions with multiple screens
        - section_grids: Per-section grid data for visualization
    """
    global _current_plan, _game_world

    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    # Import spatial analysis from validator
    from ..validation.validators.spatial_consistency import (
        SpatialConsistencyValidator,
        SpatialConsistencyConfig,
    )

    # Build screen -> section mapping
    screen_to_section: Dict[int, int] = {}
    section_screens: Dict[int, List[int]] = {}

    if _current_plan and _current_plan.world_population:
        chapter_pop = _current_plan.world_population.get_chapter(chapter_num)
        if chapter_pop:
            for section_id, screens in chapter_pop.screen_assignments.items():
                section_screens[section_id] = list(screens)
                for screen_idx in screens:
                    screen_to_section[screen_idx] = section_id

    # Run spatial analysis
    validator = SpatialConsistencyValidator(SpatialConsistencyConfig())
    analysis = validator.analyze_spatial_layout(chapter, screen_to_section)

    # Build per-section grid data for UI visualization
    section_grids = {}
    for section_id, screens in section_screens.items():
        section_positions = []
        for screen_idx in screens:
            if screen_idx in analysis.screen_positions:
                x, y = analysis.screen_positions[screen_idx]
                section_positions.append({
                    "screen_idx": screen_idx,
                    "x": x,
                    "y": y,
                })
        section_grids[section_id] = {
            "screen_count": len(screens),
            "positions": section_positions,
        }

    # Convert position_screens for JSON (tuple keys not allowed)
    position_screens_list = [
        {
            "position": [x, y],
            "screens": screens,
            "sections": list(set(screen_to_section.get(s, -1) for s in screens)),
            "is_conflict": len(screens) > 1 and len(set(screen_to_section.get(s, -1) for s in screens)) > 1,
        }
        for (x, y), screens in analysis.position_screens.items()
    ]

    # Convert screen_positions for JSON
    screen_positions_list = [
        {"screen_idx": idx, "x": pos[0], "y": pos[1], "section": screen_to_section.get(idx, -1)}
        for idx, pos in analysis.screen_positions.items()
    ]

    return {
        "chapter_num": chapter_num,
        "total_screens_mapped": analysis.total_screens_mapped,
        "grid_bounds": {
            "min_x": analysis.grid_bounds[0],
            "min_y": analysis.grid_bounds[1],
            "max_x": analysis.grid_bounds[2],
            "max_y": analysis.grid_bounds[3],
            "width": analysis.grid_bounds[2] - analysis.grid_bounds[0] + 1,
            "height": analysis.grid_bounds[3] - analysis.grid_bounds[1] + 1,
        },
        "screen_positions": screen_positions_list,
        "position_screens": position_screens_list,
        "conflicts": [
            {
                "position": [c.x, c.y],
                "screens": c.screens,
                "sections": c.sections,
            }
            for c in analysis.conflicts
        ],
        "conflict_count": len(analysis.conflicts),
        "section_grids": section_grids,
    }


# =============================================================================
# API Endpoints - Debug Changes (ROM-vs-vanilla structured diff)
# =============================================================================

def _screens_snapshot(buf: bytes) -> dict:
    """Parse ROM bytes into {ch -> {screen_index -> {field: value}}} for diffing."""
    import tempfile
    import os
    tmp = tempfile.NamedTemporaryFile(suffix=".nes", delete=False)
    try:
        tmp.write(buf)
        tmp.close()
        world = load_rom(tmp.name)
    finally:
        os.unlink(tmp.name)

    out: dict = {}
    for chapter_num in range(1, 6):
        chapter = world.chapters.get(chapter_num)
        if chapter is None:
            continue
        ch_map: dict = {}
        for screen in chapter.screens:
            ch_map[f"0x{screen.relative_index:02X}"] = {
                "content": screen.content,
                "objectset": screen.objectset,
                "datapointer": screen.datapointer,
                "top_tiles": screen.top_tiles,
                "bottom_tiles": screen.bottom_tiles,
                "nav_right": screen.screen_index_right,
                "nav_left": screen.screen_index_left,
                "nav_down": screen.screen_index_down,
                "nav_up": screen.screen_index_up,
            }
        out[f"ch{chapter_num}"] = ch_map
    return out


@app.get("/api/debug/changes")
async def debug_changes():
    """Authoritative ROM-vs-vanilla diff for the Debug tab change log."""
    from .debug_changes import build_changes
    rom, vanilla = _require_rom_pair()
    providers = [
        ("Screens", _screens_snapshot),
        ("Hero", _player_stats.read_player_stats),
        ("Inventory Caps", _inv_caps.read_caps),
        ("Experience Table", _exp_table.read_exp_table),
    ]
    return build_changes(rom, vanilla, providers)


@app.post("/api/apply")
async def apply_randomization(request: ApplyRequest):
    """Apply current plan to a ROM."""
    global _current_plan, _randomizer

    if _current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created yet")

    if _randomizer is None:
        _randomizer = Randomizer(get_default_config())

    input_path = Path(request.input_rom_path)
    output_path = Path(request.output_rom_path)

    if not input_path.exists():
        raise HTTPException(status_code=400, detail=f"Input ROM not found: {input_path}")

    try:
        result = _randomizer.apply(
            input_path,
            output_path,
            _current_plan,
            generate_spoiler=request.generate_spoiler,
        )

        return {
            "success": result.success,
            "seed": result.seed,
            "output_path": str(result.output_rom_path) if result.output_rom_path else None,
            "spoiler_path": str(result.spoiler_text_path) if result.spoiler_text_path else None,
            "rom_sha256": result.rom_sha256,
            "errors": result.errors,
            "warnings": result.warnings,
            "stats": result.stats,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =============================================================================
# API Endpoints - TileSection Preview
# =============================================================================

@app.get("/api/tiles/chr-groups/{chapter_num}")
async def get_chr_groups(chapter_num: int):
    """Get CHR group summary for a chapter.

    Shows which screens share graphics banks and can swap tiles.
    """
    if _current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    # We need a loaded ROM to get actual tile data
    # For now, return plan-based data
    chapter_plan = _current_plan.world_plan.get_chapter(chapter_num)
    if chapter_plan is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not in plan")

    # Return section-based grouping from plan
    sections = []
    for section in chapter_plan.sections:
        sections.append({
            "section_id": section.section_id,
            "section_type": section.section_type.name,
            "screen_count": section.target_screen_count,
            "can_swap": section.target_screen_count >= 2 and not section.preserve_original,
        })

    return {
        "chapter_num": chapter_num,
        "sections": sections,
        "note": "Full CHR group analysis requires loaded ROM data",
    }


@app.get("/api/tiles/preview/{chapter_num}")
async def preview_tile_swaps_endpoint(
    chapter_num: int,
    strategy: str = "basic",
    seed: Optional[int] = None,
):
    """Preview tile swaps for a chapter without applying them.

    Args:
        chapter_num: Chapter to preview
        strategy: "basic" or "terrain_aware"
        seed: Random seed (uses plan seed if not specified)
    """
    if _current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    # Use plan seed if not specified
    preview_seed = seed or _current_plan.seed

    # Return mock preview data (full implementation needs loaded ROM)
    chapter_plan = _current_plan.world_plan.get_chapter(chapter_num)
    if chapter_plan is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not in plan")

    return {
        "chapter_num": chapter_num,
        "strategy": strategy,
        "seed": preview_seed,
        "total_screens": chapter_plan.total_screens,
        "swappable_screens": sum(
            s.target_screen_count for s in chapter_plan.sections
            if not s.preserve_original
        ),
        "preserved_screens": sum(
            s.target_screen_count for s in chapter_plan.sections
            if s.preserve_original
        ),
        "note": "Full swap preview requires loaded ROM data",
    }


# =============================================================================
# API Endpoints - Tile Bank
# =============================================================================

@app.get("/api/rom/tilebank")
async def get_tile_bank():
    """Get the complete Tile Table (256 tiles, each 4 bytes).

    Returns all 256 tiles from ROM address 0x011B0B.
    Each tile consists of 4 MiniTile IDs forming a 2x2 grid:
    [TL, TR, BL, BR] = Top-Left, Top-Right, Bottom-Left, Bottom-Right
    """
    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    tiles = []
    for i in range(TILE_COUNT):
        offset = TILE_TABLE_ADDR + (i * TILE_SIZE)
        minitiles = list(_rom_data[offset:offset + TILE_SIZE])
        tiles.append({
            "index": i,
            "hex_index": f"0x{i:02X}",
            "minitiles": minitiles,  # [TL, TR, BL, BR]
            "rom_offset": f"0x{offset:05X}",
        })

    return {
        "rom_address": f"0x{TILE_TABLE_ADDR:05X}",
        "tile_count": TILE_COUNT,
        "bytes_per_tile": TILE_SIZE,
        "tiles": tiles,
    }


@app.get("/api/rom/tilebank/{tile_index}")
async def get_tile_bank_tile(tile_index: int):
    """Get a single tile from the Tile Table.

    Args:
        tile_index: Tile index (0-255)
    """
    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    if tile_index < 0 or tile_index >= TILE_COUNT:
        raise HTTPException(
            status_code=400,
            detail=f"Tile index must be 0-{TILE_COUNT - 1}, got {tile_index}"
        )

    offset = TILE_TABLE_ADDR + (tile_index * TILE_SIZE)
    minitiles = list(_rom_data[offset:offset + TILE_SIZE])

    return {
        "index": tile_index,
        "hex_index": f"0x{tile_index:02X}",
        "minitiles": minitiles,
        "rom_offset": f"0x{offset:05X}",
    }


@app.patch("/api/rom/tilebank/{tile_index}")
async def update_tile_bank_tile(tile_index: int, update: TileBankUpdate):
    """Update a tile's MiniTile IDs in the Tile Table.

    Args:
        tile_index: Tile index (0-255)
        update: New MiniTile IDs [TL, TR, BL, BR]
    """
    global _rom_data

    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    if tile_index < 0 or tile_index >= TILE_COUNT:
        raise HTTPException(
            status_code=400,
            detail=f"Tile index must be 0-{TILE_COUNT - 1}, got {tile_index}"
        )

    if len(update.minitiles) != TILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"Must provide exactly {TILE_SIZE} minitile IDs, got {len(update.minitiles)}"
        )

    # Validate each MiniTile ID is 0-255
    for i, val in enumerate(update.minitiles):
        if val < 0 or val > 255:
            raise HTTPException(
                status_code=400,
                detail=f"MiniTile ID at position {i} must be 0-255, got {val}"
            )

    # Convert to mutable bytearray and update
    offset = TILE_TABLE_ADDR + (tile_index * TILE_SIZE)
    rom_array = bytearray(_rom_data)
    for i, val in enumerate(update.minitiles):
        rom_array[offset + i] = val & 0xFF
    _rom_data = bytes(rom_array)

    return {
        "status": "updated",
        "index": tile_index,
        "hex_index": f"0x{tile_index:02X}",
        "minitiles": update.minitiles,
        "rom_offset": f"0x{offset:05X}",
    }


@app.get("/api/rom/tilebank/{tile_index}/render")
async def render_tile_from_chr(tile_index: int, chr: int = 0x0F, scale: int = 4):
    """Dynamically render a tile from ROM CHR data.

    This renders the tile by reading its minitile IDs from the Tile Table,
    then looking up and compositing the 8x8 patterns from CHR ROM.

    Args:
        tile_index: Tile index (0-255)
        chr: CHR bank index (0-63), default 0x0F (overworld)
        scale: Scale factor for output (1=16x16, 4=64x64), default 4
    """
    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    if tile_index < 0 or tile_index >= TILE_COUNT:
        raise HTTPException(
            status_code=400,
            detail=f"Tile index must be 0-{TILE_COUNT - 1}"
        )

    if chr < 0 or chr > 63:
        raise HTTPException(status_code=400, detail="CHR bank must be 0-63")

    try:
        from PIL import Image
        from io import BytesIO
    except ImportError:
        raise HTTPException(
            status_code=500,
            detail="PIL/Pillow not installed - required for tile rendering"
        )

    # NES ROM layout: 16-byte header + 128KB PRG + 128KB CHR
    # CHR ROM starts at offset 0x20010 (after header + PRG)
    CHR_ROM_START = 0x20010
    CHR_BANK_SIZE = 0x2000  # 8KB per bank
    PATTERN_SIZE = 16  # bytes per 8x8 pattern

    # Get the 4 minitile IDs for this tile
    tile_offset = TILE_TABLE_ADDR + (tile_index * TILE_SIZE)
    minitiles = list(_rom_data[tile_offset:tile_offset + TILE_SIZE])

    # Calculate CHR bank offset in ROM
    chr_offset = CHR_ROM_START + (chr * CHR_BANK_SIZE)

    # NES default grayscale palette
    PALETTE = [(0, 0, 0), (85, 85, 85), (170, 170, 170), (255, 255, 255)]

    def decode_pattern(pattern_index: int) -> list:
        """Decode an 8x8 NES pattern from CHR ROM."""
        addr = chr_offset + (pattern_index * PATTERN_SIZE)
        if addr + PATTERN_SIZE > len(_rom_data):
            return [[0] * 8 for _ in range(8)]  # Out of bounds

        plane0 = _rom_data[addr:addr + 8]
        plane1 = _rom_data[addr + 8:addr + 16]

        pixels = []
        for row in range(8):
            row_pixels = []
            for col in range(8):
                bit0 = (plane0[row] >> (7 - col)) & 1
                bit1 = (plane1[row] >> (7 - col)) & 1
                color_idx = bit0 | (bit1 << 1)
                row_pixels.append(PALETTE[color_idx])
            pixels.append(row_pixels)
        return pixels

    # Render the 4 minitiles into a 16x16 image
    img = Image.new('RGB', (16, 16), (0, 0, 0))
    positions = [(0, 0), (8, 0), (0, 8), (8, 8)]  # TL, TR, BL, BR

    for i, (mini_id, (x, y)) in enumerate(zip(minitiles, positions)):
        pattern = decode_pattern(mini_id)
        for py, row in enumerate(pattern):
            for px, color in enumerate(row):
                img.putpixel((x + px, y + py), color)

    # Scale up
    if scale > 1:
        img = img.resize((16 * scale, 16 * scale), Image.NEAREST)

    # Return as PNG
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)

    return Response(
        content=buffer.getvalue(),
        media_type="image/png",
        headers={"Cache-Control": "public, max-age=3600"}
    )


# =============================================================================
# API Endpoints - Shop Item Table (editable)
# =============================================================================

def _require_rom_pair() -> tuple[bytes, bytes]:
    """Return (current_rom, vanilla_rom). Lazily initializes the vanilla
    snapshot from current rom data if it wasn't captured at upload time
    (e.g., the server was reloaded after my upload-handler change).
    Raises HTTPException(400) if no ROM is loaded at all."""
    global _rom_vanilla
    if _rom_data is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    if _rom_vanilla is None:
        _rom_vanilla = _rom_data
    return _rom_data, _rom_vanilla


def _flush_screens(screens) -> int:
    """Serialize modified WorldScreen objects into the live _rom_data buffer.

    This keeps _rom_data the single source of truth: every screen mutation is
    written back to its WorldScreen file offset so /api/rom/patch can stream
    _rom_data directly. Returns the number of screens written.
    """
    global _rom_data
    if _rom_data is None:
        return 0
    rom_array = bytearray(_rom_data)
    count = 0
    for s in screens:
        off = CHAPTER_BASES[s.chapter] + s.relative_index * WORLDSCREEN_SIZE
        rom_array[off:off + WORLDSCREEN_SIZE] = s.to_bytes()
        count += 1
    _rom_data = bytes(rom_array)
    return count


@app.get("/api/rom/inventory-caps")
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


@app.patch("/api/rom/inventory-caps/{slot_index}")
async def update_inventory_cap(slot_index: int, update: InventoryCapUpdate):
    """Patch one inventory cap slot. Most edits target max_cap (byte 2)."""
    global _rom_data
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
    _rom_data = bytes(rom_array)
    return {"status": "updated", "slot": result}


# =============================================================================
# API Endpoints - Items registry (static metadata; two namespaces)
# =============================================================================

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


@app.get("/api/rom/items")
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


@app.get("/api/metadata/fields")
async def get_field_metadata():
    """Static field metadata: safety tiers, descriptions, enums, warnings.

    Drives the guided-editing UI and the 3-tier safety model. No ROM required.
    """
    return build_field_metadata()


# =============================================================================
# API Endpoints - EXP Tier Table (editable)
# =============================================================================

@app.get("/api/rom/exp-table")
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


@app.get("/api/rom/exp-table/usage")
async def get_exp_usage():
    """Static map of tier_index -> list of (chapter, screen_hex) using it."""
    return {"usage": _exp_table.EXP_USAGE}


@app.patch("/api/rom/exp-table/{index}")
async def update_exp_entry(index: int, update: ExpEntryUpdate):
    global _rom_data
    rom, vanilla = _require_rom_pair()

    rom_array = bytearray(rom)
    try:
        new_entry = _exp_table.write_exp_entry(rom_array, index, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)

    return {
        "status": "updated",
        "entry": new_entry,
        "vanilla": _exp_table.read_exp_entry(vanilla, index),
    }


# =============================================================================
# API Endpoints - Player Stats (editable)
# =============================================================================

@app.get("/api/rom/player-stats")
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


@app.get("/api/rom/player-stats/preview/{level}")
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


@app.get("/api/rom/player-stats/presets")
async def get_player_stats_presets():
    return {"presets": _player_stats.list_presets()}


@app.get("/api/rom/player-stats/damage-index/{index}/usage")
async def get_damage_index_usage(index: int):
    """Returns the levels (split by weapon) that currently resolve to this damage index."""
    rom, _ = _require_rom_pair()
    if not 0 <= index <= _player_stats.NIBBLE_MAX:
        raise HTTPException(status_code=400, detail=f"index must be 0..{_player_stats.NIBBLE_MAX}")
    return {"index": index, "usage": _player_stats.levels_using_damage_index(rom, index)}


@app.patch("/api/rom/player-stats/hp/{level}")
async def patch_player_hp(level: int, update: IntValueUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        new_value = _player_stats.write_hp(rom_array, level, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "field": "hp", "level": level, "value": new_value}


@app.patch("/api/rom/player-stats/sword-index/{level}")
async def patch_sword_index(level: int, update: IntValueUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        new_value = _player_stats.write_sword_index(rom_array, level, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "field": "sword_index", "level": level, "value": new_value}


@app.patch("/api/rom/player-stats/rod-index/{level}")
async def patch_rod_index(level: int, update: IntValueUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        new_value = _player_stats.write_rod_index(rom_array, level, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "field": "rod_index", "level": level, "value": new_value}


@app.patch("/api/rom/player-stats/damage-value/{index}")
async def patch_damage_value(index: int, update: IntValueUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        new_value = _player_stats.write_damage_value(rom_array, index, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {
        "status": "updated",
        "field": "damage_value",
        "index": index,
        "value": new_value,
        "cascade": _player_stats.levels_using_damage_index(_rom_data, index),
    }


@app.post("/api/rom/player-stats/preset")
async def apply_player_stats_preset(req: PlayerStatsPresetRequest):
    global _rom_data
    rom, vanilla = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        _player_stats.apply_preset(rom_array, vanilla, req.name)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "applied", "preset": req.name, "current": _player_stats.read_player_stats(_rom_data)}


@app.post("/api/rom/player-stats/transform")
async def apply_player_stats_transform(req: PlayerStatsTransformRequest):
    global _rom_data
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
    _rom_data = bytes(rom_array)
    return {"status": "applied", "current": _player_stats.read_player_stats(_rom_data)}


# =============================================================================
# API Endpoints - Enemies (battle roster + encounter lineups + per-screen groups)
# =============================================================================

@app.get("/api/rom/enemies")
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


@app.get("/api/rom/enemies/selectable")
async def get_selectable_enemies():
    """Canonical list of turn-based enemy IDs safe to offer in UI dropdowns.

    Returns every enemy from the static roster that is NOT in
    CONSERVATIVE_DANGER_ENEMY_IDS (excludes crash IDs 0x0B, 0x0C and
    dangerous/unknown variants 0x0F, 0x17, 0x25).  Does not require a loaded
    ROM — derived from the static enemy roster only.
    """
    return {"enemies": _enemy_selection.selectable_enemy_ids()}


@app.get("/api/rom/enemies/{enemy_id}/appearances")
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


@app.get("/api/rom/enemy-stats")
async def get_enemy_stats():
    rom, vanilla = _require_rom_pair()
    return {
        "stats": _enemy_stats.read_all_enemy_stats(rom),
        "vanilla": _enemy_stats.read_all_enemy_stats(vanilla),
        "id_range": [_enemy_stats.ENEMY_ID_FIRST, _enemy_stats.ENEMY_ID_LAST],
        "rom_offset": f"0x{_enemy_stats.ENEMY_STAT_TABLE:05X}",
    }


@app.patch("/api/rom/enemy-stats/{enemy_id}")
async def patch_enemy_stat(enemy_id: int, update: EnemyStatUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _enemy_stats.write_enemy_stat(
            rom_array, enemy_id, **update.model_dump(exclude_none=True)
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "stat": result}


# =============================================================================
# API Endpoints - Advanced page systems
#   Verified vs C:\...\GameAnalysis2\analysis_games\TMOS. Editable systems use
#   the standard _require_rom_pair -> bytearray -> mutate -> _rom_data pattern,
#   always returning a vanilla snapshot for diff highlighting. palette-colors
#   and level-caps are display-only (no confirmed ROM write target) -> GET only.
# =============================================================================

# --- Bosses (ROM_VERIFIED, safe) ---
@app.get("/api/rom/boss-stats")
async def get_boss_stats():
    rom, vanilla = _require_rom_pair()
    return {
        "stats": _boss_stats.read_all_boss_stats(rom),
        "vanilla": _boss_stats.read_all_boss_stats(vanilla),
        "boss_ids": list(_boss_stats.BOSS_IDS),
    }


@app.patch("/api/rom/boss-stats/{boss_id}")
async def patch_boss_stat(boss_id: str, update: BossStatUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _boss_stats.write_boss_stat(rom_array, boss_id, update.field, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "stat": result}


# --- Economy & Shops (shop slots = expert/DISASSEMBLY; trooper cost = safe) ---
@app.get("/api/rom/shop-economy")
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


@app.patch("/api/rom/shop-economy/{shop_index}/{slot_index}")
async def patch_shop_slot(shop_index: int, slot_index: int, update: ShopSlotUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _shop_economy.write_shop_slot(
            rom_array, shop_index, slot_index,
            item_code=update.item_code, base_price=update.base_price,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "slot": result}


@app.patch("/api/rom/trooper-cost")
async def patch_trooper_cost(update: TrooperCostUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _shop_economy.write_trooper_cost(rom_array, update.cost)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "trooper": result}


# --- Allies + Troopers roster (read-only) ---

@app.get("/api/rom/allies")
async def get_allies_roster():
    """Return the full ally roster with computed screen locations (read-only).

    Static metadata is ported from AlliesView.tsx KNOWN_ALLIES.  Screen
    locations are computed by scanning each ally's home chapter for screens
    whose content byte matches the ally's ContentType value.

    No ROM is strictly required: if no ROM is loaded the locations list for
    every ally will be empty but the static metadata is still returned.
    """
    return {"allies": _allies.get_allies(_game_world)}


@app.get("/api/rom/troopers")
async def get_troopers_roster():
    """Return trooper info with recruitment cost and screen locations (read-only).

    Trooper cost is read from the ROM (file offset 0x4577, vanilla = 100).
    Screen locations are the set of screens in any chapter whose content byte
    equals 0x7F (ContentType.TROOPERS).
    The cost is editable via the existing PATCH /api/rom/trooper-cost; this
    endpoint is read-only aggregation.
    """
    return _allies.get_troopers(_rom_data, _game_world)


# --- Overworld (real-time) enemy stats (HP editable, expert) ---
@app.get("/api/rom/overworld-enemy-stats")
async def get_overworld_enemy_stats():
    rom, vanilla = _require_rom_pair()
    return {
        "stats": _overworld_enemy_stats.read_all_overworld_enemy_stats(rom),
        "vanilla": _overworld_enemy_stats.read_all_overworld_enemy_stats(vanilla),
        "type_range": [_overworld_enemy_stats.TYPE_FIRST, _overworld_enemy_stats.TYPE_LAST],
        "chapter_count": _overworld_enemy_stats.CHAPTER_COUNT,
        "rom_offset": f"0x{_overworld_enemy_stats.OVERWORLD_HP_TABLE:05X}",
    }


@app.patch("/api/rom/overworld-enemy-stats/{enemy_type}")
async def patch_overworld_enemy_stat(enemy_type: int, update: OverworldHpUpdate):
    global _rom_data
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
    _rom_data = bytes(rom_array)
    return {"status": "updated", "stat": result}


# --- Turn-based combat damage tables (Expert) ---
@app.get("/api/rom/tb-damage-tables")
async def get_tb_damage_tables():
    rom, vanilla = _require_rom_pair()
    return {
        "tables": _tb_damage_tables.read_all_tables(rom),
        "vanilla": _tb_damage_tables.read_all_tables(vanilla),
        "tier": _tb_damage_tables.TIER,
    }


@app.patch("/api/rom/tb-damage-tables/{which}/{index}")
async def patch_tb_damage_entry(which: str, index: int, update: TbTableEntryUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _tb_damage_tables.write_table_entry(rom_array, which, index, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "table": result}


# --- Encounter rate tables (ramp + curve, Expert) ---
@app.get("/api/rom/encounter-rates")
async def get_encounter_rates():
    rom, vanilla = _require_rom_pair()
    return {
        "current": _encounter_rates.read_encounter_rates(rom),
        "vanilla": _encounter_rates.read_encounter_rates(vanilla),
        "tier": _encounter_rates.TIER,
    }


@app.patch("/api/rom/encounter-rates/{table}/{index}")
async def patch_encounter_rate(table: str, index: int, update: EncounterRateUpdate):
    global _rom_data
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
    _rom_data = bytes(rom_array)
    return {"status": "updated", "table": result}


# --- Weapon vs attack-object damage table (Expert) ---
@app.get("/api/rom/weapon-damage")
async def get_weapon_damage():
    rom, vanilla = _require_rom_pair()
    return {
        "table": _weapon_damage.read_table(rom),
        "vanilla": _weapon_damage.read_table(vanilla),
        "id_range": [_weapon_damage.ATTACK_ID_FIRST, _weapon_damage.ATTACK_ID_LAST],
        "writable_range": [_weapon_damage.WRITABLE_ID_FIRST, _weapon_damage.WRITABLE_ID_LAST],
        "rom_offset": f"0x{_weapon_damage.WEAPON_DAMAGE_TABLE:05X}",
    }


@app.patch("/api/rom/weapon-damage/{attack_id}")
async def patch_weapon_damage(attack_id: int, update: WeaponDamageUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _weapon_damage.write_table_entry(
            rom_array, attack_id,
            weapon_class=update.weapon_class, damage_base=update.damage_base,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "entry": result}


# --- Max-MP-per-level table (safe) ---
@app.get("/api/rom/mp-table")
async def get_mp_table():
    rom, vanilla = _require_rom_pair()
    return {
        "level_count": _mp_table.LEVEL_COUNT,
        "rom_offset": f"0x{_mp_table.MP_TABLE_OFFSET:05X}",
        "stride": _mp_table.MP_TABLE_STRIDE,
        "entries": _mp_table.read_mp_table(rom),
        "vanilla": _mp_table.read_mp_table(vanilla),
    }


@app.patch("/api/rom/mp-table/{level}")
async def patch_mp_entry(level: int, update: MpEntryUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _mp_table.write_mp_entry(rom_array, level, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "entry": result}


# --- Display-only systems (no confirmed ROM write target; GET only) ---
@app.get("/api/rom/palette-colors")
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


@app.get("/api/rom/level-caps")
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


@app.get("/api/rom/encounter-lineups")
async def get_all_encounter_lineups():
    rom, vanilla = _require_rom_pair()
    return {
        "current": _encounter_lineups.read_all_lineups(rom),
        "vanilla": _encounter_lineups.read_all_lineups(vanilla),
    }


@app.get("/api/rom/encounter-lineups/{chapter}")
async def get_chapter_encounter_lineups(chapter: int):
    rom, vanilla = _require_rom_pair()
    try:
        return {
            "current": _encounter_lineups.read_chapter_lineups(rom, chapter),
            "vanilla": _encounter_lineups.read_chapter_lineups(vanilla, chapter),
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.patch("/api/rom/encounter-lineups/{chapter}/{lineup_idx}/slots/{slot}")
async def patch_lineup_slot(chapter: int, lineup_idx: int, slot: int, update: LineupSlotUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _encounter_lineups.write_lineup_slot(
            rom_array, chapter, lineup_idx, slot, update.enemy_id
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "chapter": chapter, "lineup_index": lineup_idx, "result": result}


@app.patch("/api/rom/encounter-lineups/{chapter}/{lineup_idx}/start-byte")
async def patch_lineup_start_byte(chapter: int, lineup_idx: int, update: LineupStartByteUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _encounter_lineups.write_lineup_start_byte(rom_array, chapter, lineup_idx, update.value)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "start_byte": result}


@app.get("/api/rom/encounter-groups")
async def get_all_encounter_groups():
    rom, vanilla = _require_rom_pair()
    return {
        "current": _encounter_groups.read_all_groups(rom),
        "vanilla": _encounter_groups.read_all_groups(vanilla),
    }


@app.get("/api/rom/encounter-groups/{chapter}")
async def get_chapter_encounter_groups(chapter: int):
    rom, vanilla = _require_rom_pair()
    try:
        return {
            "current": _encounter_groups.read_chapter_groups(rom, chapter),
            "vanilla": _encounter_groups.read_chapter_groups(vanilla, chapter),
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/rom/encounter-groups/screen/{chapter}/{screen_index}")
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


@app.patch("/api/rom/encounter-groups/{chapter}/{entry_index}")
async def patch_encounter_group(chapter: int, entry_index: int, update: EncounterGroupUpdate):
    global _rom_data
    rom, _ = _require_rom_pair()
    rom_array = bytearray(rom)
    try:
        result = _encounter_groups.write_group_entry(
            rom_array, chapter, entry_index,
            screen=update.screen, monster_group=update.monster_group, flag=update.flag,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    _rom_data = bytes(rom_array)
    return {"status": "updated", "result": result}


# =============================================================================
# API Endpoints - Assets
# =============================================================================

# Asset paths (will be configured at startup)
ASSET_PATHS: Dict[str, Path] = {}


def configure_asset_paths(
    sprites_dir: Optional[Path] = None,
    tiles_dir: Optional[Path] = None,
    maps_dir: Optional[Path] = None,
):
    """Configure paths to game assets."""
    global ASSET_PATHS

    # Default paths relative to extracted-data.
    # __file__ = .../TMOS_AI/projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/server.py
    # 6 parents up = .../TMOS_AI/
    base = Path(__file__).parent.parent.parent.parent.parent.parent / "extracted-data"

    ASSET_PATHS["sprites"] = sprites_dir or (base / "images" / "sprites")
    ASSET_PATHS["maps"] = maps_dir or (base / "images" / "maps")
    ASSET_PATHS["enemies"] = base / "images" / "EncounterEnemyImages"
    ASSET_PATHS["overworld_enemies"] = base / "images" / "OverworldEnemyImages"
    ASSET_PATHS["bosses"] = base / "images" / "DemonImages"

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
        ASSET_PATHS["tiles"] = tiles_dir
    elif _packaged_tiles.exists():
        ASSET_PATHS["tiles"] = _packaged_tiles
    else:
        ASSET_PATHS["tiles"] = base / "images" / "TileImages"


@app.get("/api/assets/manifest")
async def get_asset_manifest():
    """Get manifest of available assets."""
    if not ASSET_PATHS:
        configure_asset_paths()

    # Initialize empty list for every configured asset type so we don't
    # KeyError on newer paths (enemies, overworld_enemies, bosses).
    manifest: Dict[str, List[Dict[str, str]]] = {k: [] for k in ASSET_PATHS}

    # Path segment per asset type for the served URL. Paths with underscores
    # use a hyphenated URL segment (matches the route definitions).
    URL_SEGMENT = {
        "sprites": "sprites",
        "tiles": "tiles",
        "maps": "maps",
        "enemies": "enemies",
        "overworld_enemies": "overworld-enemies",
        "bosses": "bosses",
    }

    # Scan directories
    for asset_type, path in ASSET_PATHS.items():
        if path.exists():
            for file in path.iterdir():
                if file.suffix.lower() in (".png", ".gif", ".jpg"):
                    manifest[asset_type].append({
                        "name": file.stem,
                        "filename": file.name,
                        "path": f"/api/assets/{URL_SEGMENT.get(asset_type, asset_type)}/{file.name}",
                    })

    return manifest


@app.get("/api/assets/sprites/{filename}")
async def get_sprite(filename: str):
    """Get a sprite image."""
    if not ASSET_PATHS:
        configure_asset_paths()

    file_path = ASSET_PATHS["sprites"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Sprite not found: {filename}")

    return FileResponse(file_path)


@app.get("/api/assets/enemies/{filename}")
async def get_enemy_image(filename: str):
    """Battle (encounter) enemy image."""
    if not ASSET_PATHS:
        configure_asset_paths()
    file_path = ASSET_PATHS["enemies"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Enemy image not found: {filename}")
    return FileResponse(file_path)


@app.get("/api/assets/overworld-enemies/{filename}")
async def get_overworld_enemy_image(filename: str):
    """Overworld (action-mode) enemy image."""
    if not ASSET_PATHS:
        configure_asset_paths()
    file_path = ASSET_PATHS["overworld_enemies"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Overworld enemy image not found: {filename}")
    return FileResponse(file_path)


@app.get("/api/assets/bosses/{filename}")
async def get_boss_image(filename: str):
    """Boss / demon image."""
    if not ASSET_PATHS:
        configure_asset_paths()
    file_path = ASSET_PATHS["bosses"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Boss image not found: {filename}")
    return FileResponse(file_path)


@app.get("/api/assets/tiles/{filename}")
async def get_tile(filename: str, chr: Optional[int] = None):
    """Get a tile image.

    Args:
        filename: The tile image filename (e.g., "00.png")
        chr: Optional CHR bank index for bank-specific tile graphics
    """
    if not ASSET_PATHS:
        configure_asset_paths()

    tiles_base = ASSET_PATHS["tiles"]
    file_path = None

    # If CHR bank specified, try to find a bank-specific version first
    if chr is not None:
        # Try CHR-specific directory: tiles/chr_0F/00.png
        chr_dir = tiles_base / f"chr_{chr:02X}"
        chr_file = chr_dir / filename
        if chr_file.exists():
            file_path = chr_file
        else:
            # Try alternate naming: tiles/00_chr0F.png
            base_name = filename.rsplit('.', 1)[0]
            ext = filename.rsplit('.', 1)[1] if '.' in filename else 'png'
            alt_file = tiles_base / f"{base_name}_chr{chr:02X}.{ext}"
            if alt_file.exists():
                file_path = alt_file

    # Fall back to default tile (no CHR bank suffix)
    if file_path is None:
        file_path = tiles_base / filename
        if not file_path.exists():
            raise HTTPException(status_code=404, detail=f"Tile not found: {filename}")

    # Return with cache headers - cache by chr param since URL includes it
    return FileResponse(
        file_path,
        headers={
            "Cache-Control": "public, max-age=3600",
            "Vary": "Accept-Encoding"
        }
    )


@app.get("/api/assets/maps/{filename}")
async def get_map(filename: str):
    """Get a map image."""
    if not ASSET_PATHS:
        configure_asset_paths()

    file_path = ASSET_PATHS["maps"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Map not found: {filename}")

    return FileResponse(file_path)


# =============================================================================
# Startup
# =============================================================================

_rom_env = os.environ.get("TMOS_DEFAULT_ROM", "")
if _rom_env:
    DEFAULT_ROM_PATH = Path(_rom_env)
else:
    # No env override: fall back to the project-local ROM if it exists.
    # Resolved relative to this file (portable) — restores zero-config local
    # startup without the hardcoded Windows path removed in 60505e3.
    # server.py -> .../<project>/src/tmos_randomizer/api/server.py (parents[3] = project root)
    _local_rom = Path(__file__).resolve().parents[3] / "TMOS_ORIGINAL.nes"
    DEFAULT_ROM_PATH = _local_rom if _local_rom.exists() else None


def _autoload_default_rom() -> None:
    """Load the configured default ROM into module state at startup.

    Set TMOS_DEFAULT_ROM=<path> to override, or set it to an empty string
    to disable auto-loading.
    """
    global _game_world, _rom_path, _rom_filename, _rom_data, _rom_vanilla, _screen_renderer

    if not DEFAULT_ROM_PATH or str(DEFAULT_ROM_PATH) == "":
        return
    if not DEFAULT_ROM_PATH.exists():
        print(f"  Default ROM not found at {DEFAULT_ROM_PATH} — skipping auto-load")
        return

    try:
        content = DEFAULT_ROM_PATH.read_bytes()
        _game_world = load_rom(DEFAULT_ROM_PATH)
        _rom_path = DEFAULT_ROM_PATH
        _rom_filename = DEFAULT_ROM_PATH.name
        _rom_data = content
        _rom_vanilla = content

        if RENDERING_AVAILABLE and ASSET_PATHS.get("tiles"):
            tiles_txt = ASSET_PATHS.get("tiles").parent / "DataFiles" / "tiles.txt"
            _screen_renderer = ScreenRenderer(
                _rom_data,
                str(ASSET_PATHS["tiles"]),
                str(tiles_txt) if tiles_txt.exists() else None,
            )

        print(
            f"  Auto-loaded ROM: {DEFAULT_ROM_PATH.name} "
            f"({len(content)} bytes, {len(list(_game_world))} chapters)"
        )
    except Exception as exc:
        print(f"  Failed to auto-load default ROM ({DEFAULT_ROM_PATH}): {exc}")


@app.on_event("startup")
async def startup():
    """Initialize on startup."""
    configure_asset_paths()
    print("TMOS Randomizer API started")
    print(f"  Sprites: {ASSET_PATHS.get('sprites')}")
    print(f"  Tiles: {ASSET_PATHS.get('tiles')}")
    print(f"  Maps: {ASSET_PATHS.get('maps')}")
    if DEFAULT_ROM_PATH and DEFAULT_ROM_PATH.exists():
        print(f"  Default ROM available at: {DEFAULT_ROM_PATH}")
        # Auto-load so a freshly-started backend has a ROM immediately (the UI
        # only calls /api/rom/status on mount, never /api/rom/load-default).
        _autoload_default_rom()


@app.post("/api/rom/load-default")
async def load_default_rom_endpoint():
    """Load the configured default ROM into in-memory state.

    Returns the same shape as /api/rom/upload so the UI can reuse the
    upload-success handling path.
    """
    if not DEFAULT_ROM_PATH or str(DEFAULT_ROM_PATH) == "":
        raise HTTPException(status_code=404, detail="No default ROM is configured")
    if not DEFAULT_ROM_PATH.exists():
        raise HTTPException(
            status_code=404,
            detail=f"Default ROM not found at {DEFAULT_ROM_PATH}",
        )
    _autoload_default_rom()
    if _game_world is None or _rom_data is None:
        raise HTTPException(status_code=500, detail="Failed to load default ROM")
    return {
        "status": "loaded",
        "filename": _rom_filename,
        "size": len(_rom_data),
        "checksum": "default-rom",
        "chapters": [
            {"chapter_num": ch.chapter_num, "screen_count": ch.screen_count}
            for ch in _game_world
        ],
        "rendering_available": RENDERING_AVAILABLE and _screen_renderer is not None,
    }


# =============================================================================
# CLI Entry Point
# =============================================================================

def run_server(host: str = "127.0.0.1", port: int = 8000):
    """Run the API server."""
    import uvicorn
    uvicorn.run(app, host=host, port=port)


if __name__ == "__main__":
    run_server()
