// Formatting utilities

export function formatHex(value: number, pad: number = 2): string {
  return '0x' + value.toString(16).toUpperCase().padStart(pad, '0');
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
