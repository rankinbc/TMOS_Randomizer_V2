import { useState } from 'react';
import { useRandomizerStore } from '../../store';
import { SubTabBar } from '../common/SubTabBar';
import { MapView } from './MapView';
import { SeedSummaryView } from './SeedSummaryView';
import type { RandomizationPlan } from '../../types/randomizer';

type RandomizeSubTab = 'plan' | 'summary';

const SUB_TABS: { id: RandomizeSubTab; label: string }[] = [
  { id: 'plan', label: 'Plan Flow' },
  { id: 'summary', label: 'Seed Summary' },
];

/**
 * Randomize tab: the per-chapter plan flow graph plus the applied-seed
 * summary (shops, encounters, navigability) as sub-tabs.
 */
export function RandomizeView({
  chapter,
}: {
  chapter: RandomizationPlan['chapters'][number] | null;
}) {
  const lastSeedSummary = useRandomizerStore((s) => s.lastSeedSummary);
  // Land on the summary when a seed has been applied; the flow graph
  // otherwise (matches the old default view).
  const [subTab, setSubTab] = useState<RandomizeSubTab>(
    lastSeedSummary ? 'summary' : 'plan'
  );

  return (
    <div className="flex flex-col h-full">
      <SubTabBar tabs={SUB_TABS} active={subTab} onSelect={setSubTab} />
      <div className="flex-1 overflow-hidden">
        {subTab === 'summary' ? (
          <SeedSummaryView />
        ) : chapter && chapter.sections.length > 0 ? (
          <MapView chapter={chapter} />
        ) : (
          <div className="flex items-center justify-center h-full">
            <div className="text-center p-8">
              <div className="text-4xl mb-4 opacity-50">{'\u{1F50D}'}</div>
              <h3 className="text-lg font-medium text-slate-300 mb-2">No Plan Generated</h3>
              <p className="text-sm text-slate-500 max-w-sm">
                Click the Randomize button to generate a randomization plan.
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
