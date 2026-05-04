import HealthKit

final class HealthKitWorkoutManager: NSObject {
    static let shared = HealthKitWorkoutManager()

    var onHeartRate: ((Double) -> Void)?
    var onHRV: ((Double, Date) -> Void)?
    var onRespiratoryRate: ((Double, Date) -> Void)?
    private(set) var isWorkoutActive = false

    private let healthStore = HealthKitManager.shared.store
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var heartRateAnchor: HKQueryAnchor?
    private var hrvQuery: HKAnchoredObjectQuery?
    private var hrvAnchor: HKQueryAnchor?
    private var respiratoryRateQuery: HKAnchoredObjectQuery?
    private var respiratoryRateAnchor: HKQueryAnchor?

    private override init() {
        super.init()
    }

    func start() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Workout unavailable: HealthKit data unavailable")
            return
        }

        if session == nil {
            startWorkoutSession()
        }

        startHeartRateQuery()
        startHRVQuery()
        startRespiratoryRateQuery()
    }

    func stop() {
        if let heartRateQuery {
            healthStore.stop(heartRateQuery)
        }
        if let hrvQuery {
            healthStore.stop(hrvQuery)
        }
        if let respiratoryRateQuery {
            healthStore.stop(respiratoryRateQuery)
        }
        heartRateQuery = nil
        heartRateAnchor = nil
        hrvQuery = nil
        hrvAnchor = nil
        respiratoryRateQuery = nil
        respiratoryRateAnchor = nil

        session?.end()
        builder?.endCollection(withEnd: Date()) { [weak self] _, _ in
            self?.builder?.finishWorkout { _, error in
                if let error {
                    print("Workout finish error:", error.localizedDescription)
                }
            }
        }
        session = nil
        builder = nil
        isWorkoutActive = false
    }

    private func startWorkoutSession() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown

        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()

            builder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )

            session.delegate = self
            builder.delegate = self

            self.session = session
            self.builder = builder

            let startDate = Date()
            session.startActivity(with: startDate)
            builder.beginCollection(withStart: startDate) { success, error in
                print("Workout started", success, error?.localizedDescription ?? "")
                DispatchQueue.main.async {
                    self.isWorkoutActive = success
                }
            }
        } catch {
            print("Workout start error:", error.localizedDescription)
        }
    }

    private func startHeartRateQuery() {
        guard heartRateQuery == nil,
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: heartRateAnchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            self?.heartRateAnchor = newAnchor
            self?.handleHeartRate(samples: samples, error: error)
        }

        query.updateHandler = { [weak self] _, samples, _, newAnchor, error in
            self?.heartRateAnchor = newAnchor
            self?.handleHeartRate(samples: samples, error: error)
        }

        heartRateQuery = query
        healthStore.execute(query)
    }

    private func startHRVQuery() {
        guard hrvQuery == nil,
              let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return
        }

        let query = HKAnchoredObjectQuery(
            type: hrvType,
            predicate: nil,
            anchor: hrvAnchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            self?.hrvAnchor = newAnchor
            self?.handleHRV(samples: samples, error: error)
        }

        query.updateHandler = { [weak self] _, samples, _, newAnchor, error in
            self?.hrvAnchor = newAnchor
            self?.handleHRV(samples: samples, error: error)
        }

        hrvQuery = query
        healthStore.execute(query)
    }

    private func startRespiratoryRateQuery() {
        guard respiratoryRateQuery == nil,
              let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate) else {
            return
        }

        let query = HKAnchoredObjectQuery(
            type: respiratoryRateType,
            predicate: nil,
            anchor: respiratoryRateAnchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            self?.respiratoryRateAnchor = newAnchor
            self?.handleRespiratoryRate(samples: samples, error: error)
        }

        query.updateHandler = { [weak self] _, samples, _, newAnchor, error in
            self?.respiratoryRateAnchor = newAnchor
            self?.handleRespiratoryRate(samples: samples, error: error)
        }

        respiratoryRateQuery = query
        healthStore.execute(query)
    }

    private func handleHeartRate(samples: [HKSample]?, error: Error?) {
        if let error {
            print("Heart rate query error:", error.localizedDescription)
            return
        }

        guard let quantitySamples = samples as? [HKQuantitySample] else { return }

        let unit = HKUnit.count().unitDivided(by: .minute())
        for sample in quantitySamples {
            let heartRate = sample.quantity.doubleValue(for: unit)
            DispatchQueue.main.async {
                print("REAL HR RECEIVED", heartRate)
                self.onHeartRate?(heartRate)
            }
        }
    }

    private func handleHRV(samples: [HKSample]?, error: Error?) {
        if let error {
            print("HRV query error:", error.localizedDescription)
            return
        }

        guard let quantitySamples = samples as? [HKQuantitySample] else { return }

        let unit = HKUnit.secondUnit(with: .milli)
        for sample in quantitySamples {
            let hrv = sample.quantity.doubleValue(for: unit)
            DispatchQueue.main.async {
                print("REAL HRV RECEIVED", hrv)
                self.onHRV?(hrv, sample.endDate)
            }
        }
    }

    private func handleRespiratoryRate(samples: [HKSample]?, error: Error?) {
        if let error {
            print("Respiratory rate query error:", error.localizedDescription)
            return
        }

        guard let quantitySamples = samples as? [HKQuantitySample] else { return }

        let unit = HKUnit.count().unitDivided(by: .minute())
        for sample in quantitySamples {
            let respiratoryRate = sample.quantity.doubleValue(for: unit)
            DispatchQueue.main.async {
                print("REAL RESPIRATORY RATE RECEIVED", respiratoryRate)
                self.onRespiratoryRate?(respiratoryRate, sample.endDate)
            }
        }
    }
}

extension HealthKitWorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        print("Workout session state:", toState.rawValue)
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session error:", error.localizedDescription)
    }
}

extension HealthKitWorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        for sampleType in collectedTypes {
            guard let quantityType = sampleType as? HKQuantityType else { continue }

            switch quantityType.identifier {
            case HKQuantityTypeIdentifier.heartRate.rawValue:
                guard let statistics = workoutBuilder.statistics(for: quantityType) else { continue }
                let unit = HKUnit.count().unitDivided(by: .minute())
                let value = statistics.mostRecentQuantity()?.doubleValue(for: unit)
                    ?? statistics.averageQuantity()?.doubleValue(for: unit)

                guard let value, value > 0 else { continue }
                DispatchQueue.main.async {
                    print("REAL HR RECEIVED", value)
                    self.onHeartRate?(value)
                }

            case HKQuantityTypeIdentifier.heartRateVariabilitySDNN.rawValue:
                guard let statistics = workoutBuilder.statistics(for: quantityType),
                      let value = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.secondUnit(with: .milli)),
                      value > 0 else {
                    continue
                }

                DispatchQueue.main.async {
                    print("REAL HRV RECEIVED", value)
                    self.onHRV?(value, Date())
                }

            case HKQuantityTypeIdentifier.respiratoryRate.rawValue:
                guard let statistics = workoutBuilder.statistics(for: quantityType),
                      let value = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())),
                      value > 0 else {
                    continue
                }

                DispatchQueue.main.async {
                    print("REAL RESPIRATORY RATE RECEIVED", value)
                    self.onRespiratoryRate?(value, Date())
                }

            default:
                continue
            }
        }
    }
}
