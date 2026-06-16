# Handoff — Autonomous self-verifying world-map randomization (reachability repair)

**Date:** 2026-06-16 · **Branch:** `feat/coherence-and-repair` (13 commits ahead of `master`, unmerged)
**Author:** Claude (TMOS_AI) · **Status:** core goal MET at static level; 3 of 4 milestone caveats closed.

---

## 1. The goal (why this work exists)

Push the randomizer grind onto the AI: a closed loop **generate → verify → repair** that runs
unattended and repeatably, producing a *navigable* world every time, with **the verifier as the
source of truth**. The trigger was discovering that the Lab `grow` strategy's documented
"13/13 PASS" was a **stale fake** (a v0.2.0 cross-era cheat); when honestly verified, grow
under-reaches vanilla and produced no navigable ROM.

Instead of rewriting grow, we built a **strategy-agnostic reachability-repair post-pass** that
connects any generator's output to **100% reachable** by least-damage edits.

---

## 2. What's DONE (with commits)

| Done | Where | Commit |
|------|-------|--------|
| Repair pass: `compute_reachable` + 3 levers (open-in-place → TS-swap → warp-link) | `repair/reachability_repair.py` | cf1ab04, 0fafa09, 532ca00, 8a6896f |
| **grow seed 42 → 100% reachable** all 5 chapters (265 unreachable → 0), 0xFE preserved | — | 7d3fb17 |
| **Multi-seed robustness: 30 distinct seeds all 100%** (1–10 + 20 scattered to 424242) | `util/verify-repair-multiseed.py` | fc60172, 0f6cc46 |
| **Pipeline integration: repair runs automatically** after grow generation | `strategies/lab_adapter.py` | 38fea3e, b9e1707 |
| P3 coherence oracle (segregation hard gate + clustering channel) | `validation/validators/interior_exterior_segregation.py`, `validation/coherence.py`, `testing/oracle.py` | cf1ab04 |
| grow v0.4.0 L2 filter-growth (separate Lab repo, helps but small) | `TMOS_Strategy_Lab/.../grow/impl.py` | (Lab repo) |

**Current measured result:** every chapter 131/137/153/164/154 = 100%, 0xFE 79→79, 73–81 repairs/seed.

---

## 3. How the repair pass works (the 4 invariants)

`repair_chapter(chapter, edges_of, *, candidate_tiles_of, era_of, allow_warp_links)`:

1. **Preserve building entrances** — never overwrite a `0xFE` nav byte (SAFE-FIRST; see §5).
2. **Edge-aligned walk links only** — ≥1 aligned walkable tile pair across the seam; no broken edges.
3. **Same-era walk links only** — PRESENT↔PAST solely through the existing time door (Content 0xC0 pair).
4. **Deterministic** — seeded/sorted order; same seed → identical repairs.

Levers, cheapest first:
- **open_in_place** — wire two free (0xFF), aligned, same-era ports two-way.
- **ts_swap_then_open** — swap a stranded screen's TileSection to a CHR-valid (top,bot) pair used by
  same-datapointer screens so an edge becomes alignable, then wire. Guarded so it never breaks an
  existing link.
- **warp_link** (last resort) — add a same-era stairway (Event 0x40 → Content destination) from an
  *expendable* (content==0 and event==0) reachable screen, **never screen 0**; bidirectional when the
  target is also expendable (no one-way soft-lock). This is how cross-era PAST islands behind an
  unreachable present time door get connected.

`repair_reachability(game_world, rom_data, ...)` = world-level wrapper; production uses ROM-backed
`extract_edges` + same-CHR candidate tiles. Returns `WorldRepairReport` (`.total_records`,
`.total_unrepaired`, per-chapter `reachable_before/after`, first-class `RepairRecord`s — never silent).

---

## 4. Pipeline integration (how it runs automatically)

`LabAdapterStrategy.preview_plan` (in `strategies/lab_adapter.py`) now:
1. Generates the Lab candidate once, stamps it onto `game_world`.
2. **If `self.repairs_reachability` and `rom_data`:** runs `repair_reachability` in place, stores the
   report on `self._last_repair_report`, and **raises** if `total_unrepaired > 0` (fail-closed).

`apply_plan` reads `self._last_repair_report` → `result.stats["repair_records"]` / `["repair_unrepaired"]`.

- `repairs_reachability` is a class flag, **True only on `GrowAdapter`**. It is **False** on
  `IdentityAdapter`/`TileShuffleAdapter` on purpose — they are nav-preserving, and repairing them would
  "fix" vanilla's *intended* progression-gated reachability up to 100%, corrupting their semantics.
- This **replaced** the old `preview_plan` "no worse than vanilla → reseed up to 5× → raise" gate. The
  absolute 100% floor dominates the differential gate and always succeeds. Removed the now-dead helpers
  `_snapshot_game_world` / `_restore_game_world` / `_reach_regressions` and `_NAVIGABILITY_RETRIES`.
  `_reach_counts` was KEPT (tested by `test_lab_adapter_reach.py`, guards a real past bug).
- The live UI preview path (`api/server.py` calls `strategy.preview_plan`) gets repaired worlds too.

---

## 5. Hard constraints & decisions on record (DO NOT violate)

- **SAFE-FIRST (user decision):** never remove/overwrite a building entrance (0xFE) to gain
  reachability. The static oracle cannot detect lost building access, so doing so could silently make
  the game unwinnable. The repair pass enforces this (invariant 1) and verification asserts 79→79.
- **Re-run the oracle on EVERY strategy change.** grow's "13/13" was stale because nothing re-verified
  after a version bump. The autonomous loop is the regression alarm, not just a seed-finder.
- **Commit verified work immediately.** A day of work + this session's docs were once lost to an
  uncommitted branch switch. Isolate WIP (stage only your own files; never `git add -A` or switch
  branches with dirty state) before any branch/subagent operation.
- **Reachability is PROGRESSION-GATED** (Faruk→Horen, Supica→desert, OPRIN→time door, Holy Robe→Lava
  Cape — validated against GameAnalysis2 ROM_VERIFIED data). So **every static reachability BFS is a
  PROXY that over-counts playability.** 100% reachable = "no walled-off screens assuming full movement,"
  NOT item-gated winnability. Only the P4 emulator can prove the latter.

---

## 6. Remaining work (priority order)

1. **Coherence check of warp-links** *(recommended next; smallest)* — each seed adds ~75 repairs,
   some of which are teleport stairways. Run the *repaired* grow worlds through the P3 coherence oracle
   (clustering + interior/exterior segregation, already built in `testing/oracle.py` + `validation/`)
   to confirm repair doesn't trade navigability for visual "salad." If it does, bias the repair lever
   selection toward same-biome links (`coherence.biome_key = (section_type, worldscreen_color)`).
2. **P4 emulator** *(bigger lift)* — headless NES emulator boots the ROM and drives movement via the
   ~210-addr RAM map to confirm REAL item-gated reachability. The only true playability validation.
3. **Apply repair to organic too** — `organic` strategy has its own `apply_plan`/`preview_plan`
   (`strategies/organic/strategy.py`); `repair_reachability` is already strategy-agnostic, so this is a
   one-call addition (mirror the grow wiring, gate behind the same kind of flag).
4. **P5 agentic self-tuning controller** — designed (fixed-priority knobs, advance-seed-by-default,
   layered stop conditions), not built. It's `batch.py` + a thin policy layer + a streak detector; the
   coherence vector is its tuning surface.
5. **P1 loose end:** retire the false-passing `testing/tester.py` in favor of `testing/oracle.py`.

---

## 7. How to run things

```bash
# Multi-seed repair verification (the robustness check): 100% + 0xFE preserved per seed
python util/verify-repair-multiseed.py --count 10            # seeds 1..10
python util/verify-repair-multiseed.py 42 100 777 12345      # explicit seeds
#   exit 0 iff every seed reaches 100% on every chapter with 0xFE preserved

# Repair unit tests (fast) + pipeline integration tests (real ROM, ~75s)
cd projects/TMOS_Randomizer_V2
python -m pytest tests/test_repair/ tests/test_strategies/ -q

# Unattended batch (oracle as source of truth) — judges final ROMs
python -m tmos_randomizer.testing.batch --rom ../../rom-files/TMOS_ORIGINAL.nes --count 50 --strategy lab_grow
```

ROM: `rom-files/TMOS_ORIGINAL.nes` (MD5 `b3236db14c87f375e5f24a5b9b79f071`). Never commit `.nes`.

---

## 8. Key files

| File | Role |
|------|------|
| `projects/TMOS_Randomizer_V2/src/tmos_randomizer/repair/reachability_repair.py` | the repair pass (compute_reachable + 3 levers + world wrapper) |
| `projects/TMOS_Randomizer_V2/src/tmos_randomizer/strategies/lab_adapter.py` | pipeline integration (`preview_plan` runs repair; `repairs_reachability` flag) |
| `projects/TMOS_Randomizer_V2/tests/test_repair/test_reachability_repair.py` | 14 unit tests (levers, era safety, 0xFE preservation, world wrapper) |
| `projects/TMOS_Randomizer_V2/tests/test_strategies/test_repair_integration.py` | 2 real-ROM tests (written ROM 100% reachable, 0xFE preserved, stats) |
| `util/verify-repair-multiseed.py` | parameterized multi-seed robustness check |
| `projects/TMOS_Randomizer_V2/src/tmos_randomizer/testing/oracle.py` | differential oracle (reachability + clustering channels) |
| `projects/TMOS_Randomizer_V2/src/tmos_randomizer/validation/coherence.py` | P3 biome/clustering metric |
| `docs/brainstorming/brainstorming-session-2026-06-15.md` | full session log (the running narrative) |

Authoritative ROM knowledge: `GameAnalysis2/analysis_games/TMOS` (ROM_VERIFIED specs + disassembly),
**not** the in-repo `/knowledge` folder.

---

## 9. Known issues (NOT introduced by this work)

Full V2 suite: **596 passed, 6 failed, 10 skipped.** All 6 failures are **pre-existing and unrelated**
to reachability/repair (default strategy is `organic`, untouched here):
- 4× `tests/test_rendering/test_screen_renderer.py` — TileSection addressing constants (`TILESECTION_OFFSET`
  8 vs 32 mismatch between test and code).
- 1× `tests/test_integration/test_screen_fields_endpoint.py::test_update_field_rejects_parent_world` — API field validation.
- 1× `tests/test_integration/test_randomization.py::TestSingleSeed::test_result_has_all_chapters` — organic strategy.

These are worth a separate triage but are outside the repair/coherence scope.
