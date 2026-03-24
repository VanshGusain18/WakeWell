//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
import UIKit

class SleepArchitectureAnalyzer {

    // MARK: - Weekly Data
    static func getWeeklyArchitecture() -> [SleepArchitectureData] {
        return [
            SleepArchitectureData(day: "Mon", deep: 20, rem: 25, light: 55),
            SleepArchitectureData(day: "Tue", deep: 18, rem: 22, light: 60),
            SleepArchitectureData(day: "Wed", deep: 22, rem: 20, light: 58),
            SleepArchitectureData(day: "Thu", deep: 19, rem: 23, light: 55),
            SleepArchitectureData(day: "Fri", deep: 21, rem: 24, light: 55),
            SleepArchitectureData(day: "Sat", deep: 17, rem: 26, light: 57),
            SleepArchitectureData(day: "Sun", deep: 20, rem: 22, light: 58)
        ]
    }
    // MARK: - Monthly Data
    static func getMonthlyArchitecture() -> [SleepArchitectureData] {
        return [
            SleepArchitectureData(day: "1", deep: 20, rem: 24, light: 56),
            SleepArchitectureData(day: "2", deep: 18, rem: 22, light: 60),
            SleepArchitectureData(day: "3", deep: 21, rem: 23, light: 56),
            SleepArchitectureData(day: "4", deep: 19, rem: 25, light: 56),
            SleepArchitectureData(day: "5", deep: 22, rem: 21, light: 57),
            SleepArchitectureData(day: "6", deep: 17, rem: 26, light: 57),
            SleepArchitectureData(day: "7", deep: 20, rem: 24, light: 56),
            
            SleepArchitectureData(day: "8", deep: 19, rem: 23, light: 58),
            SleepArchitectureData(day: "9", deep: 21, rem: 22, light: 57),
            SleepArchitectureData(day: "10", deep: 20, rem: 25, light: 55),
            SleepArchitectureData(day: "11", deep: 18, rem: 24, light: 58),
            SleepArchitectureData(day: "12", deep: 22, rem: 21, light: 57),
            SleepArchitectureData(day: "13", deep: 19, rem: 23, light: 58),
            SleepArchitectureData(day: "14", deep: 20, rem: 24, light: 56),

            SleepArchitectureData(day: "15", deep: 21, rem: 22, light: 57),
            SleepArchitectureData(day: "16", deep: 18, rem: 25, light: 57),
            SleepArchitectureData(day: "17", deep: 22, rem: 21, light: 57),
            SleepArchitectureData(day: "18", deep: 19, rem: 24, light: 57),
            SleepArchitectureData(day: "19", deep: 20, rem: 23, light: 57),
            SleepArchitectureData(day: "20", deep: 17, rem: 26, light: 57),
            SleepArchitectureData(day: "21", deep: 21, rem: 22, light: 57),

            SleepArchitectureData(day: "22", deep: 20, rem: 24, light: 56),
            SleepArchitectureData(day: "23", deep: 18, rem: 23, light: 59),
            SleepArchitectureData(day: "24", deep: 22, rem: 21, light: 57),
            SleepArchitectureData(day: "25", deep: 19, rem: 24, light: 57),
            SleepArchitectureData(day: "26", deep: 21, rem: 22, light: 57),
            SleepArchitectureData(day: "27", deep: 20, rem: 25, light: 55),
            SleepArchitectureData(day: "28", deep: 18, rem: 24, light: 58),

            SleepArchitectureData(day: "29", deep: 21, rem: 23, light: 56),
            SleepArchitectureData(day: "30", deep: 19, rem: 24, light: 57),
            
            SleepArchitectureData(day: "31", deep: 22, rem: 21, light: 51)
        ]
    }
    // MARK: - Average Score
    static func getAverageScore() -> Double {
        let data = getWeeklyArchitecture()
        let total = data.reduce(0) { $0 + $1.score }
        return total / Double(data.count)
    }

    // MARK: - Trend Chart Data (Score Line)
    static func trendChartData(from data: [SleepArchitectureData]) -> (
        title: String,
        dataSets: [LineChartDataSetModel],
        xAxisLabels: [String]
    ) {
        let labels = data.map { $0.day }
        let entries = data.enumerated().map { index, item in
            LineChartDataEntryModel(xIndex: Double(index), value: item.score)
        }

        let dataSet = LineChartDataSetModel(
            label: "Architecture Score",
            values: entries,
            color: .systemTeal
        )

        return (
            title: "Sleep Architecture Score",
            dataSets: [dataSet],
            xAxisLabels: labels
        )
    }

    // MARK: - Fragmentation / Stage Distribution (Bar)
    static func distributionChartData(from data: [SleepArchitectureData]) -> (
        title: String,
        dataSets: [BarChartDataSetModel],
        xAxisLabels: [String]
    ) {
        let labels = data.map { $0.day }

        let deepEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(xIndex: Double(index), value: item.deep)
        }
        let remEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(xIndex: Double(index), value: item.rem)
        }
        let lightEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(xIndex: Double(index), value: item.light)
        }

        let dataSets = [
            BarChartDataSetModel(label: "Deep Sleep", color: .systemBlue, values: deepEntries),
            BarChartDataSetModel(label: "REM Sleep", color: .systemGreen, values: remEntries),
            BarChartDataSetModel(label: "Light Sleep", color: .systemOrange, values: lightEntries)
        ]

        return (
            title: "Sleep Stage Distribution",
            dataSets: dataSets,
            xAxisLabels: labels
        )
    }

    // MARK: - Info Text
    static func architectureInfo() -> String {
        return """
        Sleep architecture shows how your sleep is distributed across stages: Deep, REM, and Light sleep.

        Ideal ranges:
        Deep Sleep: 15–25%
        REM Sleep: 20–25%
        Light Sleep: 50–60%

        Your architecture score measures how closely your sleep matches these optimal ranges.
        Aim for a balanced distribution for better recovery, cognitive function, and overall sleep quality.
        """
    }
}
