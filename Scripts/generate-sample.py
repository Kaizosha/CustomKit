#!/usr/bin/env python3
"""Create the small, silent Kaizōsha motion study used by the local player example."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import math
import subprocess

root = Path(__file__).resolve().parents[1]
destination = root / "Examples/CustomKitCatalog/Resources/KaizoshaSample.mov"
destination.parent.mkdir(parents=True, exist_ok=True)
title_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Georgia.ttf", 68)
body_font = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", 18)
process = subprocess.Popen([
    "/opt/homebrew/bin/ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
    "-f", "rawvideo", "-pixel_format", "rgb24", "-video_size", "960x540",
    "-framerate", "24", "-i", "-", "-an", "-c:v", "libx264", "-crf", "25",
    "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(destination),
], stdin=subprocess.PIPE)
for frame in range(288):
    time = frame / 24
    image = Image.new("RGB", (960, 540), (16, 37, 36))
    draw = ImageDraw.Draw(image)
    for x in range(0, 961, 120):
        draw.line((x, 0, x, 540), fill=(25, 48, 46))
    for y in range(0, 541, 120):
        draw.line((0, y, 960, y), fill=(25, 48, 46))
    radius = 155 + math.sin(time * 0.8) * 28
    draw.ellipse((480-radius, 270-radius, 480+radius, 270+radius), outline=(51, 92, 85), width=1)
    draw.text((480, 240), "Kaizōsha", font=title_font, fill=(244, 248, 245), anchor="mm")
    draw.text((480 + math.sin(time) * 12, 315), "a moment in motion.", font=body_font, fill=(141, 188, 184), anchor="mm")
    draw.text((40, 488), f"MOTION STUDY 01     {time:05.2f}s", font=body_font, fill=(115, 147, 142))
    process.stdin.write(image.tobytes())
process.stdin.close()
if process.wait() != 0:
    raise SystemExit("Movie generation failed.")
print(destination)
