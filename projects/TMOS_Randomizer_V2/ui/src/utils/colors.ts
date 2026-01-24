// Color utilities for section type visualization

import type { SectionType } from '../types/randomizer';

export const SECTION_COLORS: Record<SectionType, {
  fill: string;
  stroke: string;
  text: string;
  bg: string;
  bgLight: string;
}> = {
  overworld: {
    fill: '#22c55e',
    stroke: '#4ade80',
    text: 'text-green-400',
    bg: 'bg-green-600',
    bgLight: 'bg-green-500/20',
  },
  town: {
    fill: '#3b82f6',
    stroke: '#60a5fa',
    text: 'text-blue-400',
    bg: 'bg-blue-600',
    bgLight: 'bg-blue-500/20',
  },
  dungeon: {
    fill: '#a855f7',
    stroke: '#c084fc',
    text: 'text-purple-400',
    bg: 'bg-purple-600',
    bgLight: 'bg-purple-500/20',
  },
  maze: {
    fill: '#f97316',
    stroke: '#fb923c',
    text: 'text-orange-400',
    bg: 'bg-orange-600',
    bgLight: 'bg-orange-500/20',
  },
  boss: {
    fill: '#ef4444',
    stroke: '#f87171',
    text: 'text-red-400',
    bg: 'bg-red-600',
    bgLight: 'bg-red-500/20',
  },
  special: {
    fill: '#6b7280',
    stroke: '#9ca3af',
    text: 'text-gray-400',
    bg: 'bg-gray-600',
    bgLight: 'bg-gray-500/20',
  },
};

export function getSectionColor(
  type: SectionType,
  variant: 'fill' | 'stroke' | 'text' | 'bg' | 'bgLight' = 'fill'
): string {
  return SECTION_COLORS[type]?.[variant] ?? '#666666';
}

export const STATUS_COLORS = {
  pass: {
    text: 'text-green-400',
    bg: 'bg-green-500/20',
    border: 'border-green-500',
  },
  warn: {
    text: 'text-yellow-400',
    bg: 'bg-yellow-500/20',
    border: 'border-yellow-500',
  },
  fail: {
    text: 'text-red-400',
    bg: 'bg-red-500/20',
    border: 'border-red-500',
  },
};

export function getStatusColor(
  status: 'pass' | 'warn' | 'fail',
  variant: 'text' | 'bg' | 'border' = 'text'
): string {
  return STATUS_COLORS[status]?.[variant] ?? 'text-gray-400';
}
