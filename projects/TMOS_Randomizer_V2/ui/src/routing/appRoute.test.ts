import { describe, it, expect } from 'vitest';
import { parseHash, hashForRoute, hexToId, idToHex } from './appRoute';

describe('hexToId / idToHex', () => {
  it('round-trips a byte id', () => {
    expect(idToHex(0x1c)).toBe('1c');
    expect(hexToId('1c')).toBe(0x1c);
  });
  it('zero-pads to two digits', () => {
    expect(idToHex(0x0d)).toBe('0d');
    expect(hexToId('0d')).toBe(0x0d);
  });
  it('tolerates a 0x prefix and unpadded input', () => {
    expect(hexToId('0x1c')).toBe(28);
    expect(hexToId('d')).toBe(13);
  });
  it('rejects non-hex and out-of-range', () => {
    expect(hexToId('zz')).toBeNull();
    expect(hexToId('')).toBeNull();
    expect(hexToId('-1')).toBeNull();
    expect(hexToId('100')).toBeNull(); // 256 > 0xFF
  });
});

describe('parseHash', () => {
  it('parses a bare tab', () => {
    expect(parseHash('#/hero')).toEqual({ tab: 'hero' });
  });
  it('falls back to world for empty / unknown', () => {
    expect(parseHash('')).toEqual({ tab: 'world' });
    expect(parseHash('#/')).toEqual({ tab: 'world' });
    expect(parseHash('#/garbage')).toEqual({ tab: 'world' });
  });
  it('defaults a bare enemies route to the roster sub-tab', () => {
    expect(parseHash('#/enemies')).toEqual({ tab: 'enemies', sub: 'roster' });
  });
  it('falls back to roster for an unknown sub-tab', () => {
    expect(parseHash('#/enemies/nope')).toEqual({ tab: 'enemies', sub: 'roster' });
  });
  it('parses a roster enemy id from hex', () => {
    expect(parseHash('#/enemies/roster/1c')).toEqual({ tab: 'enemies', sub: 'roster', id: 0x1c });
  });
  it('omits the id when unparseable', () => {
    expect(parseHash('#/enemies/roster/zz')).toEqual({ tab: 'enemies', sub: 'roster' });
  });
  it('parses an encounters chapter (decimal)', () => {
    expect(parseHash('#/enemies/encounters/3')).toEqual({ tab: 'enemies', sub: 'encounters', chapter: 3 });
  });
  it('clamps a missing/out-of-range chapter to 1', () => {
    expect(parseHash('#/enemies/encounters')).toEqual({ tab: 'enemies', sub: 'encounters', chapter: 1 });
    expect(parseHash('#/enemies/encounters/9')).toEqual({ tab: 'enemies', sub: 'encounters', chapter: 1 });
  });
  it('ignores a third segment for bosses/overworld', () => {
    expect(parseHash('#/enemies/bosses')).toEqual({ tab: 'enemies', sub: 'bosses' });
    expect(parseHash('#/enemies/overworld')).toEqual({ tab: 'enemies', sub: 'overworld' });
  });
});

describe('hashForRoute', () => {
  it('formats a bare tab', () => {
    expect(hashForRoute({ tab: 'world' })).toBe('#/world');
  });
  it('normalizes bare enemies to roster', () => {
    expect(hashForRoute({ tab: 'enemies' })).toBe('#/enemies/roster');
  });
  it('formats a roster selection in hex', () => {
    expect(hashForRoute({ tab: 'enemies', sub: 'roster', id: 0x1c })).toBe('#/enemies/roster/1c');
  });
  it('omits the id segment when there is no selection', () => {
    expect(hashForRoute({ tab: 'enemies', sub: 'roster' })).toBe('#/enemies/roster');
  });
  it('always emits the encounters chapter (defaulting to 1)', () => {
    expect(hashForRoute({ tab: 'enemies', sub: 'encounters', chapter: 3 })).toBe('#/enemies/encounters/3');
    expect(hashForRoute({ tab: 'enemies', sub: 'encounters' })).toBe('#/enemies/encounters/1');
  });
});

describe('round-trip', () => {
  for (const h of ['#/world', '#/hero', '#/enemies/roster', '#/enemies/roster/1c', '#/enemies/encounters/3', '#/enemies/bosses']) {
    it(`${h} survives parse → format`, () => {
      expect(hashForRoute(parseHash(h))).toBe(h);
    });
  }
});
