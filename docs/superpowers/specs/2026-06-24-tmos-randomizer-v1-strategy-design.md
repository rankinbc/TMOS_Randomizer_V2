# Design: `tmos_randomizer_v1` Strategy

**Date:** 2026-06-24
**Status:** Approved design, pending implementation plan
**Author:** Claude (brainstormed with rankinbc)

## Goal

Port the original C# randomizer from
[`rankinbc/TMOS_Romhack1`](https://github.com/rankinbc/TMOS_Romhack1) into
TMOS_Randomizer_V2 as a registered randomization **strategy** named
`tmos_randomizer_v1`.

**Why:** V1's defining property is that it reliably emits seeds that are
playable all the way through a high percentage of the time. We want that
dependable, known-good baseline available in the web app as a fallback while the
more sophisticated next-generation strategies (organic, grow, etc.) continue to
be developed. V1 is the safety net, not the frontier.

V1 does **not** alter the world map / navigation. It shuffles WorldScreen
*content* bytes, object/enemy placement, and encounter lineups, then validates,
and brute-forces seeds until validation passes.

## Source Algorithm (what the old "Randomize" button does from one seed)

Entry: `Form1.btn_modify_Click` → `ModifyRom(seed)` →
`WorldScreenCollection.Modify(worldIndex, random)` for each of 5 worlds.

Per world:

1. **Object-set shuffle** (`ModifyObjectSets2` / `ChangeObjectSets`) — for each
   hardcoded screen-group, assign a random *allowed* `DataPointer` (byte 8) and a
   random `ObjectSet` (byte 3) drawn from per-world lookup tables. Skips
   enemy-door, demon, and wizard screens, and any screen whose `Event` is not
   `0x00`/`0x08`. This is the enemy/object placement shuffle.
2. **Content shuffle** (`ModifyContents`) — collect the `Content` byte (byte 2)
   from a fixed per-world list of shuffleable screens (towns, palaces, dungeons,
   items), Fisher-Yates shuffle them, write them back. Wizard screens excluded.
   Random-encounter screens (`Content == 0xFF`) are blanked to `0x00`, then a
   matching count of encounters is re-placed onto random eligible overworld
   screens and their `RandomEncounterGroup.WorldScreen` pointers updated.
3. **Encounter lineup shuffle** (`ModifyRandomEncounterLineups`) — shuffle the
   monster bytes within encounter lineups, excluding `0x00`, `0x01`, `0xFF`.

Validation gates (per world, then global):

- **Time doors** (`MakeSureTimeDoorsAreAccessible`) — exactly **one** time-door
  screen (`Content == 0xC0`) among each world's hardcoded "past screens" list.
  Any count != 1 ⇒ reject.
- **Required content** (`CheckThatAllRequiredScreenContentsArePresent`) — each
  world must still contain its specific required content bytes (key towns,
  palaces, NPCs). Missing any ⇒ reject.
- **Other problems** (`CheckForOtherProblems`) — Faruk (`0x81`/`0xC0`) cannot be
  on an underwater W1 screen; no content-entrance screen may end up `0xFF`;
  wizard screens must be preserved.

On any rejection the GUI generates a fresh random seed and retries (timer-driven)
— i.e. **brute-force seeds until one passes**. This retry loop is the source of
the "high % playable" property.

On save (`SaveRom`): write the mutated 16-byte screens + encounter data back,
**plus a large fixed patch layer** unrelated to randomization — boss rebalance
(Gilga, Curly, Troll, Salamander, Goragora), halved world-enemy EXP, shop and
university costs, player clothes colors, start-screen tiles/title, intro dialog,
and the seed-number display text.

## Field Mapping (V1 → V2)

V1's raw 16-byte layout maps 1:1 onto V2's `WorldScreen` dataclass — same byte
order. No translation logic needed for the fields themselves:

| Byte | V1 (`DataContent`) | V2 (`WorldScreen`) |
|------|--------------------|--------------------|
| 0 | ParentWorld | parent_world |
| 1 | AmbientSound | ambient_sound |
| 2 | Content | content |
| 3 | ObjectSet | objectset |
| 4–7 | ScreenIndex R/L/D/U | screen_index_right/left/down/up |
| 8 | DataPointer | datapointer |
| 9 | ExitPosition | exit_position |
| 10–11 | Top/BottomTiles | top_tiles / bottom_tiles |
| 12–13 | WorldScreen/SpritesColor | worldscreen_color / sprites_color |
| 14 | Unknown | unknown |
| 15 | Event | event |

V1 addresses screens by **per-world relative index** into each
`WorldScreenCollection`, which reads sequentially from the world's screen start
address. V2's `Chapter.screens[relative_index]` reads from the same start
address, so the indices should align — **this must be verified first** (see
Risk 1).

## Design Decisions (confirmed)

1. **Behavior parity, not seed parity.** Reproduce the algorithm faithfully
   using V2's own seeded RNG. A seed will *not* reproduce the old C# tool's exact
   ROM (that would require reimplementing .NET `System.Random` plus V1's bizarre
   per-call re-seeding in `GetRandom()`). We keep V1's *behavior* and validity
   properties, not its byte output.
2. **Fixed tweak layer = optional toggle, default on.** Port the boss
   rebalance / shop / cosmetic / intro patches as a separable layer gated by
   config `v1.apply_tweaks` (default `true`). Faithful by default, removable.
3. **Validation: V1 gates + internal retry, then V2 oracle.** Replicate V1's
   time-door / required-content / other-problems gates and brute-force retry
   over derived sub-seeds inside `create_plan`, then additionally run V2's
   navigability oracle and record results into the plan.
4. **Minor V1 bug cleanup permitted** where it does not change validity-producing
   behavior (e.g. `GetDeepCopy` returning a shallow copy, duplicated indices in
   some hardcoded lists). The retry+gates behavior that yields playable seeds is
   preserved exactly.

## Module Layout

New self-contained package under the existing strategies dir:

```
src/tmos_randomizer/strategies/v1/
  __init__.py     # imports strategy so @register_strategy runs
  strategy.py     # TmosRandomizerV1(RandomizationStrategy)
  tables.py       # all V1 hardcoded data ported to Python constants
  algorithm.py    # pure shuffle + validation functions over a GameWorld
  tweaks.py       # the fixed patch layer as (address, bytes) tuples
```

Registered in `strategies/__init__.py` exactly like existing strategies.

### `tables.py`
Direct port of V1 magic data, organized per world (index 0–4):
- shuffle-screen lists (`W1..W5ShuffleScreens`)
- object-set screen-groups, each group's allowed datapointers, and the
  datapointer → objectset candidate lists
- per-world "past screens" lists (time-door scan)
- per-world required-content byte lists
- W1 underwater screens
- enemy-door / demon / wizard predicate constants

### `algorithm.py`
Pure functions operating on an in-memory V2 `GameWorld` (no disk I/O):
- `shuffle_object_sets(world, chapter_idx, rng)`
- `shuffle_contents(world, chapter_idx, rng)` (incl. encounter relocation)
- `shuffle_encounter_lineups(world, chapter_idx, rng)`
- predicates: `is_town`, `is_demon`, `is_wizard`, `is_enemy_door`,
  `has_time_door`, `has_content_entrance`
- gates: `time_doors_ok`, `required_content_present`, `other_problems_ok`
- `fisher_yates(seq, rng)` matching V1's `Shuffle` (i in 0..n, j in [i, n))

RNG: a single seeded `random.Random` stream per generation attempt
(behavior-parity simplification of V1's `GetRandom`).

### `strategy.py`
```python
@register_strategy
class TmosRandomizerV1(RandomizationStrategy):
    name = "tmos_randomizer_v1"
    description = "Original V1 randomizer: content/object/encounter shuffle " \
                  "with brute-force validity gates. Reliable playable baseline."

    def create_plan(self, seed: int) -> RandomizationPlan: ...
    def apply_plan(self, input_rom, output_rom, plan, generate_spoiler) -> RandomizationResult: ...
```

- `create_plan(seed)`:
  1. Load vanilla `GameWorld`.
  2. Internal retry loop over derived sub-seeds (`seed`, then a deterministic
     sequence) up to `v1.max_retries`. Each attempt: deep-copy the world, run the
     three shuffles, evaluate V1 gates. First attempt that passes all gates wins;
     record the winning sub-seed.
  3. Run V2's navigability oracle on the winning world; collect
     errors/warnings.
  4. Build a `RandomizationPlan` capturing winning sub-seed, per-screen byte
     mutations (content/objectset/datapointer), encounter lineup bytes, and
     encounter-group worldscreen assignments, plus `validation_errors` /
     `validation_warnings`.
  5. If no sub-seed passes within `max_retries`, return a plan with a blocking
     validation error (UI surfaces it).
- `apply_plan(...)`:
  1. Load fresh `GameWorld` from `input_rom`, apply recorded mutations,
     `mark_modified`, `patch_rom` to `output_rom`.
  2. If `v1.apply_tweaks`, apply the `tweaks.py` byte patches to `output_rom`.
  3. Generate spoiler if requested; return `RandomizationResult`.

### Config
Add to `config/default.yaml` a `v1` block:
```yaml
v1:
  apply_tweaks: true   # apply the fixed boss/shop/cosmetic patch layer
  max_retries: 1000    # brute-force attempts before giving up
```
And expose corresponding dataclass fields in `io/config_loader.py`. `general.strategy`
may be set to `tmos_randomizer_v1` to make it the default.

### UI
No frontend changes required — `/api/strategies` auto-discovers registered
strategies and the dropdown renders it. An optional "Apply V1 tweaks" checkbox
bound to `v1.apply_tweaks` may be added later.

## Implementation Scope (the "list")

Medium, well-bounded, mostly isolated. **No world-map / navigation work.**

1. **Alignment spike (gating)** — verify V2 `relative_index` ordering matches
   V1's per-world ROM screen order, and reconcile ROM offset conventions (V1 uses
   raw file offsets; confirm whether V2 addresses include the iNES header).
   Resolve before bulk work.
2. **Port data tables** (`tables.py`).
3. **Implement algorithm + validators** (`algorithm.py`).
4. **Encounter lineup/group read-write** — if V2's reader does not already model
   `RandomEncounterLineup` / `RandomEncounterGroup`, add read/write for those
   byte ranges (per-world addresses known from V1).
5. **Strategy class + registration + config block.**
6. **Tweak layer** (`tweaks.py`) + toggle.
7. **Validation/retry wiring** — V1 gates + internal retry, then V2 oracle.
8. **Tests** — see below.

## Testing

- **Determinism:** same `(seed, config)` ⇒ identical plan.
- **Gates:** generated worlds satisfy exactly-one-time-door-per-world, all
  required content present, no other-problem violations.
- **Playability rate:** over a sample of seeds, a high fraction pass the gates
  on the first or few attempts (sanity check of the retry budget).
- **Tweak layer:** with `apply_tweaks=true`, the documented addresses hold the
  expected bytes in the output ROM; with `false`, they match vanilla.
- **Output validity:** output ROM differs from vanilla, parses back into a valid
  `GameWorld`, and passes V2's navigability oracle.
- **Strategy discovery:** `list_strategies()` includes `tmos_randomizer_v1` and
  `/api/strategies` returns it.

## Risks / Unknowns

1. **Index/offset alignment (Risk 1)** — the one real unknown; could expand
   scope if V2's relative indexing or header handling differs from V1's raw
   offsets. Everything else is mechanical translation. *Mitigation: spike first.*
2. **Encounter lineup/group modeling** — V2 may not parse these yet; small but
   real addition if missing.
3. **Tweak-address offset convention** — V1's patch addresses are absolute file
   offsets; confirm they need the same header adjustment (if any) as V2's writes.

## Out of Scope

- Reproducing the old C# tool's exact byte output for a given seed.
- Any world-map / navigation randomization.
- New UI beyond automatic strategy discovery (optional tweaks checkbox is a
  later nicety).
