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
            return
        }

        print("⌚️ iPhone WCSession activated:", activationState.rawValue)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let heartRate = message["heartRate"] as? Double,
              let motion = message["motion"] as? Double,
              let hrv = message["hrv"] as? Double,
              let timestamp = message["timestamp"] as? Double else {
            return
        }

        if !hasSwitchedToWatchStream {
            WatchDataManager.shared.stop()
            hasSwitchedToWatchStream = true
        }

        if AlarmManager.shared.getWakeTime() == nil {
            let demoAlarmTime = Date().addingTimeInterval(5 * 60)
            AlarmManager.shared.setAlarm(AlarmModel(time: demoAlarmTime))
            NotificationCenter.default.post(name: .alarmTimeDidChange, object: nil)
        }

        let vitalData = VitalData(
            timestamp: Date(timeIntervalSince1970: timestamp),
            heartRate: heartRate,
            hrv: hrv,
            motion: motion,
            respiratoryRate: 0,
            wristTemp: nil,
            oxygenSaturation: nil,
            phase: motion < 0.45 ? "Light Sleep" : "Wake Transition"
        )

        print("📥 Received from Watch:")
        print("HR: \(String(format: "%.2f", heartRate))")
        print("Motion: \(String(format: "%.3f", motion))")
        print("HRV: \(String(format: "%.2f", hrv))")

        WatchDataManager.shared.process(vitalData: vitalData)
    }
}
