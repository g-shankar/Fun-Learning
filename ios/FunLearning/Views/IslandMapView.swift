import SwiftUI

// MARK: - Letters Island: winding journey map with A–Z lesson nodes

struct IslandMapView: View {
    @ObservedObject var gameState: GameState
    @State private var letterCase: LetterCase = .upper
    @State private var activeLesson: LetterLesson? = nil

    private var lessons: [LetterLesson] { LessonData.lessons(for: letterCase) }
    private var unlocked: Int { gameState.unlockedCount(for: letterCase) }

    var body: some View {
        NavigationStack {
            ZStack {
                // Island backdrop.
                LinearGradient(colors: [Color(red: 0.55, green: 0.83, blue: 1.0),
                                        Color(red: 0.72, green: 0.93, blue: 0.75)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                SparklesView(count: 16)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            header
                                .padding(.top, 12)

                            Picker("Letter case", selection: $letterCase) {
                                ForEach(LetterCase.allCases, id: \.self) { c in
                                    Text("\(c.rawValue) A–Z").tag(c)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 8)
                            .onChange(of: letterCase) { _ in
                                gameState.narrator.speak(
                                    letterCase == .upper
                                    ? "Capital letters!" : "Small letters!")
                            }

                            mapCanvas
                        }
                    }
                    .onAppear {
                        // Start scrolled at the current lesson.
                        let target = max(0, min(unlocked - 1, lessons.count - 1))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            proxy.scrollTo("node-\(target)", anchor: .center)
                        }
                        gameState.narrator.speak("Welcome to Letters Island! Pick a letter!")
                    }
                }
            }
            .navigationDestination(item: $activeLesson) { lesson in
                TracingView(lesson: lesson, letterCase: letterCase,
                            gameState: gameState,
                            onNext: nextLesson(after: lesson))
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Letters Island")
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text("\(totalStars)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            Spacer()
            MascotView(state: .wave, size: 84)
        }
        .padding(.horizontal, 20)
    }

    private var totalStars: Int {
        gameState.stars.values.reduce(0, +)
    }

    // MARK: Winding map

    private var mapCanvas: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let rowH: CGFloat = 120
            let h = rowH * CGFloat(lessons.count) + 80
            ZStack {
                // Winding path through the node centers.
                Path { p in
                    let steps = 220
                    for i in 0..<steps {
                        let f = Double(i) / Double(steps - 1) * Double(lessons.count - 1)
                        let i0 = min(lessons.count - 1, Int(f))
                        let i1 = min(lessons.count - 1, i0 + 1)
                        let fr = f - Double(i0)
                        let a = nodeCenter(index: i0, width: w, rowH: rowH)
                        let b = nodeCenter(index: i1, width: w, rowH: rowH)
                        let pt = CGPoint(x: a.x + (b.x - a.x) * fr,
                                         y: a.y + (b.y - a.y) * fr)
                        if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                    }
                }
                .stroke(Color(red: 0.95, green: 0.78, blue: 0.45),
                        style: StrokeStyle(lineWidth: 26, lineCap: .round))
                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)

                // Nodes.
                ForEach(lessons.indices, id: \.self) { i in
                    let lesson = lessons[i]
                    let c = nodeCenter(index: i, width: w, rowH: rowH)
                    LessonNode(lesson: lesson,
                               state: nodeState(i),
                               stars: gameState.stars[lesson.id] ?? 0,
                               center: c) {
                        if i < unlocked {
                            activeLesson = lesson
                            gameState.narrator.speak("Letter \(lesson.char)!")
                        }
                    }
                    .id("node-\(i)")
                }

                // Pip cheering at the current stop.
                if unlocked - 1 < lessons.count {
                    let c = nodeCenter(index: max(0, unlocked - 1), width: w, rowH: rowH)
                    MascotView(state: .idle, size: 72)
                        .position(x: min(w - 50, c.x + 74), y: c.y - 8)
                }
            }
            .frame(height: h)
        }
        .frame(height: 120 * 26 + 80)
    }

    private func nodeCenter(index i: Int, width w: CGFloat, rowH: CGFloat) -> CGPoint {
        let t = Double(i) / Double(max(1, lessons.count - 1))
        let x = w * 0.5 + sin(t * .pi * 4.0) * w * 0.30
        let y = 60 + CGFloat(t) * rowH * CGFloat(lessons.count - 1)
        return CGPoint(x: x, y: y)
    }

    private func nodeState(_ i: Int) -> LessonNodeState {
        if i < unlocked {
            return gameState.stars[lessons[i].id] != nil ? .done : .current
        }
        return .locked
    }

    private func nextLesson(after lesson: LetterLesson) -> (() -> Void)? {
        guard let i = lessons.firstIndex(of: lesson),
              i + 1 < lessons.count, i + 1 < unlocked else { return nil }
        return { activeLesson = lessons[i + 1] }
    }
}

enum LessonNodeState { case locked, current, done }

struct LessonNode: View {
    let lesson: LetterLesson
    let state: LessonNodeState
    let stars: Int
    let center: CGPoint
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(nodeFill)
                    .frame(width: 76, height: 76)
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.85), lineWidth: 4)
                    )
                if state == .locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white.opacity(0.85))
                } else {
                    Text(lesson.char)
                        .font(.system(size: 38, weight: .black))
                        .foregroundColor(.white)
                }
                if state == .done && stars > 0 {
                    HStack(spacing: 1) {
                        ForEach(0..<min(3, stars), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(4)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Capsule())
                    .offset(y: 34)
                }
            }
            .scaleEffect(state == .current ? 1.12 : 1.0)
        }
        .buttonStyle(.plain)
        .position(center)
        .disabled(state == .locked)
    }

    private var nodeFill: AnyShapeStyle {
        switch state {
        case .locked:
            return AnyShapeStyle(Color.gray.opacity(0.55))
        case .current:
            return AnyShapeStyle(LinearGradient(
                colors: [.orange, Color(red: 1, green: 0.55, blue: 0.3)],
                startPoint: .top, endPoint: .bottom))
        case .done:
            return AnyShapeStyle(Color(red: 0.35, green: 0.75, blue: 0.45))
        }
    }
}
