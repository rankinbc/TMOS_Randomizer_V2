"""Tile Table (tilebank) endpoints: read, edit, and render individual tiles."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException
from fastapi.responses import Response

from .. import state
from ..deps import _require_rom_data
from ..schemas import TileBankUpdate
from ...core.constants import TILE_TABLE_ADDR, TILE_COUNT, TILE_SIZE

router = APIRouter()


@router.get("/api/rom/tilebank")
async def get_tile_bank():
    """Get the complete Tile Table (256 tiles, each 4 bytes).

    Returns all 256 tiles from ROM address 0x011B0B.
    Each tile consists of 4 MiniTile IDs forming a 2x2 grid:
    [TL, TR, BL, BR] = Top-Left, Top-Right, Bottom-Left, Bottom-Right
    """
    _require_rom_data()

    tiles = []
    for i in range(TILE_COUNT):
        offset = TILE_TABLE_ADDR + (i * TILE_SIZE)
        minitiles = list(state._rom_data[offset:offset + TILE_SIZE])
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


@router.get("/api/rom/tilebank/{tile_index}")
async def get_tile_bank_tile(tile_index: int):
    """Get a single tile from the Tile Table.

    Args:
        tile_index: Tile index (0-255)
    """
    _require_rom_data()

    if tile_index < 0 or tile_index >= TILE_COUNT:
        raise HTTPException(
            status_code=400,
            detail=f"Tile index must be 0-{TILE_COUNT - 1}, got {tile_index}"
        )

    offset = TILE_TABLE_ADDR + (tile_index * TILE_SIZE)
    minitiles = list(state._rom_data[offset:offset + TILE_SIZE])

    return {
        "index": tile_index,
        "hex_index": f"0x{tile_index:02X}",
        "minitiles": minitiles,
        "rom_offset": f"0x{offset:05X}",
    }


@router.patch("/api/rom/tilebank/{tile_index}")
async def update_tile_bank_tile(tile_index: int, update: TileBankUpdate):
    """Update a tile's MiniTile IDs in the Tile Table.

    Args:
        tile_index: Tile index (0-255)
        update: New MiniTile IDs [TL, TR, BL, BR]
    """
    _require_rom_data()

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
    rom_array = bytearray(state._rom_data)
    for i, val in enumerate(update.minitiles):
        rom_array[offset + i] = val & 0xFF
    state._rom_data = bytes(rom_array)

    return {
        "status": "updated",
        "index": tile_index,
        "hex_index": f"0x{tile_index:02X}",
        "minitiles": update.minitiles,
        "rom_offset": f"0x{offset:05X}",
    }


@router.get("/api/rom/tilebank/{tile_index}/render")
async def render_tile_from_chr(tile_index: int, chr: int = 0x0F, scale: int = 4):
    """Dynamically render a tile from ROM CHR data.

    This renders the tile by reading its minitile IDs from the Tile Table,
    then looking up and compositing the 8x8 patterns from CHR ROM.

    Args:
        tile_index: Tile index (0-255)
        chr: CHR bank index (0-63), default 0x0F (overworld)
        scale: Scale factor for output (1=16x16, 4=64x64), default 4
    """
    _require_rom_data()

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
    minitiles = list(state._rom_data[tile_offset:tile_offset + TILE_SIZE])

    # Calculate CHR bank offset in ROM
    chr_offset = CHR_ROM_START + (chr * CHR_BANK_SIZE)

    # NES default grayscale palette
    PALETTE = [(0, 0, 0), (85, 85, 85), (170, 170, 170), (255, 255, 255)]

    def decode_pattern(pattern_index: int) -> list:
        """Decode an 8x8 NES pattern from CHR ROM."""
        addr = chr_offset + (pattern_index * PATTERN_SIZE)
        if addr + PATTERN_SIZE > len(state._rom_data):
            return [[0] * 8 for _ in range(8)]  # Out of bounds

        plane0 = state._rom_data[addr:addr + 8]
        plane1 = state._rom_data[addr + 8:addr + 16]

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
