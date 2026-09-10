import SwiftUI

// MARK: - Root: world tabs + music/voice controls

struct RootView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        NavigationStack {
            TabView {
            IslandMapView(gameState: gameState)
                .tabItem { Label("Letters", systemImage: "textformat.abc") }
            StubWorldView(title: "Numbers", icon: "🔢",
                          blurb: "Count, trace, and play with numbers 1 to 20.",
                          gameState: gameState)
                .tabItem { Label("Numbers", systemImage: "number") }
            StubWorldView(title: "Shapes", icon: "🔷",
                          blurb: "Circles, squares, stars — trace every shape!",
                          gameState: gameState)
                .tabItem { Label("Shapes", systemImage: "square.on.circle") }
            StubWorldView(title: "Words", icon: "📖",
                          blurb: "Little words built from the letters you traced.",
                          gameState: gameState)
                .tabItem { Label("Words", systemImage: "book.fill") }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 4) {
                    Button {
                        gameState.voiceEnabled.toggle()
                        gameState.narrator.enabled = gameState.voiceEnabled
                        gameState.save()
                        if gameState.voiceEnabled {
                            gameState.narrator.speak("Voice on!")
                        }
                    } label: {
                        Image(systemName: gameState.voiceEnabled
                              ? "person.wave.2.fill" : "person.wave.2")
                    }
                    Button {
                        gameState.musicMuted.toggle()
                        gameState.music.muted = gameState.musicMuted
                        gameState.save()
                        if !gameState.musicMuted { gameState.music.start() }
                    } label: {
                        Image(systemName: gameState.musicMuted
                              ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    }
                }
                .font(.system(size: 20))
            }
        }
        .onAppear {
            gameState.music.muted = gameState.musicMuted
            gameState.music.start()
        }
    }
}
