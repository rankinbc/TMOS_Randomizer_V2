"""Generate the baked field-metadata JSON artifact.

This artifact (``src/tmos_randomizer/data/field_metadata.json``) is a versioned,
build-time *snapshot* of :func:`build_field_metadata`, shipped with the package
for frontend/offline consumption and reproducibility. It is NOT the runtime
source of truth: the live ``GET /api/metadata/fields`` endpoint always serves
the builder's output directly, so ``build_field_metadata()`` remains the single
source of truth. The staleness test (``tests/test_core/test_field_metadata_artifact.py``)
guards that this snapshot stays in sync with the builder; re-run this script
whenever the builder changes.

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
