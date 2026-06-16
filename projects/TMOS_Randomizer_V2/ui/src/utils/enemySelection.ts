import type { SelectableEnemy } from '../api/client';

/** A dropdown option for choosing a battle enemy. */
export interface EnemyOption {
  value: number;
  label: string;
}

/**
 * Map the canonical selectable-enemy list (already crash/danger-filtered
 * server-side) into dropdown options. This is the single frontend place that
 * derives enemy `<select>` options, so every surface filters identically.
 */
export function toEnemyOptions(enemies: SelectableEnemy[]): EnemyOption[] {
  return enemies.map((e) => ({ value: e.enemy_id, label: `${e.enemy_id_hex} · ${e.name}` }));
}
