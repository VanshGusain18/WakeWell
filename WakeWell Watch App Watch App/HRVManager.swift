import Foundation

final class HRVManager {
    static let shared = HRVManager()

    var onHRV: ((Double, Date) -> Void)?
    var onUnavailable: ((String) -> Void)?

    private var timer: Timer?
    private let pollInterval: TimeInterval = 60

    private init() {}

    func start() {
        stop()
        fetchLatestHRV()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.fetchLatestHRV()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func fetchLatestHRV() {
        HealthKitManager.shared.fetchLatestHRV { [weak self] hrv in
            guard let hrv else {
                let reason = HealthKitWorkoutManager.shared.isWorkoutActive
                    ? "system_delay_no_recent_sdnn"
                    : "no_workout_session_active"
                print("REAL HRV unavailable:", reason)
                print("RR interval logs unavailable: HealthKit SDNN sample not present")
                self?.onUnavailable?(reason)
                return
            }

            let timestamp = Date()
            print("REAL HRV RECEIVED", hrv)
            self?.onHRV?(hrv, timestamp)
        }
    }
}
