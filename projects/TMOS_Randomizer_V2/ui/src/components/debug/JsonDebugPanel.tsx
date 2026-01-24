import { useState } from 'react';
import { useRandomizerStore } from '../../store';

export function JsonDebugPanel() {
  const { chapterData, plan, selectedChapter, sectionMap } = useRandomizerStore();
  const [activeSection, setActiveSection] = useState<'chapter' | 'plan' | 'screens' | 'sectionMap'>('chapter');
  const [copied, setCopied] = useState(false);

  const getJsonData = () => {
    switch (activeSection) {
      case 'chapter':
        return chapterData;
      case 'plan':
        return plan;
      case 'screens':
        return chapterData?.screens;
      case 'sectionMap':
        return sectionMap;
      default:
        return null;
    }
  };

  const jsonData = getJsonData();
  const jsonString = jsonData ? JSON.stringify(jsonData, null, 2) : 'No data available';

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(jsonString);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  };

  // Analyze parent_world distribution
  const parentWorldAnalysis = chapterData?.screens ? (() => {
    const counts: Record<number, number[]> = {};
    for (const screen of chapterData.screens) {
      if (!counts[screen.parent_world]) {
        counts[screen.parent_world] = [];
      }
      counts[screen.parent_world].push(screen.index);
    }
    return Object.entries(counts)
      .sort((a, b) => parseInt(a[0]) - parseInt(b[0]))
      .map(([pw, screens]) => ({
        parentWorld: parseInt(pw),
        hex: `0x${parseInt(pw).toString(16).toUpperCase().padStart(2, '0')}`,
        count: screens.length,
        screens: screens.slice(0, 10), // First 10 for display
        hasMore: screens.length > 10,
      }));
  })() : [];

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 p-4 border-b border-slate-700">
        <h2 className="text-lg font-semibold text-slate-200 mb-3">Debug Data</h2>

        {/* Section buttons */}
        <div className="flex gap-2 mb-3">
          <button
            onClick={() => setActiveSection('chapter')}
            className={`px-3 py-1.5 text-sm rounded ${
              activeSection === 'chapter'
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
          >
            Chapter Data
          </button>
          <button
            onClick={() => setActiveSection('plan')}
            className={`px-3 py-1.5 text-sm rounded ${
              activeSection === 'plan'
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
          >
            Plan Data
          </button>
          <button
            onClick={() => setActiveSection('screens')}
            className={`px-3 py-1.5 text-sm rounded ${
              activeSection === 'screens'
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
          >
            Screens Only
          </button>
          <button
            onClick={() => setActiveSection('sectionMap')}
            className={`px-3 py-1.5 text-sm rounded ${
              activeSection === 'sectionMap'
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
          >
            Section Map
          </button>
        </div>

        {/* Copy button */}
        <button
          onClick={handleCopy}
          className="px-4 py-2 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded transition-colors"
        >
          {copied ? 'Copied!' : 'Copy JSON to Clipboard'}
        </button>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-4">
        {/* Parent World Analysis */}
        {activeSection === 'chapter' && parentWorldAnalysis.length > 0 && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Parent World Distribution (Chapter {selectedChapter})
            </h3>
            <div className="bg-slate-800 rounded-lg overflow-hidden">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-slate-700">
                    <th className="px-3 py-2 text-left text-slate-300">Parent World</th>
                    <th className="px-3 py-2 text-left text-slate-300">Screens</th>
                    <th className="px-3 py-2 text-left text-slate-300">Screen Indices</th>
                  </tr>
                </thead>
                <tbody>
                  {parentWorldAnalysis.map((row) => (
                    <tr key={row.parentWorld} className="border-t border-slate-700">
                      <td className="px-3 py-2">
                        <span className="font-mono text-blue-400">{row.hex}</span>
                        <span className="text-slate-500 ml-2">({row.parentWorld})</span>
                      </td>
                      <td className="px-3 py-2 text-slate-300">{row.count}</td>
                      <td className="px-3 py-2 text-slate-400 font-mono text-xs">
                        {row.screens.join(', ')}
                        {row.hasMore && <span className="text-slate-500">...</span>}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <p className="text-xs text-slate-500 mt-2">
              Total: {chapterData?.screens.length} screens in {parentWorldAnalysis.length} parent world groups
            </p>
          </div>
        )}

        {/* Plan Summary */}
        {activeSection === 'plan' && plan && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Plan Summary
            </h3>
            <div className="bg-slate-800 rounded-lg p-4 space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-slate-400">Seed:</span>
                <span className="text-slate-200 font-mono">{plan.meta.seed}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">Preset:</span>
                <span className="text-slate-200">{plan.meta.preset}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">Valid:</span>
                <span className={plan.validation.is_valid ? 'text-green-400' : 'text-red-400'}>
                  {plan.validation.is_valid ? 'Yes' : 'No'}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">Chapters:</span>
                <span className="text-slate-200">{plan.chapters.length}</span>
              </div>
              {plan.validation.errors.length > 0 && (
                <div className="mt-2 p-2 bg-red-500/10 border border-red-500/20 rounded">
                  <div className="text-red-400 text-xs font-semibold mb-1">Errors:</div>
                  {plan.validation.errors.map((err, i) => (
                    <div key={i} className="text-red-300 text-xs">{err}</div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Section Map Analysis */}
        {activeSection === 'sectionMap' && sectionMap && sectionMap.applied && sectionMap.chapters && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Section Assignments (Chapter {selectedChapter})
            </h3>
            {(() => {
              const chapterSections = sectionMap.chapters[selectedChapter];
              if (!chapterSections) return <p className="text-slate-500">No section data for chapter {selectedChapter}</p>;

              // Group screens by section
              const sectionGroups: Record<number, { type: string; screens: number[] }> = {};
              for (const [screenIdx, data] of Object.entries(chapterSections.screens)) {
                const sid = data.section_id;
                if (!sectionGroups[sid]) {
                  sectionGroups[sid] = { type: data.section_type, screens: [] };
                }
                sectionGroups[sid].screens.push(parseInt(screenIdx));
              }

              return (
                <div className="bg-slate-800 rounded-lg overflow-hidden">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="bg-slate-700">
                        <th className="px-3 py-2 text-left text-slate-300">Section ID</th>
                        <th className="px-3 py-2 text-left text-slate-300">Type</th>
                        <th className="px-3 py-2 text-left text-slate-300">Screens</th>
                        <th className="px-3 py-2 text-left text-slate-300">Screen Indices</th>
                      </tr>
                    </thead>
                    <tbody>
                      {Object.entries(sectionGroups)
                        .sort((a, b) => parseInt(a[0]) - parseInt(b[0]))
                        .map(([sectionId, data]) => (
                          <tr key={sectionId} className="border-t border-slate-700">
                            <td className="px-3 py-2 font-mono text-blue-400">{sectionId}</td>
                            <td className="px-3 py-2 text-slate-300 capitalize">{data.type}</td>
                            <td className="px-3 py-2 text-slate-300">{data.screens.length}</td>
                            <td className="px-3 py-2 text-slate-400 font-mono text-xs">
                              {data.screens.slice(0, 10).join(', ')}
                              {data.screens.length > 10 && <span className="text-slate-500">... +{data.screens.length - 10} more</span>}
                            </td>
                          </tr>
                        ))}
                    </tbody>
                  </table>
                  <p className="text-xs text-slate-500 p-2">
                    Total: {chapterSections.screen_count} screens in {chapterSections.section_count} sections
                  </p>
                </div>
              );
            })()}
          </div>
        )}

        {activeSection === 'sectionMap' && (!sectionMap || !sectionMap.applied) && (
          <div className="mb-6 p-4 bg-amber-500/10 border border-amber-500/20 rounded">
            <p className="text-amber-300 text-sm">
              Section map not available. Generate a plan and click Randomize to populate section assignments.
            </p>
          </div>
        )}

        {/* Raw JSON */}
        <div>
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Raw JSON
          </h3>
          <pre className="bg-slate-800 rounded-lg p-4 text-xs text-slate-300 overflow-auto max-h-[60vh] font-mono whitespace-pre-wrap">
            {jsonString}
          </pre>
        </div>
      </div>
    </div>
  );
}
