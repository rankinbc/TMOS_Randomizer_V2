import { useState } from 'react';
import { useRandomizerStore } from '../../store';

interface ValidationResult {
  status: string;
  rom_filename: string | null;
  chapters: Array<{
    chapter_num: number;
    total_screens: number;
    errors: string[];
    warnings: string[];
    passed: boolean;
    reachability: {
      reachable_count: number;
      total_count: number;
      percent: number;
    };
    nav_components: number;
    time_period: {
      past_count: number;
      present_count: number;
      time_doors: number[];
    };
  }>;
  summary: {
    total_errors: number;
    total_warnings: number;
    all_passed: boolean;
  };
}

export function JsonDebugPanel() {
  const { chapterData, plan, selectedChapter, sectionMap } = useRandomizerStore();
  const [activeSection, setActiveSection] = useState<'chapter' | 'plan' | 'screens' | 'sectionMap' | 'validation'>('chapter');
  const [copied, setCopied] = useState(false);
  const [validationResult, setValidationResult] = useState<ValidationResult | null>(null);
  const [validationLoading, setValidationLoading] = useState(false);
  const [validationError, setValidationError] = useState<string | null>(null);

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

  const runValidation = async () => {
    setValidationLoading(true);
    setValidationError(null);
    try {
      const response = await fetch('http://localhost:8000/api/debug/validate');
      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.detail || 'Validation failed');
      }
      const result = await response.json();
      setValidationResult(result);
      setActiveSection('validation');
    } catch (err) {
      setValidationError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setValidationLoading(false);
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
          <button
            onClick={() => setActiveSection('validation')}
            className={`px-3 py-1.5 text-sm rounded ${
              activeSection === 'validation'
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
          >
            Validation
          </button>
        </div>

        {/* Action buttons */}
        <div className="flex gap-2">
          <button
            onClick={handleCopy}
            className="px-4 py-2 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded transition-colors"
          >
            {copied ? 'Copied!' : 'Copy JSON'}
          </button>
          <button
            onClick={runValidation}
            disabled={validationLoading}
            className={`px-4 py-2 text-sm rounded transition-colors ${
              validationLoading
                ? 'bg-slate-600 text-slate-400 cursor-not-allowed'
                : 'bg-green-700 hover:bg-green-600 text-white'
            }`}
          >
            {validationLoading ? 'Running...' : 'Run Validation Tests'}
          </button>
        </div>
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

        {/* Validation Results */}
        {activeSection === 'validation' && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              ROM Validation Results
            </h3>

            {validationError && (
              <div className="p-4 bg-red-500/10 border border-red-500/20 rounded mb-4">
                <p className="text-red-400 text-sm">{validationError}</p>
              </div>
            )}

            {!validationResult && !validationError && (
              <div className="p-4 bg-slate-800 rounded">
                <p className="text-slate-400 text-sm">
                  Click "Run Validation Tests" to validate the current ROM state against all test criteria.
                </p>
              </div>
            )}

            {validationResult && (
              <>
                {/* Summary */}
                <div className={`p-4 rounded mb-4 ${
                  validationResult.summary.all_passed
                    ? 'bg-green-500/10 border border-green-500/20'
                    : 'bg-red-500/10 border border-red-500/20'
                }`}>
                  <div className="flex items-center gap-3 mb-2">
                    <span className={`text-2xl ${validationResult.summary.all_passed ? 'text-green-400' : 'text-red-400'}`}>
                      {validationResult.summary.all_passed ? '✓' : '✗'}
                    </span>
                    <span className={`text-lg font-semibold ${
                      validationResult.summary.all_passed ? 'text-green-400' : 'text-red-400'
                    }`}>
                      {validationResult.summary.all_passed ? 'ALL TESTS PASSED' : 'VALIDATION FAILED'}
                    </span>
                  </div>
                  <div className="text-sm text-slate-300">
                    <span className="text-red-400">{validationResult.summary.total_errors} errors</span>
                    {' · '}
                    <span className="text-amber-400">{validationResult.summary.total_warnings} warnings</span>
                    {validationResult.rom_filename && (
                      <>
                        {' · '}
                        <span className="text-slate-400">ROM: {validationResult.rom_filename}</span>
                      </>
                    )}
                  </div>
                </div>

                {/* Per-chapter results */}
                <div className="space-y-3">
                  {validationResult.chapters.map((chapter) => (
                    <div
                      key={chapter.chapter_num}
                      className={`bg-slate-800 rounded-lg overflow-hidden border ${
                        chapter.passed ? 'border-slate-700' : 'border-red-500/30'
                      }`}
                    >
                      <div className={`px-4 py-2 flex items-center justify-between ${
                        chapter.passed ? 'bg-slate-700' : 'bg-red-500/10'
                      }`}>
                        <div className="flex items-center gap-2">
                          <span className={chapter.passed ? 'text-green-400' : 'text-red-400'}>
                            {chapter.passed ? '✓' : '✗'}
                          </span>
                          <span className="font-semibold text-slate-200">Chapter {chapter.chapter_num}</span>
                          <span className="text-slate-500 text-sm">({chapter.total_screens} screens)</span>
                        </div>
                        <div className="flex gap-3 text-xs">
                          <span className="text-slate-400">
                            Reachability: <span className={
                              chapter.reachability.percent >= 95 ? 'text-green-400' : 'text-amber-400'
                            }>{chapter.reachability.percent.toFixed(1)}%</span>
                          </span>
                          <span className="text-slate-400">
                            Components: <span className={
                              chapter.nav_components === 1 ? 'text-green-400' : 'text-red-400'
                            }>{chapter.nav_components}</span>
                          </span>
                        </div>
                      </div>
                      <div className="px-4 py-3 text-sm">
                        {/* Time period info */}
                        <div className="flex gap-4 mb-2 text-xs text-slate-400">
                          <span>PAST: {chapter.time_period.past_count}</span>
                          <span>PRESENT: {chapter.time_period.present_count}</span>
                          <span>Time Doors: [{chapter.time_period.time_doors.join(', ')}]</span>
                        </div>

                        {/* Errors */}
                        {chapter.errors.length > 0 && (
                          <div className="mt-2">
                            <div className="text-red-400 text-xs font-semibold mb-1">Errors:</div>
                            {chapter.errors.map((err, i) => (
                              <div key={i} className="text-red-300 text-xs ml-2">• {err}</div>
                            ))}
                          </div>
                        )}

                        {/* Warnings */}
                        {chapter.warnings.length > 0 && (
                          <div className="mt-2">
                            <div className="text-amber-400 text-xs font-semibold mb-1">Warnings:</div>
                            {chapter.warnings.map((warn, i) => (
                              <div key={i} className="text-amber-300 text-xs ml-2">• {warn}</div>
                            ))}
                          </div>
                        )}

                        {chapter.errors.length === 0 && chapter.warnings.length === 0 && (
                          <div className="text-green-400 text-xs">No issues found</div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </>
            )}
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
