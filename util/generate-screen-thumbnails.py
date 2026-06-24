"""
Generate pre-rendered screen thumbnails for the navigation map.

Hits the local backend's /api/rom/render/ endpoint for every screen across
all 5 chapters and saves PNGs to ui/public/assets/screens/ch{N}/.

Requirements:
  - Backend running locally: uvicorn tmos_randomizer.api.server:app --port 8000
  - ROM loaded (set TMOS_DEFAULT_ROM env var or upload via the UI first)
  - requests package: pip install requests

Usage:
  python util/generate-screen-thumbnails.py
  python util/generate-screen-thumbnails.py --scale 2 --base-url http://localhost:8000
"""

import argparse
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print("pip install requests", file=sys.stderr)
    sys.exit(1)

REPO_ROOT = Path(__file__).parent.parent
OUT_BASE = REPO_ROOT / "projects/TMOS_Randomizer_V2/ui/public/assets/screens"

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default="http://localhost:8000")
    parser.add_argument("--scale", type=int, default=2,
                        help="Render scale (1=64px tiles, 2=128px tiles, default 2)")
    parser.add_argument("--chapters", default="1,2,3,4,5")
    args = parser.parse_args()

    chapters = [int(c) for c in args.chapters.split(",")]

    # Verify backend is up and ROM is loaded
    status = requests.get(f"{args.base_url}/api/rom/render/status", timeout=5)
    info = status.json()
    if not info.get("rom_loaded"):
        print("ERROR: ROM not loaded. Start the backend with TMOS_DEFAULT_ROM set or upload via the UI.", file=sys.stderr)
        sys.exit(1)
    if not info.get("rendering_available"):
        print("ERROR: Pillow not installed on backend. pip install Pillow", file=sys.stderr)
        sys.exit(1)

    total = 0
    errors = 0

    for chapter_num in chapters:
        resp = requests.get(f"{args.base_url}/api/rom/chapter/{chapter_num}", timeout=10)
        if resp.status_code != 200:
            print(f"  Chapter {chapter_num}: not found ({resp.status_code})")
            continue

        screens = resp.json().get("screens", [])
        out_dir = OUT_BASE / f"ch{chapter_num}"
        out_dir.mkdir(parents=True, exist_ok=True)

        print(f"Chapter {chapter_num}: {len(screens)} screens → {out_dir}")

        for screen in screens:
            idx = screen["index"]
            out_file = out_dir / f"{idx}.png"

            r = requests.get(
                f"{args.base_url}/api/rom/render/{chapter_num}/{idx}",
                params={"scale": args.scale},
                timeout=10,
            )
            if r.status_code == 200:
                out_file.write_bytes(r.content)
                total += 1
                if total % 50 == 0:
                    print(f"  ... {total} rendered")
            else:
                print(f"  WARN: ch{chapter_num}/screen {idx} → HTTP {r.status_code}")
                errors += 1

    print(f"\nDone: {total} thumbnails, {errors} errors → {OUT_BASE}")


if __name__ == "__main__":
    main()
