import { useState, useRef, useEffect, useCallback, type ReactNode } from 'react';
import { createPortal } from 'react-dom';

interface TooltipProps {
  children: ReactNode;
  content: ReactNode;
  delay?: number;
  position?: 'top' | 'bottom' | 'left' | 'right';
  disabled?: boolean;
}

interface Position {
  top: number;
  left: number;
}

export function Tooltip({
  children,
  content,
  delay = 200,
  position = 'top',
  disabled = false,
}: TooltipProps) {
  const [isVisible, setIsVisible] = useState(false);
  const [pos, setPos] = useState<Position>({ top: 0, left: 0 });
  const triggerRef = useRef<HTMLDivElement>(null);
  const tooltipRef = useRef<HTMLDivElement>(null);
  const timeoutRef = useRef<number | null>(null);

  const calculatePosition = useCallback(() => {
    if (!triggerRef.current || !tooltipRef.current) return;

    const triggerRect = triggerRef.current.getBoundingClientRect();
    const tooltipRect = tooltipRef.current.getBoundingClientRect();
    const gap = 8;

    let top = 0;
    let left = 0;

    switch (position) {
      case 'top':
        top = triggerRect.top - tooltipRect.height - gap;
        left = triggerRect.left + (triggerRect.width - tooltipRect.width) / 2;
        break;
      case 'bottom':
        top = triggerRect.bottom + gap;
        left = triggerRect.left + (triggerRect.width - tooltipRect.width) / 2;
        break;
      case 'left':
        top = triggerRect.top + (triggerRect.height - tooltipRect.height) / 2;
        left = triggerRect.left - tooltipRect.width - gap;
        break;
      case 'right':
        top = triggerRect.top + (triggerRect.height - tooltipRect.height) / 2;
        left = triggerRect.right + gap;
        break;
    }

    // Keep tooltip within viewport
    const padding = 8;
    if (left < padding) left = padding;
    if (left + tooltipRect.width > window.innerWidth - padding) {
      left = window.innerWidth - tooltipRect.width - padding;
    }
    if (top < padding) top = padding;
    if (top + tooltipRect.height > window.innerHeight - padding) {
      top = window.innerHeight - tooltipRect.height - padding;
    }

    setPos({ top, left });
  }, [position]);

  const handleMouseEnter = useCallback(() => {
    if (disabled) return;
    timeoutRef.current = window.setTimeout(() => {
      setIsVisible(true);
    }, delay);
  }, [delay, disabled]);

  const handleMouseLeave = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
    setIsVisible(false);
  }, []);

  useEffect(() => {
    if (isVisible) {
      calculatePosition();
    }
  }, [isVisible, calculatePosition]);

  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return (
    <>
      <div
        ref={triggerRef}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        className="inline-block"
      >
        {children}
      </div>
      {isVisible &&
        createPortal(
          <div
            ref={tooltipRef}
            className="fixed z-[9999] px-3 py-2 text-sm bg-slate-800 border border-slate-600 rounded-lg shadow-xl text-slate-200 max-w-xs pointer-events-none"
            style={{ top: pos.top, left: pos.left }}
          >
            {content}
          </div>,
          document.body
        )}
    </>
  );
}

// Hover card variant for richer content
interface HoverCardProps {
  children: ReactNode;
  content: ReactNode;
  delay?: number;
  disabled?: boolean;
  className?: string;
}

export function HoverCard({
  children,
  content,
  delay = 300,
  disabled = false,
  className = '',
}: HoverCardProps) {
  const [isVisible, setIsVisible] = useState(false);
  const [pos, setPos] = useState<Position>({ top: 0, left: 0 });
  const triggerRef = useRef<HTMLDivElement>(null);
  const cardRef = useRef<HTMLDivElement>(null);
  const timeoutRef = useRef<number | null>(null);

  const calculatePosition = useCallback(() => {
    if (!triggerRef.current || !cardRef.current) return;

    const triggerRect = triggerRef.current.getBoundingClientRect();
    const cardRect = cardRef.current.getBoundingClientRect();
    const gap = 8;

    // Default to bottom-right of trigger
    let top = triggerRect.bottom + gap;
    let left = triggerRect.left;

    // Keep card within viewport
    const padding = 16;
    if (left + cardRect.width > window.innerWidth - padding) {
      left = window.innerWidth - cardRect.width - padding;
    }
    if (top + cardRect.height > window.innerHeight - padding) {
      // Show above trigger instead
      top = triggerRect.top - cardRect.height - gap;
    }
    if (left < padding) left = padding;
    if (top < padding) top = padding;

    setPos({ top, left });
  }, []);

  const handleMouseEnter = useCallback(() => {
    if (disabled) return;
    timeoutRef.current = window.setTimeout(() => {
      setIsVisible(true);
    }, delay);
  }, [delay, disabled]);

  const handleMouseLeave = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
    setIsVisible(false);
  }, []);

  useEffect(() => {
    if (isVisible) {
      calculatePosition();
    }
  }, [isVisible, calculatePosition]);

  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return (
    <>
      <div
        ref={triggerRef}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        className="inline-block"
      >
        {children}
      </div>
      {isVisible &&
        createPortal(
          <div
            ref={cardRef}
            onMouseEnter={() => {
              if (timeoutRef.current) clearTimeout(timeoutRef.current);
            }}
            onMouseLeave={handleMouseLeave}
            className={`fixed z-[9999] bg-slate-800 border border-slate-600 rounded-lg shadow-xl pointer-events-auto ${className}`}
            style={{ top: pos.top, left: pos.left }}
          >
            {content}
          </div>,
          document.body
        )}
    </>
  );
}
