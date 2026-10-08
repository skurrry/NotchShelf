import Foundation
import Observation

@MainActor
@Observable
final class BreakReminderModule: NSObject {
    private(set) var isBreakDue = false
    private(set) var nextBreakDate: Date?
    private var timer: Timer?

    var enabled: Bool {
        UserDefaults.standard.bool(forKey: "breakReminder.enabled")
    }

    var intervalMinutes: Int {
        let value = UserDefaults.standard.integer(forKey: "breakReminder.intervalMinutes")
        return value == 0 ? 45 : value
    }

    func start() {
        restartSchedule()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func settingsDidChange() {
        restartSchedule()
    }

    func takeBreak() {
        isBreakDue = false
        restartSchedule()
    }

    func postpone(minutes: Int = 5) {
        schedule(after: TimeInterval(minutes * 60))
        isBreakDue = false
    }

    private func restartSchedule() {
        timer?.invalidate()
        timer = nil
        isBreakDue = false

        guard enabled else {
            nextBreakDate = nil
            return
        }

        schedule(after: TimeInterval(intervalMinutes * 60))
    }

    private func schedule(after interval: TimeInterval) {
        timer?.invalidate()
        nextBreakDate = Date().addingTimeInterval(interval)

        let timer = Timer(
            timeInterval: interval,
            target: self,
            selector: #selector(reminderFired),
            userInfo: nil,
            repeats: false
        )
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    @objc private func reminderFired() {
        timer = nil
        isBreakDue = true
        nextBreakDate = nil
    }
}
