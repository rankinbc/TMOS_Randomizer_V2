import { describe, it, expect } from 'vitest';
import {
  resolveByteLabel,
  screenValueFor,
  parentWorldName,
  BYTE_FIELD_KEYS,
} from './byteLabels';
import type { ScreenData } from '../../api/client';
import type { FieldMetadata } from '../../types/metadata';

const baseScreen = {
  index: 1, global_index: 1, datapointer: 0, chr_index: 0,
  top_tiles: 0, bottom_tiles: 0, objectset: 0, parent_world: 0,
  ambient_sound: 0, event: 0, content: 0,
  nav_right: 0, nav_left: 0, nav_down: 0, nav_up: 0,
  worldscreen_color: 0, sprites_color: 0, exit_position: 0, unknown: 0,
} as ScreenData;

const numberField = (tier: FieldMetadata['tier']): FieldMetadata => ({
  label: 'x', byte: 0, tier, control: 'number', description: '',
});

describe('BYTE_FIELD_KEYS', () => {
  it('lists all 16 bytes in ROM order', () => {
    expect(BYTE_FIELD_KEYS).toHaveLength(16);
    expect(BYTE_FIELD_KEYS[0]).toBe('parent_world');
    expect(BYTE_FIELD_KEYS[4]).toBe('screen_index_right');
    expect(BYTE_FIELD_KEYS[15]).toBe('event');
  });
});

describe('screenValueFor', () => {
  it('maps nav metadata keys to nav_* ScreenData props', () => {
    const s = { ...baseScreen, nav_right: 0x2A };
    expect(screenValueFor(s, 'screen_index_right')).toBe(0x2A);
  });
  it('maps 1:1 keys directly', () => {
    const s = { ...baseScreen, objectset: 0x10 };
    expect(screenValueFor(s, 'objectset')).toBe(0x10);
  });
});

describe('resolveByteLabel', () => {
  it('decodes chapter-specific NPC content', () => {
    expect(resolveByteLabel('content', 0x81, 1).text).toBe('Faruk');
    expect(resolveByteLabel('content', 0x80, 2).text).toBe('Gun Meca');
  });
  it('decodes shop content via CONTENT_TYPES', () => {
    expect(resolveByteLabel('content', 0x60, 1).text).toBe('Shop');
  });
  it('decodes event names', () => {
    expect(resolveByteLabel('event', 0x40, 1).text).toBe('Stairway');
  });
  it('decodes nav bytes', () => {
    expect(resolveByteLabel('screen_index_right', 0xFF, 1).text).toBe('Blocked');
    expect(resolveByteLabel('screen_index_right', 0xFE, 1).text).toBe('Building');
    expect(resolveByteLabel('screen_index_right', 0x2A, 1).text).toBe('Screen 0x2A');
  });
  it('decodes parent_world exact then by high nibble', () => {
    expect(resolveByteLabel('parent_world', 0x10, 1).text).toBe('Town A');
    expect(resolveByteLabel('parent_world', 0x4A, 1).text).toBe('Overworld');
  });
  it('falls back to hex for plain number fields', () => {
    expect(resolveByteLabel('ambient_sound', 0x05, 1).text).toBe('0x05');
  });
  it('takes tier from the metadata field, defaulting to safe', () => {
    expect(resolveByteLabel('objectset', 0, 1, numberField('danger')).tier).toBe('danger');
    expect(resolveByteLabel('objectset', 0, 1).tier).toBe('safe');
  });
});

describe('parentWorldName', () => {
  it('resolves by high nibble when no exact match', () => {
    expect(parentWorldName(0x62)).toBe('Dungeon');
  });
});
