import { useEffect, useState } from 'react';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { useRandomizerStore } from '../../store';
import { SubTabBar, type SubTab } from '../common/SubTabBar';
import { ItemsView } from './ItemsView';
import { EconomyPanel } from '../advanced/EconomyPanel';

type ItemsSection = 'items' | 'economy';

const SECTIONS: SubTab<ItemsSection>[] = [
  { id: 'items', label: 'Items' },
  { id: 'economy', label: 'Economy & Shops' },
];

interface ItemsTabViewProps {
  chapter: SimplifiedChapterPlan;
}

/**
 * Items & Economy tab: the per-chapter items view (default) plus the economy/shops
 * panel re-homed from the retired Expert tab. Consumes a focusTarget so the
 * World-screen shop link deep-links straight to Economy.
 */
export function ItemsTabView({ chapter }: ItemsTabViewProps) {
  const [section, setSection] = useState<ItemsSection>('items');
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  useEffect(() => {
    if (focusTarget?.tab === 'items' && focusTarget.section === 'economy') {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setSection('economy');
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget]);

  return (
    <div className="h-full flex flex-col">
      <SubTabBar tabs={SECTIONS} active={section} onSelect={setSection} />
      <div className="flex-1 overflow-auto">
        {section === 'items' && <ItemsView chapter={chapter} />}
        {section === 'economy' && <EconomyPanel />}
      </div>
    </div>
  );
}
