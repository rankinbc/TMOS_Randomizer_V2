// Shared screen enum tables.
//
// These live in their own module (not in ScreenDetailPanel) to avoid a
// circular import: ScreenDetailPanel imports the ScreenEditorModal component,
// and ScreenEditorModal needs these enums. When they were defined in
// ScreenDetailPanel, ScreenEditorModal's top-level use of EVENT_TYPES ran
// before ScreenDetailPanel finished initializing, throwing
// "Cannot access 'EVENT_TYPES' before initialization" (temporal dead zone).

// Content type descriptions from knowledge/enums/content-types.md
export const CONTENT_TYPES: Record<number, { name: string; category: string; description?: string }> = {
  0x00: { name: 'Empty', category: 'special', description: 'Normal screen, no building' },
  0x01: { name: 'Wizard Battle', category: 'battle', description: 'Triggers wizard battle on entry' },
  0x1D: { name: 'Frozen Palace', category: 'special', description: 'Frozen Palace area' },
  0x20: { name: 'First Mosque', category: 'mosque', description: '"Will you defeat Sabaron?" dialog' },
  // Boss demons
  0x21: { name: 'Gilga Phase 1', category: 'boss', description: 'Chapter 1 boss - first phase' },
  0x22: { name: 'Gilga Phase 2', category: 'boss', description: 'Chapter 1 boss - second phase' },
  0x23: { name: 'Curly Phase 1', category: 'boss', description: 'Chapter 2 boss - first phase' },
  0x24: { name: 'Curly Phase 2', category: 'boss', description: 'Chapter 2 boss - second phase' },
  0x25: { name: 'Troll Phase 1', category: 'boss', description: 'Chapter 3 boss - first phase' },
  0x26: { name: 'Troll Phase 2', category: 'boss', description: 'Chapter 3 boss - second phase' },
  0x27: { name: 'Salamander Phase 1', category: 'boss', description: 'Chapter 4 boss - first phase' },
  0x28: { name: 'Salamander Phase 2', category: 'boss', description: 'Chapter 4 boss - second phase' },
  0x29: { name: 'GoraGora Phase 1', category: 'boss', description: 'Chapter 5 boss - first phase' },
  0x2A: { name: 'GoraGora Phase 2', category: 'boss', description: 'Chapter 5 boss - second phase' },
  0x2B: { name: 'Princess Victory', category: 'special', description: 'Post-boss victory screen' },
  // Universities
  0x40: { name: 'University', category: 'university', description: 'Magic training (Cygnus)' },
  0x41: { name: 'University', category: 'university', description: 'Magic training (World 2)' },
  0x42: { name: 'University', category: 'university', description: 'Magic training (World 3)' },
  0x43: { name: 'University', category: 'university', description: 'Magic training (World 4)' },
  0x44: { name: 'University', category: 'university', description: 'Magic training (World 5)' },
  0x50: { name: 'University Monecom', category: 'university' },
  0x55: { name: 'University Alalart', category: 'university' },
  // Shops — per-Content-byte stock lists were unverified guesses. Real shop
  // inventory lives in a Bank 2 bytecode interpreter that has not been decoded.
  // See TMOS_AI/docs/human/items-economy-re-answers.md.
  0x60: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x61: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x62: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x63: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x64: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x65: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x66: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x75: { name: 'Magic Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x76: { name: 'Magic Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x77: { name: 'Magic Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x78: { name: 'Formation Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x79: { name: 'Mixed Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x7B: { name: 'Unused Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x7C: { name: 'Unused Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x7D: { name: 'Unused Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  // Services
  0x7E: { name: 'Mosque', category: 'mosque', description: 'Class change, save, revive' },
  0x7F: { name: 'Trooper Hire', category: 'service', description: 'Hire trooper soldiers' },
  // Hotels
  0xA0: { name: 'Hotel (10 Rupias)', category: 'hotel' },
  0xA1: { name: 'Hotel', category: 'hotel' },
  0xA2: { name: 'Hotel', category: 'hotel' },
  0xA3: { name: 'Hotel', category: 'hotel' },
  0xB0: { name: 'Hotel (169 Rupias)', category: 'hotel', description: 'Expensive hotel' },
  // Special locations
  0xBC: { name: 'Rupia Seed Plant', category: 'special', description: 'Plant rupia seed location' },
  0xBD: { name: 'Rupia Tree', category: 'special', description: 'Grown rupia tree' },
  0xBE: { name: 'Casino', category: 'special', description: 'Gambling mini-games' },
  0xC0: { name: 'Time Door (Enter)', category: 'time-door', description: 'Time travel entrance' },
  0xC7: { name: 'Time Door (Exit)', category: 'time-door', description: 'Time travel exit' },
  0xD7: { name: 'Time Door (Exit)', category: 'time-door', description: 'Time travel exit variant' },
  0xFF: { name: 'Random Battle', category: 'battle', description: 'Random encounter area' },
};

// Chapter-specific NPCs (0x80-0x8F range)
export const CHAPTER_NPCS: Record<number, Record<number, { name: string; description?: string }>> = {
  1: {
    0x80: { name: 'Jad', description: 'NPC' },
    0x81: { name: 'Faruk', description: 'Genie ally - attacks 2x per turn' },
    0x82: { name: 'Dogos', description: 'NPC' },
    0x83: { name: 'Kebabu', description: 'Harpy ally - enables Ring+Shield' },
    0x84: { name: 'Aqua Palace', description: 'Palace entrance' },
    0x85: { name: 'Wiseman Monecom', description: 'Money spell teacher' },
    0x86: { name: 'Achelato Princess', description: 'Princess NPC' },
    0x87: { name: 'Sabaron', description: 'Sabaron appearance' },
    0x88: { name: '50 Rupias', description: 'Money reward' },
    0x89: { name: 'Gun Meca', description: 'Robot NPC' },
    0x90: { name: 'Newborn Cimaron Tree', description: 'Cimaron tree' },
  },
  2: {
    0x80: { name: 'Gun Meca', description: 'Robot ally - translator' },
    0x81: { name: 'Lah', description: 'NPC' },
    0x82: { name: 'Supica', description: 'Flying monkey ally - maze guide' },
    0x83: { name: 'Epin', description: '700yr guardian ally - whistle' },
    0x84: { name: 'Wiseman Raincom', description: 'Rain spell teacher' },
    0x87: { name: 'Princess', description: 'Princess NPC' },
    0x8D: { name: 'Rupia Seed Plant', description: 'Plant location' },
  },
  3: {
    0x80: { name: 'Newborn Cimaron Tree', description: 'Baby cimaron' },
    0x81: { name: 'Cimaron Tree', description: 'Grown cimaron - gives Pukin' },
    0x82: { name: 'Supapa', description: 'NPC' },
    0x84: { name: 'Mustafa', description: 'Crystal ball ally - stingy' },
    0x85: { name: 'Frozen Palace 2', description: 'Palace area' },
    0x87: { name: 'Wiseman Spricom', description: 'Sprite spell teacher' },
  },
  4: {
    0x80: { name: 'Gubibi', description: 'Bottle magician ally - gives Holy Robe' },
    0x81: { name: 'Rainy', description: 'Rain Shrimp ally - drum' },
    0x82: { name: 'Yufla Palace', description: 'Palace entrance' },
    0x83: { name: 'Rostam', description: 'Rostam NPC' },
    0x84: { name: 'Rostam Sword', description: 'Rostam sword location' },
    0x85: { name: 'King Fiesal', description: 'King NPC' },
    0x86: { name: 'Wiseman', description: 'Spell teacher' },
    0x87: { name: '50 Rupias Lady', description: 'Money reward' },
  },
  5: {
    0x80: { name: 'Wiseman Moscom', description: 'Moscom spell teacher' },
    0x81: { name: 'Hassan', description: 'Genie ally - strong fighter' },
    0x82: { name: 'Kaji', description: 'NPC' },
    0x83: { name: 'Legend Sword', description: 'Final sword location' },
    0x84: { name: 'Armor of Light', description: 'Final armor location' },
    0x85: { name: 'Sabaron Final', description: 'Final boss trigger' },
    0x86: { name: 'Only One Jar', description: 'Jar NPC' },
    0x87: { name: 'Libcom', description: 'Spell teacher' },
    0x88: { name: 'Rupias', description: 'Money reward' },
  },
};

// Event types from knowledge/enums/content-types.md
export const EVENT_TYPES: Record<number, { name: string; description: string }> = {
  0x00: { name: 'None', description: 'No special event' },
  0x01: { name: 'Coronya: Listen', description: '"Listen to the people of the town"' },
  0x02: { name: 'Use Oprin', description: 'Oprin item required' },
  0x03: { name: 'North Cape', description: '"This is the north cape"' },
  0x05: { name: 'Town', description: 'Town event trigger' },
  0x06: { name: 'Oprin', description: 'Oprin event' },
  0x07: { name: 'North Cape', description: '"This is the north cape"' },
  0x08: { name: 'Screen Event', description: 'Generic screen event' },
  0x20: { name: 'Oprin Door', description: 'Oprin door (no message)' },
  0x22: { name: 'Oprin Door + Coronya', description: 'Oprin door with Coronya message' },
  0x40: { name: 'Stairway', description: 'Content byte = destination screen' },
  0x47: { name: 'Jump', description: 'Can jump in North Cape' },
  0x48: { name: 'Water', description: 'Water/underwater area' },
  0x60: { name: 'Building Entry', description: 'Building entrance trigger' },
  0x62: { name: 'Building Event', description: 'Building event' },
  0x80: { name: 'NPC Event', description: 'NPC interaction event' },
  0xC0: { name: 'Time Door', description: 'Time door event' },
};
