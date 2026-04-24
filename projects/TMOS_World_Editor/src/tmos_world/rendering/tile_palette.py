"""Tile-ID -> PIL.Image resolver.

V1 loads pre-rendered 64×64 metatile PNG assets from ``data/tiles/`` rather
than doing CHR-bank decoding from the ROM. The spec §3.2 decoding pipeline is
documented; swapping this resolver for a full CHR decoder would be purely
additive (the rest of rendering depends only on ``get_tile_image``).

Falls back to a deterministic color swatch for unknown tile IDs.
"""
from __future__ import annotations

from functools import lru_cache
from pathlib import Path

from PIL import Image

TILE_PIXEL_SIZE = 64

# Project root = <repo>/ — this file lives at src/tmos_world/rendering/
_PROJECT_ROOT = Path(__file__).resolve().parents[3]
_DEFAULT_TILES_DIR = _PROJECT_ROOT / "data" / "tiles"


# Canonical tile-id -> filename mapping (aliases where the parent project's
# sprite set reuses a single PNG for visually equivalent IDs).
_TILE_FILENAME_ALIASES: dict[int, str] = {
    0x06: "0D", 0x0E: "0D", 0x0F: "0D", 0x10: "0D",
    0x14: "0D", 0x15: "0D", 0x16: "0D", 0x17: "0D", 0x18: "0D", 0x19: "0D", 0x1A: "0D",
    0x07: "08", 0x09: "08", 0x0A: "08", 0x11: "08",
    0x0B: "20",
    0x2B: "43", 0x2C: "43", 0x2D: "43", 0x2E: "43",
    0x37: "43", 0x38: "43", 0x39: "43", 0x3A: "43", 0x3B: "43", 0x3C: "43", 0x3D: "43", 0x3E: "43",
    0x2F: "3F", 0x30: "3F",
    0x32: "41",
    0x33: "40", 0x34: "40",
    0x24: "25",
    0x73: "03", 0xED: "03", 0xF3: "03",
    0x79: "26",
    0xE2: "A9",
    0xAB: "AA", 0xAF: "AA",
    0xD5: "D6",
}


def _filename_for(tile_id: int) -> str:
    alias = _TILE_FILENAME_ALIASES.get(tile_id)
    base = alias if alias is not None else f"{tile_id:02X}"
    return f"{base}.png"


def _fallback_tile(tile_id: int) -> Image.Image:
    """Deterministic color swatch so missing assets stay recognizable."""
    r = (tile_id * 37) % 256
    g = (tile_id * 73) % 256
    b = (tile_id * 113) % 256
    return Image.new("RGB", (TILE_PIXEL_SIZE, TILE_PIXEL_SIZE), (r, g, b))


@lru_cache(maxsize=512)
def get_tile_image(tile_id: int, tiles_dir: str | None = None) -> Image.Image:
    """Return a 64×64 RGB PIL image for ``tile_id``.

    Cache returns a shared reference — callers that intend to draw on top must
    ``.copy()`` before mutating (spec CLAUDE.md gotcha).
    """
    root = Path(tiles_dir) if tiles_dir else _DEFAULT_TILES_DIR
    path = root / _filename_for(tile_id)
    if path.exists():
        img = Image.open(path).convert("RGB")
        if img.size != (TILE_PIXEL_SIZE, TILE_PIXEL_SIZE):
            img = img.resize((TILE_PIXEL_SIZE, TILE_PIXEL_SIZE), Image.NEAREST)
        return img
    return _fallback_tile(tile_id)


def clear_tile_cache() -> None:
    get_tile_image.cache_clear()
