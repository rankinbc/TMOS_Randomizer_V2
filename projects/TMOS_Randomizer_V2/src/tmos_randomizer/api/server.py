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

    from ..testing.validators import (
        validate_navigation_integrity,
        validate_time_period_boundaries,
        find_time_door_screens,
        run_all_chapter_validators,
        IssueSeverity,
    )
    from ..core.enums import get_time_period_for_screen, PAST_SCREEN_INDICES

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

        all_issues = []

        # If plan is applied, run all validators
        if _current_plan is not None:
            chapter_plan = _current_plan.world_plan.get_chapter(chapter_num)
            chapter_shape = _current_plan.world_shape.get_chapter(chapter_num)
            chapter_connections = _current_plan.world_connections.get_chapter(chapter_num)
            chapter_population = getattr(_current_plan, 'world_population', None)

            if chapter_population:
                chapter_pop = chapter_population.get_chapter(chapter_num)
            else:
                chapter_pop = None

            if chapter_plan and chapter_pop:
                # Get time doors for this chapter
                time_door_screens = find_time_door_screens(chapter)

                # Run all validators
                all_issues = run_all_chapter_validators(
                    chapter=chapter,
                    chapter_plan=chapter_plan,
                    chapter_population=chapter_pop,
                    chapter_connections=chapter_connections,
                    rom_data=_rom_data,
                    time_door_screens=time_door_screens,
                )

                # Add metrics
                chapter_result["metrics"]["section_count_planned"] = len(chapter_plan.sections)
                chapter_result["metrics"]["section_count_assigned"] = len([
                    s for s in chapter_plan.sections
                    if len(chapter_pop.screen_assignments.get(s.section_id, [])) > 0
                ])
        else:
            # No plan - just run basic validators
            nav_issues = validate_navigation_integrity(chapter)
            time_issues = validate_time_period_boundaries(chapter)
            all_issues = nav_issues + time_issues

        # Categorize issues
        for issue in all_issues:
            issue_dict = issue.to_dict() if hasattr(issue, 'to_dict') else {
                "severity": issue.severity.value,
                "category": issue.category,
                "message": issue.message,
                "requirement": getattr(issue, 'requirement', None),
            }

            if issue.severity == IssueSeverity.ERROR:
                chapter_result["errors"].append(issue_dict)
                # Track error breakdown by requirement
                req = getattr(issue, 'requirement', 'unknown')
                if req not in results["summary"]["error_breakdown"]:
                    results["summary"]["error_breakdown"][req] = 0
                results["summary"]["error_breakdown"][req] += 1
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
        time_doors = find_time_door_screens(chapter)
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

    # Tiles are in temp folder from github clone (need to go up one more level from projects/)
    temp_base = base.parent.parent / "temp" / "github-clones" / "TMOS_Romhack1"
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
