"""Strategy registry + identity strategy basics."""
from __future__ import annotations

from components.randomization_lab.strategies import REGISTRY
from components.randomization_lab.strategies.identity import identity_strategy


def test_identity_registered():
    assert "identity" in REGISTRY
    assert REGISTRY["identity"] is identity_strategy


def test_identity_meta_present():
    meta = identity_strategy.meta
    assert meta.name == "identity"
    assert meta.version == "1.0"
    assert meta.default_seed == 0


def test_identity_returns_input_world():
    sentinel = object()
    assert identity_strategy(sentinel) is sentinel
    assert identity_strategy(sentinel, 42) is sentinel
