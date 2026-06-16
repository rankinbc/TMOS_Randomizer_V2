import type { SwatchOption } from './GuidedSelectField';

// Mirrors ScreenGrid's PARENT_WORLD_COLORS abstract palette. Labels describe the
// section type each parent-world group represents.
export const PARENT_WORLD_OPTIONS: SwatchOption[] = [
  { value: 0x40, label: '0x40 Overworld', swatch: '#2563eb' },
  { value: 0xe0, label: '0xE0 Overworld (alt)', swatch: '#2563eb' },
  { value: 0x80, label: '0x80 Overworld (alt)', swatch: '#2563eb' },
  { value: 0x30, label: '0x30 Overworld (alt)', swatch: '#2563eb' },
  { value: 0x20, label: '0x20 Town', swatch: '#16a34a' },
  { value: 0x10, label: '0x10 Town (alt)', swatch: '#16a34a' },
  { value: 0xd0, label: '0xD0 Dungeon', swatch: '#dc2626' },
  { value: 0xf0, label: '0xF0 Dungeon (alt)', swatch: '#dc2626' },
  { value: 0xb0, label: '0xB0 Dungeon (alt)', swatch: '#dc2626' },
  { value: 0x53, label: '0x53 Maze', swatch: '#9333ea' },
  { value: 0x55, label: '0x55 Maze (alt)', swatch: '#9333ea' },
  { value: 0x58, label: '0x58 Maze (alt)', swatch: '#9333ea' },
  { value: 0x5d, label: '0x5D Maze (alt)', swatch: '#9333ea' },
];

// Background-palette swatches approximate the renderer's getGroundColor cases.
export const WS_COLOR_SWATCHES: SwatchOption[] = [
  { value: 0x21, label: '0x21 Past (green)', swatch: '#3a7d3a' },
  { value: 0x30, label: '0x30 Water (blue)', swatch: '#2b5fd0' },
  { value: 0x25, label: '0x25 Desert (sand)', swatch: '#c9a86a' },
  { value: 0x1a, label: '0x1A Dark palace', swatch: '#3a3550' },
  { value: 0x3c, label: '0x3C Red', swatch: '#b03030' },
  { value: 0x23, label: '0x23 Winter (gray)', swatch: '#9aa3ad' },
  { value: 0x27, label: '0x27 Black', swatch: '#1a1a1a' },
  { value: 0x1c, label: '0x1C Lava', swatch: '#d2601a' },
];

export const SPRITE_COLOR_SWATCHES: SwatchOption[] = [
  { value: 0x0f, label: '0x0F Default', swatch: '#cccccc' },
  { value: 0x30, label: '0x30 Town', swatch: '#e0c060' },
];
