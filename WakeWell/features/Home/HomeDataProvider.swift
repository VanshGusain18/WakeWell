import Foundation

final class HomeDataProvider {

    static let shared = HomeDataProvider()
    private init() {}

    // MARK: - Alarm
    func getAlarm() -> AlarmModel {
        let savedTime = UserDefaults.standard.object(forKey: "wakewell.savedAlarmTime") as? Date
        return AlarmModel(time: savedTime)
    }

    // MARK: - Sleep Ring
    func getSleepRing() -> SleepRingModel {
        return SleepRingModel(score: 82, subtitle: "Good Sleep")
    }

    // MARK: - Metrics
    // Current score  = average of this week's data points  (.week)
    // Previous score = average of this month's data points (.month)
    //                  The month includes the current week so the first
    //                  half approximates "last week". We compare the two
    //                  averages to derive a real trend direction and %.
    func getMetrics() -> SleepMetricsModel {

        let current  = scoresFor(range: .week)
        let previous = scoresFor(range: .month)

        func trend(_ cur: Int, _ prev: Int) -> Int {
            guard prev > 0 else { return 0 }
            return Int(((Double(cur) - Double(prev)) / Double(prev) * 100).rounded())
        }

        let combined = Int(SleepScoreCalculator.combinedScore(
            duration:     Double(current.duration),
            efficiency:   Double(current.efficiency),
            architecture: Double(current.architecture),
            continuity:   Double(current.continuity),
            calmness:     Double(current.calmness),
            consistency:  Double(current.consistency)
        ).rounded())

        return SleepMetricsModel(
            sleepScore: combined,
            metrics: [
                SleepMetricItem(title: "Duration",
                                score: current.duration,
                                trendPercent: trend(current.duration,     previous.duration)),
                SleepMetricItem(title: "Efficiency",
                                score: current.efficiency,
                                trendPercent: trend(current.efficiency,   previous.efficiency)),
                SleepMetricItem(title: "Architecture",
                                score: current.architecture,
                                trendPercent: trend(current.architecture, previous.architecture)),
                SleepMetricItem(title: "Continuity",
                                score: current.continuity,
                                trendPercent: trend(current.continuity,   previous.continuity)),
                SleepMetricItem(title: "Calmness",
                                score: current.calmness,
                                trendPercent: trend(current.calmness,     previous.calmness)),
                SleepMetricItem(title: "Consistency",
                                score: current.consistency,
                                trendPercent: trend(current.consistency,  previous.consistency))
            ]
        )
    }

    // MARK: - Private helper
    // Returns all six metric scores (0–100) averaged over the given range.
    private struct Scores {
        let duration, efficiency, architecture, continuity, calmness, consistency: Int
    }

    private func scoresFor(range: StatsTimeRange) -> Scores {
        func avg(_ metric: SleepMetricType) -> Int {
            Int(SleepScoreEngine.calculateScore(for: metric, range: range).rounded())
        }
        return Scores(
            duration:     avg(.duration),
            efficiency:   avg(.efficiency),
            architecture: avg(.architecture),
            continuity:   avg(.continuity),
            calmness:     avg(.calmness),
            consistency:  avg(.consistency)
        )
    }

    // MARK: - Sleep Debt
    func getSleepDebt() -> SleepDebtModel {
        let records = HealthKitSleepRepository.shared.records(for: .week)
        let history = records
            .filter { $0.hoursSlept > 0 }
            .sorted { $0.date > $1.date }
            .map {
                SleepDebtModelItem(
                    sleepDuration: $0.hoursSlept,
                    date: $0.date
                )
            }

        return SleepDebtModel(sleepHistory: history)
    }

    // MARK: - Groggy / Notes
    func getGroggy()  -> GroggyModel      { GroggyModel(value: 5) }
    func getNote()    -> MorningNoteModel  { MorningNoteModel(text: "", date: Date()) }

    // MARK: - Rise Ritual
    func getRiseRitual() -> RiseRitualModel {
        let savedIDs = UserDefaults.standard.stringArray(forKey: "wakewell.selectedActivityIDs")
                       ?? ["ritual_1", "ritual_3"]
        let count = savedIDs.count
        let desc: String
        switch count {
        case 0:  desc = "Add activities to build your personal morning ritual."
        case 1:  desc = "1 activity ready — tap Start Ritual to begin."
        default: desc = "\(count) activities ready — start your morning ritual."
        }
        return RiseRitualModel(title: "Rise Ritual", category: "MORNING ROUTINE", description: desc)
    }
}
