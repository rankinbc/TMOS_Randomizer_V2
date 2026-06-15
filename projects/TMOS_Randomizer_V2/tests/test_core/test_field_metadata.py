from tmos_randomizer.core.field_metadata import build_field_metadata

VALID_TIERS = {"safe", "caution", "danger"}


def test_has_worldscreen_entity_with_16_fields():
    meta = build_field_metadata()
    ws = meta["entities"]["worldscreen"]
    assert ws["label"] == "World Screen"
    # All 16 ROM bytes are represented.
    assert len(ws["fields"]) == 16


def test_every_field_has_required_keys_and_valid_tier():
    meta = build_field_metadata()
    for field in meta["entities"]["worldscreen"]["fields"].values():
        assert {"label", "byte", "tier", "description"} <= field.keys()
        assert field["tier"] in VALID_TIERS
        assert isinstance(field["description"], str) and field["description"]


def test_tier_assignments_match_spec():
    fields = build_field_metadata()["entities"]["worldscreen"]["fields"]
    assert fields["top_tiles"]["tier"] == "safe"
    assert fields["worldscreen_color"]["tier"] == "safe"
    assert fields["content"]["tier"] == "caution"
    assert fields["parent_world"]["tier"] == "caution"
    # Crash/corruption-prone bytes are Danger (Expert-tab only).
    assert fields["objectset"]["tier"] == "danger"
    assert fields["datapointer"]["tier"] == "danger"
    assert fields["exit_position"]["tier"] == "danger"
    assert fields["event"]["tier"] == "danger"


def test_content_field_has_enum_and_chapter_warning():
    content = build_field_metadata()["entities"]["worldscreen"]["fields"]["content"]
    assert content["control"] == "enum"
    # Enum is non-empty list of {value,label}.
    assert content["enum"] and {"value", "label"} <= content["enum"][0].keys()
    # Chapter-specific NPC hazard surfaced as a warning.
    assert "chapter" in content["warning"].lower()


def test_version_and_source_present():
    meta = build_field_metadata()
    assert meta["version"]
    assert "enums" in meta["generated_from"]
