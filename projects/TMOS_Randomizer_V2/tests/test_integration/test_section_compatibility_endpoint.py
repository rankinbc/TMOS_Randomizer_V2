"""Endpoint test for the compatibility-aware tilesection picker.

Drives the real FastAPI app against the default vanilla ROM. Skips when the ROM
is unavailable, matching the project's existing asset-dependent test pattern.
Sanity checks (not exhaustive): well-formed 200, ``compatible`` is a non-empty
PROPER subset of all sections, and ``suggested`` ⊆ ``compatible``.
"""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server
from tmos_randomizer.core.constants import TILESECTION_COUNT


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    resp = c.post("/api/rom/load-default")
    if resp.status_code != 200:
        pytest.skip("default ROM not available")
    return c


def test_section_compatibility_well_formed(client):
    # Chapter 1, screen 18 — a representative overworld screen with neighbors.
    resp = client.get("/api/rom/screen/1/18/section-compatibility?half=top")
    assert resp.status_code == 200
    body = resp.json()

    assert set(body.keys()) == {"compatible", "suggested"}
    compatible = body["compatible"]
    suggested = body["suggested"]
    assert isinstance(compatible, list)
    assert isinstance(suggested, list)

    # Proper, non-empty subset: neighbor constraints prune some but not all.
    assert len(compatible) > 0
    assert len(compatible) < TILESECTION_COUNT

    # All indices are valid global tilesection indices.
    assert all(0 <= g < TILESECTION_COUNT for g in compatible)

    # suggested ⊆ compatible.
    assert set(suggested).issubset(set(compatible))


def test_section_compatibility_bottom_half(client):
    resp = client.get("/api/rom/screen/1/18/section-compatibility?half=bottom")
    assert resp.status_code == 200
    body = resp.json()
    assert 0 < len(body["compatible"]) < TILESECTION_COUNT
    assert set(body["suggested"]).issubset(set(body["compatible"]))


def test_section_compatibility_bad_half(client):
    resp = client.get("/api/rom/screen/1/18/section-compatibility?half=middle")
    assert resp.status_code == 422  # query pattern validation


def test_section_compatibility_missing_screen(client):
    resp = client.get("/api/rom/screen/1/9999/section-compatibility?half=top")
    assert resp.status_code == 404
