import { describe, it, expect } from 'vitest';
import { offTheme, coherentPairCandidates, BIOME_OPTIONS } from './themeFilter';
import { suggestPairs, type NeighborSigs, type WalkabilityTable } from './tileFilter';

const NONE: NeighborSigs = { up: null, down: null, left: null, right: null };

describe('offTheme', () => {
  it('is 0 for target=all regardless of theme', () => {
    expect(offTheme('dungeon', 'all')).toBe(0);
    expect(offTheme(undefined, 'all')).toBe(0);
  });
  it('is 0 on-theme, 1 off-theme', () => {
    expect(offTheme('dungeon', 'dungeon')).toBe(0);
    expect(offTheme('overworld', 'dungeon')).toBe(1);
    expect(offTheme(undefined, 'dungeon')).toBe(1);
  });
});

describe('coherentPairCandidates', () => {
  it('returns all indices for target=all', () => {
    const themes = { '0': 'overworld', '1': 'dungeon', '2': 'town' };
    expect(coherentPairCandidates(themes, 'all', 3)).toEqual([0, 1, 2]);
  });
  it('filters to the target biome', () => {
    const themes = { '0': 'overworld', '1': 'dungeon', '2': 'dungeon' };
    expect(coherentPairCandidates(themes, 'dungeon', 3)).toEqual([1, 2]);
  });
});

describe('BIOME_OPTIONS', () => {
  it('starts with all then the 5 biomes', () => {
    expect(BIOME_OPTIONS).toEqual(['all', 'overworld', 'town', 'dungeon', 'maze', 'special']);
  });
});

describe('suggestPairs candidates filter', () => {
  it('restricts both halves to the candidate set', () => {
    const table: WalkabilityTable = { '0': '1'.repeat(32), '1': '0'.repeat(32) };
    const pairs = suggestPairs(table, NONE, 2, 40, 12, [0]);
    expect(pairs.length).toBeGreaterThan(0);
    for (const p of pairs) {
      expect(p.top).toBe(0);
      expect(p.bottom).toBe(0);
    }
  });
});
