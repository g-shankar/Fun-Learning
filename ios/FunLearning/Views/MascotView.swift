import SwiftUI

// MARK: - Pip the mascot (placeholder art)
//
// The real Pip is being modeled in Blender (see Art/README.md) and will ship
// as a USDZ. ART SWAP POINT: replace the body of this view with a
// SceneKit/RealityKit USDZ loader driven by the same MascotState enum —
// the interface (state + size) stays identical, so no call sites change.

enum MascotState {
    case idle, wave, clap, celebrate
}

struct MascotView: View {
    var state: MascotState = .idle
    var size: CGFloat = 120

    @State private var breathe = false
    @State private var blink = false
    @State private var clapPhase = false
    @State private var jump = false
    @State private var lookX: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            mascot
                .onChange(of: Int(timeline.date.timeIntervalSinceReferenceDate)) { _ in
                    // Gentle idle life: pupils wander, occasional blink.
                    lookX = CGFloat.random(in: -4...4)
                    if Int.random(in: 0..<30) == 0 { doBlink() }
                }
        }
        .frame(width: size, height: size)
        .offset(y: state == .celebrate && jump ? -size * 0.22 : 0)
        .rotationEffect(.degrees(state == .celebrate && jump ? -8 : 0))
        .scaleEffect(breathe ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: breathe)
        .onAppear {
            breathe = true
            switch state {
            case .wave: break // arm wave handled below via clapPhase timer
            case .clap: clapPhase = true
            case .celebrate: jump = true
            case .idle: break
            }
        }
    }

    private func doBlink() {
        blink = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { blink = false }
    }

    // MARK: Pip (placeholder): coral buddy, big eyes, smile, hair tuft.

    private var mascot: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                // Body
                Ellipse()
                    .fill(LinearGradient(colors: [Color(red: 1, green: 0.62, blue: 0.47),
                                                 Color(red: 1, green: 0.45, blue: 0.32)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: s * 0.78, height: s * 0.86)
                    .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
                // Belly
                Ellipse()
                    .fill(Color(red: 1, green: 0.9, blue: 0.8))
                    .frame(width: s * 0.5, height: s * 0.55)
                    .offset(y: s * 0.14)
                // Hair tuft
                ForEach(-1...1, id: \.self) { i in
                    Capsule()
                        .fill(Color(red: 0.85, green: 0.32, blue: 0.22))
                        .frame(width: s * 0.07, height: s * 0.2)
                        .offset(x: CGFloat(i) * s * 0.09, y: -s * 0.5)
                        .rotationEffect(.degrees(Double(i) * 18))
                }
                // Arms
                arm(side: -1, s: s)
                arm(side: 1, s: s)
                // Feet
                ForEach([-1, 1], id: \.self) { i in
                    Ellipse()
                        .fill(Color(red: 0.9, green: 0.38, blue: 0.26))
                        .frame(width: s * 0.2, height: s * 0.12)
                        .offset(x: CGFloat(i) * s * 0.2, y: s * 0.44)
                }
                // Eyes
                ForEach([-1, 1], id: \.self) { i in
                    ZStack {
                        Circle().fill(.white)
                            .frame(width: s * 0.2, height: s * 0.2)
                        Circle().fill(Color(white: 0.15))
                            .frame(width: s * 0.09, height: s * 0.09)
                            .offset(x: lookX, y: s * 0.01)
                        Circle().fill(.white)
                            .frame(width: s * 0.03, height: s * 0.03)
                            .offset(x: lookX - s * 0.015, y: -s * 0.015)
                    }
                    .offset(x: CGFloat(i) * s * 0.17, y: -s * 0.12)
                    .scaleEffect(y: blink ? 0.1 : 1.0)
                    .animation(.easeInOut(duration: 0.12), value: blink)
                }
                // Blush
                ForEach([-1, 1], id: \.self) { i in
                    Ellipse()
                        .fill(Color.pink.opacity(0.55))
                        .frame(width: s * 0.12, height: s * 0.08)
                        .offset(x: CGFloat(i) * s * 0.28, y: s * 0.02)
                }
                // Smile
                Path { p in
                    p.move(to: CGPoint(x: -s * 0.12, y: s * 0.08))
                    p.addQuadCurve(to: CGPoint(x: s * 0.12, y: s * 0.08),
                                   control: CGPoint(x: 0, y: s * 0.22))
                }
                .stroke(Color(red: 0.5, green: 0.2, blue: 0.15), lineWidth: s * 0.035)
                .frame(width: s, height: s)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func arm(side: CGFloat, s: CGFloat) -> some View {
        let clapping = (state == .clap || state == .wave)
        return Ellipse()
            .fill(Color(red: 1, green: 0.5, blue: 0.36))
            .frame(width: s * 0.14, height: s * 0.34)
            .offset(x: side * s * (clapping && clapPhase ? 0.18 : 0.44),
                    y: s * 0.1)
            .rotationEffect(.degrees(side * (clapping && clapPhase ? -35 : -18)))
            .animation(clapping
                       ? .easeInOut(duration: 0.35).repeatForever(autoreverses: true)
                       : .default,
                       value: clapPhase)
    }
}
