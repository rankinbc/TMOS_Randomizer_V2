import type { ChapterGroups, EncounterGroupPatch, ChapterLineups } from '../../api/client';
import { HelpChip } from '../stats/HelpChip';

interface EncounterGroupEditorProps {
  groups: ChapterGroups;
  vanilla: ChapterGroups;
  /** The chapter's lineups (used to resolve "lineup N → enemies" preview) */
  chapterLineups: ChapterLineups | null;
  onChange: (entryIndex: number, patch: EncounterGroupPatch) => Promise<void> | void;
}

const FLAG_LABEL: Record<number, string> = {
  0: 'low',
  1: 'medium',
  2: 'high',
  3: 'very high',
};

export function EncounterGroupEditor({ groups, vanilla, chapterLineups, onChange }: EncounterGroupEditorProps) {
  return (
    <div className="bg-slate-800/60 rounded-lg p-3 space-y-2">
      <div className="flex items-center gap-2 text-sm font-semibold text-slate-200">
        Per-Screen Encounter Map
        <HelpChip
          content={
            <div className="text-xs space-y-1">
              <p>
                Maps screens to encounter behavior. Each row is a 3-byte ROM entry
                listing the screen index, the lineup it triggers, and an{' '}
                encounter-rate flag.
              </p>
              <p>
                <strong>Monster group</strong> = lineup index (low 7 bits) + alternate
                behavior flag (high bit). For Ch1-2 the low bits select one of 6
                lineups; for Ch3-5 some values exceed the lineup count and may
                trigger different code paths (not fully traced).
              </p>
              <p>
                <strong>Flag</strong>: 0=low encounter rate, 3=very high. Drives how
                often you bump into enemies on that screen.
              </p>
              <p>
                <strong>Editing the screen byte</strong> retargets the encounter to
                a different screen — if you want screen X to start having
                encounters, set its byte here.
              </p>
            </div>
          }
        />
        <span className="ml-auto text-[11px] text-slate-500 font-mono">
          {groups.entry_count} entries · {groups.rom_offset}
        </span>
      </div>

      <table className="w-full text-xs">
        <thead className="text-[10px] uppercase tracking-wide text-slate-500">
          <tr>
            <th className="text-left py-1 pr-2">#</th>
            <th className="text-left pr-2">Screen</th>
            <th className="text-left pr-2">Lineup (group)</th>
            <th className="text-left pr-2">Flag</th>
            <th className="text-left">Resolves to</th>
          </tr>
        </thead>
        <tbody>
          {groups.entries.map((e) => {
            const v = vanilla.entries[e.entry_index];
            const screenDiff = e.screen !== v.screen;
            const groupDiff = e.monster_group !== v.monster_group;
            const flagDiff = e.flag !== v.flag;

            const lineupForLow = chapterLineups?.lineups.find(
              (l) => l.lineup_index === e.monster_group_low
            );
            const lineupNames = lineupForLow
              ? lineupForLow.slots
                  .filter((s) => !s.is_empty)
                  .map((s) => s.enemy_name)
                  .join(', ')
              : null;

            return (
              <tr key={e.entry_index} className="border-t border-slate-800">
                <td className="py-1 pr-2 font-mono text-slate-500">{e.entry_index}</td>
                <td className="pr-2">
                  <input
                    type="number"
                    min={0}
                    max={255}
                    value={e.screen}
                    onChange={(ev) => {
                      const v = Math.max(0, Math.min(255, parseInt(ev.target.value, 10) || 0));
                      if (v !== e.screen) onChange(e.entry_index, { screen: v });
                    }}
                    className={`w-16 bg-slate-900 border rounded px-1.5 py-0.5 text-right font-mono ${
                      screenDiff ? 'border-amber-500/60 text-amber-300' : 'border-slate-700 text-slate-200'
                    }`}
                    title={`hex 0x${e.screen.toString(16).toUpperCase().padStart(2, '0')}`}
                  />
                </td>
                <td className="pr-2">
                  <div className="flex items-center gap-1">
                    <input
                      type="number"
                      min={0}
                      max={255}
                      value={e.monster_group}
                      onChange={(ev) => {
                        const v = Math.max(0, Math.min(255, parseInt(ev.target.value, 10) || 0));
                        if (v !== e.monster_group) onChange(e.entry_index, { monster_group: v });
                      }}
                      className={`w-16 bg-slate-900 border rounded px-1.5 py-0.5 text-right font-mono ${
                        groupDiff ? 'border-amber-500/60 text-amber-300' : 'border-slate-700 text-slate-200'
                      }`}
                      title={`raw byte 0x${e.monster_group.toString(16).toUpperCase().padStart(2, '0')}`}
                    />
                    <span className="text-[10px] text-slate-500 font-mono">
                      ={e.monster_group_hi_bit ? 'H+' : ''}{e.monster_group_low}
                    </span>
                  </div>
                </td>
                <td className="pr-2">
                  <select
                    value={e.flag}
                    onChange={(ev) => onChange(e.entry_index, { flag: parseInt(ev.target.value, 10) })}
                    className={`bg-slate-900 border rounded px-1 py-0.5 ${
                      flagDiff ? 'border-amber-500/60 text-amber-300' : 'border-slate-700 text-slate-300'
                    }`}
                  >
                    {[0, 1, 2, 3].map((f) => (
                      <option key={f} value={f}>{f} ({FLAG_LABEL[f]})</option>
                    ))}
                    {/* Allow other values if vanilla had them */}
                    {![0, 1, 2, 3].includes(e.flag) && (
                      <option value={e.flag}>{e.flag} (raw)</option>
                    )}
                  </select>
                </td>
                <td className="text-[11px] text-slate-400 truncate max-w-xs">
                  {lineupForLow ? (
                    <>
                      <span className="text-slate-300">L{e.monster_group_low}</span>
                      {lineupNames && <span className="text-slate-500"> → {lineupNames}</span>}
                    </>
                  ) : (
                    <span className="text-slate-600 italic">
                      L{e.monster_group_low} (out of range)
                    </span>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
