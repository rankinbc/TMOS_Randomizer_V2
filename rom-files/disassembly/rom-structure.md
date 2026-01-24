# The Magic of Scheherazade - ROM Structure Analysis

**Confidence Level: HIGH**

## iNES Header Summary

| Field | Value |
|-------|-------|
| Format | iNES 1.0 |
| PRG-ROM | 128 KB (8 x 16KB or 16 x 8KB banks) |
| CHR-ROM | 128 KB (16 x 8KB banks) |
| Mapper | 1 (MMC1 / SxROM) |
| Mirroring | Horizontal |
| Battery | No |
| Trainer | No |

## File Layout

```
Offset      Size        Content
--------------------------------------
0x00000     16 bytes    iNES Header
0x00010     128 KB      PRG-ROM (Code)
0x20010     128 KB      CHR-ROM (Graphics)
--------------------------------------
Total:      262,160 bytes
```

## PRG-ROM Banks (8KB each)

| Bank | File Offset | CPU Address (when mapped) |
|------|-------------|---------------------------|
| 00 | 0x00010 - 0x0200F | $8000-$9FFF (switchable) |
| 01 | 0x02010 - 0x0400F | $8000-$9FFF or $A000-$BFFF |
| 02 | 0x04010 - 0x0600F | $8000-$9FFF or $A000-$BFFF |
| 03 | 0x06010 - 0x0800F | $8000-$9FFF or $A000-$BFFF |
| 04 | 0x08010 - 0x0A00F | $8000-$9FFF or $A000-$BFFF |
| 05 | 0x0A010 - 0x0C00F | $8000-$9FFF or $A000-$BFFF |
| 06 | 0x0C010 - 0x0E00F | $8000-$9FFF or $A000-$BFFF |
| 07 | 0x0E010 - 0x1000F | $8000-$9FFF or $A000-$BFFF |
| 08 | 0x10010 - 0x1200F | $8000-$9FFF or $A000-$BFFF |
| 09 | 0x12010 - 0x1400F | $8000-$9FFF or $A000-$BFFF |
| 10 | 0x14010 - 0x1600F | $8000-$9FFF or $A000-$BFFF |
| 11 | 0x16010 - 0x1800F | $8000-$9FFF or $A000-$BFFF |
| 12 | 0x18010 - 0x1A00F | $8000-$9FFF or $A000-$BFFF |
| 13 | 0x1A010 - 0x1C00F | $8000-$9FFF or $A000-$BFFF |
| 14 | 0x1C010 - 0x1E00F | $C000-$DFFF (fixed, low) |
| 15 | 0x1E010 - 0x2000F | $E000-$FFFF (fixed, high) |

## MMC1 Memory Map

```
$0000-$07FF  2KB Internal RAM
$0800-$1FFF  Mirrors of $0000-$07FF
$2000-$2007  PPU Registers
$2008-$3FFF  Mirrors of $2000-$2007
$4000-$401F  APU and I/O Registers
$4020-$5FFF  Expansion ROM (unused)
$6000-$7FFF  8KB PRG-RAM (if present)
$8000-$BFFF  16KB Switchable PRG-ROM Bank
$C000-$FFFF  16KB Fixed PRG-ROM Bank (last bank)
```

## Interrupt Vectors (in Bank 15)

Located at end of PRG-ROM (file offset 0x1FFFA - 0x1FFFF):

| Vector | Address | Purpose |
|--------|---------|---------|
| NMI | $FFFA-$FFFB | Non-Maskable Interrupt (VBlank) |
| RESET | $FFFC-$FFFD | Power-on/Reset entry point |
| IRQ/BRK | $FFFE-$FFFF | IRQ/BRK interrupt |

## Notes

1. MMC1 can operate in different banking modes - the exact mode used by this game needs runtime analysis
2. The last 16KB ($C000-$FFFF) contains the fixed bank with reset code and vectors
3. CHR-ROM contains tile/sprite graphics data - not executable code
4. No trainer data present
5. No battery-backed save RAM indicated in header
