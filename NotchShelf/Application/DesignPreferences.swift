import Foundation

enum TimerPresentationStyle: String, CaseIterable, Identifiable, Sendable {
    case largeRing, sideRing, liquidBar
    var id: String { rawValue }
    var title: String {
        switch self {
        case .largeRing: return "Großer Fortschrittsring"
        case .sideRing: return "Ring links, Zeit rechts"
        case .liquidBar: return "Flüssigkeitsbalken"
        }
    }
    static var selected: Self {
        get { Self(rawValue: UserDefaults.standard.string(forKey: "timer.presentationStyle") ?? "") ?? .largeRing }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "timer.presentationStyle"); post(.timerPresentationDidChange) }
    }
}

enum ShelfNavigationStyle: String, CaseIterable, Identifiable, Sendable {
    case topFolders, sidebar, cabinetOverview
    var id: String { rawValue }
    var title: String {
        switch self {
        case .topFolders: return "Ordnerleiste oben"
        case .sidebar: return "Seitenleiste links"
        case .cabinetOverview: return "Große Schrankübersicht"
        }
    }
    static var selected: Self {
        get { Self(rawValue: UserDefaults.standard.string(forKey: "shelf.navigationStyle") ?? "") ?? .cabinetOverview }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "shelf.navigationStyle"); post(.shelfNavigationDidChange) }
    }
}

enum GlassIntensity: String, CaseIterable, Identifiable, Sendable {
    case clear, balanced, dark
    var id: String { rawValue }
    var title: String {
        switch self { case .clear: return "Klar"; case .balanced: return "Ausgewogen"; case .dark: return "Dunkel" }
    }
    var tintOpacity: Double {
        switch self { case .clear: return 0.12; case .balanced: return 0.34; case .dark: return 0.72 }
    }
    var borderOpacity: Double {
        switch self { case .clear: return 0.34; case .balanced: return 0.24; case .dark: return 0.14 }
    }
    var shadowOpacity: Double {
        switch self { case .clear: return 0.20; case .balanced: return 0.34; case .dark: return 0.48 }
    }
    static var selected: Self {
        get { Self(rawValue: UserDefaults.standard.string(forKey: "panel.glassIntensity") ?? "") ?? .balanced }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "panel.glassIntensity"); post(.glassIntensityDidChange) }
    }
}

enum PanelAppearance: String, CaseIterable, Identifiable, Sendable {
    case translucent, black, liquidGlass
    var id: String { rawValue }
    var title: String {
        switch self { case .translucent: return "Transparent"; case .black: return "Tiefschwarz"; case .liquidGlass: return "Liquid Glass" }
    }
    static var selected: Self {
        get { Self(rawValue: UserDefaults.standard.string(forKey: "panel.appearance") ?? "") ?? .liquidGlass }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "panel.appearance"); post(.panelAppearanceDidChange) }
    }
}

private func post(_ name: Notification.Name) {
    NotificationCenter.default.post(name: name, object: nil)
}

extension Notification.Name {
    static let timerPresentationDidChange = Notification.Name("NotchShelf.timerPresentationDidChange")
    static let shelfNavigationDidChange = Notification.Name("NotchShelf.shelfNavigationDidChange")
    static let glassIntensityDidChange = Notification.Name("NotchShelf.glassIntensityDidChange")
    static let panelAppearanceDidChange = Notification.Name("NotchShelf.panelAppearanceDidChange")
}
