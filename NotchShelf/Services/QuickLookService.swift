import AppKit
import QuickLookUI

@MainActor
final class QuickLookService: NSObject, QLPreviewPanelDataSource {
    private var urls: [URL] = []

    func preview(urls: [URL], selectedURL: URL) {
        guard !urls.isEmpty else { return }
        self.urls = urls

        guard let panel = QLPreviewPanel.shared() else { return }
        panel.dataSource = self
        panel.currentPreviewItemIndex = urls.firstIndex(of: selectedURL) ?? 0
        panel.reloadData()
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        if QLPreviewPanel.sharedPreviewPanelExists() {
            QLPreviewPanel.shared()?.orderOut(nil)
        }
        urls = []
    }

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        urls.count
    }

    func previewPanel(
        _ panel: QLPreviewPanel!,
        previewItemAt index: Int
    ) -> (any QLPreviewItem)! {
        urls[index] as NSURL
    }
}
