"""Tests for rendering a single TileSection in isolation."""
import pytest

PIL = pytest.importorskip("PIL")  # skip whole module if Pillow missing

from tmos_randomizer.rendering.screen_renderer import (
    ScreenRenderer,
    TILESECTION_BASE,
    TILESECTION_OFFSET,
    TILE_PIXEL_SIZE,
)


def _make_renderer(tmp_path):
    # Synthetic ROM big enough for a few sections; tile images dir is empty so
    # the renderer uses fallback tiles (no real PNGs needed).
    rom_size = TILESECTION_BASE + 512 * TILESECTION_OFFSET
    rom = bytearray(rom_size)
    # Section 5: fill its 32 bytes with a recognizable pattern.
    base = TILESECTION_BASE + 5 * TILESECTION_OFFSET
    for i in range(32):
        rom[base + i] = i
    return ScreenRenderer(bytes(rom), str(tmp_path))


def test_render_section_returns_png_bytes(tmp_path):
    r = _make_renderer(tmp_path)
    data = r.render_tilesection_to_bytes(5, chr_bank=0x0F, scale=1)
    assert isinstance(data, (bytes, bytearray))
    assert data[:8] == b"\x89PNG\r\n\x1a\n"  # PNG magic


def test_render_section_dimensions(tmp_path):
    r = _make_renderer(tmp_path)
    from io import BytesIO
    from PIL import Image
    img = Image.open(BytesIO(r.render_tilesection_to_bytes(5, chr_bank=0, scale=2)))
    # A section is 8 tiles wide x 4 rows tall.
    assert img.size == (8 * TILE_PIXEL_SIZE * 2, 4 * TILE_PIXEL_SIZE * 2)
