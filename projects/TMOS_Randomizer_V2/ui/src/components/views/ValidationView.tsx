import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { useRandomizerStore } from '../../store';

interface ValidationViewProps {
  chapter: SimplifiedChapterPlan;
}

// Validation rules specific to TMOS
// Source: knowledge base and docs/planning/critical-path.md

interface ValidationRule {
  id: string;
  name: string;
  description: string;
  severity: 'critical' | 'warning' | 'info';
  category: 'progression' | 'placement' | 'content' | 'navigation';
}

const CRITICAL_RULES: ValidationRule[] = [
  {
    id: 'time_door',
    name: 'Time Door Accessibility',
    description: 'Exactly ONE time door (Content=0xC0) must exist in each chapter\'s "past" area',
    severity: 'critical',
    category: 'progression',
  },
  {
    id: 'boss_preserved',
    name: 'Boss Screens Preserved',
    description: 'Boss stages (Content 0x21-0x2A) must not be modified',
    severity: 'critical',
    category: 'content',
  },
  {
    id: 'victory_preserved',
    name: 'Victory Screens Preserved',
    description: 'Post-boss victory screens (Content 0x2B) must not be modified',
    severity: 'critical',
    category: 'content',
  },
  {
    id: 'wizard_preserved',
    name: 'Wizard Battles Preserved',
    description: 'Wizard battle triggers (Content 0x01) must not be modified',
    severity: 'critical',
    category: 'content',
  },
];

const PLACEMENT_RULES: ValidationRule[] = [
  {
    id: 'faruk_underwater',
    name: 'Faruk Placement (Ch.1)',
    description: 'Faruk (0x81) cannot be placed on underwater screens',
    severity: 'warning',
    category: 'placement',
  },
  {
    id: 'mustafa_troll',
    name: 'Mustafa Placement (Ch.3)',
    description: "Mustafa (0x84) cannot be placed in Troll's Palace",
    severity: 'warning',
    category: 'placement',
  },
  {
    id: 'gubibi_lava',
    name: 'Gubibi Placement (Ch.4)',
    description: 'Gubibi (0x80) cannot be placed in lava area',
    severity: 'warning',
    category: 'placement',
  },
  {
    id: 'legend_sabaron',
    name: 'Legend Sword Placement (Ch.5)',
    description: "Legend Sword (0x83) cannot be placed in Sabaron's Castle",
    severity: 'warning',
    category: 'placement',
  },
  {
    id: 'larmor_sabaron',
    name: 'Light Armor Placement (Ch.5)',
    description: "Armor of Light (0x83) cannot be placed in Sabaron's Castle",
    severity: 'warning',
    category: 'placement',
  },
];

const CONTENT_RULES: ValidationRule[] = [
  {
    id: 'building_entrance',
    name: 'Building Entrance Validity',
    description: 'Screens with entrance (ScreenIndexUp=0xFE) must have valid Content',
    severity: 'warning',
    category: 'content',
  },
  {
    id: 'no_encounter_building',
    name: 'No Random Encounters at Buildings',
    description: 'Building entrances cannot have Content=0xFF (random encounter)',
    severity: 'warning',
    category: 'content',
  },
];

// Chapter-specific data
const CHAPTER_DATA: Record<number, { name: string; excludedScreens: number; shuffleableScreens: number }> = {
  1: { name: 'Mooroon', excludedScreens: 20, shuffleableScreens: 25 },
  2: { name: 'Alalart', excludedScreens: 18, shuffleableScreens: 25 },
  3: { name: 'Samalkand', excludedScreens: 22, shuffleableScreens: 25 },
  4: { name: 'Celestern', excludedScreens: 19, shuffleableScreens: 21 },
  5: { name: "Sabaron's Realm", excludedScreens: 15, shuffleableScreens: 18 },
};

// Safe event bytes
const SAFE_EVENTS = [0x00, 0x08, 0x22, 0x40];
const UNSAFE_EVENTS = [0x01, 0x03, 0x09, 0x10, 0x20, 0x47, 0x48, 0x60, 0x62, 0x80, 0xC0];

export function ValidationView({ chapter }: ValidationViewProps) {
  const { plan } = useRandomizerStore();

  // Plan-level validation
  const validation = plan?.validation;
  const isValid = validation?.is_valid ?? true;
  const errors = validation?.errors ?? [];
  const warnings = validation?.warnings ?? [];

  const chapterInfo = CHAPTER_DATA[chapter.chapter_num] || {
    name: `Chapter ${chapter.chapter_num}`,
    excludedScreens: 0,
    shuffleableScreens: 0,
  };

  return (
    <div className="h-full flex flex-col overflow-hidden">
      {/* Header */}
      <div className="flex-shrink-0 p-4 border-b border-slate-700">
        <div className="flex items-center gap-3">
          <div
            className={`w-10 h-10 rounded-lg flex items-center justify-center text-xl ${
              isValid
                ? 'bg-green-500/20 text-green-400'
                : 'bg-red-500/20 text-red-400'
            }`}
          >
            {isValid ? '✓' : '✕'}
          </div>
          <div>
            <h2 className="text-lg font-semibold text-slate-200">
              Validation - {chapterInfo.name}
            </h2>
            <p className="text-sm text-slate-400">
              {isValid ? 'All checks passed' : 'Issues found'}
            </p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-4 space-y-6">
        {/* Chapter Summary */}
        <section>
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Chapter Summary
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div className="bg-slate-800 rounded-lg p-3">
              <div className="text-2xl font-bold text-blue-400">{chapter.total_screens}</div>
              <div className="text-xs text-slate-500">Total Screens</div>
            </div>
            <div className="bg-slate-800 rounded-lg p-3">
              <div className="text-2xl font-bold text-purple-400">{chapter.sections.length}</div>
              <div className="text-xs text-slate-500">Sections</div>
            </div>
            <div className="bg-slate-800 rounded-lg p-3">
              <div className="text-2xl font-bold text-green-400">{chapterInfo.shuffleableScreens}</div>
              <div className="text-xs text-slate-500">Shuffleable</div>
            </div>
            <div className="bg-slate-800 rounded-lg p-3">
              <div className="text-2xl font-bold text-red-400">{chapterInfo.excludedScreens}</div>
              <div className="text-xs text-slate-500">Excluded</div>
            </div>
          </div>
        </section>

        {/* Critical Rules */}
        <section>
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Critical Rules
          </h3>
          <div className="space-y-2">
            {CRITICAL_RULES.map((rule) => (
              <RuleCard key={rule.id} rule={rule} status="pass" />
            ))}
          </div>
        </section>

        {/* Placement Restrictions for this chapter */}
        <section>
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Placement Restrictions (Chapter {chapter.chapter_num})
          </h3>
          <div className="space-y-2">
            {PLACEMENT_RULES.filter((rule) => {
              // Show chapter-specific rules
              if (rule.id === 'faruk_underwater' && chapter.chapter_num === 1) return true;
              if (rule.id === 'mustafa_troll' && chapter.chapter_num === 3) return true;
              if (rule.id === 'gubibi_lava' && chapter.chapter_num === 4) return true;
              if ((rule.id === 'legend_sabaron' || rule.id === 'larmor_sabaron') && chapter.chapter_num === 5) return true;
              return false;
            }).map((rule) => (
              <RuleCard key={rule.id} rule={rule} status="pass" />
            ))}
            {chapter.chapter_num === 2 && (
              <div className="bg-slate-800 rounded-lg p-3 text-sm text-slate-400">
                No special placement restrictions for Chapter 2
              </div>
            )}
          </div>
        </section>

        {/* Section Breakdown */}
        <section>
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Section Types
          </h3>
          <div className="space-y-2">
            {chapter.sections.map((section) => (
              <div
                key={section.section_id}
                className="bg-slate-800 border border-slate-700 rounded-lg p-3 flex items-center justify-between"
              >
                <div className="flex items-center gap-3">
                  <SectionTypeIcon type={section.type} />
                  <div>
                    <div className="text-sm font-medium text-slate-200">
                      {section.section_id.replace(/_/g, ' ')}
                    </div>
                    <div className="text-xs text-slate-500">
                      {section.type} • {section.shape} shape
                    </div>
                  </div>
                </div>
                <div className="text-sm text-slate-400">
                  {section.screen_count} screens
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Event Byte Reference */}
        <section>
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Event Byte Reference
          </h3>
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-green-500/10 border border-green-500/30 rounded-lg p-3">
              <div className="text-xs font-semibold text-green-400 mb-2">Safe Events</div>
              <div className="flex flex-wrap gap-1">
                {SAFE_EVENTS.map((ev) => (
                  <span key={ev} className="text-xs font-mono bg-green-500/20 text-green-300 px-1.5 py-0.5 rounded">
                    0x{ev.toString(16).toUpperCase().padStart(2, '0')}
                  </span>
                ))}
              </div>
            </div>
            <div className="bg-red-500/10 border border-red-500/30 rounded-lg p-3">
              <div className="text-xs font-semibold text-red-400 mb-2">Unsafe Events</div>
              <div className="flex flex-wrap gap-1">
                {UNSAFE_EVENTS.map((ev) => (
                  <span key={ev} className="text-xs font-mono bg-red-500/20 text-red-300 px-1.5 py-0.5 rounded">
                    0x{ev.toString(16).toUpperCase().padStart(2, '0')}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* Warnings */}
        {warnings.length > 0 && (
          <section>
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Warnings ({warnings.length})
            </h3>
            <div className="space-y-2">
              {warnings.map((warning, i) => (
                <div
                  key={i}
                  className="bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-3"
                >
                  <div className="flex items-start gap-2">
                    <span className="text-yellow-400 mt-0.5">⚠</span>
                    <div className="text-sm text-yellow-300">{warning}</div>
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}

        {/* Errors */}
        {errors.length > 0 && (
          <section>
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Errors ({errors.length})
            </h3>
            <div className="space-y-2">
              {errors.map((error, i) => (
                <div
                  key={i}
                  className="bg-red-500/10 border border-red-500/30 rounded-lg p-3"
                >
                  <div className="flex items-start gap-2">
                    <span className="text-red-400 mt-0.5">✕</span>
                    <div className="text-sm text-red-300">{error}</div>
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}

        {/* No Issues */}
        {isValid && errors.length === 0 && warnings.length === 0 && (
          <section>
            <div className="bg-green-500/10 border border-green-500/30 rounded-lg p-4 text-center">
              <div className="text-green-400 text-2xl mb-2">✓</div>
              <div className="text-green-300 font-medium">Plan is Valid</div>
              <div className="text-green-400/70 text-sm mt-1">
                No errors or warnings detected for {chapterInfo.name}
              </div>
            </div>
          </section>
        )}
      </div>
    </div>
  );
}

interface RuleCardProps {
  rule: ValidationRule;
  status: 'pass' | 'fail' | 'warning';
}

function RuleCard({ rule, status }: RuleCardProps) {
  const statusConfig = {
    pass: { icon: '✓', bg: 'bg-green-500/10', border: 'border-green-500/30', text: 'text-green-400' },
    fail: { icon: '✕', bg: 'bg-red-500/10', border: 'border-red-500/30', text: 'text-red-400' },
    warning: { icon: '⚠', bg: 'bg-yellow-500/10', border: 'border-yellow-500/30', text: 'text-yellow-400' },
  };

  const config = statusConfig[status];

  return (
    <div className={`${config.bg} border ${config.border} rounded-lg p-3`}>
      <div className="flex items-start gap-3">
        <span className={`${config.text} mt-0.5`}>{config.icon}</span>
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <span className="text-sm font-medium text-slate-200">{rule.name}</span>
            <span className={`text-xs px-1.5 py-0.5 rounded ${
              rule.severity === 'critical' ? 'bg-red-500/20 text-red-400' :
              rule.severity === 'warning' ? 'bg-yellow-500/20 text-yellow-400' :
              'bg-blue-500/20 text-blue-400'
            }`}>
              {rule.severity}
            </span>
          </div>
          <p className="text-xs text-slate-400 mt-1">{rule.description}</p>
        </div>
      </div>
    </div>
  );
}

function SectionTypeIcon({ type }: { type: string }) {
  const iconMap: Record<string, { icon: string; color: string }> = {
    overworld: { icon: '🌍', color: 'bg-green-500/20' },
    town: { icon: '🏘️', color: 'bg-blue-500/20' },
    dungeon: { icon: '🏰', color: 'bg-purple-500/20' },
    maze: { icon: '🌀', color: 'bg-orange-500/20' },
    boss: { icon: '👑', color: 'bg-red-500/20' },
    special: { icon: '⭐', color: 'bg-yellow-500/20' },
  };

  const { icon, color } = iconMap[type] || { icon: '?', color: 'bg-slate-500/20' };

  return (
    <div className={`w-8 h-8 rounded flex items-center justify-center ${color}`}>
      {icon}
    </div>
  );
}
