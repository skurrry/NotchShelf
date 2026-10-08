import Foundation
import Observation

@MainActor
@Observable
final class TimerModule {
    enum State: Equatable, Sendable {
        case idle
        case running
        case paused
        case alarming
    }

    private(set) var state: State = .idle
    private(set) var configuredDuration: TimeInterval = 5 * 60
    private(set) var remainingWhenPaused: TimeInterval = 0
    private(set) var endDate: Date?

    var selectedHours = 0
    var selectedMinutes = 5
    var selectedSeconds = 0

    var onAlarmStarted: (() -> Void)?
    var onAlarmStopped: (() -> Void)?

    private let alarmSound = AlarmSoundService()
    private var completionTimer: Timer?
    private var lastStartedDuration: TimeInterval = 5 * 60

    var isActive: Bool {
        state == .running || state == .paused
    }

    var isRunning: Bool {
        state == .running
    }

    var isPaused: Bool {
        state == .paused
    }

    var isAlarming: Bool {
        state == .alarming
    }

    var hasConfiguredDuration: Bool {
        inputDuration > 0
    }

    var inputDuration: TimeInterval {
        TimeInterval(
            max(0, selectedHours) * 3_600
            + max(0, selectedMinutes) * 60
            + max(0, selectedSeconds)
        )
    }

    var remainingTime: TimeInterval {
        remaining(at: .now)
    }

    var formattedRemaining: String {
        formattedRemaining(at: .now)
    }

    var progress: Double {
        progress(at: .now)
    }

    func start() {
        start(duration: inputDuration)
    }

    func start(duration: TimeInterval) {
        let duration = max(1, duration)

        stopCompletionTimer()
        alarmSound.stop()

        configuredDuration = duration
        lastStartedDuration = duration
        remainingWhenPaused = duration
        endDate = Date().addingTimeInterval(duration)
        state = .running

        scheduleCompletion(after: duration)
    }

    func start(hours: Int, minutes: Int, seconds: Int) {
        selectedHours = max(0, hours)
        selectedMinutes = max(0, minutes)
        selectedSeconds = max(0, seconds)
        start()
    }

    func startPreset(minutes: Int) {
        selectedHours = 0
        selectedMinutes = max(0, minutes)
        selectedSeconds = 0
        start()
    }

    func togglePause() {
        switch state {
        case .running:
            pause()
        case .paused:
            resume()
        case .idle, .alarming:
            break
        }
    }

    func pause() {
        guard state == .running else {
            return
        }

        remainingWhenPaused = remaining(at: .now)
        endDate = nil
        state = .paused
        stopCompletionTimer()
    }

    func resume() {
        guard state == .paused else {
            return
        }

        let duration = max(1, remainingWhenPaused)
        endDate = Date().addingTimeInterval(duration)
        state = .running
        scheduleCompletion(after: duration)
    }

    func addFiveMinutes() {
        add(seconds: 5 * 60)
    }

    func add(minutes: Int) {
        add(seconds: TimeInterval(minutes * 60))
    }

    func add(seconds: TimeInterval) {
        guard seconds > 0 else {
            return
        }

        switch state {
        case .running:
            let newRemaining = remaining(at: .now) + seconds
            configuredDuration += seconds
            lastStartedDuration += seconds
            remainingWhenPaused = newRemaining
            endDate = Date().addingTimeInterval(newRemaining)
            scheduleCompletion(after: newRemaining)

        case .paused:
            remainingWhenPaused += seconds
            configuredDuration += seconds
            lastStartedDuration += seconds

        case .alarming:
            snooze(minutes: Int(seconds / 60))

        case .idle:
            let total = inputDuration + seconds
            setInputDuration(total)
        }
    }

    func cancel() {
        let wasAlarming = isAlarming

        stopCompletionTimer()
        alarmSound.stop()

        endDate = nil
        remainingWhenPaused = 0
        state = .idle

        if wasAlarming {
            onAlarmStopped?()
        }
    }

    func stopAlarm() {
        guard isAlarming else {
            return
        }

        alarmSound.stop()
        state = .idle
        endDate = nil
        remainingWhenPaused = 0
        onAlarmStopped?()
    }

    func acknowledgeAlarm() {
        stopAlarm()
    }

    func restart() {
        stopCompletionTimer()
        alarmSound.stop()

        let duration = max(1, lastStartedDuration)
        configuredDuration = duration
        remainingWhenPaused = duration
        endDate = Date().addingTimeInterval(duration)
        state = .running

        onAlarmStopped?()
        scheduleCompletion(after: duration)
    }

    func snooze(minutes: Int = 5) {
        let duration = TimeInterval(max(1, minutes) * 60)

        stopCompletionTimer()
        alarmSound.stop()

        configuredDuration = duration
        remainingWhenPaused = duration
        endDate = Date().addingTimeInterval(duration)
        state = .running

        onAlarmStopped?()
        scheduleCompletion(after: duration)
    }

    func remaining(at date: Date) -> TimeInterval {
        switch state {
        case .running:
            guard let endDate else {
                return 0
            }
            return max(0, endDate.timeIntervalSince(date))

        case .paused:
            return max(0, remainingWhenPaused)

        case .idle, .alarming:
            return 0
        }
    }

    func progress(at date: Date) -> Double {
        guard configuredDuration > 0 else {
            return 0
        }

        let elapsed = configuredDuration - remaining(at: date)
        return min(1, max(0, elapsed / configuredDuration))
    }

    func formattedRemaining(at date: Date) -> String {
        Self.format(seconds: remaining(at: date))
    }

    func setInputDuration(_ duration: TimeInterval) {
        let totalSeconds = max(0, Int(duration.rounded()))
        selectedHours = totalSeconds / 3_600
        selectedMinutes = (totalSeconds % 3_600) / 60
        selectedSeconds = totalSeconds % 60
    }

    private func scheduleCompletion(after interval: TimeInterval) {
        stopCompletionTimer()

        let timer = Timer(
            timeInterval: max(0.05, interval),
            target: self,
            selector: #selector(completionTimerFired),
            userInfo: nil,
            repeats: false
        )

        completionTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopCompletionTimer() {
        completionTimer?.invalidate()
        completionTimer = nil
    }

    @objc private func completionTimerFired() {
        guard state == .running else {
            return
        }

        completionTimer = nil
        endDate = nil
        remainingWhenPaused = 0
        state = .alarming

        alarmSound.startLooping()
        onAlarmStarted?()
    }

    private static func format(seconds: TimeInterval) -> String {
        let total = max(0, Int(ceil(seconds)))
        let hours = total / 3_600
        let minutes = (total % 3_600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(
                format: "%02d:%02d:%02d",
                hours,
                minutes,
                seconds
            )
        }

        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }
}
