import { useRandomizerStore } from '../../store';

export function ChapterSelector() {
  const { romLoaded, romChapters, selectedChapter, loadChapterData, chapterLoading } = useRandomizerStore();

  if (!romLoaded || romChapters.length === 0) {
    return (
      <div className="p-4">
        <div className="text-sm text-slate-500">No ROM loaded</div>
      </div>
    );
  }

  return (
    <div className="p-4">
      <h2 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
        Chapters
      </h2>
      <div className="space-y-2">
        {romChapters.map((chapter) => (
          <ChapterCard
            key={chapter.chapter_num}
            chapterNum={chapter.chapter_num}
            screenCount={chapter.screen_count}
            isSelected={selectedChapter === chapter.chapter_num}
            isLoading={chapterLoading && selectedChapter === chapter.chapter_num}
            onClick={() => loadChapterData(chapter.chapter_num)}
          />
        ))}
      </div>
    </div>
  );
}

interface ChapterCardProps {
  chapterNum: number;
  screenCount: number;
  isSelected: boolean;
  isLoading: boolean;
  onClick: () => void;
}

function ChapterCard({ chapterNum, screenCount, isSelected, isLoading, onClick }: ChapterCardProps) {
  return (
    <button
      onClick={onClick}
      disabled={isLoading}
      className={`w-full text-left p-3 rounded-lg transition-all ${
        isSelected
          ? 'bg-blue-600/30 border border-blue-500/50 ring-1 ring-blue-500/30'
          : 'bg-slate-700/50 border border-slate-600/50 hover:bg-slate-700 hover:border-slate-500/50'
      } ${isLoading ? 'opacity-50' : ''}`}
    >
      <div className="flex items-center justify-between">
        <span className={`font-medium ${isSelected ? 'text-blue-300' : 'text-slate-200'}`}>
          Chapter {chapterNum}
        </span>
        <span className="text-xs text-slate-400">
          {isLoading ? 'Loading...' : `${screenCount} screens`}
        </span>
      </div>
    </button>
  );
}
