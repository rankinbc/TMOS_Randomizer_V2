import type { BattleEnemy } from '../../api/client';

interface EnemyCardProps {
  enemy: BattleEnemy;
  size?: 'sm' | 'md' | 'lg';
  selected?: boolean;
  onClick?: () => void;
}

const SIZE: Record<'sm' | 'md' | 'lg', { wrap: string; img: string; label: string }> = {
  sm: { wrap: 'w-20',  img: 'w-16 h-16', label: 'text-[10px]' },
  md: { wrap: 'w-28',  img: 'w-24 h-24', label: 'text-xs' },
  lg: { wrap: 'w-36',  img: 'w-32 h-32', label: 'text-sm' },
};

export function EnemyCard({ enemy, size = 'md', selected, onClick }: EnemyCardProps) {
  const s = SIZE[size];
  const imgUrl = enemy.image
    ? `http://localhost:8000/api/assets/enemies/${enemy.image}`
    : null;

  return (
    <button
      type="button"
      onClick={onClick}
      className={`${s.wrap} flex flex-col items-center text-center rounded p-1 border transition ${
        selected
          ? 'border-amber-500 bg-amber-500/10'
          : 'border-slate-700 bg-slate-800 hover:border-slate-500'
      } ${onClick ? 'cursor-pointer' : 'cursor-default'}`}
      title={`${enemy.name} (${enemy.enemy_id_hex}) — HP ${enemy.hp ?? '?'}\n${enemy.notes}`}
    >
      <div className={`${s.img} flex items-center justify-center bg-slate-900 rounded overflow-hidden`}>
        {imgUrl ? (
          <img
            src={imgUrl}
            alt={enemy.name}
            className="max-w-full max-h-full object-contain pixelated"
            style={{ imageRendering: 'pixelated' }}
            onError={(e) => {
              (e.target as HTMLImageElement).style.display = 'none';
            }}
          />
        ) : (
          <span className="text-slate-600 text-xs">?</span>
        )}
      </div>
      <div className={`${s.label} font-medium text-slate-200 mt-1 truncate w-full`}>
        {enemy.name}
      </div>
      <div className="flex items-center gap-1 text-[9px] text-slate-500 font-mono">
        <span>{enemy.enemy_id_hex}</span>
        {enemy.hp !== null && <span>· HP {enemy.hp}</span>}
      </div>
    </button>
  );
}
