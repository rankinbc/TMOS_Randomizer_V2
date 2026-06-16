import type { SelectableEnemy } from '../api/client';

/**
 * Enemy IDs that hard-crash the game or are otherwise unsafe to use, mirroring
 * core/enums.py CONSERVATIVE_DANGER_ENEMY_IDS. The backend's
 * /api/rom/enemies/selectable endpoint is the authoritative filter; this set is
 * the frontend's defensive fallback for the brief window before that list loads
 * (and the single FE source so components don't each redefine it).
 *   0x0B, 0x0C → known crash IDs
 *   0x0F, 0x17, 0x25 → conservative danger (unstable / unverified)
 */
export const DANGER_ENEMY_IDS: ReadonlySet<number> = new Set([0x0b, 0x0c, 0x0f, 0x17, 0x25]);

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
