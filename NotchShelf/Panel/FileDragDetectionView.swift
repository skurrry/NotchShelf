import AppKit

final class FileDragDetectionView: NSView {
    var onFileDragEntered: (([URL]) -> Void)?
    var onFileDragUpdated: (([URL]) -> Void)?
    var onFileDragExited: (() -> Void)?
    var onFileDrop: (([URL]) -> Bool)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let urls = fileURLs(from: sender.draggingPasteboard)
        guard !urls.isEmpty else { return [] }
        onFileDragEntered?(urls)
        return .copy
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        let urls = fileURLs(from: sender.draggingPasteboard)
        guard !urls.isEmpty else { return [] }
        onFileDragUpdated?(urls)
        return .copy
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        onFileDragExited?()
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        !fileURLs(from: sender.draggingPasteboard).isEmpty
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = fileURLs(from: sender.draggingPasteboard)
        guard !urls.isEmpty else { return false }
        return onFileDrop?(urls) ?? false
    }

    private func fileURLs(from pasteboard: NSPasteboard) -> [URL] {
        let options: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
        ]

        let objects = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: options
        ) ?? []

        return objects.compactMap { object in
            guard let url = object as? URL, url.isFileURL else { return nil }
            return url
        }
    }
}
