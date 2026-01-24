# Data Conflicts Log

**Last Updated**: 2026-01-24

---

## Overview

This document tracks conflicts between data sources. Conflicts should be resolved through hex verification when possible.

---

## Active Conflicts

### CONFLICT-001: TileType Hex Values

**Status**: UNRESOLVED
**Discovered**: 2026-01-24
**Priority**: LOW (does not block randomizer development)

| Tile | AI Docs Value | Romhack3 Value |
|------|---------------|----------------|
| WaterTopEdge | `0x6F` | `0x44` |
| DesertTrees | `0x23` | `0x6F` |

**Sources**:
- AI Docs: `TMOS AI Docs/WorldScreenInfo.md`
- Romhack3: `Tmos.Romhacks.Library/Enum/TileType.cs`

**Analysis**:
- Romhack3 is working C# code, suggesting higher reliability
- AI Docs may have transcription error
- Both values are documented in [enums/tiles.md](../enums/tiles.md)

**Resolution Plan**:
1. Open ROM in hex editor
2. Find tile definition table at `$011B0B`
3. Verify actual byte values for these tile types
4. Update knowledgebase with verified values

---

## Resolved Conflicts

### CONFLICT-000: TileSection Count

**Status**: RESOLVED
**Resolution Date**: 2026-01-24

| Source | Value |
|--------|-------|
| TMOS-Rom-Editor-2 | 940 TileSections |
| TMOS_Romhack3 | 471 TileSections |

**Resolution**:
- TMOS_Romhack3 value of 471 is correct
- TMOS-Rom-Editor-2 may have counted both banks separately (471 + 469 = 940)
- Using 471 as authoritative count

---

## Conflict Resolution Process

### When Conflicts Are Found
1. Document in this file with unique ID
2. Note both values in relevant knowledgebase files
3. Add to resolution queue

### To Resolve
1. Hex-verify in ROM when possible
2. Test in emulator if runtime behavior
3. Update all affected documents
4. Move to "Resolved Conflicts" section

---

## Related Documents

- [sources.md](sources.md) - Source reliability ratings
- [confidence-guide.md](confidence-guide.md) - Confidence level definitions
