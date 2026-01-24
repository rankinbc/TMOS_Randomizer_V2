#!/usr/bin/env python3
"""
Find data patterns in The Magic of Scheherazade ROM.

Searches for common data structures like:
- Text/string tables (ASCII patterns)
- Pointer tables (pairs of low/high bytes)
- Tile map data
- Level data signatures

Usage:
    python find_data.py --strings        # Find ASCII text
    python find_data.py --pointers       # Find pointer tables
    python find_data.py --pattern "FF FF"  # Find specific byte pattern
    python find_data.py --zeros          # Find zero-padded regions (likely data)
"""

import argparse
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SCRIPT_DIR)
PRG_ROM = os.path.join(BASE_DIR, "prg-rom.bin")

HEADER_SIZE = 16
BANK_SIZE = 8192

def load_prg_rom():
    """Load the PRG-ROM binary."""
    with open(PRG_ROM, 'rb') as f:
        return f.read()

def offset_to_bank_info(offset):
    """Convert PRG-ROM offset to bank and address info."""
    bank = offset // BANK_SIZE
    offset_in_bank = offset % BANK_SIZE

    if bank == 15:
        cpu_addr = 0xE000 + offset_in_bank
    elif bank == 14:
        cpu_addr = 0xC000 + offset_in_bank
    else:
        cpu_addr = 0x8000 + offset_in_bank

    return bank, cpu_addr

def find_ascii_strings(data, min_length=4):
    """Find sequences of printable ASCII characters."""
    results = []
    current_start = None
    current_string = []

    # Printable ASCII plus common control chars
    printable = set(range(0x20, 0x7F)) | {0x0A, 0x0D}

    for i, byte in enumerate(data):
        if byte in printable:
            if current_start is None:
                current_start = i
            current_string.append(chr(byte) if byte >= 0x20 else f'\\x{byte:02X}')
        else:
            if current_start is not None and len(current_string) >= min_length:
                bank, addr = offset_to_bank_info(current_start)
                results.append({
                    'offset': current_start,
                    'bank': bank,
                    'cpu_addr': addr,
                    'length': len(current_string),
                    'text': ''.join(current_string)
                })
            current_start = None
            current_string = []

    return results

def find_pointer_tables(data, min_entries=3):
    """Find likely pointer tables (sequences of word-aligned addresses)."""
    results = []

    # Look for sequences where pairs form valid addresses
    i = 0
    while i < len(data) - (min_entries * 2):
        table_start = i
        entries = []

        while i < len(data) - 1:
            low = data[i]
            high = data[i + 1]
            addr = low | (high << 8)

            # Valid NES code addresses are typically $8000-$FFFF
            # Also $C000-$FFFF for fixed banks
            if 0x8000 <= addr <= 0xFFFF:
                entries.append(addr)
                i += 2
            else:
                break

        if len(entries) >= min_entries:
            bank, cpu_addr = offset_to_bank_info(table_start)
            results.append({
                'offset': table_start,
                'bank': bank,
                'cpu_addr': cpu_addr,
                'entries': len(entries),
                'first_pointers': entries[:5]
            })
            # Skip to end of this table
        else:
            i = table_start + 1

    return results

def find_byte_pattern(data, pattern_str):
    """Find occurrences of a hex byte pattern."""
    # Parse pattern string like "FF 00 A9"
    parts = pattern_str.upper().split()
    pattern = []
    mask = []

    for part in parts:
        if part == '??' or part == '**':
            pattern.append(0)
            mask.append(False)
        else:
            pattern.append(int(part, 16))
            mask.append(True)

    results = []
    for i in range(len(data) - len(pattern) + 1):
        match = True
        for j, (p, m) in enumerate(zip(pattern, mask)):
            if m and data[i + j] != p:
                match = False
                break

        if match:
            bank, addr = offset_to_bank_info(i)
            context = data[i:i + len(pattern) + 8]
            results.append({
                'offset': i,
                'bank': bank,
                'cpu_addr': addr,
                'context': ' '.join(f'{b:02X}' for b in context)
            })

    return results

def find_zero_regions(data, min_length=16):
    """Find regions of zeros (likely padding or unused data areas)."""
    results = []
    current_start = None
    current_len = 0

    for i, byte in enumerate(data):
        if byte == 0x00 or byte == 0xFF:
            if current_start is None:
                current_start = i
                current_len = 1
            else:
                current_len += 1
        else:
            if current_start is not None and current_len >= min_length:
                bank, addr = offset_to_bank_info(current_start)
                results.append({
                    'offset': current_start,
                    'bank': bank,
                    'cpu_addr': addr,
                    'length': current_len,
                    'fill_byte': data[current_start]
                })
            current_start = None
            current_len = 0

    return results

def find_jump_tables(data):
    """Find likely jump tables (sequences of JMP or JSR instructions)."""
    results = []

    # JMP = 4C, JSR = 20
    i = 0
    while i < len(data) - 9:
        # Look for 3+ consecutive JMP or JSR instructions
        opcodes = []
        j = i
        while j < len(data) - 2:
            op = data[j]
            if op in (0x4C, 0x20):  # JMP or JSR
                low = data[j + 1]
                high = data[j + 2]
                addr = low | (high << 8)
                if 0x8000 <= addr <= 0xFFFF:
                    opcodes.append(('JMP' if op == 0x4C else 'JSR', addr))
                    j += 3
                else:
                    break
            else:
                break

        if len(opcodes) >= 3:
            bank, cpu_addr = offset_to_bank_info(i)
            results.append({
                'offset': i,
                'bank': bank,
                'cpu_addr': cpu_addr,
                'entries': len(opcodes),
                'instructions': opcodes[:5]
            })
            i = j
        else:
            i += 1

    return results

def main():
    parser = argparse.ArgumentParser(description='Find data patterns in TMOS ROM')

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--strings', '-s', action='store_true',
                       help='Find ASCII text strings')
    group.add_argument('--pointers', '-p', action='store_true',
                       help='Find pointer tables')
    group.add_argument('--pattern', '-x', help='Find hex byte pattern (e.g., "FF 00 A9")')
    group.add_argument('--zeros', '-z', action='store_true',
                       help='Find zero/FF padded regions')
    group.add_argument('--jumps', '-j', action='store_true',
                       help='Find jump tables')

    parser.add_argument('--min-length', '-l', type=int, default=4,
                        help='Minimum length for strings/regions')
    parser.add_argument('--bank', '-b', type=int, choices=range(16),
                        help='Limit search to specific bank')

    args = parser.parse_args()

    if not os.path.exists(PRG_ROM):
        print(f"Error: PRG-ROM not found at {PRG_ROM}", file=sys.stderr)
        sys.exit(1)

    data = load_prg_rom()

    # Filter to specific bank if requested
    if args.bank is not None:
        start = args.bank * BANK_SIZE
        data = data[start:start + BANK_SIZE]
        offset_adjust = start
    else:
        offset_adjust = 0

    if args.strings:
        results = find_ascii_strings(data, args.min_length)
        print(f"\nFound {len(results)} ASCII strings (min length {args.min_length}):\n")
        for r in results[:50]:  # Limit output
            r['offset'] += offset_adjust
            bank, addr = offset_to_bank_info(r['offset'])
            text_preview = r['text'][:40] + ('...' if len(r['text']) > 40 else '')
            print(f"Bank {bank:02d} ${addr:04X} (len {r['length']:3d}): {text_preview}")
        if len(results) > 50:
            print(f"\n... and {len(results) - 50} more")

    elif args.pointers:
        results = find_pointer_tables(data)
        print(f"\nFound {len(results)} likely pointer tables:\n")
        for r in results[:30]:
            r['offset'] += offset_adjust
            bank, addr = offset_to_bank_info(r['offset'])
            ptrs = ', '.join(f'${p:04X}' for p in r['first_pointers'])
            print(f"Bank {bank:02d} ${addr:04X}: {r['entries']} entries -> {ptrs}...")

    elif args.pattern:
        results = find_byte_pattern(data, args.pattern)
        print(f"\nFound {len(results)} matches for pattern '{args.pattern}':\n")
        for r in results[:50]:
            r['offset'] += offset_adjust
            bank, addr = offset_to_bank_info(r['offset'])
            print(f"Bank {bank:02d} ${addr:04X}: {r['context']}")

    elif args.zeros:
        results = find_zero_regions(data, args.min_length)
        print(f"\nFound {len(results)} padded regions (min length {args.min_length}):\n")
        for r in results:
            r['offset'] += offset_adjust
            bank, addr = offset_to_bank_info(r['offset'])
            fill = f"${r['fill_byte']:02X}"
            print(f"Bank {bank:02d} ${addr:04X}: {r['length']} bytes of {fill}")

    elif args.jumps:
        results = find_jump_tables(data)
        print(f"\nFound {len(results)} jump tables:\n")
        for r in results[:30]:
            r['offset'] += offset_adjust
            bank, addr = offset_to_bank_info(r['offset'])
            instrs = ', '.join(f'{op} ${a:04X}' for op, a in r['instructions'])
            print(f"Bank {bank:02d} ${addr:04X}: {r['entries']} entries -> {instrs}...")

if __name__ == '__main__':
    main()
