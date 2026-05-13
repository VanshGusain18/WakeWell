//
//  EfficiencyAnalyzers.swift
//  WakeWell
//

import Foundation
import UIKit

final class EfficiencyAnalyzer {

    static func getData(for range: StatsTimeRange) -> [EfficiencyData] {
        let records = HealthKitSleepRepository.shared.records(for: range)
        guard !records.isEmpty else { return noData(for: range) }

        switch range {
        case .week:
            return records.map {
                EfficiencyData(day: weekdayLabel($0.date),
                               timeInBed: $0.timeInBed,
                               timeAsleep: $0.hoursSlept)
            }
        case .month:
            return fourWeeklyAveraged(records, fields: { [$0.timeInBed, $0.hoursSlept] }).map {
                EfficiencyData(day: $0.label, timeInBed: $0.values[0], timeAsleep: $0.values[1])
            }
        case .year:
            return monthlyAveraged(records, fields: { [$0.timeInBed, $0.hoursSlept] }).map {
                EfficiencyData(day: $0.label, timeInBed: $0.values[0], timeAsleep: $0.values[1])
            }
        }
    }

    static func trendChartData(from data: [EfficiencyData]) -> (title: String, dataSets: [LineChartDataSetModel], xAxisLabels: [String]) {
        let labels  = data.map { $0.day }
        let entries = data.enumerated().map {
            LineChartDataEntryModel(xIndex: Double($0.offset),
                                   value: SleepScoreCalculator.efficiencyScore(timeInBed: $0.element.timeInBed,
                                                                                timeAsleep: $0.element.timeAsleep))
        }
        return (
            title: "Efficiency Score Trend",
            dataSets: [LineChartDataSetModel(label: "Efficiency Score", values: entries)],
            xAxisLabels: labels
        )
    }

    static func breakdownChartData(from data: [EfficiencyData]) -> (title: String, dataSets: [BarChartDataSetModel], xAxisLabels: [String]) {
        let labels = data.map { $0.day }
        let inBed  = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.timeInBed) }
        let asleep = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.timeAsleep) }
        return (
            title: "Time in Bed vs Asleep (hrs)",
            dataSets: [
                BarChartDataSetModel(label: "In Bed",  values: inBed),
                BarChartDataSetModel(label: "Asleep",  values: asleep)
            ],
            xAxisLabels: labels
        )
    }

    static func efficiencyInfo() -> String {
        """
        This tells you how much of your time in bed was actually spent sleeping.

        The higher this is, the better.
        Falling asleep quickly and staying asleep means your body is using your sleep time well.
        """
    }

    private static func noData(for range: StatsTimeRange) -> [EfficiencyData] {
        []
    }
}
