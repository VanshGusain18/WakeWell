import Foundation

final class SmartAlarmEngine {

    static let shared = SmartAlarmEngine()

    private var hasTriggered = false

    func evaluateWakeOpportunity() -> Bool {

        let vitals = DatabaseManager.shared.fetchRecentVitals(limit: 20)

        guard vitals.count > 5 else { return false }

        let latest = vitals.first!

        let hrScore = normalize(latest.heartRate, min: 50, max: 100)
        let hrvScore = normalize(latest.hrv, min: 20, max: 80)
        let motionScore = latest.motion

        let wakeScore =
            0.4 * hrScore +
            0.3 * (1 - hrvScore) +
            0.3 * motionScore

        print("Wake Score:", wakeScore)

        if wakeScore > 0.6 && !hasTriggered {
            hasTriggered = true
            triggerAlarm()
            return true
        }

        return false
    }

    private func triggerAlarm() {
        print("⏰ WAKE UP TRIGGERED")
    }

    private func normalize(_ value: Double, min: Double, max: Double) -> Double {
        return (value - min) / (max - min)
    }
}
