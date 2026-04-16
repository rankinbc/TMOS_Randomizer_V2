import type { PlayerStatsPreview, PlayerStatsTables } from '../../api/client';
import { HelpChip } from './HelpChip';

interface IndirectionChainProps {
  preview: PlayerStatsPreview;
  current: PlayerStatsTables;
  onJumpToDamageIndex?: (index: number) => void;
}

/**
 * The chain visualization for the selected level:
 *
 *   Level L  ──▶  index N  ──▶  damage V
 *
 * Renders one row for sword, one for rod, with byte addresses and "shares
 * with" cascade lines. The whole point is to make the indirection inarguably
 * visible — ROM hackers see the ROM bytes, casual users see the math.
 */
export function IndirectionChain({ preview, current, onJumpToDamageIndex }: IndirectionChainProps) {
  const swordSharers = current.sword_indices
    .map((idx, i) => (idx === preview.sword_index && i + 1 !== preview.level ? i + 1 : null))
    .filter((x): x is number => x !== null);
  const rodSharers = current.rod_indices
    .map((idx, i) => (idx === preview.rod_index && i + 1 !== preview.level ? i + 1 : null))
    .filter((x): x is number => x !== null);

  // Note: sword_indices share by sword-equality; we don't include rod sharers in sword cascade.
  const swordRodSharers = current.rod_indices
    .map((idx, i) => (idx === preview.sword_index ? i + 1 : null))
    .filter((x): x is number => x !== null);
  const rodSwordSharers = current.sword_indices
    .map((idx, i) => (idx === preview.rod_index ? i + 1 : null))
    .filter((x): x is number => x !== null);

  return (
    <div className="space-y-2 text-xs">
      <div className="text-slate-400 flex items-center gap-1 font-medium uppercase tracking-wide">
        Damage chain at L{preview.level}
        <HelpChip
          content={
            <div className="text-xs space-y-1">
              <p>
                Damage isn't stored directly. The game does a two-stage lookup:
              </p>
              <p className="font-mono">
                damage(L) = damage_values[ index[L] ]
              </p>
              <p>
                Editing a level's <strong>index</strong> changes which damage tier it
                gets. Editing a value in the <strong>damage table</strong> changes
                every level that points at that index.
              </p>
            </div>
          }
        />
      </div>

      {/* SWORD ROW */}
      <ChainRow
        label="⚔ Sword"
        color="text-orange-300"
        level={preview.level}
        index={preview.sword_index}
        damage={preview.sword_damage}
        damageVanilla={preview.sword_damage_vanilla}
        levelByteOffset={`$${(0x1F667 + preview.level - 1).toString(16).toUpperCase()}`}
        levelByteDetail="high nibble"
        damageByteOffset={`$${(0x1F680 + preview.sword_index).toString(16).toUpperCase()}`}
        sharedSwordLevels={swordSharers}
        sharedRodLevels={swordRodSharers}
        onJumpToDamageIndex={onJumpToDamageIndex ? () => onJumpToDamageIndex(preview.sword_index) : undefined}
      />

      {/* ROD ROW */}
      <ChainRow
        label="🪄 Rod"
        color="text-fuchsia-300"
        level={preview.level}
        index={preview.rod_index}
        damage={preview.rod_damage}
        damageVanilla={preview.rod_damage_vanilla}
        levelByteOffset={`$${(0x1F667 + preview.level - 1).toString(16).toUpperCase()}`}
        levelByteDetail="low nibble"
        damageByteOffset={`$${(0x1F680 + preview.rod_index).toString(16).toUpperCase()}`}
        sharedSwordLevels={rodSwordSharers}
        sharedRodLevels={rodSharers}
        onJumpToDamageIndex={onJumpToDamageIndex ? () => onJumpToDamageIndex(preview.rod_index) : undefined}
      />
    </div>
  );
}

interface ChainRowProps {
  label: string;
  color: string;
  level: number;
  index: number;
  damage: number;
  damageVanilla: number;
  levelByteOffset: string;
  levelByteDetail: string;
  damageByteOffset: string;
  sharedSwordLevels: number[];
  sharedRodLevels: number[];
  onJumpToDamageIndex?: () => void;
}

function ChainRow({
  label,
  color,
  level,
  index,
  damage,
  damageVanilla,
  levelByteOffset,
  levelByteDetail,
  damageByteOffset,
  sharedSwordLevels,
  sharedRodLevels,
  onJumpToDamageIndex,
}: ChainRowProps) {
  const dmgDiff = damage - damageVanilla;
  const dmgArrow = dmgDiff > 0 ? '↑' : dmgDiff < 0 ? '↓' : '';
  const totalShares = sharedSwordLevels.length + sharedRodLevels.length;

  return (
    <div className="flex items-stretch gap-1 bg-slate-900/40 rounded p-2">
      <ChainNode
        title={`Level ${level}`}
        subtitle={levelByteOffset}
        detail={levelByteDetail}
        color={color}
      />
      <Arrow />
      <ChainNode
        title={`index ${index}`}
        subtitle="0–15"
        detail="(curve point)"
        color={color}
      />
      <Arrow />
      <button
        type="button"
        onClick={onJumpToDamageIndex}
        className="text-left"
        disabled={!onJumpToDamageIndex}
        title={onJumpToDamageIndex ? 'Click to jump to damage table' : undefined}
      >
        <ChainNode
          title={`${damage} dmg ${dmgArrow}`}
          subtitle={damageByteOffset}
          detail={damageVanilla !== damage ? `vanilla ${damageVanilla}` : ''}
          color={color}
          interactive={!!onJumpToDamageIndex}
        />
      </button>

      <div className="flex-1 ml-2 text-slate-500 self-center">
        <div className={color + ' font-medium'}>{label}</div>
        {totalShares > 0 && (
          <div className="text-[10px] mt-0.5">
            {sharedSwordLevels.length > 0 && (
              <span>shares index with sword L{sharedSwordLevels.join(',')} </span>
            )}
            {sharedRodLevels.length > 0 && (
              <span>+ rod L{sharedRodLevels.join(',')}</span>
            )}
          </div>
        )}
        {totalShares === 0 && (
          <div className="text-[10px] text-slate-600 mt-0.5">unique to this level</div>
        )}
      </div>
    </div>
  );
}

function ChainNode({
  title,
  subtitle,
  detail,
  color,
  interactive,
}: {
  title: string;
  subtitle: string;
  detail?: string;
  color: string;
  interactive?: boolean;
}) {
  return (
    <div
      className={`px-2 py-1 rounded border border-slate-700 bg-slate-800 min-w-[80px] text-center ${
        interactive ? 'hover:border-slate-500 cursor-pointer' : ''
      }`}
    >
      <div className={`${color} font-mono text-sm font-medium`}>{title}</div>
      <div className="text-[10px] text-slate-500 font-mono">{subtitle}</div>
      {detail && <div className="text-[10px] text-slate-600">{detail}</div>}
    </div>
  );
}

function Arrow() {
  return (
    <div className="self-center text-slate-600 text-lg leading-none">→</div>
  );
}
