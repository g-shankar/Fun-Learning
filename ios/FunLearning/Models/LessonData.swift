import Foundation
import CoreGraphics

// MARK: - Stroke model
//
// A stroke is authored as a compact string of normalized points:
//   "0.5,0.05 0.32,0.5 0.15,0.95"
// Coordinates run 0...1 across the tracing square, y pointing down.
// The tracing engine resamples these into smooth curves (see Geometry.swift).

struct StrokeDef {
    let raw: String

    var points: [CGPoint] {
        raw.split(separator: " ").compactMap { pair in
            let xy = pair.split(separator: ",")
            guard xy.count == 2,
                  let x = Double(xy[0]), let y = Double(xy[1]) else { return nil }
            return CGPoint(x: x, y: y)
        }
    }
}

// MARK: - Lesson

struct LetterLesson: Identifiable, Hashable {
    /// e.g. "A-upper" / "a-lower"
    let id: String
    let char: String
    let strokes: [StrokeDef]
    let word: String
    /// Placeholder art until the Blender 3D word-models land (see Art/README.md).
    let emoji: String

    static func == (lhs: LetterLesson, rhs: LetterLesson) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum LetterCase: String, CaseIterable {
    case upper = "Capital"
    case lower = "Small"
}

// MARK: - Data

enum LessonData {

    static func lessons(for letterCase: LetterCase) -> [LetterLesson] {
        letterCase == .upper ? upper : lower
    }

    // Stroke orders follow standard print-teaching order.
    // Capitals live in y 0.05 (cap top) ... 0.95 (baseline).
    static let upper: [LetterLesson] = [
        LetterLesson(id: "A-upper", char: "A", strokes: [
            StrokeDef(raw: "0.5,0.05 0.32,0.5 0.15,0.95"),
            StrokeDef(raw: "0.5,0.05 0.68,0.5 0.85,0.95"),
            StrokeDef(raw: "0.3,0.62 0.5,0.62 0.7,0.62"),
        ], word: "Apple", emoji: "🍎"),
        LetterLesson(id: "B-upper", char: "B", strokes: [
            StrokeDef(raw: "0.3,0.05 0.3,0.5 0.3,0.95"),
            StrokeDef(raw: "0.3,0.05 0.55,0.05 0.68,0.18 0.55,0.32 0.3,0.32"),
            StrokeDef(raw: "0.3,0.32 0.6,0.32 0.75,0.5 0.68,0.75 0.55,0.95 0.3,0.95"),
        ], word: "Bear", emoji: "🐻"),
        LetterLesson(id: "C-upper", char: "C", strokes: [
            StrokeDef(raw: "0.75,0.2 0.55,0.08 0.32,0.15 0.18,0.4 0.18,0.6 0.32,0.85 0.55,0.92 0.75,0.8"),
        ], word: "Cat", emoji: "🐱"),
        LetterLesson(id: "D-upper", char: "D", strokes: [
            StrokeDef(raw: "0.3,0.05 0.3,0.95"),
            StrokeDef(raw: "0.3,0.05 0.55,0.05 0.78,0.25 0.78,0.75 0.55,0.95 0.3,0.95"),
        ], word: "Dog", emoji: "🐶"),
        LetterLesson(id: "E-upper", char: "E", strokes: [
            StrokeDef(raw: "0.35,0.05 0.35,0.95"),
            StrokeDef(raw: "0.35,0.05 0.75,0.05"),
            StrokeDef(raw: "0.35,0.5 0.65,0.5"),
            StrokeDef(raw: "0.35,0.95 0.75,0.95"),
        ], word: "Egg", emoji: "🥚"),
        LetterLesson(id: "F-upper", char: "F", strokes: [
            StrokeDef(raw: "0.35,0.05 0.35,0.95"),
            StrokeDef(raw: "0.35,0.05 0.75,0.05"),
            StrokeDef(raw: "0.35,0.5 0.65,0.5"),
        ], word: "Frog", emoji: "🐸"),
        LetterLesson(id: "G-upper", char: "G", strokes: [
            StrokeDef(raw: "0.75,0.2 0.55,0.08 0.32,0.15 0.18,0.4 0.18,0.6 0.32,0.85 0.55,0.92 0.72,0.82"),
            StrokeDef(raw: "0.72,0.82 0.72,0.55 0.55,0.55"),
        ], word: "Gift", emoji: "🎁"),
        LetterLesson(id: "H-upper", char: "H", strokes: [
            StrokeDef(raw: "0.25,0.05 0.25,0.95"),
            StrokeDef(raw: "0.75,0.05 0.75,0.95"),
            StrokeDef(raw: "0.25,0.5 0.75,0.5"),
        ], word: "Hat", emoji: "🎩"),
        LetterLesson(id: "I-upper", char: "I", strokes: [
            StrokeDef(raw: "0.3,0.05 0.7,0.05"),
            StrokeDef(raw: "0.5,0.05 0.5,0.95"),
            StrokeDef(raw: "0.3,0.95 0.7,0.95"),
        ], word: "Ice cream", emoji: "🍦"),
        LetterLesson(id: "J-upper", char: "J", strokes: [
            StrokeDef(raw: "0.35,0.05 0.65,0.05"),
            StrokeDef(raw: "0.55,0.05 0.55,0.7 0.45,0.88 0.3,0.9"),
        ], word: "Juice box", emoji: "🧃"),
        LetterLesson(id: "K-upper", char: "K", strokes: [
            StrokeDef(raw: "0.3,0.05 0.3,0.95"),
            StrokeDef(raw: "0.68,0.05 0.45,0.42 0.3,0.55"),
            StrokeDef(raw: "0.42,0.5 0.55,0.68 0.72,0.95"),
        ], word: "Kite", emoji: "🪁"),
        LetterLesson(id: "L-upper", char: "L", strokes: [
            StrokeDef(raw: "0.35,0.05 0.35,0.95"),
            StrokeDef(raw: "0.35,0.95 0.7,0.95"),
        ], word: "Lion", emoji: "🦁"),
        LetterLesson(id: "M-upper", char: "M", strokes: [
            StrokeDef(raw: "0.15,0.05 0.15,0.95 0.5,0.35 0.85,0.95 0.85,0.05"),
        ], word: "Monkey", emoji: "🐵"),
        LetterLesson(id: "N-upper", char: "N", strokes: [
            StrokeDef(raw: "0.2,0.05 0.2,0.95 0.8,0.05 0.8,0.95"),
        ], word: "Nest", emoji: "🪹"),
        LetterLesson(id: "O-upper", char: "O", strokes: [
            StrokeDef(raw: "0.5,0.05 0.72,0.12 0.85,0.32 0.85,0.68 0.72,0.88 0.5,0.95 0.28,0.88 0.15,0.68 0.15,0.32 0.28,0.12 0.5,0.05"),
        ], word: "Orange", emoji: "🍊"),
        LetterLesson(id: "P-upper", char: "P", strokes: [
            StrokeDef(raw: "0.3,0.05 0.3,0.95"),
            StrokeDef(raw: "0.3,0.05 0.58,0.05 0.72,0.2 0.62,0.4 0.3,0.42"),
        ], word: "Penguin", emoji: "🐧"),
        LetterLesson(id: "Q-upper", char: "Q", strokes: [
            StrokeDef(raw: "0.5,0.05 0.72,0.12 0.85,0.32 0.85,0.68 0.72,0.88 0.5,0.95 0.28,0.88 0.15,0.68 0.15,0.32 0.28,0.12 0.5,0.05"),
            StrokeDef(raw: "0.6,0.7 0.75,0.9 0.85,1.0"),
        ], word: "Queen", emoji: "👑"),
        LetterLesson(id: "R-upper", char: "R", strokes: [
            StrokeDef(raw: "0.3,0.05 0.3,0.95"),
            StrokeDef(raw: "0.3,0.05 0.58,0.05 0.72,0.2 0.62,0.4 0.3,0.42"),
            StrokeDef(raw: "0.45,0.42 0.6,0.65 0.75,0.95"),
        ], word: "Rabbit", emoji: "🐰"),
        LetterLesson(id: "S-upper", char: "S", strokes: [
            StrokeDef(raw: "0.72,0.15 0.5,0.05 0.28,0.12 0.2,0.3 0.35,0.45 0.6,0.55 0.75,0.7 0.65,0.88 0.45,0.95 0.25,0.88"),
        ], word: "Sun", emoji: "☀️"),
        LetterLesson(id: "T-upper", char: "T", strokes: [
            StrokeDef(raw: "0.2,0.05 0.8,0.05"),
            StrokeDef(raw: "0.5,0.05 0.5,0.95"),
        ], word: "Tiger", emoji: "🐯"),
        LetterLesson(id: "U-upper", char: "U", strokes: [
            StrokeDef(raw: "0.2,0.05 0.2,0.65 0.3,0.88 0.5,0.95 0.7,0.88 0.8,0.65 0.8,0.05"),
        ], word: "Umbrella", emoji: "☂️"),
        LetterLesson(id: "V-upper", char: "V", strokes: [
            StrokeDef(raw: "0.2,0.05 0.5,0.95"),
            StrokeDef(raw: "0.8,0.05 0.5,0.95"),
        ], word: "Van", emoji: "🚐"),
        LetterLesson(id: "W-upper", char: "W", strokes: [
            StrokeDef(raw: "0.1,0.05 0.28,0.95 0.5,0.4 0.72,0.95 0.9,0.05"),
        ], word: "Whale", emoji: "🐳"),
        LetterLesson(id: "X-upper", char: "X", strokes: [
            StrokeDef(raw: "0.2,0.05 0.8,0.95"),
            StrokeDef(raw: "0.8,0.05 0.2,0.95"),
        ], word: "Xylophone", emoji: "🎶"),
        LetterLesson(id: "Y-upper", char: "Y", strokes: [
            StrokeDef(raw: "0.2,0.05 0.42,0.4 0.5,0.5"),
            StrokeDef(raw: "0.8,0.05 0.58,0.4 0.5,0.5 0.5,0.95"),
        ], word: "Yo-yo", emoji: "🪀"),
        LetterLesson(id: "Z-upper", char: "Z", strokes: [
            StrokeDef(raw: "0.2,0.05 0.8,0.05"),
            StrokeDef(raw: "0.8,0.05 0.2,0.95"),
            StrokeDef(raw: "0.2,0.95 0.8,0.95"),
        ], word: "Zebra", emoji: "🦓"),
    ]

    // Lowercase: baseline y=0.75, x-height top y=0.35,
    // ascenders reach 0.05, descenders reach 1.0.
    static let lower: [LetterLesson] = [
        LetterLesson(id: "a-lower", char: "a", strokes: [
            StrokeDef(raw: "0.68,0.45 0.5,0.35 0.32,0.45 0.3,0.62 0.45,0.75 0.62,0.68 0.68,0.55"),
            StrokeDef(raw: "0.68,0.35 0.68,0.75"),
        ], word: "Apple", emoji: "🍎"),
        LetterLesson(id: "b-lower", char: "b", strokes: [
            StrokeDef(raw: "0.32,0.05 0.32,0.75"),
            StrokeDef(raw: "0.32,0.75 0.32,0.55 0.45,0.38 0.62,0.45 0.65,0.62 0.5,0.75 0.32,0.75"),
        ], word: "Bear", emoji: "🐻"),
        LetterLesson(id: "c-lower", char: "c", strokes: [
            StrokeDef(raw: "0.68,0.42 0.5,0.35 0.32,0.45 0.3,0.62 0.45,0.75 0.62,0.7"),
        ], word: "Cat", emoji: "🐱"),
        LetterLesson(id: "d-lower", char: "d", strokes: [
            StrokeDef(raw: "0.32,0.55 0.45,0.38 0.62,0.45 0.65,0.62 0.5,0.75 0.32,0.75 0.32,0.55"),
            StrokeDef(raw: "0.68,0.05 0.68,0.75"),
        ], word: "Dog", emoji: "🐶"),
        LetterLesson(id: "e-lower", char: "e", strokes: [
            StrokeDef(raw: "0.3,0.55 0.5,0.55 0.65,0.5 0.6,0.38 0.45,0.35 0.32,0.45 0.3,0.62 0.45,0.75 0.62,0.72"),
        ], word: "Egg", emoji: "🥚"),
        LetterLesson(id: "f-lower", char: "f", strokes: [
            StrokeDef(raw: "0.62,0.15 0.45,0.08 0.38,0.2 0.38,0.6 0.35,0.8 0.45,0.85"),
            StrokeDef(raw: "0.28,0.4 0.55,0.4"),
        ], word: "Frog", emoji: "🐸"),
        LetterLesson(id: "g-lower", char: "g", strokes: [
            StrokeDef(raw: "0.62,0.45 0.45,0.35 0.3,0.45 0.3,0.62 0.45,0.75 0.62,0.68 0.65,0.55"),
            StrokeDef(raw: "0.65,0.55 0.65,0.85 0.55,1.0 0.4,0.98"),
        ], word: "Gift", emoji: "🎁"),
        LetterLesson(id: "h-lower", char: "h", strokes: [
            StrokeDef(raw: "0.3,0.05 0.3,0.75"),
            StrokeDef(raw: "0.3,0.75 0.3,0.5 0.42,0.38 0.55,0.42 0.58,0.55 0.58,0.75"),
        ], word: "Hat", emoji: "🎩"),
        LetterLesson(id: "i-lower", char: "i", strokes: [
            StrokeDef(raw: "0.5,0.35 0.5,0.75"),
            StrokeDef(raw: "0.5,0.2 0.51,0.21"),
        ], word: "Ice cream", emoji: "🍦"),
        LetterLesson(id: "j-lower", char: "j", strokes: [
            StrokeDef(raw: "0.55,0.35 0.55,0.8 0.48,0.95 0.38,0.97"),
            StrokeDef(raw: "0.55,0.2 0.56,0.21"),
        ], word: "Juice box", emoji: "🧃"),
        LetterLesson(id: "k-lower", char: "k", strokes: [
            StrokeDef(raw: "0.32,0.05 0.32,0.75"),
            StrokeDef(raw: "0.6,0.35 0.42,0.5 0.32,0.58 0.45,0.62 0.62,0.75"),
        ], word: "Kite", emoji: "🪁"),
        LetterLesson(id: "l-lower", char: "l", strokes: [
            StrokeDef(raw: "0.5,0.05 0.48,0.4 0.48,0.7 0.52,0.75"),
        ], word: "Lion", emoji: "🦁"),
        LetterLesson(id: "m-lower", char: "m", strokes: [
            StrokeDef(raw: "0.25,0.35 0.25,0.75"),
            StrokeDef(raw: "0.25,0.75 0.25,0.5 0.35,0.38 0.45,0.42 0.45,0.55 0.45,0.75 0.45,0.5 0.55,0.38 0.65,0.42 0.65,0.75"),
        ], word: "Monkey", emoji: "🐵"),
        LetterLesson(id: "n-lower", char: "n", strokes: [
            StrokeDef(raw: "0.3,0.35 0.3,0.75"),
            StrokeDef(raw: "0.3,0.75 0.3,0.5 0.42,0.38 0.55,0.42 0.58,0.55 0.58,0.75"),
        ], word: "Nest", emoji: "🪹"),
        LetterLesson(id: "o-lower", char: "o", strokes: [
            StrokeDef(raw: "0.5,0.35 0.65,0.42 0.68,0.58 0.55,0.72 0.4,0.72 0.3,0.58 0.32,0.44 0.5,0.35"),
        ], word: "Orange", emoji: "🍊"),
        LetterLesson(id: "p-lower", char: "p", strokes: [
            StrokeDef(raw: "0.32,0.35 0.32,1.0"),
            StrokeDef(raw: "0.32,0.75 0.32,0.55 0.45,0.38 0.62,0.45 0.65,0.62 0.5,0.75 0.32,0.75"),
        ], word: "Penguin", emoji: "🐧"),
        LetterLesson(id: "q-lower", char: "q", strokes: [
            StrokeDef(raw: "0.38,0.55 0.5,0.38 0.65,0.45 0.68,0.62 0.55,0.75 0.38,0.75 0.38,0.55"),
            StrokeDef(raw: "0.68,0.35 0.68,1.0"),
        ], word: "Queen", emoji: "👑"),
        LetterLesson(id: "r-lower", char: "r", strokes: [
            StrokeDef(raw: "0.35,0.35 0.35,0.75"),
            StrokeDef(raw: "0.35,0.5 0.45,0.4 0.58,0.38"),
        ], word: "Rabbit", emoji: "🐰"),
        LetterLesson(id: "s-lower", char: "s", strokes: [
            StrokeDef(raw: "0.62,0.42 0.48,0.35 0.35,0.4 0.33,0.5 0.45,0.58 0.58,0.62 0.6,0.7 0.48,0.75 0.36,0.72"),
        ], word: "Sun", emoji: "☀️"),
        LetterLesson(id: "t-lower", char: "t", strokes: [
            StrokeDef(raw: "0.5,0.15 0.48,0.5 0.45,0.68 0.52,0.75"),
            StrokeDef(raw: "0.32,0.42 0.62,0.42"),
        ], word: "Tiger", emoji: "🐯"),
        LetterLesson(id: "u-lower", char: "u", strokes: [
            StrokeDef(raw: "0.3,0.35 0.3,0.6 0.38,0.72 0.5,0.75 0.58,0.65 0.6,0.5 0.6,0.35"),
        ], word: "Umbrella", emoji: "☂️"),
        LetterLesson(id: "v-lower", char: "v", strokes: [
            StrokeDef(raw: "0.3,0.35 0.45,0.75"),
            StrokeDef(raw: "0.6,0.35 0.45,0.75"),
        ], word: "Van", emoji: "🚐"),
        LetterLesson(id: "w-lower", char: "w", strokes: [
            StrokeDef(raw: "0.2,0.35 0.3,0.75 0.45,0.45 0.6,0.75 0.7,0.35"),
        ], word: "Whale", emoji: "🐳"),
        LetterLesson(id: "x-lower", char: "x", strokes: [
            StrokeDef(raw: "0.32,0.35 0.62,0.75"),
            StrokeDef(raw: "0.62,0.35 0.32,0.75"),
        ], word: "Xylophone", emoji: "🎶"),
        LetterLesson(id: "y-lower", char: "y", strokes: [
            StrokeDef(raw: "0.28,0.35 0.38,0.65 0.5,0.72 0.58,0.6 0.62,0.35"),
            StrokeDef(raw: "0.62,0.35 0.5,0.75 0.4,1.0"),
        ], word: "Yo-yo", emoji: "🪀"),
        LetterLesson(id: "z-lower", char: "z", strokes: [
            StrokeDef(raw: "0.3,0.35 0.65,0.35"),
            StrokeDef(raw: "0.65,0.35 0.3,0.75"),
            StrokeDef(raw: "0.3,0.75 0.65,0.75"),
        ], word: "Zebra", emoji: "🦓"),
    ]
}
