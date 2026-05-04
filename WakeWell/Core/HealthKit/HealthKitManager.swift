import Foundation
import HealthKit

final class HealthKitManager {

    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
    private let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
    private let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    private let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        guard let heartRateType,
              let hrvType else {
            completion(false)
            return
        }

        var readTypes: Set<HKObjectType> = [
            sleepType,
            heartRateType,
            hrvType
        ]
        if let activeEnergyType {
            readTypes.insert(activeEnergyType)
        }
        if let stepCountType {
            readTypes.insert(stepCountType)
        }

        let shareTypes: Set<HKSampleType> = [
            sleepType
        ]

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            print("iPhone HealthKit auth:", success, error?.localizedDescription ?? "")
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    func fetchLatestHeartRate(completion: @escaping (Double?) -> Void) {
        guard let heartRateType else {
            completion(nil)
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, _ in
            let value = (samples?.first as? HKQuantitySample)?
                .quantity
                .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))

            if let value {
                print("❤️ Live HR: \(String(format: "%.2f", value))")
            }

            DispatchQueue.main.async {
                completion(value)
            }
        }

        healthStore.execute(query)
    }

    func fetchLatestHRV(completion: @escaping (Double?) -> Void) {
        guard let hrvType else {
            completion(nil)
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, _ in
            let value = (samples?.first as? HKQuantitySample)?
                .quantity
                .doubleValue(for: HKUnit.secondUnit(with: .milli))

            if let value {
                print("📈 HRV: \(String(format: "%.2f", value))")
            }

            DispatchQueue.main.async {
                completion(value)
            }
        }

        healthStore.execute(query)
    }

    func startWatchWorkoutSessionForLiveStreaming() {
        // Demo placeholder: the real HKWorkoutSession must run on watchOS.
        print("⌚️ Start HKWorkoutSession on Apple Watch for live heart-rate streaming")
    }

    func fetchLastNightSleep() {
        
//        print("fetchLastNightSleep CALLED")

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        let calendar = Calendar.current
        let now = Date()

        let startDate = calendar.date(byAdding: .day, value: -2, to: now)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in

            guard let samples = samples as? [HKCategorySample] else {
                print("Query failed or no samples")
                return
            }

//            print("Total samples:", samples.count)

            for sample in samples {

                let value = sample.value

                var stage = "Unknown"

                switch value {
                case HKCategoryValueSleepAnalysis.inBed.rawValue:
                    stage = "In Bed"
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    stage = "Core Sleep"
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    stage = "Deep Sleep"
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    stage = "REM Sleep"
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    stage = "Awake"
                default:
                    break
                }

                print("Sleep Stage:", stage)
                print("Start:", sample.startDate)
                print("End:", sample.endDate)
                print("-----------")
            }
        }

        healthStore.execute(query)
    }

    func addMockSleepData() {

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let now = Date()

        var samples: [HKCategorySample] = []

        for i in 1...10 {

            let baseDate = calendar.date(byAdding: .day, value: -i, to: now)!

            let startHour = Int.random(in: 22...23)
            let startMinute = Int.random(in: 0...59)

            let sleepStart = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: baseDate)!

            let totalMinutes = Int.random(in: 360...540)

            var currentTime = sleepStart

            func addStage(_ type: HKCategoryValueSleepAnalysis, minutes: Int) {
                let end = calendar.date(byAdding: .minute, value: minutes, to: currentTime)!
                
                let sample = HKCategorySample(
                    type: sleepType,
                    value: type.rawValue,
                    start: currentTime,
                    end: end
                )
                
                samples.append(sample)
                currentTime = end
            }

            var remaining = totalMinutes

            while remaining > 0 {

                let chunk = min(Int.random(in: 20...90), remaining)

                let stageRoll = Int.random(in: 1...100)

                if stageRoll <= 55 {
                    addStage(.asleepCore, minutes: chunk)
                } else if stageRoll <= 75 {
                    addStage(.asleepDeep, minutes: chunk)
                } else if stageRoll <= 95 {
                    addStage(.asleepREM, minutes: chunk)
                } else {
                    addStage(.awake, minutes: Int.random(in: 5...15))
                }

                remaining -= chunk
            }
        }

        healthStore.save(samples) { success, error in
            if success {
                print("Realistic mock sleep data added")
            } else {
                print("Error:", error?.localizedDescription ?? "")
            }
        }
    }

}
