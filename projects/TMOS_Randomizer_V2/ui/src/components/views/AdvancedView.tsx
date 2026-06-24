import { useEffect, useState } from 'react';
import { useRandomizerStore } from '../../store';
import { PlayerStatsView } from './PlayerStatsView';
import { BossesPanel } from '../advanced/BossesPanel';
import { EconomyPanel } from '../advanced/EconomyPanel';
import { TbFormulasPanel } from '../advanced/TbFormulasPanel';
import { EncounterRatesPanel } from '../advanced/EncounterRatesPanel';
import { WeaponDamagePanel } from '../advanced/WeaponDamagePanel';
import { MpTablePanel } from '../advanced/MpTablePanel';
import { LevelCapsPanel } from '../advanced/LevelCapsPanel';
import { PalettePanel } from '../advanced/PalettePanel';

/**
 * Advanced customization page: a sub-tab router over category panels exposing the
 * full breadth of editable ROM values. Safe (ROM_VERIFIED) values are editable and
 * prominent; riskier (DISASSEMBLY) values sit behind Expert disclosures with warn
 * tooltips; display-only (INFERRED / RAM / guide-sourced) values are shown for
 * reference but not editable. Every address was verified against the GameAnalysis2
 * ROM knowledge base before being exposed here.
 */

type SubTabId =
  | 'progression'
  | 'magic'
  | 'bosses'
  | 'encounters'
  | 'tbformulas'
  | 'weapons'
  | 'economy'
  | 'caps'
  | 'cosmetic';

const SUB_TABS: { id: SubTabId; label: string; expert?: boolean }[] = [
  { id: 'progression', label: 'Progression & Combat' },
  { id: 'magic', label: 'Magic & Spells' },
  { id: 'bosses', label: 'Boss Bytes (Advanced)', expert: true },
  { id: 'encounters', label: 'Encounter Rates', expert: true },
  { id: 'tbformulas', label: 'TB Combat Formulas', expert: true },
  { id: 'weapons', label: 'Weapon Damage', expert: true },
  { id: 'economy', label: 'Economy & Shops' },
  { id: 'caps', label: 'Caps & Limits' },
  { id: 'cosmetic', label: 'Cosmetic' },
];

export function AdvancedView() {
  const [sub, setSub] = useState<SubTabId>('progression');
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  // Deep-link: a World-panel palette/shop link asks us to open a specific
  // sub-tab. (focusTarget.tab is 'expert' since this view lives under ExpertView.)
  useEffect(() => {
    if (focusTarget?.tab === 'expert' && focusTarget.section) {
      const target = focusTarget.section as SubTabId;
      // eslint-disable-next-line react-hooks/set-state-in-effect
      if (SUB_TABS.some((t) => t.id === target)) setSub(target);
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget]);

  return (
    <div className="h-full flex flex-col">
      {/* Sub-tab bar */}
      <div className="flex-shrink-0 bg-slate-800/60 border-b border-slate-700 overflow-x-auto">
        <div className="flex">
          {SUB_TABS.map((t) => (
            <button
              key={t.id}
              onClick={() => setSub(t.id)}
              className={`whitespace-nowrap px-4 py-2.5 text-sm font-medium border-b-2 transition-colors ${
                sub === t.id
                  ? 'text-blue-400 border-blue-400 bg-slate-700/40'
                  : 'text-slate-400 border-transparent hover:text-slate-200 hover:bg-slate-700/20'
              }`}
            >
              {t.label}
              {t.expert && (
                <span className="ml-1.5 align-middle text-[10px] uppercase tracking-wide text-amber-400/80">
                  expert
                </span>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Sub-tab content */}
      <div className="flex-1 overflow-auto">
        {sub === 'progression' && <PlayerStatsView />}
        {sub === 'magic' && <MpTablePanel />}
        {sub === 'bosses' && (
          <BossesPanel
            // Safe boss fields live in the Enemies tab; Expert shows only non-safe
            // tiers so no editable field appears in two tabs.
            tierFilter={(tier) => tier !== 'safe'}
            title="Boss Bytes (Advanced)"
            romNote="Advanced boss bytes — expert/display tiers only · safe HP & damage live in the Enemies tab"
            headerTier="expert"
          />
        )}
        {sub === 'encounters' && <EncounterRatesPanel />}
        {sub === 'tbformulas' && <TbFormulasPanel />}
        {sub === 'weapons' && <WeaponDamagePanel />}
        {sub === 'economy' && <EconomyPanel />}
        {sub === 'caps' && <LevelCapsPanel />}
        {sub === 'cosmetic' && <PalettePanel />}
      </div>
    </div>
  );
}
