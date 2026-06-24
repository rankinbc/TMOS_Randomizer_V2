from tmos_randomizer.api.debug_changes import diff_structured, build_changes


def test_identical_structures_have_no_diff():
    obj = {"hp": [10, 20], "name": "x"}
    assert diff_structured(obj, dict(obj)) == []


def test_scalar_change_is_reported_with_path():
    cur = {"hp": [10, 99]}
    van = {"hp": [10, 20]}
    diffs = diff_structured(cur, van)
    assert diffs == [{"label": "hp[1]", "vanilla": 20, "current": 99}]


def test_nested_and_list_length_changes():
    cur = {"a": {"b": 2}, "list": [1, 2, 3]}
    van = {"a": {"b": 1}, "list": [1, 2]}
    diffs = diff_structured(cur, van)
    labels = {d["label"] for d in diffs}
    assert "a.b" in labels
    assert "list[2]" in labels  # extra element in current


def test_build_changes_groups_and_counts():
    rom = bytes([0, 1, 2, 9])
    van = bytes([0, 1, 2, 3])
    providers = [
        ("Hero", lambda b: {"last": b[3]}),
        ("Quiet", lambda b: {"const": 7}),
    ]
    out = build_changes(rom, van, providers)
    assert out["total_changes"] == 1
    assert out["differing_bytes"] == 1
    assert len(out["groups"]) == 1
    g = out["groups"][0]
    assert g["system"] == "Hero" and g["count"] == 1
    assert g["entries"][0] == {"label": "last", "vanilla": 3, "current": 9}


def test_provider_exception_does_not_kill_diff():
    rom, van = b"\x01", b"\x00"
    providers = [("Boom", lambda b: (_ for _ in ()).throw(ValueError("x"))),
                 ("Ok", lambda b: {"v": b[0]})]
    out = build_changes(rom, van, providers)
    systems = {g["system"] for g in out["groups"]}
    assert systems == {"Ok"}  # Boom swallowed, Ok still reported
