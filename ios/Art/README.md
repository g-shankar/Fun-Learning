# Art — 3D asset drop-in folder

This folder is where the real Blender-built art lands. It is **excluded from
compilation** (see `project.yml`), so dropping files here never breaks a build.

## What goes here

| Path | Contents |
|------|----------|
| `Art/pip.usdz` | The real Pip mascot model (replaces the SwiftUI placeholder) |
| `Art/words/<word>.usdz` | 3D word-items: `apple.usdz`, `bear.usdz`, … one per alphabet word |

## How the swap works

`Views/MascotView.swift` is built around a `MascotState` enum
(`idle` / `wave` / `clap` / `celebrate`) and is the **only** file that needs to
change: load `Art/pip.usdz` with SceneKit (`SCNScene(named:)`) or RealityKit
(`ModelEntity`) and drive the same four states. No call sites change.

`Views/WordCard.swift` and `Views/CelebrationView.swift` both carry an
`ART SWAP POINT` comment marking exactly where the emoji placeholder becomes
the word's 3D model thumbnail.

## Rule

Nothing lands in the game until its renders are judged good — same rule as the
web demo's art pipeline.
