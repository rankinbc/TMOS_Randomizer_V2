# Design: ObjectSet Enemy Thumbnails (Stage B)

**Date:** 2026-06-15
**Project:** TMOS_Randomizer_V2 (React UI + FastAPI)
**Status:** Approved design — ready for implementation plan
**Parallel sibling:** `2026-06-15-world-screen-editor-modal.md` (Stage A). Stage A ships the
`ObjectSetField` component; **Stage B only enhances that component's internals** and adds a
read-only backend endpoint. No other Stage A files are touched.

## Problem

In the world-screen editor's ObjectSet field, show the enemies a given ObjectSet spawns,
with sprite thumbnails, so the user knows what they're choosing. Images live at
`projects/TMOS_Randomizer_V2/ui/public/sprites/OverworldEnemyImages/*.gif` (Vite-served at
`/sprites/OverworldEnemyImages/<file>`).

## Key facts (from `knowledge/structures/objectset.md`, ROM_VERIFIED HIGH)

- **Pointer tables** (per chapter), base address `0x37000`, 2-byte little-endian entries:
  Ch1 `0x38933`, Ch2 `0x389A9`, Ch3 `0x38A1F`, Ch4 `0x38A95`, Ch5 `0x38B0B`.
  `spawn_addr = 0x37000 + le16(pointer_table + objectset_id*2)`.
- **Spawn data**: a header (variable, "often 3 bytes") followed by 3-byte entries
  `[enemy_type][x][y]`. **Enemy type `0x00` = terminator.**
- **Overworld enemy type → name** table is documented (e.g. `0x18`=Gargoyle, `0x28`=Changarl,
  `0x30`=Mardul, `0x31`=Barzil, `0x14`=KillerFlower, `0x15`=DesertCrab, …).

## The one real risk — spawn-data header

The doc says the header is "variable, often 3 bytes" but doesn't fully specify it, so where
the `[type][x][y]` entries *begin* is uncertain. **The plan's first task is a read-only spike:**
dump the bytes at the spawn addresses for several known ObjectSets (e.g. World 1 `0x03` "4
Robbers", `0x05` "2 Bees" — the doc gives expected enemy counts/types) and determine the
header length / entry-start empirically before writing the parser. If the header proves
genuinely variable per set, the parser keys off the documented terminator and known counts to
validate. Ship behind a defensive parse that returns `[]` (→ no thumbnails, graceful) on any
inconsistency rather than guessing.

## Architecture

### Backend — new module + endpoint (additive; no edits to Stage A code)

**`src/tmos_randomizer/core/overworld_enemies.py` (new):**
- `OVERWORLD_ENEMY_IMAGES: dict[int, dict]` — curated map `type_byte → {name, image}` built
  from the enemies table cross-referenced with the actual `OverworldEnemyImages/` filenames
  (e.g. `0x18 → {"name": "Gargoyle", "image": "gargoyle.gif"}`). Types without a matching
  sprite map to `image: None`.
- `OBJECTSET_POINTER_TABLES: dict[int, int]` and `OBJECTSET_BASE = 0x37000` (or import from
  `core/constants.py` if already present there; add if not).
- `parse_objectset_enemy_types(rom: bytes, chapter: int, objectset_id: int) -> list[int]` —
  follows the pointer table, skips the header (length nailed by the spike), reads `[type][x][y]`
  triples until `type == 0x00` or a sane max (e.g. 16) is hit; returns the type bytes.
  Defensive: returns `[]` on out-of-range pointers or malformed data.

**`server.py`:** `GET /api/rom/objectset/{chapter_num}/{objectset_id}/enemies` →
`{ chapter, objectset_id, enemies: [{ type, name, image }] }` where `image` is the bare
filename (or null). 400 no-ROM; 400 objectset_id out of 0–255. Read-only; no mutation.

### Frontend — `ObjectSetField` internals only

- `client.ts`: `getObjectSetEnemies(chapterNum, objectsetId)` → the endpoint; an
  `objectSetImageUrl(file)` helper → `/sprites/OverworldEnemyImages/${file}`.
- `ObjectSetField.tsx`: on mount / when `value` or `chapterNum` changes, fetch the enemy list
  and render a small thumbnail strip below the select — each enemy as a `<img>` (with the
  enemy name as tooltip/caption); enemies without an image show a name chip. The select +
  numeric input (Stage A) are unchanged. Debounce/guard against rapid `value` changes; on
  fetch error or empty list, render nothing extra (graceful — Stage A behavior preserved).

The props contract (`value, chapterNum, chr, onChange`) is unchanged, so the editor modal is
untouched.

## Data flow

```
ObjectSet value changes → ObjectSetField fetches GET /api/rom/objectset/{ch}/{id}/enemies
  → render thumbnail strip from /sprites/OverworldEnemyImages/<file>
(select/input editing still drives onChange → store.updateScreenFields, unchanged)
```

## Error handling

- Unparseable/out-of-range spawn data → endpoint returns `enemies: []` → no thumbnails.
- Missing image file → per-`<img>` `onError` hides it / falls back to the name chip.
- No ROM → 400; field still usable (select/input).

## Testing

- Backend spike: a one-off read-only script/test that prints spawn bytes + parsed types for
  the documented World-1 ObjectSets; confirm against the doc's expected counts.
- Backend unit: `parse_objectset_enemy_types` on a synthetic ROM with a hand-built pointer
  table + spawn entries + terminator → returns the expected types; out-of-range → `[]`.
- Backend API: endpoint returns a well-formed list for a known set (skip-graceful if no ROM).
- Frontend: live verify in the app — open the editor on a screen with a known ObjectSet and
  confirm enemy thumbnails appear; change ObjectSet and confirm the strip updates.

## Integration with Stage A

- Shared files both stages append to: `server.py` (different endpoints) and `client.ts`
  (different methods) — additive, integrated by merging the two worktrees at the end.
- The only shared component, `ObjectSetField.tsx`, is created by Stage A with the fixed
  contract and enhanced by Stage B; if both worktrees modify it, Stage A's version is the base
  and Stage B layers the fetch+strip in. (To minimize conflict, Stage A keeps `ObjectSetField`
  minimal and self-contained.)
