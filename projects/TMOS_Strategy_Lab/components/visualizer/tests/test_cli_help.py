"""Each visualizer subcommand must expose --help cleanly."""
from __future__ import annotations

from click.testing import CliRunner

from visualizer.cli import main


def test_root_help():
    runner = CliRunner()
    result = runner.invoke(main, ["--help"])
    assert result.exit_code == 0
    for sub in ("render-map", "plot-metrics", "diff", "heatmap"):
        assert sub in result.output, f"{sub} missing from root --help"


def test_subcommand_help_render_map():
    result = CliRunner().invoke(main, ["render-map", "--help"])
    assert result.exit_code == 0
    assert "CANDIDATE_JSON" in result.output
    assert "--rom" in result.output


def test_subcommand_help_plot_metrics():
    result = CliRunner().invoke(main, ["plot-metrics", "--help"])
    assert result.exit_code == 0
    assert "SUMMARY_JSON_OR_NDJSON" in result.output


def test_subcommand_help_diff():
    result = CliRunner().invoke(main, ["diff", "--help"])
    assert result.exit_code == 0
    assert "CANDIDATE_A" in result.output
    assert "CANDIDATE_B" in result.output


def test_subcommand_help_heatmap():
    result = CliRunner().invoke(main, ["heatmap", "--help"])
    assert result.exit_code == 0
    assert "CANDIDATE_JSON" in result.output
    assert "--colormap" in result.output
