// Sample randomization plan for UI development and testing

import type { RandomizationPlan, SimplifiedChapterPlan } from '../types/randomizer';

function createChapter1(): SimplifiedChapterPlan {
  return {
    chapter_num: 1,
    total_screens: 131,
    sections: [
      {
        section_id: 'overworld_a',
        type: 'overworld',
        screen_count: 28,
        shape: 'blob',
      },
      {
        section_id: 'town_1',
        type: 'town',
        screen_count: 6,
        shape: 'grid',
      },
      {
        section_id: 'overworld_b',
        type: 'overworld',
        screen_count: 18,
        shape: 'branching',
      },
      {
        section_id: 'town_2',
        type: 'town',
        screen_count: 5,
        shape: 'linear',
      },
      {
        section_id: 'maze',
        type: 'maze',
        screen_count: 12,
        shape: 'preserved',
      },
      {
        section_id: 'dungeon',
        type: 'dungeon',
        screen_count: 35,
        shape: 'branching',
      },
      {
        section_id: 'boss',
        type: 'boss',
        screen_count: 2,
        shape: 'preserved',
      },
    ],
    connections: [
      { from_section: 'town_1', to_section: 'overworld_a', method: 'edge', screen: 99 },
      { from_section: 'overworld_a', to_section: 'overworld_b', method: 'edge', screen: 7 },
      { from_section: 'overworld_b', to_section: 'town_2', method: 'edge', screen: 32 },
      { from_section: 'overworld_b', to_section: 'maze', method: 'cave', screen: 36 },
      { from_section: 'maze', to_section: 'dungeon', method: 'stairway', screen: 57 },
      { from_section: 'dungeon', to_section: 'boss', method: 'door', screen: 92 },
    ],
  };
}

function createChapter2(): SimplifiedChapterPlan {
  return {
    chapter_num: 2,
    total_screens: 137,
    sections: [
      {
        section_id: 'overworld_desert',
        type: 'overworld',
        screen_count: 42,
        shape: 'blob',
      },
      {
        section_id: 'town_oasis',
        type: 'town',
        screen_count: 8,
        shape: 'grid',
      },
      {
        section_id: 'dungeon_pyramid',
        type: 'dungeon',
        screen_count: 40,
        shape: 'branching',
      },
    ],
    connections: [
      { from_section: 'overworld_desert', to_section: 'town_oasis', method: 'edge', screen: 20 },
      { from_section: 'overworld_desert', to_section: 'dungeon_pyramid', method: 'door', screen: 41 },
    ],
  };
}

function createSimpleChapter(num: number, count: number): SimplifiedChapterPlan {
  return {
    chapter_num: num,
    total_screens: count,
    sections: [
      {
        section_id: `overworld_${num}`,
        type: 'overworld',
        screen_count: Math.floor(count * 0.4),
        shape: 'blob',
      },
      {
        section_id: `town_${num}`,
        type: 'town',
        screen_count: Math.floor(count * 0.1),
        shape: 'grid',
      },
      {
        section_id: `dungeon_${num}`,
        type: 'dungeon',
        screen_count: Math.floor(count * 0.35),
        shape: 'branching',
      },
      {
        section_id: `maze_${num}`,
        type: 'maze',
        screen_count: Math.floor(count * 0.1),
        shape: 'linear',
      },
      {
        section_id: `boss_${num}`,
        type: 'boss',
        screen_count: 2,
        shape: 'preserved',
      },
    ],
    connections: [
      { from_section: `overworld_${num}`, to_section: `town_${num}`, method: 'edge' },
      { from_section: `overworld_${num}`, to_section: `maze_${num}`, method: 'cave' },
      { from_section: `maze_${num}`, to_section: `dungeon_${num}`, method: 'stairway' },
      { from_section: `dungeon_${num}`, to_section: `boss_${num}`, method: 'door' },
    ],
  };
}

export const samplePlan: RandomizationPlan = {
  meta: {
    seed: 1234567890,
    generated_at: new Date().toISOString(),
    version: '2.0.0',
    preset: 'standard',
  },
  chapters: [
    createChapter1(),
    createChapter2(),
    createSimpleChapter(3, 153),
    createSimpleChapter(4, 164),
    createSimpleChapter(5, 154),
  ],
  validation: {
    is_valid: true,
    errors: [],
    warnings: [],
  },
};
