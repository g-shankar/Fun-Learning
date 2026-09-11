import Foundation
import CoreGraphics
import Combine

// MARK: - Tracing engine: adaptive magnetic guidance
//
// The child never gets "rejected". When their finger is near the stroke path,
// progress advances and the ink tip is magnetized toward the path. When they
// drift away, a helper hand appears and gently points at the next target.

final class TracingViewModel: ObservableObject {
    let lesson: LetterLesson
    let letterCase: LetterCase
    let curves: [[CGPoint]]

    @Published var strokeIndex: Int = 0
    @Published var frontier: Int = 0
    @Published var brush: Brush = .coral
    @Published var brushForStroke: [Int: Brush] = [:]
    @Published var completedCount: Int = 0
    @Published var showHelperHand: Bool = false
    @Published var isCelebrating: Bool = false
    @Published var tipUnitPoint: CGPoint? = nil

    private(set) var drifts: Int = 0

    private var lastProgress = Date()
    private var lastNudge = Date.distantPast
    private var lastDriftCount = Date.distantPast

    private let engageDistance: CGFloat = 0.14
    private let startWindow = 24

    private let gameState: GameState
    private let narrator: Narrator
    private let music: MusicPlayer

    init(lesson: LetterLesson, letterCase: LetterCase, gameState: GameState) {
        self.lesson = lesson
        self.letterCase = letterCase
        self.curves = lesson.strokes.map { Geometry.resample($0.points) }
        self.gameState = gameState
        self.narrator = gameState.narrator
        self.music = gameState.music
    }

    var totalStrokes: Int { curves.count }
    var isFinished: Bool { completedCount >= curves.count }

    var currentCurve: [CGPoint] {
        guard strokeIndex < curves.count else { return [] }
        return curves[strokeIndex]
    }

    // MARK: Touch handling (points in unit space, y down)

    func touch(at p: CGPoint) {
        guard !isCelebrating, strokeIndex < curves.count else { return }
        let curve = curves[strokeIndex]
        guard !curve.isEmpty else { return }

        // Dot strokes (i/j dots): a tap near the dot completes it.
        if curve.count <= 1 {
            if hypot(curve[0].x - p.x, curve[0].y - p.y) < 0.25 {
                completeStroke()
            }
            return
        }

        let (idx, dist) = Geometry.nearestIndex(on: curve, to: p)

        // Must begin near the stroke start — no skipping ahead.
        if frontier == 0 && idx > startWindow && dist < engageDistance {
            return
        }

        if dist <= engageDistance && idx >= frontier - 10 && idx <= frontier + 18 {
            if idx > frontier {
                frontier = idx
                lastProgress = Date()
                showHelperHand = false
            }
            // Magnetic tip: blend finger position toward the path.
            let target = curve[min(frontier, curve.count - 1)]
            tipUnitPoint = CGPoint(x: p.x + (target.x - p.x) * 0.45,
                                   y: p.y + (target.y - p.y) * 0.45)
            if frontier >= curve.count - 4 {
                completeStroke()
            }
        } else {
            // Drifted off — count it (throttled) and show the helper hand.
            if Date().timeIntervalSince(lastDriftCount) > 0.6 {
                drifts += 1
                lastDriftCount = Date()
            }
            showHelperHand = true
            tipUnitPoint = curve[min(frontier, curve.count - 1)]
        }
    }

    func endTouch() {
        tipUnitPoint = nil
    }

    /// Called on a timer from the view: idle detection -> helper hand + voice.
    func tick() {
        guard !isCelebrating, !isFinished else { return }
        if Date().timeIntervalSince(lastProgress) > 2.5 {
            showHelperHand = true
            if Date().timeIntervalSince(lastNudge) > 9 {
                lastNudge = Date()
                narrator.gentleNudge()
            }
        }
    }

    // MARK: Stroke lifecycle

    private func completeStroke() {
        brushForStroke[strokeIndex] = brush
        completedCount += 1
        music.playChime()
        showHelperHand = false
        tipUnitPoint = nil

        if completedCount >= curves.count {
            finishLesson()
        } else {
            strokeIndex += 1
            frontier = 0
            lastProgress = Date()
            if strokeIndex % 2 == 0 {
                narrator.praise()
            } else {
                narrator.instructStroke(number: strokeIndex + 1)
            }
        }
    }

    private func finishLesson() {
        isCelebrating = true
        narrator.celebrate(lesson: lesson)
        gameState.completeLesson(lesson, letterCase: letterCase, drifts: drifts)
    }

    func replay() {
        strokeIndex = 0
        frontier = 0
        completedCount = 0
        brushForStroke = [:]
        showHelperHand = false
        isCelebrating = false
        tipUnitPoint = nil
        drifts = 0
        lastProgress = Date()
        narrator.introduce(lesson: lesson, letterCase: letterCase)
    }
}
