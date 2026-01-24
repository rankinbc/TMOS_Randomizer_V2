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

import logging
import os
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

from ..randomizer import Randomizer, RandomizationPlan, RandomizationResult, preview_randomization
from ..io.config_loader import RandomizerConfig, get_default_config
from ..io.rom_reader import ROMReader, load_rom
from ..core.chapter import Chapter, GameWorld
from ..core.constants import get_chr_index, TILE_TABLE_ADDR, TILE_COUNT, TILE_SIZE
from ..core.enums import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
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

# CORS for local development - allow all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins in development
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
_rom_data: Optional[bytes] = None  # Raw ROM bytes for rendering
_screen_renderer: Optional[Any] = None  # ScreenRenderer instance


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


class TileBankUpdate(BaseModel):
    """Request to update a tile's MiniTile IDs."""
    minitiles: List[int]  # [TL, TR, BL, BR], each 0-255


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
    global _game_world, _rom_path, _rom_filename, _rom_data, _screen_renderer

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
        _rom_data = content  # Store raw bytes for rendering

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
            "global_index": screen.global_index,
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
        "global_index": screen.global_index,
        "chapter_num": chapter_num,
        "datapointer": screen.datapointer,
        "chr_index": get_chr_index(screen.datapointer),
        "top_tiles": screen.top_tiles,
        "bottom_tiles": screen.bottom_tiles,
        "objectset": screen.objectset,
        "parent_world": screen.parent_world,
        "event": screen.event,
        "content": screen.content,
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

    # Return updated screen data for all modified screens
    result = []
    for idx in modified_screens:
        s = chapter.get_screen(idx)
        if s:
            result.append({
                "index": s.relative_index,
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


# =============================================================================
# API Endpoints - Screen Rendering
# =============================================================================

@app.get("/api/rom/render/{chapter_num}/{screen_index}")
async def render_screen(
    chapter_num: int,
    screen_index: int,
    scale: int = Query(default=4, ge=1, le=8),
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
        raise HTTPException(status_code=500, detail="Screen renderer not initialized")

    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found in chapter {chapter_num}")

    try:
        # Render the screen
        image_bytes = _screen_renderer.render_screen_to_bytes(
            top_tiles=screen.top_tiles,
            bottom_tiles=screen.bottom_tiles,
            datapointer=screen.datapointer,
            scale=scale,
            format='PNG'
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
        raise HTTPException(status_code=500, detail=f"Rendering failed: {str(e)}")


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


logger = logging.getLogger(__name__)

@app.post("/api/plan/apply-preview")
async def apply_plan_preview():
    """Apply the current plan to the in-memory game world for preview.

    This modifies the in-memory ROM data so that /api/rom/chapter endpoints
    return the randomized world. Does NOT write to disk.
    """
    global _current_plan, _game_world, _randomizer

    logger.info("="*60)
    logger.info("APPLY_PLAN_PREVIEW called")
    logger.info("="*60)

    if _current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created yet")

    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

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
        # Import the phase functions
        from ..phases.phase4_population import populate_world
        from ..phases.phase5_navigation import rewrite_world_navigation

        logger.info("")
        logger.info("--- PHASE 4: Population ---")
        # Phase 4: Population - Assign screens to sections
        world_population = populate_world(
            game_world=_game_world,
            world_plan=_current_plan.world_plan,
            world_shape=_current_plan.world_shape,
            seed=_current_plan.seed,
        )
        _current_plan.world_population = world_population

        # Log population results
        for chapter_pop in world_population.chapters:
            logger.info(f"  Chapter {chapter_pop.chapter_num}: {len(chapter_pop.assignments)} assignments")
            for section_id, screens in chapter_pop.screen_assignments.items():
                logger.info(f"    Section {section_id}: {len(screens)} screens assigned -> {screens}")

        logger.info("")
        logger.info("--- PHASE 5: Navigation ---")
        # Phase 5: Navigation - Rewrite screen navigation
        world_navigation = rewrite_world_navigation(
            game_world=_game_world,
            world_shape=_current_plan.world_shape,
            world_connections=_current_plan.world_connections,
            world_population=world_population,
            seed=_current_plan.seed,
            preserve_buildings=True,
        )
        _current_plan.world_navigation = world_navigation

        # Count modifications
        modified_count = 0
        for chapter_nav in world_navigation.chapters:
            modified_screens = set()
            for change in chapter_nav.navigation_changes:
                modified_screens.add(change.screen_index)
            for stairway in chapter_nav.stairway_changes:
                modified_screens.add(stairway.screen_a)
                modified_screens.add(stairway.screen_b)
            modified_count += len(modified_screens)

        return {
            "status": "applied",
            "seed": _current_plan.seed,
            "screens_modified": modified_count,
            "chapters": [
                {
                    "chapter_num": ch.chapter_num,
                    "screen_count": ch.screen_count,
                }
                for ch in _game_world
            ],
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to apply preview: {str(e)}")


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

        for assignment in chapter_pop.assignments:
            screen_sections[assignment.real_screen_index] = {
                "section_id": assignment.section_id,
                "local_id": assignment.local_id,
                "section_type": assignment.original_section_type.name if hasattr(assignment.original_section_type, 'name') else str(assignment.original_section_type),
            }

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

    # Group screens by section
    sections = {}
    for assignment in chapter_pop.assignments:
        section_id = assignment.section_id
        if section_id not in sections:
            sections[section_id] = {
                "section_id": section_id,
                "section_type": assignment.original_section_type.name if hasattr(assignment.original_section_type, 'name') else str(assignment.original_section_type),
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

    # Default paths relative to extracted-data
    base = Path(__file__).parent.parent.parent.parent.parent / "extracted-data"

    ASSET_PATHS["sprites"] = sprites_dir or (base / "images" / "sprites")
    ASSET_PATHS["maps"] = maps_dir or (base / "images" / "maps")

    # Tiles are in temp folder from github clone
    temp_base = base.parent / "temp" / "github-clones" / "TMOS_Romhack1"
    ASSET_PATHS["tiles"] = tiles_dir or (temp_base / "Images" / "TileImages")


@app.get("/api/assets/manifest")
async def get_asset_manifest():
    """Get manifest of available assets."""
    if not ASSET_PATHS:
        configure_asset_paths()

    manifest = {
        "sprites": [],
        "tiles": [],
        "maps": [],
    }

    # Scan directories
    for asset_type, path in ASSET_PATHS.items():
        if path.exists():
            for file in path.iterdir():
                if file.suffix.lower() in (".png", ".gif", ".jpg"):
                    manifest[asset_type].append({
                        "name": file.stem,
                        "filename": file.name,
                        "path": f"/api/assets/{asset_type}/{file.name}",
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


@app.get("/api/assets/tiles/{filename}")
async def get_tile(filename: str):
    """Get a tile image."""
    if not ASSET_PATHS:
        configure_asset_paths()

    file_path = ASSET_PATHS["tiles"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Tile not found: {filename}")

    return FileResponse(file_path)


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

@app.on_event("startup")
async def startup():
    """Initialize on startup."""
    configure_asset_paths()
    print("TMOS Randomizer API started")
    print(f"  Sprites: {ASSET_PATHS.get('sprites')}")
    print(f"  Tiles: {ASSET_PATHS.get('tiles')}")
    print(f"  Maps: {ASSET_PATHS.get('maps')}")


# =============================================================================
# CLI Entry Point
# =============================================================================

def run_server(host: str = "127.0.0.1", port: int = 8000):
    """Run the API server."""
    import uvicorn
    uvicorn.run(app, host=host, port=port)


if __name__ == "__main__":
    run_server()
