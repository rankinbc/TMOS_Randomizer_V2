import { useRandomizerStore } from '../../store';
import { AdvancedView } from './AdvancedView';
import { JsonDebugPanel } from '../debug/JsonDebugPanel';

export function ExpertView() {
  const expertUnlocked = useRandomizerStore((s) => s.expertUnlocked);
  const unlockExpert = useRandomizerStore((s) => s.unlockExpert);

  if (!expertUnlocked) {
    return (
      <div className="flex items-center justify-center h-full p-8 bg-slate-900">
        <div className="max-w-md text-center">
          <div className="text-5xl mb-4">{'⚠'}</div>
          <h2 className="text-2xl font-bold text-red-400 mb-3">Expert Controls — Danger Zone</h2>
          <p className="text-slate-400 mb-6 leading-relaxed">
            These controls edit raw ROM bytes and combat formulas directly. Setting
            them incorrectly can crash the game or corrupt your saves. Only proceed if
            you understand and accept this risk.
          </p>
          <button
            onClick={unlockExpert}
            className="px-5 py-2.5 bg-red-700 hover:bg-red-600 text-white rounded font-medium"
          >
            I understand this can crash the game
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
