import Foundation

struct RitualBlock: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let duration: Int
    let category: RitualCategory
    let sfSymbol: String
    let instructions: String

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        duration: Int,
        category: RitualCategory,
        sfSymbol: String,
        instructions: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.category = category
        self.sfSymbol = sfSymbol
        self.instructions = instructions
    }
}
