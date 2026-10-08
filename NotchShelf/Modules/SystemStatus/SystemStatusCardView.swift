import SwiftUI

struct SystemStatusCardView: View {
    @Bindable var status: SystemStatusModule

    var body: some View {
        HStack(spacing: 12) {
            statusTile(
                symbol: status.isCharging ? "battery.100percent.bolt" : "battery.75percent",
                title: status.batteryPercent.map { "\($0) %" } ?? "Unbekannt",
                subtitle: status.isCharging ? "Wird geladen" : (status.isOnACPower ? "Netzbetrieb" : "Batterie")
            )

            statusTile(
                symbol: status.wifiPowerOn ? "wifi" : "wifi.slash",
                title: status.wifiName ?? (status.wifiPowerOn ? "Verbunden" : "WLAN aus"),
                subtitle: "WLAN"
            )
        }
    }

    private func statusTile(symbol: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.title3)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).lineLimit(1)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.06)))
    }
}
