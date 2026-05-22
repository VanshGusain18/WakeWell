import Foundation

struct WatchRiseRitual: Identifiable {
    let id: String
    let title: String
    let category: String
    let minutes: Int?
    let steps: [String]

    var durationText: String {
        guard let minutes else {
            return "Quick"
        }

        return "\(minutes)m"
    }

    var subtitle: String {
        switch id {
        case "sunlight":
            return "Light exposure to cue your body clock."
        case "hydration":
            return "A quick reset before the day starts."
        case "box_breathing":
            return "Calm breathing with a steady rhythm."
        case "short_walk":
            return "Gentle movement to lift alertness."
        default:
            return "A guided SetSail morning ritual."
        }
    }

    var iconName: String {
        switch id {
        case "sunlight":
            return "sun.max.fill"
        case "hydration":
            return "drop.fill"
        case "box_breathing":
            return "wind"
        case "short_walk":
            return "figure.walk"
        default:
            return "sparkles"
        }
    }
}

enum WatchRiseRitualLibrary {
    static let rituals: [WatchRiseRitual] = [
        WatchRiseRitual(
            id: "sunlight",
            title: "Sunlight",
            category: "Energy",
            minutes: 10,
            steps: [
                "Step outside or sit by a bright window.",
                "Keep your gaze soft.",
                "Breathe slowly and let your body wake."
            ]
        ),
        WatchRiseRitual(
            id: "hydration",
            title: "Hydrate",
            category: "Reset",
            minutes: nil,
            steps: [
                "Drink a full glass of water.",
                "Pause for three slow breaths.",
                "Notice your energy before moving on."
            ]
        ),
        WatchRiseRitual(
            id: "box_breathing",
            title: "Box Breathing",
            category: "Calm",
            minutes: 3,
            steps: [
                "Inhale for 4.",
                "Hold for 4.",
                "Exhale for 4.",
                "Hold for 4."
            ]
        ),
        WatchRiseRitual(
            id: "short_walk",
            title: "Short Walk",
            category: "Move",
            minutes: 5,
            steps: [
                "Walk at an easy pace.",
                "Keep your shoulders relaxed.",
                "Look around instead of at your phone."
            ]
        )
    ]
}
