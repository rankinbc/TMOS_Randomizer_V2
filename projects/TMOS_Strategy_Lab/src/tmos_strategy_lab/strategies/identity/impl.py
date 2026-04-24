"""identity — no-op baseline strategy.

Simply copies the loaded ``GameWorld`` into a ``Candidate`` without touching
anything. Every metric must pass on this Candidate when the input is the
stock ROM — otherwise a metric is buggy, not the strategy.
"""
from __future__ import annotations

from ...context import LabContext
from ...models import Candidate
from ...registry import register_strategy


@register_strategy
class IdentityStrategy:
    name = "identity"
    description = "Returns the loaded GameWorld layout unchanged — baseline reference."

    def generate(self, ctx: LabContext, seed: int) -> Candidate:
        chapters: dict[int, list[dict]] = {}
        for ch_num in sorted(ctx.game_world.chapters.keys()):
            chapter = ctx.game_world.chapters[ch_num]
            chapters[ch_num] = [s.to_dict() for s in chapter.screens]
        return Candidate(
            strategy_id=f"{self.name}@local",
            strategy_version="0.1.0",
            seed=seed,
            chapters=chapters,
            repairs=[],
            breadcrumbs={
                "source": ctx.source,
                "rom_md5": ctx.rom_md5,
                "preserves_baseline": True,
            },
        )
