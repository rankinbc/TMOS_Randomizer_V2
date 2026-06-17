"""CLI entry point for the TMOS testing framework.

The real, fail-closed differential oracle lives in ``batch.py``. This package
entry point delegates to it, so both of these run the same thing:

    python -m tmos_randomizer.testing --rom ROM.nes --count 50
    python -m tmos_randomizer.testing.batch --rom ROM.nes --count 50

The retired ``tester.py`` harness (hardcoded, false-passing) used to live here.
"""

import sys

from .batch import _main

if __name__ == "__main__":
    sys.exit(_main())
