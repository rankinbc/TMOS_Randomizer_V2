// Pure theme/biome filtering helpers for the tile-section picker.
// Composes with the Spec #2 collision filter: the picker sorts by the
// [offTheme, collisionMismatch, globalIndex] composite key.

export type Biome = 'overworld' | 'town' | 'dungeon' | 'maze' | 'special';
export type TargetTheme = Biome | 'all';
export type ThemeTable = Record<string, string>;

// Dropdown options: "all" plus the 5 biomes, in display order.
export const BIOME_OPTIONS: TargetTheme[] = ['all', 'overworld', 'town', 'dungeon', 'maze', 'special'];

// Primary sort key component: 0 = on-theme (or target 'all'), 1 = off-theme.
export function offTheme(theme: string | undefined, target: TargetTheme): 0 | 1 {
  if (target === 'all') return 0;
  return theme === target ? 0 : 1;
}

// Global section indices whose theme matches the target (all when target='all').
export function coherentPairCandidates(themes: ThemeTable, target: TargetTheme, count: number): number[] {
  const out: number[] = [];
  for (let g = 0; g < count; g++) {
    if (target === 'all' || themes[String(g)] === target) out.push(g);
  }
  return out;
}
