import Foundation

actor ShelfStore {
    private let fileManager = FileManager.default
    private let rootURL = URL.applicationSupportDirectory
        .appendingPathComponent("NotchShelf", isDirectory: true)
        .appendingPathComponent("Cabinet", isDirectory: true)

    private var filesURL: URL {
        rootURL.appendingPathComponent("Files", isDirectory: true)
    }

    private var indexURL: URL {
        rootURL.appendingPathComponent("files.json")
    }

    func load() throws -> [ShelfItem] {
        try prepareDirectories()

        guard fileManager.fileExists(atPath: indexURL.path) else {
            try save([])
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var items = try decoder.decode(
            [ShelfItem].self,
            from: Data(contentsOf: indexURL)
        )

        items.removeAll {
            !fileManager.fileExists(atPath: url(for: $0).path)
        }

        try save(items)
        return items
    }

    func save(_ items: [ShelfItem]) throws {
        try prepareDirectories()

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        try encoder
            .encode(items)
            .write(to: indexURL, options: .atomic)
    }

    func importFiles(_ sources: [URL]) throws -> [ShelfItem] {
        try prepareDirectories()

        return try sources.map { source in
            let id = UUID()
            let itemDirectory = filesURL
                .appendingPathComponent(id.uuidString, isDirectory: true)

            try fileManager.createDirectory(
                at: itemDirectory,
                withIntermediateDirectories: true
            )

            let destination = itemDirectory
                .appendingPathComponent(source.lastPathComponent)

            let access = source.startAccessingSecurityScopedResource()
            defer {
                if access {
                    source.stopAccessingSecurityScopedResource()
                }
            }

            try fileManager.copyItem(at: source, to: destination)

            let values = try destination.resourceValues(
                forKeys: [.fileSizeKey, .totalFileAllocatedSizeKey]
            )

            let relativePath = destination.path
                .replacingOccurrences(of: rootURL.path + "/", with: "")

            return ShelfItem(
                id: id,
                originalFileName: source.lastPathComponent,
                relativePath: relativePath,
                byteCount: Int64(
                    values.totalFileAllocatedSize
                        ?? values.fileSize
                        ?? 0
                )
            )
        }
    }

    func remove(_ item: ShelfItem) throws {
        let itemDirectory = url(for: item).deletingLastPathComponent()

        if fileManager.fileExists(atPath: itemDirectory.path) {
            try fileManager.removeItem(at: itemDirectory)
        }
    }

    func clear(_ items: [ShelfItem]) {
        for item in items {
            try? remove(item)
        }
    }

    nonisolated func url(for item: ShelfItem) -> URL {
        rootURL.appendingPathComponent(item.relativePath)
    }

    private func prepareDirectories() throws {
        try fileManager.createDirectory(
            at: filesURL,
            withIntermediateDirectories: true
        )
    }
}
