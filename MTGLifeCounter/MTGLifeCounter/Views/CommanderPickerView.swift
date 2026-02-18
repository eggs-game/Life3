import SwiftUI

/// Shown at app startup so the user can pick which commander they're playing.
/// Sets Player 1's name (the "my profile" player) to the chosen commander.
struct CommanderPickerView: View {
    @ObservedObject private var store = CommanderStore.shared
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    @State private var showSettings = false

    // Player 1 is always "my" player
    private var myPlayer: Player { gameState.players[0] }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    if store.commanders.isEmpty {
                        // Empty state — prompt to add commanders first
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 52))
                                .foregroundColor(.yellow.opacity(0.6))

                            Text("No commanders saved")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            Text("Go to Settings to add your commanders,\nthen you can pick one here each game.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                            Button(action: { showSettings = true }) {
                                Label("Open Settings", systemImage: "gear")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.yellow)
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 32)
                        Spacer()
                    } else {
                        List {
                            Section {
                                ForEach(store.commanders, id: \.self) { name in
                                    Button(action: { pick(name) }) {
                                        HStack {
                                            Image(systemName: "shield.lefthalf.filled")
                                                .foregroundColor(.yellow.opacity(0.8))
                                                .font(.system(size: 15))
                                                .frame(width: 26)

                                            Text(name)
                                                .font(.system(size: 17))
                                                .foregroundColor(.white)

                                            Spacer()

                                            if myPlayer.name == name {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 14, weight: .semibold))
                                            }
                                        }
                                    }
                                    .listRowBackground(Color.white.opacity(0.05))
                                }
                            } header: {
                                Text("Choose your commander")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .textCase(nil)
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Who are you playing?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(.gray)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            CommanderSettingsView()
        }
    }

    private func pick(_ name: String) {
        myPlayer.name = name
        dismiss()
    }
}
