#!/usr/bin/env python3
"""
Search the TMOS disassembly for patterns, opcodes, or labels.

Usage:
    python search_disassembly.py <pattern> [options]

Options:
    -t, --type    Search type: text (default), hex, opcode, label
    -b, --bank    Limit search to specific bank (0-15)
    -c, --context Number of context lines (default: 2)
    -i            Case-insensitive search

Examples:
    python search_disassembly.py "jsr.*E3"     # Find JSR to E3xx addresses
    python search_disassembly.py -t hex "A9 00 8D"  # Find LDA #$00; STA pattern
    python search_disassembly.py -t opcode "sei"    # Find all SEI instructions
    python search_disassembly.py -t label "PPU"     # Find PPU-related labels
"""

import argparse
import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SCRIPT_DIR)
BANKS_DIR = os.path.join(BASE_DIR, "output", "banks")
FULL_DISASM = os.path.join(BASE_DIR, "output", "full_disassembly.asm")

def search_file(filepath, pattern, context=2, case_insensitive=False):
    """Search a file for a pattern and return matches with context."""
    results = []
    flags = re.IGNORECASE if case_insensitive else 0

    try:
        regex = re.compile(pattern, flags)
    except re.error as e:
        print(f"Invalid regex pattern: {e}", file=sys.stderr)
        return results

    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            lines = f.readlines()
    except IOError as e:
        print(f"Error reading {filepath}: {e}", file=sys.stderr)
        return results

    for i, line in enumerate(lines):
        if regex.search(line):
            start = max(0, i - context)
            end = min(len(lines), i + context + 1)

            context_lines = []
            for j in range(start, end):
                prefix = ">>>" if j == i else "   "
                context_lines.append(f"{prefix} {j+1:5d}: {lines[j].rstrip()}")

            results.append({
                'file': os.path.basename(filepath),
                'line_num': i + 1,
                'line': line.rstrip(),
                'context': context_lines
            })

    return results

def hex_pattern_to_regex(hex_str):
    """Convert a hex pattern like 'A9 00 8D' to a regex for disassembly."""
    # Remove extra spaces and split
    bytes_list = hex_str.upper().split()

    # Build regex that matches comment section showing these bytes
    # da65 format: instruction     ; ADDR  followed by hex bytes in comments
    # We look for the bytes appearing in sequence
    pattern_parts = []
    for b in bytes_list:
        if b == '??':
            pattern_parts.append(r'[0-9A-F]{2}')
        else:
            pattern_parts.append(b)

    # Match these bytes appearing in the comment field
    return r'\$' + r'.*\$'.join(pattern_parts)

def main():
    parser = argparse.ArgumentParser(
        description='Search TMOS disassembly for patterns',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument('pattern', help='Search pattern (regex supported)')
    parser.add_argument('-t', '--type', choices=['text', 'hex', 'opcode', 'label'],
                        default='text', help='Search type')
    parser.add_argument('-b', '--bank', type=int, choices=range(16),
                        help='Limit to specific bank (0-15)')
    parser.add_argument('-c', '--context', type=int, default=2,
                        help='Context lines around matches')
    parser.add_argument('-i', '--ignore-case', action='store_true',
                        help='Case-insensitive search')

    args = parser.parse_args()

    # Transform pattern based on type
    if args.type == 'hex':
        pattern = hex_pattern_to_regex(args.pattern)
    elif args.type == 'opcode':
        # Match opcode at start of instruction (after whitespace)
        pattern = r'^\s+' + args.pattern
    elif args.type == 'label':
        pattern = r'^[A-Za-z_][A-Za-z0-9_]*.*' + args.pattern
    else:
        pattern = args.pattern

    # Determine files to search
    if args.bank is not None:
        files = [os.path.join(BANKS_DIR, f"bank_{args.bank:02d}.asm")]
    else:
        files = [os.path.join(BANKS_DIR, f"bank_{i:02d}.asm") for i in range(16)]

    total_matches = 0

    for filepath in files:
        if not os.path.exists(filepath):
            print(f"Warning: {filepath} not found", file=sys.stderr)
            continue

        results = search_file(filepath, pattern, args.context, args.ignore_case)

        if results:
            print(f"\n{'='*60}")
            print(f"FILE: {os.path.basename(filepath)}")
            print(f"{'='*60}")

            for r in results:
                print(f"\nMatch at line {r['line_num']}:")
                print("-" * 40)
                for ctx_line in r['context']:
                    print(ctx_line)
                total_matches += 1

    print(f"\n{'='*60}")
    print(f"Total matches: {total_matches}")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
