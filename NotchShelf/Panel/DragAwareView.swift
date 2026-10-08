import AppKit
import UniformTypeIdentifiers

final class DragAwareView: NSView {

    // MARK: - Mouse

    var onMouseEntered: (() -> Void)?
    var onMouseExited: (() -> Void)?

    // MARK: - Drag

    var onFileDragEntered: (([URL]) -> Void)?
    var onFileDragUpdated: (([URL]) -> Void)?
    var onFileDragExited: (() -> Void)?
    var onFileDrop: (([URL]) -> Bool)?

    private var currentTrackingArea: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        registerForDraggedTypes([
            .fileURL
        ])
    }

    required init?(
        coder: NSCoder
    ) {
        super.init(coder: coder)

        registerForDraggedTypes([
            .fileURL
        ])
    }

    // MARK: - Mouse tracking

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let currentTrackingArea {
            removeTrackingArea(
                currentTrackingArea
            )
        }

        let newTrackingArea = NSTrackingArea(
            rect: bounds,
            options: [
                .mouseEnteredAndExited,
                .activeAlways,
                .inVisibleRect
            ],
            owner: self,
            userInfo: nil
        )

        addTrackingArea(
            newTrackingArea
        )

        currentTrackingArea =
            newTrackingArea
    }

    override func mouseEntered(
        with event: NSEvent
    ) {
        onMouseEntered?()
    }

    override func mouseExited(
        with event: NSEvent
    ) {
        onMouseExited?()
    }

    // MARK: - Drag destination

    override func draggingEntered(
        _ sender: NSDraggingInfo
    ) -> NSDragOperation {
        let urls = fileURLs(
            from: sender.draggingPasteboard
        )

        guard !urls.isEmpty else {
            return []
        }

        onFileDragEntered?(urls)

        return .copy
    }

    override func draggingUpdated(
        _ sender: NSDraggingInfo
    ) -> NSDragOperation {
        let urls = fileURLs(
            from: sender.draggingPasteboard
        )

        guard !urls.isEmpty else {
            return []
        }

        onFileDragUpdated?(urls)

        return .copy
    }

    override func draggingExited(
        _ sender: NSDraggingInfo?
    ) {
        onFileDragExited?()
    }

    override func prepareForDragOperation(
        _ sender: NSDraggingInfo
    ) -> Bool {
        !fileURLs(
            from: sender.draggingPasteboard
        ).isEmpty
    }

    override func performDragOperation(
        _ sender: NSDraggingInfo
    ) -> Bool {
        let urls = fileURLs(
            from: sender.draggingPasteboard
        )

        guard !urls.isEmpty else {
            return false
        }

        return onFileDrop?(urls) ?? false
    }

    override func concludeDragOperation(
        _ sender: NSDraggingInfo?
    ) {
        needsDisplay = true
    }

    // MARK: - Pasteboard

    private func fileURLs(
        from pasteboard: NSPasteboard
    ) -> [URL] {
        let options: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
        ]

        let objects = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: options
        ) ?? []

        return objects.compactMap {
            object in

            guard let url = object as? URL else {
                return nil
            }

            return url.isFileURL
                ? url
                : nil
        }
    }
}
