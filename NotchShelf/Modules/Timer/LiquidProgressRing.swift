import SwiftUI

struct LiquidProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.10), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(1, max(0, progress)))
                .stroke(
                    AngularGradient(colors: [.cyan, .blue, .purple, .cyan], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: .cyan.opacity(0.45), radius: 8)
        }
        .animation(.smooth(duration: 0.45), value: progress)
    }
}
