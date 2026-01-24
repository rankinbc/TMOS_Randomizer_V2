# Confidence Level Guide

**Last Updated**: 2026-01-24

---

## Overview

Every documented fact in this knowledgebase includes a confidence level indicating how certain we are about its accuracy.

---

## Confidence Levels

### HIGH
**Definition**: Verified through multiple independent sources or direct testing.

**Criteria**:
- Confirmed in working code (C# projects)
- Verified by TAS tools (RAM watches, Lua scripts)
- FCEUX .nl labels present
- Multiple sources agree
- Hex-verified in ROM

**Examples**:
- Player HP address `$0081` (verified in FCEUX labels + TAS Lua)
- WorldScreen structure (verified in 3 C# projects)

---

### MEDIUM
**Definition**: Logical inference from verified data, or single reliable source.

**Criteria**:
- Single reliable source (FCEUX label OR working code)
- Inferred from pattern analysis
- Consistent with game behavior but not directly verified
- AI Docs manual notes (without external validation)

**Examples**:
- Music system RAM addresses (FCEUX labels only)
- Some chapter-specific content mappings

---

### LOW
**Definition**: Hypothesis based on observation, or conflicting sources.

**Criteria**:
- Single unverified source
- Conflicts between sources
- Incomplete data
- Guessed based on naming patterns

**Examples**:
- Unknown byte purposes in structures
- Tile type conflicts (WaterTopEdge/DesertTrees values)

---

### UNKNOWN
**Definition**: No reliable information available.

**Criteria**:
- Placeholder entries
- Completely undocumented areas
- Speculation only

---

## Source Reliability Ranking

| Source | Reliability | Notes |
|--------|-------------|-------|
| FCEUX .nl + TAS verified | HIGHEST | Direct memory observation |
| Working C# code | HIGH | Functional implementation |
| AI Docs (manual notes) | MEDIUM | Human observation, may have errors |
| Single source | LOW | No cross-validation |
| Speculation | LOWEST | Educated guesses only |

---

## Using Confidence Levels

1. **Randomizer development**: Only rely on HIGH confidence data
2. **Research/exploration**: MEDIUM is acceptable for investigation
3. **Documentation**: LOW should be marked and verified later
4. **UNKNOWN**: Should trigger investigation tasks

---

## Upgrading Confidence

To upgrade a fact's confidence:

1. **LOW → MEDIUM**: Find a second independent source
2. **MEDIUM → HIGH**: Verify with TAS tools or working code
3. Add verification notes to the document

---

## Related Documents

- [sources.md](sources.md) - Complete source list with reliability ratings
- [conflicts.md](conflicts.md) - Active and resolved conflicts
