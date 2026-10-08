import AppKit
import SwiftUI

@MainActor final class SettingsWindowController: NSWindowController {
    init(breakReminder: BreakReminderModule) {
        let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView(breakReminder: breakReminder)))
        window.title = "NotchShelf Einstellungen"; window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false; window.setContentSize(.init(width: 640, height: 530)); window.center()
        super.init(window: window)
    }
    required init?(coder: NSCoder) { nil }
    func showSettings() { showWindow(nil); window?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
}
