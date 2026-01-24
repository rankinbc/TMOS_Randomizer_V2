# The Magic of Scheherazade - Disassembly Reference

This folder contains a complete 6502 disassembly of The Magic of Scheherazade NES ROM.

## Quick Start

```bash
# View the full disassembly
cat output/full_disassembly.asm | less

# View a specific bank
cat output/banks/bank_15.asm | less   # Bank 15 has RESET/NMI handlers

# Search for a pattern
python scripts/search_disassembly.py "JSR.*E3C9"

# Find where a CPU address is in the ROM
python scripts/bank_mapper.py 0xE19B
```

## Directory Structure

```
disassembly/
├── README.md              # This file
├── rom-structure.md       # ROM header analysis and memory map
├── prg-rom.bin            # Extracted PRG-ROM (128 KB, no header)
├── config/                # da65 configuration files
│   ├── tmos_common.info   # Common labels (NES hardware)
│   └── tmos_fixed_bank.info
├── output/                # Disassembly output
│   ├── full_disassembly.asm   # Complete 80K+ line disassembly
│   └── banks/             # Individual bank files
│       ├── bank_00.asm through bank_15.asm
│       └── bank_XX.info   # Per-bank config files
├── scripts/               # Utility scripts
│   ├── analyze_header.py  # ROM header parser
│   ├── disassemble_all.sh # Main disassembly script
│   ├── search_disassembly.py  # Search tool
│   ├── bank_mapper.py     # Address/offset converter
│   └── find_data.py       # Data pattern finder
└── tools/                 # cc65/da65 binaries
    └── bin/
        └── da65.exe
```

## ROM Information

| Property | Value |
|----------|-------|
| PRG-ROM | 128 KB (16 x 8KB banks) |
| CHR-ROM | 128 KB (graphics, not disassembled) |
| Mapper | 1 (MMC1) |
| Format | iNES 1.0 |

## Memory Map

```
NES CPU Memory:
$0000-$07FF  RAM (2KB)
$2000-$2007  PPU Registers
$4000-$4017  APU/IO Registers
$8000-$9FFF  Switchable PRG Bank (Banks 0-13)
$A000-$BFFF  Switchable PRG Bank
$C000-$DFFF  Fixed PRG Bank 14
$E000-$FFFF  Fixed PRG Bank 15 (vectors here)
```

## Key Entry Points

| Vector | Address | Handler |
|--------|---------|---------|
| RESET | $FFFC | $E19B (RESET_Handler) |
| NMI | $FFFA | $E3C9 (NMI_Handler) |
| IRQ | $FFFE | $E19B |

## Utility Scripts

### search_disassembly.py
Search the disassembly for patterns:

```bash
# Find all JSR instructions to $E3xx
python scripts/search_disassembly.py "jsr.*\$E3"

# Find all SEI instructions
python scripts/search_disassembly.py -t opcode "sei"

# Find PPU-related code
python scripts/search_disassembly.py -t label "PPU"

# Search only in bank 15
python scripts/search_disassembly.py -b 15 "RESET"
```

### bank_mapper.py
Convert between CPU addresses and ROM file offsets:

```bash
# Find ROM offset for CPU address
python scripts/bank_mapper.py 0xE19B

# Find CPU address for ROM offset
python scripts/bank_mapper.py --offset 0x1E19B

# Show all bank information
python scripts/bank_mapper.py --all-banks
```

### find_data.py
Find data structures in the ROM:

```bash
# Find ASCII text strings
python scripts/find_data.py --strings

# Find pointer tables
python scripts/find_data.py --pointers

# Find specific byte pattern
python scripts/find_data.py --pattern "A9 00 8D"

# Find zero-padded regions (likely data, not code)
python scripts/find_data.py --zeros

# Find jump tables
python scripts/find_data.py --jumps
```

## Understanding the Disassembly

### Labels
- `L????` - Auto-generated labels for branch/jump targets
- `PPU_CTRL`, `PPU_MASK`, etc. - NES hardware registers
- `RESET_Handler`, `NMI_Handler` - Interrupt handlers

### Comments
Each instruction includes its address in a comment:
```asm
        lda     #$00                            ; E19D
        sta     PPU_CTRL                        ; E19F
```

### Data vs Code
The disassembler interprets everything as code. Regions that contain data
(graphics pointers, text, level data) will appear as nonsensical instructions.
Look for:
- `.byte` directives (explicit data)
- Unusual instruction sequences
- Addresses that don't make sense as branch targets

## Re-running Disassembly

To regenerate the disassembly (e.g., after modifying config files):

```bash
bash scripts/disassemble_all.sh
```

## Statistics

- Total disassembly lines: ~80,000
- Full disassembly size: ~4.2 MB
- Individual bank files: ~250-360 KB each

## Next Steps for Analysis

1. **Identify data regions** - Use `find_data.py` to locate strings and tables
2. **Trace from RESET** - Follow execution from $E19B
3. **Find the main loop** - Usually called from NMI handler
4. **Locate text engine** - Search for string printing routines
5. **Map bank switching** - Look for MMC1 register writes

## Tools Used

- **da65** (v2.19) from cc65 suite - Primary disassembler
- **Python 3** - Utility scripts

## Credits

Disassembly generated for reverse engineering and research purposes.
