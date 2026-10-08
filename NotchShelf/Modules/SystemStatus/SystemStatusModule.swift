import CoreWLAN
import Foundation
import IOKit.ps
import Observation

@MainActor
@Observable
final class SystemStatusModule: NSObject {
    private(set) var batteryPercent: Int?
    private(set) var isCharging = false
    private(set) var isOnACPower = false
    private(set) var wifiPowerOn = false
    private(set) var wifiName: String?

    private let wifiClient = CWWiFiClient.shared()
    private var timer: Timer?

    func start() {
        guard timer == nil else { return }
        refresh()

        let timer = Timer(
            timeInterval: 15,
            target: self,
            selector: #selector(refreshTimerFired),
            userInfo: nil,
            repeats: true
        )
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        refreshBattery()
        refreshWiFi()
    }

    private func refreshBattery() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            batteryPercent = nil
            return
        }

        isOnACPower = IOPSGetProvidingPowerSourceType(snapshot)
            .takeUnretainedValue() as String == kIOPSACPowerValue

        guard let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            batteryPercent = nil
            return
        }

        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(snapshot, source)
                .takeUnretainedValue() as? [String: Any] else { continue }

            guard description[kIOPSTypeKey] as? String == kIOPSInternalBatteryType else { continue }

            let current = description[kIOPSCurrentCapacityKey] as? Int ?? 0
            let maximum = description[kIOPSMaxCapacityKey] as? Int ?? 100
            batteryPercent = maximum > 0 ? Int((Double(current) / Double(maximum) * 100).rounded()) : nil
            isCharging = description[kIOPSIsChargingKey] as? Bool ?? false
            return
        }
    }

    private func refreshWiFi() {
        guard let interface = wifiClient.interface() else {
            wifiPowerOn = false
            wifiName = nil
            return
        }

        wifiPowerOn = interface.powerOn()
        wifiName = interface.ssid()
    }

    @objc private func refreshTimerFired() {
        refresh()
    }
}
