"""CLI entry point for TMOS Randomization Tester.

Usage:
    python -m tmos_randomizer.testing --rom PATH [seeds...]
    python -m tmos_randomizer.testing --rom PATH --count N
    python -m tmos_randomizer.testing --rom PATH 12345 --json
    python -m tmos_randomizer.testing --rom PATH 12345 -v
"""

import sys
import argparse
from pathlib import Path

from .tester import RandomizationTester
from .success_criteria import DEFAULT_CRITERIA, LENIENT_CRITERIA


def format_result(result, verbose: bool = False) -> str:
    """Format a test result as human-readable text."""
    lines = []

    status = "PASS" if result.passed else "FAIL"
    lines.append("=" * 60)
    lines.append(f"SEED {result.seed}: {status} ({result.duration_ms:.0f}ms)")
    lines.append("=" * 60)

    for chapter in result.chapters:
        lines.append(f"\nChapter {chapter.chapter_num}:")
        lines.append(
            f"  Reachability: {chapter.reachable_percent:.1f}% "
            f"({chapter.reachable_screens}/{chapter.total_screens})"
        )
        lines.append(f"  Nav Components: {chapter.nav_component_count}")

        if verbose:
            lines.append("  Sections:")
            for s in chapter.sections:
                icon = "[OK]" if s.passed else "[!!]"
                lines.append(
                    f"    {icon} {s.section_type}: "
                    f"{s.assigned_screens}/{s.planned_screens} screens, "
                    f"{s.component_count} components"
                )

        if chapter.errors:
            lines.append("  Errors:")
            for e in chapter.errors:
                lines.append(f"    - {e}")

    if result.criteria_failures:
        lines.append("\nCriteria Failures:")
        for f in result.criteria_failures:
            lines.append(f"  - {f}")

    return "\n".join(lines)


def format_summary(summary) -> str:
    """Format a test summary as human-readable text."""
    lines = []
    lines.append("=" * 60)
    status = "ALL PASSED" if summary.failed_tests == 0 else "SOME FAILED"
    lines.append(
        f"TEST SUMMARY: {summary.passed_tests}/{summary.total_tests} PASSED "
        f"({summary.pass_rate:.1f}%) - {status}"
    )
    lines.append("=" * 60)
    lines.append(f"Duration: {summary.total_duration_ms:.0f}ms")

    if summary.failed_seeds:
        lines.append(f"\nFailed seeds: {summary.failed_seeds}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="TMOS Randomization Tester",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Test specific seeds:
    python -m tmos_randomizer.testing --rom ROM.nes 12345 54321

  Test 10 random seeds:
    python -m tmos_randomizer.testing --rom ROM.nes --count 10

  Get JSON output:
    python -m tmos_randomizer.testing --rom ROM.nes 12345 --json

  Verbose output with section details:
    python -m tmos_randomizer.testing --rom ROM.nes 12345 -v
        """,
    )
    parser.add_argument(
        "seeds",
        nargs="*",
        type=int,
        help="Seeds to test (if empty, uses --count random seeds)",
    )
    parser.add_argument(
        "--rom",
        type=Path,
        required=True,
        help="Path to ROM file",
    )
    parser.add_argument(
        "--count",
        type=int,
        default=10,
        help="Number of random seeds to test (default: 10)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output results as JSON",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Verbose output with section details",
    )
    parser.add_argument(
        "--lenient",
        action="store_true",
        help="Use lenient success criteria",
    )

    args = parser.parse_args()

    # Validate ROM exists
    if not args.rom.exists():
        print(f"ERROR: ROM not found: {args.rom}", file=sys.stderr)
        return 1

    # Create tester
    criteria = LENIENT_CRITERIA if args.lenient else DEFAULT_CRITERIA
    tester = RandomizationTester(args.rom, criteria=criteria)

    # Run tests
    if args.seeds:
        summary = tester.test_seeds(args.seeds)
    else:
        summary = tester.test_random_seeds(args.count)

    # Output results
    if args.json:
        import json

        output = {
            "summary": summary.to_dict(),
            "results": [r.to_dict() for r in summary.results],
        }
        print(json.dumps(output, indent=2))
    else:
        # Print summary
        print(format_summary(summary))

        # Print individual results if verbose or if there are failures
        if args.verbose or summary.failed_tests > 0:
            for result in summary.results:
                if args.verbose or not result.passed:
                    print()
                    print(format_result(result, verbose=args.verbose))

    return 0 if summary.failed_tests == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
