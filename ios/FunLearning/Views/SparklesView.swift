import SwiftUI

// MARK: - Gentle drifting sparkles (ambient liveliness, toddler-calm)

struct SparklesView: View {
    var count: Int = 18
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for k in 0..<count {
                    let h1 = Double((k * 137) % 1000) / 1000.0
                    let h2 = Double((k * 251) % 1000) / 1000.0
                    let speed = 0.05 + h1 * 0.08
                    let y = size.height - ((t * speed * size.height + h2 * size.height)
                        .truncatingRemainder(dividingBy: size.height + 40)) + 20
                    let x = h1 * size.width + 14 * sin(t * 0.8 + h2 * 9.0)
                    let tw = 0.25 + 0.55 * abs(sin(t * 1.8 + h1 * 20.0))
                    let r = 3 + h2 * 5
                    var star = Path()
                    star.move(to: CGPoint(x: x, y: y - r * 1.6))
                    star.addQuadCurve(to: CGPoint(x: x, y: y + r * 1.6),
                                      control: CGPoint(x: x + r * 0.3, y: y))
                    star.move(to: CGPoint(x: x - r * 1.6, y: y))
                    star.addQuadCurve(to: CGPoint(x: x + r * 1.6, y: y),
                                      control: CGPoint(x: x, y: y + r * 0.3))
                    ctx.stroke(star, with: .color(.white.opacity(0.75 * tw)), lineWidth: 2)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
