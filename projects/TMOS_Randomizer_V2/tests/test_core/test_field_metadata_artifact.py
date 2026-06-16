import json
from pathlib import Path

from tmos_randomizer.core.field_metadata import build_field_metadata

ARTIFACT = (
    Path(__file__).resolve().parents[2]
    / "src" / "tmos_randomizer" / "data" / "field_metadata.json"
)


def test_artifact_exists_and_matches_builder():
    assert ARTIFACT.exists(), "Run: python tools/generate_field_metadata.py"
    on_disk = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    assert on_disk == build_field_metadata(), "Artifact stale — regenerate it."
