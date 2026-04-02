//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//
import Foundation
import UIKit

final class SleepDurationAnalyzer {

    static func getData(for range: StatsTimeRange) -> [DurationData] {
        switch range {
        case .week:
            return [
                DurationData(day: "Mon", hoursSlept: 7.5),
                DurationData(day: "Tue", hoursSlept: 6.8),
                DurationData(day: "Wed", hoursSlept: 8.0),
                DurationData(day: "Thu", hoursSlept: 7.2),
                DurationData(day: "Fri", hoursSlept: 6.5),
                DurationData(day: "Sat", hoursSlept: 8.5),
                DurationData(day: "Sun", hoursSlept: 7.8)
            ]
        case .month:
            return [
                DurationData(day: "W1", hoursSlept: 7.1),
                DurationData(day: "W2", hoursSlept: 7.4),
                DurationData(day: "W3", hoursSlept: 6.9),
                DurationData(day: "W4", hoursSlept: 7.6)
            ]
        case .year:
            return zip(StatsTimeRange.year.xAxisLabels,
                       [7.2, 7.0, 7.3, 7.5, 7.6, 7.8, 7.9, 7.7, 7.4, 7.2, 7.1, 7.3]).map {
                DurationData(day: $0.0, hoursSlept: $0.1)
            }
        }
    }

    static func trendChartData(from data: [DurationData]) -> (title: String, dataSets: [LineChartDataSetModel], xAxisLabels: [String]) {
        let labels  = data.map { $0.day }
        let entries = data.enumerated().map {
            LineChartDataEntryModel(xIndex: Double($0.offset),
                                   value: SleepScoreCalculator.durationScore(hoursSlept: $0.element.hoursSlept))
        }
        return (
            title: "Duration Score Trend",
            dataSets: [LineChartDataSetModel(label: "Duration Score", values: entries)],
            xAxisLabels: labels
        )
    }

    static func durationBarChartData(from data: [DurationData]) -> (title: String, dataSets: [BarChartDataSetModel], xAxisLabels: [String]) {
        let labels  = data.map { $0.day }
        let entries = data.enumerated().map {
            BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.hoursSlept)
        }
        return (
            title: "Nightly Sleep Duration (hrs)",
            dataSets: [BarChartDataSetModel(label: "Hours Slept",values: entries)],
            xAxisLabels: labels
        )
    }

    static func durationInfo() -> String {
        """
        This shows if you got enough sleep.

        Most people feel their best with around 7 to 9 hours of sleep.
        Too little or too much sleep can leave you feeling tired the next day.
        """
    }
}
