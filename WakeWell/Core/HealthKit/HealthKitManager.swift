import Foundation
import HealthKit

final class HealthKitManager {

    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
    private let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
    private let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)
    private let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    private let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
              let heartRateType,
              let hrvType,
              let respiratoryRateType else {
            completion(false)
            return
        }

        var readTypes: Set<HKObjectType> = [
            sleepType,
            heartRateType,
            hrvType,
            respiratoryRateType
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

            DispatchQueue.main.async {
                completion(value)
            }
        }

        healthStore.execute(query)
    }

    func fetchLatestRespiratoryRate(completion: @escaping (Double?) -> Void) {
        guard let respiratoryRateType else {
            completion(nil)
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: respiratoryRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, _ in
            let value = (samples?.first as? HKQuantitySample)?
                .quantity
                .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))

            DispatchQueue.main.async {
                completion(value)
            }
        }

        healthStore.execute(query)
    }

}
