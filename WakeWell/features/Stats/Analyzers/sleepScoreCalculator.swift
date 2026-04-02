//
//  sleepScoreEngine.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//
import Foundation

// MARK: - Score Calculators (one place for all formulas)

struct SleepScoreCalculator {

    // MARK: 1. Duration — Gaussian penalty centered at 8hrs
    static func durationScore(hoursSlept: Double) -> Double {
        let sigma: Double = 1.5
        let score = 100 * exp(-pow(hoursSlept - 8.0, 2) / (2 * sigma * sigma))
        return max(0, min(100, score))
    }

    // MARK: 2. Efficiency
    static func efficiencyScore(timeInBed: Double, timeAsleep: Double) -> Double {
        guard timeInBed > 0 else { return 0 }
        let e = (timeAsleep / timeInBed) * 100
        switch e {
        case 95...:   return 100
        case 75..<95: return ((e - 75) / 20) * 100
        default:      return 0
        }
    }

    // MARK: 3. Architecture — Euclidean distance from target stages
    // Expects deep, rem, light as percentages (e.g. 20.0, 22.0, 55.0)
    static func architectureScore(deep: Double, rem: Double, light: Double) -> Double {
        let k: Double = 1.2
        let error = sqrt(pow(deep - 20, 2) + pow(rem - 22, 2) + pow(light - 55, 2))
        return max(0, min(100, 100 - k * error))
    }

    // MARK: 4. Continuity
    static func continuityScore(awakenings: Int, waso: Double) -> Double {
        let score = 100 - (0.5 * waso + 5.0 * Double(awakenings))
        return max(0, min(100, score))
    }

    // MARK: 5. Consistency — std deviation penalty
    static func consistencyScore(bedtimes: [Double], wakeTimes: [Double]) -> Double {
        let k1: Double = 10, k2: Double = 10
        let score = 100 - (k1 * standardDeviation(bedtimes) + k2 * standardDeviation(wakeTimes))
        return max(0, min(100, score))
    }

    // MARK: 6. Calmness — HRV + RHR + Movement
    // Pass population min/max for normalization
    static func calmnessScore(rhr: Double, hrv: Double, movementIndex: Double,
                               rhrMin: Double = 40, rhrMax: Double = 100,
                               hrvMin: Double = 20, hrvMax: Double = 80) -> Double {
        let sRHR = 100 * (rhrMax - rhr) / (rhrMax - rhrMin)
        let sHRV = 100 * (hrv - hrvMin) / (hrvMax - hrvMin)
        let sMovement = 100 * (1 - movementIndex)

        let score = 0.4 * sHRV + 0.4 * sRHR + 0.2 * sMovement
        return max(0, min(100, score))
    }

    // MARK: 7. Final Combined Score
    static func combinedScore(duration: Double, efficiency: Double, architecture: Double,
                               continuity: Double, calmness: Double, consistency: Double) -> Double {
        return (0.20 * duration) +
               (0.15 * efficiency) +
               (0.25 * architecture) +
               (0.15 * continuity) +
               (0.15 * calmness) +
               (0.10 * consistency)
    }

    // MARK: Helper
    static func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean     = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
}

// MARK: - MetricDataProvider

final class MetricDataProvider {

    static func data(for metric: SleepMetricType, range: StatsTimeRange) -> [MetricData] {
        switch metric {

        case .duration:
            return SleepDurationAnalyzer.getData(for: range).map {
                MetricData(day: $0.day,
                           value: MetricValue(raw: SleepScoreCalculator.durationScore(hoursSlept: $0.hoursSlept)))
            }

        case .efficiency:
            return EfficiencyAnalyzer.getData(for: range).map {
                MetricData(day: $0.day,
                           value: MetricValue(raw: SleepScoreCalculator.efficiencyScore(timeInBed: $0.timeInBed,
                                                                                         timeAsleep: $0.timeAsleep)))
            }

        case .architecture:
            return SleepArchitectureAnalyzer.getData(for: range).map {
                MetricData(day: $0.day,
                           value: MetricValue(raw: SleepScoreCalculator.architectureScore(deep: $0.deep,
                                                                                           rem: $0.rem,
                                                                                           light: $0.light)))
            }

        case .continuity:
            return SleepContinuityAnalyzer.getData(for: range).map {
                MetricData(day: $0.day,
                           value: MetricValue(raw: SleepScoreCalculator.continuityScore(awakenings: $0.awakenings,
                                                                                         waso: $0.totalAwakeTime)))
            }

        case .calmness:
            return SleepCalmnessAnalyzer.getData(for: range).map {
                MetricData(day: $0.day,
                           value: MetricValue(raw: SleepScoreCalculator.calmnessScore(rhr: $0.restingHeartRate,
                                                                                       hrv: $0.hrv,
                                                                                       movementIndex: $0.movementIndex)))
            }

        case .consistency:
            let data      = SleepConsistencyAnalyzer.getData(for: range)
            let bedtimes  = data.map { $0.bedtime }
            let wakeTimes = data.map { $0.wakeTime }
            // Consistency is a single score for the whole period, repeated per point so the line chart renders
            let score     = SleepScoreCalculator.consistencyScore(bedtimes: bedtimes, wakeTimes: wakeTimes)
            return data.map { MetricData(day: $0.day, value: MetricValue(raw: score)) }
        }
    }

    // Overall combined score per data point (used by SleepScoreChartCell)
    static func overallScores(for range: StatsTimeRange) -> [MetricData] {
        let allMetrics: [SleepMetricType] = [.duration, .efficiency, .architecture,
                                              .continuity, .calmness, .consistency]
        let allData = allMetrics.map { data(for: $0, range: range) }

        guard let count = allData.first?.count, count > 0 else { return [] }

        return (0..<count).map { index in
            let dayLabel = allData[0][index].day

            // Pull each metric score for this day
            let d   = allData[0][index].value.raw  // duration
            let e   = allData[1][index].value.raw  // efficiency
            let a   = allData[2][index].value.raw  // architecture
            let con = allData[3][index].value.raw  // continuity
            let cal = allData[4][index].value.raw  // calmness
            let cs  = allData[5][index].value.raw  // consistency

            let combined = SleepScoreCalculator.combinedScore(
                duration:     d,
                efficiency:   e,
                architecture: a,
                continuity:   con,
                calmness:     cal,
                consistency:  cs
            )
            return MetricData(day: dayLabel, value: MetricValue(raw: combined))
        }
    }
}


final class SleepScoreEngine {

    static func calculateScore(for metric: SleepMetricType, range: StatsTimeRange) -> Double {
        let points = MetricDataProvider.data(for: metric, range: range)
        guard !points.isEmpty else { return 0 }
        return points.map { $0.value.raw }.reduce(0, +) / Double(points.count)
    }
}
