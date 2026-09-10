# Fun Learning — iOS app (Letters Island)

Native iOS app (Swift 5.9+, iOS 17+, SwiftUI) for the Fun Learning kids'
alphabet tracing game. This is the real product; the web demo was the
proving ground.

## What's inside

- **Letters Island map** — winding A–Z journey path, locked/unlocked nodes,
  stars, Capital / Small segmented switch.
- **Tracing lessons** — all 52 letters with real stroke orders, numbered
  stroke-order dots, finger tracing with **adaptive magnetic guidance**
  (the child is gently pulled back to the path, never rejected), and a
  visible helper hand when they stall or drift.
- **3D-look brush fill** — raised glossy ink (shadow + base + highlight);
  brush picker with coral, blue, green, purple, **rainbow**, and **glitter**
  (animated sparkles), switchable mid-trace.
- **Word card** — "A is for Apple" with picture + speaker button, always
  visible while tracing.
- **Voice** — `AVSpeechSynthesizer` narrator: letter names, instructions,
  encouragement, word pronunciations (warm, toddler-slow).
- **Music** — gentle looping background music with mute toggle.
- **Pip the mascot** — roams the island, waves, claps after strokes,
  celebrates; idle life (breathing, blinking, wandering pupils).
- **Liveliness** — drifting sparkles, springy buttons, toddler-calm motion.
- **Progress** — unlocks + stars persisted in `UserDefaults`.

No third-party dependencies — builds offline with stock Xcode.

## Placeholder vs final

| Item | Now | Final |
|------|-----|-------|
| Pip mascot | Charming SwiftUI placeholder (`MascotView`) | Blender-built USDZ → see `Art/README.md` |
| Word pictures | Emoji (`🍎`) | Blender-built 3D word models |
| Music / chime | Synthesized WAV loop | Composed tracks (drop-in, same filenames) |
| Numbers/Shapes/Words | "Coming soon" stubs | Full worlds |

## Build

Generated with XcodeGen — see [BUILD-ON-MAC.md](BUILD-ON-MAC.md).

```
ios/
├── project.yml            # XcodeGen — generates FunLearning.xcodeproj
├── BUILD-ON-MAC.md
├── README.md
├── Art/                   # 3D asset drop-in (excluded from build)
└── FunLearning/
    ├── FunLearningApp.swift
    ├── Info.plist
    ├── Models/            # LessonData (52 letters + stroke paths), Brush, GameState, Geometry
    ├── ViewModels/        # TracingViewModel (tracing engine)
    ├── Views/             # Island map, tracing canvas, word card, mascot, …
    ├── Audio/             # Narrator (AVSpeech), MusicPlayer (AVAudioPlayer)
    └── Resources/         # music_loop.wav, chime.wav, Assets.xcassets
```
