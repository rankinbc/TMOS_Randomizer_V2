# Tile-Render Regression — Root-Cause Report

**Date:** 2026-06-17
**Investigator:** diagnostic agent (read-only)
**Branch:** `feat/coherence-and-repair` (HEAD = `7096bec`)
**Symptom:** World-view map tiles not showing (regression — rendered before, recently broke)

---

## TL;DR

The World-view tile-render **code path is fully intact** and, when exercised over real
HTTP against the running backend, **serves correct tile PNGs (HTTP 200, image/png,
9393 bytes, 15 real tile images composited)**. None of the recent suspect merges
(`7096bec` coherence/repair/grow, `c3d92f0` Phase-3 Enemies) touched any file on the
render path. **I could not reproduce the regression from code+git+runtime analysis** —
the backend renders, the assets exist, CORS allows the origin, the frontend wiring is
unchanged. The breakage is therefore almost certainly a **runtime/stale-state condition
on the user's machine, not a code regression in the render path.** Confidence on
"no code regression in render path": **HIGH**. Confidence on the specific runtime cause:
**LOW–MEDIUM** (needs the running app to confirm).

---

## 1. The exact data path (confirmed)

The "World screen renderer" (the map view that composites screens) renders tiles as
**server-rendered PNG `<img>` tags**, NOT raw bytes or client-side compositing:

```
WorldView.tsx  (selectedTab === 'world')
  → viewMode === 'navigation'  →  NavigationMapView.tsx
        → ScreenMini  (components/screen/ScreenRenderer.tsx)
              → <img src={`${API_BASE}/api/rom/render/{chapter}/{screen}
                            ?scale=4&t={top_tiles}&b={bottom_tiles}
                            &d={datapointer}&ws_color={worldscreen_color}`} />
  → viewMode === 'grid'        →  ScreenGrid.tsx   (colored cells only — NO tiles, by design)
```

- `API_BASE` = `import.meta.env.VITE_API_URL || 'http://localhost:8000'`
  (`ScreenRenderer.tsx:20`). No `.env` and **no Vite proxy** exist
  (`ui/vite.config.ts` is the bare default), so the image is fetched **cross-origin**
  directly from the backend on `:8000`.
- Backend endpoint: `render_screen` at
  `projects/TMOS_Randomizer_V2/src/tmos_randomizer/api/server.py:882`. It reads the
  screen from the in-memory `_game_world` (the `?t/b/d/ws_color` query params are
  **cache-busting only** — the actual render uses `screen.top_tiles` etc. from the ROM)
  and returns a PNG via `_screen_renderer.render_screen_to_bytes(...)`.
- Renderer: `rendering/screen_renderer.py::ScreenRenderer._load_tile_image` loads tile
  PNGs from `ASSET_PATHS["tiles"]` =
  `<repo-root>/temp/github-clones/TMOS_Romhack1/Images/TileImages` (configured in
  `server.py:3363`). On a miss it falls back to a flat ground-color block — that flat
  fallback is the historical "screens don't render properly" look.
- `_screen_renderer` is initialized inside the ROM-load endpoints (`upload_rom`
  `server.py:342`, `_autoload_default_rom` `server.py:3541`, and `/api/rom/load-default`).
  Note: the `startup()` handler (`server.py:3555`) does **not** auto-load the ROM, so the
  renderer is null until the UI loads a ROM (Header "Load Default" or upload). After load
  it is initialized.

A *separate* per-tile path exists in `TileGridView.tsx` (the single-screen 8×6 grid
inspector) that uses static `/tiles/*.png` from `ui/public/tiles` — that directory exists
with 159 PNGs, so that path also has its assets.

## 2. Git regression hunt — render path UNCHANGED by the suspect merges

`git diff --stat` of both suspect merges against the render-path files returns **empty /
no render-path files**:

- `7096bec` (coherence/repair/grow merge): touched **0** files under
  `api/server.py`, `rendering/`, `ui/src/components/screen/`, `ui/src/components/views/`,
  `ui/src/api/`, `ui/src/store/`.
- `c3d92f0` (Phase-3 Enemies merge): touched `server.py` (+13 lines: the new
  `/api/rom/enemies/selectable` endpoint only), `client.ts` (+8: `getSelectableEnemies`),
  `store/index.ts` (+31: selectable-enemies / expert-unlock), and Enemies/Advanced/Expert
  tab components. **It did NOT touch** `NavigationMapView.tsx`, `ScreenRenderer.tsx`,
  `ScreenGrid.tsx`, `WorldView.tsx`, `MapView.tsx`, the render endpoint, or `ASSET_PATHS`.

Per-file `git log` confirms the last meaningful edits to the render path predate the merges:
- `rendering/screen_renderer.py` — last touched `e8a2d48` / `891ed85` (pre-merge).
- `ScreenRenderer.tsx` (ScreenMini) — last touched `891ed85` (pre-merge).
- `NavigationMapView.tsx` — last touched `cf505af` (context-menu; pre-merge).
- `ASSET_PATHS["tiles"]` line — last changed in `891ed85`; stable since
  (`git log -L 3357,3363:...server.py`).
- `ui/vite.config.ts`, `API_BASE` — unchanged since the initial commit `e7f0851`.

## 3. Runtime verification — backend renders correctly

Imported the server module: `IMPORT_OK`, `RENDERING_AVAILABLE = True` (PIL present).
The `/api/debug/validate` 500 is an **isolated, unrelated** bug — its
`from ..testing.validators import ...` is inside the function body (`server.py:1725`), so
it breaks only that one endpoint and does NOT take down the API or the render endpoint.

Direct renderer call (load ROM → render ch1/screen0):
- `tiles` path exists, **159 PNGs**.
- screen0 `top=0xD bottom=0x11 dp=0xD1` → **PNG 9393 bytes**, **15 tile images loaded
  from disk (all non-None)** — real tiles, not fallback blocks.
- `tiles.txt` is absent → renderer uses its hardcoded mapping (expected, fine).

Full HTTP test (uvicorn on :8137):
- `GET /` → 200
- `POST /api/rom/load-default` → 200
- `GET /api/rom/render/1/0?scale=1` → **HTTP 200, content-type image/png, size 9393**
- `GET /api/rom/render/status` →
  `{"rendering_available":true,"renderer_initialized":true,"rom_loaded":true,
    "tile_images_path":".../TMOS_Romhack1/Images/TileImages"}`

**The backend render path produces correct tile graphics end-to-end.**

## 4. Layer determination

- **Backend (endpoint/renderer):** WORKING — verified over HTTP. Not the regression.
- **Asset/data (CHR/tiles):** PRESENT — `temp/.../TileImages` (159) and `ui/public/tiles`
  (159) both populated. The untracked `extracted-data/images/TileImages/{27,28,49,4B}.png`
  are NOT on the active render path (the renderer reads `temp/github-clones/...`), so they
  are a red herring for this symptom.
- **Frontend (fetch/render):** wiring unchanged and correct (`selectedTab:'world'` and
  `viewMode:'navigation'` are the store defaults; `WorldView → NavigationMapView →
  ScreenMini` mounts the `<img>`). No prop/URL/endpoint drift found.

Because every layer checks out in isolation, the live symptom is most consistent with a
**runtime condition**, not a committed code change.

## 5. Most likely runtime causes (ranked) + proposed fix

These are the conditions that make the *working* code show blank/flat tiles. None require
a code change to the render math; the fix is to make a latent fragility robust.

**(A) Backend not running / wrong port / not reachable cross-origin (most likely).**
The World map's `<img>` goes to `http://localhost:8000` (hardcoded fallback, no proxy).
If the dev backend is on a different port, not started, or the browser blocks the
cross-origin image, every `<img>` fires `onError` → the colored-div fallback shows
(looks like "tiles not showing"). Other relative `/api/...` calls in the same component
(e.g. `fetch('/api/debug/spatial-analysis/...')`, `NavigationMapView.tsx:430`) would
*also* be silently failing because there is no Vite proxy and they use a relative URL —
strong corroborating signal if the map is otherwise janky.
- **Proposed fix (config, no logic change):** add a dev proxy in
  `projects/TMOS_Randomizer_V2/ui/vite.config.ts`:
  ```ts
  export default defineConfig({
    plugins: [react(), tailwindcss()],
    server: { proxy: { '/api': 'http://localhost:8000' } },
  });
  ```
  and make `ScreenRenderer.tsx` / `client.ts` use relative `/api/...`
  (i.e. `API_BASE = import.meta.env.VITE_API_URL || ''`). This removes the cross-origin
  image fetch and unifies all calls behind the proxy.

**(B) No ROM loaded in the session.** `startup()` does not auto-load the ROM, so until
the user clicks "Load Default"/uploads, `_screen_renderer is None` and
`/api/rom/render/...` returns **500 "Screen renderer not initialized"**
(`server.py:906`) → `<img>` onError → blank tiles.
- **Proposed fix (optional):** call `_autoload_default_rom()` from `startup()`
  (`server.py:3556`) when `DEFAULT_ROM_PATH` exists, so the renderer is ready before the
  first map paint. (Verify this matches intended UX before applying.)

**(C) `showTiles` / tile-opacity persisted off.** `NavigationMapView` persists
`navmap.overlay.tiles` and `navmap.overlay.tileOpacity` in localStorage
(`NavigationMapView.tsx:13-14,376-398`). If a prior session set "Show tiles" off or
opacity to 0, `effectiveTileOpacity` is 0 and `ScreenMini` does not render the `<img>`
at all (`ScreenRenderer.tsx:179`). This is per-browser state, would look exactly like
"tiles broke," and is invisible to git.
- **Proposed fix:** none in code required; clearing those localStorage keys (or toggling
  "Show tiles" back on / opacity > 0) restores tiles. Worth confirming first as it is the
  cheapest explanation and fully matches a "suddenly stopped showing" report.

## 6. What running the app would reveal (to pin it definitively)

1. Open DevTools → Network on the World tab. If `/api/rom/render/...` requests are
   **(net::ERR_CONNECTION_REFUSED / CORS / 404)** → cause (A). If **500** → cause (B).
   If **no render requests fire at all** → cause (C) (tiles toggle/opacity).
2. Check `GET http://localhost:8000/api/rom/render/status` in the browser:
   `renderer_initialized:false` confirms (B).
3. Inspect `localStorage` keys `navmap.overlay.tiles` / `navmap.overlay.tileOpacity`:
   `'0'` confirms (C).

---

## Confidence summary

| Claim | Confidence |
|---|---|
| Render-path code unchanged by `7096bec` and `c3d92f0` | HIGH (git diff empty for path) |
| Backend renderer produces correct tile PNGs | HIGH (verified over HTTP, 200/png/9393B) |
| Tile assets present and resolvable | HIGH (159 PNGs at the configured path) |
| Regression is runtime/state, not a render-path code change | MEDIUM–HIGH |
| Specific runtime cause (A/B/C) | LOW–MEDIUM (needs live app to disambiguate) |

**No fix applied (diagnostic-only).**

---

## 500 repro (2026-06-17)

**Method:** Launched a clean instance of the FastAPI app on port **8011** (not :8000, which is
the user's live server), `python -m uvicorn tmos_randomizer.api.server:app --host 127.0.0.1 --port 8011`,
NO `--reload`, stdout/stderr captured to a log. Reproduced the exact failing request before and
after loading the ROM, then killed the process and freed the port.

Target request:
`GET /api/rom/render/1/18?scale=4&t=131&b=138&d=15&ws_color=34`

### Result 1 — WITHOUT a ROM loaded
```
HTTP 400
{"detail":"No ROM loaded"}
```
Server log: `"GET /api/rom/render/1/18?... HTTP/1.1" 400 Bad Request`

There is **no traceback** — this is a deliberate guard, not an exception. `render_screen`
(`server.py:900-901`) does `if _game_world is None: raise HTTPException(status_code=400, detail="No ROM loaded")`.
So the no-ROM condition returns **400, never 500**, and has done so since the initial commit
(`git log -L 900,901` → `e7f0851 Initial commit`).

### Result 2 — WITH the default ROM loaded
`POST /api/rom/load-default` → `HTTP 200` (5 chapters, 262160 bytes, `rendering_available:true`).

Same request again:
```
HTTP 200  image/png  22323 bytes
```
Contrast `GET /api/rom/render/1/0?scale=4` → `HTTP 200 image/png 29580 bytes`. Both valid PNGs.
Repeated 1/18 → 200 again (stable).

### Key data point — the URL params ARE vanilla 1/18's real values
`GET /api/rom/screen/1/18` on the vanilla ROM returns exactly:
`top_tiles=131, bottom_tiles=138, datapointer=15, worldscreen_color=34` — i.e. the `t/b/d/ws_color`
query params are just a mirror (cache-buster) of the screen's own bytes. **The render endpoint
ignores `t`/`b`/`d` entirely** (signature `server.py:882-888` only binds `chapter_num, screen_index,
scale, ws_color`); it renders from `screen.top_tiles/bottom_tiles/datapointer` read from the loaded
ROM (`server.py:921-928`). So these byte values are NOT exotic and do NOT crash the renderer — the
renderer composites them into a 22 KB PNG without error.

### Definitive root cause
On the current `master` code, **the 500 is NOT reproducible** for this request. The only two
reachable outcomes are:
1. **No ROM in memory → HTTP 400** ("No ROM loaded"), and
2. **ROM loaded → HTTP 200** valid PNG (for both 1/18 and 1/0).

Therefore the live 500 the user observed on :8000 is **a runtime/state condition on that specific
running server, not a renderer bug for screen 1/18 or these byte params**. The render path is intact.
Most plausible explanations for the live 500, in order:
- The live :8000 server is running an **older / diverged build** of `server.py` whose no-ROM (or
  renderer-not-initialized) branch returned 500 instead of the current 400 — i.e. a stale process
  that predates the current guard. (The fix below hardens this regardless.)
- The live server hit the **`_screen_renderer is None`** guard (`server.py:906-907`, which *does*
  return 500) — e.g. ROM loaded but `ScreenRenderer` failed to construct because the tiles asset
  path didn't resolve in that process. On this clean instance the path resolved
  (`...\TMOS_Romhack1\Images\TileImages`) and the renderer built fine, so it returned 200.
- A genuine exception inside `render_screen_to_bytes` on the live server's *mutated/randomized*
  in-memory ROM state (not vanilla) → caught at `server.py:940-941` → `500 "Rendering failed: ..."`.
  Not reproducible here because the loaded ROM is vanilla and renders cleanly.

### Does startup auto-load a ROM?
**No.** `startup()` (`server.py:3555-3565`) only calls `configure_asset_paths()` and prints that a
default ROM is *available* — it does **not** call `_autoload_default_rom()`. A ROM is only loaded on
explicit `POST /api/rom/load-default` (`server.py:3568`) or an upload. So a freshly started server
has `_game_world is None` and every render returns **400 until a ROM is loaded**. If the front-end
issues tile renders before the user loads a ROM, it will see 400s (which a naive client may surface
as a generic failure).

### Proposed fix (NOT applied — diagnostic only)
The renderer path is correct; the actionable hardening is to surface the actual exception so a live
500 is diagnosable instead of opaque, and (optionally) make startup auto-load when a default ROM
exists so renders don't fail pre-load.

1. **Make the 500 self-documenting** — `src/tmos_randomizer/api/server.py:940-941`, in
   `render_screen`'s `except`, log the full traceback server-side before raising:
   ```python
   except Exception as e:
       import logging, traceback
       logging.getLogger("tmos.render").error(
           "render_screen failed ch=%s idx=%s: %s\n%s",
           chapter_num, screen_index, e, traceback.format_exc(),
       )
       raise HTTPException(status_code=500, detail=f"Rendering failed: {str(e)}")
   ```
   This guarantees the next live 500 leaves a traceback in the log (the current handler swallows it
   into a one-line `detail`).

2. **(Optional) Auto-load the default ROM at startup** so renders don't 400/500 before a manual
   load — `src/tmos_randomizer/api/server.py:3555-3565`, add inside `startup()` after the prints:
   ```python
   if DEFAULT_ROM_PATH and DEFAULT_ROM_PATH.exists():
       _autoload_default_rom()
   ```
   `_autoload_default_rom()` already exists (`server.py:3517`), is exception-guarded, and builds the
   `ScreenRenderer`. This removes the "no ROM loaded" failure window entirely.

**Recommendation:** apply fix #1 first (cheap, makes the live 500 reproducible/diagnosable); decide
on #2 based on whether the deployed front-end expects a ROM to be pre-loaded.

**Server process cleanup:** my uvicorn worker (PID 25852) was terminated (`taskkill /T /F`);
`netstat` shows **no LISTENER on :8011** (only TIME_WAIT client sockets draining). Port is free.
