import Foundation

final class HomeDataProvider {

    static let shared = HomeDataProvider()

    private init() {}

    // MARK: - Alarm
    func getAlarm() -> AlarmModel {
        return AlarmModel(
            time: Date().addingTimeInterval(3600 * 8)
        )
    }

    // MARK: - Sleep Ring
    func getSleepRing() -> SleepRingModel {
        return SleepRingModel(
            score: 82,
            subtitle: "Good sleep"
        )
    }

    // MARK: - Metrics
    func getMetrics() -> SleepMetricsModel {
        return SleepMetricsModel(
            sleepScore: 78,
            metrics: [
                SleepMetricItem(title: "Duration", score: 16, maxScore: 20, trendPercent: 5),
                SleepMetricItem(title: "Efficiency", score: 12, maxScore: 15, trendPercent: 3),
                SleepMetricItem(title: "Architecture", score: 18, maxScore: 25, trendPercent: -2),
                SleepMetricItem(title: "Continuity", score: 13, maxScore: 15, trendPercent: 1),
                SleepMetricItem(title: "Calmness", score: 11, maxScore: 15, trendPercent: -4),
                SleepMetricItem(title: "Consistency", score: 8, maxScore: 10, trendPercent: 2)
            ]
        )
    }

    // MARK: - Groggy
    func getGroggy() -> GroggyModel {
        return GroggyModel(value: 5)
    }

    // MARK: - Notes
    func getNote() -> MorningNoteModel {
        return MorningNoteModel(
            text: "",
            date: Date()
        )
    }

    // MARK: - Sounds
    func getSound() -> SleepSoundModel {
        return SleepSoundModel(
            title: "Sleep Sounds"
        )
    }
}
