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
                SleepMetricItem(title: "Duration",     score: 16, maxScore: 20, trendPercent:  5),
                SleepMetricItem(title: "Efficiency",   score: 12, maxScore: 15, trendPercent:  3),
                SleepMetricItem(title: "Sleep Stages", score: 18, maxScore: 25, trendPercent: -2),
                SleepMetricItem(title: "Continuity",   score: 13, maxScore: 15, trendPercent:  1),
                SleepMetricItem(title: "Calmness",     score: 11, maxScore: 15, trendPercent: -4),
                SleepMetricItem(title: "Consistency",  score:  8, maxScore: 10, trendPercent:  2)
            ]
        )
    }

    func getSleepDebt() -> SleepDebtModel {
        let history = [
            SleepDebtModelItem(sleepDuration: 6, date: Date()),
            SleepDebtModelItem(sleepDuration: 7, date: Date().addingTimeInterval(-86400)),
            SleepDebtModelItem(sleepDuration: 8, date: Date().addingTimeInterval(-172800)),
            SleepDebtModelItem(sleepDuration: 5, date: Date().addingTimeInterval(-259200))
        ]
        return SleepDebtModel(sleepHistory: history)
    }

    func getGroggy() -> GroggyModel {
        return GroggyModel(value: 5)
    }

    func getNote() -> MorningNoteModel {
        return MorningNoteModel(text: "", date: Date())
    }

    func getRiseRitual() -> RiseRitualModel {
        return RiseRitualModel.defaultRitual()
    }
}
