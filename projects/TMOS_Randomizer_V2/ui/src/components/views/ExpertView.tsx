import { useState } from 'react';
import { AdvancedView } from './AdvancedView';
import { JsonDebugPanel } from '../debug/JsonDebugPanel';

export function ExpertView() {
  const [unlocked, setUnlocked] = useState(false);

  if (!unlocked) {
    return (
      <div className="flex items-center justify-center h-full p-8">
        <div className="max-w-md text-center">
          <div className="text-4xl mb-3">{'⚠'}</div>
          <h2 className="text-xl font-semibold text-red-400 mb-2">Danger Zone</h2>
          <p className="text-slate-400 mb-6">
            These controls edit raw ROM bytes and can crash or corrupt the game if
            set incorrectly. Only proceed if you understand the risk.
          </p>
          <button
            onClick={() => setUnlocked(true)}
            className="px-4 py-2 bg-red-700 hover:bg-red-600 text-white rounded font-medium"
          >
            I understand — unlock Expert controls
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full overflow-y-auto">
      <AdvancedView />
      <div className="border-t border-slate-700 mt-4">
        <JsonDebugPanel />
      </div>
    </div>
  );
}
