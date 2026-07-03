"""Randomization plan endpoints: strategies, config, plan lifecycle,
apply-preview (sync + async job registry), ROM patch download, section maps."""

from __future__ import annotations

import asyncio
import logging
import re
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import Response

from .. import state
from ..deps import _require_rom, _require_rom_pair, _flush_screens
from ..schemas import ApplyRequest, ConfigUpdate, PlanRequest
from .debug import _analyze_full_reachability
from ...randomizer import Randomizer
from ...io.config_loader import get_default_config
from ...io.rom_reader import load_rom
from ...core.enums import NAV_BLOCKED, NAV_BUILDING_ENTRANCE

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/api/strategies")
async def get_strategies():
    """List registered randomization strategies, in display order.

    Built-in strategies come first (classic, organic), then adapters for
    strategies imported from the TMOS Strategy Lab (prefixed ``lab_``).
    """
    from ...strategies import get_strategy, list_strategies

    names = list_strategies()
    builtins = [n for n in names if not n.startswith("lab_")]
    lab_adapted = [n for n in names if n.startswith("lab_")]

    def describe(name: str) -> dict:
        cls = get_strategy(name)
        return {
            "name": name,
            "description": getattr(cls, "description", "") or "",
            "source": "lab" if name.startswith("lab_") else "built-in",
        }

    return {
        "strategies": [describe(n) for n in builtins + lab_adapted],
    }


@router.get("/api/config")
async def get_config():
    """Get current configuration."""
    config = get_default_config()
    return {
        "general": {
            "mode": config.general.mode,
            "chapters": config.general.chapters,
            "seed": config.general.seed,
        },
        "connectivity": {
            "topology": config.connectivity.topology,
            "dungeon_last": config.connectivity.dungeon_last,
            "order_randomization": config.connectivity.order_randomization,
        },
        "difficulty": {
            "preset": config.difficulty.preset,
        },
        "shuffling": config.shuffling,
    }


@router.post("/api/config")
async def update_config(update: ConfigUpdate):
    """Update configuration."""
    config = get_default_config()

    if update.topology is not None:
        config.connectivity.topology = update.topology
    if update.dungeon_last is not None:
        config.connectivity.dungeon_last = update.dungeon_last
    if update.chapters is not None:
        config.general.chapters = update.chapters
    if update.difficulty_preset is not None:
        config.difficulty.preset = update.difficulty_preset

    state._randomizer = Randomizer(config)

    return {"status": "updated", "config": await get_config()}


@router.post("/api/plan")
def create_plan(request: PlanRequest):
    """Create a new randomization plan.

    Deliberately sync (no async): the full randomization pipeline is
    CPU-bound, so Starlette runs this handler in its threadpool instead of
    blocking the event loop for every concurrent request.
    """
    # Build config from request or use defaults
    config = get_default_config()

    if request.config:
        # Apply shuffling settings
        if "shuffling" in request.config:
            shuffling = request.config["shuffling"]
            if "overworld" in shuffling:
                config.shuffling["shuffle_overworld"] = shuffling["overworld"]
            if "towns" in shuffling:
                config.shuffling["shuffle_towns"] = shuffling["towns"]
            if "dungeons" in shuffling:
                config.shuffling["shuffle_dungeons"] = shuffling["dungeons"]
            if "mazes" in shuffling:
                config.shuffling["randomize_mazes"] = shuffling["mazes"]

        # Apply difficulty settings
        if "difficulty" in request.config:
            difficulty = request.config["difficulty"]
            if "preset" in difficulty:
                config.difficulty.preset = difficulty["preset"]

        # Apply connectivity settings
        if "connectivity" in request.config:
            connectivity = request.config["connectivity"]
            if "topology" in connectivity:
                config.connectivity.topology = connectivity["topology"]
            if "dungeon_last" in connectivity:
                config.connectivity.dungeon_last = connectivity["dungeon_last"]

        # Apply shop randomization settings (Bank 1 tables — see
        # knowledge/systems/shops-and-economy.md)
        if "shop_randomization" in request.config:
            sr = request.config["shop_randomization"]
            shop_cfg = config.difficulty.shop_randomization
            if "enabled" in sr:
                shop_cfg.enabled = bool(sr["enabled"])
            if "randomize_items" in sr:
                shop_cfg.randomize_items = bool(sr["randomize_items"])
            if "randomize_prices" in sr:
                shop_cfg.randomize_prices = bool(sr["randomize_prices"])
            if "price_variance" in sr:
                shop_cfg.price_variance = max(0.0, min(1.0, float(sr["price_variance"])))
            if "randomize_magic_prices" in sr:
                shop_cfg.randomize_magic_prices = bool(sr["randomize_magic_prices"])
            if "sell_keys" in sr:
                shop_cfg.sell_keys = max(0, min(8, int(sr["sell_keys"])))

        # Apply enemy randomization settings (bank 3 battle tables —
        # within-chapter only, see logic/enemy_randomization.py)
        if "enemy_randomization" in request.config:
            er = request.config["enemy_randomization"]
            enemy_cfg = config.difficulty.enemy_randomization
            if "enabled" in er:
                enemy_cfg.enabled = bool(er["enabled"])
            if "shuffle_lineups" in er:
                enemy_cfg.shuffle_lineups = bool(er["shuffle_lineups"])
            if "reassign_groups" in er:
                enemy_cfg.reassign_groups = bool(er["reassign_groups"])
            if "rate_jitter" in er:
                enemy_cfg.rate_jitter = bool(er["rate_jitter"])

        # Strategy override — accepts either top-level `strategy` or
        # `general.strategy`. Without this the UI button silently fell
        # through to whatever the default is.
        strategy_name = request.config.get("strategy")
        if strategy_name is None:
            general_cfg = request.config.get("general") or {}
            strategy_name = general_cfg.get("strategy")
        if strategy_name:
            config.general.strategy = strategy_name

    state._randomizer = Randomizer(config)

    try:
        state._current_plan = state._randomizer.create_plan(seed=request.seed)
        return {
            "status": "created",
            "seed": state._current_plan.seed,
            "is_valid": state._current_plan.is_valid,
            "errors": state._current_plan.validation_errors,
            "warnings": state._current_plan.validation_warnings,
            "plan": state._current_plan.to_dict(),
            "config_applied": {
                "shuffling": config.shuffling,
                "difficulty": config.difficulty.preset if hasattr(config.difficulty, 'preset') else None,
                "topology": config.connectivity.topology if hasattr(config.connectivity, 'topology') else None,
            },
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/api/plan")
async def get_plan():
    """Get current randomization plan."""
    if state._current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    return {
        "seed": state._current_plan.seed,
        "is_valid": state._current_plan.is_valid,
        "errors": state._current_plan.validation_errors,
        "warnings": state._current_plan.validation_warnings,
        "plan": state._current_plan.to_dict(),
    }


def _prune_preview_jobs() -> None:
    """Keep the job registry small — drop the oldest finished jobs."""
    if len(state._preview_jobs) <= state._PREVIEW_JOBS_MAX:
        return
    finished = sorted(
        (jid for jid, j in state._preview_jobs.items() if j["status"] != "running"),
        key=lambda jid: state._preview_jobs[jid]["started_at"],
    )
    for jid in finished[: len(state._preview_jobs) - state._PREVIEW_JOBS_MAX]:
        state._preview_jobs.pop(jid, None)


def _apply_preview_compute() -> Dict[str, Any]:
    """Synchronous core of apply-preview.

    Mutates module state (_game_world, _current_plan, _randomizer) and returns
    the result dict. Assumes preconditions (plan created, ROM loaded) were
    already checked by the caller. Raises on internal failure; callers map that
    to an HTTP 500 (sync endpoint) or a job error (async endpoint).
    """
    if state._randomizer is None:
        state._randomizer = Randomizer(get_default_config())

    logger.info(f"Plan seed: {state._current_plan.seed}")
    logger.info(f"World plan chapters: {len(state._current_plan.world_plan.chapters)}")
    logger.info(f"World shape chapters: {len(state._current_plan.world_shape.chapters)}")
    logger.info(f"World connections chapters: {len(state._current_plan.world_connections.chapters)}")

    # Log plan details
    for chapter_plan in state._current_plan.world_plan.chapters:
        logger.info(f"  Chapter {chapter_plan.chapter_num}: {len(chapter_plan.sections)} sections, {chapter_plan.total_screens} total screens")
        for section in chapter_plan.sections:
            logger.info(f"    Section {section.section_id}: {section.section_type.name}, {section.target_screen_count} screens, preserve={section.preserve_original}")

    # Log shape details
    for chapter_shape in state._current_plan.world_shape.chapters:
        logger.info(f"  Chapter {chapter_shape.chapter_num} shape: {len(chapter_shape.sections)} sections with shapes")
        for section_shape in chapter_shape.sections:
            logger.info(f"    Section {section_shape.section_id}: {len(section_shape.screens)} screens in shape")

    try:
        # Dispatch through the active strategy so organic / classic / custom
        # strategies all route their own in-memory randomization. Falls back
        # to the legacy phase4+phase5 flow if the strategy hasn't implemented
        # preview_plan (for backwards compatibility with third-party strategies).
        strategy = state._randomizer.strategy
        logger.info(f"Dispatching preview through strategy: {strategy.name}")

        try:
            strategy.preview_plan(
                plan=state._current_plan,
                game_world=state._game_world,
                rom_data=state._rom_data or b"",
            )
        except NotImplementedError:
            # Legacy path for any strategy that hasn't adopted preview_plan.
            from ...phases.phase4_population import populate_world
            from ...phases.phase5_navigation import rewrite_world_navigation

            world_population = populate_world(
                game_world=state._game_world,
                world_plan=state._current_plan.world_plan,
                world_shape=state._current_plan.world_shape,
                seed=state._current_plan.seed,
            )
            state._current_plan.world_population = world_population
            world_navigation = rewrite_world_navigation(
                game_world=state._game_world,
                world_shape=state._current_plan.world_shape,
                world_connections=state._current_plan.world_connections,
                world_population=world_population,
                seed=state._current_plan.seed,
                preserve_buildings=True,
            )
            state._current_plan.world_navigation = world_navigation

        world_navigation = state._current_plan.world_navigation
        modified_count = 0
        if world_navigation is not None:
            for chapter_nav in world_navigation.chapters:
                modified_screens = set()
                for change in chapter_nav.navigation_changes:
                    modified_screens.add(change.screen_index)
                for stairway in chapter_nav.stairway_changes:
                    modified_screens.add(stairway.screen_a)
                    modified_screens.add(stairway.screen_b)
                modified_count += len(modified_screens)

        # Fallback for strategies (like the lab adapters) that mutate screen
        # bytes directly without populating world_navigation. The WorldScreen
        # _modified flag is the ground truth for "byte-level change".
        if modified_count == 0:
            modified_count = sum(
                1 for ch in state._game_world for s in ch.screens if s.is_modified
            )

        # Navigability gate (soft). The organic strategy is iterating toward
        # full spatial reachability but still produces seeds with some
        # unreachable screens. We report them as warnings and let the UI
        # render the rest — blocking the preview here would hide the
        # Flow/Screens views from the user entirely.
        connectivity_report = _check_world_connectivity(state._game_world)
        all_connected = all(r["fully_reachable"] for r in connectivity_report)
        if not all_connected:
            failing = [
                f"Ch{r['chapter_num']}: {r['reachable_from_0']}/{r['screen_count']} reachable"
                for r in connectivity_report if not r["fully_reachable"]
            ]
            logger.warning(f"Navigability incomplete (soft): {failing}")

        # Honest navigability check. Directed BFS understates reachability (even
        # the stock ROM isn't 100% by it because most screens connect via
        # warps), so we judge "fragmented" RELATIVE to the stock baseline using
        # warp-aware reachability per chapter — not against an absolute bar.
        baseline = _baseline_reachability()
        nav_chapters = []
        nav_ok = True
        for ch in state._game_world:
            r = _analyze_full_reachability(ch)
            base = baseline.get(ch.chapter_num, {})
            base_comp = base.get("full_components")
            base_pct = base.get("percent")
            fragmented = False
            if base_comp is not None and base_pct is not None:
                # More disconnected pieces than stock, or notably less reachable.
                fragmented = (
                    r["full_components"] > base_comp
                    or r["percent"] < base_pct - 5.0
                )
            if fragmented:
                nav_ok = False
            nav_chapters.append({
                "chapter_num": ch.chapter_num,
                "reachable_percent": round(r["percent"], 1),
                "components": r["full_components"],
                "baseline_percent": round(base_pct, 1) if base_pct is not None else None,
                "baseline_components": base_comp,
                "fragmented": fragmented,
            })
        if not nav_ok:
            frag = [c["chapter_num"] for c in nav_chapters if c["fragmented"]]
            logger.warning(
                f"Navigability gate: world more fragmented than stock in "
                f"chapters {frag}"
            )

        # Flush all randomized/edited screens into _rom_data so a later
        # /api/rom/patch captures the applied plan.
        _flush_screens(s for ch in state._game_world for s in ch.screens if s.is_modified)

        # Shop randomization post-pass on the in-memory ROM (Bank 1 tables;
        # knowledge/systems/shops-and-economy.md). The Economy panel and the
        # patched download both read _rom_data, so results show up live.
        shops_result = None
        shop_cfg = state._randomizer.config.difficulty.shop_randomization
        if shop_cfg.enabled and state._rom_data:
            from ...logic.shop_randomization import create_shop_plan

            rom_array = bytearray(state._rom_data)
            shop_plan = create_shop_plan(
                bytes(rom_array),
                state._current_plan.seed,
                shuffle_slots=shop_cfg.randomize_items,
                price_variance=(
                    shop_cfg.price_variance if shop_cfg.randomize_prices else 0.0
                ),
                price_multiplier=shop_cfg.price_multiplier,
                randomize_magic_prices=shop_cfg.randomize_magic_prices,
                sell_keys=shop_cfg.sell_keys,
            )
            shop_plan.apply(rom_array)
            state._rom_data = bytes(rom_array)
            shops_result = shop_plan.to_spoiler()

        # Enemy randomization post-pass, same shape (bank 3 battle tables;
        # within-chapter only — see logic/enemy_randomization.py).
        enemies_result = None
        enemy_cfg = state._randomizer.config.difficulty.enemy_randomization
        if enemy_cfg.enabled and state._rom_data:
            from ...logic.enemy_randomization import create_enemy_plan

            rom_array = bytearray(state._rom_data)
            enemy_plan = create_enemy_plan(
                bytes(rom_array),
                state._current_plan.seed,
                shuffle_lineups=enemy_cfg.shuffle_lineups,
                reassign_groups=enemy_cfg.reassign_groups,
                rate_jitter=enemy_cfg.rate_jitter,
            )
            enemy_plan.apply(rom_array)
            state._rom_data = bytes(rom_array)
            enemies_result = enemy_plan.to_spoiler()

        return {
            "status": "applied",
            "seed": state._current_plan.seed,
            "strategy": strategy.name,
            "shops": shops_result,
            "enemies": enemies_result,
            "screens_modified": modified_count,
            "navigability_ok": nav_ok,
            "navigability": {
                "ok": nav_ok,
                "fragmented_chapters": [
                    c["chapter_num"] for c in nav_chapters if c["fragmented"]
                ],
                "chapters": nav_chapters,
            },
            "connectivity": connectivity_report,
            "chapters": [
                {
                    "chapter_num": ch.chapter_num,
                    "screen_count": ch.screen_count,
                }
                for ch in state._game_world
            ],
        }
    except HTTPException:
        raise
    except Exception:
        # Let callers decide how to surface this (HTTP 500 for the sync
        # endpoint, a job error for the async one). Re-raise the original.
        logger.exception("apply-preview compute failed")
        raise


@router.post("/api/plan/apply-preview")
async def apply_plan_preview():
    """Apply the current plan to the in-memory game world for preview (sync).

    Modifies in-memory ROM data so /api/rom/chapter endpoints return the
    randomized world. Does NOT write to disk. This blocks for the full
    randomization; prefer /api/plan/apply-preview-async on slow tiers.
    """
    if state._current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created yet")
    _require_rom()
    try:
        return _apply_preview_compute()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to apply preview: {str(e)}")


@router.post("/api/plan/apply-preview-async")
async def apply_plan_preview_async():
    """Start apply-preview as a background job; returns a pollable job id.

    The heavy, CPU-bound randomization runs in a worker thread so this request
    returns immediately and the long compute can't hit a gateway/request
    timeout. Poll /api/plan/apply-preview-status/{job_id} for the result.
    """
    if state._current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created yet")
    _require_rom()

    job_id = uuid.uuid4().hex
    state._preview_jobs[job_id] = {
        "status": "running",
        "result": None,
        "error": None,
        "started_at": time.time(),
    }
    _prune_preview_jobs()

    def _run() -> None:
        try:
            res = _apply_preview_compute()
            job = state._preview_jobs.get(job_id)
            if job is not None:
                job["status"] = "done"
                job["result"] = res
        except Exception as e:  # noqa: BLE001 — surfaced to the client as job error
            job = state._preview_jobs.get(job_id)
            if job is not None:
                job["status"] = "error"
                job["error"] = str(e) or e.__class__.__name__

    # Schedule on the default thread pool; CPython preemptively releases the
    # GIL (~5ms) so status polls are still served while compute runs.
    asyncio.get_running_loop().run_in_executor(None, _run)
    return {"job_id": job_id, "status": "running"}


@router.get("/api/plan/apply-preview-status/{job_id}")
async def apply_plan_preview_status(job_id: str):
    """Poll the status/result of an async apply-preview job."""
    job = state._preview_jobs.get(job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Unknown job id")
    return {
        "status": job["status"],
        "result": job["result"],
        "error": job["error"],
        "elapsed_seconds": round(time.time() - job["started_at"], 1),
    }


@router.post("/api/rom/patch")
async def patch_rom(filename: Optional[str] = Query(default=None)):
    """Stream the fully-edited ROM as a browser download.

    _rom_data is the single source of truth (table edits write to it directly;
    screen edits are flushed via _flush_screens). A defensive reconcile flushes
    any still-dirty screens so a forgotten flush site cannot drop edits.
    Runs a non-blocking navigability check and reports the count via a header.
    """
    _require_rom_pair()  # raises HTTPException(400) if no ROM loaded
    _require_rom()

    # Defensive reconcile: capture any dirty screens not yet flushed.
    # _flush_screens rebuilds the _rom_data buffer in place.
    _flush_screens(s for ch in state._game_world for s in ch.screens if s.is_modified)
    modified_count = sum(
        1 for ch in state._game_world for s in ch.screens if s.is_modified
    )

    # Non-blocking navigability check: count chapters with unreachable screens.
    report = _check_world_connectivity(state._game_world)
    warning_count = sum(1 for r in report if not r["fully_reachable"])

    # Resolve a safe download filename: strip path components, then remove
    # characters that could break or inject into the Content-Disposition header
    # (double-quote and CR/LF). Fall back to the default if nothing usable remains.
    if filename:
        name = re.sub(r'[\r\n"]', "", Path(filename).name).strip()
    else:
        name = ""
    if not name:
        if state._rom_filename:
            name = f"{Path(state._rom_filename).stem}-edited.nes"
        else:
            name = "edited.nes"

    return Response(
        content=state._rom_data,
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f'attachment; filename="{name}"',
            "X-Patch-Warnings": str(warning_count),
            "X-Screens-Modified": str(modified_count),
            "Access-Control-Expose-Headers":
                "X-Patch-Warnings, X-Screens-Modified, Content-Disposition",
        },
    )


def _baseline_reachability() -> Dict[int, Dict[str, float]]:
    """Per-chapter warp-aware reachability of the PRISTINE (stock) ROM, cached.

    The stock ROM file at ``_rom_path`` is never mutated (edits live in memory),
    so re-parsing it yields the stock baseline. Used to judge whether a
    randomized world is more fragmented than the real game. Cached by ROM path,
    so it recomputes automatically when a different ROM is loaded.
    """
    key = str(state._rom_path) if state._rom_path else None
    if key is not None and state._baseline_reach_cache[0] == key:
        return state._baseline_reach_cache[1]
    result: Dict[int, Dict[str, float]] = {}
    try:
        if state._rom_path and Path(state._rom_path).exists():
            stock = load_rom(state._rom_path)
            for ch in stock:
                r = _analyze_full_reachability(ch)
                result[ch.chapter_num] = {
                    "percent": r["percent"],
                    "full_components": r["full_components"],
                }
    except Exception:
        logger.exception("baseline reachability computation failed")
        result = {}
    state._baseline_reach_cache = (key, result)
    return result


def _check_world_connectivity(game_world) -> List[Dict[str, Any]]:
    """Per-chapter directed reachability from screen 0 (ignoring 0xFE/0xFF)."""
    from collections import deque as _deque
    from ...logic.navigation import DIRECTIONS as _DIRS

    reports: List[Dict[str, Any]] = []
    for chapter in game_world:
        total = chapter.screen_count
        if total == 0:
            reports.append({
                "chapter_num": chapter.chapter_num,
                "screen_count": 0,
                "reachable_from_0": 0,
                "subworld_count": 0,
                "unreachable": [],
                "fully_reachable": True,
            })
            continue
        reached = {0}
        q = _deque([0])
        while q:
            idx = q.popleft()
            scr = chapter.get_screen(idx)
            if scr is None:
                continue
            for d in _DIRS:
                t = getattr(scr, f"screen_index_{d}")
                if t in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                    continue
                if t < 0 or t >= total:
                    continue
                if t in reached:
                    continue
                reached.add(t)
                q.append(t)
        unreachable_all = [i for i in range(total) if i not in reached]
        subworld = set()
        for i in unreachable_all:
            scr = chapter.get_screen(i)
            if scr is not None and scr.content in {0xC0, 0xC7, 0xD7}:
                subworld.add(i)
        unreachable_play = [i for i in unreachable_all if i not in subworld]
        reports.append({
            "chapter_num": chapter.chapter_num,
            "screen_count": total,
            "reachable_from_0": len(reached),
            "subworld_count": len(subworld),
            "unreachable": unreachable_play,
            "fully_reachable": len(unreachable_play) == 0,
        })
    return reports


@router.get("/api/plan/chapters")
async def get_plan_chapters():
    """Get chapter summaries from current plan."""
    if state._current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    chapters = []
    for chapter_plan in state._current_plan.world_plan.chapters:
        chapters.append({
            "chapter_num": chapter_plan.chapter_num,
            "total_screens": chapter_plan.total_screens,
            "section_count": len(chapter_plan.sections),
            "sections": [
                {
                    "section_id": s.section_id,
                    "type": s.section_type.name,
                    "screen_count": s.target_screen_count,
                    "shape": s.shape,
                    "preserved": s.preserve_original,
                }
                for s in chapter_plan.sections
            ],
        })

    return {"chapters": chapters}


@router.get("/api/plan/chapter/{chapter_num}")
async def get_chapter_detail(chapter_num: int):
    """Get detailed plan for a specific chapter."""
    if state._current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    chapter_plan = state._current_plan.world_plan.get_chapter(chapter_num)
    if chapter_plan is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not in plan")

    # Get shape data
    chapter_shape = None
    for shape in state._current_plan.world_shape.chapters:
        if shape.chapter_num == chapter_num:
            chapter_shape = shape.to_dict()
            break

    # Get connection data
    chapter_connections = None
    for conn in state._current_plan.world_connections.chapters:
        if conn.chapter_num == chapter_num:
            chapter_connections = conn.to_dict()
            break

    return {
        "plan": chapter_plan.to_dict(),
        "shape": chapter_shape,
        "connections": chapter_connections,
    }


@router.get("/api/plan/section-map")
async def get_section_map():
    """Get mapping of screen index → section for current plan.

    Returns a per-chapter mapping of screen indices to their section assignments.
    This uses the world_population data from Phase 4 (after apply-preview is called).
    """
    if state._current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    if state._current_plan.world_population is None:
        # Plan exists but hasn't been applied yet - return empty map
        return {
            "applied": False,
            "chapters": {},
            "note": "Call /api/plan/apply-preview first to populate section assignments"
        }

    chapters_map = {}
    for chapter_pop in state._current_plan.world_population.chapters:
        chapter_num = chapter_pop.chapter_num
        screen_sections = {}

        # Get section plan to retrieve is_past flag
        chapter_plan = state._current_plan.world_plan.get_chapter(chapter_num)
        section_is_past = {}
        if chapter_plan:
            for section in chapter_plan.sections:
                section_is_past[section.section_id] = section.is_past

        for assignment in chapter_pop.assignments:
            entry = {
                "section_id": assignment.section_id,
                "local_id": assignment.local_id,
                "section_type": assignment.original_section_type.name if hasattr(assignment.original_section_type, 'name') else str(assignment.original_section_type),
                "is_past": section_is_past.get(assignment.section_id, False),
            }
            if assignment.grid_position is not None:
                entry["grid_x"] = assignment.grid_position[0]
                entry["grid_y"] = assignment.grid_position[1]
            screen_sections[assignment.real_screen_index] = entry

        chapters_map[chapter_num] = {
            "screen_count": len(chapter_pop.assignments),
            "section_count": len(set(a.section_id for a in chapter_pop.assignments)),
            "screens": screen_sections,
        }

    return {
        "applied": True,
        "seed": state._current_plan.seed,
        "chapters": chapters_map,
    }


@router.get("/api/plan/section-map/{chapter_num}")
async def get_chapter_section_map(chapter_num: int):
    """Get section map for a specific chapter.

    Groups screens by section for easy visualization.
    """
    if state._current_plan is None:
        raise HTTPException(status_code=404, detail="No plan created yet")

    if state._current_plan.world_population is None:
        raise HTTPException(
            status_code=400,
            detail="Plan not applied. Call /api/plan/apply-preview first."
        )

    # Find the chapter population data
    chapter_pop = None
    for cp in state._current_plan.world_population.chapters:
        if cp.chapter_num == chapter_num:
            chapter_pop = cp
            break

    if chapter_pop is None:
        raise HTTPException(status_code=404, detail=f"Chapter {chapter_num} not in plan")

    # Get section plan to retrieve is_past flag
    chapter_plan = state._current_plan.world_plan.get_chapter(chapter_num)
    section_is_past = {}
    if chapter_plan:
        for section in chapter_plan.sections:
            section_is_past[section.section_id] = section.is_past

    # Group screens by section
    sections = {}
    for assignment in chapter_pop.assignments:
        section_id = assignment.section_id
        if section_id not in sections:
            sections[section_id] = {
                "section_id": section_id,
                "section_type": assignment.original_section_type.name if hasattr(assignment.original_section_type, 'name') else str(assignment.original_section_type),
                "is_past": section_is_past.get(section_id, False),
                "screens": [],
            }
        sections[section_id]["screens"].append({
            "screen_index": assignment.real_screen_index,
            "local_id": assignment.local_id,
        })

    # Also get parent_world info from the loaded ROM if available
    if state._game_world is not None:
        chapter = state._game_world.chapters.get(chapter_num)
        if chapter:
            for section_data in sections.values():
                parent_worlds = set()
                for screen_info in section_data["screens"]:
                    screen = chapter.get_screen(screen_info["screen_index"])
                    if screen:
                        parent_worlds.add(screen.parent_world)
                        screen_info["parent_world"] = screen.parent_world
                section_data["parent_worlds"] = list(parent_worlds)

    return {
        "chapter_num": chapter_num,
        "section_count": len(sections),
        "total_screens": len(chapter_pop.assignments),
        "sections": list(sections.values()),
    }


@router.post("/api/apply")
async def apply_randomization(request: ApplyRequest):
    """Apply current plan to a ROM."""
    if state._current_plan is None:
        raise HTTPException(status_code=400, detail="No plan created yet")

    if state._randomizer is None:
        state._randomizer = Randomizer(get_default_config())

    input_path = Path(request.input_rom_path)
    output_path = Path(request.output_rom_path)

    if not input_path.exists():
        raise HTTPException(status_code=400, detail=f"Input ROM not found: {input_path}")

    try:
        result = state._randomizer.apply(
            input_path,
            output_path,
            state._current_plan,
            generate_spoiler=request.generate_spoiler,
        )

        return {
            "success": result.success,
            "seed": result.seed,
            "output_path": str(result.output_rom_path) if result.output_rom_path else None,
            "spoiler_path": str(result.spoiler_text_path) if result.spoiler_text_path else None,
            "rom_sha256": result.rom_sha256,
            "errors": result.errors,
            "warnings": result.warnings,
            "stats": result.stats,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
