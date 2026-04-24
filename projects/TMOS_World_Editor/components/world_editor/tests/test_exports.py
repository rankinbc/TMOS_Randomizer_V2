"""exports: JSON-to-file + PNG bytes round-trip."""
from __future__ import annotations

import io

from PIL import Image

from components.world_editor import exports


def test_download_png_bytes_roundtrips():
    img = Image.new("RGB", (32, 16), (10, 200, 100))
    blob = exports.download_png_bytes(img)
    assert isinstance(blob, bytes) and blob.startswith(b"\x89PNG")
    # Re-open
    Image.open(io.BytesIO(blob)).verify()


def test_new_run_dir_collision_avoids_overwrite(tmp_path, monkeypatch):
    # Point exports._project_root at tmp_path so we don't touch real output/.
    monkeypatch.setattr(exports, "_project_root", lambda: tmp_path)
    a = exports.new_run_dir("pytest-example")
    b = exports.new_run_dir("pytest-example")
    assert a != b
    assert a.exists() and b.exists()
