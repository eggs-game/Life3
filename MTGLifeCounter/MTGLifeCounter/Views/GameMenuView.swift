import SwiftUI

struct GameMenuView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    @State private var showHistory = false
    @State private var confirmReset = false

    var body: some View {
        ZStack {
            Color(white: 0.06).ignoresSafeArea()

            VStack(spacing: 0) {

                // Turn badge
                VStack(spacing: 4) {
                    Text("TURN")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(2)
                    Text("\(gameState.turnNumber)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Button(action: { gameState.nextTurn(); dismiss() }) {
                        Label("End Turn", systemImage: "arrow.right.circle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(Color.white.opacity(0.04))

                Divider().background(Color.white.opacity(0.1))

                // Menu rows
                menuRow(
                    icon: "clock.arrow.circlepath",
                    label: "View History",
                    color: .blue
                ) {
                    showHistory = true
                }

                Divider().background(Color.white.opacity(0.08)).padding(.leading, 52)

                menuRow(
                    icon: "arrow.counterclockwise",
                    label: "Restart Game",
                    color: .red
                ) {
                    confirmReset = true
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.fraction(0.5)])
        .sheet(isPresented: $showHistory) {
            HistoryView(history: gameState.lifeHistory)
        }
        .alert("Restart Game?", isPresented: $confirmReset) {
            Button("Restart", role: .destructive) {
                gameState.resetGame()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All life totals will be reset to \(gameState.format.startingLife).")
        }
    }

    @ViewBuilder
    private func menuRow(
        icon: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 32)
                Text(label)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}
