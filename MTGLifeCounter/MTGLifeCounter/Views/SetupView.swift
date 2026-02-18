import SwiftUI

struct SetupView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 40) {
                // Logo / Title
                VStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("MTG Life Counter")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Text("Magic: The Gathering")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Format Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("FORMAT")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    HStack(spacing: 0) {
                        ForEach(GameFormat.allCases) { format in
                            Button(action: { gameState.format = format }) {
                                Text(format.rawValue)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(gameState.format == format ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        gameState.format == format
                                            ? Color.yellow
                                            : Color.white.opacity(0.1)
                                    )
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    Text("Starting life: \(gameState.format.startingLife)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                // Player Count
                VStack(alignment: .leading, spacing: 12) {
                    Text("PLAYERS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        ForEach([2, 3, 4], id: \.self) { count in
                            Button(action: { gameState.playerCount = count }) {
                                Text("\(count)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(gameState.playerCount == count ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(
                                        gameState.playerCount == count
                                            ? Color.yellow
                                            : Color.white.opacity(0.1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Start Button
                Button(action: { gameState.startGame() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                        Text("Start Game")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .orange.opacity(0.4), radius: 12, y: 4)
                }
                .padding(.horizontal)
            }
        }
    }
}
