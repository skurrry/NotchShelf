import AppKit
import SwiftUI

struct TimerAlarmView: View {
    @Bindable var timer: TimerModule
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 15) {
            alarmSymbol

            VStack(spacing: 4) {
                Text("Timer beendet")
                    .font(.title2.weight(.semibold))

                Text("Die eingestellte Zeit ist abgelaufen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                timer.acknowledgeAlarm()
            } label: {
                Label(
                    "Alarm bestätigen",
                    systemImage: "checkmark.circle.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 3)
            }
            .buttonStyle(.glassProminent)
            .tint(.orange)
            .keyboardShortcut(.return, modifiers: [])

            HStack(spacing: 10) {
                Button {
                    timer.snooze(minutes: 5)
                } label: {
                    Label(
                        "5 Min später",
                        systemImage: "clock.arrow.circlepath"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)

                Button {
                    timer.restart()
                } label: {
                    Label(
                        "Neu starten",
                        systemImage: "arrow.counterclockwise"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(0.045))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
        .padding(.horizontal, 18)
        .padding(.top, 24)
        .padding(.bottom, 22)
        .onAppear {
            if !reduceMotion {
                pulse = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Timer beendet")
    }

    private var alarmSymbol: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .orange.opacity(0.38),
                            .orange.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 46
                    )
                )
                .frame(width: 92, height: 92)
                .scaleEffect(pulse ? 1.10 : 0.92)
                .opacity(pulse ? 0.78 : 0.38)
                .animation(
                    reduceMotion
                        ? nil
                        : .easeInOut(duration: 0.9)
                            .repeatForever(autoreverses: true),
                    value: pulse
                )

            Image(systemName: "alarm.waves.left.and.right.fill")
                .font(.system(size: 38, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.orange)
                .shadow(color: .orange.opacity(0.52), radius: 10)
        }
        .frame(height: 94)
        .accessibilityHidden(true)
    }

    private var reduceMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }
}
