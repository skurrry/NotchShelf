import Foundation

nonisolated struct ShelfItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let originalFileName: String
    let relativePath: String
    let byteCount: Int64
    let importedAt: Date

    nonisolated init(
        id: UUID = UUID(),
        originalFileName: String,
        relativePath: String,
        byteCount: Int64,
        importedAt: Date = .now
    ) {
        self.id = id
        self.originalFileName = originalFileName
        self.relativePath = relativePath
        self.byteCount = byteCount
        self.importedAt = importedAt
    }

    nonisolated var displayName: String { originalFileName }
}
