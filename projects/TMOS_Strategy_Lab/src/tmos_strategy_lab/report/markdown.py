"""Markdown rendering of a ValidationReport via Jinja2."""
from __future__ import annotations

from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, select_autoescape

_TEMPLATE_DIR = Path(__file__).parent / "templates"


def _env(template_dir: Path | None = None) -> Environment:
    td = template_dir or _TEMPLATE_DIR
    return Environment(
        loader=FileSystemLoader(str(td)),
        autoescape=select_autoescape(default_for_string=False),
        trim_blocks=True,
        lstrip_blocks=True,
    )


def render_report(report: Any, template_dir: Path | None = None) -> str:
    """Render a ValidationReport.to_dict() into Markdown.

    Accepts either a ``ValidationReport`` instance or an already-dict form.
    """
    if hasattr(report, "to_dict"):
        ctx = report.to_dict()
    else:
        ctx = dict(report)
    return _env(template_dir).get_template("report.md.j2").render(**ctx)


__all__ = ["render_report"]
