import SwiftUI

struct TimerDashboardCard: View {
    @Bindable var timer: TimerModule
    @State private var style = TimerPresentationStyle.selected

    private let shape = RoundedRectangle(
        cornerRadius: 24,
        style: .continuous
    )

    var body: some View {
        Group {
            if timer.isActive {
                runningTimer
            } else {
                TimerDurationInputView(timer: timer)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            shape.fill(.white.opacity(0.045))
        )
        .overlay {
            shape.stroke(.white.opacity(0.11), lineWidth: 1)
        }
        .clipShape(shape)
        .contentShape(shape)
        .onReceive(
            NotificationCenter.default.publisher(
                for: .timerPresentationDidChange
            )
        ) { _ in
            withAnimation(.smooth(duration: 0.24)) {
                style = TimerPresentationStyle.selected
            }
        }
    }

    @ViewBuilder
    private var runningTimer: some View {
        switch style {
        case .largeRing:
            TimerLargeRingView(timer: timer)
        case .sideRing:
            TimerSideRingView(timer: timer)
        case .liquidBar:
            TimerLiquidBarView(timer: timer)
        }
    }
}
