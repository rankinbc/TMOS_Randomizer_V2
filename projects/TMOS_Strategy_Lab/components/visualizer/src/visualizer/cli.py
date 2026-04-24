"""visualizer — Click group entry point.

Four subcommands: render-map, plot-metrics, diff, heatmap. Rendering
primitives live in ``tmos_strategy_lab.viz``.
"""
from __future__ import annotations

import click

from visualizer.commands import diff, heatmap, plot_metrics, render_map


@click.group()
def main() -> None:
    """TMOS visualizer — render maps, plot metrics, diff candidates, overlay heatmaps."""


main.add_command(render_map.cmd, name="render-map")
main.add_command(plot_metrics.cmd, name="plot-metrics")
main.add_command(diff.cmd, name="diff")
main.add_command(heatmap.cmd, name="heatmap")


__all__ = ["main"]
