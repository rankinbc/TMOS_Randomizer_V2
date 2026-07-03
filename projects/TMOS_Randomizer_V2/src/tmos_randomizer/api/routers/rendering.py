"""Screen/TileSection rendering endpoints, section walkability/themes, tile previews."""

from __future__ import annotations

import logging
from typing import Optional

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import Response

from .. import state
from ..deps import _require_rom, _require_rom_data

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/api/rom/render/{chapter_num}/{screen_index}")
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
    _require_rom()

    if not state.RENDERING_AVAILABLE:
        raise HTTPException(status_code=501, detail="Rendering not available. Install Pillow: pip install Pillow")

    if state._screen_renderer is None:
        # Renderer is initialized at ROM-load time. If it's missing here the
        # practical cause is the same as "no ROM loaded" — surface it as the
        # same clean 400 the _game_world guard returns, not an opaque 500.
        raise HTTPException(status_code=400, detail="No ROM loaded")

    chapter = state._game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found in chapter {chapter_num}")

    try:
        # If the client didn't pass ws_color, fall back to the actual screen's value
        effective_ws_color = ws_color if ws_color is not None else screen.worldscreen_color
        # Render the screen
        image_bytes = state._screen_renderer.render_screen_to_bytes(
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


@router.get("/api/rom/tilesection/{index}")
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
    from ...core.constants import TILESECTION_COUNT

    if not state.RENDERING_AVAILABLE or state._screen_renderer is None:
        raise HTTPException(status_code=501, detail="Rendering not available")
    if index < 0 or index >= TILESECTION_COUNT:
        raise HTTPException(
            status_code=400,
            detail=f"section index must be 0-{TILESECTION_COUNT - 1}, got {index}",
        )
    try:
        image_bytes = state._screen_renderer.render_tilesection_to_bytes(
            index, chr_bank=chr, scale=scale, format='PNG', ws_color=ws_color
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Rendering failed: {e}")

    return Response(
        content=image_bytes,
        media_type="image/png",
        headers={"Cache-Control": "public, max-age=3600", "X-Section-Index": str(index)},
    )


@router.get("/api/rom/tilesection-walkability")
async def get_tilesection_walkability():
    """Intrinsic walkability signature for every global TileSection (0..470).

    Each value is a 32-char bitstring ('1'=walkable, '0'=blocking) over the
    section's 4 rows x 8 cols, row-major. Pure function of the ROM, cached.
    """
    _require_rom_data()

    key = id(state._rom_data)
    if state._ts_walk_cache is None or state._ts_walk_cache_key != key:
        from ...validation.tiles.edges import all_tilesection_walkability
        state._ts_walk_cache = all_tilesection_walkability(state._rom_data)
        state._ts_walk_cache_key = key

    return {"sections": state._ts_walk_cache}


@router.get("/api/rom/tilesection-themes")
async def get_tilesection_themes():
    """Biome ('overworld'/'town'/'dungeon'/'maze'/'special') for every global
    TileSection (0..470). Pure function of the loaded ROM, cached.
    """
    _require_rom()
    _require_rom_data()

    key = id(state._rom_data)
    if state._ts_theme_cache is None or state._ts_theme_cache_key != key:
        from ...validation.tiles.themes import compute_section_themes
        state._ts_theme_cache = compute_section_themes(state._game_world, state._rom_data)
        state._ts_theme_cache_key = key

    return {"themes": state._ts_theme_cache}


@router.get("/api/rom/objectset/{chapter_num}/{objectset_id}/enemies")
async def get_objectset_enemies(chapter_num: int, objectset_id: int):
    """Return the enemies an ObjectSet spawns, with sprite filenames (read-only)."""
    from ...core.overworld_enemies import parse_objectset_enemy_types, enemy_info

    _require_rom_data()
    if objectset_id < 0 or objectset_id > 255:
        raise HTTPException(status_code=400, detail="objectset_id must be 0-255")

    types = parse_objectset_enemy_types(state._rom_data, chapter_num, objectset_id)
    enemies = []
    for t in types:
        info = enemy_info(t)
        enemies.append({"type": t, "name": info["name"], "image": info["image"]})
    return {"chapter": chapter_num, "objectset_id": objectset_id, "enemies": enemies}


@router.get("/api/rom/render/status")
async def get_render_status():
    """Check if screen rendering is available."""
    return {
        "rendering_available": state.RENDERING_AVAILABLE,
        "renderer_initialized": state._screen_renderer is not None,
        "rom_loaded": state._rom_data is not None,
        "tile_images_path": str(state.ASSET_PATHS.get("tiles")) if state.ASSET_PATHS.get("tiles") else None,
    }


# =============================================================================
# API Endpoints - TileSection Preview
# =============================================================================

@router.get("/api/tiles/chr-groups/{chapter_num}")
async def get_chr_groups(chapter_num: int):
    """Get CHR group summary for a chapter.

    Shows which screens share graphics banks and can swap tiles.
    """
    if state._current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    # We need a loaded ROM to get actual tile data
    # For now, return plan-based data
    chapter_plan = state._current_plan.world_plan.get_chapter(chapter_num)
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


@router.get("/api/tiles/preview/{chapter_num}")
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
    if state._current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    # Use plan seed if not specified
    preview_seed = seed or state._current_plan.seed

    # Return mock preview data (full implementation needs loaded ROM)
    chapter_plan = state._current_plan.world_plan.get_chapter(chapter_num)
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
