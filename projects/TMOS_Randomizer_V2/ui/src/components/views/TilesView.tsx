import { useState } from 'react';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { getSectionColor } from '../../utils/colors';
import { useRandomizerStore } from '../../store';

interface TilesViewProps {
  chapter: SimplifiedChapterPlan;
}

export function TilesView({ chapter }: TilesViewProps) {
  const { selectedSection, setSelectedSection } = useRandomizerStore();
  const [viewMode, setViewMode] = useState<'overview' | 'detail'>('overview');

  const currentSection = chapter.sections.find((s) => s.section_id === selectedSection) || chapter.sections[0];

  return (
    <div className="h-full flex">
      {/* Section List */}
      <div className="w-48 border-r border-slate-700 overflow-y-auto bg-slate-800/50">
        <div className="p-3 border-b border-slate-700">
          <h3 className="text-sm font-semibold text-slate-400">Sections</h3>
        </div>
        <div className="p-2 space-y-1">
          {chapter.sections.map((section) => (
            <button
              key={section.section_id}
              onClick={() => setSelectedSection(section.section_id)}
              className={`w-full text-left px-2 py-1.5 rounded text-sm transition-colors ${
                currentSection?.section_id === section.section_id
                  ? 'bg-slate-600 text-white'
                  : 'text-slate-400 hover:bg-slate-700 hover:text-slate-300'
              }`}
            >
              <div className="flex items-center gap-2">
                <div
                  className="w-2 h-2 rounded-full"
                  style={{ backgroundColor: getSectionColor(section.type as any, 'fill') }}
                />
                <span className="capitalize">{section.section_id.replace(/_/g, ' ')}</span>
              </div>
              <div className="text-xs text-slate-500 ml-4">
                {section.screen_count} screens
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="flex-shrink-0 p-4 border-b border-slate-700 flex items-center justify-between">
          <div>
            <h2 className="text-lg font-semibold text-slate-200">
              {currentSection ? currentSection.section_id.replace(/_/g, ' ') : 'Select a section'}
            </h2>
            {currentSection && (
              <p className="text-sm text-slate-400">
                Type: {currentSection.type} | Shape: {currentSection.shape} | {currentSection.screen_count} screens
              </p>
            )}
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setViewMode('overview')}
              className={`px-3 py-1 text-sm rounded ${
                viewMode === 'overview' ? 'bg-slate-600 text-white' : 'text-slate-400 hover:text-white'
              }`}
            >
              Overview
            </button>
            <button
              onClick={() => setViewMode('detail')}
              className={`px-3 py-1 text-sm rounded ${
                viewMode === 'detail' ? 'bg-slate-600 text-white' : 'text-slate-400 hover:text-white'
              }`}
            >
              Detail
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-auto p-4">
          {viewMode === 'overview' ? (
            <SectionOverview chapter={chapter} currentSection={currentSection} />
          ) : (
            <SectionDetail section={currentSection} />
          )}
        </div>
      </div>
    </div>
  );
}

interface SectionOverviewProps {
  chapter: SimplifiedChapterPlan;
  currentSection: SimplifiedChapterPlan['sections'][0] | undefined;
}

function SectionOverview({ chapter, currentSection }: SectionOverviewProps) {
  return (
    <div className="space-y-6">
      {/* Chapter Stats */}
      <div>
        <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
          Chapter {chapter.chapter_num} Overview
        </h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <StatCard label="Total Screens" value={chapter.total_screens} color="blue" />
          <StatCard label="Sections" value={chapter.sections.length} color="purple" />
          <StatCard label="Connections" value={chapter.connections.length} color="green" />
          <StatCard
            label="Towns"
            value={chapter.sections.filter((s) => s.type === 'town').length}
            color="orange"
          />
        </div>
      </div>

      {/* Section Breakdown */}
      <div>
        <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
          Section Breakdown
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {chapter.sections.map((section) => (
            <div
              key={section.section_id}
              className={`p-4 rounded-lg border transition-colors ${
                currentSection?.section_id === section.section_id
                  ? 'border-blue-500 bg-blue-500/10'
                  : 'border-slate-700 bg-slate-800/50'
              }`}
            >
              <div className="flex items-center gap-2 mb-2">
                <div
                  className="w-3 h-3 rounded-full"
                  style={{ backgroundColor: getSectionColor(section.type as any, 'fill') }}
                />
                <span className="text-sm font-medium text-slate-200 capitalize">
                  {section.section_id.replace(/_/g, ' ')}
                </span>
              </div>
              <div className="grid grid-cols-2 gap-2 text-xs">
                <div className="text-slate-400">
                  <span className="text-slate-500">Type: </span>
                  {section.type}
                </div>
                <div className="text-slate-400">
                  <span className="text-slate-500">Shape: </span>
                  {section.shape}
                </div>
                <div className="text-slate-400 col-span-2">
                  <span className="text-slate-500">Screens: </span>
                  {section.screen_count}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Visual Screen Preview */}
      <div>
        <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
          Screen Distribution
        </h3>
        <div className="flex flex-wrap gap-1">
          {chapter.sections.map((section) =>
            Array(section.screen_count)
              .fill(0)
              .map((_, i) => (
                <div
                  key={`${section.section_id}-${i}`}
                  className="w-4 h-4 rounded-sm"
                  style={{ backgroundColor: getSectionColor(section.type as any, 'fill') }}
                  title={`${section.section_id} screen ${i + 1}`}
                />
              ))
          )}
        </div>
        <div className="flex items-center gap-4 mt-3 flex-wrap">
          {['overworld', 'town', 'dungeon', 'maze', 'boss'].map((type) => (
            <div key={type} className="flex items-center gap-1.5">
              <div
                className="w-3 h-3 rounded"
                style={{ backgroundColor: getSectionColor(type as any, 'fill') }}
              />
              <span className="text-xs text-slate-400 capitalize">{type}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

interface SectionDetailProps {
  section: SimplifiedChapterPlan['sections'][0] | undefined;
}

function SectionDetail({ section }: SectionDetailProps) {
  if (!section) {
    return (
      <div className="flex items-center justify-center h-full text-slate-500">
        Select a section to view details
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Section Info */}
      <div className="bg-slate-800 rounded-lg p-4">
        <h3 className="text-lg font-semibold text-slate-200 mb-4 capitalize">
          {section.section_id.replace(/_/g, ' ')}
        </h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <div className="text-xs text-slate-500 uppercase mb-1">Type</div>
            <div className="flex items-center gap-2">
              <div
                className="w-3 h-3 rounded-full"
                style={{ backgroundColor: getSectionColor(section.type as any, 'fill') }}
              />
              <span className="text-slate-200 capitalize">{section.type}</span>
            </div>
          </div>
          <div>
            <div className="text-xs text-slate-500 uppercase mb-1">Shape</div>
            <span className="text-slate-200 capitalize">{section.shape}</span>
          </div>
          <div>
            <div className="text-xs text-slate-500 uppercase mb-1">Screen Count</div>
            <span className="text-slate-200">{section.screen_count}</span>
          </div>
          <div>
            <div className="text-xs text-slate-500 uppercase mb-1">Section ID</div>
            <span className="text-slate-200 font-mono text-sm">{section.section_id}</span>
          </div>
        </div>
      </div>

      {/* Placeholder for detailed screen data */}
      <div className="bg-slate-800/50 border border-slate-700 rounded-lg p-6 text-center">
        <div className="text-slate-400 mb-2">
          Detailed screen data not available in preview mode
        </div>
        <p className="text-xs text-slate-500">
          Connect to the API and generate a full plan to see individual screen data, tile assignments, and navigation details.
        </p>
      </div>

      {/* Visual placeholder grid */}
      <div>
        <h4 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
          Screen Layout Preview
        </h4>
        <div className="inline-grid gap-1" style={{ gridTemplateColumns: `repeat(${Math.min(8, section.screen_count)}, 48px)` }}>
          {Array(section.screen_count)
            .fill(0)
            .map((_, i) => (
              <div
                key={i}
                className="w-12 h-12 rounded flex items-center justify-center text-xs font-mono bg-slate-700 text-slate-400"
              >
                {i + 1}
              </div>
            ))}
        </div>
      </div>
    </div>
  );
}

function StatCard({ label, value, color }: { label: string; value: number; color: string }) {
  const colorClasses: Record<string, string> = {
    blue: 'text-blue-400',
    purple: 'text-purple-400',
    green: 'text-green-400',
    orange: 'text-orange-400',
  };

  return (
    <div className="bg-slate-800 rounded-lg p-3">
      <div className={`text-2xl font-bold ${colorClasses[color]}`}>{value}</div>
      <div className="text-xs text-slate-500">{label}</div>
    </div>
  );
}
