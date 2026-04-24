# tmos_world — shared library

The core library both components import from. Pure Python, no UI.

**Responsibilities:**
- Simplified world-layout data model (WorldScreen, Chapter, Section, TileSection — per §12 of the world-editor spec; no enemy/item/boss-stat types)
- ROM I/O (parse NES ROM bytes → `World`; serialize `World` → ROM bytes)
- PIL tile renderer (compose a chapter's navigation map as a single PIL image)
- Tile-compatibility analyzer (walkable-edge matching per §3.3 of the spec)
- Walkability / section BFS
- Validation rule engine (R-001..R-022 per §10 of the spec)

**Rule:** never reimplement any of this inside a component. If you need new functionality, add it here and consume from both sides.

**Reference spec:** `C:\claude-workspace\TMOS_AI\knowledge\reference\world-editor-spec.md`
