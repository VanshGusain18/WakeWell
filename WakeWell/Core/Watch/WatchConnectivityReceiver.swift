import Foundation
import WatchConnectivity

final class WatchConnectivityReceiver: NSObject {

    static let shared = WatchConnectivityReceiver()

    private var hasSwitchedToWatchStream = false

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
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
        WatchConnectionMonitor.shared.updateReachability(session.isReachable)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        process(payload: message)
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
            hrv: hrv ?? LiveVitalsViewModel.shared.hrv,
            hrvStatus: hrv == nil ? (hrvUnavailableReason ?? "unavailable") : "HealthKit"
        )

        if AlarmManager.shared.getWakeTime() == nil {
            let demoAlarmTime = Date().addingTimeInterval(5 * 60)
            AlarmManager.shared.setAlarm(AlarmModel(time: demoAlarmTime))
            NotificationCenter.default.post(name: .alarmTimeDidChange, object: nil)
        }

        let sample = WatchPayloadSample(
            timestamp: Date(timeIntervalSince1970: timestamp),
            heartRate: heartRate,
            hrv: hrv,
            motion: motion,
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
