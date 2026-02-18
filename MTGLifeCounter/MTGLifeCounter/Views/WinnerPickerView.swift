import SwiftUI

struct WinnerPickerView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(white: 0.06).ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Declare Winner")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 28)
                    .padding(.bottom, 24)

                ForEach(gameState.players) { player in
                    Button(action: { declare(player) }) {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(player.color)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )

                            Text(player.name)
                                .font(.system(size: 17))
                                .foregroundColor(.white)

                            Spacer()

                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow.opacity(0.6))
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }

                    if player.id != gameState.players.last?.id {
                        Divider()
                            .background(Color.white.opacity(0.08))
                            .padding(.leading, 66)
                    }
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.fraction(0.5)])
    }

    private func declare(_ player: Player) {
        gameState.recordGameResult(winner: player)
        gameState.winner = player
        dismiss()
    }
}
