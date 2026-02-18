import SwiftUI

// MARK: - Model

struct GameRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let turnCount: Int
    let winnerName: String
    /// The device owner's commander name (player 1's name at the time the game ended).
    let myCommander: String
    /// All players' names and whether each one was the winner.
    let players: [PlayerSnapshot]

    struct PlayerSnapshot: Codable {
        let name: String
        let isWinner: Bool
    }
}

// MARK: - Store

class GameHistoryStore: ObservableObject {
    static let shared = GameHistoryStore()

    private let key = "savedGameHistory"

    @Published var records: [GameRecord] {
        didSet { save() }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([GameRecord].self, from: data) {
            records = decoded
        } else {
            records = []
        }
    }

    func add(_ record: GameRecord) {
        records.insert(record, at: 0) // newest first
    }

    func delete(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
    }

    func deleteAll() {
        records = []
    }

    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
