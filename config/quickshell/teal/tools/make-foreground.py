#!/usr/bin/env python3
"""Regenerate Wallpaper/wallpaper-foreground.png from the wallpaper.

The foreground PNG is the wallpaper itself with everything that should sit BEHIND the clock
made transparent (flat sky and cloud regions). Every remaining pixel is copied unchanged
from the wallpaper. If you change config/hypr/wallpaper.jpg, run this again and then adjust
the clock position constants at the top of Wallpaper/DepthWallpaper.qml.

    python3 tools/make-foreground.py ../../hypr/wallpaper.jpg Wallpaper/wallpaper-foreground.png

Needs: python3, opencv-python, numpy, pillow.
"""
import sys
import cv2
import numpy as np
from PIL import Image

SRC = sys.argv[1] if len(sys.argv) > 1 else "../../hypr/wallpaper.jpg"
DST = sys.argv[2] if len(sys.argv) > 2 else "Wallpaper/wallpaper-foreground.png"

# Seed points (x, y in 1280x720 preview coordinates) inside the sky and cloud areas that
# belong behind the clock. Flood fill from these finds every connected flat region.
SEEDS = [(100, 60), (1000, 300), (720, 120), (600, 230), (900, 600), (1100, 420), (1000, 610),
         (1080, 555), (1000, 705), (950, 600), (1200, 150), (500, 60), (900, 655), (1000, 655),
         (1100, 655), (940, 556), (1005, 551), (1250, 250), (1250, 430), (1255, 520),
         (1040, 690), (820, 690)]
PREVIEW_SCALE = 3          # 3840 / 1280

im = cv2.imread(SRC)
if im is None:
    sys.exit(f"cannot read {SRC}")
h, w = im.shape[:2]
if (w, h) != (3840, 2160):
    sys.exit(f"expected a 3840x2160 wallpaper, got {w}x{h}; rescale SEEDS/PREVIEW_SCALE first")

smooth = cv2.bilateralFilter(im, 5, 30, 5)
bg = np.zeros((h, w), np.uint8)
for x, y in SEEDS:
    m = np.zeros((h + 2, w + 2), np.uint8)
    flags = 4 | cv2.FLOODFILL_MASK_ONLY | (255 << 8)
    cv2.floodFill(smooth.copy(), m, (x * PREVIEW_SCALE, y * PREVIEW_SCALE), 0, (14, 14, 14), (14, 14, 14), flags)
    bg |= m[1:-1, 1:-1]

bg = cv2.morphologyEx(bg, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5)))
fg = (bg == 0).astype(np.uint8) * 255

# drop thin cloud outlines / wires that are not part of the subject, then grow the core back
core = cv2.morphologyEx(fg, cv2.MORPH_OPEN, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (19, 19)))
n, lab, stats, _ = cv2.connectedComponentsWithStats(core, 8)
keep = np.zeros_like(core)
for i in range(1, n):
    if stats[i, cv2.CC_STAT_AREA] > 4000:
        keep[lab == i] = 255
mask = cv2.bitwise_and(cv2.dilate(keep, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (29, 29))), fg)

# fill pin-holes inside the subject
inv = cv2.bitwise_not(mask)
n, lab, stats, _ = cv2.connectedComponentsWithStats(inv, 4)
for i in range(1, n):
    if stats[i, cv2.CC_STAT_AREA] < 900:
        mask[lab == i] = 255

alpha = cv2.GaussianBlur(mask, (0, 0), 0.8)
rgba = np.dstack([np.array(Image.open(SRC).convert("RGB")), alpha])
Image.fromarray(rgba, "RGBA").save(DST, optimize=True)
print(f"wrote {DST}: {(mask > 127).mean() * 100:.1f}% of pixels are foreground")
