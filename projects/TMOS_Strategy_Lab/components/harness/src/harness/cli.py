"""harness — CLI entry point.

Wraps ``commands.run.main`` so ``python -m harness run …`` dispatches to a
Click group with a single ``run`` subcommand. Keeping it a group (rather than
a bare command) leaves room for future subcommands (e.g. ``list-strategies``)
without breaking the invocation surface.
"""
from __future__ import annotations

import sys

import click

from harness.commands import run as run_cmd


@click.group(help="Run a Lab strategy on one seed and emit a ValidationReport.")
def main() -> None:
    pass


main.add_command(run_cmd.main, name="run")


def _cli_entry() -> None:
    """Wrapper invoked by ``__main__.py`` / console_scripts.

    Handles ``ValidationFailure`` (exit 2) and generic ``ClickException``
    (exit 1 for misuse) cleanly so the caller sees honest exit codes even
    with ``standalone_mode=False`` on the subcommand.
    """
    try:
        main(standalone_mode=False)
    except run_cmd.ValidationFailure as exc:
        exc.show()
        sys.exit(exc.exit_code)
    except click.ClickException as exc:
        exc.show()
        sys.exit(exc.exit_code)
    except click.Abort:
        sys.exit(1)


__all__ = ["main", "_cli_entry"]
