import SwiftUI

struct TimerSharedControls: View {
    @Bindable var timer: TimerModule
    var body: some View {
        HStack(spacing: 12) {
            Button("Abbrechen", role: .destructive) { timer.cancel() }
                .buttonStyle(.borderless)
            Button { timer.togglePause() } label: {
                Label(timer.isRunning ? "Pause" : "Fortsetzen", systemImage: timer.isRunning ? "pause.fill" : "play.fill")
                    .frame(minWidth: 92)
            }
            .buttonStyle(.glassProminent)
            Button("+5 Min") { timer.addFiveMinutes() }
                .buttonStyle(.glass)
        }
    }
}
