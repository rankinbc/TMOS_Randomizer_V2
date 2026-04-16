"""Tripwire: the shop_randomization module must fail to import.

Guards against a future contributor deleting the top-level `raise ImportError`
guard or otherwise re-enabling the module without the Bank 2 bytecode RE
work that would make it safe.

See TMOS_AI/docs/human/items-economy-re-answers.md.
"""

from __future__ import annotations

import importlib
import sys

import pytest


MODULE_NAME = "tmos_randomizer.logic.shop_randomization"


def test_import_raises_import_error():
    """Direct import of the disabled module must raise ImportError.

    The module may have been imported (and failed) earlier in the test session.
    Python caches that failure as None in sys.modules; clear it so importlib
    re-runs the module body and we see the fresh exception.
    """
    sys.modules.pop(MODULE_NAME, None)
    with pytest.raises(ImportError) as excinfo:
        importlib.import_module(MODULE_NAME)
    # Error must point to the RE doc for maintainer context.
    assert "items-economy-re-answers.md" in str(excinfo.value)


def test_error_message_mentions_bank_2_bytecode():
    """The error must explain WHY the module is disabled (undecoded bytecode)."""
    sys.modules.pop(MODULE_NAME, None)
    with pytest.raises(ImportError) as excinfo:
        importlib.import_module(MODULE_NAME)
    msg = str(excinfo.value).lower()
    assert "bank 2" in msg or "bytecode" in msg
