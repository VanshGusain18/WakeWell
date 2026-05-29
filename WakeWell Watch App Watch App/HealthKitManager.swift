import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()

    let store = HKHealthStore()

    private init() {}

    func requestPermissions(completion: ((Bool) -> Void)? = nil) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion?(false)
            return
        }

        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
              let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate) else {
            completion?(false)
            return
        }

        let types: Set<HKObjectType> = [heartRate, hrv, respiratoryRate]

        store.requestAuthorization(toShare: [], read: types) { success, _ in
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }

    func fetchLatestHRV(completion: @escaping (Double?) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion(nil)
            return
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: type,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { _, samples, error in

            let value = (samples?.first as? HKQuantitySample)?
                .quantity
                .doubleValue(for: HKUnit.secondUnit(with: .milli))

            DispatchQueue.main.async {
                completion(value)
            }
        }

        store.execute(query)
    }

    func fetchLatestRespiratoryRate(completion: @escaping (Double?) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .respiratoryRate) else {
            completion(nil)
            return
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: type,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { _, samples, error in

            let value = (samples?.first as? HKQuantitySample)?
                .quantity
                .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))

            DispatchQueue.main.async {
                completion(value)
            }
        }

        store.execute(query)
    }
}
