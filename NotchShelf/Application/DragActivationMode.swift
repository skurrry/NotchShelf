import Foundation

enum DragActivationMode: String, CaseIterable, Identifiable, Sendable {
    case nearNotch, immediate
    var id: String { rawValue }
    var title: String { self == .nearNotch ? "Bei Annäherung" : "Sofort bei Datei-Drag" }
    static var selected: Self {
        get { Self(rawValue: UserDefaults.standard.string(forKey: "shelf.dragActivation") ?? "") ?? .nearNotch }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "shelf.dragActivation") }
    }
}
