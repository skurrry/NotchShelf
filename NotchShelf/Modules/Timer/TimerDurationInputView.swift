import SwiftUI

struct TimerDurationInputView: View {
    @Bindable var timer: TimerModule

    private let presets = [5, 10, 15, 25, 30, 45, 60]

    var body: some View {
        VStack(spacing: 13) {
            header
            timeEditor
            presetBar
            startButton
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "timer")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.cyan)

            Text("Timer einstellen")
                .font(.headline)

            Spacer()

            Text(formattedInput)
                .font(
                    .system(
                        size: 18,
                        weight: .semibold,
                        design: .rounded
                    )
                    .monospacedDigit()
                )
                .foregroundStyle(.cyan)
                .contentTransition(.numericText())
        }
    }

    private var timeEditor: some View {
        HStack(spacing: 8) {
            CompactTimeField(
                title: "Std",
                value: $timer.selectedHours,
                range: 0...23
            )

            Text(":")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            CompactTimeField(
                title: "Min",
                value: $timer.selectedMinutes,
                range: 0...59
            )

            Text(":")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            CompactTimeField(
                title: "Sek",
                value: $timer.selectedSeconds,
                range: 0...59
            )
        }
    }

    private var presetBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(presets, id: \.self) { minutes in
                    Button(presetTitle(minutes)) {
                        timer.selectedHours = minutes / 60
                        timer.selectedMinutes = minutes % 60
                        timer.selectedSeconds = 0
                    }
                    .buttonStyle(.glass)
                    .controlSize(.small)
                }
            }
        }
    }

    private var startButton: some View {
        Button {
            timer.start()
        } label: {
            Label("Timer starten", systemImage: "play.fill")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .tint(.cyan)
        .disabled(!timer.hasConfiguredDuration)
        .keyboardShortcut(.return, modifiers: [])
    }

    private var formattedInput: String {
        String(
            format: "%02d:%02d:%02d",
            timer.selectedHours,
            timer.selectedMinutes,
            timer.selectedSeconds
        )
    }

    private func presetTitle(_ minutes: Int) -> String {
        minutes == 60 ? "1 Std" : "\(minutes) Min"
    }
}

private struct CompactTimeField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Button {
                    value = max(range.lowerBound, value - 1)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 18, height: 22)
                }
                .buttonStyle(.borderless)

                TextField("00", value: $value, format: .number)
                    .textFieldStyle(.plain)
                    .font(
                        .system(
                            size: 22,
                            weight: .semibold,
                            design: .rounded
                        )
                        .monospacedDigit()
                    )
                    .multilineTextAlignment(.center)
                    .frame(width: 46, height: 30)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 9,
                            style: .continuous
                        )
                        .fill(.white.opacity(0.075))
                    )
                    .onChange(of: value) { _, newValue in
                        value = min(
                            range.upperBound,
                            max(range.lowerBound, newValue)
                        )
                    }

                Button {
                    value = min(range.upperBound, value + 1)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 18, height: 22)
                }
                .buttonStyle(.borderless)
            }

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
