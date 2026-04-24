"""Run folder + artifact writers for world_editor exports."""
from __future__ import annotations

import io
import json
from datetime import date
from pathlib import Path

from PIL import Image

from src.tmos_world.model import World
from src.tmos_world.rendering import render_chapter_map
from src.tmos_world.serialization import world_to_json


def _project_root() -> Path:
    return Path(__file__).resolve().parent.parent.parent


def new_run_dir(description: str) -> Path:
    """Create (and return) a fresh output/world_editor/<date>_<desc>/ directory."""
    base = _project_root() / "output" / "world_editor"
    slug = f"{date.today().isoformat()}_{description}"
    run = base / slug
    if run.exists():
        import uuid

        run = base / f"{slug}-{uuid.uuid4().hex[:6]}"
    run.mkdir(parents=True, exist_ok=False)
    return run


def export_json(world: World, description: str) -> Path:
    """Serialize world + per-chapter map PNGs to a new run folder. Return the run path."""
    run = new_run_dir(description)
    (run / "world.json").write_text(
        json.dumps(world_to_json(world), indent=2), encoding="utf-8"
    )
    for i in range(len(world.chapters)):
        img = render_chapter_map(world, i)
        img.save(run / f"map_chapter{world.chapters[i].number}.png")
        img.close()
    return run


def download_png_bytes(image: Image.Image) -> bytes:
    """Return PNG bytes for ``st.download_button``."""
    buf = io.BytesIO()
    image.save(buf, format="PNG")
    return buf.getvalue()
