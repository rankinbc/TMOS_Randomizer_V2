import { describe, it, expect } from 'vitest';
import {
  rowSig, colSig, mismatchCount, sectionPair, scoreCandidate,
  rankSections, internalSeam, scorePair, suggestPairs,
  type NeighborSigs, type WalkabilityTable,
} from './tileFilter';

const WALK = '1'.repeat(32);
const BLOCK = '0'.repeat(32);
const NONE: NeighborSigs = { up: null, down: null, left: null, right: null };

describe('rowSig / colSig', () => {
  it('rowSig slices an 8-char row', () => {
    // row 1 of a sig whose row1 is all 0, rest 1
    const sig = '11111111' + '00000000' + '11111111' + '11111111';
    expect(rowSig(sig, 1)).toBe('00000000');
  });
  it('colSig reads a column over the given rows', () => {
    // col 0 of each row = first char of each 8-char row
    const sig = '0' + '1111111' + '1' + '1111111' + '0' + '1111111' + '1' + '1111111';
    expect(colSig(sig, 0, [0, 1, 2, 3])).toBe('0101');
  });
});

describe('mismatchCount', () => {
  it('counts per-position 1-vs-0 mismatches', () => {
    expect(mismatchCount('1111', '1111')).toBe(0);
    expect(mismatchCount('1111', '0000')).toBe(4);
    expect(mismatchCount('1010', '1100')).toBe(2);
  });
});

describe('sectionPair', () => {
  it('returns null when either section is missing', () => {
    const t: WalkabilityTable = { '0': WALK };
    expect(sectionPair(t, 0, 1)).toBeNull();
    expect(sectionPair(t, 0, 0)).toEqual({ top: WALK, bottom: WALK });
  });
});

describe('scoreCandidate', () => {
  it('top half matches up-neighbor bottom edge (section row 1)', () => {
    const up = { top: WALK, bottom: BLOCK }; // up bottom edge = row1 of BLOCK = 00000000
    const n: NeighborSigs = { ...NONE, up };
    expect(scoreCandidate(WALK, 'top', n)).toBe(8); // candidate row0 = 11111111 vs 00000000
    expect(scoreCandidate(BLOCK, 'top', n)).toBe(0);
  });
  it('bottom half matches down-neighbor top edge (section row 0)', () => {
    const down = { top: BLOCK, bottom: WALK }; // down top edge = row0 of BLOCK = 00000000
    const n: NeighborSigs = { ...NONE, down };
    expect(scoreCandidate(WALK, 'bottom', n)).toBe(8); // candidate row1 = 11111111
    expect(scoreCandidate(BLOCK, 'bottom', n)).toBe(0);
  });
  it('ignores neighbors irrelevant to the active half', () => {
    const down = { top: BLOCK, bottom: WALK };
    expect(scoreCandidate(WALK, 'top', { ...NONE, down })).toBe(0); // down ignored for top
  });
  it('skips absent neighbors', () => {
    expect(scoreCandidate(WALK, 'top', NONE)).toBe(0);
  });
});

describe('rankSections', () => {
  it('sorts ascending by mismatch, missing sigs last', () => {
    const table: WalkabilityTable = { '0': WALK, '1': BLOCK }; // index 2 missing
    const up = { top: WALK, bottom: WALK }; // up bottom edge = 11111111
    const ranked = rankSections(table, 'top', { ...NONE, up }, 3);
    expect(ranked[0]).toEqual({ globalIndex: 0, mismatch: 0 });
    expect(ranked[1]).toEqual({ globalIndex: 1, mismatch: 8 });
    expect(ranked[2].globalIndex).toBe(2);
    expect(ranked[2].mismatch).toBe(Infinity);
  });
});

describe('internalSeam / scorePair', () => {
  it('internalSeam compares top row3 vs bottom row0', () => {
    expect(internalSeam(WALK, BLOCK)).toBe(8);
    expect(internalSeam(WALK, WALK)).toBe(0);
  });
  it('scorePair sums both halves and the internal seam', () => {
    // no neighbors → only internal seam contributes
    expect(scorePair(WALK, BLOCK, NONE)).toBe(8);
    expect(scorePair(WALK, WALK, NONE)).toBe(0);
  });
});

describe('suggestPairs', () => {
  it('returns up to limit pairs, best first', () => {
    const table: WalkabilityTable = { '0': WALK, '1': BLOCK };
    const pairs = suggestPairs(table, NONE, 2, 40, 12);
    expect(pairs.length).toBeGreaterThan(0);
    expect(pairs.length).toBeLessThanOrEqual(12);
    // best pair has the lowest mismatch and is sorted first
    for (let i = 1; i < pairs.length; i++) {
      expect(pairs[i].mismatch).toBeGreaterThanOrEqual(pairs[i - 1].mismatch);
    }
    // WALK+WALK has a clean internal seam (0); WALK+BLOCK has 8
    expect(pairs[0].mismatch).toBe(0);
  });
});
