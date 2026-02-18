import SwiftUI

struct HistoryView: View {
    let history: [String]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if history.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 44))
                            .foregroundColor(.gray)
                        Text("No actions yet")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(Array(history.enumerated().reversed()), id: \.offset) { _, entry in
                            Text(entry)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white)
                                .listRowBackground(Color.white.opacity(0.05))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Game History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
    }
}
