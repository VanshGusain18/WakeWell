//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
import UIKit

final class SleepConsistencyAnalyzer {

    static func getData(for range: StatsTimeRange) -> [SleepConsistencyData] {
        switch range {
        case .week:
            return [
                SleepConsistencyData(day: "Mon", bedtime: 23.0, wakeTime: 7.0),
                SleepConsistencyData(day: "Tue", bedtime: 23.5, wakeTime: 7.2),
                SleepConsistencyData(day: "Wed", bedtime: 24.0, wakeTime: 7.5),
                SleepConsistencyData(day: "Thu", bedtime: 23.2, wakeTime: 7.1),
                SleepConsistencyData(day: "Fri", bedtime: 23.8, wakeTime: 7.4),
                SleepConsistencyData(day: "Sat", bedtime: 24.5, wakeTime: 8.0),
                SleepConsistencyData(day: "Sun", bedtime: 23.3, wakeTime: 7.3)
            ]
        case .month:
            return [
                SleepConsistencyData(day: "W1", bedtime: 23.4, wakeTime: 7.1),
                SleepConsistencyData(day: "W2", bedtime: 23.2, wakeTime: 7.0),
                SleepConsistencyData(day: "W3", bedtime: 23.6, wakeTime: 7.2),
                SleepConsistencyData(day: "W4", bedtime: 23.3, wakeTime: 7.1)
            ]
        case .year:
            return zip(StatsTimeRange.year.xAxisLabels,
                       [(23.5,7.2),(23.4,7.1),(23.3,7.0),(23.2,7.0),
                        (23.1,6.9),(23.0,6.8),(23.0,6.8),(23.1,6.9),
                        (23.2,7.0),(23.4,7.1),(23.5,7.2),(23.6,7.3)]).map {
                SleepConsistencyData(day: $0.0, bedtime: $0.1.0, wakeTime: $0.1.1)
            }
        }
    }

    // Takes the full dataset for the range and derives a score from its std deviation
    static func calculateScore(bedtime: Double, wakeTime: Double) -> Double {
        // Individual point score using fixed week baseline — swap for range-specific when real data arrives
        let data      = getData(for: .week)
        let sigmaBed  = standardDeviation(data.map { $0.bedtime })
        let sigmaWake = standardDeviation(data.map { $0.wakeTime })
        let score     = 100 - (10.0 * sigmaBed + 10.0 * sigmaWake)
        return max(0, min(100, score))
    }

    static func getAverageScore(for range: StatsTimeRange) -> Double {
        let data = getData(for: range)
        guard !data.isEmpty else { return 0 }
        let sigmaBed  = standardDeviation(data.map { $0.bedtime })
        let sigmaWake = standardDeviation(data.map { $0.wakeTime })
        let score     = 100 - (10.0 * sigmaBed + 10.0 * sigmaWake)
        return max(0, min(100, score))
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
                BarChartDataSetModel(label: "Bedtime", values: bedtimes),
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
    
    private static func standardDeviation(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let mean     = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
}
