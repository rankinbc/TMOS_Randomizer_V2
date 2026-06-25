# Hierarchical URL Routing (`#/tab/sub/id`) — Design

**Date:** 2026-06-25
**Status:** Approved, ready for implementation plan
**Area:** `ui/` (React + Zustand frontend)

## Goal

Make the URL reflect where you are in the app, and make the app reflect the URL.
Bookmark a location, paste the link, refresh the page, or use the browser
back/forward buttons — and land on the same tab, sub-tab, and selection.

Concretely, the motivating example: navigating to `#/enemies/roster/1c` opens the
Enemies tab, the Roster sub-tab, with enemy `0x1C` (Romsarb) selected in the
detail panel.

## Decisions (locked during brainstorming)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| URL style | **Hash** (`#/enemies/roster/1c`) | Zero-config: refresh + direct-paste work on the Vite dev server and any static host with no rewrite rules. |
| Scope (first pass) | **All tabs URL-addressable + Enemies fully deep** | Every top-level tab gets a URL; Enemies is the reference implementation for deep selection. Other tabs' deep selections follow later via the same pattern. |
| Id format | **Hex, no `0x`** (`1c`) | Matches `enemy_id_hex` shown in the roster list — what you see is what's in the URL. |
| Sub-tab in URL | **Explicit** (`#/enemies/roster/1c`) | Every sub-tab is bookmarkable; uniform scheme across tabs. |

## Current state (why a structural change is needed)

Navigation state is fragmented:

- `selectedTab` — **store-backed** (`store/index.ts`), drives `MainContent` view switching.
- Enemies sub-tab (`section`) — **local `useState`** in `EnemiesView.tsx`.
- Selected enemy id (`selectedId`) — **local `useState`** in `BattleRosterEditor.tsx`.

A URL can only reflect selection that is **observable**. The selected enemy and
sub-tab are trapped in component-local state, so the one structural change is to
**lift those two pieces into the store**. After that the router simply mirrors
store ↔ URL.

There is an existing one-shot cross-view deep-link mechanism (`focusTarget` in the
store, with `tab`/`section`/`kind`/`id` fields, consumed on arrival). That stays
as the cross-view "go here" command; it is distinct from the persistent
"I am here" location the router needs, but its Enemies handler will call the new
store setter instead of the removed local state.

## URL grammar

```
#/<tab>                      world | enemies | items | hero | allies | graphics | randomize | expert | debug
#/enemies/<sub>              roster | encounters | bosses | overworld
#/enemies/roster/<hexId>     e.g. #/enemies/roster/1c   (0x1C)
```

Normalization (applied on parse and when writing the canonical hash):

- `#/enemies` (no sub) → `#/enemies/roster`
- Unknown / missing tab → `world`
- Unknown / missing enemies sub-tab → `roster`
- Unparseable id → no selection (`null`)
- Id arriving before the roster has loaded is valid: the selection resolves once
  the enemy list is in (the panel shows "Select an enemy" until then).

## Components

### 1. `ui/src/routing/appRoute.ts` — pure, testable, no React/DOM
- `parseHash(hash: string): { tab: TabType; sub?: string; id?: number }` — applies all validation/normalization above.
- `hashForRoute(route: { tab: TabType; sub?: string; id?: number }): string` — builds the canonical hash.
- `idToHex(n: number): string` / `hexToId(s: string): number | null` — lowercase hex, tolerant of a leading `0x`, rejects non-hex.
- A small table mapping which tabs have sub-tabs / ids, so extending deep routing
  to other tabs later is a table edit, not new machinery.

### 2. `ui/src/routing/useAppRouting.ts` — sync hook (one effect set)
- **On mount:** parse `window.location.hash` → set `selectedTab` (+ `enemiesSection`, `enemiesSelectedId` when the tab is `enemies`), then normalize the hash in place.
- **Store → URL:** subscribe to `selectedTab` / `enemiesSection` / `enemiesSelectedId`; write the canonical hash whenever it changes.
- **URL → store:** `hashchange` listener (covers back/forward and manual edits) parses and updates those store fields.
- **Loop prevention:** every write (both directions) is guarded by an equality
  check — write only if the value actually differs — so a store-driven hash write
  and a hash-driven store write cannot ping-pong.

### 3. `ui/src/store/index.ts` — two new fields + setters
- `enemiesSection: 'roster' | 'encounters' | 'bosses' | 'overworld'` (default `'roster'`)
- `enemiesSelectedId: number | null` (default `null`)
- `setEnemiesSection(section)`, `setEnemiesSelectedId(id)`

### 4. `ui/src/components/views/EnemiesView.tsx`
- Remove the local `section` `useState`; read/write `enemiesSection` from the store.
- The existing `focusTarget` effect now calls `setEnemiesSection` instead of the
  removed local setter (behavior unchanged).

### 5. `ui/src/components/enemies/BattleRosterEditor.tsx`
- Remove the local `selectedId` `useState`; read/write `enemiesSelectedId` from the store.
- Selecting an enemy now updates the URL automatically via the router subscription.

### 6. `ui/src/App.tsx`
- Call `useAppRouting()` alongside the existing mount effects.

## Deliberate scope boundaries

- The **Encounters chapter** selector (`selectedChapter` local state in `EnemiesView`)
  stays local — it is a third level not in the motivating example. It is the next
  candidate to lift when desired.
- Other tabs are URL-addressable at the **tab level only** for now. Their deep
  selections (screen, tile, item, ally, …) follow this exact pattern later:
  a table entry in `appRoute.ts` + lifting that view's local selection into the store.
- No `react-router-dom` (or any) new dependency.

## Testing

- `ui/src/routing/appRoute.test.ts` (vitest, matching existing `*.test.ts` convention):
  - `parseHash` / `hashForRoute` round-trips.
  - Hex id parse/format (`1c` ↔ `28`, tolerate `0x1c`, reject non-hex).
  - Every normalization rule: unknown tab → `world`; missing/unknown sub → `roster`;
    bare `#/enemies` → `roster`; bad id → `null`.
- The hook's effects are thin enough to verify by hand in the browser
  (click a tab → URL updates; paste a deep link → correct tab/sub/selection;
  back/forward; refresh).

## Footprint

3 new files (`appRoute.ts`, `appRoute.test.ts`, `useAppRouting.ts`),
4 edited (`store/index.ts`, `EnemiesView.tsx`, `BattleRosterEditor.tsx`, `App.tsx`).
No new dependencies.
