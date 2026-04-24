# identity — baseline reference strategy

## Purpose

Emit a Candidate that exactly matches the input ROM / snapshot. Every
byte of every WorldScreen in the output Candidate equals the byte in the
input. No randomization, no mutation, no repairs.

## Why it exists

1. **Reference baseline** — every metric must pass on stock content by
   construction. If a metric flags `identity` on the stock ROM, the metric
   itself is broken, not the strategy.
2. **Determinism smoke-test** — two runs with the same seed must produce
   byte-identical Candidate JSON, because `identity` has zero randomness
   to disagree about.
3. **End-to-end pipeline probe** — the harness → metrics → report → viz
   chain can be exercised without touching a real randomizer.

## Constraints honored

- **Immutability**: `ctx.game_world` is not touched; the Candidate takes
  copies of the dict form via `WorldScreen.to_dict()`.
- **Determinism**: trivially — nothing depends on the seed.
- **No repairs**: the Candidate's `repairs` list is always empty.

## Known limitations

- Variety entropy on the stock ROM is just what the game ships with;
  downstream comparison against other strategies is fine, but the value
  itself is not a "target".
- If the input snapshot was produced from a ROM different from V2's
  expected MD5 (`b3236db14c87f375e5f24a5b9b79f071`), the Candidate will
  faithfully reproduce *that* ROM — including any corruption.
