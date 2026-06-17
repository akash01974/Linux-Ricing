#!/usr/bin/env python3
"""Pre-compute dominant colors for all wallpapers (fast lookup for keyboard RGB)."""

import json
import os
import sys
from collections import Counter
from pathlib import Path

from PIL import Image

WALL_DIR = os.path.expanduser("~/Pictures/Wallpapers")
CACHE_FILE = os.path.expanduser("~/.cache/wallpaper-colors.json")
EXTS = {".jpg", ".jpeg", ".png", ".webp"}
QUANTIZE_COLORS = 8
LUM_THRESHOLD = 128


def dominant_color(img_path: str) -> str | None:
    """Extract the most vibrant color from an image.

    Strategy:
      1. Resize to 32×32 (speed, discard fine detail).
      2. Quantize palette to 8 colors (reduce noise).
      3. Score each palette entry by (count × saturation).
      4. Lightness-boost very dark colors so the keyboard is visible.
    """
    with Image.open(img_path).convert("RGB") as img:
        small = img.resize((32, 32), Image.LANCZOS)

    pal = small.quantize(colors=QUANTIZE_COLORS)

    # Palette → list of (R, G, B) tuples
    raw = pal.getpalette()
    n_colors = min(QUANTIZE_COLORS, len(raw) // 3)
    palette_colors = [tuple(raw[i * 3:(i * 3) + 3]) for i in range(n_colors)]

    # Count pixel indices (fast: pal.getdata() returns indices in mode 'P')
    idx_counts = Counter(pal.getdata())

    # Score: count × saturation (max - min / max) to prefer vibrant colors
    def score(idx: int) -> float:
        c = idx_counts.get(idx, 0)
        if c == 0:
            return 0.0
        r, g, b = palette_colors[idx]
        mx, mn = max(r, g, b), min(r, g, b)
        sat = (mx - mn) / max(mx, 1)
        return c * sat

    best_idx = max(range(n_colors), key=score)
    r, g, b = palette_colors[best_idx]

    # Lightness boost for dark colors (ensures keyboard is readable)
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < LUM_THRESHOLD:
        scale = LUM_THRESHOLD / max(lum, 1)
        r = min(255, int(r * scale))
        g = min(255, int(g * scale))
        b = min(255, int(b * scale))

    return f"{r:02X}{g:02X}{b:02X}"


def main() -> None:
    cache = {}
    files = sorted(Path(WALL_DIR).iterdir())
    for f in files:
        if f.suffix.lower() in EXTS:
            try:
                color = dominant_color(str(f))
                if color:
                    cache[f.name] = color
                    print(f"  ✓ {f.name}  →  #{color}")
            except Exception as e:
                print(f"  ✗ {f.name}  →  {e}", file=sys.stderr)

    with open(CACHE_FILE, "w") as fh:
        json.dump(cache, fh, indent=2)
    print(f"\nWrote {len(cache)} entries → {CACHE_FILE}")


if __name__ == "__main__":
    main()
