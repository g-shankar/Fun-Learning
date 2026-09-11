import SwiftUI

// MARK: - "A is for Apple" word card, always visible while tracing

struct WordCard: View {
    let lesson: LetterLesson
    @ObservedObject var gameState: GameState

    @State private var bounce = false

    var body: some View {
        HStack(spacing: 14) {
            // ART SWAP POINT: replace Text(emoji) with the Blender 3D word-model
            // thumbnail / USDZ preview when the model library lands.
            Text(lesson.emoji)
                .font(.system(size: 52))
                .scaleEffect(bounce ? 1.12 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: bounce)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(lesson.char) is for")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                Text(lesson.word)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)
            }

            Spacer()

            Button {
                bounce.toggle()
                gameState.narrator.sayWord(for: lesson)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(
                        LinearGradient(colors: [Color.orange, Color(red: 1, green: 0.55, blue: 0.3)],
                                       startPoint: .top, endPoint: .bottom))
                    .clipShape(Circle())
                    .shadow(color: .orange.opacity(0.4), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Hear the word \(lesson.word)")
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4))
        .padding(.horizontal, 16)
    }
}
