import SwiftUI

struct LiquidGlassSurface<Content: View>: View {
    let cornerRadius: CGFloat
    let interactive: Bool
    let content: Content
    @State private var intensity = GlassIntensity.selected

    init(cornerRadius: CGFloat = 22, interactive: Bool = true, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius; self.interactive = interactive; self.content = content()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        Group {
            if #available(macOS 26.0, *) {
                content.glassEffect(
                    interactive ? .regular.tint(.black.opacity(intensity.tintOpacity)).interactive() : .regular.tint(.black.opacity(intensity.tintOpacity)),
                    in: shape
                )
            } else { content.background(.ultraThinMaterial, in: shape) }
        }
        .overlay { shape.stroke(.white.opacity(intensity.borderOpacity), lineWidth: 1) }
        .shadow(color: .black.opacity(intensity.shadowOpacity), radius: 18, y: 8)
        .onReceive(NotificationCenter.default.publisher(for: .glassIntensityDidChange)) { _ in intensity = GlassIntensity.selected }
    }
}
