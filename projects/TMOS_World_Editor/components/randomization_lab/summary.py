"""Build summary.md from a run's per-strategy results."""
from __future__ import annotations

import json
from datetime import date
from typing import Iterable

import pandas as pd


def build_summary_markdown(
    run_desc: str,
    rom_md5: str,
    strategy_results: Iterable[dict],
) -> str:
    """Render the per-run markdown summary.

    Each ``strategy_results`` entry is a dict with:
        name, seed, total_failures, new_vs_pristine, failures_by_chapter (dict)
    """
    results = list(strategy_results)
    header = [
        f"# randomization_lab run — {run_desc}",
        "",
        f"- Date: {date.today().isoformat()}",
        f"- ROM MD5: `{rom_md5}`",
        f"- Strategies: {len(results)}",
        "",
    ]
    if not results:
        header.append("_(no strategies ran)_")
        return "\n".join(header) + "\n"

    rows = []
    for r in results:
        rows.append(
            {
                "Strategy": r["name"],
                "Seed": r["seed"],
                "Total failures": r["total_failures"],
                "New vs pristine": r["new_vs_pristine"],
                "Failures by chapter": json.dumps(r["failures_by_chapter"], sort_keys=True),
            }
        )
    df = pd.DataFrame(rows)
    table = df.to_markdown(index=False)
    return "\n".join(header) + table + "\n"
