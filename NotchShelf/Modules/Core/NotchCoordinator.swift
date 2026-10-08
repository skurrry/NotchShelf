import Foundation
import Observation

@MainActor @Observable
final class NotchCoordinator {
    func compactContent(for state: AppState) -> CompactContent {
        if state.timer.isAlarming { return .timerAlarm }
        if state.timer.isActive { return .timer }
        return .idleModules
    }
}
