import Foundation

struct RiseRitual: Identifiable, Hashable {
    let id: UUID
    let title: String
    let totalDuration: Int
    let blocks: [RitualBlock]

    init(id: UUID = UUID(), title: String, blocks: [RitualBlock]) {
        self.id = id
        self.title = title
        self.blocks = blocks
        self.totalDuration = blocks.reduce(0) { $0 + $1.duration }
    }
}
