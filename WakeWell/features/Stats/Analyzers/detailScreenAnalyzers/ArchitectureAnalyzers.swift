//
//  ArchitectureAnalyzers.swift
//  WakeWell
//

import Foundation
import UIKit

final class SleepArchitectureAnalyzer {

    static func getData(for range: StatsTimeRange) -> [SleepArchitectureData] {
        let records = HealthKitSleepRepository.shared.records(for: range)
        guard !records.isEmpty else { return fallback(for: range) }

        func toPct(_ record: NightRecord) -> (deep: Double, rem: Double, light: Double) {
            let total = record.deepHours + record.remHours + record.lightHours
            guard total > 0 else { return (20, 22, 58) }
            return (
                deep:  (record.deepHours  / total) * 100,
                rem:   (record.remHours   / total) * 100,
                light: (record.lightHours / total) * 100
            )
        }

        switch range {
        case .week:
            return records.map {
                let p = toPct($0)
                return SleepArchitectureData(day: weekdayLabel($0.date),
                                             deep: p.deep, rem: p.rem, light: p.light)
            }
        case .month:
            return weeklyAveraged(records, fields: {
                let p = toPct($0); return [p.deep, p.rem, p.light]
            }).map {
                SleepArchitectureData(day: $0.label,
                                      deep: $0.values[0], rem: $0.values[1], light: $0.values[2])
            }
        case .year:
            return monthlyAveraged(records, fields: {
                let p = toPct($0); return [p.deep, p.rem, p.light]
            }).map {
                SleepArchitectureData(day: $0.label,
                                      deep: $0.values[0], rem: $0.values[1], light: $0.values[2])
            }
        }
    }

    static func getAverageScore(for range: StatsTimeRange) -> Double {
        let data = getData(for: range)
        guard !data.isEmpty else { return 0 }
        return data.reduce(0.0) {
            $0 + SleepScoreCalculator.architectureScore(deep: $1.deep, rem: $1.rem, light: $1.light)
        } / Double(data.count)
    }

    static func trendChartData(from data: [SleepArchitectureData]) -> (title: String, dataSets: [LineChartDataSetModel], xAxisLabels: [String]) {
        let labels  = data.map { $0.day }
        let entries = data.enumerated().map {
            LineChartDataEntryModel(xIndex: Double($0.offset),
                                   value: SleepScoreCalculator.architectureScore(deep: $0.element.deep,
                                                                                  rem: $0.element.rem,
                                                                                  light: $0.element.light))
        }
        return (
            title: "Architecture Score Trend",
            dataSets: [LineChartDataSetModel(label: "Architecture Score", values: entries)],
            xAxisLabels: labels
        )
    }

    static func distributionChartData(from data: [SleepArchitectureData]) -> (title: String, dataSets: [BarChartDataSetModel], xAxisLabels: [String]) {
        let labels = data.map { $0.day }
        let deep   = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.deep) }
        let rem    = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.rem) }
        let light  = data.enumerated().map { BarChartDataEntryModel(xIndex: Double($0.offset), value: $0.element.light) }
        return (
            title: "Sleep Stage Distribution (%)",
            dataSets: [
                BarChartDataSetModel(label: "Deep",  values: deep),
                BarChartDataSetModel(label: "REM",   values: rem),
                BarChartDataSetModel(label: "Light",  values: light)
            ],
            xAxisLabels: labels
        )
    }

    static func architectureInfo() -> String {
        """
        This shows how balanced your sleep was.

        A good night of sleep includes the right mix of deep, light, and dream (REM) sleep.
        The closer your sleep matches this balance, the better you recover and feel the next day.
        """
    }

    private static func fallback(for range: StatsTimeRange) -> [SleepArchitectureData] {
        switch range {
        case .week:
            return [
                SleepArchitectureData(day: "Mon", deep: 18.0, rem: 20.0, light: 62.0),
                SleepArchitectureData(day: "Tue", deep: 16.0, rem: 19.0, light: 65.0),
                SleepArchitectureData(day: "Wed", deep: 21.0, rem: 23.0, light: 56.0),
                SleepArchitectureData(day: "Thu", deep: 19.0, rem: 21.0, light: 60.0),
                SleepArchitectureData(day: "Fri", deep: 15.0, rem: 18.0, light: 67.0),
                SleepArchitectureData(day: "Sat", deep: 22.0, rem: 24.0, light: 54.0),
                SleepArchitectureData(day: "Sun", deep: 20.0, rem: 22.0, light: 58.0)
            ]
        case .month:
            return [
                SleepArchitectureData(day: "W1", deep: 18.0, rem: 20.0, light: 62.0),
                SleepArchitectureData(day: "W2", deep: 19.5, rem: 21.5, light: 59.0),
                SleepArchitectureData(day: "W3", deep: 17.0, rem: 19.0, light: 64.0),
                SleepArchitectureData(day: "W4", deep: 20.5, rem: 22.5, light: 57.0)
            ]
        case .year:
            return zip(StatsTimeRange.year.xAxisLabels,
                       [(18,20,62),(17,19,64),(19,21,60),(20,22,58),
                        (21,23,56),(22,24,54),(22,24,54),(21,23,56),
                        (20,22,58),(19,21,60),(18,20,62),(18,20,62)]).map {
                SleepArchitectureData(day: $0.0, deep: Double($0.1.0),
                                      rem: Double($0.1.1), light: Double($0.1.2))
            }
        }
    }
}
