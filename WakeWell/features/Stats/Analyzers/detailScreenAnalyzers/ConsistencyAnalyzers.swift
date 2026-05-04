//
//  ConsistencyAnalyzers.swift
//  WakeWell
//

import Foundation
import UIKit

final class SleepConsistencyAnalyzer {

    static func getData(for range: StatsTimeRange) -> [SleepConsistencyData] {
        let records = HealthKitSleepRepository.shared.records(for: range)
        guard !records.isEmpty else { return noData(for: range) }

        switch range {
        case .week:
            return records.map {
                SleepConsistencyData(day: weekdayLabel($0.date),
                                     bedtime: $0.bedtime,
                                     wakeTime: $0.wakeTime)
            }
        case .month:
            return weeklyAveraged(records, fields: { [$0.bedtime, $0.wakeTime] }).map {
                SleepConsistencyData(day: $0.label, bedtime: $0.values[0], wakeTime: $0.values[1])
            }
        case .year:
            return monthlyAveraged(records, fields: { [$0.bedtime, $0.wakeTime] }).map {
                SleepConsistencyData(day: $0.label, bedtime: $0.values[0], wakeTime: $0.values[1])
            }
        }
    }

    static func calculateScore(bedtime: Double, wakeTime: Double) -> Double {
        let data      = getData(for: .week)
        let sigmaBed  = standardDeviation(data.map { $0.bedtime })
        let sigmaWake = standardDeviation(data.map { $0.wakeTime })
        return max(0, min(100, 100 - (10.0 * sigmaBed + 10.0 * sigmaWake)))
    }

    static func getAverageScore(for range: StatsTimeRange) -> Double {
        let data = getData(for: range)
        guard !data.isEmpty else { return 0 }
        let sigmaBed  = standardDeviation(data.map { $0.bedtime })
        let sigmaWake = standardDeviation(data.map { $0.wakeTime })
        return max(0, min(100, 100 - (10.0 * sigmaBed + 10.0 * sigmaWake)))
    }

    static func trendChartData(from data: [SleepConsistencyData]) -> (title: String, dataSets: [LineChartDataSetModel], xAxisLabels: [String]) {
        let labels  = data.map { $0.day }
        let entries = data.enumerated().map { LineChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.score) }
        return (
            title: "Consistency Score Trend",
            dataSets: [LineChartDataSetModel(label: "Consistency Score", values: entries)],
            xAxisLabels: labels
        )
    }

    static func timingChartData(from data: [SleepConsistencyData]) -> (title: String, dataSets: [BarChartDataSetModel], xAxisLabels: [String]) {
        let labels   = data.map { $0.day }
        let bedtimes = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.bedtime) }
        let wakes    = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.wakeTime) }
        return (
            title: "Sleep Timing",
            dataSets: [
                BarChartDataSetModel(label: "Bedtime",   values: bedtimes),
                BarChartDataSetModel(label: "Wake Time", values: wakes)
            ],
            xAxisLabels: labels
        )
    }

    static func consistencyInfo() -> String {
        """
        This shows how regular your sleep schedule is.

        Going to bed and waking up at similar times every day helps your body stay in a healthy rhythm,
        making it easier to fall asleep and wake up feeling refreshed.
        """
    }

    private static func noData(for range: StatsTimeRange) -> [SleepConsistencyData] {
        []
    }

    private static func standardDeviation(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let mean     = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
}
