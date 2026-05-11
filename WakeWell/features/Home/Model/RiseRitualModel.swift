import Foundation

struct RiseRitualModel {
    let title: String
    let category: String
    let description: String

    static func defaultRitual() -> RiseRitualModel {
        return RiseRitualModel(
            title: "Rise Ritual",
            category: "MORNING ROUTINE",
            description: "No ritual selected yet. Add activities in My Rituals to build a routine that fits your mornings."
        )
    }
}
