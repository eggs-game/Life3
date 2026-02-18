import SwiftUI

/// The App Store URL (or universal link) encoded in the QR code.
/// Replace this with your real App Store link once the app is published.
private let appStoreURL = "https://apps.apple.com/app/idYOUR_APP_ID"

struct QRJoinPanel: View {
    @ObservedObject var player: Player

    var body: some View {
        GeometryReader { geo in
            ZStack {
                player.color

                HStack(spacing: 0) {

                    // ── Left: QR code ──────────────────────────────────
                    ZStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .padding(5)
                            QRCodeView(content: appStoreURL, size: qrSize(for: geo.size))
                        }
                        .frame(
                            width:  qrSize(for: geo.size) + 20,
                            height: qrSize(for: geo.size) + 20
                        )
                    }
                    .frame(width: geo.size.width / 2, height: geo.size.height)

                    // ── Right: Join Now ────────────────────────────────
                    ZStack {
                        Button(action: join) {
                            Text("Join Now")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                    }
                    .frame(width: geo.size.width / 2, height: geo.size.height)
                }
            }
        }
    }

    private func qrSize(for size: CGSize) -> CGFloat {
        min(size.height * 0.5, 100)
    }

    private func join() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            player.hasBeenNamed = true
        }
    }
}

