# tmos_randomizer_v1 Strategy — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a registered `tmos_randomizer_v1` randomization strategy to TMOS_Randomizer_V2 that faithfully ports the original C# tool's seed-driven ROM modification (content / object-set / encounter shuffle + brute-force validity gates) as a reliable "playable baseline" option in the web app.

**Architecture:** A self-contained `strategies/v1/` package. Pure, ROM-agnostic shuffle + gate functions operate on V2's in-memory `GameWorld`. A `run_v1` core wraps them in a deterministic brute-force retry loop over derived sub-seeds until V1's gates pass. The strategy follows the existing **lab-adapter pattern**: `create_plan` builds the required plan shell via phases 1–3; `preview_plan` runs the V1 algorithm in place (mutating screens) and the V2 reachability oracle; `apply_plan` calls `preview_plan`, writes screens via `patch_rom`, then applies encounter + optional tweak byte-patches to the output file.

**Tech Stack:** Python 3.13, pytest, dataclasses, `random.Random`. Reuses V2 modules: `io.rom_reader.load_rom`, `io.rom_writer.patch_rom`, `phases.phase1_planning/phase2_shaping/phase3_connection`, `phases.phase6_validation.analyze_reachability`, `core.encounter_lineups`, `core.encounter_groups`, `plan.RandomizationPlan/Result`, `strategies.base`/`registry`.

## Global Constraints

- **Behavior parity, not seed parity.** Use V2's seeded `random.Random`; do NOT attempt to reproduce .NET `System.Random` output. A seed need not byte-match the old C# tool.
- **Faithful gate/retry replication.** The brute-force-until-gates-pass behavior is the source of V1's high playable rate — replicate the gates and retry exactly, including V1's known quirks (documented per task). Minor code cleanup is allowed only where it does NOT change which worlds pass the gates.
- **No world-map / navigation mutation.** V1 only touches `content` (byte 2), `objectset` (byte 3), `datapointer` (byte 8), encounter lineup bytes, and encounter-group screen pointers. Never write nav bytes 4–7.
- **ROM offsets are file-absolute (include the 16-byte iNES header).** V2's `CHAPTER_BASES`, `LINEUP_BASE`, `GROUP_BASE`, and V1's tweak addresses all use the same absolute convention. Do not add/subtract a header offset.
- **Source of truth for all hardcoded tables:** the committed C# reference at `knowledge/code-analysis/TMOS_Romhack1_v1/`. Transcribe hex values from there verbatim.
- **Chapter↔world mapping:** V2 `chapter_num` is 1–5; V1 `world_index` is 0–4. Always `world_index = chapter_num - 1`. V1 tables are indexed 0–4.
- **Determinism:** same `(base_seed, config, input ROM)` ⇒ identical output ROM. The retry loop derives sub-seeds deterministically (never `random.Random()` without a seed).
- Run all commands from `C:/claude-workspace/TMOS_AI/projects/TMOS_Randomizer_V2`. Tests live under `tests/test_strategies/`.

---

## File Structure

```
src/tmos_randomizer/strategies/v1/
  __init__.py        # re-exports TmosRandomizerV1
  tables.py          # all V1 hardcoded data (transcribed from C# reference)
  predicates.py      # screen predicates + fisher_yates shuffle
  algorithm.py       # shuffle_object_sets, shuffle_contents, gates
  encounters.py      # lineup-shuffle + group-pointer byte patches
  tweaks.py          # fixed tweak layer + seed-text builder
  core.py            # run_v1 retry loop -> V1Outcome
  strategy.py        # TmosRandomizerV1(RandomizationStrategy)

src/tmos_randomizer/strategies/__init__.py   # MODIFY: import + export TmosRandomizerV1
config/default.yaml                          # MODIFY: add v1: block

tests/test_strategies/
  test_v1_predicates.py
  test_v1_algorithm.py
  test_v1_encounters.py
  test_v1_tweaks.py
  test_v1_core.py
  test_v1_strategy.py
  test_v1_integration.py   # ROM-gated (skipped without a real ROM)
```

---

## Task 1: Package scaffold + registration

**Files:**
- Create: `src/tmos_randomizer/strategies/v1/__init__.py`
- Create: `src/tmos_randomizer/strategies/v1/strategy.py`
- Modify: `src/tmos_randomizer/strategies/__init__.py`
- Test: `tests/test_strategies/test_v1_strategy.py`

**Interfaces:**
- Produces: `TmosRandomizerV1` (class, `name = "tmos_randomizer_v1"`), importable from `tmos_randomizer.strategies`. Registered in the strategy registry on import.

- [ ] **Step 1: Write the failing test**

```python
# tests/test_strategies/test_v1_strategy.py
from tmos_randomizer.strategies import list_strategies, get_strategy


def test_v1_is_registered():
    assert "tmos_randomizer_v1" in list_strategies()


def test_v1_class_metadata():
    cls = get_strategy("tmos_randomizer_v1")
    assert cls.name == "tmos_randomizer_v1"
    assert cls.description  # non-empty
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_strategies/test_v1_strategy.py -v`
Expected: FAIL — `"tmos_randomizer_v1"` not in registry (KeyError / assertion error).

- [ ] **Step 3: Create the minimal strategy stub**

```python
# src/tmos_randomizer/strategies/v1/strategy.py
"""V1 randomizer ported as a V2 strategy. See
docs/superpowers/specs/2026-06-24-tmos-randomizer-v1-strategy-design.md.
"""
from __future__ import annotations

from pathlib import Path

from ..base import RandomizationStrategy
from ..registry import register_strategy
from ...plan import RandomizationPlan, RandomizationResult


@register_strategy
class TmosRandomizerV1(RandomizationStrategy):
    name = "tmos_randomizer_v1"
    description = (
        "Original V1 randomizer: content / object-set / encounter shuffle with "
        "brute-force validity gates. Reliable playable baseline."
    )

    def create_plan(self, seed: int) -> RandomizationPlan:  # pragma: no cover - Task 9
        raise NotImplementedError

    def apply_plan(  # pragma: no cover - Task 9
        self,
        input_rom: Path,
        output_rom: Path,
        plan: RandomizationPlan,
        generate_spoiler: bool,
    ) -> RandomizationResult:
        raise NotImplementedError
```

```python
# src/tmos_randomizer/strategies/v1/__init__.py
"""V1 strategy package."""
from .strategy import TmosRandomizerV1

__all__ = ["TmosRandomizerV1"]
```

- [ ] **Step 4: Wire registration into the strategies package**

In `src/tmos_randomizer/strategies/__init__.py`, add the import (after the `from .organic import OrganicStrategy` line) and the export. Add:

```python
from .v1 import TmosRandomizerV1
```

and add `"TmosRandomizerV1",` to the `__all__` list (keep it alphabetically near the others).

- [ ] **Step 5: Run tests to verify they pass**

Run: `python -m pytest tests/test_strategies/test_v1_strategy.py -v`
Expected: PASS (both tests).

- [ ] **Step 6: Commit**

```bash
git add src/tmos_randomizer/strategies/v1/__init__.py \
        src/tmos_randomizer/strategies/v1/strategy.py \
        src/tmos_randomizer/strategies/__init__.py \
        tests/test_strategies/test_v1_strategy.py
git commit -m "feat(v1): register tmos_randomizer_v1 strategy stub"
```

---

## Task 2: Predicates + Fisher–Yates shuffle

**Files:**
- Create: `src/tmos_randomizer/strategies/v1/predicates.py`
- Test: `tests/test_strategies/test_v1_predicates.py`

**Interfaces:**
- Produces:
  - `is_demon(content: int) -> bool`
  - `is_wizard(content: int) -> bool`
  - `is_town(sprites_color: int) -> bool`
  - `is_enemy_door(parent_world: int, objectset: int) -> bool`
  - `has_time_door(content: int) -> bool`
  - `has_content_entrance(right: int, left: int, down: int, up: int) -> bool`
  - `fisher_yates(seq: list, rng: random.Random) -> None` (in-place; matches V1 `Tasks.Shuffle`)

Reference: `knowledge/code-analysis/TMOS_Romhack1_v1/WorldScreen.cs` (predicates), `Form1.cs` lines 549–559 (`Shuffle`).

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_strategies/test_v1_predicates.py
import random

from tmos_randomizer.strategies.v1.predicates import (
    is_demon, is_wizard, is_town, is_enemy_door,
    has_time_door, has_content_entrance, fisher_yates,
)


def test_is_demon_range():
    assert is_demon(0x21) and is_demon(0x2A)
    assert not is_demon(0x20) and not is_demon(0x2B)


def test_is_wizard_and_town_and_timedoor():
    assert is_wizard(0x01) and not is_wizard(0x02)
    assert is_town(0x12) and not is_town(0x11)
    assert has_time_door(0xC0) and not has_time_door(0xC1)


def test_is_enemy_door_known_pairs():
    assert is_enemy_door(0x61, 0x10)
    assert is_enemy_door(0x9F, 0x0D)
    assert not is_enemy_door(0x61, 0x0F)


def test_has_content_entrance():
    assert has_content_entrance(0xFE, 0x00, 0x00, 0x00)
    assert not has_content_entrance(0x00, 0x01, 0x02, 0x03)


def test_fisher_yates_is_deterministic_and_a_permutation():
    a = list(range(20))
    b = list(range(20))
    fisher_yates(a, random.Random(123))
    fisher_yates(b, random.Random(123))
    assert a == b                      # deterministic for a fixed seed
    assert sorted(a) == list(range(20))  # still a permutation
    assert a != list(range(20))         # actually shuffled
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `python -m pytest tests/test_strategies/test_v1_predicates.py -v`
Expected: FAIL — module `predicates` not found.

- [ ] **Step 3: Implement predicates.py**

```python
# src/tmos_randomizer/strategies/v1/predicates.py
"""Screen predicates + RNG, ported verbatim from V1 WorldScreen.cs / Form1.cs."""
from __future__ import annotations

import random

# isEnemyDoorScreen(): exact (parent_world, objectset) pairs from WorldScreen.cs:88-109
_ENEMY_DOOR_PAIRS = frozenset({
    (0x61, 0x10), (0x64, 0x0F), (0x67, 0x14), (0x67, 0x15),
    (0x69, 0x14), (0x69, 0x15), (0x6C, 0x0D), (0x6A, 0x14),
    (0x6A, 0x15), (0x6E, 0x0D), (0x9F, 0x0D),
})


def is_demon(content: int) -> bool:
    return 0x21 <= content <= 0x2A


def is_wizard(content: int) -> bool:
    return content == 0x01


def is_town(sprites_color: int) -> bool:
    return sprites_color == 0x12


def is_enemy_door(parent_world: int, objectset: int) -> bool:
    return (parent_world, objectset) in _ENEMY_DOOR_PAIRS


def has_time_door(content: int) -> bool:
    return content == 0xC0


def has_content_entrance(right: int, left: int, down: int, up: int) -> bool:
    return 0xFE in (right, left, down, up)


def fisher_yates(seq: list, rng: random.Random) -> None:
    """In-place shuffle matching V1 Tasks.Shuffle: for i in 0..n, j in [i, n)."""
    n = len(seq)
    for i in range(n):
        j = rng.randrange(i, n)   # C# Random.Next(i, n) -> [i, n)
        seq[i], seq[j] = seq[j], seq[i]
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `python -m pytest tests/test_strategies/test_v1_predicates.py -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/strategies/v1/predicates.py \
        tests/test_strategies/test_v1_predicates.py
git commit -m "feat(v1): screen predicates and fisher-yates shuffle"
```

---

## Task 3: Data tables

**Files:**
- Create: `src/tmos_randomizer/strategies/v1/tables.py`
- Test: `tests/test_strategies/test_v1_tables.py`

**Interfaces:**
- Produces (all lists indexed by `world_index` 0–4):
  - `SHUFFLE_SCREENS: list[list[int]]`
  - `PAST_SCREENS: list[list[int]]`
  - `REQUIRED_CONTENTS: list[list[int]]`
  - `OBJECT_SET_GROUPS: list[list[tuple[tuple[int, ...], tuple[int, ...]]]]` — per world, a list of `(screen_indices, allowed_datapointers)` groups
  - `DATAPOINTER_OBJECTSETS: list[dict[int, tuple[int, ...]]]` — per world, datapointer → candidate objectset bytes
  - `UNDERWATER_SCREENS: tuple[int, ...]` — the `w1UnderwaterScreens` array (applied to every world, faithful to V1)

**Transcription instructions (source of truth = committed C# reference):**
- `SHUFFLE_SCREENS[0..4]` ← `WorldScreenCollection.cs:148-152` (`W1..W5ShuffleScreens`).
- `PAST_SCREENS[0..4]` ← `WorldScreenCollection.cs:748-752` (`w1..w5PastScreens`).
- `REQUIRED_CONTENTS[0..4]` ← `RandomizeScript.cs:283-315` (`requiredContentsW1..W5`).
- `UNDERWATER_SCREENS` ← `WorldScreenCollection.cs:713` (`w1UnderwaterScreens`).
- `OBJECT_SET_GROUPS[wi]` and `DATAPOINTER_OBJECTSETS[wi]` ← `WorldScreenCollection.cs:190-448` (`ModifyObjectSets2`). For each `WorldIndex` branch: every `DataPointerObjectSets.Add(dp, {...})` becomes a `DATAPOINTER_OBJECTSETS[wi][dp] = (...)` entry; each `ScreenGroupN` + its `ScreenGroupNAllowedDataPointers` becomes a `(screen_tuple, datapointer_tuple)` pair in `OBJECT_SET_GROUPS[wi]`, in the SAME order the C# builds the `ScreenGroups`/`ScreenGroupDataPointers` arrays (order affects RNG draw sequence — preserve it).

> NOTE on faithful quirks you must preserve verbatim: some C# arrays contain
> duplicate indices (e.g. W3 `ScreenGroup1` repeats screens; W4 past-screens
> repeat `0x88`/`0x84`). Copy them as-is — do not de-duplicate. They affect the
> RNG draw count and historical output.

- [ ] **Step 1: Write the failing structural test**

Counts below are the exact element counts of the C# arrays — verify each against the reference file as you transcribe.

```python
# tests/test_strategies/test_v1_tables.py
from tmos_randomizer.strategies.v1 import tables as T


def test_shuffle_screen_counts():
    assert [len(x) for x in T.SHUFFLE_SCREENS] == [25, 25, 25, 21, 19]


def test_required_content_values():
    assert T.REQUIRED_CONTENTS[0] == [0x81, 0x83, 0x84]      # W1 Faruk/Kebabu/Aqua
    assert T.REQUIRED_CONTENTS[1] == [0x83]                  # W2 Epin
    assert T.REQUIRED_CONTENTS[4] == [0x80, 0x82, 0x83, 0x84, 0x85]  # W5


def test_past_screens_present_for_all_worlds():
    assert len(T.PAST_SCREENS) == 5
    assert all(len(p) > 0 for p in T.PAST_SCREENS)


def test_underwater_screens():
    assert T.UNDERWATER_SCREENS == (0x7A, 0x77, 0x82, 0x79, 0x78)


def test_object_set_groups_shape():
    assert len(T.OBJECT_SET_GROUPS) == 5
    assert len(T.DATAPOINTER_OBJECTSETS) == 5
    # Every allowed datapointer in a group must have an objectset candidate list.
    for wi in range(5):
        for screens, dps in T.OBJECT_SET_GROUPS[wi]:
            for dp in dps:
                assert dp in T.DATAPOINTER_OBJECTSETS[wi], f"world {wi} missing dp {dp:#x}"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_strategies/test_v1_tables.py -v`
Expected: FAIL — module `tables` not found.

- [ ] **Step 3: Transcribe tables.py from the C# reference**

Create `src/tmos_randomizer/strategies/v1/tables.py`. Transcribe every array exactly from `knowledge/code-analysis/TMOS_Romhack1_v1/`. Header skeleton (fill the `...` from the reference per the instructions above):

```python
# src/tmos_randomizer/strategies/v1/tables.py
"""V1 hardcoded data, transcribed verbatim from the committed C# reference at
knowledge/code-analysis/TMOS_Romhack1_v1/. Indexed by world_index 0..4.
Do not de-duplicate repeated indices — they are faithful to V1's RNG behavior.
"""

# WorldScreenCollection.cs:148-152
SHUFFLE_SCREENS = [
    [0x18, 0x1A, 0x3E, 0x40, 0x49, 0x62, 0x63, 0x6B, 0x6e, 0x6f, 0x70, 0x71, 0x61, 0x65, 0x67, 0x68, 0x66, 0x6C, 0x6A, 0x74, 0x75, 0x73, 0x77, 0x78, 0x79],  # W1
    # W2..W5 ← transcribe lines 149-152
]

# WorldScreenCollection.cs:748-752
PAST_SCREENS = [
    # W1..W5 ← transcribe
]

# RandomizeScript.cs:283-315
REQUIRED_CONTENTS = [
    [0x81, 0x83, 0x84],
    [0x83],
    [0x81, 0x82, 0x84, 0x85],
    [0x80, 0x81, 0x82],
    [0x80, 0x82, 0x83, 0x84, 0x85],
]

# WorldScreenCollection.cs:713
UNDERWATER_SCREENS = (0x7A, 0x77, 0x82, 0x79, 0x78)

# WorldScreenCollection.cs:190-448 (ModifyObjectSets2), per world_index.
# Each tuple is (screen_indices, allowed_datapointers) in C# array order.
OBJECT_SET_GROUPS = [
    # world 0: ScreenGroup1..5 with their AllowedDataPointers
    [
        ((0x01, 0x04, 0x03, ...), (0x0F, 0x0E, 0x10)),   # ← transcribe full ScreenGroup1
        # ScreenGroup2..5
    ],
    # worlds 1..4 ← transcribe
]

# datapointer -> objectset candidates, per world_index (from DataPointerObjectSets.Add(...))
DATAPOINTER_OBJECTSETS = [
    {0x0E: (0x44, 0x11, 0x12, ...), ...},   # world 0 ← transcribe
    # worlds 1..4 ← transcribe
]
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_strategies/test_v1_tables.py -v`
Expected: PASS. If a count assertion fails, re-check the corresponding C# array — do not change the test counts without confirming against the reference.

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/strategies/v1/tables.py \
        tests/test_strategies/test_v1_tables.py
git commit -m "feat(v1): port hardcoded screen/objectset/gate data tables"
```

---

## Task 4: Shuffle functions + gates (algorithm.py)

**Files:**
- Create: `src/tmos_randomizer/strategies/v1/algorithm.py`
- Test: `tests/test_strategies/test_v1_algorithm.py`

**Interfaces:**
- Consumes: `tables`, `predicates` (Tasks 2–3). A "screen" is any object with mutable attributes `content, objectset, datapointer, parent_world, event, sprites_color, screen_index_{right,left,down,up}` and a `relative_index`.
- Produces:
  - `shuffle_object_sets(screens, originals, world_index, rng) -> None` — mutates `screens` in place.
  - `shuffle_contents(screens, originals, world_index, rng) -> dict[int, int]` — mutates `screens`; returns `{group_entry_index: screen_index}` for relocated random encounters.
  - `time_doors_ok(screens, world_index) -> bool`
  - `required_content_present(screens, world_index) -> bool`
  - `other_problems_ok(screens, originals, world_index) -> bool`
  - `MAX_GROUP_ENTRIES_BY_WORLD: tuple[int, ...]` = `(15, 16, 17, 22, 19)` — V1 `RandomEncounterGroup` counts per world (`RandomizeScript.cs:413-417`), used to bound encounter relocation.

`screens` and `originals` are both **lists indexed by relative index** (`screens[i].relative_index == i`). `originals` is a frozen snapshot of the pre-mutation values (predicates that V1 evaluates against `OriginalWorldScreens` must read from `originals`).

Reference: `WorldScreenCollection.cs` — `ChangeObjectSets` (450-472), `ModifyContents` (596-709), `MakeSureTimeDoorsAreAccessible` (743-825), `CheckForOtherProblems` (711-740); `RandomizeScript.cs` required-content check (279-381).

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_strategies/test_v1_algorithm.py
import random
from types import SimpleNamespace

from tmos_randomizer.strategies.v1 import algorithm as A
from tmos_randomizer.strategies.v1 import tables as T


def _mk(content=0x00, objectset=0x00, datapointer=0x00, parent_world=0x00,
        event=0x00, sprites_color=0x00, nav=0x00):
    return SimpleNamespace(
        content=content, objectset=objectset, datapointer=datapointer,
        parent_world=parent_world, event=event, sprites_color=sprites_color,
        screen_index_right=nav, screen_index_left=nav,
        screen_index_down=nav, screen_index_up=nav,
        relative_index=0, _modified=False,
    )


def _world(n):
    screens = [_mk() for _ in range(n)]
    for i, s in enumerate(screens):
        s.relative_index = i
    return screens


def test_shuffle_contents_is_a_permutation_of_shuffled_screens():
    n = 200
    screens = _world(n)
    # Give each shuffleable screen a distinct content so we can track the multiset.
    for k, idx in enumerate(T.SHUFFLE_SCREENS[0]):
        screens[idx].content = 0x40 + k
    originals = [_mk(content=s.content) for s in screens]
    for i, o in enumerate(originals):
        o.relative_index = i

    before = sorted(screens[idx].content for idx in T.SHUFFLE_SCREENS[0])
    A.shuffle_contents(screens, originals, 0, random.Random(1))
    after = sorted(screens[idx].content for idx in T.SHUFFLE_SCREENS[0])
    assert before == after  # same multiset, just rearranged


def test_time_doors_ok_requires_exactly_one():
    screens = _world(200)
    # zero time doors -> not ok
    assert A.time_doors_ok(screens, 0) is False
    # exactly one in a past screen -> ok
    screens[T.PAST_SCREENS[0][0]].content = 0xC0
    assert A.time_doors_ok(screens, 0) is True
    # two -> not ok
    screens[T.PAST_SCREENS[0][1]].content = 0xC0
    assert A.time_doors_ok(screens, 0) is False


def test_required_content_present():
    screens = _world(200)
    assert A.required_content_present(screens, 1) is False  # needs 0x83 somewhere
    screens[5].content = 0x83
    assert A.required_content_present(screens, 1) is True


def test_other_problems_flags_blank_entrance():
    screens = _world(200)
    originals = _world(200)
    s = screens[10]
    s.screen_index_down = 0xFE   # an entrance screen
    s.content = 0xFF             # blanked -> problem
    assert A.other_problems_ok(screens, originals, 0) is False
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `python -m pytest tests/test_strategies/test_v1_algorithm.py -v`
Expected: FAIL — module `algorithm` not found.

- [ ] **Step 3: Implement algorithm.py**

```python
# src/tmos_randomizer/strategies/v1/algorithm.py
"""V1 shuffle + gate logic, ported from WorldScreenCollection.cs.

Operates on plain screen objects (anything with the ROM-byte attributes and a
relative_index). `originals` is a snapshot of pre-mutation values; predicates
that V1 evaluates against OriginalWorldScreens read from it.
"""
from __future__ import annotations

import random

from . import tables as T
from .predicates import (
    is_demon, is_wizard, is_enemy_door, has_time_door, has_content_entrance,
    fisher_yates,
)

# RandomEncounterGroup counts per world (RandomizeScript.cs:413-417).
MAX_GROUP_ENTRIES_BY_WORLD = (15, 16, 17, 22, 19)


def shuffle_object_sets(screens, originals, world_index, rng) -> None:
    """ModifyObjectSets2 + ChangeObjectSets (WorldScreenCollection.cs:190-472)."""
    dp_objsets = T.DATAPOINTER_OBJECTSETS[world_index]
    for screen_indices, allowed_dps in T.OBJECT_SET_GROUPS[world_index]:
        for idx in screen_indices:
            o = originals[idx]
            if (not is_enemy_door(o.parent_world, o.objectset)
                    and not is_demon(o.content)
                    and not is_wizard(o.content)
                    and o.event in (0x00, 0x08)):
                dp = allowed_dps[rng.randrange(len(allowed_dps))]
                screens[idx].datapointer = dp
                candidates = dp_objsets[dp]
                screens[idx].objectset = candidates[rng.randrange(len(candidates))]
                screens[idx]._modified = True


def shuffle_contents(screens, originals, world_index, rng) -> dict[int, int]:
    """ModifyContents (WorldScreenCollection.cs:596-709).

    Returns {group_entry_index: screen_index} for relocated random encounters.
    """
    shuffle_set = set(T.SHUFFLE_SCREENS[world_index])
    n = len(screens)

    should_shuffle = [False] * n
    contents: list[int] = []
    overworld_indexes: list[int] = []
    random_encounter_count = 0

    for i in range(n):
        o = originals[i]
        if i in shuffle_set and not is_wizard(o.content):
            should_shuffle[i] = True
            contents.append(o.content)
        elif o.content in (0xFF, 0x00):
            if o.content == 0xFF:
                random_encounter_count += 1
            screens[i].content = 0x00
            overworld_indexes.append(i)
        # else: demons / fixed screens -> leave alone

    fisher_yates(contents, rng)

    ci = 0
    for i in range(n):
        if should_shuffle[i]:
            screens[i].content = contents[ci]
            ci += 1

    # Re-place random encounters (faithful to V1's quirk: the random value is
    # used directly as a screen index, bounded by len(overworld_indexes)).
    group_assignments: dict[int, int] = {}
    if overworld_indexes:
        fisher_yates(overworld_indexes, rng)
        bound = len(overworld_indexes)
        max_entries = MAX_GROUP_ENTRIES_BY_WORLD[world_index]
        for entry in range(min(random_encounter_count, max_entries)):
            idx = rng.randrange(bound)
            # V1's while-guard, ported verbatim (note the C# operator precedence:
            # `||` binds looser than `&&`).
            while (screens[idx].content == 0xFF
                   or (screens[idx].event != 0x00
                       and screens[idx].screen_index_down != 0xFE
                       and screens[idx].screen_index_up != 0xFE
                       and screens[idx].screen_index_left != 0xFE
                       and screens[idx].screen_index_right != 0xFE)):
                idx = rng.randrange(bound)
            if screens[idx].sprites_color != 0x12:
                screens[idx].content = 0xFF
                group_assignments[entry] = idx
    return group_assignments


def time_doors_ok(screens, world_index) -> bool:
    """Exactly one time door among the world's past screens (cs:743-825)."""
    count = sum(1 for idx in T.PAST_SCREENS[world_index]
                if has_time_door(screens[idx].content))
    return count == 1


def required_content_present(screens, world_index) -> bool:
    """All required content bytes still exist somewhere (RandomizeScript.cs:279)."""
    present = {s.content for s in screens}
    return all(req in present for req in T.REQUIRED_CONTENTS[world_index])


def other_problems_ok(screens, originals, world_index) -> bool:
    """CheckForOtherProblems (cs:711-740). Underwater check applies every world,
    faithful to V1 (the w1UnderwaterScreens array is used unconditionally)."""
    for idx in T.UNDERWATER_SCREENS:
        if idx < len(screens) and screens[idx].content in (0x81, 0xC0):
            return False
    for i in range(len(screens)):
        s = screens[i]
        if (has_content_entrance(s.screen_index_right, s.screen_index_left,
                                 s.screen_index_down, s.screen_index_up)
                and s.content == 0xFF):
            return False
        if is_wizard(originals[i].content) and not is_wizard(s.content):
            return False
    return True
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `python -m pytest tests/test_strategies/test_v1_algorithm.py -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/strategies/v1/algorithm.py \
        tests/test_strategies/test_v1_algorithm.py
git commit -m "feat(v1): object-set/content shuffle and validity gates"
```

---

## Task 5: Encounter byte patches (encounters.py)

**Files:**
- Create: `src/tmos_randomizer/strategies/v1/encounters.py`
- Test: `tests/test_strategies/test_v1_encounters.py`

**Interfaces:**
- Consumes: V2 constants `LINEUP_BASE, LINEUP_COUNT, LINEUP_SIZE` (`core.encounter_lineups`) and `GROUP_BASE` (`core.encounter_groups`).
- Produces:
  - `GROUP_ENTRY_SIZE: int` = 3
  - `shuffle_lineup_patches(rom: bytes, chapter: int, rng: random.Random) -> list[tuple[int, int]]` — `(absolute_offset, new_byte)` patches that shuffle non-empty lineup monsters (excluding `0x00, 0x01, 0xFF`).
  - `group_pointer_patches(chapter: int, group_assignments: dict[int, int]) -> list[tuple[int, int]]` — `(absolute_offset, screen_byte)` patches setting each group entry's WorldScreen byte.

Reference: `WorldScreenCollection.cs` `ModifyRandomEncounterLineups` (529-577); group WorldScreen byte is offset 0 of each 3-byte entry (`RandomEncounterGroup.cs`). `chapter` is 1–5.

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_strategies/test_v1_encounters.py
import random

from tmos_randomizer.strategies.v1 import encounters as E
from tmos_randomizer.core.encounter_lineups import LINEUP_BASE, LINEUP_COUNT, LINEUP_SIZE
from tmos_randomizer.core.encounter_groups import GROUP_BASE


def _rom_with_lineups(chapter):
    base = LINEUP_BASE[chapter]
    size = LINEUP_COUNT[chapter] * LINEUP_SIZE
    rom = bytearray(0x40000)
    # Fill the lineup block with distinct "monster" bytes plus some empties.
    for k in range(size):
        rom[base + k] = 0x00 if k % LINEUP_SIZE == 0 else (0x10 + k)
    return bytes(rom)


def test_lineup_patches_preserve_multiset_and_keep_empties_fixed():
    chapter = 1
    rom = _rom_with_lineups(chapter)
    base = LINEUP_BASE[chapter]
    size = LINEUP_COUNT[chapter] * LINEUP_SIZE

    patches = E.shuffle_lineup_patches(rom, chapter, random.Random(7))
    patched = bytearray(rom)
    for off, val in patches:
        patched[off] = val

    before = sorted(b for b in rom[base:base + size] if b not in (0x00, 0x01, 0xFF))
    after = sorted(b for b in patched[base:base + size] if b not in (0x00, 0x01, 0xFF))
    assert before == after                      # same monsters, rearranged
    # start_byte slots (every LINEUP_SIZE-th) stay 0x00
    for li in range(LINEUP_COUNT[chapter]):
        assert patched[base + li * LINEUP_SIZE] == 0x00


def test_lineup_patches_are_deterministic():
    rom = _rom_with_lineups(2)
    p1 = E.shuffle_lineup_patches(rom, 2, random.Random(99))
    p2 = E.shuffle_lineup_patches(rom, 2, random.Random(99))
    assert p1 == p2


def test_group_pointer_patches():
    patches = E.group_pointer_patches(3, {0: 0x1B, 2: 0x40})
    base = GROUP_BASE[3]
    assert (base + 0 * E.GROUP_ENTRY_SIZE, 0x1B) in patches
    assert (base + 2 * E.GROUP_ENTRY_SIZE, 0x40) in patches
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `python -m pytest tests/test_strategies/test_v1_encounters.py -v`
Expected: FAIL — module `encounters` not found.

- [ ] **Step 3: Implement encounters.py**

```python
# src/tmos_randomizer/strategies/v1/encounters.py
"""Encounter lineup shuffle + group-pointer patches (V1 ModifyRandomEncounterLineups).

V2 models encounters read-only, so we emit (absolute_offset, byte) patches to be
applied to the output ROM after patch_rom().
"""
from __future__ import annotations

import random

from .predicates import fisher_yates
from ..base import RandomizationStrategy  # noqa: F401  (keeps import graph obvious)
from ...core.encounter_lineups import LINEUP_BASE, LINEUP_COUNT, LINEUP_SIZE
from ...core.encounter_groups import GROUP_BASE

GROUP_ENTRY_SIZE = 3  # RandomEncounterGroup.Size

_LINEUP_SKIP = (0x00, 0x01, 0xFF)


def shuffle_lineup_patches(rom: bytes, chapter: int, rng: random.Random) -> list[tuple[int, int]]:
    base = LINEUP_BASE[chapter]
    size = LINEUP_COUNT[chapter] * LINEUP_SIZE
    block = list(rom[base:base + size])

    occupied = [i for i, b in enumerate(block) if b not in _LINEUP_SKIP]
    monsters = [block[i] for i in occupied]
    fisher_yates(monsters, rng)

    patches: list[tuple[int, int]] = []
    for slot_pos, new_val in zip(occupied, monsters):
        if block[slot_pos] != new_val:
            patches.append((base + slot_pos, new_val))
    return patches


def group_pointer_patches(chapter: int, group_assignments: dict[int, int]) -> list[tuple[int, int]]:
    base = GROUP_BASE[chapter]
    return [
        (base + entry * GROUP_ENTRY_SIZE, screen_index)
        for entry, screen_index in sorted(group_assignments.items())
    ]
```

> If `from ..base import RandomizationStrategy` causes a circular import at
> collection time, delete that unused line — it is only there to document the
> package relationship and is not required.

- [ ] **Step 4: Run tests to verify they pass**

Run: `python -m pytest tests/test_strategies/test_v1_encounters.py -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/strategies/v1/encounters.py \
        tests/test_strategies/test_v1_encounters.py
git commit -m "feat(v1): encounter lineup-shuffle and group-pointer patches"
```

---

## Task 6: Fixed tweak layer (tweaks.py)

**Files:**
- Create: `src/tmos_randomizer/strategies/v1/tweaks.py`
- Test: `tests/test_strategies/test_v1_tweaks.py`

**Interfaces:**
- Produces:
  - `TWEAKS: list[tuple[int, bytes]]` — `(absolute_offset, bytes)` static patches.
  - `SEED_TEXT_OFFSET: int` = `0x038493`
  - `seed_text_bytes(seed: int) -> bytes` — 6 bytes; each decimal digit → its value (`'7'`→`0x07`), right-padded with `0x2C`.
  - `apply_tweaks(rom: bytearray, seed: int) -> None` — apply `TWEAKS` then the seed text, in place.

**Transcription instructions:** transcribe every `WriteByte` / `WriteBytes` / `fs.Seek+Write` from `RandomizeScript.cs` `SaveRom` (lines 42–222) into `TWEAKS`, EXCEPT the per-screen / encounter writes (those are handled by `patch_rom` + Task 5) and the dynamic seed text at `0x038493` (handled by `seed_text_bytes`). Each `WriteByte(fs, addr, v)` → `(addr, bytes([v]))`; each `WriteBytes(fs, addr, arr)` → `(addr, bytes(arr))`; each `fs.Seek(addr); fs.Write(arr)` → `(addr, bytes(arr))`.

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_strategies/test_v1_tweaks.py
from tmos_randomizer.strategies.v1 import tweaks as TW


def test_seed_text_digits_and_padding():
    assert TW.seed_text_bytes(12345) == bytes([0x01, 0x02, 0x03, 0x04, 0x05, 0x2C])
    assert TW.seed_text_bytes(7) == bytes([0x07, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C])


def test_known_tweak_present():
    # Gilga eye HP: WriteByte(fs, 0x1743f, 0x06)  (RandomizeScript.cs:64)
    assert (0x1743F, bytes([0x06])) in TW.TWEAKS
    # troopers cost 200: WriteByte(fs, 0x4577, 0xc8)
    assert (0x4577, bytes([0xC8])) in TW.TWEAKS


def test_apply_tweaks_writes_bytes_and_seed():
    rom = bytearray(0x40000)
    TW.apply_tweaks(rom, 12345)
    assert rom[0x1743F] == 0x06
    assert rom[TW.SEED_TEXT_OFFSET:TW.SEED_TEXT_OFFSET + 6] == bytes([1, 2, 3, 4, 5, 0x2C])
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `python -m pytest tests/test_strategies/test_v1_tweaks.py -v`
Expected: FAIL — module `tweaks` not found.

- [ ] **Step 3: Implement tweaks.py**

```python
# src/tmos_randomizer/strategies/v1/tweaks.py
"""V1 SaveRom fixed patch layer (boss rebalance, shop costs, cosmetics, intro).
Transcribed from RandomizeScript.cs:42-222. Excludes per-screen/encounter writes
and the dynamic seed text (handled elsewhere). Gated by config v1.apply_tweaks.
"""
from __future__ import annotations

SEED_TEXT_OFFSET = 0x038493

# (absolute_offset, bytes) — transcribe ALL static SaveRom writes here.
TWEAKS: list[tuple[int, bytes]] = [
    (0x03F687, bytes([0x4D, 0x20, 0xB8, 0xC4, 0xC6, 0xB8, 0x20, 0x4D, 0x4D, 0x20, 0xB9, 0xC5, 0xC7, 0xB9, 0x20, 0x4D, 0x4D, 0xB8, 0xB8, 0xC0, 0xC3, 0xB8, 0xB8, 0x4D, 0x4D, 0xB9, 0xB9, 0xC0, 0xC3, 0xB9, 0xB9, 0x4D])),
    (0x03F7C7, bytes([0x73, 0x73, 0x73, 0x73, 0x73, 0x73, 0x73, 0x73, 0xBF, 0x73, 0xBE, 0xBF, 0x73, 0x73, 0x73, 0xBE, 0x4D])),
    (0x1743F, bytes([0x06])),  # Gilga eye hp
    # ... transcribe the remaining writes from RandomizeScript.cs:64-217 ...
    (0x4577, bytes([0xC8])),   # troopers cost 200
]


def seed_text_bytes(seed: int) -> bytes:
    out = bytearray([0x2C] * 6)
    for i, ch in enumerate(str(seed)[:6]):
        out[i] = int(ch)
    return bytes(out)


def apply_tweaks(rom: bytearray, seed: int) -> None:
    for offset, data in TWEAKS:
        rom[offset:offset + len(data)] = data
    text = seed_text_bytes(seed)
    rom[SEED_TEXT_OFFSET:SEED_TEXT_OFFSET + len(text)] = text
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `python -m pytest tests/test_strategies/test_v1_tweaks.py -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/strategies/v1/tweaks.py \
        tests/test_strategies/test_v1_tweaks.py
git commit -m "feat(v1): fixed tweak layer and seed-text display"
```

---

## Task 7: run_v1 core (retry loop)

**Files:**
- Create: `src/tmos_randomizer/strategies/v1/core.py`
- Test: `tests/test_strategies/test_v1_core.py`

**Interfaces:**
- Consumes: `algorithm`, `encounters` (Tasks 4–5). A `GameWorld` (iterates chapters 1–5; each `chapter.screens` is a relative-index list; `chapter.chapter_num` is 1–5).
- Produces:
  - `@dataclass V1Outcome`: `success: bool`, `winning_seed: int`, `attempts: int`, `lineup_patches: list[tuple[int, int]]`, `group_patches: list[tuple[int, int]]`, `failures: list[str]`.
  - `derive_seed(base_seed: int, attempt: int) -> int` — deterministic; `attempt 0` returns `base_seed`.
  - `run_v1(game_world, rom: bytes, base_seed: int, max_retries: int) -> V1Outcome` — mutates `game_world` screens in place for the winning attempt.

**Behavior:** For each attempt, reset every screen's mutable bytes to the original snapshot, build a `random.Random(derive_seed(...))`, then per chapter (in order 1→5) run `shuffle_object_sets`, `shuffle_contents`, and compute `shuffle_lineup_patches`; evaluate all three gates per chapter. The first attempt where ALL chapters pass every gate wins: keep its screen mutations and accumulate its lineup + group patches. If none pass within `max_retries`, return `success=False` (screens left in the last attempt's state) with `failures` describing the last attempt.

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_strategies/test_v1_core.py
import random
from types import SimpleNamespace

from tmos_randomizer.strategies.v1.core import derive_seed, run_v1, V1Outcome
from tmos_randomizer.core.encounter_lineups import LINEUP_BASE, LINEUP_COUNT, LINEUP_SIZE


def test_derive_seed_attempt_zero_is_base():
    assert derive_seed(4242, 0) == 4242
    assert derive_seed(4242, 1) != 4242
    assert derive_seed(4242, 1) == derive_seed(4242, 1)  # deterministic


_ROM_FIELDS = (
    "parent_world", "ambient_sound", "content", "objectset",
    "screen_index_right", "screen_index_left", "screen_index_down",
    "screen_index_up", "datapointer", "exit_position", "top_tiles",
    "bottom_tiles", "worldscreen_color", "sprites_color", "unknown", "event",
)


class _Screen(SimpleNamespace):
    @property
    def is_modified(self):
        return getattr(self, "_modified", False)

    def mark_modified(self):
        self._modified = True


def _fake_game_world():
    """Build a 5-chapter world from a real vanilla-like screen template.

    For a unit test we only need the structure; load a real ROM in the
    integration test (Task 10). Here we fabricate worlds whose gates are easy
    to satisfy so the loop terminates quickly.
    """
    from tmos_randomizer.strategies.v1 import tables as T

    chapters = {}
    for ch in range(1, 6):
        wi = ch - 1
        n = 200
        screens = []
        for i in range(n):
            s = _Screen(relative_index=i, _modified=False,
                        **{f: 0 for f in _ROM_FIELDS})
            screens.append(s)
        # Ensure exactly one time door per world.
        screens[T.PAST_SCREENS[wi][0]].content = 0xC0
        # Seed required contents so the gate can pass.
        for k, req in enumerate(T.REQUIRED_CONTENTS[wi]):
            screens[T.SHUFFLE_SCREENS[wi][k]].content = req
        chapters[ch] = SimpleNamespace(chapter_num=ch, screens=screens)

    return SimpleNamespace(
        chapters=chapters,
        __iter__=lambda self=None: iter(chapters[i] for i in range(1, 6)),
    )


def test_run_v1_returns_outcome_and_marks_screens():
    gw = _fake_game_world()
    rom = bytes(0x40000)
    outcome = run_v1(gw, rom, base_seed=1, max_retries=200)
    assert isinstance(outcome, V1Outcome)
    # The loop ran and produced a result object regardless of pass/fail.
    assert outcome.attempts >= 1
```

> NOTE: `_fake_game_world` above keeps the time door fixed but the content
> shuffle may move it, so the gates may fail and the loop may exhaust — that is
> fine for this structural test (it only asserts an outcome is produced). The
> real validity behavior is exercised against a vanilla ROM in Task 10.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_strategies/test_v1_core.py -v`
Expected: FAIL — module `core` not found.

- [ ] **Step 3: Implement core.py**

```python
# src/tmos_randomizer/strategies/v1/core.py
"""run_v1: deterministic brute-force-until-gates-pass loop (V1 ModifyRom)."""
from __future__ import annotations

import random
from dataclasses import dataclass, field

from . import algorithm as A
from .encounters import shuffle_lineup_patches, group_pointer_patches

_ROM_FIELDS = (
    "parent_world", "ambient_sound", "content", "objectset",
    "screen_index_right", "screen_index_left", "screen_index_down",
    "screen_index_up", "datapointer", "exit_position", "top_tiles",
    "bottom_tiles", "worldscreen_color", "sprites_color", "unknown", "event",
)


@dataclass
class V1Outcome:
    success: bool
    winning_seed: int
    attempts: int
    lineup_patches: list[tuple[int, int]] = field(default_factory=list)
    group_patches: list[tuple[int, int]] = field(default_factory=list)
    failures: list[str] = field(default_factory=list)


def derive_seed(base_seed: int, attempt: int) -> int:
    if attempt == 0:
        return base_seed
    # Deterministic, well-spread sub-seed sequence (no global RNG).
    return (base_seed * 1_000_003 + attempt * 2_654_435_761) & 0x7FFFFFFF


def _snapshot(game_world) -> dict[int, list[dict[str, int]]]:
    snap: dict[int, list[dict[str, int]]] = {}
    for chapter in game_world:
        snap[chapter.chapter_num] = [
            {f: getattr(s, f) for f in _ROM_FIELDS} for s in chapter.screens
        ]
    return snap


def _restore(game_world, snap) -> None:
    for chapter in game_world:
        for s, orig in zip(chapter.screens, snap[chapter.chapter_num]):
            for f, v in orig.items():
                setattr(s, f, v)


class _OrigView:
    """Read-only screen view over a snapshot dict, with a relative_index."""
    __slots__ = ("_d", "relative_index")

    def __init__(self, d, idx):
        self._d = d
        self.relative_index = idx

    def __getattr__(self, name):
        return self._d[name]


def run_v1(game_world, rom: bytes, base_seed: int, max_retries: int) -> V1Outcome:
    snap = _snapshot(game_world)
    last_failures: list[str] = []

    for attempt in range(max_retries):
        sub_seed = derive_seed(base_seed, attempt)
        rng = random.Random(sub_seed)
        _restore(game_world, snap)

        lineup_patches: list[tuple[int, int]] = []
        group_patches: list[tuple[int, int]] = []
        failures: list[str] = []

        for chapter in game_world:
            wi = chapter.chapter_num - 1
            screens = chapter.screens
            originals = [
                _OrigView(snap[chapter.chapter_num][i], i)
                for i in range(len(screens))
            ]
            A.shuffle_object_sets(screens, originals, wi, rng)
            assignments = A.shuffle_contents(screens, originals, wi, rng)
            lineup_patches += shuffle_lineup_patches(rom, chapter.chapter_num, rng)
            group_patches += group_pointer_patches(chapter.chapter_num, assignments)

            if not A.time_doors_ok(screens, wi):
                failures.append(f"chapter {chapter.chapter_num}: time-door count != 1")
            if not A.required_content_present(screens, wi):
                failures.append(f"chapter {chapter.chapter_num}: required content missing")
            if not A.other_problems_ok(screens, originals, wi):
                failures.append(f"chapter {chapter.chapter_num}: other-problem violation")

        if not failures:
            # Mark mutated screens so patch_rom writes only what changed.
            for chapter in game_world:
                for s, orig in zip(chapter.screens, snap[chapter.chapter_num]):
                    if any(getattr(s, f) != orig[f] for f in _ROM_FIELDS):
                        s.mark_modified()
            return V1Outcome(True, sub_seed, attempt + 1,
                             lineup_patches, group_patches)
        last_failures = failures

    return V1Outcome(False, base_seed, max_retries, failures=last_failures)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_strategies/test_v1_core.py -v`
Expected: PASS (`test_derive_seed_*` and `test_run_v1_returns_outcome_and_marks_screens`).

- [ ] **Step 5: Commit**

```bash
git add src/tmos_randomizer/strategies/v1/core.py \
        tests/test_strategies/test_v1_core.py
git commit -m "feat(v1): run_v1 deterministic retry loop"
```

---

## Task 8: Strategy wiring (create_plan / preview_plan / apply_plan) + config

**Files:**
- Modify: `src/tmos_randomizer/strategies/v1/strategy.py`
- Modify: `config/default.yaml`
- Test: `tests/test_strategies/test_v1_strategy.py` (extend)

**Interfaces:**
- Consumes: `run_v1`/`V1Outcome` (Task 7), `tweaks.apply_tweaks` (Task 6), V2 `load_rom`, `patch_rom`, `analyze_reachability`, phases 1–3, `RandomizationPlan`, `RandomizationResult`.
- Config read via `self.config.get("v1.apply_tweaks", True)` and `self.config.get("v1.max_retries", 1000)` (RandomizerConfig dot-path helper — no parser change needed).

- [ ] **Step 1: Add the config block to default.yaml**

Append to `config/default.yaml` (top level, sibling of `general:`):

```yaml
# tmos_randomizer_v1 strategy options
v1:
  apply_tweaks: true   # apply V1's fixed boss/shop/cosmetic/intro patch layer
  max_retries: 1000    # brute-force attempts before reporting failure
```

- [ ] **Step 2: Write the failing test**

```python
# append to tests/test_strategies/test_v1_strategy.py
from pathlib import Path

import pytest

from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.validation.config import ValidationConfig
from tmos_randomizer.validation import ValidationRunner


def _make_strategy():
    cls = get_strategy("tmos_randomizer_v1")
    config = get_default_config()
    vconfig = ValidationConfig()
    runner = ValidationRunner(vconfig)
    return cls(config, vconfig, runner)


def test_create_plan_builds_valid_shell():
    strat = _make_strategy()
    plan = strat.create_plan(seed=12345)
    assert plan.seed == 12345
    assert plan.strategy_name == "tmos_randomizer_v1"
    assert plan.world_plan is not None
    assert plan.world_connections is not None
```

> If `ValidationRunner(ValidationConfig())` is not the correct constructor,
> mirror how an existing strategy test or `tests/conftest.py` builds a strategy
> instance and adjust `_make_strategy` accordingly. Verify with:
> `python -m pytest tests/ -k "strateg" -q` to find the established fixture.

- [ ] **Step 3: Run test to verify it fails**

Run: `python -m pytest tests/test_strategies/test_v1_strategy.py::test_create_plan_builds_valid_shell -v`
Expected: FAIL — `create_plan` raises `NotImplementedError`.

- [ ] **Step 4: Implement the strategy methods**

Replace the body of `src/tmos_randomizer/strategies/v1/strategy.py` with:

```python
"""V1 randomizer ported as a V2 strategy. See
docs/superpowers/specs/2026-06-24-tmos-randomizer-v1-strategy-design.md.
"""
from __future__ import annotations

import hashlib
import logging
from pathlib import Path
from typing import TYPE_CHECKING, Optional

from ..base import RandomizationStrategy
from ..registry import register_strategy
from ...io.rom_reader import load_rom
from ...io.rom_writer import patch_rom
from ...phases.phase1_planning import plan_randomization
from ...phases.phase2_shaping import shape_world
from ...phases.phase3_connection import connect_world
from ...phases.phase6_validation import analyze_reachability
from ...plan import RandomizationPlan, RandomizationResult
from .core import run_v1, V1Outcome
from .tweaks import apply_tweaks

if TYPE_CHECKING:
    from ...core.chapter import GameWorld

logger = logging.getLogger(__name__)


@register_strategy
class TmosRandomizerV1(RandomizationStrategy):
    name = "tmos_randomizer_v1"
    description = (
        "Original V1 randomizer: content / object-set / encounter shuffle with "
        "brute-force validity gates. Reliable playable baseline."
    )

    def create_plan(self, seed: int) -> RandomizationPlan:
        # Build the required plan shell via phases 1-3 (lab-adapter pattern).
        world_plan = plan_randomization(self.config, seed=seed)
        world_shape = shape_world(world_plan)
        world_connections = connect_world(
            world_plan,
            world_shape,
            topology=self.config.connectivity.topology,
            dungeon_last=self.config.connectivity.dungeon_last,
            randomize_order=self.config.connectivity.order_randomization,
        )
        return RandomizationPlan(
            seed=seed,
            config=self.config,
            world_plan=world_plan,
            world_shape=world_shape,
            world_connections=world_connections,
            strategy_name=self.name,
        )

    def preview_plan(self, plan, game_world, rom_data) -> None:
        max_retries = int(self.config.get("v1.max_retries", 1000))
        outcome = run_v1(game_world, rom_data or b"", plan.seed, max_retries)
        self._last_outcome: V1Outcome = outcome

        if not outcome.success:
            msg = "V1 gates failed after %d attempts: %s" % (
                outcome.attempts, "; ".join(outcome.failures[:5]) or "unknown")
            plan.validation_errors.append(msg)
            raise RuntimeError(msg)

        # V2 navigability oracle (informational: V1 never edits nav bytes).
        for chapter in game_world:
            if chapter.screen_count == 0:
                continue
            res = analyze_reachability(chapter, starting_screen=0)
            if res.unreachable_screens:
                plan.validation_warnings.append(
                    f"chapter {chapter.chapter_num}: "
                    f"{len(res.unreachable_screens)} screen(s) unreachable from start"
                )
        plan.validation_warnings.append(
            f"v1: solved on seed {outcome.winning_seed} in {outcome.attempts} attempt(s)"
        )

    def apply_plan(
        self,
        input_rom: Path,
        output_rom: Path,
        plan: RandomizationPlan,
        generate_spoiler: bool,
    ) -> RandomizationResult:
        result = RandomizationResult(success=False, seed=plan.seed)
        try:
            game_world = load_rom(input_rom)
            with open(input_rom, "rb") as f:
                rom_data = f.read()

            self.preview_plan(plan, game_world, rom_data)
            outcome: V1Outcome = self._last_outcome

            # 1) Write mutated screens.
            patch_rom(input_rom, output_rom, game_world)

            # 2) Apply encounter + tweak byte-patches to the output file.
            with open(output_rom, "rb") as f:
                data = bytearray(f.read())
            for offset, value in outcome.lineup_patches:
                data[offset] = value
            for offset, value in outcome.group_patches:
                data[offset] = value
            if self.config.get("v1.apply_tweaks", True):
                apply_tweaks(data, outcome.winning_seed)
            with open(output_rom, "wb") as f:
                f.write(data)

            result.output_rom_path = output_rom
            result.rom_sha256 = hashlib.sha256(bytes(data)).hexdigest()
            result.stats = {
                "strategy": self.name,
                "winning_seed": outcome.winning_seed,
                "attempts": outcome.attempts,
                "lineup_patches": len(outcome.lineup_patches),
                "group_patches": len(outcome.group_patches),
                "tweaks_applied": bool(self.config.get("v1.apply_tweaks", True)),
            }
            result.warnings = list(plan.validation_warnings)
            result.success = True
        except Exception as e:  # noqa: BLE001 - surface to caller as result.errors
            result.errors.append(str(e))
        return result
```

- [ ] **Step 5: Run test to verify it passes**

Run: `python -m pytest tests/test_strategies/test_v1_strategy.py -v`
Expected: PASS (registration + metadata + `test_create_plan_builds_valid_shell`).

- [ ] **Step 6: Commit**

```bash
git add src/tmos_randomizer/strategies/v1/strategy.py config/default.yaml \
        tests/test_strategies/test_v1_strategy.py
git commit -m "feat(v1): wire create/preview/apply plan + config options"
```

---

## Task 9: ROM-gated end-to-end integration test

**Files:**
- Create: `tests/test_strategies/test_v1_integration.py`

**Interfaces:**
- Consumes: the full strategy (Tasks 1–8) + a real vanilla ROM.

The test loads a real ROM (path from env `TMOS_ROM` or a known fixture), runs `create_plan` → `apply_plan`, and asserts a valid, changed, navigable output. It is skipped when no ROM is available so CI stays green without committing a `.nes`.

- [ ] **Step 1: Write the integration test**

```python
# tests/test_strategies/test_v1_integration.py
import hashlib
import os
from pathlib import Path

import pytest

from tmos_randomizer.strategies import get_strategy
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.phases.phase6_validation import analyze_reachability
from tmos_randomizer.validation.config import ValidationConfig
from tmos_randomizer.validation import ValidationRunner

EXPECTED_MD5 = "b3236db14c87f375e5f24a5b9b79f071"


def _find_rom() -> Path | None:
    env = os.environ.get("TMOS_ROM")
    if env and Path(env).exists():
        return Path(env)
    for guess in (
        Path("rom-files/TMOS.nes"),
        Path("../../rom-files/TMOS.nes"),
    ):
        if guess.exists():
            return guess
    return None


_ROM = _find_rom()
pytestmark = pytest.mark.skipif(_ROM is None, reason="no TMOS ROM available")


def _strategy():
    cls = get_strategy("tmos_randomizer_v1")
    cfg = get_default_config()
    vcfg = ValidationConfig()
    return cls(cfg, vcfg, ValidationRunner(vcfg))


def test_end_to_end_produces_valid_changed_navigable_rom(tmp_path):
    strat = _strategy()
    plan = strat.create_plan(seed=12345)
    out = tmp_path / "out.nes"
    result = strat.apply_plan(_ROM, out, plan, generate_spoiler=False)

    assert result.success, result.errors
    assert out.exists()

    # Output differs from vanilla.
    vanilla_md5 = hashlib.md5(_ROM.read_bytes()).hexdigest()
    out_md5 = hashlib.md5(out.read_bytes()).hexdigest()
    assert out_md5 != vanilla_md5

    # Output re-parses and every chapter satisfies V1's time-door gate.
    from tmos_randomizer.strategies.v1 import algorithm as A
    gw = load_rom(out)
    for chapter in gw:
        wi = chapter.chapter_num - 1
        assert A.time_doors_ok(chapter.screens, wi), f"chapter {chapter.chapter_num}"
        assert A.required_content_present(chapter.screens, wi)
        # Nav untouched -> reachability no worse than vanilla.
        analyze_reachability(chapter, starting_screen=0)


def test_determinism_same_seed_same_rom(tmp_path):
    strat = _strategy()
    a = tmp_path / "a.nes"
    b = tmp_path / "b.nes"
    strat.apply_plan(_ROM, a, strat.create_plan(seed=777), generate_spoiler=False)
    strat.apply_plan(_ROM, b, strat.create_plan(seed=777), generate_spoiler=False)
    assert a.read_bytes() == b.read_bytes()
```

- [ ] **Step 2: Run the test**

Run (with a ROM): `TMOS_ROM=/path/to/TMOS.nes python -m pytest tests/test_strategies/test_v1_integration.py -v`
Run (without): `python -m pytest tests/test_strategies/test_v1_integration.py -v` → both tests SKIPPED.

Expected with ROM: PASS. If `test_end_to_end` fails because gates never pass within `max_retries`, raise `v1.max_retries` and re-confirm against the C# tables (a persistent failure means a transcription error in Task 3, not a budget problem).

- [ ] **Step 3: Commit**

```bash
git add tests/test_strategies/test_v1_integration.py
git commit -m "test(v1): ROM-gated end-to-end integration test"
```

---

## Task 10: Full-suite verification + manifest/changelog

**Files:**
- Modify: `.claude-system/CHANGELOG.md` (project organization log)
- Modify: `.claude-system/manifest.json` (register the new files)

- [ ] **Step 1: Run the full strategy test suite**

Run: `python -m pytest tests/test_strategies/ -v`
Expected: all V1 tests PASS; integration SKIPPED unless a ROM is present. No regressions in other strategy tests.

- [ ] **Step 2: Confirm the strategy is discoverable**

Run: `python -c "from tmos_randomizer.strategies import list_strategies; print(list_strategies())"`
Expected output includes `'tmos_randomizer_v1'`.

- [ ] **Step 3: Update the project manifest + changelog**

Add the new `strategies/v1/` files and tests to `.claude-system/manifest.json` under category `source`, and append a dated entry to `.claude-system/CHANGELOG.md` summarizing the V1 strategy addition (new package, reference source under `knowledge/code-analysis/TMOS_Romhack1_v1/`, spec + plan docs).

- [ ] **Step 4: Commit**

```bash
git add .claude-system/CHANGELOG.md .claude-system/manifest.json
git commit -m "chore(v1): record v1 strategy in manifest + changelog"
```

---

## Self-Review (completed during authoring)

- **Spec coverage:** module layout (Task 1,8) ✓; data tables (Task 3) ✓; algorithm + gates (Task 4) ✓; encounters incl. read-only V2 → byte patches (Task 5) ✓; tweak layer + toggle (Task 6,8) ✓; retry loop + V2 oracle (Task 7,8) ✓; behavior parity / deterministic seeds (Global Constraints, Task 7) ✓; tests incl. determinism, gates, tweak bytes, output validity, discovery (Tasks 2–10) ✓; UI auto-discovery (no code; verified Task 10) ✓; alignment/offset risk (resolved in Global Constraints — V2 `CHAPTER_BASES`/`LINEUP_BASE`/`GROUP_BASE` match V1) ✓.
- **Type consistency:** `run_v1(game_world, rom, base_seed, max_retries) -> V1Outcome`; `V1Outcome.{success,winning_seed,attempts,lineup_patches,group_patches,failures}`; `shuffle_contents(...) -> dict[int,int]`; `shuffle_lineup_patches(rom, chapter, rng) -> list[tuple[int,int]]`; `group_pointer_patches(chapter, assignments) -> list[tuple[int,int]]`; `apply_tweaks(rom: bytearray, seed: int)` — names used consistently across Tasks 4–9.
- **Known accommodations:** the large hex tables (Task 3) and tweak list (Task 6) are transcribed from the committed C# reference rather than re-pasted in full here; each has a structural test plus a verification step. This is deliberate — the reference file is the no-ambiguity source of truth.
