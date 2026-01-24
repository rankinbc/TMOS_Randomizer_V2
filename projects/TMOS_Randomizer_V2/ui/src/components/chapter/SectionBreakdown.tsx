import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { getSectionColor } from '../../utils/colors';
import { formatSectionLabel } from '../../utils/formatters';
import { useRandomizerStore } from '../../store';

interface SectionBreakdownProps {
  chapter: SimplifiedChapterPlan;
}

export function SectionBreakdown({ chapter }: SectionBreakdownProps) {
  const { selectedSection, setSelectedSection } = useRandomizerStore();

  // Group sections by type
  const sectionsByType = chapter.sections.reduce((acc, section) => {
    const type = section.type;
    if (!acc[type]) acc[type] = [];
    acc[type].push(section);
    return acc;
  }, {} as Record<string, typeof chapter.sections>);

  const typeOrder = ['overworld', 'town', 'dungeon', 'maze', 'boss', 'special'];

  return (
    <div className="p-4">
      <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
        Sections
      </h3>
      <div className="space-y-3">
        {typeOrder.map((type) => {
          const sections = sectionsByType[type];
          if (!sections?.length) return null;

          const totalScreens = sections.reduce((sum, s) => sum + s.screen_count, 0);

          return (
            <div key={type}>
              <div className="flex items-center justify-between mb-1">
                <div className="flex items-center gap-2">
                  <div
                    className="w-2 h-2 rounded-full"
                    style={{ backgroundColor: getSectionColor(type as any, 'fill') }}
                  />
                  <span className="text-sm text-slate-300 capitalize">{type}</span>
                </div>
                <span className="text-xs text-slate-500">{totalScreens} screens</span>
              </div>

              <div className="ml-4 space-y-1">
                {sections.map((section) => (
                  <button
                    key={section.section_id}
                    onClick={() =>
                      setSelectedSection(
                        selectedSection === section.section_id ? null : section.section_id
                      )
                    }
                    className={`w-full text-left px-2 py-1 rounded text-xs transition-colors ${
                      selectedSection === section.section_id
                        ? 'bg-slate-600 text-white'
                        : 'text-slate-400 hover:bg-slate-700 hover:text-slate-300'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span>{formatSectionLabel(section)}</span>
                      <span className="text-slate-500">{section.screen_count}</span>
                    </div>
                    <div className="text-slate-500 capitalize">{section.shape}</div>
                  </button>
                ))}
              </div>
            </div>
          );
        })}
      </div>

      {/* Connection Summary */}
      <div className="mt-6 pt-4 border-t border-slate-700">
        <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-2">
          Connections
        </h3>
        <div className="text-xs text-slate-500">
          {chapter.connections.length} section connections
        </div>
        <div className="mt-2 space-y-1">
          {chapter.connections.slice(0, 5).map((conn, i) => (
            <div key={i} className="text-xs text-slate-400 flex items-center gap-1">
              <span className="truncate">{conn.from_section.split('_')[0]}</span>
              <span className="text-slate-600">{conn.method === 'edge' ? '↔' : '→'}</span>
              <span className="truncate">{conn.to_section.split('_')[0]}</span>
            </div>
          ))}
          {chapter.connections.length > 5 && (
            <div className="text-xs text-slate-600">
              +{chapter.connections.length - 5} more
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
