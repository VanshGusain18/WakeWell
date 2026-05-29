import Foundation

final class HealthKitVitalsFallbackManager {
    static let shared = HealthKitVitalsFallbackManager()

    private let pollInterval: TimeInterval = 30
    private let reusableMotionMaxAge: TimeInterval = 5 * 60
    private var timer: Timer?

    private init() {}

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.poll()
        }
        poll()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        guard WatchConnectionMonitor.shared.isStaleData else { return }

        fetchLatestHealthKitVitals { [weak self] heartRate, hrv, respiratoryRate in
            guard let self, let heartRate else { return }

            LiveVitalsViewModel.shared.update(
                heartRate: heartRate,
                motion: 0,
                hrv: hrv ?? 0,
                respiratoryRate: respiratoryRate,
                hrvStatus: hrv == nil ? "unavailable" : "iPhone HealthKit"
            )

            guard let motionSample = self.latestReusableMotionSample() else {
                return
            }

            let vitalData = VitalData(
                timestamp: Date(),
                heartRate: heartRate,
                hrv: hrv,
                motion: motionSample.motion,
                respiratoryRate: respiratoryRate,
                wristTemp: nil,
                oxygenSaturation: nil,
                phase: motionSample.motion < 0.45 ? "Light Sleep" : "Wake Transition"
            )

            WatchDataManager.shared.process(vitalData: vitalData)
        }
    }

    private func fetchLatestHealthKitVitals(
        completion: @escaping (_ heartRate: Double?, _ hrv: Double?, _ respiratoryRate: Double?) -> Void
    ) {
        var latestHeartRate: Double?
        var latestHRV: Double?
        var latestRespiratoryRate: Double?
        let group = DispatchGroup()

        group.enter()
        HealthKitManager.shared.fetchLatestHeartRate {
            latestHeartRate = $0
            group.leave()
        }

        group.enter()
        HealthKitManager.shared.fetchLatestHRV {
            latestHRV = $0
            group.leave()
        }

        group.enter()
        HealthKitManager.shared.fetchLatestRespiratoryRate {
            latestRespiratoryRate = $0
            group.leave()
        }

        group.notify(queue: .main) {
            completion(latestHeartRate, latestHRV, latestRespiratoryRate)
        }
    }

    private func latestReusableMotionSample() -> WatchVitalsModel? {
        guard let sample = DatabaseManager.shared.fetchRecentVitals(limit: 1).first,
              Date().timeIntervalSince(sample.timestamp) <= reusableMotionMaxAge else {
            return nil
        }

        return sample
    }
}
