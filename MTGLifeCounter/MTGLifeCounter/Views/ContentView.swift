import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()

    var body: some View {
        if gameState.isGameActive {
            GameView(gameState: gameState)
        } else {
            SetupView(gameState: gameState)
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
