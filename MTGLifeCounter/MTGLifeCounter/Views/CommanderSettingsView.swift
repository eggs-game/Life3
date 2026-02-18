import SwiftUI

/// Settings screen where the user manages their saved commander names.
struct CommanderSettingsView: View {
    @ObservedObject private var store = CommanderStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var newName: String = ""
    @FocusState private var fieldFocused: Bool
    @State private var showHistory = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Add new commander
                    HStack(spacing: 12) {
                        TextField("Add commander name…", text: $newName)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .submitLabel(.done)
                            .focused($fieldFocused)
                            .onSubmit { commitAdd() }

                        Button(action: commitAdd) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(newName.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .yellow)
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    Divider().background(Color.white.opacity(0.1))

                    if store.commanders.isEmpty {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 44))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No commanders yet")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            Text("Add your commander names above so you can\nquickly pick one when starting a game.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 32)
                        Spacer()
                    } else {
                        List {
                            ForEach(store.commanders, id: \.self) { name in
                                HStack {
                                    Image(systemName: "shield.lefthalf.filled")
                                        .foregroundColor(.yellow.opacity(0.7))
                                        .font(.system(size: 14))
                                    Text(name)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                }
                                .listRowBackground(Color.white.opacity(0.05))
                            }
                            .onDelete { offsets in
                                store.delete(at: offsets)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("My Commanders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.yellow)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .foregroundColor(.gray)
                        .opacity(store.commanders.isEmpty ? 0 : 1)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { showHistory = true }) {
                        Label("Game History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showHistory) {
            GameHistoryView()
        }
    }

    private func commitAdd() {
        store.add(newName)
        newName = ""
        fieldFocused = false
    }
}
