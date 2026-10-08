import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    enum PanelMode: Equatable {
        case idle
        case preview
        case dashboard
        case dropTarget(itemCount: Int)
        case alarm
    }

    var panelMode: PanelMode = .idle
    var selectedDashboardTab: DashboardTab = .shelf
    var isPanelVisible = false
    var isSuppressedByFullScreen = false
    var pendingDropURLs: [URL] = []
    var shelfItems: [ShelfItem] = []
    var shelfErrorMessage: String?
    var isImportingFiles = false

    let timer = TimerModule()
    let coordinator = NotchCoordinator()
    let clipboard = ClipboardModule()
    let systemStatus = SystemStatusModule()
    let breakReminder = BreakReminderModule()
    let shelfStore = ShelfStore()
    let quickLook = QuickLookService()

    var formattedShelfSize: String {
        ByteCountFormatter.string(
            fromByteCount: shelfItems.reduce(0) { $0 + $1.byteCount },
            countStyle: .file
        )
    }

    func prepareSession() async {
        do {
            shelfItems = try await shelfStore.load()
        } catch {
            shelfErrorMessage = error.localizedDescription
        }

        clipboard.start()
        systemStatus.start()
        breakReminder.start()
    }

    func endSession() {
        clipboard.stop()
        systemStatus.stop()
        breakReminder.stop()
        quickLook.close()
    }

    func importFiles(_ urls: [URL]) async {
        guard !urls.isEmpty else { return }
        isImportingFiles = true

        do {
            shelfItems += try await shelfStore.importFiles(urls)
            try await shelfStore.save(shelfItems)
        } catch {
            shelfErrorMessage = error.localizedDescription
        }

        isImportingFiles = false
    }

    func removeShelfItem(_ item: ShelfItem) async {
        do {
            try await shelfStore.remove(item)
            shelfItems.removeAll { $0.id == item.id }
            try await shelfStore.save(shelfItems)
        } catch {
            shelfErrorMessage = error.localizedDescription
        }
    }

    func clearShelf() async {
        await shelfStore.clear(shelfItems)
        shelfItems = []
        try? await shelfStore.save([])
    }

    func localURL(for item: ShelfItem) -> URL {
        shelfStore.url(for: item)
    }

    func preview(_ item: ShelfItem) {
        quickLook.preview(
            urls: shelfItems.map(localURL),
            selectedURL: localURL(for: item)
        )
    }
}
