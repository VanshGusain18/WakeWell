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
        sendStartSession(alarmTime: alarmTime, windowStart: nil, windowEnd: nil)
    }

    func sendStartSession(alarmTime: Date, windowStart: Date?, windowEnd: Date?) {
        guard WCSession.isSupported() else {
            WatchConnectionMonitor.shared.markUnavailable()
            return
        }

        var payload: [String: Any] = [
            "action": "start_session",
            "alarmTime": alarmTime.timeIntervalSince1970
        ]
        if let windowStart {
            payload["windowStart"] = windowStart.timeIntervalSince1970
        }
        if let windowEnd {
            payload["windowEnd"] = windowEnd.timeIntervalSince1970
        }

        let session = WCSession.default
        pendingStartPayload = payload
        activate()

        guard session.activationState == .activated else {
            WatchConnectionMonitor.shared.markDeliveryQueued()
            return
        }

        flushPendingStartPayload()
    }

    func sendScheduledSession(alarmTime: Date, windowStart: Date, windowEnd: Date) {
        sendCommand([
            "action": "schedule_session",
            "alarmTime": alarmTime.timeIntervalSince1970,
            "windowStart": windowStart.timeIntervalSince1970,
            "windowEnd": windowEnd.timeIntervalSince1970,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func openRiseRitualOnWatch() {
        startRiseRitualOnWatch()
    }

    func startRiseRitualOnWatch() {
        let alarmTime = AlarmManager.shared.getWakeTime()
        let windowStart = alarmTime.map { AlarmManager.shared.alarmWindowStart(for: $0) }
        let windowEnd = alarmTime

        if let alarmTime {
            SleepSessionManager.shared.startSession(alarmTime: alarmTime)
            SmartAlarmEngine.shared.beginMonitoring()
            sendStartSession(alarmTime: alarmTime, windowStart: windowStart, windowEnd: windowEnd)
        }

        var ritualPayload: [String: Any] = [
            "action": "start_ritual",
            "timestamp": Date().timeIntervalSince1970
        ]
        if let alarmTime {
            ritualPayload["alarmTime"] = alarmTime.timeIntervalSince1970
        }
        if let windowStart {
            ritualPayload["windowStart"] = windowStart.timeIntervalSince1970
        }
        if let windowEnd {
            ritualPayload["windowEnd"] = windowEnd.timeIntervalSince1970
        }
        sendCommand(ritualPayload)
    }

    func startWakeAlarmOnWatch() {
        sendCommand([
            "action": "start_wake_alarm",
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func endWatchSession() {
        sendCommand([
            "action": "end_session",
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    private func sendCommand(_ payload: [String: Any]) {
        guard WCSession.isSupported() else {
            WatchConnectionMonitor.shared.markUnavailable()
            return
        }

        pendingCommandPayload = payload
        activate()

        guard WCSession.default.activationState == .activated else {
            WatchConnectionMonitor.shared.markDeliveryQueued()
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
            WatchConnectionMonitor.shared.markUnavailable()
            pendingStartPayload = nil
            return
        }

        do {
            try session.updateApplicationContext(payload)
        } catch {
            WatchConnectionMonitor.shared.markDeliveryQueued()
        }

        guard session.isReachable else {
            WatchConnectionMonitor.shared.markDeliveryQueued()
            pendingStartPayload = nil
            return
        }

        session.sendMessage(payload, replyHandler: nil) { _ in
            WatchConnectionMonitor.shared.markDeliveryQueued()
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
            WatchConnectionMonitor.shared.markUnavailable()
            pendingCommandPayload = nil
            return
        }

        do {
            try session.updateApplicationContext(payload)
        } catch {
            WatchConnectionMonitor.shared.markDeliveryQueued()
        }

        guard session.isReachable else {
            WatchConnectionMonitor.shared.markDeliveryQueued()
            pendingCommandPayload = nil
            return
        }

        session.sendMessage(payload, replyHandler: nil) { _ in
            WatchConnectionMonitor.shared.markDeliveryQueued()
        }

        pendingCommandPayload = nil
    }
}

extension WatchConnectivityReceiver: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error != nil {
            WatchConnectionMonitor.shared.markUnavailable()
            return
        }

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
        process(payload: applicationContext)
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        WatchConnectionMonitor.shared.updateReachability(session.isReachable)
    }

    private func process(payload: [String: Any]) {

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
        } else if hrv == nil {
        }

        WatchConnectionMonitor.shared.markPayloadReceived()
        AppConnectionState.shared.markWatchPayloadReceived()

        if !hasSwitchedToWatchStream {

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
            return nil
        }

        guard let value = payload[key] as? Double else {
            return nil
        }

        return value
    }
}
