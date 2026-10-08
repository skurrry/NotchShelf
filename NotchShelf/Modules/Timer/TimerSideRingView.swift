import SwiftUI

struct TimerSideRingView: View {
    @Bindable var timer: TimerModule
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            LiquidGlassSurface(cornerRadius: 26) {
                HStack(spacing: 24) {
                    ZStack {
                        LiquidProgressRing(progress: timer.progress(at: context.date), lineWidth: 8)
                        Image(systemName: "timer").font(.title2)
                    }
                    .frame(width: 102, height: 102)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(timer.formattedRemaining(at: context.date))
                            .font(.system(size: 40, weight: .semibold, design: .rounded).monospacedDigit())
                        TimerSharedControls(timer: timer)
                    }
                    Spacer()
                }
                .padding(24)
            }
        }
    }
}
