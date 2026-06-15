# Clickable Tile Sections Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Top/Bottom TileSection values in the screen detail panel clickable, opening a scrollable dropdown of all 471 tile sections that live-updates the selected screen's tiles.

**Architecture:** Two new FastAPI endpoints — one renders any of the 471 sections in isolation (for dropdown thumbnails), one PATCHes a screen's tile sections (taking global section indices 0–470, computing the byte + DataPointer). A pure `tilesection_bank` logic module owns the byte/bank/DataPointer math. The React UI gets a `TileSectionPicker` component, an API client method, and a Zustand store action that mirrors the existing `updateScreenNavigation` call-and-merge pattern so the panel and renderer refresh live.

**Tech Stack:** Python 3.11 / FastAPI / Pillow (backend, pytest TDD with synthetic ROM bytes); React + TypeScript + Vite + Zustand + Tailwind (frontend, verified via `tsc`/`vite build` + eslint + manual — no UI unit-test harness exists in this project).

**Reference spec:** `docs/superpowers/specs/2026-06-15-clickable-tile-sections-design.md`

**Run all backend commands from** `projects/TMOS_Randomizer_V2/`. **Run all frontend commands from** `projects/TMOS_Randomizer_V2/ui/`.

---

## Domain cheat-sheet (read once)

- A `WorldScreen.top_tiles` / `bottom_tiles` is a **0–255 byte**. There are **471** sections (`TILESECTION_COUNT`). Sections ≥ 256 live in "bank 1."
- The bank per half comes from the **DataPointer** via value ranges — the authoritative model is `get_bank_offset(datapointer)` in `rendering/screen_renderer.py`:
  - `< 0x40` → (top 0, bottom 0); `0x40–0x8E` → (0, 1); `0x8F–0x9F` → (1, 0); `>= 0xC0` → (1, 1).
- DataPointer also carries CHR bank: `chr = datapointer & 0x3F`.
- ⚠️ Do NOT use `get_all_valid_datapointers` from `core/constants.py` — it uses a *bit* model that disagrees with `get_bank_offset` for the (1,0) combo. The renderer (`get_bank_offset`) is authoritative.
- A section read: `address = 0x03C4C7 + index*32`, 32 bytes, where `index` is the **global** index (byte + bank*256).

---

## Task 1: Pure bank/DataPointer logic module

**Files:**
- Create: `src/tmos_randomizer/logic/tilesection_bank.py`
- Test: `tests/test_logic/test_tilesection_bank.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_logic/test_tilesection_bank.py`:

```python
"""Tests for tile-section byte/bank/DataPointer math.

The authoritative bank model is the renderer's value-range get_bank_offset:
  < 0x40 -> (0,0); 0x40-0x8E -> (0,1); 0x8F-0x9F -> (1,0); >= 0xC0 -> (1,1)
"""
import pytest
from tmos_randomizer.rendering.screen_renderer import get_bank_offset
from tmos_randomizer.logic.tilesection_bank import (
    decompose_section_index,
    compute_datapointer,
    resolve_tile_update,
)


class TestDecompose:
    def test_bank0_section(self):
        assert decompose_section_index(0) == (0, 0)
        assert decompose_section_index(189) == (189, 0)
        assert decompose_section_index(255) == (255, 0)

    def test_bank1_section(self):
        assert decompose_section_index(256) == (0, 1)
        assert decompose_section_index(300) == (44, 1)
        assert decompose_section_index(470) == (214, 1)

    def test_out_of_range_raises(self):
        with pytest.raises(ValueError):
            decompose_section_index(-1)
        with pytest.raises(ValueError):
            decompose_section_index(471)


class TestComputeDatapointer:
    def test_combo_0_0_preserves_chr(self):
        dp, chr_used = compute_datapointer(0, 0, 0x0F)
        assert chr_used == 0x0F
        assert get_bank_offset(dp) == (0, 0)
        assert dp & 0x3F == 0x0F

    def test_combo_0_1_preserves_chr(self):
        dp, chr_used = compute_datapointer(0, 1, 0x0F)
        assert chr_used == 0x0F
        assert get_bank_offset(dp) == (0, 256)
        assert dp & 0x3F == 0x0F

    def test_combo_1_1_preserves_chr(self):
        dp, chr_used = compute_datapointer(1, 1, 0x3F)
        assert chr_used == 0x3F
        assert get_bank_offset(dp) == (256, 256)
        assert dp & 0x3F == 0x3F

    def test_combo_1_0_clamps_chr_into_window(self):
        # (1,0) only exists for dp 0x8F-0x9F => chr 0x0F-0x1F
        dp, chr_used = compute_datapointer(1, 0, 0x00)
        assert get_bank_offset(dp) == (256, 0)
        assert 0x0F <= chr_used <= 0x1F

    def test_combo_1_0_keeps_chr_already_in_window(self):
        dp, chr_used = compute_datapointer(1, 0, 0x12)
        assert chr_used == 0x12
        assert get_bank_offset(dp) == (256, 0)


class TestResolveTileUpdate:
    def test_top_within_same_bank_no_dp_change(self):
        # current dp 0x0F => (top0, bottom0), chr 0x0F. New top section 100 (bank 0).
        r = resolve_tile_update(current_datapointer=0x0F, top_index=100, bottom_index=None)
        assert r["top_tiles"] == 100
        assert r["bottom_tiles"] is None
        assert r["datapointer"] == 0x0F
        assert r["datapointer_changed"] is False
        assert r["chr_changed"] is False

    def test_top_cross_bank_changes_dp(self):
        # current dp 0x0F => banks (0,0). New top section 300 => bank 1, byte 44.
        # Need (top1, bottom0) => combo (1,0) => chr clamps to 0x0F-0x1F.
        r = resolve_tile_update(current_datapointer=0x0F, top_index=300, bottom_index=None)
        assert r["top_tiles"] == 44
        assert get_bank_offset(r["datapointer"]) == (256, 0)
        assert r["datapointer_changed"] is True

    def test_both_halves(self):
        # New top 256 (bank1), new bottom 257 (bank1) => combo (1,1).
        r = resolve_tile_update(current_datapointer=0x0F, top_index=256, bottom_index=257)
        assert r["top_tiles"] == 0
        assert r["bottom_tiles"] == 1
        assert get_bank_offset(r["datapointer"]) == (256, 256)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_logic/test_tilesection_bank.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'tmos_randomizer.logic.tilesection_bank'`

- [ ] **Step 3: Write minimal implementation**

Create `src/tmos_randomizer/logic/tilesection_bank.py`:

```python
"""Byte/bank/DataPointer math for editing a WorldScreen's tile sections.

A WorldScreen stores top_tiles/bottom_tiles as 0-255 bytes, but there are
TILESECTION_COUNT (471) sections. Sections >= 256 live in "bank 1". The bank
for each half is selected by the DataPointer via the renderer's value-range
model (get_bank_offset), which is authoritative here. The DataPointer also
carries the CHR bank index in its low 6 bits.

The (top=1, bottom=0) bank combo only exists for DataPointer 0x8F-0x9F, so the
CHR index is constrained to 0x0F-0x1F for that combo. All other combos preserve
the current CHR index.
"""
from __future__ import annotations

from typing import Optional

from ..core.constants import TILESECTION_COUNT


def decompose_section_index(global_index: int) -> tuple[int, int]:
    """Split a global section index (0..470) into (byte, bank)."""
    if global_index < 0 or global_index >= TILESECTION_COUNT:
        raise ValueError(
            f"section index {global_index} out of range [0, {TILESECTION_COUNT})"
        )
    bank = 1 if global_index >= 256 else 0
    byte = global_index - 256 * bank
    return byte, bank


def compute_datapointer(
    top_bank: int, bottom_bank: int, current_chr: int
) -> tuple[int, int]:
    """Return (datapointer, chr_used) realizing the requested bank combo.

    chr_used == current_chr for every combo except (1, 0), where it is clamped
    into 0x0F-0x1F (the only CHR window for which DataPointer yields top-bank-1
    + bottom-bank-0 under get_bank_offset).
    """
    chr_index = current_chr & 0x3F
    combo = (top_bank, bottom_bank)
    if combo == (0, 0):
        return chr_index, chr_index           # dp < 0x40
    if combo == (0, 1):
        return 0x40 | chr_index, chr_index     # 0x40-0x7F
    if combo == (1, 1):
        return 0xC0 | chr_index, chr_index     # 0xC0-0xFF
    # combo == (1, 0): only dp 0x8F-0x9F => chr 0x0F-0x1F
    chr_used = min(max(chr_index, 0x0F), 0x1F)
    return 0x80 | chr_used, chr_used


def resolve_tile_update(
    current_datapointer: int,
    top_index: Optional[int],
    bottom_index: Optional[int],
) -> dict:
    """Resolve a tile-section edit into concrete byte/DataPointer values.

    Args:
        current_datapointer: the screen's current DataPointer byte.
        top_index: new global section index for the top half, or None to keep.
        bottom_index: new global section index for the bottom half, or None.

    Returns dict with: top_tiles (byte|None), bottom_tiles (byte|None),
    datapointer (int), datapointer_changed (bool), chr_changed (bool).
    """
    # Lazy import to avoid a circular import at module load.
    from ..rendering.screen_renderer import get_bank_offset

    cur_top_off, cur_bot_off = get_bank_offset(current_datapointer)
    cur_top_bank = 1 if cur_top_off else 0
    cur_bot_bank = 1 if cur_bot_off else 0
    current_chr = current_datapointer & 0x3F

    top_byte: Optional[int] = None
    bottom_byte: Optional[int] = None
    new_top_bank = cur_top_bank
    new_bot_bank = cur_bot_bank

    if top_index is not None:
        top_byte, new_top_bank = decompose_section_index(top_index)
    if bottom_index is not None:
        bottom_byte, new_bot_bank = decompose_section_index(bottom_index)

    datapointer, chr_used = compute_datapointer(new_top_bank, new_bot_bank, current_chr)

    return {
        "top_tiles": top_byte,
        "bottom_tiles": bottom_byte,
        "datapointer": datapointer,
        "datapointer_changed": datapointer != current_datapointer,
        "chr_changed": chr_used != current_chr,
    }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_logic/test_tilesection_bank.py -v`
Expected: PASS (all tests)

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/logic/tilesection_bank.py tests/test_logic/test_tilesection_bank.py
git commit -m "feat(v2): tile-section byte/bank/DataPointer math"
```

---

## Task 2: Renderer helper to render a single section

**Files:**
- Modify: `src/tmos_randomizer/rendering/screen_renderer.py` (add method to `ScreenRenderer`)
- Test: `tests/test_rendering/test_tilesection_render.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_rendering/test_tilesection_render.py`:

```python
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_rendering/test_tilesection_render.py -v`
Expected: FAIL with `AttributeError: 'ScreenRenderer' object has no attribute 'render_tilesection_to_bytes'`

- [ ] **Step 3: Write minimal implementation**

In `src/tmos_randomizer/rendering/screen_renderer.py`, add these two methods to the `ScreenRenderer` class, immediately after `render_screen_to_bytes` (around line 412). Use the existing module-level helpers `read_tilesection`, `get_tilesection_grid`, `get_ground_color`, and constants already imported in this file:

```python
    def render_tilesection(
        self,
        index: int,
        chr_bank: int = 0,
        scale: int = 1,
        ws_color: Optional[int] = None,
    ) -> "Image.Image":
        """Render a single TileSection (8 wide x 4 rows) in isolation.

        Args:
            index: GLOBAL section index (0..470 incl. bank offset).
            chr_bank: CHR bank index for tile graphics (0-63).
            scale: scale factor.
            ws_color: optional WorldScreen color for the canvas / missing-tile
                fallback; black if not given.
        """
        section = read_tilesection(self.rom_data, index)
        grid = get_tilesection_grid(section)  # 4 rows x 8 tiles

        base_color = get_ground_color(ws_color) if ws_color is not None else (0, 0, 0)
        width = 8 * TILE_PIXEL_SIZE * scale
        height = 4 * TILE_PIXEL_SIZE * scale
        output = Image.new('RGB', (width, height), base_color)

        for row_idx, row in enumerate(grid):
            for col_idx, tile_id in enumerate(row):
                tile_img = self._load_tile_image(tile_id, chr_bank)
                if tile_img is None:
                    tile_img = self._create_fallback_tile(
                        tile_id, base_color if ws_color is not None else None
                    )
                if scale > 1:
                    tile_img = tile_img.resize(
                        (TILE_PIXEL_SIZE * scale, TILE_PIXEL_SIZE * scale),
                        Image.NEAREST,
                    )
                output.paste(tile_img, (col_idx * TILE_PIXEL_SIZE * scale,
                                        row_idx * TILE_PIXEL_SIZE * scale))
        return output

    def render_tilesection_to_bytes(
        self,
        index: int,
        chr_bank: int = 0,
        scale: int = 1,
        format: str = 'PNG',
        ws_color: Optional[int] = None,
    ) -> bytes:
        """Render a single TileSection and return image bytes."""
        img = self.render_tilesection(index, chr_bank, scale, ws_color=ws_color)
        buffer = BytesIO()
        img.save(buffer, format=format)
        return buffer.getvalue()
```

Verify `get_ground_color` is imported at the top of the file; if not, add it to the existing constants import (it is already used by `render_screen`, so it is present).

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_rendering/test_tilesection_render.py -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/rendering/screen_renderer.py tests/test_rendering/test_tilesection_render.py
git commit -m "feat(v2): render a single TileSection in isolation"
```

---

## Task 3: Section-preview endpoint

**Files:**
- Modify: `src/tmos_randomizer/api/server.py` (add endpoint after `render_screen`, ~line 645)
- Test: `tests/test_integration/test_tilesection_endpoints.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_integration/test_tilesection_endpoints.py`:

```python
"""Endpoint tests for the section-preview and tile-update APIs.

These drive the real FastAPI app. They load the default ROM if present and
skip when it (or Pillow) is unavailable, matching the project's existing
asset-dependent test pattern.
"""
import pytest

pytest.importorskip("PIL")
pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    resp = c.post("/api/rom/load-default")
    if resp.status_code != 200:
        pytest.skip("default ROM not available")
    status = c.get("/api/rom/render/status").json()
    if not status.get("renderer_initialized"):
        pytest.skip("screen renderer not initialized (tile images missing)")
    return c


def test_section_preview_ok(client):
    resp = client.get("/api/rom/tilesection/5?chr=15&scale=1")
    assert resp.status_code == 200
    assert resp.headers["content-type"] == "image/png"
    assert resp.content[:8] == b"\x89PNG\r\n\x1a\n"


def test_section_preview_out_of_range(client):
    resp = client.get("/api/rom/tilesection/471")
    assert resp.status_code == 400
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_integration/test_tilesection_endpoints.py::test_section_preview_ok -v`
Expected: FAIL with 404 (route not found) — or SKIP if no ROM. If it skips, you can still confirm the route is missing by checking `server.app` has no `/api/rom/tilesection/{index}` route; proceed to implement.

- [ ] **Step 3: Write minimal implementation**

In `src/tmos_randomizer/api/server.py`, add after the `render_screen` endpoint (after line ~645, before `get_render_status`):

```python
@app.get("/api/rom/tilesection/{index}")
async def render_tilesection(
    index: int,
    chr: int = Query(default=0, ge=0, le=63),
    scale: int = Query(default=4, ge=1, le=8),
    ws_color: Optional[int] = Query(default=None, ge=0, le=255),
):
    """Render a single TileSection (8x4 tiles) in isolation as a PNG.

    `index` is a global section index (0..470). Decoupled from any screen's
    DataPointer — bank selection is already baked into the global index.
    """
    from ..core.constants import TILESECTION_COUNT

    if not RENDERING_AVAILABLE or _screen_renderer is None:
        raise HTTPException(status_code=501, detail="Rendering not available")
    if index < 0 or index >= TILESECTION_COUNT:
        raise HTTPException(
            status_code=400,
            detail=f"section index must be 0-{TILESECTION_COUNT - 1}, got {index}",
        )
    try:
        image_bytes = _screen_renderer.render_tilesection_to_bytes(
            index, chr_bank=chr, scale=scale, format='PNG', ws_color=ws_color
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Rendering failed: {e}")

    return Response(
        content=image_bytes,
        media_type="image/png",
        headers={"Cache-Control": "public, max-age=3600", "X-Section-Index": str(index)},
    )
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_integration/test_tilesection_endpoints.py -v`
Expected: PASS (or SKIP if the default ROM/tile images are unavailable in this environment)

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/api/server.py tests/test_integration/test_tilesection_endpoints.py
git commit -m "feat(v2): GET /api/rom/tilesection/{index} section preview endpoint"
```

---

## Task 4: Tile-update PATCH endpoint

**Files:**
- Modify: `src/tmos_randomizer/api/server.py` (add `TileSectionUpdate` model near `NavigationUpdate` ~line 130; add endpoint after `update_screen_navigation` ~line 578)
- Test: `tests/test_integration/test_tilesection_endpoints.py` (extend)

- [ ] **Step 1: Write the failing test**

Append to `tests/test_integration/test_tilesection_endpoints.py`:

```python
def test_update_tiles_same_bank(client):
    # Pick chapter 1 screen 0; set top section to 100 (bank 0).
    before = client.get("/api/rom/screen/1/0").json()
    resp = client.patch("/api/rom/screen/1/0/tiles", json={"top_tiles": 100})
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "updated"
    assert body["screen"]["top_tiles"] == 100
    assert "datapointer_changed" in body
    # restore
    client.patch("/api/rom/screen/1/0/tiles", json={"top_tiles": before["top_tiles"]})


def test_update_tiles_out_of_range(client):
    resp = client.patch("/api/rom/screen/1/0/tiles", json={"top_tiles": 471})
    assert resp.status_code == 400


def test_update_tiles_missing_screen(client):
    resp = client.patch("/api/rom/screen/1/9999/tiles", json={"top_tiles": 5})
    assert resp.status_code == 404
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_integration/test_tilesection_endpoints.py::test_update_tiles_same_bank -v`
Expected: FAIL with 404/405 (route not found) — or SKIP if no ROM.

- [ ] **Step 3: Write minimal implementation**

In `src/tmos_randomizer/api/server.py`, add the request model next to `NavigationUpdate` (after line ~137):

```python
class TileSectionUpdate(BaseModel):
    """Update a screen's tile sections. Values are GLOBAL section indices 0-470."""
    top_tiles: Optional[int] = None
    bottom_tiles: Optional[int] = None
```

Then add the endpoint after `update_screen_navigation` (after line ~578):

```python
@app.patch("/api/rom/screen/{chapter_num}/{screen_index}/tiles")
async def update_screen_tiles(
    chapter_num: int,
    screen_index: int,
    update: TileSectionUpdate,
):
    """Update a screen's Top/Bottom TileSection (live, in-memory).

    `top_tiles`/`bottom_tiles` are GLOBAL section indices (0..470). The backend
    splits each into (byte, bank) and rewrites the DataPointer so the renderer
    selects the right bank, preserving CHR where the bank rules allow.
    """
    from ..core.constants import TILESECTION_COUNT, get_chr_index
    from ..logic.tilesection_bank import resolve_tile_update

    if _game_world is None:
        raise HTTPException(status_code=400, detail="No ROM loaded")
    chapter = _game_world.chapters.get(chapter_num)
    if chapter is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not found")
    screen = chapter.get_screen(screen_index)
    if screen is None:
        raise HTTPException(status_code=404, detail=f"Screen {screen_index} not found")

    if update.top_tiles is None and update.bottom_tiles is None:
        raise HTTPException(status_code=400, detail="Provide top_tiles and/or bottom_tiles")
    for label, val in (("top_tiles", update.top_tiles), ("bottom_tiles", update.bottom_tiles)):
        if val is not None and (val < 0 or val >= TILESECTION_COUNT):
            raise HTTPException(
                status_code=400,
                detail=f"{label} must be 0-{TILESECTION_COUNT - 1}, got {val}",
            )

    resolved = resolve_tile_update(
        current_datapointer=screen.datapointer,
        top_index=update.top_tiles,
        bottom_index=update.bottom_tiles,
    )
    screen.set_tiles(top=resolved["top_tiles"], bottom=resolved["bottom_tiles"])
    screen.datapointer = resolved["datapointer"]
    screen.mark_modified()

    return {
        "status": "updated",
        "datapointer_changed": resolved["datapointer_changed"],
        "chr_changed": resolved["chr_changed"],
        "screen": {
            "index": screen.relative_index,
            "global_index": screen.global_index,
            "datapointer": screen.datapointer,
            "chr_index": get_chr_index(screen.datapointer),
            "top_tiles": screen.top_tiles,
            "bottom_tiles": screen.bottom_tiles,
            "objectset": screen.objectset,
            "parent_world": screen.parent_world,
            "event": screen.event,
            "content": screen.content,
            "nav_right": screen.screen_index_right,
            "nav_left": screen.screen_index_left,
            "nav_down": screen.screen_index_down,
            "nav_up": screen.screen_index_up,
            "worldscreen_color": screen.worldscreen_color,
            "sprites_color": screen.sprites_color,
            "exit_position": screen.exit_position,
        },
    }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_integration/test_tilesection_endpoints.py -v`
Expected: PASS (or SKIP if no ROM/images). Also run the full backend suite to confirm no regressions:
Run: `python -m pytest tests/ -q`
Expected: PASS (no new failures)

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/api/server.py tests/test_integration/test_tilesection_endpoints.py
git commit -m "feat(v2): PATCH screen tiles endpoint (byte+DataPointer)"
```

---

## Task 5: API client methods (frontend)

**Files:**
- Modify: `ui/src/api/client.ts`

- [ ] **Step 1: Add response type and methods**

In `ui/src/api/client.ts`, add this interface next to `NavigationUpdateResponse` (~line 133):

```typescript
export interface ScreenTilesUpdateResponse {
  status: string;
  datapointer_changed: boolean;
  chr_changed: boolean;
  screen: ScreenData;
}
```

Add these methods inside the `ApiClient` class, right after `updateScreenNavigation` (~line 619):

```typescript
  // Tile section operations. top_tiles/bottom_tiles are GLOBAL section indices (0-470).
  async updateScreenTiles(
    chapterNum: number,
    screenIndex: number,
    update: { top_tiles?: number; bottom_tiles?: number }
  ): Promise<ScreenTilesUpdateResponse> {
    return this.fetch<ScreenTilesUpdateResponse>(
      `/api/rom/screen/${chapterNum}/${screenIndex}/tiles`,
      { method: 'PATCH', body: JSON.stringify(update) }
    );
  }

  // Total number of selectable tile sections.
  static readonly TILESECTION_COUNT = 471;

  // URL for a single section preview (8x4 tiles). index is a global index 0-470.
  getTileSectionPreviewUrl(index: number, chr: number, scale = 2): string {
    return `${this.baseUrl}/api/rom/tilesection/${index}?chr=${chr}&scale=${scale}`;
  }
```

- [ ] **Step 2: Verify it type-checks**

Run (from `ui/`): `npx tsc -b --noEmit`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add ui/src/api/client.ts
git commit -m "feat(v2/ui): API client for tile-section preview + update"
```

---

## Task 6: Store action (frontend)

**Files:**
- Modify: `ui/src/store/index.ts` (type decl near `updateScreenNavigation` ~line 162; impl near ~line 609)

- [ ] **Step 1: Add the action type to the store interface**

In `ui/src/store/index.ts`, find the `updateScreenNavigation` signature in the store interface (~line 162) and add directly below it:

```typescript
  updateScreenTiles: (
    screenIndex: number,
    update: { top_tiles?: number; bottom_tiles?: number }
  ) => Promise<{ datapointer_changed: boolean; chr_changed: boolean }>;
```

- [ ] **Step 2: Add the implementation**

In `ui/src/store/index.ts`, add right after the `updateScreenNavigation` implementation closes (after line ~609):

```typescript
  updateScreenTiles: async (screenIndex, update) => {
    const state = get();
    if (!state.chapterData) {
      throw new Error('No chapter data loaded');
    }
    try {
      const response = await api.updateScreenTiles(
        state.selectedChapter,
        screenIndex,
        update
      );
      const updatedScreens = state.chapterData.screens.map((screen) =>
        screen.index === response.screen.index ? response.screen : screen
      );
      set({
        chapterData: { ...state.chapterData, screens: updatedScreens },
      });
      return {
        datapointer_changed: response.datapointer_changed,
        chr_changed: response.chr_changed,
      };
    } catch (error) {
      set({
        apiError: error instanceof Error ? error.message : 'Failed to update tiles',
      });
      throw error;
    }
  },
```

- [ ] **Step 3: Verify it type-checks**

Run (from `ui/`): `npx tsc -b --noEmit`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add ui/src/store/index.ts
git commit -m "feat(v2/ui): store action updateScreenTiles (merge-on-response)"
```

---

## Task 7: TileSectionPicker component (frontend)

**Files:**
- Create: `ui/src/components/screen/TileSectionPicker.tsx`

- [ ] **Step 1: Create the component**

Create `ui/src/components/screen/TileSectionPicker.tsx`:

```tsx
import { useState, useRef, useEffect } from 'react';
import { api, ApiClient } from '../../api/client';

interface TileSectionPickerProps {
  which: 'top' | 'bottom';
  /** Current value as a 0-255 byte (the screen's stored top_tiles/bottom_tiles). */
  currentByte: number;
  /** Current bank for this half (0 or 1) — to map the byte to a global index. */
  currentBank: number;
  /** CHR bank index for rendering thumbnails. */
  chr: number;
  /** Called with the chosen GLOBAL section index (0-470). */
  onPick: (globalIndex: number) => void;
}

const TOTAL = ApiClient.TILESECTION_COUNT; // 471

export function TileSectionPicker({
  which, currentByte, currentBank, chr, onPick,
}: TileSectionPickerProps) {
  const [open, setOpen] = useState(false);
  const currentGlobal = currentBank * 256 + currentByte;
  const label = which === 'top' ? 'Top TileSection' : 'Bottom TileSection';

  return (
    <div className="flex justify-between text-sm items-center">
      <span className="text-slate-500">{label}</span>
      <button
        onClick={() => setOpen(true)}
        className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
        title="Click to change tile section"
      >
        0x{currentByte.toString(16).toUpperCase()} ({currentByte})
      </button>
      {open && (
        <TileSectionDropdown
          chr={chr}
          currentGlobal={currentGlobal}
          onClose={() => setOpen(false)}
          onPick={(g) => { onPick(g); setOpen(false); }}
        />
      )}
    </div>
  );
}

function TileSectionDropdown({
  chr, currentGlobal, onClose, onPick,
}: {
  chr: number;
  currentGlobal: number;
  onClose: () => void;
  onPick: (globalIndex: number) => void;
}) {
  const indices = Array.from({ length: TOTAL }, (_, i) => i);
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div
        className="bg-slate-800 border border-slate-600 rounded-lg shadow-xl w-[640px] max-h-[80vh] flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-3 border-b border-slate-700">
          <h4 className="text-slate-200 font-semibold">Select Tile Section ({TOTAL} total)</h4>
          <button onClick={onClose} className="text-slate-400 hover:text-white text-xl">&times;</button>
        </div>
        <div className="overflow-y-auto p-3 grid grid-cols-6 gap-2">
          {indices.map((g) => (
            <SectionThumb
              key={g}
              globalIndex={g}
              chr={chr}
              selected={g === currentGlobal}
              crossBank={g >= 256}
              onClick={() => onPick(g)}
            />
          ))}
        </div>
        <div className="p-2 border-t border-slate-700 text-xs text-slate-500">
          Sections ≥ 256 are in bank 1 — selecting one also changes the screen's DataPointer/CHR.
        </div>
      </div>
    </div>
  );
}

function SectionThumb({
  globalIndex, chr, selected, crossBank, onClick,
}: {
  globalIndex: number;
  chr: number;
  selected: boolean;
  crossBank: boolean;
  onClick: () => void;
}) {
  const ref = useRef<HTMLButtonElement>(null);
  const [visible, setVisible] = useState(false);

  // Lazy-load: only request the thumbnail PNG once the cell scrolls into view.
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) { setVisible(true); obs.disconnect(); }
    }, { rootMargin: '100px' });
    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  const byte = crossBank ? globalIndex - 256 : globalIndex;
  return (
    <button
      ref={ref}
      onClick={onClick}
      className={`relative rounded overflow-hidden border transition-all ${
        selected ? 'border-yellow-400 ring-2 ring-yellow-400' : 'border-slate-700 hover:border-blue-400'
      }`}
      title={`Section ${globalIndex} (0x${byte.toString(16).toUpperCase()}${crossBank ? ', bank 1' : ''})`}
      style={{ aspectRatio: '2 / 1', backgroundColor: '#0f172a' }}
    >
      {visible && (
        <img
          src={api.getTileSectionPreviewUrl(globalIndex, chr, 2)}
          alt={`Section ${globalIndex}`}
          className="w-full h-full object-cover"
          style={{ imageRendering: 'auto' }}
          loading="lazy"
          onError={(e) => { e.currentTarget.style.visibility = 'hidden'; }}
        />
      )}
      <span className="absolute top-0 left-0 bg-black/70 text-white text-[8px] font-mono px-1">
        {globalIndex}{crossBank ? '*' : ''}
      </span>
    </button>
  );
}
```

- [ ] **Step 2: Verify it type-checks**

Run (from `ui/`): `npx tsc -b --noEmit`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add ui/src/components/screen/TileSectionPicker.tsx
git commit -m "feat(v2/ui): TileSectionPicker dropdown with lazy thumbnails"
```

---

## Task 8: Wire the picker into ScreenDetailPanel

**Files:**
- Modify: `ui/src/components/screen/ScreenDetailPanel.tsx` (imports; props; "Graphics (DataPointer)" section ~lines 386–395)

- [ ] **Step 1: Add imports, store hook, and a banks helper**

At the top of `ui/src/components/screen/ScreenDetailPanel.tsx`, add imports:

```tsx
import { useState } from 'react';
import { useRandomizerStore } from '../../store';
import { TileSectionPicker } from './TileSectionPicker';
```

Add this helper near the other module-level functions (e.g. above `getObjectSetDescription`). It mirrors the authoritative `get_bank_offset` value-range model from the backend:

```tsx
// Bank selection per half from the DataPointer (value-range model — matches
// the backend renderer's get_bank_offset, NOT the bit model).
function getBanks(datapointer: number): { top: number; bottom: number } {
  if (datapointer >= 0xC0) return { top: 1, bottom: 1 };
  if (datapointer >= 0x8F && datapointer < 0xA0) return { top: 1, bottom: 0 };
  if (datapointer >= 0x40 && datapointer < 0x8F) return { top: 0, bottom: 1 };
  return { top: 0, bottom: 0 };
}
```

- [ ] **Step 2: Use the store action inside the component**

Inside `ScreenDetailPanel(...)`, near the top of the function body (after the existing `const chrBankIndex = ...` lines ~235-237), add:

```tsx
  const updateScreenTiles = useRandomizerStore((s) => s.updateScreenTiles);
  const [tileNote, setTileNote] = useState<string | null>(null);
  const banks = getBanks(screen.datapointer);

  const handlePickTile = async (which: 'top' | 'bottom', globalIndex: number) => {
    setTileNote(null);
    const result = await updateScreenTiles(
      screen.index,
      which === 'top' ? { top_tiles: globalIndex } : { bottom_tiles: globalIndex }
    );
    if (result.datapointer_changed) {
      setTileNote(
        result.chr_changed
          ? 'Bank change also adjusted the DataPointer and CHR bank.'
          : 'Bank change also adjusted the DataPointer.'
      );
    }
  };
```

- [ ] **Step 3: Replace the two static TileSection rows**

In the "Graphics (DataPointer)" `DataSection` (~lines 391–394), replace the inner `<div className="border-t ...">` block:

```tsx
          <div className="border-t border-slate-700 mt-2 pt-2">
            <DataRow label="Top TileSection" value={`0x${screen.top_tiles.toString(16).toUpperCase()} (${screen.top_tiles})`} />
            <DataRow label="Bottom TileSection" value={`0x${screen.bottom_tiles.toString(16).toUpperCase()} (${screen.bottom_tiles})`} />
          </div>
```

with:

```tsx
          <div className="border-t border-slate-700 mt-2 pt-2 space-y-1">
            <TileSectionPicker
              which="top"
              currentByte={screen.top_tiles}
              currentBank={banks.top}
              chr={chrBankIndex}
              onPick={(g) => handlePickTile('top', g)}
            />
            <TileSectionPicker
              which="bottom"
              currentByte={screen.bottom_tiles}
              currentBank={banks.bottom}
              chr={chrBankIndex}
              onPick={(g) => handlePickTile('bottom', g)}
            />
            {tileNote && (
              <div className="text-xs text-amber-400 pt-1">{tileNote}</div>
            )}
          </div>
```

- [ ] **Step 4: Verify it type-checks and lints**

Run (from `ui/`): `npx tsc -b --noEmit`
Expected: no errors.
Run (from `ui/`): `npm run lint`
Expected: no new errors in the files touched.

- [ ] **Step 5: Commit**

```bash
git add ui/src/components/screen/ScreenDetailPanel.tsx
git commit -m "feat(v2/ui): clickable Top/Bottom TileSection with picker"
```

---

## Task 9: Build + manual verification

**Files:** none (verification only)

- [ ] **Step 1: Production build (frontend)**

Run (from `ui/`): `npm run build`
Expected: `tsc -b && vite build` completes with no errors.

- [ ] **Step 2: Backend suite green**

Run (from project root): `python -m pytest tests/ -q`
Expected: PASS (new logic/render tests pass; endpoint tests pass or skip if no ROM).

- [ ] **Step 3: Manual smoke (requires ROM in place)**

1. Start backend: `python -m uvicorn tmos_randomizer.api.server:app --reload` (or the project's documented run command), then load the default ROM in the UI.
2. Start UI: `npm run dev` (from `ui/`).
3. Open the Screens/map tab, click a screen to open the detail panel.
4. In "Graphics (DataPointer)", click the **Top TileSection** value → dropdown opens showing section thumbnails; scrolling lazily loads more.
5. Click a section in the current bank (index < 256) → the screen preview at the top of the panel updates; no DataPointer note appears.
6. Click a section with index ≥ 256 (marked `*`) → tiles update and the amber note about DataPointer/CHR change appears; the "DataPointer"/"CHR Bank Index" rows reflect the new value.
7. Repeat for **Bottom TileSection**.

- [ ] **Step 4: Final commit (if any manual fixups were needed)**

```bash
git add -A
git commit -m "chore(v2): tile-section picker manual-verification fixups"
```

---

## Self-review notes (addressed)

- **Spec coverage:** section preview endpoint (Task 3), tile update endpoint w/ DataPointer computation (Tasks 1, 4), client method + preview URL (Task 5), store merge action (Task 6), picker component with lazy thumbnails + all 471 + cross-bank flag (Task 7), panel wiring + cross-bank note (Task 8), data flow + error handling covered across tasks.
- **Bank-model landmine:** `resolve_tile_update`/`compute_datapointer` and the frontend `getBanks` both use the value-range model; the plan explicitly forbids `get_all_valid_datapointers`.
- **Type consistency:** `ScreenTilesUpdateResponse.screen: ScreenData`; store merges by `screen.index === response.screen.index` (backend returns `index = relative_index`, matching `ScreenData.index`); `updateScreenTiles` signature identical across client/store/component.
- **No UI unit tests:** project has no UI test harness; frontend tasks verify via `tsc`/`vite build` + eslint + manual. Introducing vitest is intentionally out of scope.
