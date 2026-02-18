import SwiftUI

struct PlayerCardView: View {
    @ObservedObject var player: Player
    @ObservedObject var gameState: GameState
    /// The rotation (degrees) applied to this card in its parent layout.
    /// Used to interpret the swipe-up direction in screen-space coordinates.
    var cardRotation: Double = 0

    @State private var showCommanderDamage = false
    @State private var showEditPlayer = false
    @State private var lifeChangeDisplay: Int? = nil
    @State private var displayTimer: Timer? = nil

    var isEliminated: Bool { gameState.isEliminated(player) }

    var body: some View {
        ZStack {
            // Background
            player.color
                .overlay(
                    isEliminated
                        ? Color.black.opacity(0.65)
                        : Color.clear
                )

            if isEliminated {
                VStack(spacing: 8) {
                    Image(systemName: "skull.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    Text("ELIMINATED")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(3)
                    Text(player.name)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
            } else if !player.isOwner && !player.hasBeenNamed {
                // ── QR panel ── other player hasn't joined yet
                QRJoinPanel(player: player)
            } else {
                VStack(spacing: 0) {
                    // Player name — tap to edit
                    Button(action: { showEditPlayer = true }) {
                        HStack(spacing: 4) {
                            Text(player.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                            Image(systemName: "pencil")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .padding(.top, 10)

                    Spacer()

                    // Life total
                    ZStack {
                        Text("\(player.life)")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4)

                        if let delta = lifeChangeDisplay {
                            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(delta > 0 ? .green : .red)
                                .offset(x: 44, y: -28)
                                .transition(.opacity)
                        }
                    }

                    Spacer()

                    // Bottom controls
                    HStack {
                        Button(action: { showCommanderDamage.toggle() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 11))
                                Text("\(player.totalCommanderDamageReceived())")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                }
            }

            // Large tap zones (left = -1, right = +1) + swipe-up to edit
            if !isEliminated && !showCommanderDamage && (player.isOwner || player.hasBeenNamed) {
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { adjustLife(by: -1) }
                        .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 30) {
                            adjustLife(by: -5)
                        }

                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { adjustLife(by: +1) }
                        .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 30) {
                            adjustLife(by: +5)
                        }
                }
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            if isUpwardSwipe(value.translation) {
                                showEditPlayer = true
                            }
                        }
                )
            }

            // Drag handle — only shown on the owner's panel
            if player.isOwner && !isEliminated {
                OwnerDragHandle(cardRotation: cardRotation)
            }
        }
        .clipShape(Rectangle())
        .sheet(isPresented: $showCommanderDamage) {
            CommanderDamageView(player: player, gameState: gameState)
        }
        .sheet(isPresented: $showEditPlayer) {
            PlayerEditView(player: player)
        }
    }

    // MARK: - Helpers

    /// Detects a swipe "upward" from the player's visual perspective.
    /// rotationEffect() is visual-only; gesture coords stay in screen space.
    /// So we invert the expected axis/direction based on the card's rotation.
    private func isUpwardSwipe(_ t: CGSize) -> Bool {
        let threshold: Double = 40
        switch cardRotation {
        case 180:   return t.height > threshold    // player's up = screen down
        case 90:    return t.width  < -threshold   // player's up = screen left
        case -90:   return t.width  > threshold    // player's up = screen right
        default:    return t.height < -threshold   // player's up = screen up
        }
    }

    private func adjustLife(by amount: Int) {
        gameState.changeLife(for: player, by: amount)
        displayTimer?.invalidate()
        lifeChangeDisplay = (lifeChangeDisplay ?? 0) + amount
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            withAnimation { lifeChangeDisplay = nil }
        }
    }
}

// MARK: - Owner drag handle

/// A grip icon pinned to the corner of the owner's panel.
/// Reports its drag location in global coordinates via OwnerDragPreferenceKey
/// so GameView can determine which slot to swap into.
private struct OwnerDragHandle: View {
    let cardRotation: Double
    @State private var dragPoint: CGPoint? = nil

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(dragPoint != nil ? 1.0 : 0.7))
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(dragPoint != nil ? 0.7 : 0.4))
                            .overlay(
                                Circle().stroke(
                                    Color.white.opacity(dragPoint != nil ? 0.6 : 0.2),
                                    lineWidth: 1.5
                                )
                            )
                    )
                    .scaleEffect(dragPoint != nil ? 1.15 : 1.0)
                    .animation(.spring(response: 0.2), value: dragPoint != nil)
                    .rotationEffect(.degrees(cardRotation))
                    .padding(10)
                    .gesture(
                        DragGesture(minimumDistance: 4, coordinateSpace: .global)
                            .onChanged { value in dragPoint = value.location }
                            .onEnded   { _     in dragPoint = nil }
                    )
            }
            Spacer()
        }
        .preference(key: OwnerDragPreferenceKey.self, value: dragPoint)
    }
}

