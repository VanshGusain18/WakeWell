import Foundation

struct RiseRitualModel {
    let title: String
    let category: String
    let description: String

    static func defaultRitual() -> RiseRitualModel {
        return RiseRitualModel(
            title: "Rise Ritual",
            category: "MORNING ROUTINE",
            description: "Awaken your mind with a guided 5-minute movement and mindfulness flow."
        )
    }
}
