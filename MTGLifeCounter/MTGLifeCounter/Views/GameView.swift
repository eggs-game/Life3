import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState

    // Radial menu
    @State private var menuOpen = false
    @State private var showDice = false
    @State private var showSettings = false
    @State private var showWinnerPicker = false
    @State private var confirmReset = false

    // Drag state
    @State private var isDragging = false
    @State private var dragLocation: CGPoint = .zero
    @State private var hoveredSlot: Int? = nil

    var layout: GameLayout {
        switch gameState.players.count {
        case 2: return .twoPlayer
        case 3: return .threePlayer
        default: return .fourPlayer
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                // Player grid
                playerGrid(geo: geo)

                // Drag thumbnail
                if isDragging, let owner = gameState.players.first(where: { $0.isOwner }) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(owner.color)
                        .overlay(
                            Text(owner.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .frame(width: 100, height: 65)
                        .shadow(color: .black.opacity(0.7), radius: 14)
                        .scaleEffect(1.08)
                        .position(dragLocation)
                        .allowsHitTesting(false)
                }

                // Dim backdrop when menu is open
                if menuOpen {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .onTapGesture { closeMenu() }
                        .transition(.opacity)
                }

                // Radial menu + centre button
                RadialMenuView(
                    isOpen: $menuOpen,
                    onDice:     { closeMenu(); showDice = true },
                    onSettings: { closeMenu(); showSettings = true },
                    onRestart:  { closeMenu(); confirmReset = true },
                    onTrophy:   { closeMenu(); showWinnerPicker = true }
                )

                // Winner overlay
                WinnerAnnouncementView(gameState: gameState)
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: menuOpen)
            .animation(.easeInOut(duration: 0.25), value: gameState.winner?.id)
            .sheet(isPresented: $showDice) {
                DiceRollerView()
            }
            .sheet(isPresented: $showSettings) {
                CommanderSettingsView()
            }
            .sheet(isPresented: $showWinnerPicker) {
                WinnerPickerView(gameState: gameState)
            }
            .alert("Restart Game?", isPresented: $confirmReset) {
                Button("Restart", role: .destructive) { gameState.resetGame() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All life totals will be reset to \(gameState.format.startingLife).")
            }
            .onPreferenceChange(OwnerDragPreferenceKey.self) { value in
                guard let v = value else {
                    if isDragging {
                        let target = slotIndex(at: dragLocation, in: geo.size)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if let t = target { gameState.moveOwner(to: t) }
                            isDragging = false
                            hoveredSlot = nil
                        }
                    }
                    return
                }
                isDragging = true
                dragLocation = v
                hoveredSlot = slotIndex(at: v, in: geo.size)
            }
        }
        .ignoresSafeArea()
    }

    private func closeMenu() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            menuOpen = false
        }
    }

    // MARK: - Grid

    @ViewBuilder
    private func playerGrid(geo: GeometryProxy) -> some View {
        let W = geo.size.width
        let H = geo.size.height
        let gap: CGFloat = 2
        let tileW = (W - gap) / 2
        let tileH = (H - gap) / 2

        let centres: [CGPoint] = [
            CGPoint(x: tileW / 2,               y: tileH / 2),
            CGPoint(x: tileW / 2 + tileW + gap, y: tileH / 2),
            CGPoint(x: tileW / 2,               y: tileH / 2 + tileH + gap),
            CGPoint(x: tileW / 2 + tileW + gap, y: tileH / 2 + tileH + gap),
        ]

        let rotations = slotRotations()

        ZStack {
            ForEach(0..<gameState.players.count, id: \.self) { i in
                PlayerCardView(
                    player: gameState.players[i],
                    gameState: gameState,
                    cardRotation: rotations[i]
                )
                .frame(width: tileW, height: tileH)
                .rotationEffect(.degrees(rotations[i]))
                .frame(width: tileW, height: tileH)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(hoveredSlot == i && isDragging ? 0.9 : 0), lineWidth: 3)
                        .animation(.easeInOut(duration: 0.12), value: hoveredSlot)
                )
                .position(centres[i])
            }
        }
        .frame(width: W, height: H, alignment: .topLeading)
    }

    private func slotRotations() -> [Double] {
        switch layout {
        case .twoPlayer:   return [-90,  90, -90,  90]
        case .threePlayer: return [180, 180,   0,   0]
        case .fourPlayer:  return [180, 180,   0,   0]
        }
    }

    private func slotIndex(at point: CGPoint, in size: CGSize) -> Int? {
        let col = point.x < size.width  / 2 ? 0 : 1
        let row = point.y < size.height / 2 ? 0 : 1
        let index = row * 2 + col
        return gameState.players.indices.contains(index) ? index : nil
    }
}

// MARK: - Radial Menu

struct RadialMenuView: View {
    @Binding var isOpen: Bool
    let onDice:     () -> Void
    let onSettings: () -> Void
    let onRestart:  () -> Void
    let onTrophy:   () -> Void

    // Satellite buttons: (icon, colour, angle in degrees, action)
    private var satellites: [(icon: String, color: Color, angle: Double, action: () -> Void)] {[
        ("dice.fill",             .orange,  -90, onDice),
        ("gear",                  .gray,      0, onSettings),
        ("arrow.counterclockwise",.red,      90, onRestart),
        ("trophy.fill",           .yellow,  180, onTrophy),
    ]}

    private let orbitRadius: CGFloat = 90
    private let satelliteSize: CGFloat = 48
    private let centerSize: CGFloat = 64

    var body: some View {
        ZStack {
            // Satellite buttons
            ForEach(satellites.indices, id: \.self) { i in
                let s = satellites[i]
                let rad = s.angle * .pi / 180
                let offset = CGSize(
                    width:  isOpen ? cos(rad) * orbitRadius : 0,
                    height: isOpen ? sin(rad) * orbitRadius : 0
                )

                Button(action: s.action) {
                    Image(systemName: s.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: satelliteSize, height: satelliteSize)
                        .background(
                            Circle()
                                .fill(Color(white: 0.15))
                                .overlay(Circle().stroke(s.color.opacity(0.6), lineWidth: 1.5))
                                .shadow(color: .black.opacity(0.6), radius: 8)
                        )
                }
                .offset(offset)
                .scaleEffect(isOpen ? 1 : 0.3)
                .opacity(isOpen ? 1 : 0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.7)
                    .delay(isOpen ? Double(i) * 0.04 : 0),
                    value: isOpen
                )
            }

            // Centre button
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isOpen.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color(white: isOpen ? 0.18 : 0.1))
                        .overlay(
                            Circle().stroke(
                                Color.white.opacity(isOpen ? 0.5 : 0.25),
                                lineWidth: 1.5
                            )
                        )
                        .shadow(color: .black.opacity(0.8), radius: 12)

                    Image(systemName: isOpen ? "xmark" : "circle.grid.cross.fill")
                        .font(.system(size: isOpen ? 18 : 20, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                        .animation(.spring(response: 0.3), value: isOpen)
                }
                .frame(width: centerSize, height: centerSize)
            }
        }
    }
}

// MARK: - Preference key

struct OwnerDragPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint? = nil
    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        value = nextValue() ?? value
    }
}

enum GameLayout {
    case twoPlayer, threePlayer, fourPlayer
}

