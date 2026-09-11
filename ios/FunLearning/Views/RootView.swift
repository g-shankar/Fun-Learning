import SwiftUI

// MARK: - Root: world tabs + music/voice controls

struct RootView: View {
    @ObservedObject var gameState: GameState
    @State private var showVoicePicker = false

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
                    if !gameState.isUnlocked {
                        Button {
                            gameState.paywallRequested = true
                        } label: {
                            Image(systemName: "lock.fill")
                        }
                        .accessibilityLabel("Unlock the full app")
                    }
                    Button {
                        gameState.voiceEnabled.toggle()
                        gameState.narrator.enabled = gameState.voiceEnabled
                        gameState.save()
                        if gameState.voiceEnabled {
                            gameState.narrator.welcome()
                        }
                    } label: {
                        Image(systemName: gameState.voiceEnabled
                              ? "person.wave.2.fill" : "person.wave.2")
                    }
                    Button {
                        showVoicePicker = true
                    } label: {
                        Image(systemName: "waveform.circle.fill")
                    }
                    .accessibilityLabel("Choose narrator voice")
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
        .sheet(isPresented: $showVoicePicker) {
            VoicePickerView(gameState: gameState)
        }
        .sheet(isPresented: $gameState.paywallRequested) {
            PaywallView(gameState: gameState)
        }
    }
}

// MARK: - Narrator voice picker (Warm / Bubbly / Chipper)

struct VoicePickerView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(NarratorVoice.allCases, id: \.self) { v in
                HStack(spacing: 14) {
                    Button {
                        gameState.narrator.preview(voice: v)
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Preview \(v.title) voice")

                    Text(v.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    if gameState.narratorVoice == v {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                .onTapGesture { gameState.setNarratorVoice(v) }
            }
            .navigationTitle("Narrator Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
