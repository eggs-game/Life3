import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @State private var showGameMenu = false

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

            // Center turn / home button
            Button(action: { showGameMenu = true }) {
                VStack(spacing: 1) {
                    Text("TURN")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(1)
                    Text("\(gameState.turnNumber)")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 64, height: 64)
                .background(
                    Circle()
                        .fill(Color(white: 0.1))
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1.5))
                        .shadow(color: .black.opacity(0.8), radius: 12)
                )
            }
        }
        .sheet(isPresented: $showGameMenu) {
            GameMenuView(gameState: gameState)
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
