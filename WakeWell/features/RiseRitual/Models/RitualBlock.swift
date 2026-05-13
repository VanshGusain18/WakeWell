import Foundation

struct RitualBlock: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let duration: Int
    let sfSymbol: String
    let category: String

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        duration: Int,
        sfSymbol: String,
        category: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.sfSymbol = sfSymbol
        self.category = category
    }
}
