//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
import UIKit

final class SleepContinuityAnalyzer {

    static func getData(for range: StatsTimeRange) -> [ContinuityData] {
        switch range {
        case .week:
            return [
                ContinuityData(day: "Mon", awakenings: 3, totalAwakeTime: 25),
                ContinuityData(day: "Tue", awakenings: 2, totalAwakeTime: 15),
                ContinuityData(day: "Wed", awakenings: 4, totalAwakeTime: 35),
                ContinuityData(day: "Thu", awakenings: 1, totalAwakeTime: 10),
                ContinuityData(day: "Fri", awakenings: 2, totalAwakeTime: 18),
                ContinuityData(day: "Sat", awakenings: 3, totalAwakeTime: 22),
                ContinuityData(day: "Sun", awakenings: 2, totalAwakeTime: 16)
            ]
        case .month:
            return [
                ContinuityData(day: "W1", awakenings: 3, totalAwakeTime: 22),
                ContinuityData(day: "W2", awakenings: 2, totalAwakeTime: 17),
                ContinuityData(day: "W3", awakenings: 3, totalAwakeTime: 24),
                ContinuityData(day: "W4", awakenings: 2, totalAwakeTime: 15)
            ]
        case .year:
            return zip(StatsTimeRange.year.xAxisLabels,
                       [(3,24),(3,22),(2,18),(2,16),(2,15),(2,14),
                        (2,13),(2,14),(2,16),(3,18),(3,20),(3,22)]).map {
                ContinuityData(day: $0.0, awakenings: $0.1.0, totalAwakeTime: Double($0.1.1))
            }
        }
    }

    static func calculateScore(awakenings: Int, awakeTime: Double) -> Double {
        let score = 100 - (Double(awakenings) * 5 + awakeTime * 0.5)
        return max(0, min(100, score))
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
                BarChartDataSetModel(label: "Awakenings", values: awakenings),
                BarChartDataSetModel(label: "Awake Time (min)", values: awakeTime)
            ],
            xAxisLabels: labels
        )
    }

    static func continuityInfo() -> String {
        """
        Sleep continuity refers to how uninterrupted your sleep is throughout the night.

        Frequent awakenings or long periods of wakefulness can reduce sleep quality, even if
        total sleep time is sufficient. Aim to minimise disturbances and maintain longer
        uninterrupted sleep periods.
        """
    }
}
