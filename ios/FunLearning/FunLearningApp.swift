import SwiftUI

@main
struct FunLearningApp: App {
    @StateObject private var gameState = GameState.shared

    var body: some Scene {
        WindowGroup {
            RootView(gameState: gameState)
        }
    }
}
