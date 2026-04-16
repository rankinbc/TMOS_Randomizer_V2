"""Organic randomization strategy.

Extracts per-section spatial templates from the ORIGINAL ROM and shuffles
content within each template, placing screens so edges line up. Preserves
the feel of the real game (natural-looking maps, real section shapes)
while producing a different-but-consistent playthrough.

Importing this package triggers registration of ``OrganicStrategy``.
"""

from .strategy import OrganicStrategy

__all__ = ["OrganicStrategy"]
