#!/usr/bin/env python3
"""Generate placeholder audio for Fun Learning iOS app.
- music_loop.wav : gentle cheerful music-box loop (~16 s, seamless)
- chime.wav      : bright success arpeggio (~1.4 s)
44.1 kHz 16-bit mono. Final composed tracks will replace these.
"""
import math, struct, wave

SR = 44100

def note_freq(midi):
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))

def music_box(freq, t, dur):
    """Music-box-ish timbre: fundamental + partials, exponential decay."""
    env = math.exp(-3.2 * t / dur)
    return env * (math.sin(2*math.pi*freq*t)
                  + 0.35 * math.sin(2*math.pi*freq*3.01*t) * math.exp(-2.0*t)
                  + 0.12 * math.sin(2*math.pi*freq*9.2*t) * math.exp(-4.0*t))

def render(events, total):
    buf = [0.0] * int(SR * total)
    for (start, dur, midi, vol) in events:
        f = note_freq(midi)
        n0 = int(start * SR); n1 = min(len(buf), int((start + dur) * SR))
        for n in range(n0, n1):
            t = (n - n0) / SR
            buf[n] += vol * music_box(f, t, dur)
    peak = max(1e-6, max(abs(x) for x in buf))
    return [int(max(-1, min(1, x / peak * 0.85)) * 32767) for x in buf]

def write_wav(path, samples):
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(struct.pack("<%dh" % len(samples), *samples))
    print("wrote", path, len(samples)/SR, "s")

# ---- music loop: original gentle tune, C major, music box + soft bass ----
# (melody_midi, start_beat, beats)
melody = [
    (72, 0, 1), (76, 1, 1), (79, 2, 1), (76, 3, 1),
    (81, 4, 1.5), (79, 5.5, 0.5), (76, 6, 1), (72, 7, 1),
    (74, 8, 1), (77, 9, 1), (81, 10, 1), (77, 11, 1),
    (79, 12, 1.5), (76, 13.5, 0.5), (74, 14, 1), (72, 15, 2),
]
bass = [  # soft root notes, one per 2 beats
    (48, 0, 2), (45, 2, 2), (41, 4, 2), (43, 6, 2),
    (45, 8, 2), (41, 10, 2), (43, 12, 2), (48, 14, 2),
]
BEAT = 0.5  # seconds per beat -> 16 s loop
events = []
for midi, b, beats in melody:
    events.append((b*BEAT, beats*BEAT + 0.6, midi, 0.5))
for midi, b, beats in bass:
    events.append((b*BEAT, beats*BEAT + 0.3, midi - 12, 0.22))
write_wav("music_loop.wav", render(events, 16*BEAT + 0.4))

# ---- chime: C5 E5 G5 C6 sparkle ----
chime_notes = [(72, 0.0), (76, 0.12), (79, 0.24), (84, 0.36)]
events = [(s, 0.9, m, 0.55) for m, s in chime_notes]
write_wav("chime.wav", render(events, 1.5))
