import CoreGraphics
import SwiftUI

// MARK: - Curve geometry for the tracing engine

enum Geometry {

    /// Resample a raw authored polyline into a smooth, evenly-walkable curve
    /// using Catmull-Rom interpolation. Degenerate (dot) strokes collapse
    /// to a single repeated point.
    static func resample(_ raw: [CGPoint], samplesPerSegment: Int = 14) -> [CGPoint] {
        guard raw.count >= 2 else { return raw }
        // Dot stroke (e.g. the dot of i/j): all points ~identical.
        let span = raw.dropFirst().map { hypot($0.x - raw[0].x, $0.y - raw[0].y) }.max() ?? 0
        if span < 0.004 { return [raw[0]] }

        var out: [CGPoint] = []
        let pts = [raw[0]] + raw + [raw.last!]
        for i in 1..<(pts.count - 2) {
            let p0 = pts[i - 1], p1 = pts[i], p2 = pts[i + 1], p3 = pts[i + 2]
            for s in 0..<samplesPerSegment {
                let t = CGFloat(s) / CGFloat(samplesPerSegment)
                out.append(catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: t))
            }
        }
        out.append(raw.last!)
        return out
    }

    private static func catmullRom(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, t: CGFloat) -> CGPoint {
        let t2 = t * t, t3 = t2 * t
        func c(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> CGFloat {
            0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (-a + 3 * b - 3 * c + d) * t3)
        }
        return CGPoint(x: c(p0.x, p1.x, p2.x, p3.x), y: c(p0.y, p1.y, p2.y, p3.y))
    }

    /// Index of the resampled point nearest to `p`, and its distance.
    static func nearestIndex(on curve: [CGPoint], to p: CGPoint) -> (index: Int, distance: CGFloat) {
        var best = 0
        var bestD = CGFloat.greatestFiniteMagnitude
        for (i, q) in curve.enumerated() {
            let d = hypot(q.x - p.x, q.y - p.y)
            if d < bestD { bestD = d; best = i }
        }
        return (best, bestD)
    }

    /// Build a SwiftUI Path through unit-space points scaled into `rect`.
    static func path(through points: [CGPoint], in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: CGPoint(x: rect.minX + first.x * rect.width,
                              y: rect.minY + first.y * rect.height))
        for p in points.dropFirst() {
            path.addLine(to: CGPoint(x: rect.minX + p.x * rect.width,
                                     y: rect.minY + p.y * rect.height))
        }
        return path
    }

    static func point(_ p: CGPoint, in rect: CGRect) -> CGPoint {
        CGPoint(x: rect.minX + p.x * rect.width, y: rect.minY + p.y * rect.height)
    }
}
