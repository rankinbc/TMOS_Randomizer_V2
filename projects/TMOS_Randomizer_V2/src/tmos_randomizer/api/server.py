"""FastAPI server for TMOS Randomizer UI backend.

Provides REST API endpoints for:
- Creating and previewing randomization plans
- Applying randomization to ROMs
- Serving game assets (sprites, tiles, maps)

Usage:
    uvicorn tmos_randomizer.api.server:app --reload --port 8000

Or via CLI:
    python -m tmos_randomizer serve --port 8000

This module is the composition root: endpoints live in api/routers/*, shared
helpers in api/deps.py, and all mutable app state in api/state.py. Legacy
names (``configure_asset_paths``, ``_autoload_default_rom``, the Pydantic
schemas, ``RENDERING_AVAILABLE``) are re-exported here for compatibility.
"""

from __future__ import annotations

import logging
import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import state
from .deps import configure_asset_paths, configure_logging  # noqa: F401 — re-exported
from .routers import (
    assets,
    debug,
    economy,
    enemies,
    items,
    plan,
    player_stats,
    rendering,
    rom,
    screens,
    tilebank,
)
from .routers.rom import _autoload_default_rom  # noqa: F401 — re-exported

# Module-level logger.
logger = logging.getLogger(__name__)

# Re-exported for compatibility (rendering availability flag).
RENDERING_AVAILABLE = state.RENDERING_AVAILABLE


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


# =============================================================================
# Pydantic Models — moved to schemas.py; re-exported here for compatibility.
# =============================================================================

from .schemas import (  # noqa: E402,F401
    ApplyRequest,
    BossStatUpdate,
    ConfigUpdate,
    EncounterGroupUpdate,
    EncounterRateUpdate,
    EnemyStatUpdate,
    ExpEntryUpdate,
    IntValueUpdate,
    InventoryCapUpdate,
    LineupSlotUpdate,
    LineupStartByteUpdate,
    MpEntryUpdate,
    NavigationUpdate,
    OverworldHpUpdate,
    PlanRequest,
    PlayerStatsPresetRequest,
    PlayerStatsTransformRequest,
    ScreenFieldsUpdate,
    ShopSlotUpdate,
    TbTableEntryUpdate,
    TileBankUpdate,
    TileSectionUpdate,
    TrooperCostUpdate,
    WeaponDamageUpdate,
)


@app.get("/")
async def root():
    """API root - returns status."""
    return {
        "name": "TMOS Randomizer API",
        "version": "2.0.0",
        "status": "running",
        "has_plan": state._current_plan is not None,
        "rom_loaded": state._game_world is not None,
        "rom_filename": state._rom_filename,
    }


# Routers (paths unchanged from the original monolith).
app.include_router(rom.router)
app.include_router(screens.router)
app.include_router(rendering.router)
app.include_router(tilebank.router)
app.include_router(plan.router)
app.include_router(debug.router)
app.include_router(items.router)
app.include_router(player_stats.router)
app.include_router(enemies.router)
app.include_router(economy.router)
app.include_router(assets.router)


# =============================================================================
# Startup
# =============================================================================

@app.on_event("startup")
async def startup():
    """Initialize on startup."""
    configure_logging()
    configure_asset_paths()
    print("TMOS Randomizer API started")
    print(f"  Sprites: {state.ASSET_PATHS.get('sprites')}")
    print(f"  Tiles: {state.ASSET_PATHS.get('tiles')}")
    print(f"  Maps: {state.ASSET_PATHS.get('maps')}")
    if rom.DEFAULT_ROM_PATH and rom.DEFAULT_ROM_PATH.exists():
        print(f"  Default ROM available at: {rom.DEFAULT_ROM_PATH}")
        # Auto-load so a freshly-started backend has a ROM immediately (the UI
        # only calls /api/rom/status on mount, never /api/rom/load-default).
        _autoload_default_rom()


# =============================================================================
# CLI Entry Point
# =============================================================================

def run_server(host: str = "127.0.0.1", port: int = 8000):
    """Run the API server."""
    import uvicorn
    uvicorn.run(app, host=host, port=port)


if __name__ == "__main__":
    run_server()
