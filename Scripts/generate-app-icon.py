#!/usr/bin/env python3
"""Render the canonical Kaizōsha artwork as an opaque iOS app icon."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[1]
catalog = root / "Examples/CustomKitCatalog/Resources/Assets.xcassets"
icon_set = catalog / "AppIcon.appiconset"
icon_set.mkdir(parents=True, exist_ok=True)

scale = 4
image = Image.new("RGB", (1024 * scale, 1024 * scale), (249, 248, 244))
draw = ImageDraw.Draw(image)
artwork_scale = 4.15 * scale
column_width = 40 * artwork_scale
column_spacing = 14 * artwork_scale
region_width = 148 * artwork_scale
pillar_height = 105 * artwork_scale
origin_x = (image.width - region_width) / 2
origin_y = 198 * scale
ink = (20, 22, 21)

for column in range(3):
    x = origin_x + column * (column_width + column_spacing)
    draw.rounded_rectangle(
        (x, origin_y, x + column_width, origin_y + pillar_height),
        radius=2 * artwork_scale,
        fill=ink,
    )

font_path = next(Path("/System/Library/Fonts").glob("*W6.ttc"))
font = ImageFont.truetype(str(font_path), round(31 * artwork_scale))
for column, character in enumerate("改造社"):
    center_x = origin_x + column * (column_width + column_spacing) + column_width / 2
    center_y = origin_y + pillar_height + 9 * artwork_scale + 18.5 * artwork_scale
    draw.text((center_x, center_y), character, font=font, fill=ink, anchor="mm")

image = image.resize((1024, 1024), Image.Resampling.LANCZOS)
image.save(icon_set / "AppIcon.png", optimize=True)
(catalog / "Contents.json").write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n")
(icon_set / "Contents.json").write_text(json.dumps({
    "images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
    "info": {"author": "xcode", "version": 1},
}, indent=2) + "\n")
print(icon_set / "AppIcon.png")
