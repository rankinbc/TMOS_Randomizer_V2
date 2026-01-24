# Building Contents Quick Reference

**Last Updated**: 2026-01-24
**RAM Address**: `$00B2` (WorldScreen byte 2)
**Source**: TAS flashdrive, Romhack code
**Confidence**: HIGH

---

## Overview

This is a quick reference for the Content byte (`$00B2`). For complete documentation, see [enums/content-types.md](../enums/content-types.md).

---

## Quick Lookup Table

| Value | Type | Description |
|-------|------|-------------|
| `$00` | None | Empty |
| `$01` | Battle | Wizard battle on enter |
| `$1D` | Palace | Frozen palace |
| `$20` | Mosque | First mosque (Isfa's descendant) |
| `$21-$2A` | Boss | Demon screens (bosses) |
| `$40-$55` | University | Magic universities |
| `$60-$66` | Shop | Various shops |
| `$75-$79` | Shop | Magic shops |
| `$7B-$7D` | Shop | Unused shops |
| `$7E` | Mosque | Standard mosque |
| `$7F` | Trooper | Trooper purchase |
| `$80-$8F` | NPC | Chapter-specific NPCs |
| `$A0-$B0` | Hotel | Hotels (various prices) |
| `$BC` | Tree | Rupia seed plant |
| `$BD` | Tree | Rupia tree |
| `$BE` | Casino | Gambling |
| `$C0` | TimeDoor | Time door enter |
| `$C7, $D7` | TimeDoor | Time door exit |
| `$FF` | Battle | Random encounter |

---

## Content Ranges

| Range | Category |
|-------|----------|
| `$00-$20` | Special/Bosses |
| `$21-$2A` | Demons (bosses) |
| `$40-$55` | Universities |
| `$60-$7F` | Shops & Services |
| `$80-$8F` | Chapter NPCs |
| `$A0-$BF` | Hotels/Casino/Trees |
| `$C0-$DF` | Time Doors |
| `$FF` | Random Battle |

---

## Screen Type Detection

```
Is Demon Screen: Content >= 0x21 && Content <= 0x2A
Is Wizard:       Content == 0x01
Has Time Door:   Content == 0xC0
Is Battle:       Content == 0xFF
```

---

## Related Documents

- [enums/content-types.md](../enums/content-types.md) - Complete content type documentation
- [structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation as quick reference |
