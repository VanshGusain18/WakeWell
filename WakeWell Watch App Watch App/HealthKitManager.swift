import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()

    let store = HKHealthStore()

    private init() {}

    func requestPermissions(completion: ((Bool) -> Void)? = nil) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit auth:", false, "Health data unavailable")
            completion?(false)
            return
        }

        let types: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]

        store.requestAuthorization(toShare: [], read: types) { success, error in
            if success {
                print("HealthKit auth:", true, "")
            } else {
                print("HealthKit auth:", false, error?.localizedDescription ?? "permission denied")
            }
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
            if let error {
                print("HRV query error:", error.localizedDescription)
            }

            let value = (samples?.first as? HKQuantitySample)?
                .quantity
                .doubleValue(for: HKUnit.secondUnit(with: .milli))

            DispatchQueue.main.async {
                completion(value)
            }
        }

        store.execute(query)
    }
}
