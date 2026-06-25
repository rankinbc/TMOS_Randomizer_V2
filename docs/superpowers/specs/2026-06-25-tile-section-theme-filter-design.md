# Tile-Section Theme Filter & Coherent Swap — Design

**Date:** 2026-06-25
**Status:** Approved (design); ready for implementation plan
**Area:** `projects/TMOS_Randomizer_V2` (FastAPI backend + React/TypeScript frontend)
**Scope:** Spec #3 of the tile-editing series. Builds on Spec #1 (Selected World Screen panel) and Spec #2 (tile-picker collision filter), both shipped. This adds the theme/biome dimension the collision filter deliberately deferred.

## Problem

The Edit-modal tile picker (after Spec #2) ranks the 471 sections by collision/edge fit, but
nothing stops a *thematically* incoherent screen — a dungeon-wall bottom paired with an
overworld-grass top, or browsing town sections when building an overworld screen. Collision
matching guarantees seams line up; it says nothing about whether the tiles *look like they
belong together*. Spec #2 explicitly deferred this because no theme classifier existed.

## Goal

Classify each of the 471 tile sections into one of **5 biomes** and use that to:

1. **Theme filter** — a dropdown that groups the picker by biome (defaulting to the screen's
   own biome), composing with the Spec #2 collision ranking.
2. **Coherent whole-screen swap** — suggest top+bottom pairs that are **same-biome AND
   collision-fitting**, so a one-click swap never mixes a dungeon bottom with an overworld top.

## Non-Goals

- No change to the collision filter's behavior; theme **composes** with it (Spec #2 stays as-is).
- No per-tile palette/CHR editing. CHR/palette are not used as the theme signal here.
- The theme map is a **reference classification** of each section's intrinsic biome (computed
  from as-loaded ROM usage); it is not recomputed live as the user edits screens.

## The 5 Biomes

`overworld · town · dungeon · maze · special`. Collapsed from the canonical `SectionType`
enum (`core/enums.py`):

| SectionType | biome |
|---|---|
| OVERWORLD | overworld |
| TOWN | town |
| DUNGEON, MINI_DUNGEON | dungeon |
| MAZE | maze |
| SPECIAL, BOSS, VICTORY, UNKNOWN | special |

## Key Insight (de-risks "no classifier exists")

A section's biome can be derived **empirically** from how the ROM uses it, with a deterministic
fallback. Both inputs already exist in V2:

- **`PARENTWORLD_TO_SECTION`** (`core/enums.py:205`) + **`WorldScreen.section_type`**
  (`worldscreen.py:207`): every screen already classifies to a `SectionType`.
- **`get_bank_offset(datapointer)`** (`rendering/screen_renderer.py`): resolves a screen's
  `top_tiles`/`bottom_tiles` bytes to **global** section indices `0..470`
  (`global = byte + bank_offset`), matching the convention Spec #2 already uses.
- **`read_tilesection` / `get_tilesection_grid`** (`validation/tiles/edges.py`) + the tile-ID
  category groupings in `validation/tiles/categories.py` and `knowledge/enums/tiles.md` for the
  tile-content tiebreaker.

## Architecture

Same shape as Spec #2: **backend precompute endpoint + client-side filtering.**

### Backend — theme classifier + endpoint

New module `validation/tiles/themes.py`:

- `BIOMES = ("overworld", "town", "dungeon", "maze", "special")`.
- `section_type_to_biome(section_type: SectionType) -> str` — the collapse table above.
- `score_tilesection_biome(tile_ids: list[int]) -> str` — counts the section's 32 tile IDs into
  biome buckets and returns the dominant one; **no categorized tiles → `"special"`**. Buckets
  (drawn from `categories.py` comments + `knowledge/enums/tiles.md`):
  - **maze:** `0x00–0x19` (maze walls)
  - **dungeon:** `0x53–0x6B` dungeon walls (excluding the walkable `0x5F`, `0x65`, `0x66`)
  - **town:** `0x86–0x9C` building walls, `0xA1–0xCF` town walls/structures, `0xD5–0xFE` structures
  - **overworld:** `0x22, 0x23, 0x47` trees, `0x43, 0x46` grass/desert, `0x73, 0x77–0x84` cliffs
  - **special:** `0x2F, 0x30` lava, `0x3F–0x42, 0x6F` water, `0x4C, 0x4F–0x52, 0xCB, 0xCC`
    dark-world, `0xDE, 0xF6–0xF9` underwater
  - (the exact membership lists are finalized against `categories.py` in the implementation plan)
- `compute_section_themes(game_world, rom_data) -> dict[str, str]`:
  1. **Reverse index (primary):** for every screen in every chapter, compute
     `top_global = top_tiles + top_off` and `bottom_global = bottom_tiles + bot_off` (from
     `get_bank_offset`), and append the screen's biome (`section_type_to_biome(screen.section_type)`)
     as a vote for each of those two section indices.
  2. For each global index `0..470`: if it has votes, theme = **plurality** biome; ties broken by
     `score_tilesection_biome`. If it has **no** votes, theme = `score_tilesection_biome`.
  3. Returns `{ "0": "overworld", ..., "470": "..." }` (471 entries, each in `BIOMES`).

Endpoint `GET /api/rom/tilesection-themes` → `{ "themes": {...} }`, ROM-gated (`400` when no ROM),
cached on `id(_rom_data)` (mirrors the Spec #2 walkability cache; `_game_world` derives from the
same ROM, so the single key is sufficient).

### Frontend

- **Client:** `getTileSectionThemes(): Promise<{ themes: Record<string,string> }>` (mirrors
  `getTileSectionWalkability`).
- **Store:** lazy session-cached `tileThemes: Record<string,string> | null` + `loadTileThemes()`
  (mirrors `tileWalkability` / `loadTileWalkability`).
- **Pure util** (new `themeFilter.ts`, or a small addition to `tileFilter.ts`):
  - `orderKey(globalIndex, mismatch, theme, targetTheme) → [offTheme, mismatch, globalIndex]`
    where `offTheme = (targetTheme !== 'all' && theme !== targetTheme) ? 1 : 0`. The picker sorts
    by this composite key — on-theme + collision-perfect first.
  - `coherentPairCandidates(themes, targetTheme) → number[]` — the section indices whose theme
    equals the target, fed into the existing Spec #2 `suggestPairs` so suggested pairs are
    same-biome and collision-fitting.

### UI (`ScreenEditorModal`)

- A **theme dropdown** above the section grid: `All · Overworld · Town · Dungeon · Maze · Special`,
  **defaulting to the current screen's own biome** (`tileThemes[currentTopGlobal]`, falling back to
  `'all'` until the table loads).
- **Soft grouping:** when a specific theme is selected, off-theme sections are **dimmed** and sorted
  after on-theme ones (never hidden), and each `SectionThumb` shows a small **biome tag/color dot**.
- **Composition with the collision filter:** the grid order is `ordered` sorted by the composite
  `[offTheme, collisionMismatch, globalIndex]` key. Theme = `All` → pure Spec #2 collision behavior;
  collision off → pure theme grouping. The two controls are independent and never conflict.
- **Coherent swap:** a "Coherent swap" button (next to Spec #2's "Suggest pairs") runs `suggestPairs`
  over `coherentPairCandidates(themes, targetTheme)` and applies a chosen same-biome, collision-fit
  pair via the existing atomic `onPickPair`.
- **Graceful degradation:** while `tileThemes` is null the dropdown shows a loading state and the grid
  is ungrouped (Spec #2 behavior unchanged).

## Files Touched

- `src/tmos_randomizer/validation/tiles/themes.py` — **new**: biome collapse, `score_tilesection_biome`,
  `compute_section_themes`.
- `src/tmos_randomizer/api/server.py` — **new** `GET /api/rom/tilesection-themes` (cached).
- `tests/test_tilesection_themes.py` — **new** backend unit + endpoint tests.
- `ui/src/api/client.ts` — `getTileSectionThemes()` + response type.
- `ui/src/store/index.ts` — `tileThemes` state + lazy `loadTileThemes()`.
- `ui/src/components/screen/themeFilter.ts` (+ `.test.ts`) — **new** pure composite-sort + candidate-filter util.
- `ui/src/components/screen/ScreenEditorModal.tsx` — theme dropdown, composite ordering, biome tags,
  Coherent-swap button.

## Testing

- **Backend (pytest):** `score_tilesection_biome` on synthetic tile lists (all dungeon-wall → dungeon,
  all grass → overworld, all building-wall → town, empty/uncategorized → special); `compute_section_themes`
  on a small synthetic `game_world` + ROM (a section voted overworld by its screens → overworld; an unused
  section falls to the tile-ID score; a tie resolves via tiles). Endpoint (TestClient): no-ROM → 400,
  populated → 471 entries each in `BIOMES`. Run with `PYTHONPATH` set to the worktree src (the package is
  editable-installed against the main tree).
- **Frontend (`themeFilter.ts`, pure, node-env vitest):** `offTheme` partitioning, composite sort-key
  ordering against collision mismatch, theme=`All` is a no-op, `coherentPairCandidates` filters to the
  target biome.
- **Modal wiring** verified by `tsc`/lint/manual (consistent with Spec #1/#2).
- **Manual:** dungeon screen → dropdown defaults to Dungeon, dungeon sections first (others dimmed with
  tags); switch to Overworld → grouping changes; enable collision too → on-theme + perfect-fit lead;
  "Coherent swap" → applies a same-biome top+bottom pair.

## Risks / Open Notes

- **`get_bank_offset` gap:** datapointer values `0xA0–0xBF` fall through to `(0,0)` in the current
  value-range model (a known "two bank models" gap). This affects a small set of screens' reverse-index
  votes; the tile-ID tiebreaker covers any section thereby left unvoted, so theme classification still
  resolves. Worth confirming during implementation that no biome is grossly mislabeled by it.
- **Mixed-use sections:** a section used across biomes gets a plurality label; the tile-ID score only
  breaks exact ties. This is acceptable — the soft (never-hide) UI means a "wrong" label only changes
  sort order, never availability.
- **Theme ≠ palette:** two sections of the same biome can still use different palettes; theme coherence is
  about tile *structure/biome*, not exact colors. Out of scope.
- Walkability/collision remains the Spec #2 concern; this spec only adds the biome dimension on top.
