"""Generates assets/sounds/chime.wav: the prototype's two-tone chime
(660 Hz then 880 Hz 160 ms later; 20 ms attack to 0.18, exponential decay to
0.001 at 350 ms). Run: python tool/make_chime.py"""
import math, struct, wave

RATE = 44100
LENGTH = 0.62
NOTES = [(660.0, 0.0), (880.0, 0.16)]
PEAK, ATTACK, END = 0.18 * 3, 0.02, 0.35  # x3: Web Audio gain is quieter

samples = [0.0] * int(RATE * LENGTH)
for freq, start in NOTES:
    for i in range(int(RATE * 0.4)):
        t = i / RATE
        if t < ATTACK:
            env = PEAK * t / ATTACK
        else:
            k = math.log(0.001 / PEAK) / (END - ATTACK)
            env = PEAK * math.exp(k * (t - ATTACK))
        j = int((start + t) * RATE)
        if j < len(samples):
            samples[j] += env * math.sin(2 * math.pi * freq * t)

with wave.open('assets/sounds/chime.wav', 'wb') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(b''.join(
        struct.pack('<h', int(max(-1, min(1, s)) * 32767)) for s in samples))
