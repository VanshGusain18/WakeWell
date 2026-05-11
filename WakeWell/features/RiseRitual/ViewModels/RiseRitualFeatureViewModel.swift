import Combine
import Foundation

final class RiseRitualFeatureViewModel: ObservableObject {
    @Published var sessionState: RitualSessionState = .selectingMood
    @Published var selectedMood: RiseMood?
    @Published var currentRitual: RiseRitual?
    @Published var currentStepIndex = 0
    @Published var isGenerating = false
    @Published var elapsedSeconds = 0
    @Published var remainingSeconds = 0
    @Published var autoAdvanceEnabled = true
    @Published var energyLevel: Double = 0.55
    @Published var notes = ""
    @Published private(set) var latestCompletion: RitualCompletion?

    private var timer: Timer?
    private var completedBlocksCount = 0
    private var skippedBlocksCount = 0
    private var recentRitualSignatures: [String] = []

    deinit {
        invalidateTimer()
    }

    var currentBlock: RitualBlock? {
        guard let currentRitual,
              currentRitual.blocks.indices.contains(currentStepIndex) else {
            return nil
        }
        return currentRitual.blocks[currentStepIndex]
    }

    var ritualProgress: Double {
        guard let currentRitual, !currentRitual.blocks.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(currentRitual.blocks.count)
    }

    var blockProgress: Double {
        let totalSeconds = max(blockDurationSeconds, 1)
        return Double(elapsedSeconds) / Double(totalSeconds)
    }

    var blockDurationSeconds: Int {
        max((currentBlock?.duration ?? 0) * 60, 0)
    }

    var timerText: String {
        format(seconds: remainingSeconds)
    }

    func beginGeneration(for mood: RiseMood) {
        invalidateTimer()
        selectedMood = mood
        isGenerating = true
        sessionState = .generating

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self, self.selectedMood == mood else { return }
            self.currentRitual = self.generateRitual(for: mood)
            self.currentStepIndex = 0
            self.isGenerating = false
            self.sessionState = .preview
        }
    }

    func generateRitual(for mood: RiseMood) -> RiseRitual {
        var candidate = makeRitual(for: mood)
        var attempts = 0

        while recentRitualSignatures.contains(signature(for: candidate.blocks)) && attempts < 8 {
            candidate = makeRitual(for: mood)
            attempts += 1
        }

        rememberSignature(for: candidate.blocks)
        return candidate
    }

    func shuffleBlock(at index: Int) {
        guard let ritual = currentRitual,
              ritual.blocks.indices.contains(index) else {
            return
        }

        let original = ritual.blocks[index]
        let usedIDs = Set(ritual.blocks.map(\.id))
        let sameCategoryOptions = RitualLibrary.blocks(for: original.category)
            .filter { !usedIDs.contains($0.id) }
            .shuffled()
        let fallbackOptions = RitualLibrary.allBlocks
            .filter { !usedIDs.contains($0.id) }
            .shuffled()

        guard let replacement = sameCategoryOptions.first ?? fallbackOptions.first else { return }

        var blocks = ritual.blocks
        blocks[index] = replacement
        currentRitual = RiseRitual(title: ritual.title, blocks: blocks)
        rememberSignature(for: blocks)
    }

    func shuffleRandomBlock() {
        guard let ritual = currentRitual, !ritual.blocks.isEmpty else { return }
        shuffleBlock(at: Int.random(in: ritual.blocks.indices))
    }

    func regenerateCurrentRitual() {
        guard let selectedMood else { return }
        invalidateTimer()
        currentRitual = generateRitual(for: selectedMood)
        currentStepIndex = 0
        resetTimerForCurrentBlock()
        sessionState = .preview
    }

    func startGuidedSession() {
        guard currentRitual != nil else { return }
        completedBlocksCount = 0
        skippedBlocksCount = 0
        currentStepIndex = 0
        sessionState = .inProgress
        resetTimerForCurrentBlock()
        startTimer()
    }

    func markCurrentStepDone() {
        completedBlocksCount += 1
        advanceToNextStep()
    }

    func skipCurrentStep() {
        skippedBlocksCount += 1
        advanceToNextStep()
    }

    func resetCompletionInput() {
        energyLevel = 0.55
        notes = ""
    }

    func finishCompletion() {
        guard let selectedMood, let currentRitual else {
            sessionState = .selectingMood
            return
        }

        latestCompletion = RitualCompletion(
            selectedMood: selectedMood,
            ritualTitle: currentRitual.title,
            energyLevel: energyLevel,
            morningNote: notes,
            completedBlocksCount: completedBlocksCount,
            skippedBlocksCount: skippedBlocksCount,
            totalDuration: currentRitual.totalDuration
        )
        sessionState = .selectingMood
    }

    func cancelTimer() {
        invalidateTimer()
    }

    private func makeRitual(for mood: RiseMood) -> RiseRitual {
        let categories = weightedCategories(for: mood)
        var usedIDs = Set<UUID>()
        var selectedBlocks: [RitualBlock] = []

        for category in categories {
            guard selectedBlocks.count < 4 else { break }
            guard let block = RitualLibrary.blocks(for: category)
                .filter({ !usedIDs.contains($0.id) })
                .randomElement() else {
                continue
            }
            selectedBlocks.append(block)
            usedIDs.insert(block.id)
        }

        if selectedBlocks.count < 4 {
            let extras = RitualLibrary.allBlocks
                .filter { !usedIDs.contains($0.id) }
                .shuffled()
                .prefix(4 - selectedBlocks.count)
            selectedBlocks.append(contentsOf: extras)
        }

        return RiseRitual(title: "\(mood.title) Rise Ritual", blocks: selectedBlocks)
    }

    private func weightedCategories(for mood: RiseMood) -> [RitualCategory] {
        let priority: [RitualCategory]
        switch mood {
        case .foggy:
            priority = [.hydration, .movement, .activation]
        case .lowEnergy:
            priority = [.movement, .sunlight, .activation]
        case .distracted:
            priority = [.focus, .breathing]
        case .restless:
            priority = [.mindfulness, .breathing]
        case .slowStart:
            priority = [.hydration, .sunlight, .breathing]
        }

        var weighted = priority + priority + RitualCategory.allCases.shuffled()
        var unique: [RitualCategory] = []
        while unique.count < 4, !weighted.isEmpty {
            let category = weighted.remove(at: Int.random(in: weighted.indices))
            if !unique.contains(category) {
                unique.append(category)
            }
        }
        return unique
    }

    private func advanceToNextStep() {
        guard let ritual = currentRitual else { return }

        if currentStepIndex < ritual.blocks.count - 1 {
            currentStepIndex += 1
            resetTimerForCurrentBlock()
            startTimer()
        } else {
            completeGuidedSession()
        }
    }

    private func completeGuidedSession() {
        invalidateTimer()
        resetCompletionInput()
        sessionState = .completed
    }

    private func resetTimerForCurrentBlock() {
        invalidateTimer()
        elapsedSeconds = 0
        remainingSeconds = blockDurationSeconds
    }

    private func startTimer() {
        invalidateTimer()
        guard sessionState == .inProgress, remainingSeconds > 0 else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tickTimer()
        }
    }

    private func tickTimer() {
        guard sessionState == .inProgress else {
            invalidateTimer()
            return
        }

        elapsedSeconds += 1
        remainingSeconds = max(blockDurationSeconds - elapsedSeconds, 0)

        if remainingSeconds == 0 {
            invalidateTimer()
            if autoAdvanceEnabled {
                completedBlocksCount += 1
                advanceToNextStep()
            }
        }
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func signature(for blocks: [RitualBlock]) -> String {
        blocks.map { $0.id.uuidString }.joined(separator: "|")
    }

    private func rememberSignature(for blocks: [RitualBlock]) {
        recentRitualSignatures.append(signature(for: blocks))
        if recentRitualSignatures.count > 6 {
            recentRitualSignatures.removeFirst(recentRitualSignatures.count - 6)
        }
    }

    private func format(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
