import SwiftUI

enum GameFormat {
    case commander
    var startingLife: Int { 40 }
}

class Player: ObservableObject, Identifiable {
    let id: UUID
    @Published var name: String
    @Published var life: Int
    @Published var commanderDamage: [UUID: Int] = [:]
    @Published var color: Color

    init(id: UUID = UUID(), name: String, startingLife: Int, color: Color) {
        self.id = id
        self.name = name
        self.life = startingLife
        self.color = color
    }

    func resetLife(to startingLife: Int, opponents: [Player]) {
        life = startingLife
        commanderDamage = Dictionary(uniqueKeysWithValues: opponents.map { ($0.id, 0) })
    }

    func totalCommanderDamageReceived() -> Int {
        commanderDamage.values.reduce(0, +)
    }
}

class GameState: ObservableObject {
    @Published var players: [Player] = []
    @Published var lifeHistory: [String] = []

    let format: GameFormat = .commander

    static let playerColors: [Color] = [
        Color(red: 0.8, green: 0.2, blue: 0.2),   // Red
        Color(red: 0.1, green: 0.4, blue: 0.8),   // Blue
        Color(red: 0.1, green: 0.6, blue: 0.2),   // Green
        Color(red: 0.6, green: 0.4, blue: 0.8)    // Purple
    ]

    static let playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"]

    init() {
        players = (0..<4).map { index in
            Player(
                name: GameState.playerNames[index],
                startingLife: GameFormat.commander.startingLife,
                color: GameState.playerColors[index]
            )
        }
        for player in players {
            let opponents = players.filter { $0.id != player.id }
            player.commanderDamage = Dictionary(uniqueKeysWithValues: opponents.map { ($0.id, 0) })
        }
    }

    func resetGame() {
        for player in players {
            let opponents = players.filter { $0.id != player.id }
            player.resetLife(to: format.startingLife, opponents: opponents)
        }
        lifeHistory = []
    }

    func changeLife(for player: Player, by amount: Int) {
        let old = player.life
        player.life += amount
        let change = amount > 0 ? "+\(amount)" : "\(amount)"
        lifeHistory.append("\(player.name): \(old) \(change) = \(player.life)")
    }

    func addCommanderDamage(to player: Player, from attackerId: UUID, amount: Int) {
        player.commanderDamage[attackerId, default: 0] += amount
        player.life -= amount
        if let attacker = players.first(where: { $0.id == attackerId }) {
            lifeHistory.append("Commander damage: \(attacker.name) dealt \(amount) to \(player.name)")
        }
    }

    func isEliminated(_ player: Player) -> Bool {
        if player.life <= 0 { return true }
        if format == .commander && player.totalCommanderDamageReceived() >= 21 { return true }
        return false
    }
}
