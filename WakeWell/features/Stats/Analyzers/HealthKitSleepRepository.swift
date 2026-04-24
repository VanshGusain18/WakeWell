//
//  HealthKitSleepRepository.swift
//  WakeWell
//
//  Central HealthKit data layer.
//  All analyzers call this instead of returning hardcoded arrays.
//  Data is cached per range so HealthKit is queried only once per session.
//

import Foundation
import HealthKit

// MARK: - Raw HealthKit sleep sample

struct RawSleepSample {
    let startDate: Date
    let endDate:   Date
    let stage:     HKCategoryValueSleepAnalysis   // inBed, asleepREM, asleepCore, asleepDeep, awake
    var duration:  TimeInterval { endDate.timeIntervalSince(startDate) }
}

// MARK: - Aggregated night record (one row per night)

struct NightRecord {
    let date:            Date       // calendar date of the night (wake-up day)
    let hoursSlept:      Double     // total asleep hours
    let timeInBed:       Double     // total in-bed hours
    let deepHours:       Double
    let remHours:        Double
    let lightHours:      Double
    let awakenings:      Int
    let totalAwakeMin:   Double     // minutes awake after sleep onset
    let restingHR:       Double     // average RHR that night (0 if unavailable)
    let hrv:             Double     // average HRV that night (0 if unavailable)
    let movementIndex:   Double     // placeholder; 0.2 default until motion data added
    let bedtime:         Double     // hour of day as decimal (e.g. 23.5 = 11:30 PM)
    let wakeTime:        Double     // hour of day as decimal (e.g. 7.25 = 7:15 AM)
}

// MARK: - Repository

final class HealthKitSleepRepository {

    static let shared = HealthKitSleepRepository()
    private init() {}

    private let store = HKHealthStore()

    // Simple in-memory cache keyed by range raw value
    private var cache: [String: [NightRecord]] = [:]

    // MARK: - Public API

    /// Returns cached records synchronously if available, otherwise fetches async.
    /// Callers that need data synchronously should call `prefetch(for:)` once on app launch.
    func records(for range: StatsTimeRange) -> [NightRecord] {
        return cache[range.cacheKey] ?? []
    }

    /// Async prefetch — call this when the user opens the stats screen.
    func prefetch(for range: StatsTimeRange, completion: @escaping () -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { completion(); return }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let hrType    = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let hrvType   = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!

        store.requestAuthorization(toShare: nil, read: [sleepType, hrType, hrvType]) { [weak self] granted, _ in
            guard granted, let self else { completion(); return }
            self.fetchSleep(for: range) { records in
                self.cache[range.cacheKey] = records
                DispatchQueue.main.async { completion() }
            }
        }
    }

    private func fetchSleep(for range: StatsTimeRange, completion: @escaping ([NightRecord]) -> Void) {
        let interval   = range.dateInterval
        let predicate  = HKQuery.predicateForSamples(withStart: interval.start,
                                                      end: interval.end,
                                                      options: .strictStartDate)
        let sleepType  = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sortDesc   = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sortDesc]) { [weak self] _, samples, _ in
            guard let self, let samples = samples as? [HKCategorySample] else {
                completion([]); return
            }

            let raw = samples.map {
                RawSleepSample(
                    startDate: $0.startDate,
                    endDate:   $0.endDate,
                    stage:     HKCategoryValueSleepAnalysis(rawValue: $0.value) ?? .inBed
                )
            }
            let nights = self.groupIntoNights(raw)
            self.enrichWithHeartData(nights: nights, interval: interval) { records in
                completion(records)
            }
        }
        store.execute(query)
    }

    private func groupIntoNights(_ samples: [RawSleepSample]) -> [[RawSleepSample]] {
        var buckets: [String: [RawSleepSample]] = [:]
        let cal = Calendar.current

        for s in samples {
            let anchor = cal.date(byAdding: .hour, value: -12, to: s.endDate) ?? s.endDate
            let key    = DateFormatter.yyyyMMdd.string(from: anchor)
            buckets[key, default: []].append(s)
        }
        return buckets.values.sorted { a, b in
            (a.first?.startDate ?? .distantPast) < (b.first?.startDate ?? .distantPast)
        }
    }

    private func enrichWithHeartData(nights: [[RawSleepSample]],
                                      interval: DateInterval,
                                      completion: @escaping ([NightRecord]) -> Void) {
        guard !nights.isEmpty else { completion([]); return }

        let group   = DispatchGroup()
        var records = [NightRecord?](repeating: nil, count: nights.count)

        for (idx, bucket) in nights.enumerated() {
            group.enter()
            buildRecord(from: bucket, index: idx) { record in
                records[idx] = record
                group.leave()
            }
        }

        group.notify(queue: .global()) {
            completion(records.compactMap { $0 })
        }
    }

    private func buildRecord(from bucket: [RawSleepSample],
                              index: Int,
                              completion: @escaping (NightRecord?) -> Void) {
        guard !bucket.isEmpty else { completion(nil); return }

        let cal      = Calendar.current
        let wakeDate = bucket.map { $0.endDate }.max() ?? bucket[0].endDate
        let asleepStages: [HKCategoryValueSleepAnalysis] = [.asleepREM, .asleepCore, .asleepDeep, .asleepUnspecified]
        let totalAsleep  = bucket.filter { asleepStages.contains($0.stage) }.reduce(0) { $0 + $1.duration }
        let totalInBed   = bucket.filter { $0.stage == .inBed || asleepStages.contains($0.stage) }.reduce(0) { $0 + $1.duration }
        let deepSecs     = bucket.filter { $0.stage == .asleepDeep }.reduce(0) { $0 + $1.duration }
        let remSecs      = bucket.filter { $0.stage == .asleepREM  }.reduce(0) { $0 + $1.duration }
        let lightSecs    = bucket.filter { $0.stage == .asleepCore || $0.stage == .asleepUnspecified }.reduce(0) { $0 + $1.duration }
        let awakeSecs    = bucket.filter { $0.stage == .awake }.reduce(0) { $0 + $1.duration }
        let awakenings   = bucket.filter { $0.stage == .awake }.count

        let hoursSlept   = totalAsleep / 3600
        let timeInBed    = max(totalInBed, totalAsleep) / 3600

        let deepPct  = totalAsleep > 0 ? (deepSecs  / totalAsleep) * 100 : 0
        let remPct   = totalAsleep > 0 ? (remSecs   / totalAsleep) * 100 : 0
        let lightPct = totalAsleep > 0 ? (lightSecs / totalAsleep) * 100 : max(0, 100 - deepPct - remPct)

        let sleepOnset   = bucket.filter { asleepStages.contains($0.stage) }.map { $0.startDate }.min() ?? bucket[0].startDate
        let bedComponents = cal.dateComponents([.hour, .minute], from: sleepOnset)
        var bedDecimal    = Double(bedComponents.hour ?? 23) + Double(bedComponents.minute ?? 0) / 60.0
        if bedDecimal < 12 { bedDecimal += 24 }   // treat early-morning times as "past midnight"

        let wakeComponents = cal.dateComponents([.hour, .minute], from: wakeDate)
        let wakeDecimal    = Double(wakeComponents.hour ?? 7) + Double(wakeComponents.minute ?? 0) / 60.0

        let start = bucket.map { $0.startDate }.min() ?? wakeDate
        let end   = wakeDate

        fetchHeartStats(from: start, to: end) { rhr, hrv in
            let record = NightRecord(
                date:          wakeDate,
                hoursSlept:    hoursSlept,
                timeInBed:     timeInBed,
                deepHours:     deepSecs / 3600,
                remHours:      remSecs  / 3600,
                lightHours:    lightSecs / 3600,
                awakenings:    awakenings,
                totalAwakeMin: awakeSecs / 60,
                restingHR:     rhr,
                hrv:           hrv,
                movementIndex: 0.20,
                bedtime:       bedDecimal,
                wakeTime:      wakeDecimal
            )
            completion(record)
        }
    }

    private func fetchHeartStats(from start: Date, to end: Date,
                                  completion: @escaping (_ rhr: Double, _ hrv: Double) -> Void) {
        let group    = DispatchGroup()
        var rhr: Double = 0
        var hrv: Double = 0

        group.enter()
        fetchAverage(typeID: .heartRate, from: start, to: end, unit: HKUnit.count().unitDivided(by: .minute())) { val in
            rhr = val; group.leave()
        }

        group.enter()
        fetchAverage(typeID: .heartRateVariabilitySDNN, from: start, to: end, unit: .secondUnit(with: .milli)) { val in
            hrv = val; group.leave()
        }

        group.notify(queue: .global()) { completion(rhr, hrv) }
    }

    private func fetchAverage(typeID: HKQuantityTypeIdentifier,
                               from: Date, to: Date,
                               unit: HKUnit,
                               completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: typeID) else {
            completion(0); return
        }
        let pred  = HKQuery.predicateForSamples(withStart: from, end: to)
        let query = HKStatisticsQuery(quantityType: type,
                                      quantitySamplePredicate: pred,
                                      options: .discreteAverage) { _, stats, _ in
            let value = stats?.averageQuantity()?.doubleValue(for: unit) ?? 0
            completion(value)
        }
        store.execute(query)
    }
}

extension StatsTimeRange {
    var cacheKey: String { title }

    var dateInterval: DateInterval {
        let now = Date()
        let cal = Calendar.current
        switch self {
        case .week:
            let start = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: now))!
            return DateInterval(start: start, end: now)
        case .month:
            let start = cal.date(byAdding: .day, value: -29, to: cal.startOfDay(for: now))!
            return DateInterval(start: start, end: now)
        case .year:
            let start = cal.date(byAdding: .month, value: -11, to: cal.startOfDay(for: now))!
            return DateInterval(start: start, end: now)
        }
    }
}

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
