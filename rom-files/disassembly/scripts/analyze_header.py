#!/usr/bin/env python3
"""Analyze NES iNES ROM header"""

import sys

def analyze_ines_header(rom_path):
    with open(rom_path, 'rb') as f:
        header = f.read(16)
    
    # Verify magic number
    magic = header[0:4]
    if magic != b'NES\x1a':
        print("ERROR: Not a valid iNES ROM file")
        return None
    
    prg_rom_size = header[4] * 16384  # in bytes (16KB units)
    chr_rom_size = header[5] * 8192   # in bytes (8KB units)
    
    flags6 = header[6]
    flags7 = header[7]
    
    # Parse flags6
    mirroring = "Vertical" if (flags6 & 0x01) else "Horizontal"
    battery = bool(flags6 & 0x02)
    trainer = bool(flags6 & 0x04)
    four_screen = bool(flags6 & 0x08)
    mapper_lo = (flags6 >> 4) & 0x0F
    
    # Parse flags7
    vs_unisystem = bool(flags7 & 0x01)
    playchoice = bool(flags7 & 0x02)
    nes2_format = ((flags7 >> 2) & 0x03) == 2
    mapper_hi = (flags7 >> 4) & 0x0F
    
    mapper = mapper_lo | (mapper_hi << 4)
    
    # Mapper names
    mapper_names = {
        0: "NROM (no mapper)",
        1: "MMC1 (SxROM)",
        2: "UxROM",
        3: "CNROM",
        4: "MMC3 (TxROM)",
        5: "MMC5 (ExROM)",
        7: "AxROM",
        9: "MMC2 (PxROM)",
        10: "MMC4 (FxROM)",
    }
    mapper_name = mapper_names.get(mapper, f"Unknown ({mapper})")
    
    prg_banks_16k = header[4]
    prg_banks_8k = header[4] * 2
    chr_banks_8k = header[5]
    chr_banks_4k = header[5] * 2
    
    print("=" * 60)
    print("NES ROM HEADER ANALYSIS")
    print("=" * 60)
    print(f"Magic:           {magic}")
    print(f"Format:          {'iNES 2.0' if nes2_format else 'iNES 1.0'}")
    print()
    print("MEMORY LAYOUT:")
    print(f"  PRG-ROM:       {prg_rom_size:,} bytes ({prg_rom_size // 1024} KB)")
    print(f"                 {prg_banks_16k} x 16KB banks")
    print(f"                 {prg_banks_8k} x 8KB banks")
    print(f"  CHR-ROM:       {chr_rom_size:,} bytes ({chr_rom_size // 1024} KB)")
    print(f"                 {chr_banks_8k} x 8KB banks")
    print()
    print("MAPPER:")
    print(f"  Mapper #:      {mapper}")
    print(f"  Mapper Name:   {mapper_name}")
    print()
    print("FLAGS:")
    print(f"  Mirroring:     {mirroring}")
    print(f"  Battery:       {battery}")
    print(f"  Trainer:       {trainer} (512 bytes before PRG)")
    print(f"  4-Screen VRAM: {four_screen}")
    print(f"  VS UniSystem:  {vs_unisystem}")
    print(f"  PlayChoice-10: {playchoice}")
    print()
    print("ROM FILE OFFSETS:")
    trainer_size = 512 if trainer else 0
    prg_start = 16 + trainer_size
    chr_start = prg_start + prg_rom_size
    print(f"  Header:        0x0000 - 0x000F (16 bytes)")
    if trainer:
        print(f"  Trainer:       0x0010 - 0x020F (512 bytes)")
    print(f"  PRG-ROM:       0x{prg_start:04X} - 0x{prg_start + prg_rom_size - 1:04X}")
    print(f"  CHR-ROM:       0x{chr_start:04X} - 0x{chr_start + chr_rom_size - 1:04X}")
    print()
    
    # For PRG banks
    print("PRG BANK LAYOUT (8KB banks):")
    for i in range(prg_banks_8k):
        bank_start = prg_start + (i * 8192)
        bank_end = bank_start + 8191
        print(f"  Bank {i:02d}:       0x{bank_start:05X} - 0x{bank_end:05X}")
    
    return {
        'prg_size': prg_rom_size,
        'chr_size': chr_rom_size,
        'mapper': mapper,
        'mapper_name': mapper_name,
        'prg_start': prg_start,
        'prg_banks_8k': prg_banks_8k,
        'trainer': trainer
    }

if __name__ == "__main__":
    rom_path = sys.argv[1] if len(sys.argv) > 1 else "TMOS_ORIGINAL.nes"
    analyze_ines_header(rom_path)
