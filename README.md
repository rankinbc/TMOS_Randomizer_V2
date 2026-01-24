# TMOS_AI

**The Magic of Scheherazade - ROM Reverse Engineering & Randomizer Project**

A comprehensive AI-assisted project for reverse engineering the NES game "The Magic of Scheherazade" (1987) and building a sophisticated map randomizer.

---

## Overview

| Attribute | Value |
|-----------|-------|
| Platform | NES (Nintendo Entertainment System) |
| ROM Size | 128KB PRG + 128KB CHR |
| Mapper | MMC1 (iNES 1) |
| Total Screens | 739 across 5 chapters |
| Project Status | Active Development |

---

## Project Structure

```
TMOS_AI/
├── projects/
│   └── TMOS_Randomizer_V2/     # Main randomizer application
│       ├── src/                 # Python backend (FastAPI)
│       ├── ui/                  # React/TypeScript frontend
│       ├── config/              # YAML randomizer configs
│       └── tests/               # Pytest test suite
│
├── knowledge/                   # Authoritative reverse-engineering docs
│   ├── memory/                  # RAM/ROM address maps
│   ├── structures/              # Data structure specifications
│   ├── systems/                 # Game system documentation
│   ├── enums/                   # Game data enumerations
│   ├── bosses/                  # Boss reference data
│   ├── reference/               # Quick reference guides
│   └── images/                  # Maps and tile images
│
├── docs/
│   ├── human/                   # User-facing documentation
│   └── ai/                      # AI context documentation
│
├── rom-files/                   # ROM data (gitignored)
│   └── disassembly/             # Disassembly analysis tools
│
├── extracted-data/              # Game assets and extracted data
├── temp/                        # Temporary/scratch files
├── reports/                     # Analysis reports
├── testing/                     # Test ROM files and results
├── tools/                       # Utility scripts
└── util/                        # Reusable utility modules
```

---

## Quick Start

### Prerequisites

- Python 3.10+
- Node.js 18+ (for UI)
- A legally obtained copy of the ROM

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd TMOS_AI

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Install UI dependencies (optional)
cd projects/TMOS_Randomizer_V2/ui
npm install
```

### Usage

```bash
# Preview randomization (no ROM modification)
tmos-randomize preview --seed 12345

# Randomize a ROM
tmos-randomize randomize input.nes output.nes --seed 12345

# Start the web UI
tmos-randomize serve
```

---

## The Randomizer

The randomizer uses a **7-phase pipeline**:

1. **Planning** - Determine section counts and sizes per chapter
2. **Shaping** - Generate random section shapes
3. **Connection** - Connect sections into a navigable graph
4. **Population** - Assign TileSections and ObjectSets
5. **Navigation** - Rewrite screen navigation and stairways
6. **Validation** - Verify traversability and compatibility
7. **Content** - Place items, allies, and shops

### Key Features

- Seed-based deterministic randomization
- Multi-level validation (edge compatibility, traversability, CHR/ObjectSet compatibility)
- Configurable via YAML
- Spoiler log generation
- Web-based visualization UI

---

## Knowledge Base

The `/knowledge/` folder contains 33 markdown documents with 170+ images documenting:

- **739 WorldScreens** (16 bytes each)
- **474 TileSections** (32 bytes each)
- **~210 RAM addresses**
- **~160 ROM addresses**
- **11 recruitable allies**
- **6 chapter bosses**

All documentation includes confidence levels (HIGH/MEDIUM/LOW) and source citations.

---

## Related Resources

- [Flying Omelette's TMOS Page](https://flyingomelette.com/nes/tmos/) - Community game data
- [NESdev Wiki](https://www.nesdev.org/wiki/) - NES hardware reference

---

## License

This project is for educational and preservation purposes. The original game is copyright Konami.

---

## Contributing

1. Check the knowledge base before adding new documentation
2. Follow the confidence level system for all data
3. Run tests before submitting changes: `pytest projects/TMOS_Randomizer_V2/tests/`
