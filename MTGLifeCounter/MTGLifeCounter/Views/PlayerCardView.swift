import SwiftUI

struct PlayerCardView: View {
    @ObservedObject var player: Player
    @ObservedObject var gameState: GameState
    @State private var showCommanderDamage = false
    @State private var lifeChangeDisplay: Int? = nil
    @State private var displayTimer: Timer? = nil
    @GestureState private var isDragging = false

    var isEliminated: Bool { gameState.isEliminated(player) }

    var body: some View {
        ZStack {
            // Background
            player.color
                .overlay(
                    isEliminated
                        ? Color.black.opacity(0.65)
                        : Color.clear
                )

            if isEliminated {
                // Eliminated overlay
                VStack(spacing: 8) {
                    Image(systemName: "skull.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    Text("ELIMINATED")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(3)
                    Text(player.name)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
            } else {
                VStack(spacing: 0) {
                    // Player name
                    Text(player.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 10)

                    Spacer()

                    // Life total
                    ZStack {
                        Text("\(player.life)")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4)

                        // Delta indicator
                        if let delta = lifeChangeDisplay {
                            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(delta > 0 ? .green : .red)
                                .offset(x: 44, y: -28)
                                .transition(.opacity)
                        }
                    }

                    Spacer()

                    // Bottom controls
                    HStack {
                        // Commander damage badge
                        if gameState.format == .commander {
                            Button(action: { showCommanderDamage.toggle() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "shield.lefthalf.filled")
                                        .font(.system(size: 11))
                                    Text("\(player.totalCommanderDamageReceived())")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                            }
                        }

                        Spacer()

                        // +/- quick buttons
                        HStack(spacing: 12) {
                            Button(action: { adjustLife(by: -1) }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }

                            Button(action: { adjustLife(by: +1) }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                }
            }

            // Large tap zones (left = -1, right = +1)
            if !isEliminated && !showCommanderDamage {
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { adjustLife(by: -1) }
                        .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 30) {
                            adjustLife(by: -5)
                        }

                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { adjustLife(by: +1) }
                        .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 30) {
                            adjustLife(by: +5)
                        }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showCommanderDamage) {
            CommanderDamageView(player: player, gameState: gameState)
        }
    }

    private func adjustLife(by amount: Int) {
        gameState.changeLife(for: player, by: amount)

        displayTimer?.invalidate()
        if let current = lifeChangeDisplay {
            lifeChangeDisplay = current + amount
        } else {
            lifeChangeDisplay = amount
        }
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            withAnimation { lifeChangeDisplay = nil }
        }
    }
}
