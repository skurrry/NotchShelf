import SwiftUI

struct TimerLargeRingView: View {
    @Bindable var timer: TimerModule
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            LiquidGlassSurface(cornerRadius: 28) {
                VStack(spacing: 18) {
                    ZStack {
                        LiquidProgressRing(progress: timer.progress(at: context.date), lineWidth: 12)
                        VStack(spacing: 4) {
                            Text(timer.formattedRemaining(at: context.date))
                                .font(.system(size: 42, weight: .semibold, design: .rounded).monospacedDigit())
                            Text(timer.isRunning ? "Läuft" : "Pausiert")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 218, height: 218)
                    TimerSharedControls(timer: timer)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
