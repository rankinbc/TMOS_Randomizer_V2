import type { PlayerStatsPreview } from '../../api/client';
import { HelpChip } from './HelpChip';

interface ConsequencePreviewProps {
  preview: PlayerStatsPreview | null;
  level: number;
  levelMin: number;
  levelMax: number;
  onLevelChange: (level: number) => void;
}

export function ConsequencePreview({
  preview,
  level,
  levelMin,
  levelMax,
  onLevelChange,
}: ConsequencePreviewProps) {
  return (
    <div className="space-y-3">
      {/* Level slider */}
      <div className="flex items-center gap-3">
        <span className="text-sm text-slate-400 uppercase tracking-wide">Level</span>
        <input
          type="range"
          min={levelMin}
          max={levelMax}
          value={level}
          onChange={(e) => onLevelChange(parseInt(e.target.value, 10))}
          className="flex-1 accent-blue-500"
        />
        <input
          type="number"
          min={levelMin}
          max={levelMax}
          value={level}
          onChange={(e) => {
            const v = Math.max(levelMin, Math.min(levelMax, parseInt(e.target.value, 10) || levelMin));
            onLevelChange(v);
          }}
          className="bg-slate-900 border border-slate-700 rounded px-2 py-0.5 w-14 text-right text-slate-200"
        />
      </div>

      {/* Stat snapshot */}
      {preview && (
        <div className="flex items-center gap-4 flex-wrap text-sm">
          <StatChip
            label="HP"
            value={preview.hp}
            vanilla={preview.hp_vanilla}
            color="text-emerald-300"
          />
          <StatChip
            label="⚔ Sword"
            value={preview.sword_damage}
            vanilla={preview.sword_damage_vanilla}
            color="text-orange-300"
          />
          <StatChip
            label="🪄 Rod"
            value={preview.rod_damage}
            vanilla={preview.rod_damage_vanilla}
            color="text-fuchsia-300"
          />
        </div>
      )}

      {/* Hit-count cards */}
      {preview && (
        <div>
          <div className="flex items-center gap-2 mb-2 text-xs uppercase tracking-wide text-slate-500">
            Enemy hits to kill at L{preview.level}
            <HelpChip
              tone="warn"
              icon="⚠"
              content={
                <div className="text-xs space-y-1">
                  <p>
                    Overworld enemy HP has <strong>not been located in the ROM</strong>{' '}
                    by any known research effort. Values shown are estimates from the
                    GameAnalysis2 knowledge base, calibrated against TAS hit counts and
                    community guides.
                  </p>
                  <p>
                    <strong>Absolute hit counts are approximate.</strong> Relative
                    differences vs. vanilla are still meaningful — if a buff cuts hits
                    in half here, it will roughly cut hits in half in-game.
                  </p>
                  <p>
                    Bosses use a different damage code path and are excluded.
                  </p>
                </div>
              }
            />
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
            {preview.enemy_kills.map((e) => (
              <EnemyCard key={e.name} enemy={e} />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

function StatChip({
  label,
  value,
  vanilla,
  color,
}: {
  label: string;
  value: number;
  vanilla: number;
  color: string;
}) {
  const diff = value - vanilla;
  const arrow = diff > 0 ? '↑' : diff < 0 ? '↓' : '';
  const arrowColor = diff > 0 ? 'text-emerald-400' : diff < 0 ? 'text-red-400' : '';
  return (
    <div className="flex items-baseline gap-1.5">
      <span className={`${color} font-medium`}>{label}</span>
      <span className="text-slate-100 font-mono text-base">{value}</span>
      {diff !== 0 && (
        <span className={`text-xs ${arrowColor} font-mono`}>
          {arrow} (vanilla {vanilla})
        </span>
      )}
    </div>
  );
}

function EnemyCard({ enemy }: { enemy: PlayerStatsPreview['enemy_kills'][number] }) {
  const swordDelta = enemy.sword_hits - enemy.sword_hits_vanilla;
  const rodDelta = enemy.rod_hits - enemy.rod_hits_vanilla;
  const Big = ({ n }: { n: number }) => (
    <span className="font-mono text-base">
      {n >= 999 ? '∞' : n}
    </span>
  );
  return (
    <div className="bg-slate-800 rounded p-2 border border-slate-700">
      <div className="flex items-center justify-between">
        <span className="text-sm text-slate-200 truncate">{enemy.name}</span>
        {enemy.hp_confidence === 'estimated' && (
          <span
            className="text-[9px] text-slate-500 italic"
            title="HP value is estimated; absolute hit counts are approximate"
          >
            est.
          </span>
        )}
      </div>
      <div className="text-[10px] text-slate-500 mb-1">HP {enemy.hp}</div>
      <div className="grid grid-cols-2 gap-1 text-xs">
        <div className="bg-slate-900/40 rounded px-1.5 py-0.5">
          <span className="text-orange-400">⚔</span>{' '}
          <Big n={enemy.sword_hits} />
          <DeltaChip delta={swordDelta} />
        </div>
        <div className="bg-slate-900/40 rounded px-1.5 py-0.5">
          <span className="text-fuchsia-400">🪄</span>{' '}
          <Big n={enemy.rod_hits} />
          <DeltaChip delta={rodDelta} />
        </div>
      </div>
    </div>
  );
}

function DeltaChip({ delta }: { delta: number }) {
  if (delta === 0) return null;
  const better = delta < 0; // fewer hits = better
  return (
    <span
      className={`ml-1 text-[10px] ${better ? 'text-emerald-400' : 'text-red-400'}`}
    >
      {better ? '↓' : '↑'}
      {Math.abs(delta)}
    </span>
  );
}
