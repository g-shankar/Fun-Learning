import SwiftUI

// MARK: - Tracing canvas: ghost letter, 3D brush fill, helper hand
//
// Draws in unit space (0...1, y down) scaled into the view rect.
// Wrapped in a TimelineView so glitter/sparkles stay alive (toddler-calm).

struct TracingCanvas: View {
    @ObservedObject var vm: TracingViewModel

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size)
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    draw(ctx: &ctx, rect: rect, time: time)
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            let s = geo.size
                            guard s.width > 0, s.height > 0 else { return }
                            vm.touch(at: CGPoint(x: value.location.x / s.width,
                                                 y: value.location.y / s.height))
                        }
                        .onEnded { _ in vm.endTouch() }
                )
            }
            .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
                vm.tick()
            }
        }
    }

    // MARK: Drawing

    private func draw(ctx: inout GraphicsContext, rect: CGRect, time: Double) {
        let w = rect.width
        let lineW = w * 0.085

        // 1. Ghost letter: upcoming strokes full, active stroke's remainder.
        for i in vm.strokeIndex..<vm.curves.count {
            let curve = vm.curves[i]
            let pts: [CGPoint]
            if i == vm.strokeIndex {
                pts = Array(curve[min(vm.frontier, curve.count - 1)...])
            } else {
                pts = curve
            }
            guard pts.count > 1 else {
                // Dot ghost (or the last nub of the active stroke).
                if let d = pts.first {
                    let c = Geometry.point(d, in: rect)
                    ctx.fill(Path(ellipseIn: CGRect(x: c.x - lineW * 0.32, y: c.y - lineW * 0.32,
                                                   width: lineW * 0.64, height: lineW * 0.64)),
                             with: .color(.gray.opacity(0.35)))
                }
                continue
            }
            let path = Geometry.path(through: pts, in: rect)
            ctx.stroke(path, with: .color(.gray.opacity(0.22)), lineWidth: lineW)
            ctx.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: lineW * 0.45)
        }

        // 2. Completed strokes: 3D brush fill in each stroke's own brush.
        for i in 0..<vm.completedCount where i < vm.curves.count {
            let brush = vm.brushForStroke[i] ?? .coral
            drawInk(ctx: &ctx, rect: rect, points: vm.curves[i],
                    brush: brush, width: lineW, time: time, seed: i * 97)
        }

        // 3. Active stroke progress.
        if vm.strokeIndex < vm.curves.count {
            let curve = vm.curves[vm.strokeIndex]
            if curve.count > 1 {
                let pts = Array(curve[0...min(vm.frontier, curve.count - 1)])
                if pts.count > 1 {
                    drawInk(ctx: &ctx, rect: rect, points: pts,
                            brush: vm.brush, width: lineW, time: time, seed: 7)
                }
            }
        }

        // 4. Numbered stroke-order dots at upcoming stroke starts.
        for i in vm.strokeIndex..<vm.curves.count {
            guard let start = vm.curves[i].first else { continue }
            let c = Geometry.point(start, in: rect)
            let r = w * 0.045
            let pulse = 1.0 + 0.08 * sin(time * 3.0 + Double(i))
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - r * pulse, y: c.y - r * pulse,
                                            width: r * 2 * pulse, height: r * 2 * pulse)),
                     with: .color(i == vm.strokeIndex ? Color.orange : Color.gray.opacity(0.6)))
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - r * 0.72, y: c.y - r * 0.72,
                                            width: r * 1.44, height: r * 1.44)),
                     with: .color(.white))
            ctx.draw(Text("\(i + 1)")
                .font(.system(size: r * 1.15, weight: .bold))
                .foregroundColor(i == vm.strokeIndex ? .orange : .gray),
                     at: c)
        }

        // 5. Magnetic ink tip.
        if let tip = vm.tipUnitPoint {
            let c = Geometry.point(tip, in: rect)
            let r = lineW * 0.42 * (1.0 + 0.06 * sin(time * 6.0))
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                     with: .radialGradient(
                        Gradient(colors: [.white, vm.brush.color]),
                        center: c, startRadius: 0, endRadius: r))
        }

        // 6. Helper hand: appears where the child should go next.
        if vm.showHelperHand, vm.strokeIndex < vm.curves.count {
            let curve = vm.curves[vm.strokeIndex]
            let target = curve[min(vm.frontier + 6, curve.count - 1)]
            let c = Geometry.point(target, in: rect)
            let bob = 6.0 * sin(time * 4.0)
            ctx.draw(Text("👆").font(.system(size: w * 0.11)),
                     at: CGPoint(x: c.x, y: c.y - w * 0.09 + bob))
        }
    }

    // MARK: 3D-look ink

    private func drawInk(ctx: inout GraphicsContext, rect: CGRect, points: [CGPoint],
                         brush: Brush, width: CGFloat, time: Double, seed: Int) {
        guard points.count > 1 else { return }
        let path = Geometry.path(through: points, in: rect)

        if brush == .rainbow {
            // Hue shifts along the stroke.
            let chunks = 14
            for s in 0..<chunks {
                let a = s * points.count / chunks
                let b = min(points.count - 1, (s + 1) * points.count / chunks)
                guard b > a else { continue }
                let seg = Geometry.path(through: Array(points[a...b]), in: rect)
                let hue = Double(s) / Double(chunks)
                inkPasses(ctx: &ctx, path: seg, base: Color(hue: hue, saturation: 0.75, brightness: 0.95),
                          dark: Color(hue: hue, saturation: 0.8, brightness: 0.6), width: width)
            }
        } else {
            inkPasses(ctx: &ctx, path: path, base: brush.color, dark: brush.dark, width: width)
        }

        if brush == .glitter {
            drawGlitter(ctx: &ctx, rect: rect, points: points, width: width, time: time, seed: seed)
        }
    }

    /// Shadow + base + top highlight = raised glossy 3D finish.
    private func inkPasses(ctx: inout GraphicsContext, path: Path,
                           base: Color, dark: Color, width: CGFloat) {
        let shadow = path.offsetBy(dx: 0, dy: width * 0.14)
        ctx.stroke(shadow, with: .color(.black.opacity(0.22)),
                    lineWidth: width * 1.12)
        ctx.stroke(path, with: .color(dark), lineWidth: width)
        ctx.stroke(path, with: .color(base), lineWidth: width * 0.72)
        let hi = path.offsetBy(dx: 0, dy: -width * 0.16)
        ctx.stroke(hi, with: .color(.white.opacity(0.5)), lineWidth: width * 0.28)
    }

    private func drawGlitter(ctx: inout GraphicsContext, rect: CGRect, points: [CGPoint],
                             width: CGFloat, time: Double, seed: Int) {
        let n = 26
        for k in 0..<n {
            // Deterministic pseudo-random scatter along the stroke.
            let h1 = Double((seed * 31 + k * 57) % 1000) / 1000.0
            let h2 = Double((seed * 17 + k * 91) % 1000) / 1000.0
            let idx = Int(h1 * Double(points.count - 1))
            var p = Geometry.point(points[idx], in: rect)
            p.x += (h2 - 0.5) * width * 1.1
            p.y += (Double((seed + k * 13) % 1000) / 1000.0 - 0.5) * width * 1.1
            let twinkle = 0.35 + 0.65 * abs(sin(time * 2.5 + h1 * 12.0))
            let r = width * 0.10 * twinkle + 1
            // 4-point sparkle.
            var star = Path()
            star.move(to: CGPoint(x: p.x, y: p.y - r * 1.8))
            star.addQuadCurve(to: CGPoint(x: p.x, y: p.y + r * 1.8),
                              control: CGPoint(x: p.x + r * 0.35, y: p.y))
            star.move(to: CGPoint(x: p.x - r * 1.8, y: p.y))
            star.addQuadCurve(to: CGPoint(x: p.x + r * 1.8, y: p.y),
                              control: CGPoint(x: p.x, y: p.y + r * 0.35))
            ctx.stroke(star, with: .color(.white.opacity(0.9 * twinkle)), lineWidth: max(1.5, r * 0.5))
        }
    }
}
