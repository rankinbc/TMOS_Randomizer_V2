"""Render-side smoke tests (do not require a real ROM — synthetic world suffices)."""
from __future__ import annotations

from pathlib import Path

import pytest
from PIL import Image

from src.tmos_world.rendering import render_chapter_map, render_world_overview
from src.tmos_world.rendering.compose import render_screen
from tests.fixtures import make_screen, make_single_chapter_world

_PROJECT_ROOT = Path(__file__).resolve().parent.parent
ROM = _PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"


def test_render_screen_returns_image():
    world = make_single_chapter_world([make_screen()])
    img = render_screen(world, world.chapters[0].screens[0])
    assert isinstance(img, Image.Image)
    assert img.size == (8 * 64, 6 * 64)
    img.close()


def test_render_chapter_map_synthetic():
    world = make_single_chapter_world([make_screen(), make_screen()])
    img = render_chapter_map(world, 0, overlays=None, tile_px=8)
    assert isinstance(img, Image.Image)
    # 2 screens fit into 1 row at 16 cols → canvas is 16 * (8*8) wide
    assert img.width == 16 * (8 * 8)
    img.close()


def test_overlays_apply_without_error():
    world = make_single_chapter_world([make_screen(nav_right=1, content=0xC0), make_screen(nav_left=0)])
    overlays = {"collision_edges", "nav_arrows", "content_bytes", "section_outlines"}
    img = render_chapter_map(world, 0, overlays=overlays, tile_px=8)
    assert img is not None
    img.close()


@pytest.mark.skipif(not ROM.exists(), reason="ROM not present")
def test_render_chapter_map_real_rom():
    from src.tmos_world.rom import parse_rom

    world = parse_rom(ROM)
    img = render_chapter_map(world, 0, overlays=None, tile_px=8)
    assert img.size[0] > 0 and img.size[1] > 0
    img.close()


@pytest.mark.skipif(not ROM.exists(), reason="ROM not present")
def test_render_world_overview_real_rom():
    from src.tmos_world.rom import parse_rom

    world = parse_rom(ROM)
    img = render_world_overview(world, tile_px=4)  # tiny — just a smoke test
    assert img.size[0] > 0 and img.size[1] > 0
    img.close()
