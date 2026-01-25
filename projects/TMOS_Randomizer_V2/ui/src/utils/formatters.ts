// Formatting utilities

export function formatHex(value: number, pad: number = 2): string {
  return '0x' + value.toString(16).toUpperCase().padStart(pad, '0');
}

// Screen ID formatting - provides consistent representation across the UI
export interface ScreenIdFormat {
  short: string;           // "#42 / 0x2A"
  full: string;            // "Screen #42 / 0x2A [Global: 106]"
  withChapter: string;     // "Ch1 #42 / 0x2A"
  hex: string;             // "0x2A"
  decimal: string;         // "#42"
  global: string;          // "G:106"
  compact: string;         // "0x2A" (just hex for small overlays)
}

export function formatScreenId(
  screenIndex: number,
  globalIndex: number,
  chapterNum?: number
): ScreenIdFormat {
  const hex = formatHex(screenIndex);
  const decimal = `#${screenIndex}`;
  const global = `G:${globalIndex}`;
  const short = `${decimal} / ${hex}`;
  const compact = hex;  // Just hex for compact displays
  const full = `Screen ${decimal} / ${hex} [Global: ${globalIndex}]`;
  const withChapter = chapterNum !== undefined
    ? `Ch${chapterNum} ${decimal} / ${hex}`
    : short;

  return { short, full, withChapter, hex, decimal, global, compact };
}

// Format navigation value with appropriate context
export function formatNavValue(
  value: number,
  globalIndex?: number,
  chapterNum?: number
): { display: string; isValid: boolean; isBlocked: boolean; isBuilding: boolean } {
  const NAV_BLOCKED = 0xFF;
  const NAV_BUILDING = 0xFE;

  if (value === NAV_BLOCKED) {
    return { display: 'Blocked', isValid: false, isBlocked: true, isBuilding: false };
  }

  if (value === NAV_BUILDING) {
    return { display: 'Building', isValid: false, isBlocked: false, isBuilding: true };
  }

  // Valid screen reference
  const format = formatScreenId(value, globalIndex ?? value, chapterNum);
  return { display: format.short, isValid: true, isBlocked: false, isBuilding: false };
}

// Simplified section format from API
interface SimplifiedSection {
  section_id: string;
  type: string;
  screen_count: number;
  shape: string;
}

export function formatSectionLabel(section: SimplifiedSection): string {
  const typeLabels: Record<string, string> = {
    overworld: 'Overworld',
    town: 'Town',
    dungeon: 'Dungeon',
    maze: 'Maze',
    boss: 'Boss',
    special: 'Special',
  };

  // Extract index from section_id if present (e.g., "overworld_1" -> 1)
  const parts = section.section_id.split('_');
  const lastPart = parts[parts.length - 1];
  const index = /^\d+$/.test(lastPart) ? parseInt(lastPart, 10) : 0;

  const base = typeLabels[section.type] || section.type;
  if (index > 0) {
    return `${base} ${String.fromCharCode(64 + index)}`;
  }
  return base;
}

export function getSectionCounts(sections: SimplifiedSection[]): Record<string, number> {
  const counts: Record<string, number> = {};
  for (const section of sections) {
    counts[section.type] = (counts[section.type] || 0) + section.screen_count;
  }
  return counts;
}

export function formatSeed(seed: number): string {
  return seed.toString().padStart(10, '0');
}

export function pluralize(count: number, singular: string, plural?: string): string {
  return count === 1 ? singular : (plural || `${singular}s`);
}
