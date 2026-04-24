"""harness ``run`` subcommand — the end-to-end pipeline.

The actual pipeline lives in ``tmos_strategy_lab.pipeline`` (shared with
benchmark). This file owns the Click wiring, the PYTHONHASHSEED assertion,
and the JSON-envelope-on-stderr behavior for validation failures.
"""
from __future__ import annotations

import json
import os
import sys
from datetime import date
from pathlib import Path
from typing import Any

import click
from tmos_strategy_lab.pipeline import PipelineArtifacts, run_pipeline, write_artifacts

COMPONENT_DIR = Path(__file__).resolve().parents[3]
PROJECT_ROOT = COMPONENT_DIR.parents[1]
DEFAULT_OUTPUT_BASE = PROJECT_ROOT / "output" / "harness"


class ValidationFailure(click.ClickException):
    """Raised on metric-failure validation; carries the report for stderr envelope.

    Exit code 2 (reserved for validation-level failures, distinct from Click's
    default 1 for misuse/parsing errors and 0 for success).
    """
    exit_code = 2

    def __init__(self, artifacts: PipelineArtifacts, output_format: str):
        super().__init__("Validation failed; see report for details.")
        self.artifacts = artifacts
        self.output_format = output_format

    def show(self, file: Any = None) -> None:  # noqa: ANN401
        stream = file or sys.stderr
        if self.output_format == "json":
            envelope = {
                "error": "validation_failed",
                "strategy_id": self.artifacts.report.strategy_id,
                "seed": self.artifacts.report.seed,
                "report": self.artifacts.report.to_dict(),
            }
            click.echo(json.dumps(envelope, indent=2, sort_keys=True), file=stream)
        else:
            super().show(file=stream)


@click.command("run")
@click.option("--strategy", required=True, type=str,
              help="Strategy name (registered in tmos_strategy_lab).")
@click.option("--seed", required=True, type=click.INT,
              help="Integer seed. String seeds break determinism (CPython #27706).")
@click.option("--input", "input_path", required=True,
              type=click.Path(exists=True, dir_okay=False, path_type=Path),
              help="ROM file or snapshot JSON.")
@click.option("--output-dir", default=None, type=click.Path(path_type=Path),
              help="Override output directory. Default: output/harness/<YYYY-MM-DD>_<label>/")
@click.option("--format", "output_format",
              type=click.Choice(["md", "json", "both"]),
              default="both", show_default=True,
              help="Artifact format(s) to emit.")
@click.option("--run-label", default="run", show_default=True,
              help="Suffix appended to the auto-generated output dir name.")
def main(
    strategy: str,
    seed: int,
    input_path: Path,
    output_dir: Path | None,
    output_format: str,
    run_label: str,
) -> PipelineArtifacts:
    """Run one strategy on one seed and emit a ValidationReport."""
    # PYTHONHASHSEED assertion — must run before any domain code.
    actual = os.environ.get("PYTHONHASHSEED")
    if actual != str(seed):
        raise click.ClickException(
            f"PYTHONHASHSEED must equal --seed for deterministic output. "
            f"Got PYTHONHASHSEED={actual!r}, --seed={seed}. "
            f"Prefix: PYTHONHASHSEED={seed} python -m harness run ..."
        )

    if output_dir is None:
        output_dir = DEFAULT_OUTPUT_BASE / f"{date.today().isoformat()}_{run_label}"

    click.echo(
        f"harness: strategy={strategy} seed={seed} input={input_path}",
        err=True,
    )
    artifacts = run_pipeline(strategy, seed, input_path, check_hashseed=False)
    artifacts = write_artifacts(artifacts, output_dir, output_format)
    click.echo(f"wrote report to: {output_dir}", err=True)

    if not artifacts.report.passed:
        raise ValidationFailure(artifacts, output_format)
    return artifacts


__all__ = ["main", "ValidationFailure"]
