//
//  sleepScoreEngine.swift
//  SetSail
//
//  Created by geu on 18/03/26.
//
import Foundation

struct SleepScoreCalculator {

    static func durationScore(hoursSlept: Double) -> Double {
        let sigma: Double = 1.5
        let score = 100 * exp(-pow(hoursSlept - 8.0, 2) / (2 * sigma * sigma))
        return max(0, min(100, score))
    }

    static func efficiencyScore(timeInBed: Double, timeAsleep: Double) -> Double {
        guard timeInBed > 0 else { return 0 }
        let e = (timeAsleep / timeInBed) * 100
        switch e {
        case 95...:   return 100
        case 75..<95: return ((e - 75) / 20) * 100
        default:      return 0
        }
    }

    // Formula from SetSail doc:
    //   d = sqrt(k1*(deep-20)^2 + k2*(rem-22)^2 + k3*(light-55)^2)
    //   Score(a) = (1 - d) * 100
    //   k1=1.5, k2=1.2, k3=1.0
    //
    // BUG: The doc formula produces 0 for virtually every real input because `d`
    // is almost always >> 1 (e.g. typical sleep of deep=15, rem=20, light=65
    // gives d ≈ 12, so (1 - 12) * 100 clamps to 0). Only a pixel-perfect match
    // to the ideal centroid (20, 22, 55) returns a non-zero value.
    //
    // FIX (faithful to doc intent): Normalise d by d_max so the formula maps
    // the full input range to [0, 100] as clearly intended.
    // d_max is the distance when all stages are 0 — the furthest possible point
    // from the ideal centroid given percentages can't go below 0.
    // d_max = sqrt(k1*20^2 + k2*22^2 + k3*55^2) ≈ 56.6
    //
    // This preserves the doc's relative weighting (deep penalised most, then REM,
    // then light) while making the score numerically meaningful.
    static func architectureScore(deep: Double, rem: Double, light: Double) -> Double {
        let k1: Double = 1.5, k2: Double = 1.2, k3: Double = 1.0
        let d     = sqrt(k1 * pow(deep  - 20, 2) +
                         k2 * pow(rem   - 22, 2) +
                         k3 * pow(light - 55, 2))
        let d_max = sqrt(k1 * pow(20, 2) + k2 * pow(22, 2) + k3 * pow(55, 2))
        return max(0, min(100, (1 - d / d_max) * 100))
    }

    // Doc formula: Score = 100 - (0.5 * WASO(min) + 5 * Awakenings)  ✓ matches
    static func continuityScore(awakenings: Int, waso: Double) -> Double {
        let score = 100 - (0.5 * waso + 5.0 * Double(awakenings))
        return max(0, min(100, score))
    }

    // Consistency formula is not defined in the SetSail doc beyond the concept.
    // The std-dev penalty approach (10*σBed + 10*σWake) is a reasonable
    // implementation and is left unchanged.
    static func consistencyScore(bedtimes: [Double], wakeTimes: [Double]) -> Double {
        let k1: Double = 10, k2: Double = 10
        let score = 100 - (k1 * standardDeviation(bedtimes) + k2 * standardDeviation(wakeTimes))
        return max(0, min(100, score))
    }

    // Doc formulas:
    //   sRHR     = 100 × (rhrMax − rhr) / (rhrMax − rhrMin)           ✓ matches
    //   sHRV     = 100 × (hrv − hrvMin) / (hrv − hrvMin)              ← TYPO in doc
    //              correct denominator is (hrvMax − hrvMin)            ✓ code is correct
    //   sMovement = 100 × (1 − movementIndex)                         ✓ matches
    //   Score    = 0.4*sHRV + 0.4*sRHR + 0.2*sMovement               (from code; doc omits weights)
    static func calmnessScore(rhr: Double, hrv: Double, movementIndex: Double,
                               rhrMin: Double = 40, rhrMax: Double = 100,
                               hrvMin: Double = 20, hrvMax: Double = 80) -> Double {
        let sRHR      = 100 * (rhrMax - rhr)  / (rhrMax - rhrMin)
        let sHRV      = 100 * (hrv - hrvMin)  / (hrvMax - hrvMin)  // doc typo fixed: denominator is (hrvMax - hrvMin)
        let sMovement = 100 * (1 - movementIndex)
        let score = 0.4 * sHRV + 0.4 * sRHR + 0.2 * sMovement
        return max(0, min(100, score))
    }

    static func combinedScore(duration: Double, efficiency: Double, architecture: Double,
                               continuity: Double, calmness: Double, consistency: Double) -> Double {
        return (0.20 * duration) +
               (0.15 * efficiency) +
               (0.25 * architecture) +
               (0.15 * continuity) +
               (0.15 * calmness) +
               (0.10 * consistency)
    }

    static func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean     = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
}

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
            let score     = SleepScoreCalculator.consistencyScore(bedtimes: bedtimes, wakeTimes: wakeTimes)
            return data.map { MetricData(day: $0.day, value: MetricValue(raw: score)) }
        }
    }

    static func overallScores(for range: StatsTimeRange) -> [MetricData] {
        let allMetrics: [SleepMetricType] = [.duration, .efficiency, .architecture,
                                              .continuity, .calmness, .consistency]
        let allData = allMetrics.map { data(for: $0, range: range) }

        guard let count = allData.first?.count, count > 0 else { return [] }

        return (0..<count).map { index in
            let dayLabel = allData[0][index].day

            let d   = allData[0][index].value.raw
            let e   = allData[1][index].value.raw
            let a   = allData[2][index].value.raw
            let con = allData[3][index].value.raw
            let cal = allData[4][index].value.raw
            let cs  = allData[5][index].value.raw

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
