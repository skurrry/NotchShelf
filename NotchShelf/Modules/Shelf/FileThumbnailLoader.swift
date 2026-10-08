@preconcurrency import AppKit
import Foundation
@preconcurrency import QuickLookThumbnailing

@MainActor
final class FileThumbnailLoader {
    static let shared = FileThumbnailLoader()

    private let cache = NSCache<NSString, NSImage>()
    private var runningTasks: [String: Task<NSImage?, Never>] = [:]

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 96 * 1_024 * 1_024
    }

    func thumbnail(
        for url: URL,
        size: CGSize,
        scale: CGFloat
    ) async -> NSImage? {
        let key = cacheKey(
            url: url,
            size: size,
            scale: scale
        )

        if let cached = cache.object(forKey: key as NSString) {
            return cached
        }

        if let runningTask = runningTasks[key] {
            return await runningTask.value
        }

        let task = Task<NSImage?, Never> {
            await Self.generateThumbnail(
                for: url,
                size: size,
                scale: scale
            )
        }

        runningTasks[key] = task
        let image = await task.value
        runningTasks[key] = nil

        if let image {
            let pixelWidth = Int(size.width * scale)
            let pixelHeight = Int(size.height * scale)
            let estimatedCost = max(
                1,
                pixelWidth * pixelHeight * 4
            )

            cache.setObject(
                image,
                forKey: key as NSString,
                cost: estimatedCost
            )
        }

        return image
    }

    func invalidate(for url: URL) {
        let prefix = url.standardizedFileURL.path + "|"

        for key in runningTasks.keys where key.hasPrefix(prefix) {
            runningTasks[key]?.cancel()
            runningTasks[key] = nil
        }

        // NSCache kann nicht nach Präfix iteriert werden. Der Cache ist
        // absichtlich klein und wird bei Dateiänderungen vollständig geleert.
        cache.removeAllObjects()
    }

    func removeAll() {
        for task in runningTasks.values {
            task.cancel()
        }
        runningTasks.removeAll()
        cache.removeAllObjects()
    }

    private func cacheKey(
        url: URL,
        size: CGSize,
        scale: CGFloat
    ) -> String {
        let modificationDate = try? url.resourceValues(
            forKeys: [.contentModificationDateKey]
        ).contentModificationDate

        return [
            url.standardizedFileURL.path,
            String(Int(size.width)),
            String(Int(size.height)),
            String(format: "%.2f", scale),
            modificationDate.map {
                String($0.timeIntervalSince1970)
            } ?? "0"
        ]
        .joined(separator: "|")
    }

    private static func generateThumbnail(
        for url: URL,
        size: CGSize,
        scale: CGFloat
    ) async -> NSImage? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .all
        )
        request.iconMode = false

        return await withCheckedContinuation { continuation in
            QLThumbnailGenerator.shared.generateBestRepresentation(
                for: request
            ) { representation, _ in
                continuation.resume(
                    returning: representation?.nsImage
                )
            }
        }
    }
}
