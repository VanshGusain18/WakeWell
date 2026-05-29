import Foundation

final class SleepSessionManager {

    static let shared = SleepSessionManager()

    private init() {}

    private(set) var currentSessionId: Int?
    private(set) var startTime: Date?
    private(set) var alarmTime: Date?

    func restoreActiveSessionIfNeeded() {
        guard currentSessionId == nil,
              let session = DatabaseManager.shared.fetchOpenSleepSession() else {
            return
        }

        currentSessionId = session.id
        startTime = session.startTime
        alarmTime = session.alarmTime
    }

    func startSession(alarmTime: Date) {
        restoreActiveSessionIfNeeded()

        if currentSessionId != nil {
            return
        }

        let startTime = Date()


        guard let sessionId = DatabaseManager.shared.createSleepSession(
            startTime: startTime,
            alarmTime: alarmTime
        ) else {
            return
        }

        self.currentSessionId = sessionId
        self.startTime = startTime
        self.alarmTime = alarmTime
    }

    func endSession(triggerTime: Date, reason: String, confidence: Double) {
        guard let currentSessionId else {
            return
        }


        DatabaseManager.shared.completeSleepSession(
            triggerTime: triggerTime,
            reason: reason,
            confidence: confidence,
            sessionId: currentSessionId
        )

        self.currentSessionId = nil
        self.startTime = nil
        self.alarmTime = nil
    }

    func cancelActiveSession(reason: String) {
        restoreActiveSessionIfNeeded()

        guard let currentSessionId else {
            return
        }

        DatabaseManager.shared.completeSleepSession(
            triggerTime: Date(),
            reason: reason,
            confidence: 0,
            sessionId: currentSessionId
        )

        self.currentSessionId = nil
        self.startTime = nil
        self.alarmTime = nil
    }
}
