import { describe, it, expect } from 'vitest';
import { tierStyle, lookupField, isDanger } from './safety';
import type { FieldMetadataResponse } from '../types/metadata';

const META: FieldMetadataResponse = {
  version: '1',
  generated_from: 'test',
  entities: {
    worldscreen: {
      label: 'World Screen',
      fields: {
        content: { label: 'Content', byte: 2, tier: 'caution', description: 'x' },
        objectset: { label: 'ObjectSet', byte: 3, tier: 'danger', description: 'y' },
      },
    },
  },
};

describe('tierStyle', () => {
  it('maps each tier to distinct classes', () => {
    expect(tierStyle('safe').dot).toContain('green');
    expect(tierStyle('caution').dot).toContain('amber');
    expect(tierStyle('danger').dot).toContain('red');
  });
});

describe('lookupField', () => {
  it('finds a field by entity + field name', () => {
    expect(lookupField(META, 'worldscreen', 'content')?.tier).toBe('caution');
  });
  it('returns undefined for unknown fields', () => {
    expect(lookupField(META, 'worldscreen', 'nope')).toBeUndefined();
  });
});

describe('isDanger', () => {
  it('is true only for danger-tier fields', () => {
    expect(isDanger(META, 'worldscreen', 'objectset')).toBe(true);
    expect(isDanger(META, 'worldscreen', 'content')).toBe(false);
  });
});
