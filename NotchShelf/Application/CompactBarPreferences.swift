import Foundation

enum CompactBarDensity: String, CaseIterable, Identifiable, Sendable {
    case minimal
    case balanced
    case informative

    var id: String { rawValue }

    var title: String {
        switch self {
        case .minimal: return "Minimal"
        case .balanced: return "Ausgewogen"
        case .informative: return "Informativ"
        }
    }

    static var selected: Self {
        get {
            Self(
                rawValue: UserDefaults.standard.string(
                    forKey: "compactBar.density"
                ) ?? ""
            ) ?? .balanced
        }
        set {
            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: "compactBar.density"
            )
            NotificationCenter.default.post(
                name: .compactBarPreferencesDidChange,
                object: nil
            )
        }
    }
}

enum CompactBarPreferences {
    static var showFileStatus: Bool {
        get {
            UserDefaults.standard.object(
                forKey: "compactBar.showFileStatus"
            ) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: "compactBar.showFileStatus"
            )
            notify()
        }
    }

    static var showBatteryWhenRelevant: Bool {
        get {
            UserDefaults.standard.object(
                forKey: "compactBar.showBatteryWhenRelevant"
            ) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: "compactBar.showBatteryWhenRelevant"
            )
            notify()
        }
    }

    static var showNextBreak: Bool {
        get {
            UserDefaults.standard.object(
                forKey: "compactBar.showNextBreak"
            ) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: "compactBar.showNextBreak"
            )
            notify()
        }
    }

    private static func notify() {
        NotificationCenter.default.post(
            name: .compactBarPreferencesDidChange,
            object: nil
        )
    }
}

extension Notification.Name {
    static let compactBarPreferencesDidChange = Notification.Name(
        "NotchShelf.compactBarPreferencesDidChange"
    )
}
