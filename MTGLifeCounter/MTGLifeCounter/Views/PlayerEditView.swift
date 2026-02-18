import SwiftUI

struct PlayerEditView: View {
    @ObservedObject var player: Player
    @Environment(\.dismiss) private var dismiss
    @State private var draftName: String
    @State private var draftColor: Color

    // Preset palette — same initial 4 as GameState plus extras
    static let colorOptions: [Color] = [
        Color(red: 1.0,  green: 0.25, blue: 0.35), // Coral Red
        Color(red: 0.18, green: 0.55, blue: 1.0),  // Electric Blue
        Color(red: 0.18, green: 0.85, blue: 0.45), // Neon Mint
        Color(red: 0.85, green: 0.25, blue: 1.0),  // Vivid Purple
        Color(red: 1.0,  green: 0.55, blue: 0.0),  // Blazing Orange
        Color(red: 0.0,  green: 0.85, blue: 0.85), // Cyan
        Color(red: 1.0,  green: 0.2,  blue: 0.75), // Hot Pink
        Color(red: 0.65, green: 1.0,  blue: 0.0),  // Lime Green
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
                        if !trimmed.isEmpty {
                            player.name = trimmed
                            player.hasBeenNamed = true
                        }
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
