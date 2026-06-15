"""Generate the baked field-metadata JSON artifact.

Usage:
    python tools/generate_field_metadata.py
"""

from __future__ import annotations

import json
from pathlib import Path

from tmos_randomizer.core.field_metadata import build_field_metadata

OUTPUT = (
    Path(__file__).resolve().parents[1]
    / "src" / "tmos_randomizer" / "data" / "field_metadata.json"
)


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(
        json.dumps(build_field_metadata(), indent=2) + "\n", encoding="utf-8"
    )
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
