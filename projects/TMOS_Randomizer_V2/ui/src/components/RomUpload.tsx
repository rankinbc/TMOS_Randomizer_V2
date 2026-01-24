import { useCallback, useState } from 'react';
import { useRandomizerStore } from '../store';

export function RomUpload() {
  const { romLoaded, romFilename, romChapters, apiConnected, apiError, uploadRom } = useRandomizerStore();
  const [uploading, setUploading] = useState(false);
  const [dragOver, setDragOver] = useState(false);

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

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(false);

    const file = e.dataTransfer.files[0];
    if (file) {
      handleFileSelect(file);
    }
  }, [handleFileSelect]);

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(true);
  }, []);

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(false);
  }, []);

  const handleInputChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      handleFileSelect(file);
    }
  }, [handleFileSelect]);

  if (!apiConnected) {
    return (
      <div className="p-4 bg-red-900/30 border border-red-700 rounded-lg">
        <p className="text-red-300 text-sm">
          API not connected. Start the backend server to load ROMs.
        </p>
      </div>
    );
  }

  if (romLoaded) {
    return (
      <div className="p-4 bg-slate-800 border border-slate-700 rounded-lg">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-slate-200 font-medium">{romFilename}</p>
            <p className="text-slate-400 text-sm">
              {romChapters.length} chapters, {romChapters.reduce((acc, ch) => acc + ch.screen_count, 0)} screens
            </p>
          </div>
          <label className="cursor-pointer px-3 py-1 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded">
            Change
            <input
              type="file"
              accept=".nes"
              className="hidden"
              onChange={handleInputChange}
            />
          </label>
        </div>
      </div>
    );
  }

  return (
    <div
      className={`
        p-8 border-2 border-dashed rounded-lg text-center transition-colors cursor-pointer
        ${dragOver
          ? 'border-blue-500 bg-blue-500/10'
          : 'border-slate-600 hover:border-slate-500 bg-slate-800/50'
        }
        ${uploading ? 'opacity-50 pointer-events-none' : ''}
      `}
      onDrop={handleDrop}
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onClick={() => document.getElementById('rom-file-input')?.click()}
    >
      <input
        id="rom-file-input"
        type="file"
        accept=".nes"
        className="hidden"
        onChange={handleInputChange}
      />

      <div className="text-4xl mb-2">
        {uploading ? '...' : '📁'}
      </div>

      <p className="text-slate-300 mb-1">
        {uploading ? 'Uploading...' : 'Drop ROM file here or click to browse'}
      </p>
      <p className="text-slate-500 text-sm">
        Accepts .nes files
      </p>

      {apiError && (
        <p className="text-red-400 text-sm mt-2">{apiError}</p>
      )}
    </div>
  );
}
