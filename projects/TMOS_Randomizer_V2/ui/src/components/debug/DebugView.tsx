// ui/src/components/debug/DebugView.tsx
import { useState } from 'react';
import { ChangesView } from './ChangesView';
import { ValidationView } from './ValidationView';
import { JsonDebugPanel } from './JsonDebugPanel';

type Section = 'changes' | 'validation' | 'inspector';

const SECTIONS: { id: Section; label: string }[] = [
  { id: 'changes', label: 'Changes' },
  { id: 'validation', label: 'Validation' },
  { id: 'inspector', label: 'Inspector' },
];

export function DebugView() {
  const [section, setSection] = useState<Section>('changes');
  return (
    <div className="h-full flex flex-col">
      <div className="flex-shrink-0 flex gap-2 p-3 border-b border-slate-700 bg-slate-800">
        {SECTIONS.map((s) => (
          <button
            key={s.id}
            onClick={() => setSection(s.id)}
            className={`px-3 py-1.5 text-sm rounded ${section === s.id ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'}`}
          >
            {s.label}
          </button>
        ))}
      </div>
      <div className="flex-1 overflow-hidden">
        {section === 'changes' && <ChangesView />}
        {section === 'validation' && <ValidationView />}
        {section === 'inspector' && <JsonDebugPanel />}
      </div>
    </div>
  );
}
