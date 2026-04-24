import Foundation

final class SleepSessionManager {

    static let shared = SleepSessionManager()

    private init() {}

    private(set) var currentSessionId: Int?
    private(set) var startTime: Date?
    private(set) var alarmTime: Date?

    func startSession(alarmTime: Date) {
        if currentSessionId != nil {
            print("⚠️ Active session already exists")
            return
        }

        let startTime = Date()

        print("🟢 SESSION STARTED")
        print("- startTime:", startTime)
        print("- alarmTime:", alarmTime)

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
            print("⚠️ No active session to end")
            return
        }

        print("🔴 SESSION ENDED")
        print("- triggerTime:", triggerTime)
        print("- reason:", reason)
        print("- confidence:", confidence)

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
}
