import { useState } from 'react';
import { useRandomizerStore } from '../../store';

export function RandomizeModal() {
  const {
    modalOpen,
    setModalOpen,
    fetchPlanFromApi,
    planLoading,
    romLoaded,
    apiConnected,
    settings,
    setSettings,
    setSelectedTab,
  } = useRandomizerStore();

  const [seed, setSeed] = useState<string>('');
  const [useRandomSeed, setUseRandomSeed] = useState(true);

  if (modalOpen !== 'randomize') return null;

  const handleRandomize = async () => {
    const seedValue = useRandomSeed ? undefined : parseInt(seed, 10) || undefined;
    try {
      await fetchPlanFromApi(seedValue);
      setModalOpen(null);
      // Switch to map tab to show the randomized world
      setSelectedTab('map');
    } catch (error) {
      console.error('Randomization failed:', error);
    }
  };

  const handleClose = () => {
    setModalOpen(null);
  };

  const canRandomize = romLoaded && apiConnected && !planLoading;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={handleClose}
      />

      {/* Modal */}
      <div className="relative bg-slate-800 border border-slate-700 rounded-lg shadow-xl w-full max-w-md mx-4">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-700">
          <h2 className="text-lg font-semibold text-slate-200">Randomize Game</h2>
          <button
            onClick={handleClose}
            className="text-slate-400 hover:text-slate-200 transition-colors"
          >
            <span className="text-xl">&times;</span>
          </button>
        </div>

        {/* Content */}
        <div className="px-6 py-4 space-y-4">
          {/* Seed Input */}
          <div>
            <label className="flex items-center gap-2 mb-2">
              <input
                type="checkbox"
                checked={useRandomSeed}
                onChange={(e) => setUseRandomSeed(e.target.checked)}
                className="rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500"
              />
              <span className="text-sm text-slate-300">Use random seed</span>
            </label>

            {!useRandomSeed && (
              <div>
                <label className="block text-sm text-slate-400 mb-1">Seed</label>
                <input
                  type="text"
                  value={seed}
                  onChange={(e) => setSeed(e.target.value.replace(/\D/g, ''))}
                  placeholder="Enter numeric seed"
                  className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded text-slate-200 placeholder-slate-500 focus:outline-none focus:border-blue-500"
                />
              </div>
            )}
          </div>

          {/* Options Section */}
          <div className="border-t border-slate-700 pt-4">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Randomization Options
            </h3>

            <div className="space-y-3">
              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={settings.shuffle_overworld}
                  onChange={(e) => setSettings({ shuffle_overworld: e.target.checked })}
                  className="rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500"
                />
                <span className="text-sm text-slate-300">Shuffle Overworld</span>
              </label>

              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={settings.shuffle_towns}
                  onChange={(e) => setSettings({ shuffle_towns: e.target.checked })}
                  className="rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500"
                />
                <span className="text-sm text-slate-300">Shuffle Towns</span>
              </label>

              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={settings.shuffle_dungeons}
                  onChange={(e) => setSettings({ shuffle_dungeons: e.target.checked })}
                  className="rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500"
                />
                <span className="text-sm text-slate-300">Shuffle Dungeons</span>
              </label>

              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={settings.randomize_mazes}
                  onChange={(e) => setSettings({ randomize_mazes: e.target.checked })}
                  className="rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500"
                />
                <span className="text-sm text-slate-300">Randomize Mazes</span>
              </label>
            </div>
          </div>

          {/* Preset */}
          <div className="border-t border-slate-700 pt-4">
            <label className="block text-sm text-slate-400 mb-2">Preset</label>
            <select
              value={settings.preset}
              onChange={(e) => setSettings({ preset: e.target.value as 'standard' | 'chaotic' | 'minimal' })}
              className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded text-slate-200 focus:outline-none focus:border-blue-500"
            >
              <option value="standard">Standard</option>
              <option value="minimal">Minimal</option>
              <option value="chaotic">Chaotic</option>
            </select>
          </div>

          {/* Status Messages */}
          {!romLoaded && (
            <div className="bg-yellow-500/10 border border-yellow-500/30 rounded p-3 text-sm text-yellow-300">
              Please import a ROM file first
            </div>
          )}
          {!apiConnected && (
            <div className="bg-red-500/10 border border-red-500/30 rounded p-3 text-sm text-red-300">
              API is not connected
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-3 px-6 py-4 border-t border-slate-700">
          <button
            onClick={handleClose}
            className="px-4 py-2 text-sm text-slate-300 hover:text-slate-100 transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleRandomize}
            disabled={!canRandomize}
            className={`px-4 py-2 text-sm rounded font-medium transition-colors ${
              canRandomize
                ? 'bg-purple-600 hover:bg-purple-500 text-white'
                : 'bg-slate-600 text-slate-400 cursor-not-allowed'
            }`}
          >
            {planLoading ? (
              <span className="flex items-center gap-2">
                <span className="animate-spin">&#9696;</span>
                Randomizing...
              </span>
            ) : (
              'Randomize'
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
