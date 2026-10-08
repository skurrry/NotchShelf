import SwiftUI

struct SettingsView: View {
    @Bindable var breakReminder: BreakReminderModule

    @State private var appearance = PanelAppearance.selected
    @State private var glassIntensity = GlassIntensity.selected
    @State private var animationPreset = PanelAnimationPreset.selected
    @State private var animationSpeed = PanelAnimationPreset.speed
    @State private var closeDelay = CloseDelayPreset.selected
    @State private var timerStyle = TimerPresentationStyle.selected
    @State private var dragMode = DragActivationMode.selected

    @AppStorage("alarm.sound")
    private var alarmSoundRaw = AlarmSoundChoice.classic.rawValue

    @AppStorage("breakReminder.enabled")
    private var breakEnabled = false

    @AppStorage("breakReminder.intervalMinutes")
    private var breakMinutes = 45

    @State private var alarmSoundService = AlarmSoundService()

    var body: some View {
        TabView {
            notchSettings
                .tabItem {
                    Label(
                        "Notch",
                        systemImage: "rectangle.topthird.inset.filled"
                    )
                }

            CompactBarSettingsView()
                .tabItem {
                    Label(
                        "Compact",
                        systemImage: "calendar.day.timeline.left"
                    )
                }

            timerSettings
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }

            shelfSettings
                .tabItem {
                    Label("Schrank", systemImage: "cabinet.fill")
                }
        }
        .padding(16)
        .frame(width: 650, height: 540)
        .onDisappear {
            alarmSoundService.stop()
        }
    }

    // MARK: - Notch

    private var notchSettings: some View {
        Form {
            Section("Erscheinungsbild") {
                Picker(
                    "Design",
                    selection: $appearance
                ) {
                    ForEach(PanelAppearance.allCases) { value in
                        Text(value.title)
                            .tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: appearance) { _, value in
                    PanelAppearance.selected = value
                }

                Picker(
                    "Liquid-Glass-Intensität",
                    selection: $glassIntensity
                ) {
                    ForEach(GlassIntensity.allCases) { value in
                        Text(value.title)
                            .tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(appearance != .liquidGlass)
                .onChange(of: glassIntensity) { _, value in
                    GlassIntensity.selected = value
                }

                if appearance != .liquidGlass {
                    Text(
                        "Die Glasintensität ist nur beim Design „Liquid Glass“ verfügbar."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Section("Öffnungsanimation") {
                Picker(
                    "Animation",
                    selection: $animationPreset
                ) {
                    ForEach(PanelAnimationPreset.allCases) { preset in
                        Text(preset.title)
                            .tag(preset)
                    }
                }
                .onChange(of: animationPreset) { _, value in
                    PanelAnimationPreset.selected = value
                }

                Text(animationPreset.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Text("Langsamer")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Slider(
                        value: $animationSpeed,
                        in: 0.5...2.0,
                        step: 0.1
                    )
                    .disabled(animationPreset == .none)
                    .onChange(of: animationSpeed) { _, value in
                        PanelAnimationPreset.speed = value
                    }

                    Text("Schneller")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Geschwindigkeit")
                    Spacer()
                    Text(
                        animationPreset == .none
                            ? "Deaktiviert"
                            : String(
                                format: "%.1f×",
                                animationSpeed
                            )
                    )
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                }

                Text(
                    "Die neue Geschwindigkeit wird beim nächsten vollständigen Öffnen oder Größenwechsel der Notch verwendet."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Section("Automatisches Schließen") {
                Picker(
                    "Verzögerung",
                    selection: $closeDelay
                ) {
                    ForEach(CloseDelayPreset.allCases) { preset in
                        Text(preset.title)
                            .tag(preset)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: closeDelay) { _, value in
                    CloseDelayPreset.selected = value
                }

                Text(
                    "Bestimmt, wie lange die Notch nach Verlassen mit der Maus geöffnet bleibt."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Timer

    private var timerSettings: some View {
        Form {
            Section("Timer-Darstellung") {
                Picker(
                    "Stil",
                    selection: $timerStyle
                ) {
                    ForEach(TimerPresentationStyle.allCases) { style in
                        Text(style.title)
                            .tag(style)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: timerStyle) { _, value in
                    TimerPresentationStyle.selected = value
                }
            }

            Section("Timeralarm") {
                Picker(
                    "Alarmton",
                    selection: $alarmSoundRaw
                ) {
                    ForEach(AlarmSoundChoice.allCases) { sound in
                        Text(sound.title)
                            .tag(sound.rawValue)
                    }
                }

                HStack {
                    Button("Ton testen") {
                        alarmSoundService.preview(
                            choice: selectedAlarmSound
                        )
                    }

                    Button("Test stoppen") {
                        alarmSoundService.stop()
                    }
                }

                Text(
                    "Die Alarmlautstärke richtet sich nach der macOS-Systemlautstärke."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Section("Pausen-Erinnerung") {
                Toggle(
                    "Pausen-Erinnerung aktivieren",
                    isOn: $breakEnabled
                )

                Stepper(
                    "Pause alle \(breakMinutes) Minuten",
                    value: $breakMinutes,
                    in: 10...180,
                    step: 5
                )
                .disabled(!breakEnabled)

                Text(
                    "Eine fällige Pause wird mit hoher Priorität in der intelligenten Tagesleiste angezeigt."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .onChange(of: breakEnabled) { _, _ in
            breakReminder.settingsDidChange()
        }
        .onChange(of: breakMinutes) { _, _ in
            breakReminder.settingsDidChange()
        }
    }

    // MARK: - Shelf

    private var shelfSettings: some View {
        Form {
            Section("Datei-Drag") {
                Picker(
                    "Schrank öffnen",
                    selection: $dragMode
                ) {
                    ForEach(DragActivationMode.allCases) { mode in
                        Text(mode.title)
                            .tag(mode)
                    }
                }
                .onChange(of: dragMode) { _, value in
                    DragActivationMode.selected = value
                }

                Text(dragModeDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Darstellung") {
                LabeledContent("Organisation") {
                    Text("Ein gemeinsamer Dateischrank")
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Dateivorschau") {
                    Text("Doppelklick für Quick Look")
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Weitere Aktionen") {
                    Text("über das Kontextmenü")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Dauerhafte Speicherung") {
                Text(
                    "Dateien bleiben nach App-Neustarts erhalten. Beim Löschen einer Datei oder beim Leeren des Schranks wird die gespeicherte Kopie ebenfalls entfernt."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Helpers

    private var selectedAlarmSound: AlarmSoundChoice {
        AlarmSoundChoice(
            rawValue: alarmSoundRaw
        ) ?? .classic
    }

    private var dragModeDescription: String {
        switch dragMode {
        case .nearNotch:
            return "Der Schrank öffnet erst, wenn eine Datei in die Nähe der Notch gezogen wird. Das reduziert unnötige Pasteboard-Zugriffe."

        case .immediate:
            return "Der Schrank öffnet bereits, sobald ein Datei-Drag erkannt wird."
        }
    }
}
