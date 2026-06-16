"""Generic post-generation repair passes (strategy-agnostic).

Operate on a finished GameWorld to guarantee invariants the generator may not have
met on its own -- starting with reachability repair (every screen reachable from
screen 0, warp-aware), by least-damage edits that preserve building entrances,
edge-validity, and era-safety.
"""
