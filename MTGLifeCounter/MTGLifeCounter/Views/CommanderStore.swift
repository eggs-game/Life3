import SwiftUI
import Combine

/// Persists the user's saved commander names across launches.
class CommanderStore: ObservableObject {
    static let shared = CommanderStore()

    private let key = "savedCommanders"

    @Published var commanders: [String] {
        didSet { save() }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            commanders = decoded
        } else {
            commanders = []
        }
    }

    func add(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !commanders.contains(trimmed) else { return }
        commanders.append(trimmed)
    }

    func delete(at offsets: IndexSet) {
        commanders.remove(atOffsets: offsets)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(commanders) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
