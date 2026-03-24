//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
import UIKit

// MARK: - Analyzer
class SleepConsistencyAnalyzer {

    // MARK: - Weekly Raw Data
    static func getWeeklyConsistency() -> [SleepConsistencyData] {
        return [
            SleepConsistencyData(day: "Mon", bedtime: 20.0, wakeTime: 7.0),
            SleepConsistencyData(day: "Tue", bedtime: 23.5, wakeTime: 7.2),
            SleepConsistencyData(day: "Wed", bedtime: 24.0, wakeTime: 0.5),
            SleepConsistencyData(day: "Thu", bedtime: 23.2, wakeTime: 7.1),
            SleepConsistencyData(day: "Fri", bedtime: 23.8, wakeTime: 7.4),
            SleepConsistencyData(day: "Sat", bedtime: 24.0, wakeTime: 0.0),
            SleepConsistencyData(day: "Sun", bedtime: 23.3, wakeTime: 7.3)
        ]
    }

    // MARK: - Score Logic
    static func calculateConsistencyScore(bedtime: Double, wakeTime: Double) -> Double {
        let data = getWeeklyConsistency()
        let bedTimes = data.map { $0.bedtime }
        let wakeTimes = data.map { $0.wakeTime }

        let sigmaBed = standardDeviation(bedTimes)
        let sigmaWake = standardDeviation(wakeTimes)

        let k1 = 10.0, k2 = 10.0
        let rawScore = 100 - (k1 * sigmaBed + k2 * sigmaWake)
        return max(0, min(100, rawScore))
    }

    // MARK: - Average Score
    static func getAverageScore() -> Double {
            let data = getWeeklyConsistency()
            let totalScore = data.reduce(0) { $0 + $1.score }
            return totalScore / Double(data.count)
    }

    // MARK: - 📈 TREND DATA (Score Line Chart)
    static func trendChartData(from data: [SleepConsistencyData]) -> (
        title: String,
        dataSets: [LineChartDataSetModel],
        xAxisLabels: [String]
    ) {
        let labels = data.map { $0.day }
        let entries = data.enumerated().map { index, item in
            LineChartDataEntryModel(
                xIndex: Double(index),
                value: item.score
            )
        }

        let dataSet = LineChartDataSetModel(
            label: "Consistency Score",
            values: entries,
            color: .systemGreen
        )

        return (
            title: "Consistency Score Trend",
            dataSets: [dataSet],
            xAxisLabels: labels
        )
    }

    // MARK: - 📊 TIMING DATA (Bedtime vs Wake-up Time)
    static func timingChartData(from data: [SleepConsistencyData]) -> (
        title: String,
        dataSets: [BarChartDataSetModel],
        xAxisLabels: [String]
    ) {
        let labels = data.map { $0.day }

        let bedtimeEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(xIndex: Double(index), value: item.bedtime)
        }
        let wakeTimeEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(xIndex: Double(index), value: item.wakeTime)
        }

        let dataSets = [
            BarChartDataSetModel(label: "Bedtime", color: .systemBlue, values: bedtimeEntries),
            BarChartDataSetModel(label: "Wake Time", color: .systemOrange, values: wakeTimeEntries)
        ]

        return (
            title: "Sleep Timing",
            dataSets: dataSets,
            xAxisLabels: labels
        )
    }

    // MARK: - Info Text
    static func consistencyInfo() -> String {
        return """
        Consistency measures how regular your sleep schedule is.
        Maintaining a stable bedtime and wake-up time improves circadian rhythm, sleep quality, and daytime alertness.

        The consistency score is calculated based on the variation (standard deviation) of your bed and wake times across the week.
        Lower variance = higher score. Aim to keep similar sleep times every day.
        """
    }

    // MARK: - Helper: Standard Deviation
    private static func standardDeviation(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
}
