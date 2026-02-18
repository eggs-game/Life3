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
                // Slim single toolbar
                HStack(spacing: 20) {
                    Button(action: { showHistorySheet = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Text("Commander")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())

                    Spacer()

                    Button(action: { showResetAlert = true }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)

                // Player grid — fills all remaining height
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
//
// Landscape orientation: screen is wider than tall.
// For 2 players: side-by-side, each panel rotated 90° so players face inward from
// opposite long edges of the table.
// For 3 players: two on top (rotated 180°) + one full-width on bottom.
// For 4 players: 2 × 2 grid — top row rotated 180°, bottom row normal.

struct TwoPlayerLayout: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 2) {
            // Left player reads upward (rotated 90° CCW)
            PlayerCardView(player: gameState.players[0], gameState: gameState, cardRotation: -90)
                .rotationEffect(.degrees(-90))

            // Right player reads downward (rotated 90° CW)
            PlayerCardView(player: gameState.players[1], gameState: gameState, cardRotation: 90)
                .rotationEffect(.degrees(90))
        }
    }
}

struct ThreePlayerLayout: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                PlayerCardView(player: gameState.players[0], gameState: gameState, cardRotation: 180)
                    .rotationEffect(.degrees(180))
                PlayerCardView(player: gameState.players[1], gameState: gameState, cardRotation: 180)
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
                PlayerCardView(player: gameState.players[0], gameState: gameState, cardRotation: 180)
                    .rotationEffect(.degrees(180))
                PlayerCardView(player: gameState.players[1], gameState: gameState, cardRotation: 180)
                    .rotationEffect(.degrees(180))
            }
            HStack(spacing: 2) {
                PlayerCardView(player: gameState.players[2], gameState: gameState)
                PlayerCardView(player: gameState.players[3], gameState: gameState)
            }
        }
    }
}
