import SwiftUI

struct PanelSurface<Content: View>: View {
    let shape: UnevenRoundedRectangle
    let content: Content
    @State private var appearance = PanelAppearance.selected
    @State private var intensity = GlassIntensity.selected

    init(shape: UnevenRoundedRectangle, @ViewBuilder content: () -> Content) {
        self.shape = shape; self.content = content()
    }

    var body: some View {
        Group {
            switch appearance {
            case .translucent: content.background(shape.fill(.black.opacity(0.94)))
            case .black: content.background(shape.fill(.black))
            case .liquidGlass:
                if #available(macOS 26.0, *) {
                    content.glassEffect(.regular.tint(.black.opacity(intensity.tintOpacity)).interactive(), in: shape)
                } else { content.background(.ultraThinMaterial, in: shape) }
            }
        }
        .clipShape(shape).contentShape(shape)
        .onReceive(NotificationCenter.default.publisher(for: .panelAppearanceDidChange)) { _ in appearance = PanelAppearance.selected }
        .onReceive(NotificationCenter.default.publisher(for: .glassIntensityDidChange)) { _ in intensity = GlassIntensity.selected }
    }
}
