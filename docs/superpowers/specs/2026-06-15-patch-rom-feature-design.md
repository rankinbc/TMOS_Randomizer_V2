# Patch ROM Feature — Design

**Date:** 2026-06-15
**Project:** TMOS_Randomizer_V2 (Python backend + React/TypeScript UI)
**Status:** Approved for planning

## Goal

Add a "Patch ROM" action that collects **all modifications the user made during the
session** and downloads them as an edited `.nes` ROM file in the browser. Alongside the
ROM, optionally download a human-readable edit-log `.txt`.

The "Patch ROM" button already exists in the UI (`Header.tsx`) as a stub that alerts
"Not yet implemented". This feature makes it real.

## Background: where modifications live today

The FastAPI server holds two stores of state, and they are **not** currently merged:

| Store | Holds | How written today |
|-------|-------|-------------------|
| `_rom_data` (bytes) | Tile bank, player stats, enemy stats, encounter lineups/groups, EXP table, inventory caps | Each PATCH endpoint does `rom_array = bytearray(_rom_data)` → mutate → `_rom_data = bytes(rom_array)` |
| `_game_world` (objects) | WorldScreen navigation, tile sections, `parent_world`, **and** randomization apply-preview | Only via `ROMWriter.write_game_world()` — **never flushed into `_rom_data`** |

The existing `POST /api/apply` endpoint ignores both live stores; it re-applies a
randomization *plan* from an on-disk input ROM to an on-disk output path. It is therefore
**not** the mechanism for this feature.

There are exactly **three** sites that mutate `_game_world` WorldScreen objects (verified
by grep over `api/server.py`):

1. `update_screen_navigation` (PATCH) — sets `parent_world`, calls `disconnect_screens` /
   `connect_screens`; with `bidirectional=True` also mutates the neighbor screen.
2. `update_screen_tiles` (PATCH) — `set_tiles`, `datapointer`, `mark_modified`.
3. `apply_plan_preview` (POST) — runs the active strategy's `preview_plan` (or the legacy
   phase4/phase5 path), mutating many screens. Lab-adapter strategies mutate screen bytes
   directly inside this call.

The table-edit endpoints already write straight to `_rom_data` and never touch
`_game_world`, so they are already single-source.

## Decisions (locked with the user)

- **Delivery:** Browser download of the `.nes` (no server-side path writing). Works
  regardless of where the server runs.
- **Scope:** Bake in **every live edit** — both the `_rom_data` table edits and the
  `_game_world` screen/randomization edits.
- **Validation:** **Warn, don't block.** Run the existing navigability/connectivity check,
  surface warnings in the patch dialog, but always allow the download. Matches the existing
  soft gate in `apply-preview` and respects that manual editing is intentional.
- **Companion file:** Also offer a human-readable edit-log `.txt` (default on), built
  client-side from the store's `editLog`.

## Chosen approach: B — Flush-on-edit (single source of truth)

Make `_rom_data` the single authoritative buffer. Every WorldScreen mutation is flushed
into `_rom_data` immediately, so at patch time the endpoint simply streams `_rom_data`.

Rejected alternatives:

- **A — In-memory merge at save time:** Merge `_game_world` into a copy of `_rom_data`
  only when patching, via `ROMWriter`. Smaller change, but keeps two stores permanently
  divergent and re-derivable only at save.
- **C — Disk round-trip:** `ROMWriter.save()` to a temp file then `FileResponse`. Adds
  temp-file lifecycle for no benefit; we can stream from memory.

B's primary risk is `_game_world` ↔ `_rom_data` divergence. The design contains it by
(1) funnelling **all** screen writes through one helper and (2) a defensive reconcile at
patch time.

## Backend design (`api/server.py`)

### 1. Flush helper

```python
def _flush_screens(screens) -> int:
    """Serialize modified WorldScreen objects into the live _rom_data buffer.

    Returns the number of screens written.
    """
    global _rom_data
    if _rom_data is None:
        return 0
    rom_array = bytearray(_rom_data)
    count = 0
    for s in screens:
        off = CHAPTER_BASES[s.chapter] + s.relative_index * WORLDSCREEN_SIZE
        rom_array[off:off + WORLDSCREEN_SIZE] = s.to_bytes()
        count += 1
    _rom_data = bytes(rom_array)
    return count
```

- Single bytearray round-trip, matching the existing table-edit write pattern.
- Imports needed: `CHAPTER_BASES`, `WORLDSCREEN_SIZE` from `..core.constants` (already used
  by `ROMWriter`).
- All screen writes funnel through this one function — the linchpin of B's safety.

### 2. Call sites

- **`update_screen_navigation`:** after applying updates, `_flush_screens(chapter.get_screen(i) for i in modified_screens)` (the existing `modified_screens` set already includes the bidirectional neighbor).
- **`update_screen_tiles`:** `_flush_screens([screen])` after `mark_modified()`.
- **`apply_plan_preview`:** after the strategy/legacy path completes, flush all modified
  screens: `_flush_screens(s for ch in _game_world for s in ch.screens if s.is_modified)`.

### 3. New endpoint `POST /api/rom/patch`

- 400 if `_game_world` or `_rom_data` is None ("No ROM loaded").
- **Defensive reconcile:** first `_flush_screens(s for ch in _game_world for s in ch.screens if s.is_modified)`. Idempotent — guarantees a forgotten flush site cannot drop edits.
- Run `_check_world_connectivity(_game_world)`; collect warnings. **Never block.**
- Default filename `f"{Path(_rom_filename).stem}-edited.nes"`; accept optional `?filename=`
  query (sanitize to a bare filename — strip path separators).
- Return:
  ```python
  return Response(
      content=_rom_data,
      media_type="application/octet-stream",
      headers={
          "Content-Disposition": f'attachment; filename="{name}"',
          "X-Patch-Warnings": str(warning_count),
          "X-Screens-Modified": str(modified_count),
          # Expose custom headers to the browser fetch():
          "Access-Control-Expose-Headers": "X-Patch-Warnings, X-Screens-Modified, Content-Disposition",
      },
  )
  ```

## Frontend design

### API client (`ui/src/api/client.ts`)

`async patchRom(filename?: string): Promise<{ blob: Blob; warnings: number; screensModified: number; filename: string }>`

- `fetch` the endpoint (not the JSON `this.fetch` helper, since the body is binary).
- On non-OK, parse JSON `detail` for the error message (consistent with existing client).
- Read `X-Patch-Warnings` / `X-Screens-Modified` headers and the filename from
  `Content-Disposition`.
- Return the `Blob` plus metadata; the caller triggers the download.

### `PatchRomModal.tsx` (new, mirrors `RandomizeModal`)

- Renders only when `modalOpen === 'export'` (the `ModalType` already includes `'export'`).
- Fields/UI:
  - Filename text input, prefilled with `<romFilename stem>-edited.nes`.
  - Navigability-warnings panel (populated from the response headers / connectivity check).
  - "Download edit log too" checkbox, default checked.
  - Patch button (disabled while in flight).
- On Patch:
  1. `await api.patchRom(filename)` → trigger ROM download via object URL + temporary
     `<a download>` element, then `URL.revokeObjectURL`.
  2. If the checkbox is on, build `<stem>-edits.txt` from `store.editLog`
     (each entry: timestamp, `field`, `rom_offset`, `before` → `after`, optional `cascade`)
     and download it the same way.
  3. Close the modal.

### `App.tsx`

- Mount `<PatchRomModal />` next to the existing `<RandomizeModal />`.

### `Header.tsx` (fix the existing stub, lines ~179–191)

- Change `disabled={!romLoaded || !plan}` → `disabled={!romLoaded}` — manual edits do not
  require a randomization plan.
- Change `onClick={() => alert('Patch ROM - Not yet implemented')}` →
  `onClick={() => setModalOpen('export')}`.
- Keep the green styling; base the enabled styling on `romLoaded` alone.

## Testing

Backend pytest (under `tests/`):

- **Flush sync:** after a navigation edit, the 16 bytes in `_rom_data` at the screen's
  WorldScreen offset equal `screen.to_bytes()`.
- **Combined edits:** after a navigation edit **and** an EXP/table edit, `/api/rom/patch`
  bytes differ from the vanilla upload at **both** the WorldScreen offset and the table
  offset; the 16-byte iNES header and total file length are preserved.
- **Randomization:** create plan → apply-preview → patch; output reflects modified screens.
- **No ROM loaded:** `/api/rom/patch` returns 400.

(Frontend download wiring is verified manually; the binary-stream + `<a download>` path is
not unit-tested.)

## Out of scope (YAGNI)

- IPS/BPS patch formats — full ROM only.
- Server-side path writing (the existing `/api/apply` covers disk→disk plan application).
- Spoiler-log bundling and zip packaging — the `.nes` and a plain `.txt` edit log suffice.
