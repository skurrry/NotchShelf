import SwiftUI

struct SmartDailyBarView: View {
    @Bindable var appState: AppState
    let onOpenTab: (DashboardTab) -> Void

    @State private var page: CompactBarPage = .day
    @State private var density = CompactBarDensity.selected
    @State private var showFiles = CompactBarPreferences.showFileStatus
    @State private var showBattery = CompactBarPreferences.showBatteryWhenRelevant
    @State private var showBreak = CompactBarPreferences.showNextBreak

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            HStack(spacing: 12) {
                pageContent(date: context.date)
                    .id(page)
                    .transition(
                        .scale(scale: 0.96, anchor: .top)
                            .combined(with: .opacity)
                    )

                Spacer(minLength: 8)

                controlButtons
            }
            .padding(.leading, 18)
            .padding(.trailing, 14)
            .padding(.top, 36)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity)
            .animation(
                .smooth(duration: 0.24, extraBounce: 0.04),
                value: page
            )
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .compactBarPreferencesDidChange
            )
        ) { _ in
            density = CompactBarDensity.selected
            showFiles = CompactBarPreferences.showFileStatus
            showBattery = CompactBarPreferences.showBatteryWhenRelevant
            showBreak = CompactBarPreferences.showNextBreak
        }
    }

    @ViewBuilder
    private func pageContent(date: Date) -> some View {
        switch page {
        case .day:
            dayPage(date: date)

        case .files:
            filesPage

        case .system:
            systemPage

        case .breakStatus:
            breakPage(date: date)
        }
    }

    private func dayPage(date: Date) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(
                date.formatted(
                    .dateTime
                        .weekday(.wide)
                        .day()
                        .month(.wide)
                )
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)

            Text(
                date.formatted(
                    .dateTime.hour().minute()
                )
            )
            .font(
                .system(
                    size: 23,
                    weight: .semibold,
                    design: .rounded
                )
                .monospacedDigit()
            )
            .contentTransition(.numericText())
        }
    }

    private var filesPage: some View {
        VStack(alignment: .leading, spacing: 3) {
            Label("Dateischrank", systemImage: "tray.full.fill")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.cyan)

            if appState.shelfItems.isEmpty {
                Text("Keine Dateien")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text(
                    appState.shelfItems.count == 1
                        ? "Eine Datei · \(appState.formattedShelfSize)"
                        : "\(appState.shelfItems.count) Dateien · \(appState.formattedShelfSize)"
                )
                .font(.caption.weight(.medium))
                .contentTransition(
                    .numericText(
                        value: Double(appState.shelfItems.count)
                    )
                )
            }
        }
    }

    private var systemPage: some View {
        VStack(alignment: .leading, spacing: 3) {
            Label("System", systemImage: batterySymbol)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(
                    appState.systemStatus.isCharging
                        ? .green
                        : .secondary
                )

            if let percent = appState.systemStatus.batteryPercent {
                Text(
                    appState.systemStatus.isCharging
                        ? "\(percent) % · Wird geladen"
                        : "\(percent) % Batterie"
                )
                .font(.caption.weight(.medium))
                .monospacedDigit()
                .contentTransition(
                    .numericText(value: Double(percent))
                )
            } else {
                Text("Batteriestatus nicht verfügbar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func breakPage(date: Date) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Label(
                appState.breakReminder.isBreakDue
                    ? "Zeit für eine Pause"
                    : "Pausen-Erinnerung",
                systemImage: "figure.walk"
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(
                appState.breakReminder.isBreakDue
                    ? .green
                    : .secondary
            )

            if appState.breakReminder.isBreakDue {
                Text("Klicken, um die Pause zu bestätigen")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let nextDate = appState.breakReminder.nextBreakDate {
                Text(
                    "Nächste Pause um \(nextDate.formatted(.dateTime.hour().minute()))"
                )
                .font(.caption.weight(.medium))
            } else {
                Text("Nicht aktiv")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if appState.breakReminder.isBreakDue {
                appState.breakReminder.takeBreak()
            }
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 7) {
            Button {
                withAnimation(
                    .smooth(duration: 0.24, extraBounce: 0.04)
                ) {
                    page = page.next()
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.11))
                    )
            }
            .buttonStyle(.plain)
            .help("Nächste Information")
            .accessibilityLabel("Nächste Information")

            Button {
                onOpenTab(dashboardTabForCurrentPage)
            } label: {
                Image(systemName: "rectangle.grid.2x2.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(.cyan.opacity(0.22))
                    )
            }
            .buttonStyle(.plain)
            .help("Dashboard öffnen")
            .accessibilityLabel("Dashboard öffnen")
        }
    }

    private var dashboardTabForCurrentPage: DashboardTab {
        switch page {
        case .day, .system, .breakStatus:
            return .status
        case .files:
            return .shelf
        }
    }

    private var batterySymbol: String {
        if appState.systemStatus.isCharging {
            return "battery.100percent.bolt"
        }

        guard let percent = appState.systemStatus.batteryPercent else {
            return "battery.0percent"
        }

        switch percent {
        case 76...100: return "battery.100percent"
        case 51...75: return "battery.75percent"
        case 26...50: return "battery.50percent"
        case 1...25: return "battery.25percent"
        default: return "battery.0percent"
        }
    }
}
