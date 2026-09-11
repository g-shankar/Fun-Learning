"""Cheerful toddler-calm ukulele-style background loop for Fun Learning.
C major, 96 BPM, 8 bars (20s), seamless loop. Fully synthesized = fully owned.
"""
import numpy as np, subprocess, os

SR = 44100
BPM = 96
BEAT = 60.0 / BPM
BAR = 4 * BEAT
N_BARS = 8
DUR = N_BARS * BAR

def env_decay(n, tau):
    t = np.arange(n) / SR
    return np.exp(-t / tau)

def pluck(freq, start, dur=0.35, gain=0.30):
    n = int(dur * SR)
    t = np.arange(n) / SR
    wave = (np.sin(2*np.pi*freq*t) + 0.35*np.sin(2*np.pi*2*freq*t)
            + 0.12*np.sin(2*np.pi*3*freq*t))
    wave *= env_decay(n, 0.16)
    return start, wave * gain

def bass_note(freq, start, dur=0.5, gain=0.22):
    n = int(dur * SR)
    t = np.arange(n) / SR
    wave = np.sin(2*np.pi*freq*t) + 0.15*np.sin(2*np.pi*2*freq*t)
    wave *= env_decay(n, 0.28)
    return start, wave * gain

def bell(freq, start, dur=0.9, gain=0.20):
    n = int(dur * SR)
    t = np.arange(n) / SR
    wave = (np.sin(2*np.pi*freq*t) + 0.25*np.sin(2*np.pi*3*freq*t)
            + 0.08*np.sin(2*np.pi*4.2*freq*t))
    wave *= env_decay(n, 0.45)
    return start, wave * gain

def shaker(start, gain=0.045, accent=False):
    n = int(0.09 * SR)
    wave = np.random.default_rng(int(start*1000)+7).standard_normal(n)
    wave *= env_decay(n, 0.03)
    return start, wave * (gain * (1.6 if accent else 1.0))

# ---- harmony: | C | F | G | C | C | F | G | C |
CHORDS = [
    ("C", [261.63, 329.63, 392.00], 65.41),
    ("F", [174.61, 220.00, 261.63], 87.31),
    ("G", [196.00, 246.94, 293.66], 98.00),
    ("C", [261.63, 329.63, 392.00], 65.41),
    ("C", [261.63, 329.63, 392.00], 65.41),
    ("F", [174.61, 220.00, 261.63], 87.31),
    ("G", [196.00, 246.94, 293.66], 98.00),
    ("C", [261.63, 329.63, 392.00], 65.41),
]
# ukulele-ish strum pattern over 8 eighth-notes: R 3 5 8 5 3 5 3
STRUM = [0, 1, 2, 2, 1, 0, 1, 2]

E4, G4, A4, B4, C5, D5, F4, G5 = 329.63, 392.00, 440.00, 493.88, 523.25, 587.33, 349.23, 783.99
q, h = BEAT, 2*BEAT
MELODY = [  # (freq or None, beats)
    (E4,q),(G4,q),(C5,q),(G4,q),
    (A4,q),(C5,q),(A4,q),(F4,q),
    (B4,q),(D5,q),(B4,q),(G4,q),
    (C5,h),(None,q),(E4,q),
    (E4,q),(G4,q),(C5,q),(D5,q),
    (C5,q),(A4,q),(F4,q),(A4,q),
    (G4,q),(B4,q),(D5,q),(G5,q),
    (C5,h),(None,h),
]

mix = np.zeros(int(DUR * SR) + SR)

def add(start, wave):
    i = int(start * SR)
    mix[i:i+len(wave)] += wave

for b, (name, chord, root) in enumerate(CHORDS):
    t0 = b * BAR
    for e in range(8):  # strums
        s, w = pluck(chord[STRUM[e]], t0 + e*BEAT/2 + 0.008*(e%3))
        add(s, w)
    for beat in (0, 2):  # bass on 1 and 3
        s, w = bass_note(root, t0 + beat*BEAT)
        add(s, w)
    for e in range(8):  # gentle shaker
        s, w = shaker(t0 + e*BEAT/2, accent=(e % 2 == 0))
        add(s, w)

t = 0.0
for freq, beats in MELODY:
    if freq:
        s, w = bell(freq, t)
        add(s, w)
    t += beats

# seamless loop: equal-power crossfade last 120ms into the start
X = int(0.12 * SR)
a = mix[:X].copy(); bseg = mix[-X:].copy()
fade_out = np.cos(np.linspace(0, np.pi/2, X))**2
fade_in = np.sin(np.linspace(0, np.pi/2, X))**2
mix[:X] = a*fade_in + bseg*fade_out
mix = mix[:-X]

mix = np.tanh(mix * 1.1)
mix *= 0.89 / max(1e-6, np.abs(mix).max())

out = "/home/hatch/workspace/fun-learning/music"
os.makedirs(out, exist_ok=True)
wav = os.path.join(out, "bgm_cheerful.wav")
mp3 = os.path.join(out, "bgm_cheerful.mp3")
import wave as wv
with wv.open(wav, "wb") as f:
    f.setnchannels(1); f.setsampwidth(2); f.setframerate(SR)
    f.writeframes((mix*32767).astype(np.int16).tobytes())
subprocess.run(["ffmpeg","-y","-loglevel","error","-i",wav,"-codec:a","libmp3lame",
                "-b:a","128k",mp3], check=True)
size = os.path.getsize(mp3)
print(f"done: {mp3} {size//1024}KB, {len(mix)/SR:.1f}s")
