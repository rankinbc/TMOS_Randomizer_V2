# TMOS_Romhack1 (V1) — C# Source Reference

Verbatim copies of the core randomization source from the original C# tool
[`rankinbc/TMOS_Romhack1`](https://github.com/rankinbc/TMOS_Romhack1),
preserved here as the authoritative source-of-truth for porting V1 into
TMOS_Randomizer_V2 as the `tmos_randomizer_v1` strategy.

**Confidence:** HIGH (exact source copy).
**Source:** cloned from GitHub `rankinbc/TMOS_Romhack1`, 2026-06-24.
**Do not edit** — these are a frozen reference, not live code.

| File | What to port from it |
|------|----------------------|
| `RandomizeScript.cs` | Top-level flow `ModifyRom`, required-content lists (`CheckThatAllRequiredScreenContentsArePresent`), per-world shuffle-screen arrays (`LoadWorldScreenDataFromRomFile` addresses), `SaveRom` fixed tweak layer. |
| `WorldScreenCollection.cs` | The heart: `Modify`, `ModifyObjectSets2` (object-set tables), `ModifyContents`, `ModifyRandomEncounterLineups`, gates `MakeSureTimeDoorsAreAccessible` (past-screen lists) + `CheckForOtherProblems`, the `GetRandom`/`Shuffle` RNG. |
| `WorldScreen.cs` | Byte layout + predicates `IsDemonScreen`, `IsWizardScreen`, `IsTown`, `isEnemyDoorScreen`, `HasTimeDoor`, `HasContentEntrance`. |
| `RandomEncounterLineup.cs` | Lineup struct: 8 bytes `[start, slot1..slot7]`. |
| `RandomEncounterGroup.cs` | Group struct: 3 bytes `[worldScreen, monsterGroup, unknown]`. |

See `docs/superpowers/specs/2026-06-24-tmos-randomizer-v1-strategy-design.md`
and `docs/superpowers/plans/2026-06-24-tmos-randomizer-v1-strategy.md`.
