import Foundation

struct RiseRitual: Identifiable, Equatable {
    let id: UUID
    let title: String
    let mood: String
    let blocks: [RitualBlock]

    var totalDuration: Int {
        blocks.reduce(0) { $0 + $1.duration }
    }

    init(
        id: UUID = UUID(),
        title: String,
        mood: String,
        blocks: [RitualBlock]
    ) {
        self.id = id
        self.title = title
        self.mood = mood
        self.blocks = blocks
    }
}
