import Foundation

final class HomeDataProvider {

    static let shared = HomeDataProvider()
    private init() {}

    private let ringRange: StatsTimeRange = .week

    // MARK: - Alarm
    func getAlarm() -> AlarmModel {
        let savedTime = UserDefaults.standard.object(forKey: "wakewell.savedAlarmTime") as? Date
        if let savedTime {
            return AlarmModel(time: savedTime)
        }

        let profileGoal = DatabaseManager.shared.fetchUserProfile()?.wakeUpGoalTime
        return AlarmModel(time: profileGoal)
    }

    // MARK: - Sleep Ring
    func getSleepRing() -> SleepRingModel {
        let records = HealthKitSleepRepository.shared.records(for: ringRange)
        guard !records.isEmpty else {
            return SleepRingModel(
                score: nil,
                subtitle: "Start tonight"
            )
        }

        let stats = SleepStatsAggregator.aggregate(for: ringRange)
        let score = SleepScoreCalculator.combinedScore(
            duration: stats.duration,
            efficiency: stats.efficiency,
            architecture: stats.architecture,
            continuity: stats.continuity,
            calmness: stats.calmness,
            consistency: stats.consistency
        )

        return SleepRingModel(
            score: Int(score.rounded()),
            subtitle: SleepRingModel.subtitle(for: stats, score: score)
        )
    }

    // MARK: - Metrics
    // Current score  = average of this week's data points  (.week)
    // Previous score = average of this month's data points (.month)
    //                  The month includes the current week so the first
    //                  half approximates "last week". We compare the two
    //                  averages to derive a real trend direction and %.
    func getMetrics() -> SleepMetricsModel {
        let currentRecords = HealthKitSleepRepository.shared.records(for: .week)

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
            hasData: !currentRecords.isEmpty,
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
        let todayRecord = records.first(where: { Calendar.current.isDateInToday($0.date) })
        let yesterdayRecord = records.first(where: { Calendar.current.isDateInYesterday($0.date) })
        let history = records
            .filter { $0.hoursSlept > 0 }
            .sorted { $0.date > $1.date }
            .map {
                SleepDebtModelItem(
                    sleepDuration: $0.hoursSlept,
                    date: $0.date
                )
            }

        return SleepDebtModel(
            todaySleepDuration: todayRecord?.hoursSlept,
            yesterdaySleepDuration: yesterdayRecord?.hoursSlept,
            sleepHistory: history
        )
    }

    // MARK: - Groggy / Notes
    func getGroggy() -> GroggyModel {
        let journal = DatabaseManager.shared.fetchDailyJournalEntry()
        return GroggyModel(
            value: journal.map { max(0, min(10, $0.groggyValue)) } ?? 0,
            isLocked: journal?.isLocked ?? false,
            hasEntry: journal != nil
        )
    }

    func getNote() -> MorningNoteModel {
        let journal = DatabaseManager.shared.fetchDailyJournalEntry()
        return MorningNoteModel(
            text: journal?.morningNote ?? "",
            date: journal?.date ?? Date(),
            isLocked: journal?.isLocked ?? false,
            hasEntry: journal != nil
        )
    }

    func saveGroggy(_ value: Float) {
        _ = DatabaseManager.shared.saveDailyJournal(groggyValue: value)
    }

    func saveMorningNote(_ text: String) {
        _ = DatabaseManager.shared.saveDailyJournal(morningNote: text)
    }

    func finalizeTodayJournal(groggyValue: Float, morningNote: String) {
        _ = DatabaseManager.shared.saveDailyJournal(
            groggyValue: groggyValue,
            morningNote: morningNote,
            locked: true
        )
    }

}
