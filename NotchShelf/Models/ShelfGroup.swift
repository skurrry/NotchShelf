import Foundation

struct ShelfGroup: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    let createdAt: Date
    nonisolated init(id: UUID = UUID(), name: String, createdAt: Date = .now) {
        self.id = id; self.name = name; self.createdAt = createdAt
    }
}
