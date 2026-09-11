import SwiftUI

// MARK: - Tracing lesson screen

struct TracingView: View {
    let lesson: LetterLesson
    let letterCase: LetterCase
    @ObservedObject var gameState: GameState
    var onNext: (() -> Void)?

    @StateObject private var vm: TracingViewModel
    @State private var mascotState: MascotState = .wave
    @Environment(\.dismiss) private var dismiss

    init(lesson: LetterLesson, letterCase: LetterCase,
         gameState: GameState, onNext: (() -> Void)? = nil) {
        self.lesson = lesson
        self.letterCase = letterCase
        self.gameState = gameState
        self.onNext = onNext
        _vm = StateObject(wrappedValue: TracingViewModel(lesson: lesson,
                                                         letterCase: letterCase,
                                                         gameState: gameState))
    }

    var body: some View {
        ZStack {
            // Cheerful sky background.
            LinearGradient(colors: [Color(red: 0.62, green: 0.86, blue: 1.0),
                                    Color(red: 0.85, green: 0.95, blue: 1.0)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            SparklesView(count: 12)

            VStack(spacing: 10) {
                // Header: back, title, Pip.
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Trace the \(letterCase == .upper ? "capital" : "small") \(lesson.char)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                        .shadow(radius: 4)

                    Spacer()

                    MascotView(state: mascotState, size: 64)
                }
                .padding(.horizontal, 16)

                // Tracing board.
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(red: 1, green: 0.98, blue: 0.94))
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                    TracingCanvas(vm: vm)
                        .padding(18)
                }
                .padding(.horizontal, 16)
                .frame(maxHeight: .infinity)

                // Stroke progress dots.
                HStack(spacing: 8) {
                    ForEach(0..<vm.totalStrokes, id: \.self) { i in
                        Circle()
                            .fill(i < vm.completedCount ? Color.green : Color.white.opacity(0.7))
                            .frame(width: 12, height: 12)
                    }
                }

                BrushPicker(brush: $vm.brush)

                WordCard(lesson: lesson, gameState: gameState)
                    .padding(.bottom, 8)
            }
            .padding(.top, 8)

            if vm.isCelebrating {
                CelebrationView(lesson: lesson, gameState: gameState,
                                onReplay: { vm.replay() },
                                onNext: onNext)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            vm.replay() // speaks the intro via narrator
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                if !vm.isCelebrating { mascotState = .idle }
            }
        }
        .onChange(of: vm.completedCount) { count in
            guard count > 0, !vm.isCelebrating else { return }
            mascotState = .clap
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                if !vm.isCelebrating { mascotState = .idle }
            }
        }
    }
}
