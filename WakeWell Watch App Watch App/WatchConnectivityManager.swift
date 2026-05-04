import Combine
import Foundation
import WatchKit
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
    @Published var alarmTime: Date?
    @Published var hasReceivedHeartRate = false
    @Published var hasReceivedMotion = false
    @Published var hasReceivedHRV = false
    @Published var hasReceivedRespiratoryRate = false
    @Published var shouldOpenRiseRitual = false

    private let session = WCSession.default
    private let aggregator = UnifiedVitalsAggregator.shared
    private var isActivated = false
    private var pendingVitals: WatchVitals?
    private var isStreaming = false
    private var pendingBackgroundTasks: [WKRefreshBackgroundTask] = []

    private override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else {
            statusText = "WCSession not supported"
            return
        }

        session.delegate = self
        switch session.activationState {
        case .activated:
            isActivated = true
            isReachable = session.isReachable
            handleReceivedApplicationContextIfAvailable()
        case .notActivated:
            session.activate()
        case .inactive:
            session.activate()
        @unknown default:
            session.activate()
        }
    }

    func startStreaming() {
        guard !isStreaming else { return }
        isStreaming = true

        HealthKitManager.shared.requestPermissions { [weak self] success in
            guard let self else { return }

            self.hasHealthDataAccess = success
            guard success else {
                self.statusText = "No Health Data Access"
                MotionManager.shared.stop()
                HealthKitWorkoutManager.shared.stop()
                HRVManager.shared.stop()
                self.aggregator.stop()
                self.isStreaming = false
                return
            }

            self.statusText = "LIVE HEALTH DATA MODE"
            print("Streaming started")

            self.aggregator.onVitalsReady = { [weak self] vitals in
                self?.handleAggregatedVitals(vitals)
            }
            self.aggregator.start()

            HealthKitWorkoutManager.shared.onHeartRate = { [weak self] heartRate in
                self?.lastHeartRate = heartRate
                self?.hasReceivedHeartRate = true
                self?.aggregator.addHeartRate(heartRate)
            }
            HealthKitWorkoutManager.shared.onHRV = { [weak self] hrv, timestamp in
                self?.lastHRV = hrv
                self?.lastHRVUpdatedAt = timestamp
                self?.hasReceivedHRV = true
                self?.aggregator.updateHRV(hrv, timestamp: timestamp)
            }
            HealthKitWorkoutManager.shared.onRespiratoryRate = { [weak self] respiratoryRate, timestamp in
                self?.lastRespiratoryRate = respiratoryRate
                self?.hasReceivedRespiratoryRate = true
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
                self?.hasReceivedMotion = true
                self?.aggregator.addMotion(motion)
            }
        }
    }

    private func handleCommand(_ payload: [String: Any]) {
        guard let action = payload["action"] as? String else { return }

        if action == "open_rise_ritual" {
            shouldOpenRiseRitual = true
            completeBackgroundTasks()
            return
        }

        guard action == "start_session" else { return }

        if let alarmTimestamp = payload["alarmTime"] as? Double {
            alarmTime = Date(timeIntervalSince1970: alarmTimestamp)
        }

        startStreaming()
        completeBackgroundTasks()
    }

    func handle(backgroundTasks: Set<WKRefreshBackgroundTask>) {
        pendingBackgroundTasks.append(contentsOf: backgroundTasks)
        activateSession()
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
            completeBackgroundTasks()
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

    private func completeBackgroundTasks() {
        guard !pendingBackgroundTasks.isEmpty else { return }

        let tasks = pendingBackgroundTasks
        pendingBackgroundTasks.removeAll()

        for task in tasks {
            task.setTaskCompletedWithSnapshot(false)
        }
    }

    private func handleReceivedApplicationContextIfAvailable() {
        guard session.activationState == .activated else { return }

        let context = session.receivedApplicationContext
        guard !context.isEmpty else { return }
        handleCommand(context)
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
                self.handleReceivedApplicationContextIfAvailable()
                if let pendingVitals = self.pendingVitals {
                    self.pendingVitals = nil
                    self.send(vitals: pendingVitals)
                }
                self.completeBackgroundTasks()
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleCommand(message)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.handleCommand(applicationContext)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            self.handleCommand(userInfo)
        }
    }
}
