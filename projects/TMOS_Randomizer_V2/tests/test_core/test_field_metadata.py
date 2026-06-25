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


def test_metadata_includes_enemy_entity():
    meta = build_field_metadata()
    enemy = meta["entities"]["enemy"]
    assert enemy["label"]
    for key in ("hp", "ep", "rupia"):
        f = enemy["fields"][key]
        assert f["tier"] == "safe"
        assert f["control"] == "number"
        assert len(f["valid_range"]) == 2
        assert f["description"]


def test_enemy_entity_documents_all_ten_bytes():
    fields = build_field_metadata()["entities"]["enemy"]["fields"]
    assert set(fields) == {
        "ep", "rupia", "bribe", "escape_trigger", "action_prob",
        "lineup_min", "action_prob2", "hp", "atk", "byte_9",
    }
    # Byte offsets are exactly 0..9, one per field.
    assert sorted(f["byte"] for f in fields.values()) == list(range(10))
    assert fields["bribe"]["byte"] == 2
    assert fields["atk"]["byte"] == 8
    for f in fields.values():
        assert f["tier"] in {"safe", "caution", "danger"}
        assert f["valid_range"] == [0, 255]
        assert f["description"]


def test_enemy_tier_assignment():
    fields = build_field_metadata()["entities"]["enemy"]["fields"]
    assert fields["bribe"]["tier"] == "safe"
    assert fields["atk"]["tier"] == "safe"
    assert fields["escape_trigger"]["tier"] == "caution"
    assert fields["byte_9"]["tier"] == "caution"


def test_metadata_version_is_two():
    assert build_field_metadata()["version"] == "2"
