import SwiftUI

enum DashboardTab: String, CaseIterable, Identifiable, Sendable {
    case shelf, timer, clipboard, status
    var id: String { rawValue }
    var title: String {
        switch self { case .shelf: "Shelf"; case .timer: "Timer"; case .clipboard: "Texte"; case .status: "Status" }
    }
    var symbol: String {
        switch self { case .shelf: "tray.full.fill"; case .timer: "timer"; case .clipboard: "doc.on.clipboard"; case .status: "macbook" }
    }
}
