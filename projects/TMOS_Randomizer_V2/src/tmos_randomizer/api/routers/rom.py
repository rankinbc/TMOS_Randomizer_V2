"""ROM loading endpoints: upload, status, default-ROM autoload."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path

from fastapi import APIRouter, HTTPException, UploadFile, File

from .. import state
from ...io.rom_reader import ROMReader, load_rom

router = APIRouter()


# =============================================================================
# Default ROM resolution
# =============================================================================

_rom_env = os.environ.get("TMOS_DEFAULT_ROM", "")
if _rom_env:
    DEFAULT_ROM_PATH = Path(_rom_env)
else:
    # No env override: fall back to the project-local ROM if it exists.
    # Resolved relative to this file (portable) — restores zero-config local
    # startup without the hardcoded Windows path removed in 60505e3.
    # rom.py -> .../<project>/src/tmos_randomizer/api/routers/rom.py
    # (parents[4] = project root)
    _local_rom = Path(__file__).resolve().parents[4] / "TMOS_ORIGINAL.nes"
    DEFAULT_ROM_PATH = _local_rom if _local_rom.exists() else None


def _autoload_default_rom() -> None:
    """Load the configured default ROM into module state at startup.

    Set TMOS_DEFAULT_ROM=<path> to override, or set it to an empty string
    to disable auto-loading.
    """
    if not DEFAULT_ROM_PATH or str(DEFAULT_ROM_PATH) == "":
        return
    if not DEFAULT_ROM_PATH.exists():
        print(f"  Default ROM not found at {DEFAULT_ROM_PATH} — skipping auto-load")
        return

    try:
        content = DEFAULT_ROM_PATH.read_bytes()
        state._game_world = load_rom(DEFAULT_ROM_PATH)
        state._rom_path = DEFAULT_ROM_PATH
        state._rom_filename = DEFAULT_ROM_PATH.name
        state._rom_data = content
        state._rom_vanilla = content

        if state.RENDERING_AVAILABLE and state.ASSET_PATHS.get("tiles"):
            tiles_txt = state.ASSET_PATHS.get("tiles").parent / "DataFiles" / "tiles.txt"
            state._screen_renderer = state.ScreenRenderer(
                state._rom_data,
                str(state.ASSET_PATHS["tiles"]),
                str(tiles_txt) if tiles_txt.exists() else None,
            )

        print(
            f"  Auto-loaded ROM: {DEFAULT_ROM_PATH.name} "
            f"({len(content)} bytes, {len(list(state._game_world))} chapters)"
        )
    except Exception as exc:
        print(f"  Failed to auto-load default ROM ({DEFAULT_ROM_PATH}): {exc}")


# =============================================================================
# API Endpoints - ROM Loading
# =============================================================================

@router.post("/api/rom/upload")
async def upload_rom(file: UploadFile = File(...)):
    """Upload a ROM file for editing/randomization."""
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
        state._game_world = load_rom(temp_path)
        state._rom_path = temp_path
        state._rom_filename = file.filename
        state._rom_data = content  # Mutable working copy
        state._rom_vanilla = content  # Immutable snapshot for diff comparisons

        # Initialize screen renderer if available
        if state.RENDERING_AVAILABLE and state.ASSET_PATHS.get("tiles"):
            tiles_txt = state.ASSET_PATHS.get("tiles").parent / "DataFiles" / "tiles.txt"
            state._screen_renderer = state.ScreenRenderer(
                state._rom_data,
                str(state.ASSET_PATHS["tiles"]),
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
                for ch in state._game_world
            ],
            "rendering_available": state.RENDERING_AVAILABLE and state._screen_renderer is not None,
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to load ROM: {str(e)}")


@router.get("/api/rom/status")
async def get_rom_status():
    """Get current ROM loading status."""
    if state._game_world is None:
        return {
            "loaded": False,
            "filename": None,
            "chapters": [],
        }

    return {
        "loaded": True,
        "filename": state._rom_filename,
        "chapters": [
            {
                "chapter_num": ch.chapter_num,
                "screen_count": ch.screen_count,
            }
            for ch in state._game_world
        ],
    }


@router.post("/api/rom/load-default")
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
    if state._game_world is None or state._rom_data is None:
        raise HTTPException(status_code=500, detail="Failed to load default ROM")
    return {
        "status": "loaded",
        "filename": state._rom_filename,
        "size": len(state._rom_data),
        "checksum": "default-rom",
        "chapters": [
            {"chapter_num": ch.chapter_num, "screen_count": ch.screen_count}
            for ch in state._game_world
        ],
        "rendering_available": state.RENDERING_AVAILABLE and state._screen_renderer is not None,
    }
