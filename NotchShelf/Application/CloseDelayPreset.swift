import Foundation

enum CloseDelayPreset: String, CaseIterable, Identifiable, Sendable {
    case immediate, short, normal, long
    var id: String { rawValue }
    var title: String { switch self { case .immediate: "Sofort"; case .short: "Kurz"; case .normal: "Normal"; case .long: "Lang" } }
    var duration: TimeInterval { switch self { case .immediate: 0.05; case .short: 0.35; case .normal: 0.75; case .long: 1.5 } }
    static var selected: Self {
        get { Self(rawValue: UserDefaults.standard.string(forKey: "panel.closeDelay") ?? "") ?? .normal }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "panel.closeDelay") }
    }
}
