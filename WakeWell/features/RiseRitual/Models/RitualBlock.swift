import Foundation

enum RitualInteractionType: String, Equatable {
    case instruction
    case tapCounter
    case breathingPacer
    case focusPrompt
    case mentalActivation
    case bodyActivation
    case grounding
}

struct RitualBlock: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let duration: Int
    let sfSymbol: String
    let category: String
    let moodTags: [String]
    let detailedInstructions: [String]
    let interactionType: RitualInteractionType
    let interactionTarget: Int
    let interactionPrompts: [String]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        duration: Int,
        sfSymbol: String,
        category: String,
        moodTags: [String] = [],
        detailedInstructions: [String] = [],
        interactionType: RitualInteractionType = .instruction,
        interactionTarget: Int = 0,
        interactionPrompts: [String] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.sfSymbol = sfSymbol
        self.category = category
        self.moodTags = moodTags
        self.detailedInstructions = detailedInstructions.isEmpty
            ? [
                subtitle,
                "Move slowly enough that it feels easy to finish.",
                "Press Done when you feel complete."
            ]
            : detailedInstructions
        self.interactionType = interactionType
        self.interactionTarget = interactionTarget
        self.interactionPrompts = interactionPrompts
    }
}
