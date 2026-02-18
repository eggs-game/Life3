import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()

    var body: some View {
        GameView(gameState: gameState)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
