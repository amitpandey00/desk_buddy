"""Generates the app icon at every size from one 1024 px master (no image
libraries): the buddy's face on a rounded accent tile.
  windows/runner/resources/app_icon.ico                  16..256
  macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png  16..1024
  assets/icon/app_icon.png                               512 (MSIX logo)
Run: python tool/make_app_icons.py   (takes ~1 min)"""
import math, os, struct, zlib

def png(w, h, px):
    raw = b''.join(b'\x00' + bytes(px[y*w*4:(y+1)*w*4]) for y in range(h))
    def chunk(t, d):
        c = struct.pack('>I', len(d)) + t + d
        return c + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))

ACCENT_TOP, ACCENT_BOTTOM = (0x5A, 0x9C, 0xF0), (0x2F, 0x7D, 0xE1)
SKIN, HAIR, INK, CHEEK = (0xE9, 0xB4, 0x8A), (0x2B, 0x1B, 0x12), (0x1C, 0x27, 0x33), (0xF2, 0x9C, 0x8C)

def sample(u, v):
    """u, v in 0..1 → RGBA (0..1 alpha). macOS-style tile with 10% margin."""
    m, r = 0.10, 0.225 * 0.8
    x0, y0, x1, y1 = m, m, 1 - m, 1 - m
    cx, cy = min(max(u, x0 + r), x1 - r), min(max(v, y0 + r), y1 - r)
    if (u - cx) ** 2 + (v - cy) ** 2 > r * r or not (x0 <= u <= x1 and y0 <= v <= y1):
        return (0, 0, 0, 0)
    t = (v - y0) / (y1 - y0)
    col = tuple(int(a + (b - a) * t) for a, b in zip(ACCENT_TOP, ACCENT_BOTTOM))
    # Face in the prototype's design units: head centred at (60, 46).
    x = 60 + (u - 0.5) * 118
    y = 47 + (v - 0.5) * 118
    head = ((x - 60) / 25) ** 2 + ((y - 46) / 27) ** 2 <= 1
    ear = (x - 35) ** 2 + (y - 49) ** 2 <= 25 or (x - 85) ** 2 + (y - 49) ** 2 <= 25
    hair = (y < 40 - 8 * abs(math.sin((x - 35) / 50 * math.pi * 4))
            and ((x - 60) / 26.5) ** 2 + ((y - 44) / 29) ** 2 <= 1)
    eye = (x - 51) ** 2 + (y - 48) ** 2 <= 3.4 ** 2 or (x - 69) ** 2 + (y - 48) ** 2 <= 3.4 ** 2
    shine = (x - 52) ** 2 + (y - 47) ** 2 <= 1.0 or (x - 70) ** 2 + (y - 47) ** 2 <= 1.0
    d = math.hypot(x - 60, y - 50)
    smile = 13.5 <= d <= 15.5 and y > 57 and abs(x - 60) < 10
    cheek = (x - 45) ** 2 + (y - 57) ** 2 <= 16 or (x - 75) ** 2 + (y - 57) ** 2 <= 16
    if head or ear:
        col = SKIN
        if hair: col = HAIR
        elif shine: col = (255, 255, 255)
        elif eye or smile: col = INK
        elif cheek: col = CHEEK
    elif hair:
        col = HAIR
    return col + (1,)

def render(size, ss):
    out = []
    for y in range(size):
        for x in range(size):
            acc = [0.0] * 4
            for sy in range(ss):
                for sx in range(ss):
                    r, g, b, a = sample((x + (sx + .5) / ss) / size, (y + (sy + .5) / ss) / size)
                    acc[0] += r * a; acc[1] += g * a; acc[2] += b * a; acc[3] += a
            a = acc[3]
            out += [int(acc[i] / a) if a else 0 for i in range(3)] + [int(255 * a / (ss * ss))]
    return out

def downsample(px, size, target):
    f = size // target
    out = []
    for y in range(target):
        for x in range(target):
            acc = [0] * 4
            for dy in range(f):
                row = ((y * f + dy) * size + x * f) * 4
                for dx in range(f):
                    i = row + dx * 4
                    a = px[i + 3]
                    acc[0] += px[i] * a; acc[1] += px[i + 1] * a; acc[2] += px[i + 2] * a; acc[3] += a
            a = acc[3]
            out += [acc[i] // a if a else 0 for i in range(3)] + [a // (f * f)]
    return out

master = render(1024, 2)
sizes = {s: (master if s == 1024 else downsample(master, 1024, s)) for s in (16, 32, 64, 128, 256, 512, 1024)}
sizes[24] = render(24, 4)   # 1024 isn't a multiple of 24 or 48
sizes[48] = render(48, 4)

mac = 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
for s in (16, 32, 64, 128, 256, 512, 1024):
    open(f'{mac}/app_icon_{s}.png', 'wb').write(png(s, s, sizes[s]))

ico_sizes = [16, 24, 32, 48, 64, 128, 256]
blobs = [png(s, s, sizes[s]) for s in ico_sizes]
head = struct.pack('<HHH', 0, 1, len(ico_sizes))
offset, entries = 6 + 16 * len(ico_sizes), b''
for s, b in zip(ico_sizes, blobs):
    entries += struct.pack('<BBBBHHII', s % 256, s % 256, 0, 0, 1, 32, len(b), offset)
    offset += len(b)
open('windows/runner/resources/app_icon.ico', 'wb').write(head + entries + b''.join(blobs))

os.makedirs('assets/icon', exist_ok=True)
open('assets/icon/app_icon.png', 'wb').write(png(512, 512, sizes[512]))
print('ok')
