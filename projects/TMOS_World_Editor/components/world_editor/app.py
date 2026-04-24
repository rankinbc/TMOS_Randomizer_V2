"""world_editor — Streamlit dashboard entry point."""
from __future__ import annotations

import io
import sys
from pathlib import Path

import streamlit as st
from PIL import Image
from streamlit_image_coordinates import streamlit_image_coordinates

# Ensure project root is on sys.path so ``src.tmos_world`` imports resolve
# when Streamlit launches this file directly.
_COMPONENT_DIR = Path(__file__).resolve().parent
_PROJECT_ROOT = _COMPONENT_DIR.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from src.tmos_world.model import WORLDSCREEN_FIELD_NAMES  # noqa: E402
from src.tmos_world.rendering import render_chapter_map  # noqa: E402
from src.tmos_world.rendering.compose import THUMB_TILE_PX  # noqa: E402
from src.tmos_world.validation import validate_world  # noqa: E402

from components.world_editor import exports, state  # noqa: E402

ROM_DIR = _PROJECT_ROOT / "data" / "rom"


st.set_page_config(page_title="TMOS World Editor", layout="wide")
st.title("TMOS World Editor")

# ---------------------------------------------------------------------------
# ROM load — once per session
# ---------------------------------------------------------------------------
rom_files = sorted(ROM_DIR.glob("*.nes"))
if not rom_files:
    st.error(
        f"Drop `TMOS_ORIGINAL.nes` into `{ROM_DIR.relative_to(_PROJECT_ROOT)}` to begin."
    )
    st.stop()

try:
    world = state.load_world_if_needed(st.session_state, rom_files[0])
except Exception as err:  # pragma: no cover — IO / MD5 errors
    st.error(f"Failed to load ROM: {err}")
    st.stop()


# ---------------------------------------------------------------------------
# Cached map render — keyed on (chapter_idx, frozenset(overlays)).
# @st.cache_data returns a SHARED reference — the fragment copies before draw.
# ---------------------------------------------------------------------------
@st.cache_data(show_spinner=False)
def cached_chapter_map(chapter_idx: int, overlays_key: frozenset[str]) -> bytes:
    """Render chapter map and return PNG bytes (cache-safe — immutable bytes)."""
    img = render_chapter_map(world, chapter_idx, overlays=overlays_key)
    return exports.download_png_bytes(img)


# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------
left_col, right_col = st.columns([1, 3])

with left_col:
    st.subheader("Chapters")
    chapter_idx = st.radio(
        "Select chapter",
        options=list(range(len(world.chapters))),
        format_func=lambda i: f"Chapter {world.chapters[i].number}",
        label_visibility="collapsed",
        key="chapter_idx",
    )

    st.subheader("Overlays")
    overlays: set[str] = set()
    if st.checkbox("Collision edges", value=True):
        overlays.add("collision_edges")
    if st.checkbox("Nav arrows", value=False):
        overlays.add("nav_arrows")
    if st.checkbox("Content-byte labels", value=False):
        overlays.add("content_bytes")
    if st.checkbox("Section outlines", value=False):
        overlays.add("section_outlines")

    chapter = world.chapters[chapter_idx]
    st.subheader("Stats")
    st.metric("Screens", chapter.screen_count)
    st.metric("Past indices", len(chapter.past_indices))
    st.metric("Sections", len(chapter.sections))
    st.caption(f"ROM base: {chapter.base_rom_addr:#07x}")

    st.subheader("Export")
    description = st.text_input("Run description", value="session", key="export_desc")
    if st.button("Export world JSON + chapter PNGs"):
        run_dir = exports.export_json(world, description)
        st.success(f"Wrote {run_dir.relative_to(_PROJECT_ROOT)}")


with right_col:
    map_png = cached_chapter_map(chapter_idx, frozenset(overlays))
    coords = streamlit_image_coordinates(
        Image.open(io.BytesIO(map_png)),
        key=f"map-{chapter_idx}-{'-'.join(sorted(overlays))}",
    )
    screen_w_px = 8 * THUMB_TILE_PX
    screen_h_px = 6 * THUMB_TILE_PX

    selected_screen_idx: int | None = None
    if coords is not None:
        displayed_w = coords.get("width")
        displayed_h = coords.get("height")
        native_w = 16 * screen_w_px  # cols * screen_w in native pixels
        if displayed_w and displayed_h:
            scale_x = native_w / displayed_w
            click_x_native = coords["x"] * scale_x
            click_y_native = coords["y"] * scale_x  # assume square pixels
            col = int(click_x_native // screen_w_px)
            row = int(click_y_native // screen_h_px)
            idx = row * 16 + col
            if 0 <= idx < chapter.screen_count:
                selected_screen_idx = idx
                state.set_selected_screen(st.session_state, chapter_idx, idx)

    if selected_screen_idx is None:
        sel = state.get_selected_screen(st.session_state)
        if sel is not None and sel[0] == chapter_idx:
            selected_screen_idx = sel[1]

    st.divider()

    @st.fragment
    def edit_panel() -> None:
        sel = state.get_selected_screen(st.session_state)
        if sel is None:
            st.info("Click a screen on the map to open its edit panel.")
            return
        ch_idx, sc_idx = sel
        if ch_idx != chapter_idx:
            st.info(f"Selected screen is in chapter {world.chapters[ch_idx].number}. "
                    f"Switch to that chapter or click a screen here.")
            return
        screen = state.get_screen(st.session_state, ch_idx, sc_idx)
        st.subheader(f"Chapter {world.chapters[ch_idx].number} · Screen {sc_idx:#04x} ({sc_idx})")
        cols = st.columns(4)
        changed = False
        for i, name in enumerate(WORLDSCREEN_FIELD_NAMES):
            cur = getattr(screen, name)
            new_val = cols[i % 4].number_input(
                name,
                min_value=0,
                max_value=255,
                value=int(cur),
                step=1,
                key=f"fld-{ch_idx}-{sc_idx}-{name}",
            )
            if new_val != cur:
                state.update_screen_field(st.session_state, ch_idx, sc_idx, name, int(new_val))
                changed = True

        # Live validation (chapter-scoped so the panel is cheap on big chapters).
        chapter_issues = [
            iss for iss in validate_world(world)
            if iss.chapter_num == world.chapters[ch_idx].number
            and (iss.screen_index == sc_idx or iss.screen_index is None)
        ]
        if chapter_issues:
            st.error(f"{len(chapter_issues)} validation issue(s) on this screen/chapter:")
            for iss in chapter_issues[:25]:
                st.text(f"  [{iss.severity}] {iss.rule_id}: {iss.message}")
            if len(chapter_issues) > 25:
                st.caption(f"(+{len(chapter_issues) - 25} more)")
        else:
            st.success("No validation issues on this screen.")

        if changed:
            # Invalidate the cached chapter map so the next full rerun redraws.
            cached_chapter_map.clear()
            st.rerun(scope="fragment")

    edit_panel()


# ---------------------------------------------------------------------------
# Download buttons
# ---------------------------------------------------------------------------
st.divider()
dl1, dl2 = st.columns(2)
with dl1:
    st.download_button(
        label=f"Download chapter {chapter.number} map PNG",
        data=map_png,
        file_name=f"chapter_{chapter.number}_map.png",
        mime="image/png",
    )

with dl2:
    import json as _json

    from src.tmos_world.serialization import world_to_json as _world_to_json

    st.download_button(
        label="Download world.json",
        data=_json.dumps(_world_to_json(world), indent=2).encode("utf-8"),
        file_name="world.json",
        mime="application/json",
    )
