import { useEffect, useRef, useState, useCallback } from 'react';
import { useRandomizerStore } from '../../store';
import { formatSeed } from '../../utils/formatters';

export function Header() {
  const {
    plan,
    romFilename,
    romLoaded,
    setModalOpen,
    apiConnected,
    apiError,
    checkApiConnection,
    loadAssetManifest,
    uploadRom,
    loadDefaultRom,
  } = useRandomizerStore();

  const fileInputRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [loadingDefault, setLoadingDefault] = useState(false);

  const handleLoadDefault = useCallback(async () => {
    setLoadingDefault(true);
    try {
      await loadDefaultRom();
    } catch (error) {
      console.error('Load default ROM failed:', error);
      alert(`Failed to load default ROM: ${error instanceof Error ? error.message : 'unknown error'}`);
    } finally {
      setLoadingDefault(false);
    }
  }, [loadDefaultRom]);

  const handleFileSelect = useCallback(async (file: File) => {
    if (!file.name.endsWith('.nes')) {
      alert('Please select a .nes ROM file');
      return;
    }

    setUploading(true);
    try {
      await uploadRom(file);
    } catch (error) {
      console.error('Upload failed:', error);
    } finally {
      setUploading(false);
    }
  }, [uploadRom]);

  const handleInputChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      handleFileSelect(file);
    }
    // Reset input so same file can be selected again
    e.target.value = '';
  }, [handleFileSelect]);

  // Check API connection on mount
  useEffect(() => {
    checkApiConnection();
    loadAssetManifest();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <header className="bg-slate-800 border-b border-slate-700 px-4 py-3">
      <div className="flex items-center justify-between">
        {/* Logo and Title */}
        <div className="flex items-center gap-3">
          <div className="text-2xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
            TMOS Randomizer V2
          </div>
          <span className="text-xs text-slate-500 bg-slate-700 px-2 py-0.5 rounded">
            v2.0.0
          </span>
        </div>

        {/* Seed and Plan Info */}
        {plan && (
          <div className="flex items-center gap-6">
            <div className="flex items-center gap-2 text-sm">
              <span className="text-slate-400">Seed:</span>
              <span className="font-mono text-blue-400">{formatSeed(plan.meta.seed)}</span>
            </div>
            {plan.meta.preset && (
              <div className="flex items-center gap-2 text-sm">
                <span className="text-slate-400">Preset:</span>
                <span className="text-green-400 capitalize">{plan.meta.preset}</span>
              </div>
            )}
            {romFilename && (
              <div className="flex items-center gap-2 text-sm">
                <span className="text-slate-400">ROM:</span>
                <span className="text-slate-300">{romFilename}</span>
              </div>
            )}
          </div>
        )}

        {/* Actions */}
        <div className="flex items-center gap-2">
          {/* Hidden file input for ROM import */}
          <input
            ref={fileInputRef}
            type="file"
            accept=".nes"
            className="hidden"
            onChange={handleInputChange}
          />

          {/* API Status Indicator */}
          <div className="flex items-center gap-2 mr-2">
            <div
              className={`w-2 h-2 rounded-full ${
                apiConnected ? 'bg-green-500' : 'bg-red-500'
              }`}
              title={apiConnected ? 'API Connected' : apiError || 'API Disconnected'}
            />
            <span className="text-xs text-slate-500">
              {apiConnected ? 'API' : 'Offline'}
            </span>
          </div>

          {/* Import ROM Button */}
          {apiConnected && (
            <button
              onClick={() => fileInputRef.current?.click()}
              disabled={uploading || loadingDefault}
              className="px-3 py-1.5 bg-blue-600 hover:bg-blue-500 disabled:bg-slate-600 text-white text-sm rounded transition-colors flex items-center gap-2"
              title={romLoaded ? `Current: ${romFilename}` : 'Import a .nes ROM file'}
            >
              {uploading ? (
                <>
                  <span className="animate-spin">&#9696;</span>
                  Importing...
                </>
              ) : (
                <>
                  <span>&#128194;</span>
                  {romLoaded ? 'Change ROM' : 'Import ROM'}
                </>
              )}
            </button>
          )}

          {/* Load Default ROM Button */}
          {apiConnected && (
            <button
              onClick={handleLoadDefault}
              disabled={uploading || loadingDefault}
              className="px-3 py-1.5 bg-slate-700 hover:bg-slate-600 disabled:bg-slate-800 text-white text-sm rounded transition-colors flex items-center gap-2"
              title="Load the default TMOS_ORIGINAL.nes shipped in rom-files/"
            >
              {loadingDefault ? (
                <>
                  <span className="animate-spin">&#9696;</span>
                  Loading...
                </>
              ) : (
                <>
                  <span>&#9733;</span>
                  Load Default ROM
                </>
              )}
            </button>
          )}

          {/* Randomize Button */}
          <button
            onClick={() => setModalOpen('randomize')}
            className="px-3 py-1.5 bg-purple-600 hover:bg-purple-500 text-white text-sm rounded transition-colors flex items-center gap-2"
          >
            <span>&#9881;</span>
            Randomize
          </button>

          {/* Patch ROM Button */}
          <button
            disabled={!romLoaded || !plan}
            onClick={() => alert('Patch ROM - Not yet implemented')}
            className={`px-3 py-1.5 text-white text-sm rounded transition-colors flex items-center gap-2 ${
              romLoaded && plan
                ? 'bg-green-600 hover:bg-green-500'
                : 'bg-slate-600 cursor-not-allowed'
            }`}
          >
            <span>&#128190;</span>
            Patch ROM
          </button>

          <button
            onClick={() => setModalOpen('settings')}
            className="px-3 py-1.5 bg-slate-700 hover:bg-slate-600 text-white text-sm rounded transition-colors"
          >
            Settings
          </button>
        </div>
      </div>
    </header>
  );
}
