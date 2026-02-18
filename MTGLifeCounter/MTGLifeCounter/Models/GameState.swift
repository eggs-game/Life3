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
    /// True only for the device owner's panel.
    var isOwner: Bool
    /// False until the player has been given a real name (not a default placeholder).
    /// Drives the QR-panel vs life-counter decision regardless of slot position.
    @Published var hasBeenNamed: Bool

    init(id: UUID = UUID(), name: String, startingLife: Int, color: Color, isOwner: Bool = false, hasBeenNamed: Bool = false) {
        self.id = id
        self.name = name
        self.life = startingLife
        self.color = color
        self.isOwner = isOwner
        self.hasBeenNamed = hasBeenNamed
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
    @Published var turnNumber: Int = 1
    @Published var winner: Player? = nil

    /// Tracks which players have changed life this turn.
    /// When all players have changed life at least once, the turn advances.
    private var playersChangedThisTurn: Set<UUID> = []

    let format: GameFormat = .commander

    static let playerColors: [Color] = [
        Color(red: 1.0, green: 0.25, blue: 0.35),  // Coral Red
        Color(red: 0.18, green: 0.55, blue: 1.0),  // Electric Blue
        Color(red: 0.18, green: 0.85, blue: 0.45), // Neon Mint
        Color(red: 0.85, green: 0.25, blue: 1.0),  // Vivid Purple
    ]

    static let playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"]

    init() {
        players = (0..<4).map { index in
            Player(
                name: GameState.playerNames[index],
                startingLife: GameFormat.commander.startingLife,
                color: GameState.playerColors[index],
                isOwner: index == 0,
                hasBeenNamed: index == 0  // owner is considered named; others show QR until named
            )
        }
        for player in players {
            let opponents = players.filter { $0.id != player.id }
            player.commanderDamage = Dictionary(uniqueKeysWithValues: opponents.map { ($0.id, 0) })
        }
    }

    /// Swaps the owner's current slot with the player at `targetIndex`.
    func moveOwner(to targetIndex: Int) {
        guard let ownerIndex = players.firstIndex(where: { $0.isOwner }),
              targetIndex != ownerIndex,
              players.indices.contains(targetIndex) else { return }
        players.swapAt(ownerIndex, targetIndex)
    }

    func resetGame() {
        for player in players {
            let opponents = players.filter { $0.id != player.id }
            player.resetLife(to: format.startingLife, opponents: opponents)
            if !player.isOwner { player.hasBeenNamed = false }
        }
        lifeHistory = []
        turnNumber = 1
        playersChangedThisTurn = []
        winner = nil
    }

    func nextTurn() {
        turnNumber += 1
        playersChangedThisTurn = []
    }

    func changeLife(for player: Player, by amount: Int) {
        let old = player.life
        player.life += amount
        let change = amount > 0 ? "+\(amount)" : "\(amount)"
        lifeHistory.append("Turn \(turnNumber) — \(player.name): \(old) \(change) = \(player.life)")

        playersChangedThisTurn.insert(player.id)
        if playersChangedThisTurn.count == players.count {
            nextTurn()
        }
    }

    func addCommanderDamage(to player: Player, from attackerId: UUID, amount: Int) {
        player.commanderDamage[attackerId, default: 0] += amount
        player.life -= amount
        if let attacker = players.first(where: { $0.id == attackerId }) {
            lifeHistory.append("Commander damage: \(attacker.name) dealt \(amount) to \(player.name)")
        }
    }

    /// Called by WinnerPickerView (and anywhere else a winner is set) to
    /// snapshot the current game state into persistent history.
    func recordGameResult(winner: Player) {
        let snapshots = players.map {
            GameRecord.PlayerSnapshot(name: $0.name, isWinner: $0.id == winner.id)
        }
        // Player at index 0 is always the device owner; their name is the commander they played.
        let myCommander = players.first?.name ?? "Unknown"
        let record = GameRecord(
            id: UUID(),
            date: Date(),
            turnCount: turnNumber,
            winnerName: winner.name,
            myCommander: myCommander,
            players: snapshots
        )
        GameHistoryStore.shared.add(record)
    }

    func isEliminated(_ player: Player) -> Bool {
        if player.life <= 0 { return true }
        if format == .commander && player.totalCommanderDamageReceived() >= 21 { return true }
        return false
    }
}
