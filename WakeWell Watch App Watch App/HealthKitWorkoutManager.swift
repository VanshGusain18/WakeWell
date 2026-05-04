import HealthKit

final class HealthKitWorkoutManager: NSObject {
    static let shared = HealthKitWorkoutManager()

    var onHeartRate: ((Double) -> Void)?
    private(set) var isWorkoutActive = false

    private let healthStore = HealthKitManager.shared.store
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var heartRateAnchor: HKQueryAnchor?

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
    }

    func stop() {
        if let heartRateQuery {
            healthStore.stop(heartRateQuery)
        }
        heartRateQuery = nil
        heartRateAnchor = nil

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
                print("HK WORKOUT STARTED", success, error?.localizedDescription ?? "")
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
    ) {}
}
