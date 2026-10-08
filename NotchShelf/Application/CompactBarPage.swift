import Foundation

enum CompactBarPage: String, CaseIterable, Identifiable, Sendable {
    case day
    case files
    case system
    case breakStatus

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day: return "Tagesübersicht"
        case .files: return "Dateischrank"
        case .system: return "Systemstatus"
        case .breakStatus: return "Pausenstatus"
        }
    }

    var symbol: String {
        switch self {
        case .day: return "calendar"
        case .files: return "tray.full.fill"
        case .system: return "battery.75percent"
        case .breakStatus: return "figure.walk"
        }
    }

    func next() -> Self {
        let values = Self.allCases
        guard let index = values.firstIndex(of: self) else { return .day }
        return values[(index + 1) % values.count]
    }
}
