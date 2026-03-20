import Foundation

final class HomeDataProvider {

    static let shared = HomeDataProvider()

    private init() {}

    func getAlarm() -> AlarmModel {
        return AlarmModel(
            time: Date().addingTimeInterval(3600 * 8)
        )
    }

    func getSleepRing() -> SleepRingModel {
        return SleepRingModel(
            score: 82,
            subtitle: "Good Sleep"
        )
    }

    func getMetrics() -> SleepMetricsModel {
        return SleepMetricsModel(
            sleepScore: 78,
            metrics: [
                SleepMetricItem(title: "Duration Score", score: 16, maxScore: 20, trendPercent: 5),
                SleepMetricItem(title: "Efficiency Score", score: 12, maxScore: 15, trendPercent: 3),
                SleepMetricItem(title: "Architecture Score", score: 18, maxScore: 25, trendPercent: -2),
                SleepMetricItem(title: "Continuity Score", score: 13, maxScore: 15, trendPercent: 1),
                SleepMetricItem(title: "Calmness Score", score: 11, maxScore: 15, trendPercent: -4),
                SleepMetricItem(title: "Consistency Score", score: 8, maxScore: 10, trendPercent: 2)
            ]
        )
    }

    func getGroggy() -> GroggyModel {
        return GroggyModel(value: 5)
    }

    func getNote() -> MorningNoteModel {
        return MorningNoteModel(
            text: "",
            date: Date()
        )
    }
}
