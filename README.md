# Fun Learning

A kids' learning game — starting with alphabet tracing on **Letters Island**,
growing into a living learning world (numbers, shapes, words, and more).

- **Warm narrator voice** guides every lesson; **cheerful music** throughout.
- **Pip**, a 3D mascot, roams the island, claps, and celebrates with kids.
- Every letter is a journey stop: trace it, hear its word (*A is for Apple*),
  meet the word as a real 3D object.

## Layout

| Path | What's here |
|------|-------------|
| `demo/` | Web proving ground (playable prototype; ships via artifact) |
| `art/` | Blender source — Pip the mascot, 3D word-items, skins, renders, GLBs |
| `ios/` | Native iOS app (Swift/SwiftUI) — future |
| `android/` | Native Android app (Kotlin) — future |

## Art pipeline

Characters and word-items are modeled in Blender (headless `bpy` scripts),
judged from renders, then exported as GLB for the game. See `art/README.md`.
