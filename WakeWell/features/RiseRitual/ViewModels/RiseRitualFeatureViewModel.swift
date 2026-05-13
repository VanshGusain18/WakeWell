import Combine
import Foundation

final class RiseRitualFeatureViewModel: ObservableObject {
    enum Mood: String, CaseIterable, Identifiable {
        case foggy
        case lowEnergy
        case distracted
        case restless
        case slowStart

        var id: String { rawValue }

        var title: String {
            switch self {
            case .foggy: return "Foggy"
            case .lowEnergy: return "Low Energy"
            case .distracted: return "Distracted"
            case .restless: return "Restless"
            case .slowStart: return "Slow Start"
            }
        }

        var subtitle: String {
            switch self {
            case .foggy: return "Clear the haze with light activation."
            case .lowEnergy: return "Build energy with movement and sunlight."
            case .distracted: return "Reset attention with a simple focus ritual."
            case .restless: return "Calm the body before starting the day."
            case .slowStart: return "Ease into the morning without force."
            }
        }

        var symbol: String {
            switch self {
            case .foggy: return "cloud.fog.fill"
            case .lowEnergy: return "bolt.heart.fill"
            case .distracted: return "brain.head.profile"
            case .restless: return "wind"
            case .slowStart: return "sunrise.fill"
            }
        }
    }

    enum Screen {
        case mood
        case carousel
        case guided
        case completion
    }

    @Published var screen: Screen = .mood
    @Published var selectedMood: Mood?
    @Published var currentRitual: RiseRitual?
    @Published var currentCardIndex = 0
    @Published var remainingSeconds = 0
    @Published var elapsedSeconds = 0
    @Published var energyLevel = 0.6
    @Published var notes = ""

    private var timer: Timer?
    private var generationSeed = 0

    deinit {
        stopTimer()
    }

    var currentBlock: RitualBlock? {
        guard let currentRitual,
              currentRitual.blocks.indices.contains(currentCardIndex) else {
            return nil
        }
        return currentRitual.blocks[currentCardIndex]
    }

    var progress: Double {
        guard let currentRitual, !currentRitual.blocks.isEmpty else { return 0 }
        return Double(currentCardIndex + 1) / Double(currentRitual.blocks.count)
    }

    var timerText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func selectMood(_ mood: Mood) {
        stopTimer()
        selectedMood = mood
        currentRitual = generateRitual(for: mood)
        currentCardIndex = 0
        screen = .carousel
    }

    func shuffleCurrentCard() {
        guard let ritual = currentRitual,
              let mood = selectedMood,
              ritual.blocks.indices.contains(currentCardIndex) else {
            return
        }

        var blocks = ritual.blocks
        let current = blocks[currentCardIndex]
        let replacement = replacementBlock(for: current, mood: mood, excluding: Set(blocks.map(\.title)))
        blocks[currentCardIndex] = replacement
        currentRitual = RiseRitual(title: ritual.title, mood: ritual.mood, blocks: blocks)
    }

    func shuffleAllCards() {
        guard let selectedMood else { return }
        currentRitual = generateRitual(for: selectedMood)
        currentCardIndex = 0
    }

    func startRitualFlow() {
        guard currentRitual != nil else { return }
        currentCardIndex = 0
        screen = .guided
        startTimerForCurrentBlock()
    }

    func completeCurrentBlock() {
        advanceGuidedFlow()
    }

    func skipCurrentBlock() {
        advanceGuidedFlow()
    }

    func backToMoodSelection() {
        stopTimer()
        selectedMood = nil
        currentRitual = nil
        currentCardIndex = 0
        screen = .mood
    }

    func backToCarousel() {
        stopTimer()
        currentCardIndex = 0
        screen = currentRitual == nil ? .mood : .carousel
    }

    func finishCompletion() {
        stopTimer()
        selectedMood = nil
        currentRitual = nil
        currentCardIndex = 0
        remainingSeconds = 0
        elapsedSeconds = 0
        energyLevel = 0.6
        notes = ""
        screen = .mood
    }

    private func generateRitual(for mood: Mood) -> RiseRitual {
        generationSeed += 1
        let plan = categoryPlan(for: mood)
        var usedCategories = Set<String>()
        var usedTitles = Set<String>()

        let blocks = plan.compactMap { category -> RitualBlock? in
            guard !usedCategories.contains(category) else { return nil }
            let block = block(for: category, mood: mood, excluding: usedTitles)
            usedCategories.insert(block.category)
            usedTitles.insert(block.title)
            return block
        }

        return RiseRitual(
            title: ritualTitle(for: mood),
            mood: mood.title,
            blocks: Array(blocks.prefix(5))
        )
    }

    private func categoryPlan(for mood: Mood) -> [String] {
        switch mood {
        case .foggy:
            return ["hydration", "sunlight", "breathing", "activation"]
        case .lowEnergy:
            return ["movement", "posture", "breathing", "hydration"]
        case .distracted:
            return ["focus", "breathing", "hydration", "intention"]
        case .restless:
            return ["breathing", "movement", "grounding", "mindfulness"]
        case .slowStart:
            return ["movement", "sunlight", "hydration", "activation"]
        }
    }

    private func ritualTitle(for mood: Mood) -> String {
        switch mood {
        case .foggy: return "Clear Morning"
        case .lowEnergy: return "Wake Pulse"
        case .distracted: return "Focused Reset"
        case .restless: return "Calm Start"
        case .slowStart: return "Soft Launch"
        }
    }

    private func block(for category: String, mood: Mood, excluding usedTitles: Set<String>) -> RitualBlock {
        let options = Self.library[category, default: []]
            .filter { !usedTitles.contains($0.title) }
        guard !options.isEmpty else {
            return Self.library.values.flatMap { $0 }.first { !usedTitles.contains($0.title) } ?? Self.fallbackBlock
        }
        let index = abs((generationSeed + mood.rawValue.count + category.count) % options.count)
        return options[index]
    }

    private func replacementBlock(for block: RitualBlock, mood: Mood, excluding usedTitles: Set<String>) -> RitualBlock {
        let options = Self.library[block.category, default: []]
            .filter { !usedTitles.contains($0.title) }
        guard !options.isEmpty else {
            return self.block(for: block.category, mood: mood, excluding: usedTitles.subtracting([block.title]))
        }
        generationSeed += 1
        return options[abs(generationSeed % options.count)]
    }

    private func startTimerForCurrentBlock() {
        stopTimer()
        remainingSeconds = max((currentBlock?.duration ?? 1) * 60, 1)
        elapsedSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard screen == .guided else {
            stopTimer()
            return
        }
        elapsedSeconds += 1
        remainingSeconds = max(remainingSeconds - 1, 0)
        if remainingSeconds == 0 {
            advanceGuidedFlow()
        }
    }

    private func advanceGuidedFlow() {
        guard let ritual = currentRitual else { return }
        if currentCardIndex < ritual.blocks.count - 1 {
            currentCardIndex += 1
            startTimerForCurrentBlock()
        } else {
            stopTimer()
            screen = .completion
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

private extension RiseRitualFeatureViewModel {
    static let fallbackBlock = RitualBlock(
        title: "Breathe",
        subtitle: "A simple reset.",
        duration: 1,
        sfSymbol: "wind",
        category: "breathing"
    )

    static let library: [String: [RitualBlock]] = [
        "hydration": [
            RitualBlock(title: "Mineral Sip", subtitle: "Wake with a steady sip.", duration: 1, sfSymbol: "waterbottle.fill", category: "hydration"),
            RitualBlock(title: "Hydrate", subtitle: "A full glass before momentum.", duration: 1, sfSymbol: "drop.fill", category: "hydration"),
            RitualBlock(title: "Cold Splash", subtitle: "Freshen the senses.", duration: 1, sfSymbol: "drop.degreesign.fill", category: "hydration")
        ],
        "sunlight": [
            RitualBlock(title: "Fresh Air", subtitle: "Open a window or step outside.", duration: 1, sfSymbol: "cloud.sun.fill", category: "sunlight"),
            RitualBlock(title: "Sunlight Reset", subtitle: "Let bright light cue your body.", duration: 1, sfSymbol: "sun.max.fill", category: "sunlight"),
            RitualBlock(title: "Window Pause", subtitle: "Face morning light softly.", duration: 1, sfSymbol: "sunrise.fill", category: "sunlight")
        ],
        "breathing": [
            RitualBlock(title: "Deep Breathing", subtitle: "Slow inhales, longer exhales.", duration: 1, sfSymbol: "lungs.fill", category: "breathing"),
            RitualBlock(title: "Box Breathing", subtitle: "Four counts in each direction.", duration: 1, sfSymbol: "wind", category: "breathing"),
            RitualBlock(title: "Fast Breathing", subtitle: "Twenty controlled bright breaths.", duration: 1, sfSymbol: "lungs", category: "breathing")
        ],
        "activation": [
            RitualBlock(title: "Fast Activation", subtitle: "20 seconds of movement.", duration: 1, sfSymbol: "bolt.fill", category: "activation"),
            RitualBlock(title: "Arm Swings", subtitle: "Simple rhythmic motion.", duration: 1, sfSymbol: "figure.arms.open", category: "activation"),
            RitualBlock(title: "Wake Pulse", subtitle: "March in place with energy.", duration: 1, sfSymbol: "figure.run", category: "activation")
        ],
        "movement": [
            RitualBlock(title: "Mini Squats", subtitle: "Warm the legs gently.", duration: 1, sfSymbol: "figure.cross.training", category: "movement"),
            RitualBlock(title: "Neck Stretch", subtitle: "Release sleep stiffness.", duration: 1, sfSymbol: "figure.cooldown", category: "movement"),
            RitualBlock(title: "Easy Walk", subtitle: "Move without strain.", duration: 2, sfSymbol: "figure.walk", category: "movement")
        ],
        "posture": [
            RitualBlock(title: "Power Posture", subtitle: "Stand tall and breathe.", duration: 1, sfSymbol: "figure.stand", category: "posture"),
            RitualBlock(title: "Shoulder Reset", subtitle: "Open the chest and ribs.", duration: 1, sfSymbol: "figure.strengthtraining.functional", category: "posture")
        ],
        "focus": [
            RitualBlock(title: "Focus Prompt", subtitle: "Name the first useful action.", duration: 1, sfSymbol: "target", category: "focus"),
            RitualBlock(title: "Clear Surface", subtitle: "Reduce visual noise.", duration: 1, sfSymbol: "rectangle.and.hand.point.up.left.fill", category: "focus")
        ],
        "intention": [
            RitualBlock(title: "Intention Reset", subtitle: "Choose how to begin.", duration: 1, sfSymbol: "sparkles", category: "intention"),
            RitualBlock(title: "Top Three", subtitle: "Pick three simple priorities.", duration: 1, sfSymbol: "checklist", category: "intention")
        ],
        "grounding": [
            RitualBlock(title: "Grounding", subtitle: "Feel your feet and slow down.", duration: 1, sfSymbol: "leaf.fill", category: "grounding"),
            RitualBlock(title: "Five Senses", subtitle: "Name what is here now.", duration: 1, sfSymbol: "eye.fill", category: "grounding")
        ],
        "mindfulness": [
            RitualBlock(title: "Calm Check-In", subtitle: "Notice one good thing.", duration: 1, sfSymbol: "heart.fill", category: "mindfulness"),
            RitualBlock(title: "Body Scan", subtitle: "Relax one tense spot.", duration: 1, sfSymbol: "person.fill.checkmark", category: "mindfulness")
        ]
    ]
}
