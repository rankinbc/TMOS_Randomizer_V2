# Data Sources

**Last Updated**: 2026-01-24

---

## Overview

This document tracks all sources used to build the knowledgebase, with reliability ratings.

---

## Primary Sources (HIGH Reliability)

### FCEUX Emulator Files
- **Type**: .nl label files, RAM watches (.wch)
- **Location**: Tim's flashdrive, local FCEUX folders
- **Reliability**: HIGHEST
- **Content**: ~175 labeled RAM addresses, ~77 ROM function labels
- **Notes**: Direct memory observation, TAS-verified

### TAS Lua Scripts
- **Type**: Lua scripts for FCEUX
- **Location**: Tim's flashdrive (`D:\OneDrive\...\Tims flashdrive\TMoS`)
- **Reliability**: HIGHEST
- **Scripts**:
  - `Sal_Tracker.lua` - Salamander boss tracking
  - `viewRandEnc.lua` - Random encounter analysis
  - `PlayerCoverScreen.lua` - Screen navigation tracking
- **Notes**: Active code, directly verified addresses

### TMOS_Romhack3 (GitHub)
- **Type**: C# codebase
- **URL**: https://github.com/rankinbc/TMOS_Romhack3
- **Reliability**: HIGH
- **Content**: Most comprehensive - enums, structures, collision data, enemy stats
- **Notes**: Working implementation, includes Flying Omelette validation

### TMOS_Romhack1 (GitHub)
- **Type**: C# codebase
- **Reliability**: HIGH
- **Content**: WorldScreen implementation, content types, event types
- **Notes**: Earlier project, some data superseded by Romhack3

### TMOS-Rom-Editor-2 (GitHub)
- **Type**: C# codebase
- **Reliability**: HIGH
- **Content**: TileSection structures, screen editing logic
- **Notes**: Different TileSection count than Romhack3 (940 vs 471)

---

## Secondary Sources (MEDIUM Reliability)

### AI Docs (Manual Notes)
- **Type**: Markdown documentation
- **Location**: `D:\OneDrive\...\TMOS AI Docs`
- **Reliability**: MEDIUM
- **Content**: WorldScreen info, ROM structures, manual research
- **Notes**: Human observation, may contain transcription errors

### Flying Omelette Website
- **Type**: Game guide/FAQ
- **Reliability**: MEDIUM (for enemy data: HIGH)
- **Content**: Enemy stats, character abilities, item effects
- **Notes**: Community-verified gameplay data

---

## Tertiary Sources (LOW Reliability)

### Speculation/Analysis
- **Type**: Inferred data
- **Reliability**: LOW
- **Notes**: Documented as hypotheses, requires verification

---

## Source Conflicts

Active conflicts are tracked in [conflicts.md](conflicts.md).

| Conflict | Sources | Status |
|----------|---------|--------|
| TileType values | AI Docs vs Romhack3 | UNRESOLVED |

---

## File Locations

### Tim's Flashdrive (Primary TAS Data)
```
D:\OneDrive\SoftwareDev\Personal Projects\TMOS Stuff\TMOS Project\Emulation stuff\Tims flashdrive\TMoS
├── *.wch (RAM watch files)
├── *.lua (Lua scripts)
├── scheherazade_addresses.txt
├── A-B Button Assignments.txt
├── data.txt
└── Maps\ (chapter maps)
```

### GitHub Clones (archived in temp)
```
C:\claude-workspace\TMOS_AI\temp\github-clones\
├── TMOS_Romhack1\
├── TMOS-Rom-Editor-2\
└── TMOS_Romhack3\
```

### AI Docs
```
D:\OneDrive\SoftwareDev\Personal Projects\TMOS Stuff\TMOS AI Docs
```

---

## Related Documents

- [confidence-guide.md](confidence-guide.md) - How reliability maps to confidence
- [conflicts.md](conflicts.md) - Source disagreements
