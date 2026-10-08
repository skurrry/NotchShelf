import SwiftUI

struct PanelRootView: View {
    @Bindable var appState: AppState
    let onOpenTab: (DashboardTab) -> Void
    let onCollapse: () -> Void
    let onClose: () -> Void

    var body: some View {
        PanelSurface(shape: panelShape) {
            Group {
                switch appState.panelMode {
                case .idle:
                    EmptyView()
                case .preview:
                    compactContent
                case .dashboard:
                    dashboardContent
                case .dropTarget(let count):
                    dropTargetContent(count)
                case .alarm:
                    TimerAlarmView(timer: appState.timer)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var compactContent: some View {
        switch appState.coordinator.compactContent(for: appState) {
        case .timerAlarm:
            TimerAlarmView(timer: appState.timer)

        case .timer:
            TimerCompactView(
                timer: appState.timer,
                onExpand: {
                    onOpenTab(.timer)
                }
            )
            .padding(.top, 38)
            .padding(.horizontal, 18)
            .padding(.bottom, 16)

        case .idleModules:
            SmartDailyBarView(
                appState: appState,
                onOpenTab: onOpenTab
            )
        }
    }

    private var dashboardContent: some View {
        VStack(spacing: 12) {
            dashboardHeader
            dashboardTabBar

            Divider()
                .overlay(.white.opacity(0.14))
                .padding(.horizontal, 18)

            BreakReminderCardView(
                reminder: appState.breakReminder
            )
            .padding(.horizontal, 18)

            ZStack(alignment: .top) {
                activeTabContent
                    .id(appState.selectedDashboardTab)
                    .transition(
                        .asymmetric(
                            insertion: .scale(
                                scale: 0.965,
                                anchor: .top
                            )
                            .combined(with: .opacity),
                            removal: .scale(
                                scale: 0.985,
                                anchor: .top
                            )
                            .combined(with: .opacity)
                        )
                    )
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()

            Spacer(minLength: 0)
        }
        .padding(.bottom, 18)
    }

    private var dashboardHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("NotchShelf")
                    .font(.headline)
                Text(appState.selectedDashboardTab.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.opacity)
            }

            Spacer()

            roundButton(
                symbol: "chevron.up",
                help: "Notch einklappen",
                action: onCollapse
            )

            roundButton(
                symbol: "xmark",
                help: "Notch schließen",
                action: onClose
            )
        }
        .padding(.top, 38)
        .padding(.horizontal, 20)
    }

    private var dashboardTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DashboardTab.allCases) { tab in
                    Button {
                        guard tab != appState.selectedDashboardTab else {
                            return
                        }

                        withAnimation(
                            .smooth(
                                duration: 0.28,
                                extraBounce: 0.04
                            )
                        ) {
                            appState.selectedDashboardTab = tab
                        }
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: tab.symbol)
                                .contentTransition(.symbolEffect(.replace))

                            Text(tab.title)
                                .font(.subheadline.weight(.semibold))

                            if tab == .shelf,
                               !appState.shelfItems.isEmpty {
                                Text("\(appState.shelfItems.count)")
                                    .font(.caption2.weight(.bold))
                                    .contentTransition(
                                        .numericText(
                                            value: Double(
                                                appState.shelfItems.count
                                            )
                                        )
                                    )
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(.cyan.opacity(0.82))
                                    )
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    appState.selectedDashboardTab == tab
                                        ? .white.opacity(0.18)
                                        : .white.opacity(0.06)
                                )
                        )
                        .scaleEffect(
                            appState.selectedDashboardTab == tab
                                ? 1.0
                                : 0.98
                        )
                    }
                    .buttonStyle(.plain)
                    .help("\(tab.title) öffnen")
                }
            }
            .padding(.horizontal, 18)
        }
    }

    @ViewBuilder
    private var activeTabContent: some View {
        switch appState.selectedDashboardTab {
        case .shelf:
            ShelfDashboardView(appState: appState)
        case .timer:
            TimerDashboardCard(timer: appState.timer)
        case .clipboard:
            ClipboardCardView(clipboard: appState.clipboard)
        case .status:
            SystemStatusCardView(status: appState.systemStatus)
        }
    }

    private func dropTargetContent(_ count: Int) -> some View {
        VStack(spacing: 18) {
            Spacer(minLength: 24)

            Image(systemName: "tray.and.arrow.down.fill")
                .font(.system(size: 44, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.cyan)

            Text("Im Schrank ablegen")
                .font(.title3.weight(.semibold))

            Text(
                count == 1
                    ? "Eine Datei erkannt"
                    : "\(count) Dateien erkannt"
            )
            .foregroundStyle(.secondary)

            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .stroke(
                .cyan,
                style: StrokeStyle(
                    lineWidth: 2,
                    dash: [9, 6]
                )
            )
            .overlay {
                Text("Loslassen zum dauerhaften Ablegen")
                    .font(.headline)
                    .foregroundStyle(.cyan)
            }
            .frame(height: 116)
            .padding(.horizontal, 24)

            Spacer(minLength: 24)
        }
        .padding(.top, 32)
        .padding(.bottom, 18)
    }

    private func roundButton(
        symbol: String,
        help: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.white.opacity(0.11))
                )
        }
        .buttonStyle(.plain)
        .help(help)
    }

    private var panelShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 28,
            bottomTrailingRadius: 28,
            topTrailingRadius: 0,
            style: .continuous
        )
    }
}
