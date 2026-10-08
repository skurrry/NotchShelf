import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appState = AppState()
    private let displayService = DisplayService()

    private var panelController: NotchPanelController?
    private var settingsWindowController: SettingsWindowController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let controller = NotchPanelController(
            appState: appState,
            displayService: displayService
        )

        panelController = controller
        configureStatusItem()
        controller.start()

        // Lädt persistente Shelf-Ordner und Dateien und startet
        // Clipboard, Systemstatus und Pausen-Erinnerung.
        Task {
            await appState.prepareSession()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        panelController?.stop()

        // Beendet ausschließlich laufende Services. Persistente
        // Shelf-Daten dürfen hier ausdrücklich nicht gelöscht werden.
        appState.endSession()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.squareLength
        )

        item.button?.image = NSImage(
            systemSymbolName: "rectangle.topthird.inset.filled",
            accessibilityDescription: "NotchShelf"
        )
        item.button?.toolTip = "NotchShelf"

        let menu = NSMenu()
        menu.addItem(makeItem("Vorschau öffnen", #selector(openPreview)))
        menu.addItem(makeItem("Schrank öffnen", #selector(openShelf)))
        menu.addItem(makeItem("Timer öffnen", #selector(openTimer)))
        menu.addItem(makeItem("Texte öffnen", #selector(openClipboard)))
        menu.addItem(makeItem("Status öffnen", #selector(openStatus)))
        menu.addItem(makeItem("Panel schließen", #selector(closePanel)))
        menu.addItem(.separator())
        menu.addItem(makeItem("Einstellungen …", #selector(openSettings), key: ","))
        menu.addItem(.separator())
        menu.addItem(makeItem("NotchShelf beenden", #selector(quit), key: "q"))

        item.menu = menu
        statusItem = item
    }

    private func makeItem(
        _ title: String,
        _ action: Selector,
        key: String = ""
    ) -> NSMenuItem {
        let item = NSMenuItem(
            title: title,
            action: action,
            keyEquivalent: key
        )
        item.target = self
        item.keyEquivalentModifierMask = key.isEmpty ? [] : [.command]
        return item
    }

    @objc private func openPreview() {
        panelController?.showPreview()
    }

    @objc private func openShelf() {
        panelController?.showDashboard(tab: .shelf)
    }

    @objc private func openTimer() {
        panelController?.showDashboard(tab: .timer)
    }

    @objc private func openClipboard() {
        panelController?.showDashboard(tab: .clipboard)
    }

    @objc private func openStatus() {
        panelController?.showDashboard(tab: .status)
    }

    @objc private func closePanel() {
        panelController?.hidePanel()
    }

    @objc private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(
                breakReminder: appState.breakReminder
            )
        }

        settingsWindowController?.showSettings()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
