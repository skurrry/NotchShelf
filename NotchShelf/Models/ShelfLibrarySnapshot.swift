import Foundation
struct ShelfLibrarySnapshot: Codable, Sendable {
    var groups: [ShelfGroup]
    var items: [ShelfItem]
    var selectedGroupID: UUID
}
