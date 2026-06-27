import type { RefObject } from 'react';
import type { BattleEnemy } from '../../api/client';
import { GridPicker } from '../shared/GridPicker';
import type { GridPickerItem } from '../shared/GridPicker';

interface EnemyPickerProps {
  enemies: BattleEnemy[];
  currentEnemyId: number;
  onPick: (enemyId: number) => void;
  /** Show empty-slot button (0xFF) at the top */
  allowEmpty?: boolean;
  onClose: () => void;
  /** The element to anchor the popup against */
  anchorRef: RefObject<HTMLElement | null>;
}

function enemyToItem(e: BattleEnemy): GridPickerItem {
  return {
    id: e.enemy_id,
    label: e.name,
    hex: e.enemy_id_hex,
    sub: e.hp !== null ? `HP ${e.hp}` : undefined,
    imageUrl: e.image ? `/assets/enemies/${e.image}` : undefined,
  };
}

/**
 * Floating image-grid picker for enemy selection.
 * Thin wrapper over GridPicker: maps BattleEnemy[] → GridPickerItem[]
 * (imageUrl from the enemy sprite path) so LineupEditor keeps working unchanged.
 */
export function EnemyPicker({
  enemies,
  currentEnemyId,
  onPick,
  allowEmpty = true,
  onClose,
  anchorRef,
}: EnemyPickerProps) {
  return (
    <GridPicker
      items={enemies.map(enemyToItem)}
      currentId={currentEnemyId}
      onPick={onPick}
      onClose={onClose}
      anchorRef={anchorRef}
      allowEmpty={allowEmpty}
    />
  );
}
