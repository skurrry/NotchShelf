import AppKit
import Observation

struct ClipboardTextItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let copiedAt: Date
}

@MainActor
@Observable
final class ClipboardModule: NSObject {
    private(set) var items: [ClipboardTextItem] = []
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount

    func start() {
        guard timer == nil else { return }

        let timer = Timer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(checkPasteboard),
            userInfo: nil,
            repeats: true
        )
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        items = []
    }

    func copyAgain(_ item: ClipboardTextItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.text, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }

    func clear() {
        items = []
    }

    @objc private func checkPasteboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard
            let text = pasteboard.string(forType: .string)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty,
            text.count <= 20_000,
            items.first?.text != text
        else {
            return
        }

        items.insert(
            ClipboardTextItem(text: text, copiedAt: .now),
            at: 0
        )

        if items.count > 20 {
            items.removeLast(items.count - 20)
        }
    }
}
