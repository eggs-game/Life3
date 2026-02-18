import SwiftUI

struct CommanderDamageView: View {
    @ObservedObject var player: Player
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    var opponents: [Player] {
        gameState.players.filter { $0.id != player.id }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header info
                    VStack(spacing: 4) {
                        Text("Commander Damage")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                        Text("Taken by \(player.name)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("21+ damage from one commander = eliminated")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    Divider().background(Color.white.opacity(0.1))

                    // Damage from each opponent
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(opponents) { opponent in
                                let damage = player.commanderDamage[opponent.id, default: 0]
                                HStack(spacing: 16) {
                                    // Opponent color swatch + name
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(opponent.color)
                                            .frame(width: 14, height: 14)
                                        Text(opponent.name)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }

                                    Spacer()

                                    // Damage counter
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            if damage > 0 {
                                                gameState.addCommanderDamage(
                                                    to: player,
                                                    from: opponent.id,
                                                    amount: -1
                                                )
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(.white.opacity(0.6))
                                        }

                                        VStack(spacing: 2) {
                                            Text("\(damage)")
                                                .font(.system(size: 32, weight: .black, design: .rounded))
                                                .foregroundColor(damage >= 21 ? .red : .white)
                                                .frame(minWidth: 48)

                                            if damage >= 21 {
                                                Text("LETHAL")
                                                    .font(.system(size: 9, weight: .black))
                                                    .foregroundColor(.red)
                                                    .tracking(2)
                                            }
                                        }

                                        Button(action: {
                                            gameState.addCommanderDamage(
                                                to: player,
                                                from: opponent.id,
                                                amount: 1
                                            )
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(opponent.color)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.07))
                                        .overlay(
                                            damage >= 21
                                                ? RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.red.opacity(0.6), lineWidth: 1.5)
                                                : nil
                                        )
                                )
                            }
                        }
                        .padding()
                    }

                    // Total
                    HStack {
                        Text("Total commander damage received")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(player.totalCommanderDamageReceived())")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(player.totalCommanderDamageReceived() >= 21 ? .red : .white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.yellow)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
