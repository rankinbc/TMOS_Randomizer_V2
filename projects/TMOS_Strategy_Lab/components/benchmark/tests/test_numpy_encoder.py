"""NumpyEncoder: json-dumps numpy scalar/array types."""
from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

# scripts/ isn't an installed package — stitch its path in so `from run import …` works.
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from run import NumpyEncoder  # noqa: E402


def test_encodes_numpy_scalars():
    payload = {"i": np.int64(7), "f": np.float64(3.14), "arr": np.array([1, 2, 3])}
    serialized = json.dumps(payload, cls=NumpyEncoder, sort_keys=True)
    assert json.loads(serialized) == {"i": 7, "f": 3.14, "arr": [1, 2, 3]}


def test_raises_on_truly_unknown_type():
    class Opaque:
        pass

    try:
        json.dumps({"x": Opaque()}, cls=NumpyEncoder)
    except TypeError:
        return
    raise AssertionError("NumpyEncoder should not silently serialize unknown objects.")
