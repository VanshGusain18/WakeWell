//
//  EfficiencyAnalyzers.swift
//  WakeWell
//

import Foundation
import UIKit

final class EfficiencyAnalyzer {

    static func getData(for range: StatsTimeRange) -> [EfficiencyData] {
        let records = HealthKitSleepRepository.shared.records(for: range)
        guard !records.isEmpty else { return fallback(for: range) }

        switch range {
        case .week:
            return records.map {
                EfficiencyData(day: weekdayLabel($0.date),
                               timeInBed: $0.timeInBed,
                               timeAsleep: $0.hoursSlept)
            }
        case .month:
            return weeklyAveraged(records, fields: { [$0.timeInBed, $0.hoursSlept] }).map {
                EfficiencyData(day: $0.label, timeInBed: $0.values[0], timeAsleep: $0.values[1])
            }
        case .year:
            return monthlyAveraged(records, fields: { [$0.timeInBed, $0.hoursSlept] }).map {
                EfficiencyData(day: $0.label, timeInBed: $0.values[0], timeAsleep: $0.values[1])
            }
        }
    }

    // MARK: - Chart builders (unchanged)

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

    // MARK: - Fallback

    private static func fallback(for range: StatsTimeRange) -> [EfficiencyData] {
        switch range {
        case .week:
            return [
                EfficiencyData(day: "Mon", timeInBed: 9.0, timeAsleep: 8.0),
                EfficiencyData(day: "Tue", timeInBed: 8.5, timeAsleep: 7.5),
                EfficiencyData(day: "Wed", timeInBed: 8.0, timeAsleep: 7.0),
                EfficiencyData(day: "Thu", timeInBed: 9.0, timeAsleep: 8.0),
                EfficiencyData(day: "Fri", timeInBed: 8.0, timeAsleep: 7.5),
                EfficiencyData(day: "Sat", timeInBed: 9.5, timeAsleep: 8.5),
                EfficiencyData(day: "Sun", timeInBed: 8.5, timeAsleep: 7.8)
            ]
        case .month:
            return [
                EfficiencyData(day: "W1", timeInBed: 8.8, timeAsleep: 7.8),
                EfficiencyData(day: "W2", timeInBed: 8.5, timeAsleep: 7.6),
                EfficiencyData(day: "W3", timeInBed: 8.2, timeAsleep: 7.2),
                EfficiencyData(day: "W4", timeInBed: 8.7, timeAsleep: 7.9)
            ]
        case .year:
            return zip(StatsTimeRange.year.xAxisLabels,
                       [(8.5,7.7),(8.3,7.4),(8.6,7.8),(8.4,7.6),
                        (8.2,7.5),(8.0,7.3),(8.3,7.6),(8.5,7.8),
                        (8.6,7.9),(8.4,7.5),(8.3,7.4),(8.5,7.7)]).map {
                EfficiencyData(day: $0.0, timeInBed: $0.1.0, timeAsleep: $0.1.1)
            }
        }
    }
}
