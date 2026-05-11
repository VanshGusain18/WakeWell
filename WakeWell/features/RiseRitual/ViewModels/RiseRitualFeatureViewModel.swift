import Combine
import Foundation

final class RiseRitualFeatureViewModel: ObservableObject {
    @Published var selectedMood: RiseMood?
    @Published var currentRitual: RiseRitual?
    @Published var currentStepIndex = 0
    @Published var isGenerating = false
    @Published var energyLevel: Double = 0.55
    @Published var notes = ""

    private var generationOffset = 0

    var currentBlock: RitualBlock? {
        guard let currentRitual,
              currentRitual.blocks.indices.contains(currentStepIndex) else {
            return nil
        }
        return currentRitual.blocks[currentStepIndex]
    }

    var progress: Double {
        guard let currentRitual, !currentRitual.blocks.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(currentRitual.blocks.count)
    }

    func beginGeneration(for mood: RiseMood, completion: @escaping () -> Void) {
        selectedMood = mood
        isGenerating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.currentRitual = self.makeRitual(for: mood)
            self.currentStepIndex = 0
            self.isGenerating = false
            completion()
        }
    }

    func shuffleOneBlock() {
        guard let ritual = currentRitual, !ritual.blocks.isEmpty else { return }
        let index = generationOffset % ritual.blocks.count
        let original = ritual.blocks[index]
        let usedIDs = Set(ritual.blocks.map(\.id))
        let options = Self.localBlocks.filter {
            $0.category == original.category && !usedIDs.contains($0.id)
        }

        guard let replacement = options[safe: generationOffset % max(options.count, 1)] else { return }
        var blocks = ritual.blocks
        blocks[index] = replacement
        generationOffset += 1
        currentRitual = RiseRitual(title: ritual.title, blocks: blocks)
    }

    func shuffleAll() {
        guard let selectedMood else { return }
        generationOffset += 1
        currentRitual = makeRitual(for: selectedMood)
        currentStepIndex = 0
    }

    func markCurrentStepDone() -> Bool {
        guard let ritual = currentRitual else { return false }
        if currentStepIndex < ritual.blocks.count - 1 {
            currentStepIndex += 1
            return false
        }
        return true
    }

    func skipCurrentStep() -> Bool {
        markCurrentStepDone()
    }

    func resetCompletionInput() {
        energyLevel = 0.55
        notes = ""
    }

    private func makeRitual(for mood: RiseMood) -> RiseRitual {
        var usedIDs = Set<UUID>()
        let blocks = categoryPlan(for: mood).compactMap { category -> RitualBlock? in
            guard let block = block(for: category, avoiding: usedIDs) else { return nil }
            usedIDs.insert(block.id)
            return block
        }

        return RiseRitual(title: "\(mood.title) Rise Ritual", blocks: blocks)
    }

    private func categoryPlan(for mood: RiseMood) -> [RitualCategory] {
        switch mood {
        case .foggy:
            return [.hydration, .movement, .breathing, .sunlight]
        case .lowEnergy:
            return [.movement, .hydration, .focus, .sunlight]
        case .distracted:
            return [.breathing, .focus, .mindfulness, .movement]
        case .restless:
            return [.breathing, .mindfulness, .movement, .focus]
        case .slowStart:
            return [.hydration, .breathing, .movement, .sunlight]
        }
    }

    private func block(for category: RitualCategory, avoiding usedIDs: Set<UUID>) -> RitualBlock? {
        let blocks = Self.localBlocks.filter { $0.category == category && !usedIDs.contains($0.id) }
        guard !blocks.isEmpty else { return nil }
        let index = (generationOffset + category.rawValue.count) % blocks.count
        return blocks[index]
    }
}

private extension RiseRitualFeatureViewModel {
    static let localBlocks: [RitualBlock] = [
        RitualBlock(title: "Hydrate", subtitle: "A full glass before momentum.", duration: 1, category: .hydration, sfSymbol: "drop.fill", instructions: "Drink a full glass of water slowly. Pause halfway and relax your shoulders."),
        RitualBlock(title: "Mineral Sip", subtitle: "Wake with a steady sip.", duration: 1, category: .hydration, sfSymbol: "waterbottle.fill", instructions: "Take several slow sips of water. Refill the glass before moving on."),
        RitualBlock(title: "Cool Water Reset", subtitle: "Freshen your senses.", duration: 1, category: .hydration, sfSymbol: "drop.degreesign.fill", instructions: "Splash cool water on your face or rinse your hands, then take three calm breaths."),
        RitualBlock(title: "Box Breathing", subtitle: "Four-count calm.", duration: 1, category: .breathing, sfSymbol: "wind", instructions: "Inhale for 4, hold for 4, exhale for 4, hold for 4. Repeat three rounds."),
        RitualBlock(title: "Long Exhale", subtitle: "Downshift gently.", duration: 1, category: .breathing, sfSymbol: "lungs.fill", instructions: "Inhale for 3 counts and exhale for 6 counts. Let your jaw soften each time."),
        RitualBlock(title: "Three Deep Breaths", subtitle: "Reset in place.", duration: 1, category: .breathing, sfSymbol: "sparkles", instructions: "Take three slow breaths. Relax your hands, shoulders, and face."),
        RitualBlock(title: "Easy Walk", subtitle: "Move without strain.", duration: 2, category: .movement, sfSymbol: "figure.walk", instructions: "Walk at a relaxed pace. Keep your gaze up and let your arms swing naturally."),
        RitualBlock(title: "Standing Stretch", subtitle: "Lengthen the body.", duration: 1, category: .movement, sfSymbol: "figure.cooldown", instructions: "Fold forward with soft knees, then slowly roll back up."),
        RitualBlock(title: "Step Jacks", subtitle: "Quick circulation boost.", duration: 1, category: .movement, sfSymbol: "figure.jumprope", instructions: "Do low-impact step jacks for one minute. Keep the movement light."),
        RitualBlock(title: "Shoulder Rolls", subtitle: "Release sleep stiffness.", duration: 1, category: .movement, sfSymbol: "figure.strengthtraining.functional", instructions: "Roll your shoulders forward and back, then reach overhead and breathe."),
        RitualBlock(title: "Sunlight Reset", subtitle: "Bright light cue.", duration: 1, category: .sunlight, sfSymbol: "sun.max.fill", instructions: "Stand by a bright window or step outside. Keep your gaze soft."),
        RitualBlock(title: "Window Pause", subtitle: "Quiet morning light.", duration: 1, category: .sunlight, sfSymbol: "sunrise.fill", instructions: "Face a bright window for one minute and breathe naturally."),
        RitualBlock(title: "Fresh Air", subtitle: "Light and air together.", duration: 1, category: .sunlight, sfSymbol: "cloud.sun.fill", instructions: "Open a window or step outside. Notice the air temperature and light."),
        RitualBlock(title: "Five Senses", subtitle: "Ground attention.", duration: 1, category: .mindfulness, sfSymbol: "eye.fill", instructions: "Notice one thing you see, feel, hear, smell, and taste."),
        RitualBlock(title: "Gratitude Spark", subtitle: "Start with one good thing.", duration: 1, category: .mindfulness, sfSymbol: "heart.fill", instructions: "Name one thing you appreciate and one thing you are ready to begin."),
        RitualBlock(title: "Body Scan", subtitle: "Arrive in your body.", duration: 1, category: .mindfulness, sfSymbol: "person.fill.checkmark", instructions: "Scan from forehead to feet. Relax one tense spot before continuing."),
        RitualBlock(title: "First Target", subtitle: "Pick one useful task.", duration: 1, category: .focus, sfSymbol: "target", instructions: "Name one small task that would make the morning feel successful."),
        RitualBlock(title: "Phone Boundary", subtitle: "Protect first focus.", duration: 1, category: .focus, sfSymbol: "iphone.slash", instructions: "Keep your phone away or open only the tool needed for your first task."),
        RitualBlock(title: "Clear Surface", subtitle: "Reduce visual noise.", duration: 1, category: .focus, sfSymbol: "rectangle.and.hand.point.up.left.fill", instructions: "Clear one small surface. Remove only what blocks your first action.")
    ]
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
