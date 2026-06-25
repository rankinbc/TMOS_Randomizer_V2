import { useEffect, useState } from 'react';
import { useRandomizerStore } from '../../store';
import { SubTabBar, type SubTab } from '../common/SubTabBar';
import { TileBankView } from '../tilebank';
import { PalettePanel } from '../advanced/PalettePanel';

type GraphicsSection = 'tiles' | 'cosmetic';

const SECTIONS: SubTab<GraphicsSection>[] = [
  { id: 'tiles', label: 'Tiles' },
  { id: 'cosmetic', label: 'Cosmetic' },
];

/**
 * Graphics tab: the tile-bank editor (default) plus the palette/cosmetic panel
 * re-homed from the retired Expert tab. Consumes a focusTarget so the World-screen
 * palette link deep-links straight to Cosmetic.
 */
export function GraphicsView() {
  const [section, setSection] = useState<GraphicsSection>('tiles');
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  useEffect(() => {
    if (focusTarget?.tab === 'graphics' && focusTarget.section === 'cosmetic') {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setSection('cosmetic');
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget]);

  return (
    <div className="h-full flex flex-col">
      <SubTabBar tabs={SECTIONS} active={section} onSelect={setSection} />
      <div className="flex-1 overflow-auto">
        {section === 'tiles' && <TileBankView />}
        {section === 'cosmetic' && <PalettePanel />}
      </div>
    </div>
  );
}
