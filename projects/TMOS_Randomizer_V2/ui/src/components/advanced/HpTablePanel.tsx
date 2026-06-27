import { useEffect } from 'react';
import { useRandomizerStore } from '../../store';
import { ByteField } from './ByteField';
import { PanelFrame } from './panelHelpers';

/**
 * HP-per-level byte grid, mirroring MpTablePanel's layout.
 *
 * Data source: Zustand store `playerStats.current.hp[25]` / `playerStats.vanilla.hp[25]`.
 * Commits via `updatePlayerHp(level, value)` (optimistic + preview refresh already
 * wired in the store action).
 */
export function HpTablePanel() {
  const playerStats = useRandomizerStore((s) => s.playerStats);
  const loading = useRandomizerStore((s) => s.playerStatsLoading);
  const error = useRandomizerStore((s) => s.playerStatsError);
  const loadPlayerStats = useRandomizerStore((s) => s.loadPlayerStats);
  const updatePlayerHp = useRandomizerStore((s) => s.updatePlayerHp);

  useEffect(() => {
    if (!playerStats && !loading) void loadPlayerStats();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const reload = () => { void loadPlayerStats(); };

  return (
    <PanelFrame
      title="HP per Level"
      tier="safe"
      romNote={`Max HP per character level · ROM_VERIFIED (${playerStats?.current.rom_offsets.hp ?? '$1F734'}, 25 bytes)`}
      help={
        <div className="text-xs space-y-1">
          <p>Direct lookup — one byte per level (Lv1–Lv25). The value at index L is the exact HP the character has at level L.</p>
          <p>Amber border = value differs from the vanilla ROM. Changes persist to the preview immediately.</p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!playerStats}
      onReload={reload}
    >
      {playerStats && (
        <section className="space-y-2">
          <h3 className="text-sm font-semibold text-slate-200">Max HP per level</h3>
          <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-2">
            {playerStats.current.hp.map((value, i) => {
              const level = i + 1;
              return (
                <div
                  key={level}
                  className="flex items-center gap-2 rounded-lg border border-slate-700 bg-slate-800/40 px-2.5 py-1.5"
                >
                  <span className="text-xs font-medium text-slate-400 w-9 shrink-0">
                    Lv {level}
                  </span>
                  <ByteField
                    value={value}
                    vanilla={playerStats.vanilla.hp[i]}
                    min={0}
                    max={255}
                    onCommit={(next) => updatePlayerHp(level, next)}
                    ariaLabel={`Max HP at level ${level}`}
                  />
                </div>
              );
            })}
          </div>
        </section>
      )}
    </PanelFrame>
  );
}
