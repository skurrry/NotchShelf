import SwiftUI

struct TimerCompactView: View {
    @Bindable var timer: TimerModule
    let onExpand: () -> Void

    var body: some View {
        TimelineView(
            .periodic(
                from: .now,
                by: 1
            )
        ) { context in
            LiquidGlassSurface(
                cornerRadius: 18
            ) {
                HStack(spacing: 13) {
                    progressIndicator(
                        at: context.date
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {
                        Text(
                            timer.formattedRemaining(
                                at: context.date
                            )
                        )
                        .font(
                            .system(
                                size: 22,
                                weight: .semibold,
                                design: .rounded
                            )
                            .monospacedDigit()
                        )

                        Text(
                            timer.isRunning
                                ? "Timer läuft"
                                : "Timer pausiert"
                        )
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 4)

                    Button {
                        timer.togglePause()
                    } label: {
                        Image(
                            systemName:
                                timer.isRunning
                                    ? "pause.fill"
                                    : "play.fill"
                        )
                        .frame(
                            width: 28,
                            height: 28
                        )
                    }
                    .buttonStyle(.glass)
                    .help(
                        timer.isRunning
                            ? "Timer pausieren"
                            : "Timer fortsetzen"
                    )

                    Button(action: onExpand) {
                        Image(
                            systemName:
                                "arrow.up.left.and.arrow.down.right"
                        )
                        .frame(
                            width: 28,
                            height: 28
                        )
                    }
                    .buttonStyle(.glass)
                    .help("Timer öffnen")
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
            }
        }
        .accessibilityElement(
            children: .contain
        )
    }

    private func progressIndicator(
        at date: Date
    ) -> some View {
        ZStack {
            Circle()
                .stroke(
                    .white.opacity(0.10),
                    lineWidth: 5
                )

            Circle()
                .trim(
                    from: 0,
                    to: min(
                        1,
                        max(
                            0,
                            timer.progress(at: date)
                        )
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            .cyan,
                            .blue,
                            .purple
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .shadow(
                    color: .cyan.opacity(0.42),
                    radius: 5
                )

            Image(systemName: "timer")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(width: 46, height: 46)
        .animation(
            .smooth(duration: 0.40),
            value: timer.progress(at: date)
        )
        .accessibilityLabel("Timerfortschritt")
        .accessibilityValue(
            "\(Int(timer.progress(at: date) * 100)) Prozent"
        )
    }
}
