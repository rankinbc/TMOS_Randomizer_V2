"""Chapter/screen read endpoints and live screen editing (navigation, tiles, fields)."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path

from fastapi import APIRouter, HTTPException

from .. import state
from ..deps import _require_rom, _require_rom_data, _screen_api_dict, _flush_screens
from ..schemas import NavigationUpdate, ScreenFieldsUpdate, TileSectionUpdate
from ...io.rom_reader import load_rom
from ...core.constants import get_chr_index
from ...core.enums import is_past_screen_index
from ...logic.navigation import connect_screens, disconnect_screens

router = APIRouter()


@router.get("/api/rom/chapter/{chapter_num}")
async def get_chapter_data(chapter_num: int):
    """Get all screen data for a chapter."""
    _require_rom()

    chapter = state._game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screens = [_screen_api_dict(chapter_num, screen) for screen in chapter]

    return {
        "chapter_num": chapter_num,
        "screen_count": chapter.screen_count,
        "screens": screens,
    }


@router.get("/api/rom/screen/{chapter_num}/{screen_index}")
async def get_screen_data(chapter_num: int, screen_index: int):
    """Get detailed data for a single screen."""
    _require_rom()

    chapter = state._game_world.chapters.get(chapter_num)
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


@router.get("/api/rom/navigation/{chapter_num}")
async def get_chapter_navigation(chapter_num: int):
    """Get navigation graph for a chapter."""
    _require_rom()

    chapter = state._game_world.chapters.get(chapter_num)
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


@router.get("/api/rom/chapter/{chapter_num}/edge-walkability")
async def get_chapter_edge_walkability(chapter_num: int):
    """Per-screen booleans flagging which edges are fully non-walkable.

    For each screen, returns whether each of its 4 edges (top/bottom/left/right)
    consists entirely of non-walkable tiles (collidable or deadly). True means
    the player cannot exit through that edge.
    """
    _require_rom()
    _require_rom_data()

    chapter = state._game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    from ...validation.tiles.edges import extract_edges
    from ...validation.tiles.categories import is_walkable

    screens: dict[str, dict[str, bool]] = {}
    for screen in chapter:
        try:
            edges = extract_edges(
                state._rom_data,
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


@router.patch("/api/rom/screen/{chapter_num}/{screen_index}/navigation")
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
    _require_rom()

    chapter = state._game_world.chapters.get(chapter_num)
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
            result.append(_screen_api_dict(chapter_num, s))

    return {
        "status": "updated",
        "modified_count": len(modified_screens),
        "screens": result,
    }


@router.patch("/api/rom/screen/{chapter_num}/{screen_index}/tiles")
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
    from ...core.constants import TILESECTION_COUNT, get_chr_index
    from ...logic.tilesection_bank import resolve_tile_update

    _require_rom()
    chapter = state._game_world.chapters.get(chapter_num)
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
        "screen": _screen_api_dict(chapter_num, screen),
    }


@router.patch("/api/rom/screen/{chapter_num}/{screen_index}/fields")
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
    from ...core.constants import get_chr_index

    _require_rom()
    chapter = state._game_world.chapters.get(chapter_num)
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
        "screen": _screen_api_dict(chapter_num, screen),
    }


@router.get("/api/rom/screen/{chapter_num}/{screen_index}/vanilla")
async def get_screen_vanilla(chapter_num: int, screen_index: int):
    """Return a screen's original (as-uploaded) field values, for change comparison.

    Returns the screen's original field values (the same ~18 keys as the live
    screen endpoint, including ``index`` and ``global_index``), parsed from the
    pristine ROM rather than the (possibly mutated) live world.
    """
    if state._rom_vanilla is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")

    # Parse the pristine snapshot independently of the (mutated) live world.
    # Edits only ever touch the in-memory _game_world/_rom_data; the file at
    # _rom_path is the as-uploaded ROM and is never mutated, so re-parsing it
    # yields pristine data (same established pattern as _baseline_reachability).
    if state._rom_path is not None and Path(state._rom_path).exists():
        vanilla_world = load_rom(state._rom_path)
    else:
        # Fallback: _rom_path is gone; load from the immutable bytes snapshot
        # via a unique temp file that is always cleaned up.
        tmp = tempfile.NamedTemporaryFile(suffix=".nes", delete=False)
        try:
            tmp.write(state._rom_vanilla)
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
    return _screen_api_dict(chapter_num, s)


@router.get("/api/rom/tiles/{chapter_num}/{screen_index}")
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
    _require_rom()

    _require_rom_data()

    if state.build_screen_tile_grid is None:
        raise HTTPException(status_code=501, detail="Tile grid function not available. Install rendering module.")

    chapter = state._game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")

    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found in chapter {chapter_num}")

    try:
        # Build the 8x6 tile grid
        tile_grid = state.build_screen_tile_grid(
            state._rom_data,
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
