# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
"""Build multimedia/images/argos-social-preview.png (1280x640), the image
GitHub and social networks show when the repository link is shared.

Usage: python multimedia/src/build_social_preview.py [FONT_BOLD] [FONT_REGULAR]
Needs Pillow. Default fonts: DejaVu Sans (Linux) or Segoe UI (Windows).
"""

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFont

ROOT = Path(__file__).resolve().parents[1]
PHOTO = ROOT / "images" / "banner - be-quiet-priest-sculpture-in-venlo_by_raffael_herrmann.jpg"
OUT = ROOT / "images" / "argos-social-preview.png"
W, H = 1280, 640
ACCENT = (232, 93, 4)


def font(candidates, size):
    for name in candidates:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


bold = [sys.argv[1]] if len(sys.argv) > 1 else []
bold += ["DejaVuSans-Bold.ttf", "C:/Windows/Fonts/segoeuib.ttf"]
regular = [sys.argv[2]] if len(sys.argv) > 2 else []
regular += ["DejaVuSans.ttf", "C:/Windows/Fonts/segoeui.ttf"]

# Photo: greyscale, scaled to cover 1280x640, cropped keeping the statue on the right.
photo = Image.open(PHOTO).convert("L")
scale = max(W / photo.width, H / photo.height)
photo = photo.resize((round(photo.width * scale), round(photo.height * scale)), Image.LANCZOS)
left = photo.width - W
top = (photo.height - H) // 2
photo = photo.crop((left, top, left + W, top + H))
photo = ImageEnhance.Brightness(photo).enhance(0.85).convert("RGB")

# Dark gradient on the left so the text stays readable.
shade = Image.new("L", (W, H))
draw_shade = ImageDraw.Draw(shade)
for x in range(W):
    alpha = 235 if x < 520 else max(0, int(235 * (1 - (x - 520) / 420)))
    draw_shade.line([(x, 0), (x, H)], fill=alpha)
canvas = Image.composite(Image.new("RGB", (W, H), (12, 14, 18)), photo, shade)

d = ImageDraw.Draw(canvas)
d.rectangle([64, 150, 72, 470], fill=ACCENT)
d.text((96, 140), "ARGOS", font=font(bold, 128), fill=(255, 255, 255))
d.text((100, 290), "OSINT workstation for Ubuntu", font=font(bold, 40), fill=(255, 255, 255))
d.text((100, 344), "24.04 and 26.04 LTS", font=font(bold, 40), fill=(255, 255, 255))
small = font(regular, 27)
d.text((100, 418), "20+ tools · one menu entry per task", font=small, fill=(215, 215, 215))
d.text((100, 456), "case folders with logged commands and SHA-256", font=small, fill=(215, 215, 215))
d.text((64, 572), "github.com/SOsintOps/Argos  ·  MIT licence", font=font(regular, 24), fill=(170, 170, 170))

canvas.save(OUT, optimize=True)
print("written", OUT, canvas.size)
