//
//  DurationAnalyzers.swift
//  WakeWell
//
//  getData() now pulls from HealthKitSleepRepository.
//  Hardcoded arrays are kept as fallback when no HealthKit data exists yet.
//

import Foundation
import UIKit

final class SleepDurationAnalyzer {

    static func getData(for range: StatsTimeRange) -> [DurationData] {
        let records = HealthKitSleepRepository.shared.records(for: range)
        guard !records.isEmpty else { return fallback(for: range) }

        switch range {
        case .week:
            return records.map {
                DurationData(day: weekdayLabel($0.date), hoursSlept: $0.hoursSlept)
            }
        case .month:
            return weeklyAveraged(records).map {
                DurationData(day: $0.label, hoursSlept: $0.values[0])
            }
        case .year:
            return monthlyAveraged(records).map {
                DurationData(day: $0.label, hoursSlept: $0.values[0])
            }
        }
    }

    // MARK: - Chart builders (unchanged)

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
            dataSets: [BarChartDataSetModel(label: "Hours Slept", values: entries)],
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

    // MARK: - Fallback (original hardcoded data)

    private static func fallback(for range: StatsTimeRange) -> [DurationData] {
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
}

// MARK: - Shared aggregation helpers (used by all analyzers)

// Returns one bucket per week with averaged values
struct AggregatedBucket {
    let label:  String
    let values: [Double]   // index matches caller's fields
}

func weeklyAveraged(_ records: [NightRecord],
                    fields: (NightRecord) -> [Double] = { [$0.hoursSlept] }) -> [AggregatedBucket] {
    guard !records.isEmpty else { return [] }
    let cal     = Calendar.current
    var buckets: [Int: [NightRecord]] = [:]
    for r in records {
        let week = cal.component(.weekOfYear, from: r.date)
        buckets[week, default: []].append(r)
    }
    return buckets.sorted { $0.key < $1.key }.enumerated().map { idx, pair in
        let avg = average(pair.value.map(fields))
        return AggregatedBucket(label: "W\(idx + 1)", values: avg)
    }
}

func monthlyAveraged(_ records: [NightRecord],
                     fields: (NightRecord) -> [Double] = { [$0.hoursSlept] }) -> [AggregatedBucket] {
    guard !records.isEmpty else { return [] }
    let cal     = Calendar.current
    let fmt     = DateFormatter()
    fmt.dateFormat = "MMM"
    var buckets: [Int: [NightRecord]] = [:]
    for r in records {
        let month = cal.component(.month, from: r.date)
        buckets[month, default: []].append(r)
    }
    return buckets.sorted { $0.key < $1.key }.map { _, records in
        let label = fmt.string(from: records[0].date)
        let avg   = average(records.map(fields))
        return AggregatedBucket(label: label, values: avg)
    }
}

// Averages an array-of-arrays column-wise
private func average(_ matrix: [[Double]]) -> [Double] {
    guard let cols = matrix.first?.count, cols > 0 else { return [] }
    return (0..<cols).map { col in
        matrix.map { $0[col] }.reduce(0, +) / Double(matrix.count)
    }
}

func weekdayLabel(_ date: Date) -> String {
    let fmt = DateFormatter()
    fmt.dateFormat = "EEE"
    return fmt.string(from: date)
}
