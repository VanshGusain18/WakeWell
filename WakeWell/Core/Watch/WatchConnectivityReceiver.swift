import Foundation
import WatchConnectivity

final class WatchConnectivityReceiver: NSObject {

    static let shared = WatchConnectivityReceiver()

    private var hasSwitchedToWatchStream = false
    private var pendingStartPayload: [String: Any]?
    private var pendingCommandPayload: [String: Any]?
    private var isActivated = false

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        switch session.activationState {
        case .activated:
            isActivated = true
            WatchConnectionMonitor.shared.updateReachability(session.isReachable)
            flushPendingStartPayload()
        case .notActivated, .inactive:
            session.activate()
        @unknown default:
            session.activate()
        }
    }

    func sendStartSession(alarmTime: Date) {
        guard WCSession.isSupported() else {
            WatchConnectionMonitor.shared.updateReachability(false)
            return
        }

        let payload: [String: Any] = [
            "action": "start_session",
            "alarmTime": alarmTime.timeIntervalSince1970
        ]

        let session = WCSession.default
        pendingStartPayload = payload
        activate()

        guard session.activationState == .activated else {
            print("⌚️ Queued start_session until WCSession activation completes")
            return
        }

        flushPendingStartPayload()
    }

    func openRiseRitualOnWatch() {
        sendCommand([
            "action": "open_rise_ritual",
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    private func sendCommand(_ payload: [String: Any]) {
        guard WCSession.isSupported() else {
            WatchConnectionMonitor.shared.updateReachability(false)
            return
        }

        pendingCommandPayload = payload
        activate()

        guard WCSession.default.activationState == .activated else {
            print("⌚️ Queued watch command until WCSession activation completes")
            return
        }

        flushPendingCommandPayload()
    }

    private func flushPendingStartPayload() {
        guard let payload = pendingStartPayload,
              WCSession.isSupported() else {
            return
        }

        let session = WCSession.default
        guard session.activationState == .activated else { return }

        if session.isWatchAppInstalled {
            session.transferUserInfo(payload)
        } else {
            WatchConnectionMonitor.shared.updateReachability(false)
            print("⌚️ Watch app is not installed")
        }

        do {
            try session.updateApplicationContext(payload)
        } catch {
            print("⌚️ Failed to update watch command context:", error.localizedDescription)
        }

        guard session.isReachable else {
            WatchConnectionMonitor.shared.updateReachability(false)
            print("⌚️ Watch not reachable; start_session queued via context/userInfo")
            pendingStartPayload = nil
            return
        }

        session.sendMessage(payload, replyHandler: nil) { error in
            print("⌚️ Failed to send start_session:", error.localizedDescription)
        }

        pendingStartPayload = nil
    }

    private func flushPendingCommandPayload() {
        guard let payload = pendingCommandPayload,
              WCSession.isSupported() else {
            return
        }

        let session = WCSession.default
        guard session.activationState == .activated else { return }

        if session.isWatchAppInstalled {
            session.transferUserInfo(payload)
        } else {
            WatchConnectionMonitor.shared.updateReachability(false)
            print("⌚️ Watch app is not installed")
        }

        do {
            try session.updateApplicationContext(payload)
        } catch {
            print("⌚️ Failed to update watch command context:", error.localizedDescription)
        }

        guard session.isReachable else {
            WatchConnectionMonitor.shared.updateReachability(false)
            print("⌚️ Watch not reachable; command queued via context/userInfo")
            pendingCommandPayload = nil
            return
        }

        session.sendMessage(payload, replyHandler: nil) { error in
            print("⌚️ Failed to send watch command:", error.localizedDescription)
        }

        pendingCommandPayload = nil
    }
}

extension WatchConnectivityReceiver: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            print("⌚️ iPhone WCSession activation error:", error.localizedDescription)
            WatchConnectionMonitor.shared.updateReachability(false)
            return
        }

        print("⌚️ iPhone WCSession activated:", activationState.rawValue)
        isActivated = activationState == .activated
        WatchConnectionMonitor.shared.updateReachability(session.isReachable)
        flushPendingStartPayload()
        flushPendingCommandPayload()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        process(payload: message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        process(payload: userInfo)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📥 Received raw:", applicationContext)
        process(payload: applicationContext)
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        WatchConnectionMonitor.shared.updateReachability(session.isReachable)
    }

    private func process(payload: [String: Any]) {
        print("📥 Received raw payload:", payload)

        guard let heartRate = requiredDouble("heartRate", in: payload),
              let motion = requiredDouble("motion", in: payload),
              let timestamp = requiredDouble("timestamp", in: payload) else {
            return
        }

        let rawHRV = payload["hrv"] as? Double
        let hrv = rawHRV.flatMap { $0 > 0 ? $0 : nil }
        let respiratoryRate = payload["respiratoryRate"] as? Double
        let hrvUnavailableReason = payload["hrvUnavailableReason"] as? String
        let validityFlags = WatchValidityFlags(dictionary: payload["validityFlags"] as? [String: Any])
        if rawHRV == nil {
            print("⚠️ HRV missing from Watch payload:", hrvUnavailableReason ?? "NO_DATA")
        } else if hrv == nil {
            print("HRV MISSING - IGNORED NOT ZEROED")
        }
        print("HR:", heartRate)
        print("HRV:", rawHRV as Any)
        print("Motion:", motion)
        print("Respiratory Rate:", respiratoryRate as Any)
        print("Source labels: HR=HealthKit HRV=\(validityFlags.hrvReal ? "HealthKit" : "unavailable") Motion=CoreMotion")

        WatchConnectionMonitor.shared.markPayloadReceived()
        AppConnectionState.shared.markWatchPayloadReceived()

        if !hasSwitchedToWatchStream {
            print("🔄 Switching to REAL watch stream")

            WatchDataManager.shared.stop()
            WatchDataManager.shared.start(resetData: false)
            hasSwitchedToWatchStream = true
        }

        LiveVitalsViewModel.shared.update(
            heartRate: heartRate,
            motion: motion,
            hrv: hrv ?? 0,
            respiratoryRate: respiratoryRate,
            hrvStatus: hrv == nil ? (hrvUnavailableReason ?? "unavailable") : "HealthKit"
        )

        let sample = WatchPayloadSample(
            timestamp: Date(timeIntervalSince1970: timestamp),
            heartRate: heartRate,
            hrv: hrv,
            motion: motion,
            respiratoryRate: respiratoryRate,
            validityFlags: validityFlags,
            hrvUnavailableReason: hrvUnavailableReason
        )

        guard let validatedSample = DataIntegrityValidator.shared.validate(sample) else {
            return
        }

        let vitalData = VitalsEngine.shared.process(validatedSample)
        WatchDataManager.shared.process(vitalData: vitalData)
    }

    private func requiredDouble(_ key: String, in payload: [String: Any]) -> Double? {
        guard payload.keys.contains(key) else {
            print("⚠️ Missing key from Watch payload:", key)
            return nil
        }

        guard let value = payload[key] as? Double else {
            print("⚠️ Invalid value for Watch payload key:", key, payload[key] as Any)
            return nil
        }

        return value
    }
}
