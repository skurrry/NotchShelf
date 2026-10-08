import Foundation

enum PanelAnimationPreset: String, CaseIterable, Identifiable, Sendable {
    case waterfall
    case liquidStretch
    case snapDown
    case none

    var id: String { rawValue }

    var title: String {
        switch self {
        case .waterfall: return "Waterfall"
        case .liquidStretch: return "Liquid Stretch"
        case .snapDown: return "Snap Down"
        case .none: return "Keine"
        }
    }

    var detail: String {
        switch self {
        case .waterfall: return "Das Panel fließt breit von der Notch nach unten."
        case .liquidStretch: return "Das Material zieht sich viskos von oben nach unten."
        case .snapDown: return "Schnelle vertikale Expansion mit kräftigem Einrasten."
        case .none: return "Das Panel erscheint ohne Übergang."
        }
    }

    static var selected: Self {
        get {
            Self(rawValue: UserDefaults.standard.string(forKey: "panel.animation.preset") ?? "") ?? .waterfall
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "panel.animation.preset")
        }
    }

    static var speed: Double {
        get {
            guard UserDefaults.standard.object(forKey: "panel.animation.speed") != nil else { return 1.0 }
            return min(2.0, max(0.5, UserDefaults.standard.double(forKey: "panel.animation.speed")))
        }
        set {
            UserDefaults.standard.set(min(2.0, max(0.5, newValue)), forKey: "panel.animation.speed")
        }
    }
}
