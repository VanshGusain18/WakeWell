//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//


import Foundation
import UIKit

// MARK: - Analyzer
class SleepDurationAnalyzer {

    // MARK: - Weekly Raw Data
    static func getWeeklyDuration() -> [DurationData] {
        return [
            DurationData(day: "Mon", hoursSlept: 6.5),
            DurationData(day: "Tue", hoursSlept: 7.2),
            DurationData(day: "Wed", hoursSlept: 8.0),
            DurationData(day: "Thu", hoursSlept: 9.0),
            DurationData(day: "Fri", hoursSlept: 5.5),
            DurationData(day: "Sat", hoursSlept: 7.8),
            DurationData(day: "Sun", hoursSlept: 8.5)
        ]
    }

    // MARK: - Score Logic
    static func calculateDurationScore(hours: Double) -> Double {
        switch hours {
        case 7...9:
            return 100
        case 6..<7, 9..<10:
            return 80
        case ..<6, 10...:
            return 50
        default:
            return 0
        }
    }

    // MARK: - Average Score
    static func getAverageScore() -> Double {
        let data = getWeeklyDuration()
        let total = data.reduce(0) { $0 + $1.score }
        return total / Double(data.count)
    }

    // MARK: - 📈 TREND DATA (Score Line Chart)
    static func trendChartData(from data: [DurationData]) -> (
        title: String,
        dataSets: [LineChartDataSetModel],
        xAxisLabels: [String]
    ) {
        let labels = data.map { $0.day }
        let entries = data.enumerated().map { index, item in
            LineChartDataEntryModel(xIndex: Double(index), value: item.score)
        }

        let dataSet = LineChartDataSetModel(
            label: "Duration Score",
            values: entries,
            color: .systemBlue
        )

        return (title: "Sleep Duration Trend", dataSets: [dataSet], xAxisLabels: labels)
    }

    // MARK: - 📊 BAR CHART DATA (Hours Slept)
    static func durationBarChartData(from data: [DurationData]) -> (
        title: String,
        dataSets: [BarChartDataSetModel],
        xAxisLabels: [String]
    ) {
        let labels = data.map { $0.day }
        let entries = data.enumerated().map { index, item in
            BarChartDataEntryModel(xIndex: Double(index), value: item.hoursSlept)
        }

        let dataSet = BarChartDataSetModel(
            label: "Hours Slept",
            color: .systemGreen,
            values: entries
        )

        return (title: "Sleep Duration", dataSets: [dataSet], xAxisLabels: labels)
    }

    // MARK: - Info Section
    static func durationInfo() -> String {
        return """
        Recommended sleep duration for adults is 7–9 hours per night.

        Sleep less than 7 hours or more than 10 hours can affect recovery, cognitive performance, and overall health.

        Your duration score indicates how close your nightly sleep is to the optimal range.
        """
    }
}
