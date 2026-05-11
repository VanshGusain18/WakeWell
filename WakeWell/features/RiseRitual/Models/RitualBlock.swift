import SwiftUI

struct RitualBlock: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let duration: Int
    let category: RitualCategory
    let sfSymbol: String
    let instructions: String
    let gradientColors: [Color]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        duration: Int,
        category: RitualCategory,
        sfSymbol: String,
        instructions: String,
        gradientColors: [Color]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.category = category
        self.sfSymbol = sfSymbol
        self.instructions = instructions
        self.gradientColors = gradientColors
    }
}

extension RitualBlock: Equatable {
    static func == (lhs: RitualBlock, rhs: RitualBlock) -> Bool {
        lhs.id == rhs.id
    }
}

extension RitualBlock: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
