"""Generates the tray icons (no image libraries needed):
  assets/tray/tray.ico           Windows: 16/24/32 px, the buddy's face in color
  assets/tray/tray_template.png  macOS menu bar template: black + alpha, 36 px (@2x of 18 pt)
Run: python tool/make_tray_icons.py"""
import math, struct, zlib

def png(w, h, rgba):
    raw = b''.join(b'\x00' + bytes(rgba[y*w*4:(y+1)*w*4]) for y in range(h))
    def chunk(t, d):
        c = struct.pack('>I', len(d)) + t + d
        return c + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))

def face(size, template=False, ss=4):
    """Head, spiky hair, eyes and smile in the prototype's 120x222 design,
    cropped to the head (x 30..90, y 8..76) and supersampled."""
    S = size * ss
    def inside(px, py):
        # map to design coords
        x = 30 + px / S * 60
        y = 10 + py / S * 64
        head = ((x-60)/25)**2 + ((y-46)/27)**2 <= 1
        ear = (x-35)**2 + (y-49)**2 <= 25 or (x-85)**2 + (y-49)**2 <= 25
        hair = y < 40 - 8*abs(math.sin((x-35)/50*math.pi*4)) and 35 <= x <= 86 and ((x-60)/27)**2 + ((y-40)/32)**2 <= 1
        eye = (x-51)**2 + (y-48)**2 <= 3.6**2 or (x-69)**2 + (y-48)**2 <= 3.6**2
        d = math.hypot(x-60, y-50)
        smile = 13 <= d <= 16.5 and y > 56 and abs(x-60) < 11
        return head or ear, hair, eye or smile
    out = []
    for y in range(size):
        for x in range(size):
            acc = [0, 0, 0, 0]
            for sy in range(ss):
                for sx in range(ss):
                    skin, hair, feat = inside(x*ss+sx+.5, y*ss+sy+.5)
                    if template:
                        a = 1 if (skin or hair) and not feat else 0
                        c = (0, 0, 0)
                    elif feat:
                        a, c = 1, (0x1C, 0x27, 0x33)
                    elif hair:
                        a, c = 1, (0x2B, 0x1B, 0x12)
                    elif skin:
                        a, c = 1, (0xE9, 0xB4, 0x8A)
                    else:
                        a, c = 0, (0, 0, 0)
                    for i in range(3): acc[i] += c[i] * a
                    acc[3] += a
            n = ss * ss
            alpha = acc[3] / n
            rgb = [int(acc[i] / acc[3]) if acc[3] else 0 for i in range(3)]
            out += rgb + [int(alpha * 255)]
    return out

sizes = [16, 24, 32]
pngs = [png(s, s, face(s)) for s in sizes]
header = struct.pack('<HHH', 0, 1, len(sizes))
offset = 6 + 16 * len(sizes)
entries = b''
for s, p in zip(sizes, pngs):
    entries += struct.pack('<BBBBHHII', s, s, 0, 0, 1, 32, len(p), offset)
    offset += len(p)
open('assets/tray/tray.ico', 'wb').write(header + entries + b''.join(pngs))
open('assets/tray/tray_template.png', 'wb').write(png(36, 36, face(36, template=True)))
