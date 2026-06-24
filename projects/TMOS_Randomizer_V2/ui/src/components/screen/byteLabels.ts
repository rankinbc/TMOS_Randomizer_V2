import type { ScreenData } from '../../api/client';
import type { FieldMetadata, SafetyTier } from '../../types/metadata';
import { CONTENT_TYPES, CHAPTER_NPCS, EVENT_TYPES } from './screenEnums';

// The 16 worldscreen metadata field keys, in ROM byte order (byte 0 → 15).
export const BYTE_FIELD_KEYS = [
  'parent_world', 'ambient_sound', 'content', 'objectset',
  'screen_index_right', 'screen_index_left', 'screen_index_down', 'screen_index_up',
  'datapointer', 'exit_position', 'top_tiles', 'bottom_tiles',
  'worldscreen_color', 'sprites_color', 'unknown', 'event',
] as const;

// Metadata field key → ScreenData property. All identical except the nav bytes.
export const FIELD_TO_SCREEN_KEY: Record<string, keyof ScreenData> = {
  parent_world: 'parent_world',
  ambient_sound: 'ambient_sound',
  content: 'content',
  objectset: 'objectset',
  screen_index_right: 'nav_right',
  screen_index_left: 'nav_left',
  screen_index_down: 'nav_down',
  screen_index_up: 'nav_up',
  datapointer: 'datapointer',
  exit_position: 'exit_position',
  top_tiles: 'top_tiles',
  bottom_tiles: 'bottom_tiles',
  worldscreen_color: 'worldscreen_color',
  sprites_color: 'sprites_color',
  unknown: 'unknown',
  event: 'event',
};

// Parent world / section types (value can vary by chapter; high-nibble fallback).
export const PARENT_WORLD_TYPES: Record<number, { name: string; color: string }> = {
  0x00: { name: 'Overworld', color: '#22c55e' },
  0x10: { name: 'Town A', color: '#3b82f6' },
  0x20: { name: 'Town B', color: '#6366f1' },
  0x40: { name: 'Overworld', color: '#22c55e' },
  0x50: { name: 'Maze', color: '#f97316' },
  0x60: { name: 'Dungeon', color: '#a855f7' },
  0x70: { name: 'Special', color: '#eab308' },
  0x80: { name: 'Special', color: '#eab308' },
  0xA0: { name: 'Boss Area', color: '#ef4444' },
  0xAC: { name: 'Boss Area', color: '#ef4444' },
  0xC0: { name: 'Boss Area', color: '#ef4444' },
  0xE0: { name: 'Overworld', color: '#22c55e' },
};

const NAV_KEYS = new Set([
  'screen_index_right', 'screen_index_left', 'screen_index_down', 'screen_index_up',
]);

function hex(value: number): string {
  return value.toString(16).toUpperCase().padStart(2, '0');
}

export function screenValueFor(screen: ScreenData, fieldKey: string): number {
  const key = FIELD_TO_SCREEN_KEY[fieldKey];
  return (screen[key] as number) ?? 0;
}

export function parentWorldName(value: number): string | null {
  if (PARENT_WORLD_TYPES[value]) return PARENT_WORLD_TYPES[value].name;
  return PARENT_WORLD_TYPES[value & 0xF0]?.name ?? null;
}

function contentLabel(value: number, chapterNum: number): string | null {
  if (value >= 0x80 && value <= 0x9F) {
    return CHAPTER_NPCS[chapterNum]?.[value]?.name ?? `NPC 0x${hex(value)}`;
  }
  return CONTENT_TYPES[value]?.name ?? null;
}

function enumLabel(field: FieldMetadata | undefined, value: number): string | null {
  if (field?.control === 'enum' && field.enum) {
    return field.enum.find((o) => o.value === value)?.label ?? null;
  }
  return null;
}

export interface ByteLabel {
  text: string;
  tier: SafetyTier;
}

export function resolveByteLabel(
  fieldKey: string,
  value: number,
  chapterNum: number,
  field?: FieldMetadata,
): ByteLabel {
  const tier: SafetyTier = field?.tier ?? 'safe';
  let text: string;

  if (NAV_KEYS.has(fieldKey)) {
    text = value === 0xFF ? 'Blocked'
      : value === 0xFE ? 'Building'
      : `Screen 0x${hex(value)}`;
  } else if (fieldKey === 'content') {
    text = contentLabel(value, chapterNum) ?? enumLabel(field, value) ?? `0x${hex(value)}`;
  } else if (fieldKey === 'event') {
    text = EVENT_TYPES[value]?.name ?? enumLabel(field, value) ?? `0x${hex(value)}`;
  } else if (fieldKey === 'parent_world') {
    text = parentWorldName(value) ?? enumLabel(field, value) ?? `0x${hex(value)}`;
  } else {
    text = enumLabel(field, value) ?? `0x${hex(value)}`;
  }

  return { text, tier };
}
