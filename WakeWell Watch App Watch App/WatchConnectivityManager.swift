import Combine
import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {

    static let shared = WatchConnectivityManager()

    @Published var lastHeartRate: Double = 0
    @Published var lastMotion: Double = 0
    @Published var lastHRV: Double = 0
    @Published var lastRespiratoryRate: Double = 0
    @Published var lastHRVUpdatedAt: Date?
    @Published var isReachable = false
    @Published var hasSentPayload = false
    @Published var hasHealthDataAccess = true
    @Published var statusText = "LIVE HEALTH DATA MODE"

    private let session = WCSession.default
    private let aggregator = UnifiedVitalsAggregator.shared
    private var isActivated = false
    private var pendingVitals: WatchVitals?

    private override init() {
        super.init()
        activateSession()
        startStreaming()
    }

    private func activateSession() {
        guard WCSession.isSupported() else {
            statusText = "WCSession not supported"
            return
        }

        session.delegate = self
        session.activate()
        isReachable = session.isReachable
    }

    func startStreaming() {
        HealthKitManager.shared.requestPermissions { [weak self] success in
            guard let self else { return }

            self.hasHealthDataAccess = success
            guard success else {
                self.statusText = "No Health Data Access"
                MotionManager.shared.stop()
                HealthKitWorkoutManager.shared.stop()
                HRVManager.shared.stop()
                self.aggregator.stop()
                return
            }

            self.statusText = "LIVE HEALTH DATA MODE"

            self.aggregator.onVitalsReady = { [weak self] vitals in
                self?.handleAggregatedVitals(vitals)
            }
            self.aggregator.start()

            HealthKitWorkoutManager.shared.onHeartRate = { [weak self] heartRate in
                self?.lastHeartRate = heartRate
                self?.aggregator.addHeartRate(heartRate)
            }
            HealthKitWorkoutManager.shared.onHRV = { [weak self] hrv, timestamp in
                self?.lastHRV = hrv
                self?.lastHRVUpdatedAt = timestamp
                self?.aggregator.updateHRV(hrv, timestamp: timestamp)
            }
            HealthKitWorkoutManager.shared.onRespiratoryRate = { [weak self] respiratoryRate, timestamp in
                self?.lastRespiratoryRate = respiratoryRate
                self?.aggregator.updateRespiratoryRate(respiratoryRate, timestamp: timestamp)
            }
            HealthKitWorkoutManager.shared.start()

            HRVManager.shared.onHRV = { [weak self] hrv, timestamp in
                self?.lastHRV = hrv
                self?.lastHRVUpdatedAt = timestamp
                self?.aggregator.updateHRV(hrv, timestamp: timestamp)
            }
            HRVManager.shared.onUnavailable = { [weak self] reason in
                self?.aggregator.markHRVUnavailable(reason: reason)
            }
            HRVManager.shared.start()

            MotionManager.shared.start { [weak self] motion in
                self?.lastMotion = motion
                self?.aggregator.addMotion(motion)
            }
        }
    }

    private func handleAggregatedVitals(_ vitals: WatchVitals) {
        lastHeartRate = vitals.heartRate
        lastMotion = vitals.motion
        lastHRV = vitals.hrv ?? lastHRV
        lastRespiratoryRate = vitals.respiratoryRate ?? lastRespiratoryRate
        send(vitals: vitals)
    }

    private func send(vitals: WatchVitals) {
        let payload = vitals.payload

        isReachable = session.isReachable

        print("Watch HR:", vitals.heartRate)
        if let hrv = vitals.hrv {
            print("Watch HRV:", hrv)
        } else {
            print("Watch HRV unavailable:", vitals.hrvUnavailableReason ?? "unknown")
        }
        print("Watch Motion:", vitals.motion)
        print("📤 Sending payload:", payload)

        guard isActivated else {
            pendingVitals = vitals
            statusText = "Activating connection..."
            return
        }

        do {
            try session.updateApplicationContext(payload)
            hasSentPayload = true
            statusText = "LIVE HEALTH DATA MODE"
        } catch {
            statusText = "Context failed: \(error.localizedDescription)"
            hasSentPayload = false
        }

        guard session.isReachable else { return }
        session.sendMessage(payload, replyHandler: nil) { [weak self] error in
            DispatchQueue.main.async {
                self?.statusText = "Message failed: \(error.localizedDescription)"
            }
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error {
                self.statusText = "Activation error: \(error.localizedDescription)"
            } else {
                self.isActivated = true
                self.isReachable = session.isReachable
                if let pendingVitals = self.pendingVitals {
                    self.pendingVitals = nil
                    self.send(vitals: pendingVitals)
                }
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}
