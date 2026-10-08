import SwiftUI

struct BreakReminderCardView: View {
    @Bindable var reminder: BreakReminderModule

    var body: some View {
        if reminder.isBreakDue {
            HStack(spacing: 12) {
                Image(systemName: "figure.walk")
                    .font(.title2)
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Zeit für eine Pause")
                        .font(.headline)
                    Text("Kurz aufstehen, bewegen und den Blick entspannen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("5 Min später") {
                    reminder.postpone()
                }

                Button("Erledigt") {
                    reminder.takeBreak()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.green.opacity(0.12))
            )
        }
    }
}
