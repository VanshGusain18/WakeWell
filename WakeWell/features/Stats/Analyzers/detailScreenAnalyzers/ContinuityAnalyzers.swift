//
//  ContinuityAnalyzers.swift
//  WakeWell
//

import Foundation
import UIKit

final class SleepContinuityAnalyzer {

    static func getData(for range: StatsTimeRange) -> [ContinuityData] {
        let records = HealthKitSleepRepository.shared.records(for: range)
        guard !records.isEmpty else { return noData(for: range) }

        switch range {
        case .week:
            return records.map {
                ContinuityData(day: weekdayLabel($0.date),
                               awakenings: $0.awakenings,
                               totalAwakeTime: $0.totalAwakeMin)
            }
        case .month:
            return weeklyAveraged(records, fields: { [Double($0.awakenings), $0.totalAwakeMin] }).map {
                ContinuityData(day: $0.label,
                               awakenings: Int($0.values[0].rounded()),
                               totalAwakeTime: $0.values[1])
            }
        case .year:
            return monthlyAveraged(records, fields: { [Double($0.awakenings), $0.totalAwakeMin] }).map {
                ContinuityData(day: $0.label,
                               awakenings: Int($0.values[0].rounded()),
                               totalAwakeTime: $0.values[1])
            }
        }
    }

    static func calculateScore(awakenings: Int, awakeTime: Double) -> Double {
        return max(0, min(100, 100 - (Double(awakenings) * 5 + awakeTime * 0.5)))
    }

    static func getAverageScore(for range: StatsTimeRange) -> Double {
        let data = getData(for: range)
        guard !data.isEmpty else { return 0 }
        return data.map { $0.score }.reduce(0, +) / Double(data.count)
    }

    static func trendChartData(from data: [ContinuityData]) -> (title: String, dataSets: [LineChartDataSetModel], xAxisLabels: [String]) {
        let labels  = data.map { $0.day }
        let entries = data.enumerated().map { LineChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.score) }
        return (
            title: "Continuity Score Trend",
            dataSets: [LineChartDataSetModel(label: "Continuity Score", values: entries)],
            xAxisLabels: labels
        )
    }

    static func fragmentationChartData(from data: [ContinuityData]) -> (title: String, dataSets: [BarChartDataSetModel], xAxisLabels: [String]) {
        let labels     = data.map { $0.day }
        let awakenings = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: Double($0.element.awakenings)) }
        let awakeTime  = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.totalAwakeTime) }
        return (
            title: "Sleep Fragmentation",
            dataSets: [
                BarChartDataSetModel(label: "Awakenings",       values: awakenings),
                BarChartDataSetModel(label: "Awake Time (min)", values: awakeTime)
            ],
            xAxisLabels: labels
        )
    }

    static func continuityInfo() -> String {
        """
        This measures how smooth and uninterrupted your sleep was.

        Fewer wake-ups during the night mean better rest.
        Staying asleep for longer stretches helps your body recover properly.
        """
    }

    private static func noData(for range: StatsTimeRange) -> [ContinuityData] {
        []
    }
}
