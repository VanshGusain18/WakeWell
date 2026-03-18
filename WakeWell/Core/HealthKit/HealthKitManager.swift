import Foundation
import HealthKit

final class HealthKitManager {

    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!

        let readTypes: Set<HKObjectType> = [
            sleepType,
            heartRateType,
            hrvType
        ]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

}
