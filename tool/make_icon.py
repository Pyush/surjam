"""Draws the SurJam app icon: a tabla-headed eighth note with sound waves."""
import math, sys
from PIL import Image, ImageDraw, ImageFilter

S = 4                      # supersampling factor
N = 1024 * S
AMBER = (255, 137, 6)
MAGENTA = (229, 49, 112)
INK = (15, 14, 23)
WHITE = (255, 255, 255)

def p(v):                  # design units (1024 canvas) -> supersampled pixels
    return int(round(v * S))

def gradient_background():
    img = Image.new('RGB', (N, N))
    px = img.load()
    # Diagonal gradient, top-left amber to bottom-right magenta.
    row = []
    for i in range(2 * N):
        t = i / (2 * N - 2)
        row.append(tuple(int(AMBER[k] + (MAGENTA[k] - AMBER[k]) * t) for k in range(3)))
    grad = Image.new('RGB', (2 * N, 1))
    grad.putdata(row)
    grad = grad.resize((2 * N, 1))
    for y in range(N):
        img.paste(grad.crop((y, 0, y + N, 1)), (0, y))
    return img

def glyph_layer(scale=1.0, offset=(0.0, 0.0)):
    """White glyph on transparent canvas. scale/offset fit it into adaptive-icon safe zones."""
    layer = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    cx0, cy0 = 512, 512
    def t(x, y):
        return p(cx0 + (x - cx0) * scale + offset[0]), p(cy0 + (y - cy0) * scale + offset[1])
    def r(v):
        return p(v * scale)

    head = (420, 650)
    R = 130
    # Sound waves radiating from the drum head (drawn first so the head sits on top).
    for radius, width, alpha in [(205, 30, 235), (272, 30, 160)]:
        bbox = [*t(head[0] - radius, head[1] - radius), *t(head[0] + radius, head[1] + radius)]
        d.arc(bbox, start=8, end=62, fill=WHITE + (alpha,), width=r(width))
    # Stem
    stem_x = head[0] + R - 40
    d.rounded_rectangle([*t(stem_x, 230), *t(stem_x + 46, head[1])], radius=r(23), fill=WHITE)
    # Flag: thick cubic Bezier from the top of the stem
    P = [(stem_x + 23, 245), (640, 285), (735, 360), (668, 505)]
    steps = 400
    for i in range(steps + 1):
        u = i / steps
        x = (1-u)**3*P[0][0] + 3*(1-u)**2*u*P[1][0] + 3*(1-u)*u**2*P[2][0] + u**3*P[3][0]
        y = (1-u)**3*P[0][1] + 3*(1-u)**2*u*P[1][1] + 3*(1-u)*u**2*P[2][1] + u**3*P[3][1]
        w = 23 + 10 * math.sin(math.pi * u) - 9 * u   # flush with the stem, swells, tapers
        d.ellipse([*t(x - w, y - w), *t(x + w, y + w)], fill=WHITE)
    # Note head as a tabla: white skin, thin rim ring, dark syahi centre
    d.ellipse([*t(head[0] - R, head[1] - R), *t(head[0] + R, head[1] + R)], fill=WHITE)
    ring = R * 0.80
    d.ellipse([*t(head[0] - ring, head[1] - ring), *t(head[0] + ring, head[1] + ring)], outline=INK + (70,), width=r(7))
    sy = R * 0.42
    d.ellipse([*t(head[0] - sy, head[1] - sy), *t(head[0] + sy, head[1] + sy)], fill=INK)
    return layer

def with_shadow(layer):
    alpha = layer.split()[3]
    shadow = Image.new('RGBA', layer.size, (60, 10, 30, 0))
    shadow.putalpha(alpha.point(lambda a: int(a * 0.35)))
    shadow = shadow.filter(ImageFilter.GaussianBlur(p(14)))
    out = Image.new('RGBA', layer.size, (0, 0, 0, 0))
    out.alpha_composite(shadow, (0, p(14)))
    out.alpha_composite(layer)
    return out

def down(img, size):
    return img.resize((size, size), Image.LANCZOS)

if __name__ == '__main__':
    # Usage: python3 tool/make_icon.py assets/icon [--preview]
    out = sys.argv[1] if len(sys.argv) > 1 else '.'
    bg = gradient_background().convert('RGBA')
    # Full-bleed square icon (iOS, macOS, web, Windows, legacy Android)
    full = bg.copy()
    full.alpha_composite(with_shadow(glyph_layer(offset=(22, -12))))
    down(full, 1024).convert('RGB').save(f'{out}/icon_1024.png')
    # Android adaptive icon: glyph scaled into the 66% safe zone over a separate background
    fg = with_shadow(glyph_layer(scale=0.88, offset=(8, 0)))  # largest that keeps the glyph inside the 66dp safe zone
    down(fg, 1024).save(f'{out}/adaptive_foreground_1024.png')
    down(bg, 1024).convert('RGB').save(f'{out}/adaptive_background_1024.png')
    # Launch screen logos on the app's dark background.
    # Android 11-, iOS and web: the icon as a rounded square, treated as xxxhdpi (640px = 160dp).
    logo = down(full, 640)
    corner = Image.new('L', (640, 640), 0)
    ImageDraw.Draw(corner).rounded_rectangle([0, 0, 639, 639], radius=144, fill=255)
    splash = Image.new('RGBA', (640, 640), (0, 0, 0, 0))
    splash.paste(logo, (0, 0), corner)
    splash.save(f'{out}/splash_logo.png')
    # Android 12+: the system masks a 1152px canvas to a centred 768px circle.
    android12 = Image.new('RGBA', (1152, 1152), (0, 0, 0, 0))
    disc = down(bg, 1024)
    disc.alpha_composite(down(fg, 1024))
    disc = disc.resize((768, 768), Image.LANCZOS)
    circle = Image.new('L', (768, 768), 0)
    ImageDraw.Draw(circle).ellipse([0, 0, 767, 767], fill=255)
    android12.paste(disc, (192, 192), circle)
    android12.save(f'{out}/splash_android12.png')

    if '--preview' not in sys.argv:
        sys.exit(0)
    # Preview of how launchers mask it
    preview = Image.new('RGBA', (1024 * 3 + 80, 1024), (240, 240, 240, 255))
    sq = down(full, 1024)
    rounded = Image.new('L', (1024, 1024), 0); ImageDraw.Draw(rounded).rounded_rectangle([0, 0, 1023, 1023], radius=230, fill=255)
    preview.paste(sq, (0, 0), rounded)
    adaptive = down(bg, 1024); adaptive.alpha_composite(down(fg, 1024))
    circle = Image.new('L', (1024, 1024), 0); ImageDraw.Draw(circle).ellipse([0, 0, 1023, 1023], fill=255)
    preview.paste(adaptive, (1024 + 40, 0), circle)
    small = down(full, 48).resize((1024, 1024), Image.NEAREST)
    preview.paste(small, (2048 + 80, 0))
    preview.convert('RGB').resize(((1024 * 3 + 80) // 2, 512)).save(f'{out}/preview.png')
