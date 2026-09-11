import SwiftUI

// MARK: - Stub worlds (Numbers / Shapes / Words) — coming soon

struct StubWorldView: View {
    let title: String
    let icon: String
    let blurb: String
    @ObservedObject var gameState: GameState

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.62, green: 0.86, blue: 1.0),
                                    Color(red: 0.88, green: 0.96, blue: 0.9)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            SparklesView(count: 14)

            VStack(spacing: 20) {
                Spacer()
                Text(icon).font(.system(size: 90))
                Text(title)
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                Text(blurb)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .shadow(radius: 3)
                MascotView(state: .wave, size: 130)
                Text("Coming soon to the island!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 6)
                Spacer()
            }
        }
    }
}
