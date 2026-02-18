import SwiftUI
import CoreImage.CIFilterBuiltins

/// Renders a QR code for any string using CoreImage — no third-party packages needed.
struct QRCodeView: View {
    let content: String
    var size: CGFloat = 160

    private var qrImage: UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(content.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        // Scale up so it's crisp at display size
        let scale = size / outputImage.extent.width
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    var body: some View {
        if let img = qrImage {
            Image(uiImage: img)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: size, height: size)
        }
    }
}
