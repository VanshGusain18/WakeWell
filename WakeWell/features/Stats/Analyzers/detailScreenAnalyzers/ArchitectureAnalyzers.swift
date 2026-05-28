//
//  ArchitectureAnalyzers.swift
//  SetSail
//

import Foundation
import UIKit

final class SleepArchitectureAnalyzer {

    static func getData(for range: StatsTimeRange) -> [SleepArchitectureData] {
        let records = HealthKitSleepRepository.shared.records(for: range)
        guard !records.isEmpty else { return noData(for: range) }

        func toPct(_ record: NightRecord) -> (deep: Double, rem: Double, light: Double)? {
            let total = record.deepHours + record.remHours + record.lightHours
            guard total > 0 else { return nil }
            return (
                deep:  (record.deepHours  / total) * 100,
                rem:   (record.remHours   / total) * 100,
                light: (record.lightHours / total) * 100
            )
        }

        switch range {
        case .week:
            return records.compactMap {
                guard let p = toPct($0) else { return nil }
                return SleepArchitectureData(day: weekdayLabel($0.date),
                                             deep: p.deep, rem: p.rem, light: p.light)
            }
        case .month:
            let validRecords = records.filter { toPct($0) != nil }
            return fourWeeklyAveraged(validRecords, fields: {
                guard let p = toPct($0) else { return [] }
                return [p.deep, p.rem, p.light]
            }).map {
                SleepArchitectureData(day: $0.label,
                                      deep: $0.values[0], rem: $0.values[1], light: $0.values[2])
            }
        case .year:
            let validRecords = records.filter { toPct($0) != nil }
            return monthlyAveraged(validRecords, fields: {
                guard let p = toPct($0) else { return [] }
                return [p.deep, p.rem, p.light]
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
        This shows how balanced your sleep stages were throughout the night.

        A healthy night includes around 15–25% deep sleep, 20–25% REM, and 50–60% light sleep. \
        Deep sleep matters most for physical recovery, REM for memory and mood, \
        and light sleep bridges the two.

        Your score is penalised more for missing deep sleep (weight 1.5×) than REM (1.2×) \
        or light sleep (1.0×), reflecting their relative importance to overnight recovery.
        """
    }

    private static func noData(for range: StatsTimeRange) -> [SleepArchitectureData] {
        []
    }
}
