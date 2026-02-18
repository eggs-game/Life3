import SwiftUI

struct WinnerAnnouncementView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        if let winner = gameState.winner {
            ZStack {
                Color.black.opacity(0.85).ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.yellow)

                    Text(winner.name)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("WINS")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(6)

                    Button(action: { gameState.resetGame() }) {
                        Text("Play Again")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 12)
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
}
