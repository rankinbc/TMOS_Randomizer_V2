import { useState } from 'react';
import { SubTabBar, type SubTab } from '../common/SubTabBar';
import { PlayerStatsView } from './PlayerStatsView';
import { MpTablePanel } from '../advanced/MpTablePanel';
import { WeaponDamagePanel } from '../advanced/WeaponDamagePanel';
import { LevelCapsPanel } from '../advanced/LevelCapsPanel';

type HeroSection = 'progression' | 'magic' | 'weapons' | 'caps';

const SECTIONS: SubTab<HeroSection>[] = [
  { id: 'progression', label: 'Progression & Combat' },
  { id: 'magic', label: 'Magic & Spells' },
  { id: 'weapons', label: 'Weapon Damage', expert: true },
  { id: 'caps', label: 'Caps & Limits' },
];

/**
 * Hero tab: the player-progression editor (default) plus the magic, weapon-damage,
 * and caps panels re-homed from the retired Expert tab.
 */
export function HeroView() {
  const [section, setSection] = useState<HeroSection>('progression');
  return (
    <div className="h-full flex flex-col">
      <SubTabBar tabs={SECTIONS} active={section} onSelect={setSection} />
      <div className="flex-1 overflow-auto">
        {section === 'progression' && <PlayerStatsView />}
        {section === 'magic' && <MpTablePanel />}
        {section === 'weapons' && <WeaponDamagePanel />}
        {section === 'caps' && <LevelCapsPanel />}
      </div>
    </div>
  );
}
