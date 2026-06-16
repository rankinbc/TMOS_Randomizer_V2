import { useEffect } from 'react';

export interface ContextMenuItem {
  label: string;
  onClick: () => void;
  danger?: boolean;
  disabled?: boolean;
}

interface Props {
  x: number;
  y: number;
  items: ContextMenuItem[];
  onClose: () => void;
}

export function ContextMenu({ x, y, items, onClose }: Props) {
  useEffect(() => {
    const close = () => onClose();
    window.addEventListener('click', close);
    window.addEventListener('contextmenu', close);
    window.addEventListener('scroll', close, true);
    const onEsc = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', onEsc);
    return () => {
      window.removeEventListener('click', close);
      window.removeEventListener('contextmenu', close);
      window.removeEventListener('scroll', close, true);
      window.removeEventListener('keydown', onEsc);
    };
  }, [onClose]);

  return (
    <div
      className="fixed z-[100] min-w-[160px] bg-slate-800 border border-slate-600 rounded shadow-xl py-1 text-sm"
      style={{ top: y, left: x }}
      onClick={(e) => e.stopPropagation()}
    >
      {items.map((it, i) => (
        <button
          key={i}
          disabled={it.disabled}
          onClick={() => { it.onClick(); onClose(); }}
          className={`block w-full text-left px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40 disabled:cursor-not-allowed ${
            it.danger ? 'text-red-400' : 'text-slate-200'
          }`}
        >
          {it.label}
        </button>
      ))}
    </div>
  );
}
