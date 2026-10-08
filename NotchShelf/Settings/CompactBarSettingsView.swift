import SwiftUI

struct CompactBarSettingsView: View {
    @State private var density = CompactBarDensity.selected
    @State private var showFiles = CompactBarPreferences.showFileStatus
    @State private var showBattery = CompactBarPreferences.showBatteryWhenRelevant
    @State private var showBreak = CompactBarPreferences.showNextBreak

    var body: some View {
        Form {
            Section("Intelligente Tagesleiste") {
                Picker("Informationsdichte", selection: $density) {
                    ForEach(CompactBarDensity.allCases) { value in
                        Text(value.title).tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: density) { _, value in
                    CompactBarDensity.selected = value
                }

                Toggle("Dateianzahl anzeigen", isOn: $showFiles)
                    .disabled(density == .minimal)
                    .onChange(of: showFiles) { _, value in
                        CompactBarPreferences.showFileStatus = value
                    }

                Toggle("Akku nur bei Relevanz anzeigen", isOn: $showBattery)
                    .disabled(density == .minimal)
                    .onChange(of: showBattery) { _, value in
                        CompactBarPreferences.showBatteryWhenRelevant = value
                    }

                Toggle("Nächste Pause anzeigen", isOn: $showBreak)
                    .disabled(density != .informative)
                    .onChange(of: showBreak) { _, value in
                        CompactBarPreferences.showNextBreak = value
                    }
            }

            Section("Prioritäten") {
                Text("Timeralarm, laufender Timer, fällige Pause, Akku- oder WLAN-Probleme werden automatisch vor normalen Informationen angezeigt.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Interaktion") {
                LabeledContent("Datum") {
                    Text("öffnet Status")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Uhrzeit") {
                    Text("öffnet Timer")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Dateistatus") {
                    Text("öffnet Schrank")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
}
