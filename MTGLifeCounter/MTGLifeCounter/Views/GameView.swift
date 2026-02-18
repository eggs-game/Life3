import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @State private var showResetAlert = false
    @State private var showHistorySheet = false

    var layout: GameLayout {
        switch gameState.players.count {
        case 2: return .twoPlayer
        case 3: return .threePlayer
        default: return .fourPlayer
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { showHistorySheet = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Text(gameState.format.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())

                    Spacer()

                    Button(action: { showResetAlert = true }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // Player grid
                Group {
                    switch layout {
                    case .twoPlayer:
                        TwoPlayerLayout(gameState: gameState)
                    case .threePlayer:
                        ThreePlayerLayout(gameState: gameState)
                    case .fourPlayer:
                        FourPlayerLayout(gameState: gameState)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom bar
                HStack {
                    Button(action: {
                        withAnimation {
                            gameState.isGameActive = false
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "house.fill")
                            Text("Menu")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .alert("Reset Game?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { gameState.resetGame() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All life totals will be reset to \(gameState.format.startingLife).")
        }
        .sheet(isPresented: $showHistorySheet) {
            HistoryView(history: gameState.lifeHistory)
        }
    }
}

enum GameLayout {
    case twoPlayer, threePlayer, fourPlayer
}

// MARK: - Layouts

struct TwoPlayerLayout: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 2) {
            PlayerCardView(player: gameState.players[0], gameState: gameState)
                .rotationEffect(.degrees(180))
            PlayerCardView(player: gameState.players[1], gameState: gameState)
        }
    }
}

struct ThreePlayerLayout: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                PlayerCardView(player: gameState.players[0], gameState: gameState)
                    .rotationEffect(.degrees(180))
                PlayerCardView(player: gameState.players[1], gameState: gameState)
                    .rotationEffect(.degrees(180))
            }
            PlayerCardView(player: gameState.players[2], gameState: gameState)
        }
    }
}

struct FourPlayerLayout: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                PlayerCardView(player: gameState.players[0], gameState: gameState)
                    .rotationEffect(.degrees(180))
                PlayerCardView(player: gameState.players[1], gameState: gameState)
                    .rotationEffect(.degrees(180))
            }
            HStack(spacing: 2) {
                PlayerCardView(player: gameState.players[2], gameState: gameState)
                PlayerCardView(player: gameState.players[3], gameState: gameState)
            }
        }
    }
}
