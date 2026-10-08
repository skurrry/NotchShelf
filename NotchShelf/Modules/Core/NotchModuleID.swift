import Foundation

enum NotchModuleID: String, CaseIterable, Identifiable, Sendable {
    case shelf, timer, clipboard, status
    var id: String { rawValue }
}

enum CompactContent: Equatable {
    case idleModules
    case timer
    case timerAlarm
}
