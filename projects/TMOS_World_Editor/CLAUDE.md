# Project: TMOS World Editor

A specialized, standalone toolkit for inspecting, editing, and stress-testing the world-layout data of *The Magic of Scheherazade* (NES). Loads a ROM file, parses 739 WorldScreens across 5 chapters into a simplified in-memory model, renders chapter navigation maps (PIL-composited tile imagery), runs a rule-based validator (R-001..R-022), and batch-compares randomization/shuffling strategies.

**Stack**: Python 3.11+. Streamlit 1.44+ + Pillow 11 + `streamlit-image-coordinates` for the dashboard. Pandas 2.2 + tabulate 0.9 for the batch lab. Shared `src/tmos_world/` library owns ROM I/O, data model, rendering, analysis, and validation — components never duplicate that logic.

**Authoritative reference** (ROM constants, data structures, validation rules): `C:\claude-workspace\TMOS_AI\knowledge\reference\world-editor-spec.md`

---

## Project structure (STRICT — do not deviate)

```
TMOS_World_Editor/
├── CLAUDE.md
├── README.md
├── PRPs/
│   ├── v1_tmos_world_editor.md    # v1 mega-PRP
│   ├── templates/prp_base.md
│   ├── archive/
│   └── source/INITIAL.md
├── .claude/
│   ├── settings.local.json
│   └── commands/                  # /generate-prp, /execute-prp, /handoff
├── components/
│   ├── world_editor/
│   └── randomization_lab/
├── src/
│   └── tmos_world/                # Shared library — data model, ROM I/O, rendering, analysis, validation
├── notebooks/                     # Exploratory hypothesis-testing
├── data/
│   └── rom/                       # Drop TMOS_ORIGINAL.nes here (MD5 b3236db14c87f375e5f24a5b9b79f071)
├── output/
│   ├── world_editor/
│   └── randomization_lab/
└── .gitignore
```

**Enforcement rules:**
- Components live in `components/<name>/` only — never loose at project root
- All ROM inputs live in `data/rom/` — never inside a component folder
- All outputs land in `output/<component>/<YYYY-MM-DD>_<description>/` — never at project root, never overwriting prior runs
- Project-level folders `src/tmos_world/` (shared library — required by both components) and `notebooks/` (exploratory) are part of this project's declared structure — use each as described in its README; don't improvise alternatives
- **Never reimplement ROM parsing, tile rendering, or validation inside a component** — all of it lives in `src/tmos_world/`; components import from it. Adding new shared logic goes in `src/tmos_world/`, not in a component
- Never add a new top-level folder without updating this section first
- Never rename `components/`, `data/`, `output/`, `src/`, or `PRPs/`

**Python import path note:** both components import from `src.tmos_world`. Run from the project root so `src/` resolves on `sys.path` (or, if the v1 PRP adds a `pyproject.toml` with an editable install, use that instead). Flag from scaffolding: no `pyproject.toml` was generated at scaffold time; the v1 PRP should decide whether to add one or rely on project-root execution.

---

## Components

### world_editor (dashboard)

**Purpose**: Streamlit interactive editor. Loads a ROM, renders each chapter as a PIL-composited navigation map (tile-level imagery, overlay toggles for collision edges, nav arrows, content-byte labels, section outlines), lets the user click a screen to open an edit panel, live-validates edits against the R-001..R-022 rule engine, and exports world state as JSON and map snapshots as PNG.

**Inputs**: `data/rom/TMOS_ORIGINAL.nes`
**Outputs**: `output/world_editor/<YYYY-MM-DD>_<description>/` — `world.json`, `map_chapter<N>.png`, optional `session_notes.md`
**How to run**: `streamlit run components/world_editor/app.py`

**Gotchas:**
- `streamlit-image-coordinates` returns **display-pixel coords**, not PIL canvas coords — always convert via the returned `width`/`height` keys; never hardcode native pixel dimensions
- `st.fragment` cannot render into `st.sidebar` — place sidebar widgets (overlay toggles, chapter stats) in the main script body, outside any fragment
- `@st.cache_data` returns **shared PIL Image references** — call `.copy()` before any `paste()` or `ImageDraw` call on an overlay, or the cache entry mutates and corrupts subsequent renders
- **Never cache mutable world state** — `st.session_state["world"]` is the sole mutable source of truth; only cache read-only composites (e.g., `render_chapter_map` outputs keyed on `(chapter_id, frozenset(active_overlays))`)
- Use `st.rerun(scope="fragment")` inside the edit panel for live validation; plain `st.rerun()` redraws the whole map and discards the composited image
- Pin Streamlit `>=1.44,<1.46` — 1.45 changed markdown anchor slug behavior in ways that can break internal links
- Stack deviates from `patterns/dashboard.md` default: no pandas, no plotly (image-centric, not data-explorer). Don't re-introduce them without reason.

### randomization_lab (analysis)

**Purpose**: Batch experiment runner. Applies each registered randomization strategy to a fresh copy of the parsed world, captures a PNG screenshot, JSON world state, validation report (R-001..R-022), and rule-by-rule diff vs. the pristine baseline. Produces a top-level `summary.md` comparison table.

**Inputs**: `data/rom/TMOS_ORIGINAL.nes` (overridable via `--rom`), strategies in `components/randomization_lab/strategies/`
**Outputs**: `output/randomization_lab/<YYYY-MM-DD>_<description>/` with `run_manifest.json`, `summary.md`, and `<strategy>/{screenshot.png, world.json, validation_report.json, diff_vs_pristine.json}`
**How to run**: `python -m components.randomization_lab.runner --desc <run_description>` (or `--dry-run` to exercise the registry without a ROM)

**Gotchas:**
- Always call `image.close()` immediately after `img.save(...)` inside the strategy loop, then `gc.collect()`. PIL-compositing 3000px images per strategy is memory-heavy — GC alone is not reliable
- `DataFrame.to_markdown()` silently breaks on pandas builds missing tabulate — `tabulate>=0.9` must be in `requirements.txt` explicitly, not assumed as a pandas extra
- Seed `random` (and numpy's RNG, if used) **inside** the strategy callable, never at import time — module-level seeding is ignored by the runner's per-strategy seed parameter
- Parse the ROM and run `validate_world()` **exactly once** before the strategy loop; cache the pristine baseline in memory. Never re-validate pristine inside the loop — expensive and defeats determinism
- Run folder collision: when `<date>_<desc>` already exists, `RunWriter` appends a 6-char uuid hex suffix. Don't bypass it with ad-hoc `Path` construction
- Strategy registry is **plain-dict with explicit registration** (not decorator-based). Every new strategy module must be imported at the bottom of `strategies/__init__.py` so `register(...)` runs at import time

---

## Validation gates

```bash
# Lint both components and the shared library
ruff check components/ src/

# Imports resolve
python -c "import streamlit, PIL, streamlit_image_coordinates, pandas, tabulate; print('OK')"
python -c "from src.tmos_world.rom import parse_rom; print('tmos_world importable')"

# randomization_lab dry-run (no ROM needed — exercises registry + CLI)
python -m components.randomization_lab.runner --dry-run

# world_editor smoke (headless)
streamlit run components/world_editor/app.py --server.headless=true &
sleep 4 && curl -f http://localhost:8501 >/dev/null && echo "world_editor loads"
kill %1

# Full lab smoke (requires ROM in data/rom/)
python -m components.randomization_lab.runner --desc smoke-test --strategies identity
ls output/randomization_lab/*/run_manifest.json >/dev/null && echo "manifest OK"
ls output/randomization_lab/*/summary.md >/dev/null && echo "summary OK"
ls output/randomization_lab/*/identity/screenshot.png 2>/dev/null && echo "identity screenshot OK"
```

---

### Session Start

- **Read `.scaffolding/manifest.json` first if it exists.** Check `lifecycle.stage`:
  - `"plan"` — the v1 implementation plan is written at `PRPs/v1_tmos_world_editor.md` but hasn't been executed. Components are stubs. On a fresh session, tell the user "**This project is at stage 1 of 2 (planned). Components are stubs — not yet runnable.** Next step: `/execute-prp PRPs/v1_tmos_world_editor.md`." Never suggest running component entry commands; they won't work yet.
  - `"built"` (rare — `/execute-prp` normally deletes `.scaffolding/` on first full build, so this state is only seen mid-partial-build) — some components built, others still stubs. Check individual `scaffold_state` values before claiming the project is ready.
  - `.scaffolding/` missing entirely — the common built-project case. `/execute-prp` cleaned up scaffolder state on first successful build. Treat the project as fully built; entry commands in CLAUDE.md's "How to run" are runnable. Adding new features uses `/generate-prp` (reads `PRPs/source/INITIAL.md`) → `/execute-prp PRPs/<new-slug>.md`.
- If `HANDOFF.md` exists, read it first — a previous session paused mid-work.
- Otherwise, if `PRPs/source/INITIAL.md` is filled in and no PRP exists in `PRPs/` yet, that's the project intent — suggest `/generate-prp` (no arg) as the next step.
- Consult `PRPs/README.md` if the PRP workflow comes up.
- Check `PLANNING.md` / `TASK.md` if they exist.

### Context Discipline

Keep long sessions coherent — follow these automatically.

- **Scout files >400 lines before full-reading.** Grep for the target section first; Read only the slice you need.
- **Dispatch sub-agents for multi-file research and web lookups** (Task tool: Explore, general-purpose, Plan). Don't pollute the main session.
- **Externalize multi-step plans to files.** Write PRPs under `PRPs/`. Plans in files survive context resets; plans in conversation don't.
- **Propose `/handoff` proactively** when context is heavy or the user's about to pause. Don't let long sessions silently degrade.

### Code

- **No file over ~500 lines.** Split when approaching the limit.
- **Organize by feature**, following the language's conventions.
- **Externalize config and secrets** via env vars. Never hardcode credentials.

### Testing

- **Unit tests for new features.** At minimum: one expected-use, one edge case, one failure case.
- **When you change logic**, update affected tests.

### Docs

- **Update `README.md`** when features change or setup changes.
- **Comment the non-obvious why**, not what the code does.

### AI Behavior

- **Ask if uncertain** — don't assume missing context.
- **No hallucinated libraries or APIs** — verify packages exist before using them.
- **Confirm file paths and symbols** before referencing them.
- **Don't delete or overwrite existing code** without explicit instruction.

### Workflow

- **Default to the PRP workflow for new work.** New features, components, or multi-step changes go through `/generate-prp` → `/execute-prp`. If the user asks for non-trivial new work and no active (non-archived) PRP in `PRPs/` covers it, propose `/generate-prp` first and briefly explain why — the validation gates and checkpoints are what keep long sessions coherent across resets. Trivial fixes (typos, one-line bug fixes, doc tweaks, minor refactors) don't need a PRP — just do them.

### Project Cleanliness

- **Respect the project structure** declared at the top of this file. Never create new top-level folders without updating the structure block first. Components live in `components/<name>/`, inputs in `data/<source>/`, outputs in `output/<component>/<date>_<description>/`.
- **Tool caches outside the project.** Configure your language's tools to cache under `~/.cache/<tool>/` (or equivalent). For Python: set cache dirs in `pyproject.toml` and `PYTHONDONTWRITEBYTECODE=1` in `.env`.
- **Descriptive file and folder names.** Avoid `utils.py`, `data.csv`, `temp.txt` — prefer `rom_parser.py`, `pristine_ch1_validation.json`, etc.
- **Generated artifacts** always land under `output/<component>/<date>_<description>/` — never at the project root.
- **Output rotation.** Keep the latest ~5 runs directly under `output/<component>/`. Move older runs to `output/<component>/_archive/`.
- **PRP lifecycle.** Active plans live in `PRPs/`. On successful `/execute-prp`, the command moves the PRP to `PRPs/archive/<date>_<slug>.md`. Your spec lives at `PRPs/source/INITIAL.md` from scaffold onward; edit it in place for the next feature.
- **Throwaway / single-use files** → prefix with `temp_`.
- **Don't create files the user didn't ask for** — no `PLANNING.md`, `NOTES.md`, `TODO.md`, etc. unless requested.

### Task Completion

- **PRP workflow**: validation gates passing = work is done.

---

## Stack-specific rules

Python 3.11+. Format with `ruff format`; lint with `ruff check`. Test with `pytest`. Keep the simplified world-layout model strict: WorldScreen, Chapter, Section, TileSection only — no enemy/item/boss-stat types. Any new spec-driven invariant becomes a new rule in `src/tmos_world/validation/` keyed by an R-number, and a matching entry in the diff comparator.
