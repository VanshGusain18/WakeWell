//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//
import Foundation
import UIKit

final class SleepCalmnessAnalyzer {

    static func getData(for range: StatsTimeRange) -> [CalmnessData] {
        switch range {
        case .week:
            return [
                CalmnessData(day: "Mon", restingHeartRate: 62, hrv: 38, movementIndex: 0.30),
                CalmnessData(day: "Tue", restingHeartRate: 60, hrv: 42, movementIndex: 0.22),
                CalmnessData(day: "Wed", restingHeartRate: 58, hrv: 48, movementIndex: 0.15),
                CalmnessData(day: "Thu", restingHeartRate: 57, hrv: 50, movementIndex: 0.12),
                CalmnessData(day: "Fri", restingHeartRate: 61, hrv: 40, movementIndex: 0.25),
                CalmnessData(day: "Sat", restingHeartRate: 59, hrv: 45, movementIndex: 0.18),
                CalmnessData(day: "Sun", restingHeartRate: 58, hrv: 47, movementIndex: 0.14)
            ]
        case .month:
            return [
                CalmnessData(day: "W1", restingHeartRate: 61, hrv: 41, movementIndex: 0.24),
                CalmnessData(day: "W2", restingHeartRate: 59, hrv: 44, movementIndex: 0.19),
                CalmnessData(day: "W3", restingHeartRate: 60, hrv: 43, movementIndex: 0.21),
                CalmnessData(day: "W4", restingHeartRate: 58, hrv: 47, movementIndex: 0.16)
            ]
        case .year:
            return zip(StatsTimeRange.year.xAxisLabels,
                       [(63,37,0.32),(62,38,0.30),(61,40,0.27),(60,42,0.24),
                        (59,44,0.21),(58,46,0.18),(57,48,0.15),(58,46,0.17),
                        (59,44,0.20),(60,42,0.23),(61,40,0.26),(62,38,0.29)]).map {
                CalmnessData(day: $0.0,
                             restingHeartRate: Double($0.1.0),
                             hrv: Double($0.1.1),
                             movementIndex: $0.1.2)
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
        let labels  = data.map { $0.day }
        let hrv     = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.hrv) }
        let rhr     = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.restingHeartRate) }
        return (
            title: "HRV & Resting Heart Rate",
            dataSets: [
                BarChartDataSetModel(label: "HRV (ms)", values: hrv),
                BarChartDataSetModel(label: "RHR (bpm)", values: rhr)
            ],
            xAxisLabels: labels
        )
    }

    static func calmnessInfo() -> String {
        """
        Calmness score is weighted across three sub-metrics:
        HRV (40%) — higher HRV = better recovery
        Resting Heart Rate (40%) — lower RHR = calmer sleep
        Movement Index (20%) — lower movement = more restful sleep
        """
    }
}
