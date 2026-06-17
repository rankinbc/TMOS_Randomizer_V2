# Handoff — 2026-06-17 session (stabilize + tiles/editor + Wave 2 kickoff)

**Branch:** `master` (pushed to origin) · **Supersedes** the stale root `HANDOFF_PROMPT.md` (navigation-phase) and largely subsumes `AI_reachability-repair-handoff.md` (that work is now fully merged into master).

This session ran orchestrator-style: most work was done by isolated subagents and integrated onto `master`. Goal was reframed mid-session (see §2).

---

## 1. What shipped to `master` today (all verified, suite green: 601 passed / 10 skipped)

- **Git reconciliation (Wave 0):** master was a strict superset of 4 divergent branches; consolidated to a single `master`, deleted the redundant branches, kept `archive/*` tags as recovery points. (origin/master was stuck at `8604039`; now synced.)
- **Wave 1 (stabilize):** fixed 5 stale tests (`b8f5c6f`); repair confirmed **coherence-safe** + guard test (`e05a084`); retired the false-passing `tester.py`/`validators.py` in favour of the differential oracle (`0a0a525`).
- **Tiles regression → root cause = missing `Pillow`** in the backend venv (not a code regression). Declared `Pillow` in the `[api]` extra (`9b54a68`).
- **`server.py` fixes (`5f12e62`):** repointed `/api/debug/validate` off the deleted `validators` module onto `ValidationRunner` (backward-compatible response shape); `render_screen` now logs the full traceback before raising (so the swallowed Pillow error would've been obvious); no-ROM path returns clean 400 not 500.
- **Editor UI:** World-Screen modal **widened + two-pane layout** (fields left, tiles right) (`7fdfbb4`); **screen-drag fix** — screen `<img>` was draggable-by-default and stole the gesture, so set `draggable={false}` + `select-none` (`2c0294d`).
- **Research + spec:** gate-logic research (local disasm + web) in `reports/2026-06-17_tmos-gates-*.md`; merged into `docs/ai/AI_item-gating-logic-spec.md` (`98d1c9f`).

## 2. Decisions & rules established today (also saved as memories)

- **GOAL REFRAMED:** aim for **most seeds playable**, not perfection. A seed may need **user review + manual fix** — acceptable. The item-gating validator is a **detector/reporter** (flag for review + a "playable %" metric), NOT a 100% hard gate. Physical-reachability repair still targets 100%.
- **Time Door screens are PINNED:** keep their screen index + stay Time Doors through randomization (external refs depend on the index). Eras join freely at time doors (no scarce-item gate).
- **Remove the desert-maze concept entirely** (not a real gate; Supica not required; confuses tile randomization).
- **Resolved gate rules:** `PAST_SCREEN_INDICES` authoritative; Ch3 Troll needs **both** Pukin + Mustafa; Ch5 Isfa Rod **required**; ally-ban screens assumed not to strand. **Still open (handle conservatively):** B4 class-change stranding, B8 runtime exit-byte edits.

## 3. PARKED work — recover next session (do NOT lose)

- **`wave2/item-gating-detector` @ `6db9f56`** (worktree `.claude/worktrees/agent-a3025872dd13a1417`): the item-gating winnability detector — `validation/item_gating/` (`model.py`, `checker.py`, `reachability.py`, `validator.py`), an `oracle.py` channel, and `tests/test_validation/test_item_gating.py`. **UNVERIFIED** (the build agent hit a transient 529 before verifying). NEXT: port onto master (patch/merge-base — its base is the old `8604039`), run the suite, confirm **vanilla ROM reports all 5 chapters winnable** and produce a first **playable %** on grow seeds.
- **`feat/tilesection-compat-picker`** (worktree `.claude/worktrees/agent-acb0d39f0b73dcfbe`): the compatibility-aware tilesection picker (Top/Bottom radio + filters [Compatible / Suggested / Bank] + `GET /api/rom/screen/{ch}/{idx}/section-compatibility`). Was **still building at session end** — check its worktree/branch for the committed result (or uncommitted WIP if it 529'd). NEXT: re-verify pytest + `ui` tsc on master, port, and **visually sanity-check** that the *Compatible* set is a sensible non-empty subset (the per-half edge + bank/CHR semantics were the flagged risk).
- **Cleanup after integrating both:** `git worktree remove` the two `agent-*` worktrees + `git branch -D` their temp branches. The 4 `archive/*` tags are Wave-0 recovery points — safe to keep.

## 4. NOT started

- **Wave 2b:** (a) enforce the Time-Door pin invariant in generation/repair (verify grow/organic + the warp-link lever honour it); (b) rip out the desert-maze concept from the shaping/population pipeline.

## 5. Gotchas learned this session (important for next agent)

- **Worktree isolation bases new worktrees off `origin/master`**, not local `master` — so before pushing, agent worktrees were cut from a stale base. It also left the orchestrator shell's CWD *inside* a leftover worktree once. ALWAYS: integrate on `master` from the **main** worktree (`git -C <mainpath>`), re-verify there, and port agent changes via clean **patch/merge-base** (not wholesale merge of a stale-base branch).
- **Background subagents sometimes 529 before committing** — their work is preserved as uncommitted changes in their worktree; recover by committing those files yourself.
- **Editable install resolves to the MAIN checkout**, so a subagent's in-worktree `pytest` can test the wrong source — never trust an agent's in-worktree test count; re-verify on master.
- **`Pillow` is required by `rendering.ScreenRenderer`** (now in the `[api]` extra). A missing-Pillow render raises and was being swallowed as an opaque 500.

## 6. Verify / run

```bash
cd projects/TMOS_Randomizer_V2 && python -m pytest -q          # baseline: 601 passed, 10 skipped
python util/verify-repair-multiseed.py --count 10              # repair: 10/10 100% reachable, 0xFE preserved
cd projects/TMOS_Randomizer_V2/ui && npx tsc --noEmit          # frontend typecheck
```
ROM: `rom-files/TMOS_ORIGINAL.nes` (MD5 `b3236db14c87f375e5f24a5b9b79f071`). Backend needs a ROM loaded (`POST /api/rom/load-default`) or render endpoints 400.
