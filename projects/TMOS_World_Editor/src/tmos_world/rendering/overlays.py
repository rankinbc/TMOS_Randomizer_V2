"""PIL overlays for chapter maps."""
from __future__ import annotations

from PIL import Image, ImageDraw, ImageFont

from src.tmos_world.analysis.tiles import category, screen_edge_tiles
from src.tmos_world.model import World
from src.tmos_world.rom.constants import (
    NAV_BLOCKED,
    NAV_BUILDING_ENTRANCE,
    TIME_DOOR_CONTENTS,
)

OVERLAY_KEYS = frozenset(
    {"collision_edges", "nav_arrows", "content_bytes", "section_outlines"}
)


def _font() -> ImageFont.ImageFont:
    try:
        return ImageFont.load_default()
    except OSError:  # pragma: no cover — load_default is always available
        return ImageFont.load_default()


def apply_overlays(
    base: Image.Image,
    world: World,
    chapter_idx: int,
    overlays: set[str],
    layout: dict[int, tuple[int, int]],
    tile_px: int,
) -> Image.Image:
    """Apply the requested overlays and return a NEW image (caller-safe)."""
    out = base.copy()
    draw = ImageDraw.Draw(out, "RGBA")

    screen_w = 8 * tile_px
    screen_h = 6 * tile_px
    chapter = world.chapters[chapter_idx]

    if "collision_edges" in overlays:
        _draw_collision_edges(draw, world, chapter_idx, layout, tile_px)
    if "section_outlines" in overlays:
        _draw_section_outlines(draw, chapter, layout, screen_w, screen_h)
    if "nav_arrows" in overlays:
        _draw_nav_arrows(draw, chapter, layout, screen_w, screen_h)
    if "content_bytes" in overlays:
        _draw_content_labels(draw, chapter, layout, screen_w, screen_h)

    return out


def _draw_collision_edges(
    draw: ImageDraw.ImageDraw,
    world: World,
    chapter_idx: int,
    layout: dict[int, tuple[int, int]],
    tile_px: int,
) -> None:
    chapter = world.chapters[chapter_idx]
    screen_w = 8 * tile_px
    screen_h = 6 * tile_px
    red = (220, 30, 30, 180)
    for screen_idx, (c, r) in layout.items():
        screen = chapter.screens[screen_idx]
        x0 = c * screen_w
        y0 = r * screen_h
        for direction, (dx0, dy0, dx1, dy1) in (
            ("left",  (0, 0, 0, screen_h - 1)),
            ("right", (screen_w - 1, 0, screen_w - 1, screen_h - 1)),
            ("up",    (0, 0, screen_w - 1, 0)),
            ("down",  (0, screen_h - 1, screen_w - 1, screen_h - 1)),
        ):
            edge = screen_edge_tiles(world, screen, direction)
            if all(category(t) != "walkable" for t in edge):
                draw.line(
                    [(x0 + dx0, y0 + dy0), (x0 + dx1, y0 + dy1)],
                    fill=red,
                    width=max(1, tile_px // 4),
                )


def _draw_nav_arrows(
    draw: ImageDraw.ImageDraw,
    chapter,
    layout: dict[int, tuple[int, int]],
    screen_w: int,
    screen_h: int,
) -> None:
    arrow = (80, 200, 255, 255)
    for screen_idx, (c, r) in layout.items():
        screen = chapter.screens[screen_idx]
        cx = c * screen_w + screen_w // 2
        cy = r * screen_h + screen_h // 2
        for nav_field, dx, dy in (
            ("nav_right", 1, 0),
            ("nav_left", -1, 0),
            ("nav_up", 0, -1),
            ("nav_down", 0, 1),
        ):
            v = getattr(screen, nav_field)
            if v in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if v >= chapter.screen_count:
                continue
            tx = cx + dx * (screen_w // 3)
            ty = cy + dy * (screen_h // 3)
            draw.line([(cx, cy), (tx, ty)], fill=arrow, width=1)


def _draw_content_labels(
    draw: ImageDraw.ImageDraw,
    chapter,
    layout: dict[int, tuple[int, int]],
    screen_w: int,
    screen_h: int,
) -> None:
    font = _font()
    for screen_idx, (c, r) in layout.items():
        screen = chapter.screens[screen_idx]
        text = f"{screen.content:02X}"
        color = (255, 255, 0, 255)
        if screen.content in TIME_DOOR_CONTENTS:
            color = (180, 80, 255, 255)  # time doors highlighted
        draw.text(
            (c * screen_w + 1, r * screen_h + 1),
            text,
            fill=color,
            font=font,
        )


def _draw_section_outlines(
    draw: ImageDraw.ImageDraw,
    chapter,
    layout: dict[int, tuple[int, int]],
    screen_w: int,
    screen_h: int,
) -> None:
    palette = [
        (0, 255, 128, 220),
        (255, 128, 0, 220),
        (128, 128, 255, 220),
        (255, 255, 0, 220),
        (255, 0, 180, 220),
    ]
    for si, section in enumerate(chapter.sections):
        color = palette[si % len(palette)]
        for screen_idx in section.members:
            pos = layout.get(screen_idx)
            if pos is None:
                continue
            c, r = pos
            x0 = c * screen_w
            y0 = r * screen_h
            draw.rectangle(
                [x0, y0, x0 + screen_w - 1, y0 + screen_h - 1],
                outline=color,
                width=1,
            )
