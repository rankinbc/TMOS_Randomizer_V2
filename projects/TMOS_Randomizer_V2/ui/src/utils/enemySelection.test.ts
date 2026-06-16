import { describe, it, expect } from 'vitest';
import { toEnemyOptions } from './enemySelection';

describe('toEnemyOptions', () => {
  it('maps selectable enemies to {value,label} options', () => {
    const opts = toEnemyOptions([{ enemy_id: 0x0d, enemy_id_hex: '0x0D', name: 'Pandarm' }]);
    expect(opts[0].value).toBe(0x0d);
    expect(opts[0].label).toContain('Pandarm');
    expect(opts[0].label).toContain('0x0D');
  });

  it('returns empty for empty input', () => {
    expect(toEnemyOptions([])).toEqual([]);
  });

  it('preserves order and maps every entry', () => {
    const opts = toEnemyOptions([
      { enemy_id: 0x0d, enemy_id_hex: '0x0D', name: 'Pandarm' },
      { enemy_id: 0x10, enemy_id_hex: '0x10', name: 'Miniyad' },
    ]);
    expect(opts.map((o) => o.value)).toEqual([0x0d, 0x10]);
  });
});
