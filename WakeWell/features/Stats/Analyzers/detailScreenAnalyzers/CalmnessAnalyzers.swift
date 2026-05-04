//
//  CalmnessAnalyzers.swift
//  WakeWell
//

import Foundation
import UIKit

final class SleepCalmnessAnalyzer {

    static func getData(for range: StatsTimeRange) -> [CalmnessData] {
        let records = HealthKitSleepRepository.shared.records(for: range).filter {
            $0.restingHR > 0 && $0.hrv > 0
        }
        guard !records.isEmpty else { return noData(for: range) }

        switch range {
        case .week:
            return records.map {
                CalmnessData(day: weekdayLabel($0.date),
                             restingHeartRate: $0.restingHR,
                             hrv:              $0.hrv,
                             movementIndex:    $0.movementIndex)
            }
        case .month:
            return weeklyAveraged(records, fields: { [$0.restingHR, $0.hrv, $0.movementIndex] }).map {
                CalmnessData(day: $0.label,
                             restingHeartRate: $0.values[0],
                             hrv:              $0.values[1],
                             movementIndex:    $0.values[2])
            }
        case .year:
            return monthlyAveraged(records, fields: { [$0.restingHR, $0.hrv, $0.movementIndex] }).map {
                CalmnessData(day: $0.label,
                             restingHeartRate: $0.values[0],
                             hrv:              $0.values[1],
                             movementIndex:    $0.values[2])
            }
        }
    }

    static func trendChartData(from data: [CalmnessData]) -> (title: String, dataSets: [LineChartDataSetModel], xAxisLabels: [String]) {
        let labels  = data.map { $0.day }
        let entries = data.enumerated().map {
            LineChartDataEntryModel(xIndex: Double($0.offset),
                                   value: SleepScoreCalculator.calmnessScore(rhr: $0.element.restingHeartRate,
                                                                              hrv: $0.element.hrv,
                                                                              movementIndex: $0.element.movementIndex))
        }
        return (
            title: "Calmness Score Trend",
            dataSets: [LineChartDataSetModel(label: "Calmness Score", values: entries)],
            xAxisLabels: labels
        )
    }

    static func movementChartData(from data: [CalmnessData]) -> (title: String, dataSets: [BarChartDataSetModel], xAxisLabels: [String]) {
        let labels = data.map { $0.day }
        let hrv    = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.hrv) }
        let rhr    = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.restingHeartRate) }
        return (
            title: "HRV & Resting Heart Rate",
            dataSets: [
                BarChartDataSetModel(label: "HRV (ms)",  values: hrv),
                BarChartDataSetModel(label: "RHR (bpm)", values: rhr)
            ],
            xAxisLabels: labels
        )
    }

    static func calmnessInfo() -> String {
        """
        This reflects how calm and relaxed your body was during sleep.

        A calm night means your heart stayed steady and your body wasn't too active.
        The more relaxed you are, the better your body can recover overnight.
        """
    }

    private static func noData(for range: StatsTimeRange) -> [CalmnessData] {
        []
    }
}
