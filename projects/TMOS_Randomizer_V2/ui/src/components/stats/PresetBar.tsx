import type { PlayerStatsPreset } from '../../api/client';
import { HelpChip } from './HelpChip';

interface PresetBarProps {
  presets: PlayerStatsPreset[] | null;
  onApply: (name: string) => void;
  busy?: boolean;
}

const TONE: Record<string, string> = {
  vanilla: 'bg-slate-700 hover:bg-slate-600 text-slate-200',
  easy: 'bg-emerald-700/60 hover:bg-emerald-600/60 text-emerald-100',
  hardcore: 'bg-red-700/60 hover:bg-red-600/60 text-red-100',
  glass_cannon: 'bg-amber-700/60 hover:bg-amber-600/60 text-amber-100',
  tank: 'bg-blue-700/60 hover:bg-blue-600/60 text-blue-100',
  speedrun: 'bg-purple-700/60 hover:bg-purple-600/60 text-purple-100',
  romhack1_halved: 'bg-slate-700 hover:bg-slate-600 text-slate-300',
};

const PRETTY: Record<string, string> = {
  vanilla: 'Vanilla',
  easy: 'Easy',
  hardcore: 'Hardcore',
  glass_cannon: 'Glass Cannon',
  tank: 'Tank',
  speedrun: 'Speedrun',
  romhack1_halved: 'Romhack1 (halved)',
};

export function PresetBar({ presets, onApply, busy }: PresetBarProps) {
  return (
    <div className="flex items-center flex-wrap gap-2">
      <div className="text-xs uppercase tracking-wide text-slate-500 mr-1 flex items-center gap-1">
        Presets
        <HelpChip
          content={
            <div className="text-xs space-y-1">
              <p>
                Each preset writes a curated set of values to HP, damage indices, and
                damage values, starting from <strong>vanilla</strong> as the baseline.
              </p>
              <p>
                Presets <em>replace</em> your current edits. Use <code>Vanilla</code>{' '}
                to undo everything.
              </p>
            </div>
          }
        />
      </div>
      {!presets && <span className="text-xs text-slate-500">Loading…</span>}
      {presets?.map((p) => (
        <button
          key={p.name}
          type="button"
          disabled={busy}
          onClick={() => onApply(p.name)}
          title={p.description}
          className={`text-xs px-2.5 py-1 rounded transition ${TONE[p.name] ?? 'bg-slate-700 hover:bg-slate-600 text-slate-200'} ${busy ? 'opacity-50 cursor-wait' : ''}`}
        >
          {PRETTY[p.name] ?? p.name}
        </button>
      ))}
    </div>
  );
}
