import SwiftUI

struct TimerLiquidBarView: View {
    @Bindable var timer: TimerModule
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            LiquidGlassSurface(cornerRadius: 26) {
                VStack(spacing: 20) {
                    Text(timer.formattedRemaining(at: context.date))
                        .font(.system(size: 48, weight: .semibold, design: .rounded).monospacedDigit())
                    GeometryReader { proxy in
                        let progress = min(1, max(0, timer.progress(at: context.date)))
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.10))
                            Capsule()
                                .fill(LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * progress)
                                .shadow(color: .cyan.opacity(0.55), radius: 10)
                        }
                    }
                    .frame(height: 18)
                    TimerSharedControls(timer: timer)
                }
                .padding(26)
            }
        }
    }
}
