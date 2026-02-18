import SwiftUI

struct GameHistoryView: View {
    @ObservedObject private var store = GameHistoryStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var confirmClear = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if store.records.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.records) { record in
                            GameRecordRow(record: record)
                                .listRowBackground(Color.white.opacity(0.05))
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        }
                        .onDelete { store.delete(at: $0) }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Game History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.yellow)
                        .fontWeight(.semibold)
                }
                if !store.records.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) { confirmClear = true } label: {
                            Text("Clear All")
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                }
            }
            .alert("Clear History?", isPresented: $confirmClear) {
                Button("Clear All", role: .destructive) { store.deleteAll() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All game records will be permanently deleted.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.4))
            Text("No games recorded yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)
            Text("Declare a winner at the end of a game\nand it will appear here.")
                .font(.system(size: 13))
                .foregroundColor(.gray.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Row

private struct GameRecordRow: View {
    let record: GameRecord

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Date + turn count
            HStack {
                Text(Self.dateFormatter.string(from: record.date))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Spacer()
                Label("\(record.turnCount) turns", systemImage: "arrow.trianglehead.clockwise")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            // Winner banner
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                Text(record.winnerName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text("wins")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }

            Divider()
                .background(Color.white.opacity(0.08))

            // My commander
            HStack(spacing: 6) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow.opacity(0.7))
                Text("You played")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(record.myCommander)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
            }

            // Other players
            let others = record.players.filter { !isMyCommander($0) }
            if !others.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(others, id: \.name) { player in
                        HStack(spacing: 6) {
                            Image(systemName: player.isWinner ? "crown.fill" : "person.fill")
                                .font(.system(size: 11))
                                .foregroundColor(player.isWinner ? .yellow : .gray.opacity(0.5))
                                .frame(width: 14)
                            Text(player.name)
                                .font(.system(size: 12))
                                .foregroundColor(player.isWinner ? .white.opacity(0.9) : .white.opacity(0.55))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    /// The first snapshot is always the device owner (index 0 in GameState).
    private func isMyCommander(_ snapshot: GameRecord.PlayerSnapshot) -> Bool {
        snapshot.name == record.myCommander && record.players.first?.name == record.myCommander
    }
}
