//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
import UIKit


// MARK: - Analyzer
class SleepContinuityAnalyzer {

    // MARK: - Weekly Raw Data
    static func getWeeklyContinuity() -> [ContinuityData] {

        return [
            ContinuityData(day: "Mon", awakenings: 3, totalAwakeTime: 25),
            ContinuityData(day: "Tue", awakenings: 2, totalAwakeTime: 15),
            ContinuityData(day: "Wed", awakenings: 4, totalAwakeTime: 35),
            ContinuityData(day: "Thu", awakenings: 1, totalAwakeTime: 10),
            ContinuityData(day: "Fri", awakenings: 2, totalAwakeTime: 18),
            ContinuityData(day: "Sat", awakenings: 3, totalAwakeTime: 22),
            ContinuityData(day: "Sun", awakenings: 2, totalAwakeTime: 16)
        ]
    }

    // MARK: - Score Logic
    static func calculateContinuityScore(awakenings: Int, awakeTime: Double) -> Double {

        let awakeningPenalty = Double(awakenings) * 5
        let awakeTimePenalty = awakeTime * 0.5   // WASO in minutes

        let rawScore = 100 - (awakeningPenalty + awakeTimePenalty)

        return max(0, min(100, rawScore))
    }
    // MARK: - Average Score
    static func getAverageScore() -> Double {
        let data = getWeeklyContinuity()
        let total = data.reduce(0) { $0 + $1.score }
        return total / Double(data.count)
    }

    // MARK: - 📈 TREND DATA (Score Line Chart)
    static func trendChartData(from data: [ContinuityData]) -> (
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
            label: "Continuity Score",
            values: entries,
            color: .systemPurple
        )

        return (
            title: "Continuity Score Trend",
            dataSets: [dataSet],
            xAxisLabels: labels
        )
    }

    // MARK: - 📊 FRAGMENTATION DATA (Double Bar)
    static func fragmentationChartData(from data: [ContinuityData]) -> (
        title: String,
        dataSets: [BarChartDataSetModel],
        xAxisLabels: [String]
    ) {

        let labels = data.map { $0.day }

        let awakeningsEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(
                xIndex: Double(index),
                value: Double(item.awakenings)
            )
        }

        let awakeTimeEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(
                xIndex: Double(index),
                value: item.totalAwakeTime
            )
        }

        let dataSets = [
            BarChartDataSetModel(
                label: "Awakenings",
                color: .systemOrange,
                values: awakeningsEntries
            ),
            BarChartDataSetModel(
                label: "Awake Time (min)",
                color: .systemRed,
                values: awakeTimeEntries
            )
        ]

        return (
            title: "Sleep Fragmentation",
            dataSets: dataSets,
            xAxisLabels: labels
        )
    }

    // MARK: - Info Text
    static func continuityInfo() -> String {
        return """
        Sleep continuity refers to how uninterrupted your sleep is throughout the night.

        Frequent awakenings or long periods of wakefulness can reduce sleep quality, even if total sleep time is sufficient.

        Fewer awakenings and shorter awake durations indicate more restorative and continuous sleep.

        Aim to minimize disturbances and maintain longer uninterrupted sleep periods.
        """
    }
    
}
