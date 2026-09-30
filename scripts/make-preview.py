#!/usr/bin/env python3
"""Build preview.png for the README.

The leopard fills the picture. Two small cards sit at the sides, the way the
Davinci preview does, so the animal stays visible between them.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
W, H = 1920, 1080

BG = (18, 17, 12)
FG = (243, 234, 212)
MUTED = (138, 129, 104)
ACCENT = (232, 180, 35)
YELLOW = (240, 193, 78)
RED = (224, 122, 82)
GREEN = (143, 173, 98)
CYAN = (212, 196, 138)
BLUE = (201, 150, 46)
MAGENTA = (212, 160, 106)
BRIGHT_RED = (240, 148, 112)
BRIGHT_YELLOW = (255, 213, 106)
BRIGHT_GREEN = (180, 201, 122)

FONT = "/usr/share/fonts/noto/NotoSans-Regular.ttf"
FONT_MED = "/usr/share/fonts/noto/NotoSans-Medium.ttf"


def font(path, size):
    return ImageFont.truetype(path, size)


def main():
    photo = Image.open(ROOT / "backgrounds" / "01-serengeti-tree.jpg").convert("RGB")
    photo = photo.resize((W, H), Image.Resampling.LANCZOS)
    canvas = photo.convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    title = font(FONT_MED, 20)
    row = font(FONT, 18)
    tiny = font(FONT, 16)

    # Left card: the named colours. Short, and held to the left edge.
    left = (48, 250, 430, 830)
    draw.rounded_rectangle(left, radius=14, fill=BG + (235,), outline=ACCENT, width=2)
    draw.text((72, 270), "colors.toml", font=title, fill=ACCENT)

    swatches = (
        (BG, "background", "#12110c"),
        (FG, "foreground", "#f3ead4"),
        (ACCENT, "accent", "#e8b423"),
        (RED, "red", "#e07a52"),
        (YELLOW, "yellow", "#f0c14e"),
        (GREEN, "green", "#8fad62"),
        (CYAN, "cyan", "#d4c48a"),
        (BLUE, "blue", "#c9962e"),
        (MAGENTA, "magenta", "#d4a06a"),
    )
    for i, (color, name, hex_code) in enumerate(swatches):
        y = 316 + i * 48
        outline = FG if color == BG else None
        draw.rounded_rectangle((76, y, 108, y + 28), radius=6, fill=color, outline=outline, width=1)
        draw.text((120, y + 2), f"{name}  {hex_code}", font=row, fill=FG)

    draw.text((72, 780), "omarchy theme set leopard", font=tiny, fill=MUTED)

    # Right card: a small terminal palette.
    right = (1490, 280, 1872, 800)
    draw.rounded_rectangle(right, radius=14, fill=BG + (235,), outline=ACCENT, width=2)
    draw.text((1514, 300), "terminal", font=title, fill=ACCENT)

    chips = (
        (("normal",), (BG, FG, ACCENT)),
        (("red", "yellow", "green"), (RED, YELLOW, GREEN)),
        (("cyan", "blue", "magenta"), (CYAN, BLUE, MAGENTA)),
        (("bright",), (BRIGHT_RED, BRIGHT_YELLOW, BRIGHT_GREEN)),
    )
    for i, (labels, colors) in enumerate(chips):
        y = 360 + i * 100
        if len(labels) == 1:
            draw.text((1514, y), labels[0], font=tiny, fill=MUTED)
        else:
            for n, word in enumerate(labels):
                draw.text((1514 + n * 112, y), word, font=tiny, fill=MUTED)
        for n, color in enumerate(colors):
            x = 1514 + n * 112
            outline = FG if color == BG else None
            draw.rounded_rectangle((x, y + 28, x + 96, y + 84), radius=8, fill=color, outline=outline, width=1)

    canvas.convert("RGB").save(ROOT / "preview.png", optimize=True)
    print(f"Wrote {ROOT / 'preview.png'}")


if __name__ == "__main__":
    main()
