"""Static asset endpoints: manifest plus sprite/tile/map/enemy/boss images."""

from __future__ import annotations

from typing import Dict, List, Optional

from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse

from .. import state
from ..deps import configure_asset_paths

router = APIRouter()


@router.get("/api/assets/manifest")
async def get_asset_manifest():
    """Get manifest of available assets."""
    if not state.ASSET_PATHS:
        configure_asset_paths()

    # Initialize empty list for every configured asset type so we don't
    # KeyError on newer paths (enemies, overworld_enemies, bosses).
    manifest: Dict[str, List[Dict[str, str]]] = {k: [] for k in state.ASSET_PATHS}

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
    for asset_type, path in state.ASSET_PATHS.items():
        if path.exists():
            for file in path.iterdir():
                if file.suffix.lower() in (".png", ".gif", ".jpg"):
                    manifest[asset_type].append({
                        "name": file.stem,
                        "filename": file.name,
                        "path": f"/api/assets/{URL_SEGMENT.get(asset_type, asset_type)}/{file.name}",
                    })

    return manifest


@router.get("/api/assets/sprites/{filename}")
async def get_sprite(filename: str):
    """Get a sprite image."""
    if not state.ASSET_PATHS:
        configure_asset_paths()

    file_path = state.ASSET_PATHS["sprites"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Sprite not found: {filename}")

    return FileResponse(file_path)


@router.get("/api/assets/enemies/{filename}")
async def get_enemy_image(filename: str):
    """Battle (encounter) enemy image."""
    if not state.ASSET_PATHS:
        configure_asset_paths()
    file_path = state.ASSET_PATHS["enemies"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Enemy image not found: {filename}")
    return FileResponse(file_path)


@router.get("/api/assets/overworld-enemies/{filename}")
async def get_overworld_enemy_image(filename: str):
    """Overworld (action-mode) enemy image."""
    if not state.ASSET_PATHS:
        configure_asset_paths()
    file_path = state.ASSET_PATHS["overworld_enemies"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Overworld enemy image not found: {filename}")
    return FileResponse(file_path)


@router.get("/api/assets/bosses/{filename}")
async def get_boss_image(filename: str):
    """Boss / demon image."""
    if not state.ASSET_PATHS:
        configure_asset_paths()
    file_path = state.ASSET_PATHS["bosses"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Boss image not found: {filename}")
    return FileResponse(file_path)


@router.get("/api/assets/tiles/{filename}")
async def get_tile(filename: str, chr: Optional[int] = None):
    """Get a tile image.

    Args:
        filename: The tile image filename (e.g., "00.png")
        chr: Optional CHR bank index for bank-specific tile graphics
    """
    if not state.ASSET_PATHS:
        configure_asset_paths()

    tiles_base = state.ASSET_PATHS["tiles"]
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


@router.get("/api/assets/maps/{filename}")
async def get_map(filename: str):
    """Get a map image."""
    if not state.ASSET_PATHS:
        configure_asset_paths()

    file_path = state.ASSET_PATHS["maps"] / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail=f"Map not found: {filename}")

    return FileResponse(file_path)
