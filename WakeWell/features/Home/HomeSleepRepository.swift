import Foundation

final class HomeSleepRepository {
    
    static let shared = HomeSleepRepository()
    
    private let fallbackProvider = HomeDataProvider.shared
    
    private init() {}
    
    func fetchSnapshot(completion: @escaping (HomeDashboardSnapshot) -> Void) {
        let fallback = fallbackProvider.fallbackSnapshot()
        
        HealthKitSleepRepository.shared.prefetch(for: .week) { [weak self] in
            guard let self else {
                completion(fallback)
                return
            }
            
            let records = HealthKitSleepRepository.shared.records(for: .week)
            guard !records.isEmpty else {
                completion(fallback)
                return
            }
            
            completion(self.makeSnapshot(from: records, fallback: fallback))
        }
    }
    
    private func makeSnapshot(from records: [NightRecord],
                              fallback: HomeDashboardSnapshot) -> HomeDashboardSnapshot {
        let sortedRecords = records.sorted { $0.date < $1.date }
        
        return HomeDashboardSnapshot(
            alarm: fallback.alarm,
            sleepDebt: makeSleepDebt(from: sortedRecords, fallback: fallback.sleepDebt),
            riseRitual: fallback.riseRitual,
            sleepRing: makeSleepRing(from: sortedRecords, fallback: fallback.sleepRing),
            metrics: makeMetrics(from: sortedRecords, fallback: fallback.metrics),
            postSleepCheckIn: fallback.postSleepCheckIn
        )
    }
    
    private func makeSleepDebt(from records: [NightRecord],
                               fallback: SleepDebtModel) -> SleepDebtModel {
        let history = records.suffix(7).map {
            SleepDebtModelItem(
                sleepDuration: $0.hoursSlept,
                date: $0.date
            )
        }
        
        return history.isEmpty ? fallback : SleepDebtModel(sleepHistory: history)
    }
    
    private func makeSleepRing(from records: [NightRecord],
                               fallback: SleepRingModel) -> SleepRingModel {
        let score = averageCombinedScore(for: records)
        guard score > 0 else { return fallback }
        
        let rounded = Int(score.rounded())
        let subtitle: String
        
        switch rounded {
        case 85...:
            subtitle = "Excellent Sleep"
        case 70...84:
            subtitle = "Good Sleep"
        case 55...69:
            subtitle = "Fair Sleep"
        default:
            subtitle = "Recovery Needed"
        }
        
        return SleepRingModel(score: rounded, subtitle: subtitle)
    }
    
    private func makeMetrics(from records: [NightRecord],
                             fallback: SleepMetricsModel) -> SleepMetricsModel {
        let slices = metricScores(from: records)
        let allMetrics = [
            buildMetricItem(title: "Duration", scores: slices.duration),
            buildMetricItem(title: "Efficiency", scores: slices.efficiency),
            buildMetricItem(title: "Sleep Stages", scores: slices.architecture),
            buildMetricItem(title: "Continuity", scores: slices.continuity),
            buildMetricItem(title: "Calmness", scores: slices.calmness),
            buildMetricItem(title: "Consistency", scores: slices.consistency)
        ]
        
        let overallScore = averageCombinedScore(for: records)
        guard overallScore > 0 else { return fallback }
        
        return SleepMetricsModel(
            sleepScore: Int(overallScore.rounded()),
            metrics: allMetrics
        )
    }
    
    private func buildMetricItem(title: String, scores: [Double]) -> SleepMetricItem {
        let recent = Array(scores.suffix(3))
        let previous = Array(scores.dropLast(min(3, scores.count)).suffix(3))
        
        let average = recent.isEmpty ? 0 : recent.reduce(0, +) / Double(recent.count)
        let previousAverage = previous.isEmpty ? average : previous.reduce(0, +) / Double(previous.count)
        let trend = Int((average - previousAverage).rounded())
        
        return SleepMetricItem(
            title: title,
            score: Int(average.rounded()),
            maxScore: 100,
            trendPercent: trend
        )
    }
    
    private func averageCombinedScore(for records: [NightRecord]) -> Double {
        let slices = metricScores(from: records)
        let duration = average(slices.duration)
        let efficiency = average(slices.efficiency)
        let architecture = average(slices.architecture)
        let continuity = average(slices.continuity)
        let calmness = average(slices.calmness)
        let consistency = average(slices.consistency)
        
        return SleepScoreCalculator.combinedScore(
            duration: duration,
            efficiency: efficiency,
            architecture: architecture,
            continuity: continuity,
            calmness: calmness,
            consistency: consistency
        )
    }
    
    private func metricScores(from records: [NightRecord]) -> (duration: [Double], efficiency: [Double], architecture: [Double], continuity: [Double], calmness: [Double], consistency: [Double]) {
        let durationScores = records.map {
            SleepScoreCalculator.durationScore(hoursSlept: $0.hoursSlept)
        }
        
        let efficiencyScores = records.map {
            SleepScoreCalculator.efficiencyScore(timeInBed: $0.timeInBed, timeAsleep: $0.hoursSlept)
        }
        
        let architectureScores = records.map {
            let asleepHours = max($0.hoursSlept, 0.01)
            let deepPct = ($0.deepHours / asleepHours) * 100
            let remPct = ($0.remHours / asleepHours) * 100
            let lightPct = ($0.lightHours / asleepHours) * 100
            
            return SleepScoreCalculator.architectureScore(
                deep: deepPct,
                rem: remPct,
                light: lightPct
            )
        }
        
        let continuityScores = records.map {
            SleepScoreCalculator.continuityScore(
                awakenings: $0.awakenings,
                waso: $0.totalAwakeMin
            )
        }
        
        let calmnessScores = records.map {
            SleepScoreCalculator.calmnessScore(
                rhr: $0.restingHR,
                hrv: $0.hrv,
                movementIndex: $0.movementIndex
            )
        }
        
        let bedtimes = records.map(\.bedtime)
        let wakeTimes = records.map(\.wakeTime)
        let consistencyScore = SleepScoreCalculator.consistencyScore(
            bedtimes: bedtimes,
            wakeTimes: wakeTimes
        )
        let consistencyScores = records.map { _ in consistencyScore }
        
        return (
            duration: durationScores,
            efficiency: efficiencyScores,
            architecture: architectureScores,
            continuity: continuityScores,
            calmness: calmnessScores,
            consistency: consistencyScores
        )
    }
    
    private func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
}
