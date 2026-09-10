import SwiftUI

// MARK: - Lesson-complete celebration: stars, Pip, word reveal

struct CelebrationView: View {
    let lesson: LetterLesson
    @ObservedObject var gameState: GameState
    var onReplay: () -> Void
    var onNext: (() -> Void)?

    @State private var starsShown = 0

    private var earned: Int { gameState.stars[lesson.id] ?? 3 }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Great job!")
                    .font(.system(size: 44, weight: .black))
                    .foregroundColor(.white)
                    .shadow(radius: 6)

                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < starsShown ? "star.fill" : "star")
                            .font(.system(size: 46))
                            .foregroundColor(i < starsShown ? .yellow : .white.opacity(0.4))
                            .scaleEffect(i < starsShown ? 1 : 0.8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.5)
                                .delay(Double(i) * 0.25), value: starsShown)
                    }
                }

                MascotView(state: .celebrate, size: 150)

                // Word reveal (emoji placeholder -> 3D model later, see WordCard).
                VStack(spacing: 4) {
                    Text(lesson.emoji).font(.system(size: 64))
                    Text("\(lesson.char) is for \(lesson.word)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                HStack(spacing: 16) {
                    Button {
                        onReplay()
                    } label: {
                        Label("Again", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .buttonStyle(CelebrationButtonStyle(color: .white, fg: .orange))

                    if let onNext {
                        Button {
                            onNext()
                        } label: {
                            Label("Next", systemImage: "arrow.right")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .buttonStyle(CelebrationButtonStyle(color: .orange, fg: .white))
                    }
                }
            }
            .padding(30)
            .onAppear {
                gameState.narrator.sayWord(for: lesson)
                for i in 1...earned {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.35) {
                        starsShown = i
                    }
                }
            }
        }
    }
}

struct CelebrationButtonStyle: ButtonStyle {
    var color: Color
    var fg: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(fg)
            .padding(.horizontal, 26)
            .padding(.vertical, 14)
            .background(color)
            .clipShape(Capsule())
            .shadow(radius: 6)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6),
                       value: configuration.isPressed)
    }
}
