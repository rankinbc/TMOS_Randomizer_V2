#!/usr/bin/env python3
"""
Bank Mapper Utility for The Magic of Scheherazade

Maps between CPU addresses, ROM file offsets, and bank numbers.

Usage:
    python bank_mapper.py <address>
    python bank_mapper.py --offset <file_offset>
    python bank_mapper.py --bank <bank_number>

Examples:
    python bank_mapper.py 0xE19B      # Find ROM offset for CPU address $E19B
    python bank_mapper.py --offset 0x1E19B  # Find CPU address for file offset
    python bank_mapper.py --bank 15   # Show bank 15 information
"""

import argparse
import sys

# ROM configuration
HEADER_SIZE = 16
PRG_SIZE = 128 * 1024  # 128 KB
BANK_SIZE = 8 * 1024   # 8 KB
NUM_BANKS = 16

def cpu_to_rom(cpu_addr, bank=None):
    """Convert CPU address to ROM file offset(s)."""
    results = []

    # Determine which memory region
    if cpu_addr < 0x8000:
        return [{'error': f'Address ${cpu_addr:04X} is not in PRG-ROM space (< $8000)'}]

    if cpu_addr >= 0xE000:
        # Fixed bank 15
        offset_in_bank = cpu_addr - 0xE000
        file_offset = HEADER_SIZE + (15 * BANK_SIZE) + offset_in_bank
        results.append({
            'cpu_addr': cpu_addr,
            'bank': 15,
            'offset_in_bank': offset_in_bank,
            'file_offset': file_offset,
            'region': 'Fixed (Bank 15)'
        })
    elif cpu_addr >= 0xC000:
        # Fixed bank 14
        offset_in_bank = cpu_addr - 0xC000
        file_offset = HEADER_SIZE + (14 * BANK_SIZE) + offset_in_bank
        results.append({
            'cpu_addr': cpu_addr,
            'bank': 14,
            'offset_in_bank': offset_in_bank,
            'file_offset': file_offset,
            'region': 'Fixed (Bank 14)'
        })
    else:
        # Switchable region $8000-$BFFF
        offset_in_region = cpu_addr - 0x8000
        if offset_in_region < BANK_SIZE:
            # $8000-$9FFF
            if bank is not None:
                banks_to_check = [bank]
            else:
                banks_to_check = range(14)  # Banks 0-13 can be mapped here

            for b in banks_to_check:
                file_offset = HEADER_SIZE + (b * BANK_SIZE) + offset_in_region
                results.append({
                    'cpu_addr': cpu_addr,
                    'bank': b,
                    'offset_in_bank': offset_in_region,
                    'file_offset': file_offset,
                    'region': f'Switchable (could be bank 0-13)'
                })
                if bank is not None:
                    break
        else:
            # $A000-$BFFF
            offset_in_bank = offset_in_region - BANK_SIZE
            if bank is not None:
                banks_to_check = [bank]
            else:
                banks_to_check = range(14)

            for b in banks_to_check:
                file_offset = HEADER_SIZE + (b * BANK_SIZE) + BANK_SIZE + offset_in_bank
                results.append({
                    'cpu_addr': cpu_addr,
                    'bank': b,
                    'offset_in_bank': offset_in_bank,
                    'file_offset': file_offset,
                    'region': f'Switchable upper (could be bank 0-13)'
                })
                if bank is not None:
                    break

    return results

def rom_to_cpu(file_offset):
    """Convert ROM file offset to CPU address and bank."""
    if file_offset < HEADER_SIZE:
        return {'error': 'Offset is within iNES header (bytes 0-15)'}

    prg_offset = file_offset - HEADER_SIZE

    if prg_offset >= PRG_SIZE:
        return {'error': 'Offset is in CHR-ROM (graphics data, not code)'}

    bank = prg_offset // BANK_SIZE
    offset_in_bank = prg_offset % BANK_SIZE

    if bank == 15:
        cpu_addr = 0xE000 + offset_in_bank
        region = 'Fixed (Bank 15)'
    elif bank == 14:
        cpu_addr = 0xC000 + offset_in_bank
        region = 'Fixed (Bank 14)'
    else:
        cpu_addr = 0x8000 + offset_in_bank
        region = f'Switchable (Bank {bank})'

    return {
        'file_offset': file_offset,
        'bank': bank,
        'offset_in_bank': offset_in_bank,
        'cpu_addr': cpu_addr,
        'region': region
    }

def bank_info(bank_num):
    """Get information about a specific bank."""
    if bank_num < 0 or bank_num >= NUM_BANKS:
        return {'error': f'Invalid bank number: {bank_num} (valid: 0-15)'}

    file_start = HEADER_SIZE + (bank_num * BANK_SIZE)
    file_end = file_start + BANK_SIZE - 1

    if bank_num == 15:
        cpu_start = 0xE000
        cpu_end = 0xFFFF
        region = 'Fixed'
    elif bank_num == 14:
        cpu_start = 0xC000
        cpu_end = 0xDFFF
        region = 'Fixed'
    else:
        cpu_start = 0x8000
        cpu_end = 0x9FFF
        region = 'Switchable'

    return {
        'bank': bank_num,
        'file_offset_start': file_start,
        'file_offset_end': file_end,
        'cpu_addr_start': cpu_start,
        'cpu_addr_end': cpu_end,
        'size': BANK_SIZE,
        'region': region
    }

def print_result(result):
    """Pretty print a result dictionary."""
    if 'error' in result:
        print(f"Error: {result['error']}")
        return

    print("-" * 50)
    for key, value in result.items():
        if 'offset' in key.lower() or 'addr' in key.lower() or 'size' in key.lower():
            if isinstance(value, int):
                print(f"  {key}: 0x{value:05X} ({value})")
            else:
                print(f"  {key}: {value}")
        else:
            print(f"  {key}: {value}")
    print("-" * 50)

def parse_address(addr_str):
    """Parse an address string (handles 0x, $, or plain decimal)."""
    addr_str = addr_str.strip()
    if addr_str.startswith('$'):
        return int(addr_str[1:], 16)
    elif addr_str.lower().startswith('0x'):
        return int(addr_str, 16)
    else:
        # Try hex first, then decimal
        try:
            return int(addr_str, 16)
        except ValueError:
            return int(addr_str)

def main():
    parser = argparse.ArgumentParser(
        description='Map between CPU addresses, ROM offsets, and banks',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )

    group = parser.add_mutually_exclusive_group()
    group.add_argument('address', nargs='?', help='CPU address to look up')
    group.add_argument('--offset', '-o', help='ROM file offset to look up')
    group.add_argument('--bank', '-b', type=int, help='Show bank information')
    group.add_argument('--all-banks', '-a', action='store_true', help='Show all banks')

    parser.add_argument('--force-bank', '-f', type=int,
                        help='Force specific bank for switchable addresses')

    args = parser.parse_args()

    if args.all_banks:
        print("=" * 50)
        print("All PRG-ROM Banks")
        print("=" * 50)
        for i in range(NUM_BANKS):
            info = bank_info(i)
            print(f"\nBank {i:02d} ({info['region']}):")
            print(f"  File:  0x{info['file_offset_start']:05X} - 0x{info['file_offset_end']:05X}")
            print(f"  CPU:   ${info['cpu_addr_start']:04X} - ${info['cpu_addr_end']:04X}")
    elif args.bank is not None:
        result = bank_info(args.bank)
        print(f"\nBank {args.bank} Information:")
        print_result(result)
    elif args.offset:
        offset = parse_address(args.offset)
        result = rom_to_cpu(offset)
        print(f"\nROM Offset 0x{offset:05X}:")
        print_result(result)
    elif args.address:
        addr = parse_address(args.address)
        results = cpu_to_rom(addr, args.force_bank)
        print(f"\nCPU Address ${addr:04X}:")
        if len(results) == 1:
            print_result(results[0])
        else:
            print(f"  (Address could map to multiple banks)")
            for r in results[:3]:  # Show first 3
                print_result(r)
            if len(results) > 3:
                print(f"  ... and {len(results) - 3} more possibilities")
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
