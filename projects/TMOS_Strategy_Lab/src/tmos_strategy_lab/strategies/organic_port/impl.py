"""organic_port — Lab wrapper around V2's OrganicStrategy.

Runs V2's organic pipeline against a deep-copied ``GameWorld`` + ``rom_bytes``
and packages the result as a ``Candidate``. Does NOT patch a ROM.
"""
from __future__ import annotations

import copy
import logging
from typing import Any

from ..._v2_compat import V2_AVAILABLE
from ...context import LabContext
from ...models import Candidate, RepairRecord
from ...registry import register_strategy

_log = logging.getLogger(__name__)


def _build_v2_strategy(seed: int):
    """Construct V2 OrganicStrategy with minimal defaults.

    V2's abstract base requires (config, validation_config, validation_runner).
    Both dataclasses have default-factory fields, so empty constructors suffice.
    """
    from tmos_randomizer.io.config_loader import get_default_config  # type: ignore[import-untyped]
    from tmos_randomizer.strategies.organic.strategy import OrganicStrategy  # type: ignore[import-untyped]
    from tmos_randomizer.validation.config import ValidationConfig  # type: ignore[import-untyped]
    from tmos_randomizer.validation.runner import ValidationRunner  # type: ignore[import-untyped]

    config = get_default_config()
    val_config = ValidationConfig(
        run_incremental=False,  # we don't need V2's incremental validators for the Lab
        run_final=False,        # Lab runs its own metric battery
    )
    runner = ValidationRunner(val_config)
    return OrganicStrategy(config=config, validation_config=val_config, validation_runner=runner)


def _extract_repairs(strategy: Any) -> list[RepairRecord]:
    repairs: list[RepairRecord] = []
    reports = getattr(strategy, "_last_repair_reports", None) or {}
    for chapter_num, rep in reports.items():
        iters = getattr(rep, "iterations_used", 0)
        if iters == 0:
            continue
        broken_before = getattr(rep, "broken_edges_before", 0)
        broken_after = getattr(rep, "broken_edges_after", 0)
        if broken_before > broken_after:
            repairs.append(RepairRecord(
                what=f"repaired {broken_before - broken_after} broken edges in chapter {chapter_num}",
                why="edge_repair pass eliminated walkability mismatches",
                screen_ids=[],
                rule="edge_compatibility",
            ))
        orphans_before = getattr(rep, "orphans_before", 0)
        orphans_after = getattr(rep, "orphans_after", 0)
        if orphans_before > orphans_after:
            repairs.append(RepairRecord(
                what=f"reclaimed {orphans_before - orphans_after} orphan screens in chapter {chapter_num}",
                why="orphan_merge pass folded disconnected screens into main blob",
                screen_ids=[],
                rule="reachability",
            ))
    aggressive = getattr(strategy, "_last_aggressive_stats", None) or {}
    if aggressive.get("relocations", 0):
        repairs.append(RepairRecord(
            what=f"aggressive_blob_merge relocated {aggressive['relocations']} screens",
            why="fallback pass forced disconnected blobs into the main component",
            screen_ids=[],
            rule="reachability",
        ))
    return repairs


@register_strategy
class OrganicPortStrategy:
    name = "organic_port"
    description = "Runs V2's OrganicStrategy pipeline in-memory and captures repairs as Candidate records."

    def generate(self, ctx: LabContext, seed: int) -> Candidate:
        if not V2_AVAILABLE:
            raise RuntimeError(
                "organic_port requires the V2 sibling (TMOS_Randomizer_V2) to be reachable."
            )
        if ctx.rom_bytes is None:
            raise ValueError(
                "organic_port requires --input <rom.nes> (rom_bytes). Snapshots "
                "do not carry the raw ROM bytes needed by V2's template extraction."
            )

        world = copy.deepcopy(ctx.game_world)
        rom_data = ctx.rom_bytes

        strategy = _build_v2_strategy(seed)
        plan = strategy.create_plan(seed)

        try:
            strategy.preview_plan(plan, world, rom_data)
        except Exception:
            _log.exception("organic_port: V2 preview_plan raised; re-raising as fail-loud.")
            raise

        repairs = _extract_repairs(strategy)

        chapters: dict[int, list[dict]] = {}
        for ch_num in sorted(world.chapters.keys()):
            chapters[ch_num] = [s.to_dict() for s in world.chapters[ch_num].screens]

        breadcrumbs: dict[str, Any] = {
            "source": ctx.source,
            "rom_md5": ctx.rom_md5,
            "retries_used": getattr(strategy, "_last_retries_used", 0),
        }
        aggressive = getattr(strategy, "_last_aggressive_stats", None) or {}
        if aggressive:
            breadcrumbs["aggressive_stats"] = dict(aggressive)

        return Candidate(
            strategy_id=f"{self.name}@local",
            strategy_version="0.1.0",
            seed=seed,
            chapters=chapters,
            repairs=repairs,
            breadcrumbs=breadcrumbs,
        )
