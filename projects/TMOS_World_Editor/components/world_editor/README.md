# world_editor

**Purpose**: Streamlit interactive world-layout editor for the NES game "The Magic of Scheherazade" (TMOS). Loads a ROM file from `data/rom/`, parses its world-layout data via the shared `src/tmos_world/` library, and renders each of 5 chapters as a PIL-composited navigation map (tiles from TileSection bytes) with overlay toggles (tile opacity, collision edges, nav arrows, content-byte labels, section outlines). Users click a screen to open an edit panel (nav bytes, tile sections, content byte, event byte); edits are live-validated against the R-001..R-022 rule engine in `src/tmos_world/validation/`. Export buttons produce a simplified world-state JSON and a downloadable PNG of the current chapter map.

**Inputs**: `data/rom/` — drop `TMOS_ORIGINAL.nes` here before running

**Outputs**: `output/world_editor/<YYYY-MM-DD>_<description>/` — exported `world.json`, map-snapshot PNGs, optional session notes

**Pattern**: `dashboard.md` (adapted: image-centric Streamlit, not data-explorer; no pandas/plotly)

**Stack**: Python 3.11+ · Streamlit >=1.44,<1.46 · Pillow >=11 · streamlit-image-coordinates >=0.1.8

## How to run

From the project root:

```bash
pip install -r components/world_editor/requirements.txt
streamlit run components/world_editor/app.py
```

Opens at `http://localhost:8501`. Drop `TMOS_ORIGINAL.nes` into `data/rom/` first.

## Structure

```
components/world_editor/
├── README.md         # This file — purpose, inputs, outputs, how to run
├── app.py            # Streamlit entry point (stubbed flow; /execute-prp builds it out)
├── requirements.txt  # Component-pinned deps (streamlit, Pillow, streamlit-image-coordinates)
└── tests/            # Empty — /execute-prp writes tests alongside implementation
    └── __init__.py
```

All rendering, ROM parsing, and validation logic lives in `src/tmos_world/` — this component imports from there and does not duplicate it. Input data lives in `data/rom/` at the project root. Exports land in `output/world_editor/` at the project root.

---

**To extend this component**: edit `PRPs/source/INITIAL.md` and run `/generate-prp`. Don't modify files here directly for new work — let the PRP drive it.
