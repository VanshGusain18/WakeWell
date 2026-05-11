import Foundation

struct RitualCompletion: Identifiable, Hashable {
    let id: UUID
    let selectedMood: RiseMood
    let ritualTitle: String
    let completionDate: Date
    let energyLevel: Double
    let morningNote: String
    let completedBlocksCount: Int
    let skippedBlocksCount: Int
    let totalDuration: Int

    init(
        id: UUID = UUID(),
        selectedMood: RiseMood,
        ritualTitle: String,
        completionDate: Date = Date(),
        energyLevel: Double,
        morningNote: String,
        completedBlocksCount: Int,
        skippedBlocksCount: Int,
        totalDuration: Int
    ) {
        self.id = id
        self.selectedMood = selectedMood
        self.ritualTitle = ritualTitle
        self.completionDate = completionDate
        self.energyLevel = energyLevel
        self.morningNote = morningNote
        self.completedBlocksCount = completedBlocksCount
        self.skippedBlocksCount = skippedBlocksCount
        self.totalDuration = totalDuration
    }
}
