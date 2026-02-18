import SwiftUI

struct PlayerEditView: View {
    @ObservedObject var player: Player
    @Environment(\.dismiss) private var dismiss
    @State private var draftName: String
    @State private var draftColor: Color

    // Preset palette — same initial 4 as GameState plus extras
    static let colorOptions: [Color] = [
        Color(red: 0.8, green: 0.2, blue: 0.2),  // Red
        Color(red: 0.1, green: 0.4, blue: 0.8),  // Blue
        Color(red: 0.1, green: 0.6, blue: 0.2),  // Green
        Color(red: 0.6, green: 0.4, blue: 0.8),  // Purple
        Color(red: 0.9, green: 0.5, blue: 0.1),  // Orange
        Color(red: 0.1, green: 0.6, blue: 0.6),  // Teal
        Color(red: 0.85, green: 0.2, blue: 0.5), // Pink
        Color(red: 0.4, green: 0.3, blue: 0.2),  // Brown
    ]

    init(player: Player) {
        self.player = player
        _draftName = State(initialValue: player.name)
        _draftColor = State(initialValue: player.color)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Live preview
                    RoundedRectangle(cornerRadius: 12)
                        .fill(draftColor)
                        .frame(height: 72)
                        .overlay(
                            Text(draftName.isEmpty ? "Player" : draftName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.2), value: draftColor)

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NAME")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)

                        TextField("Player name", text: $draftName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .submitLabel(.done)
                    }
                    .padding(.horizontal)

                    // Color grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COLOR")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                            spacing: 10
                        ) {
                            ForEach(Self.colorOptions.indices, id: \.self) { idx in
                                let color = Self.colorOptions[idx]
                                Button(action: { draftColor = color }) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(color)
                                        .frame(height: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(
                                                    draftColor.description == color.description
                                                        ? Color.white
                                                        : Color.clear,
                                                    lineWidth: 3
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty { player.name = trimmed }
                        player.color = draftColor
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }
}
