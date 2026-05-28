//
//  DurationAnalyzers.swift
//  SetSail
//
//  getData() pulls from HealthKitSleepRepository.
//

import Foundation
import UIKit

final class SleepDurationAnalyzer {

    static func getData(for range: StatsTimeRange) -> [DurationData] {
        let records = HealthKitSleepRepository.shared.records(for: range)
        guard !records.isEmpty else { return noData(for: range) }

        switch range {
        case .week:
            return records.map {
                DurationData(day: weekdayLabel($0.date), hoursSlept: $0.hoursSlept)
            }
        case .month:
            return fourWeeklyAveraged(records).map {
                DurationData(day: $0.label, hoursSlept: $0.values[0])
            }
        case .year:
            return monthlyAveraged(records).map {
                DurationData(day: $0.label, hoursSlept: $0.values[0])
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

    private static func noData(for range: StatsTimeRange) -> [DurationData] {
        []
    }
}

struct AggregatedBucket {
    let label:  String
    let values: [Double]
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

func fourWeeklyAveraged(_ records: [NightRecord],
                        fields: (NightRecord) -> [Double] = { [$0.hoursSlept] }) -> [AggregatedBucket] {
    guard !records.isEmpty else { return [] }

    let cal = Calendar.current
    let sorted = records.sorted { $0.date < $1.date }
    let startDay = cal.startOfDay(for: sorted.first!.date)
    let endDay = cal.startOfDay(for: sorted.last!.date)
    let totalDays = max(1, (cal.dateComponents([.day], from: startDay, to: endDay).day ?? 0) + 1)
    let bucketSize = max(1, Int(ceil(Double(totalDays) / 4.0)))
    let columnCount = max(1, fields(sorted[0]).count)

    var buckets: [[NightRecord]] = Array(repeating: [], count: 4)
    for record in sorted {
        let dayOffset = max(0, cal.dateComponents([.day], from: startDay, to: cal.startOfDay(for: record.date)).day ?? 0)
        let bucketIndex = min(3, dayOffset / bucketSize)
        buckets[bucketIndex].append(record)
    }

    return buckets.enumerated().map { idx, bucket in
        let values = bucket.isEmpty ? Array(repeating: 0, count: columnCount) : average(bucket.map(fields))
        return AggregatedBucket(label: "W\(idx + 1)", values: values)
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
