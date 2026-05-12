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
            return fourWeeklyAveraged(records, fields: { [$0.restingHR, $0.hrv, $0.movementIndex] }).map {
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

    static func componentBreakdownChartData(from data: [CalmnessData],
                                             rhrMin: Double = 40, rhrMax: Double = 100,
                                             hrvMin: Double = 20, hrvMax: Double = 80)
        -> (title: String, dataSets: [BarChartDataSetModel], xAxisLabels: [String]) {

        let labels = data.map { $0.day }

        let sRHR = data.enumerated().map { idx, d in
            BarChartDataEntryModel(xIndex: Double(idx),
                                   value: max(0, min(100, 100 * (rhrMax - d.restingHeartRate) / (rhrMax - rhrMin))))
        }
        let sHRV = data.enumerated().map { idx, d in
            BarChartDataEntryModel(xIndex: Double(idx),
                                   value: max(0, min(100, 100 * (d.hrv - hrvMin) / (hrvMax - hrvMin))))
        }
        let sMovement = data.enumerated().map { idx, d in
            BarChartDataEntryModel(xIndex: Double(idx),
                                   value: max(0, min(100, 100 * (1 - d.movementIndex))))
        }

        return (
            title: "Calmness Components (0–100)",
            dataSets: [
                BarChartDataSetModel(label: "sHRV (40%)",      values: sHRV),
                BarChartDataSetModel(label: "sRHR (40%)",      values: sRHR),
                BarChartDataSetModel(label: "sMovement (20%)", values: sMovement)
            ],
            xAxisLabels: labels
        )
    }

    static func calmnessInfo() -> String {
        """
        This reflects how calm and relaxed your body was during sleep.

        The score combines three signals:
        • HRV (40%) — higher heart-rate variability means your nervous system was more relaxed.
        • Resting HR (40%) — a lower heart rate during sleep signals deeper rest.
        • Movement (20%) — less physical restlessness means more restorative sleep.

        Each signal is normalised to 0–100 before being blended, so no single reading \
        dominates unfairly.
        """
    }

    private static func noData(for range: StatsTimeRange) -> [CalmnessData] {
        []
    }
}
