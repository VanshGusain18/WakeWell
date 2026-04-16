import Foundation

final class SmartAlarmEngine {

    static let shared = SmartAlarmEngine()

    private var hasTriggered = false

    func evaluateWakeOpportunity() -> Bool {
        
        print("hello")
        let vitals = DatabaseManager.shared.fetchRecentVitals(limit: 20)
        print("Vitals count:", vitals.count)
        
        guard vitals.count >= 5 else { return false }

        let recent = vitals.sorted { $0.timestamp > $1.timestamp }.prefix(5)

        let avgHR = recent.map { $0.heartRate }.reduce(0, +) / Double(recent.count)
        let avgHRV = recent.map { $0.hrv }.reduce(0, +) / Double(recent.count)
        let avgMotion = recent.map { $0.motion }.reduce(0, +) / Double(recent.count)
        print(avgHR, avgHRV, avgMotion)
        let hrScore = normalize(avgHR, min: 50, max: 100)
        let hrvScore = normalize(avgHRV, min: 20, max: 80)
        let motionScore = avgMotion

        let wakeScore =
            0.4 * hrScore +
            0.3 * (1 - hrvScore) +
            0.3 * motionScore

        print("🔥🔥🔥 SCORE:", wakeScore)

        if wakeScore > 0.48 && !hasTriggered {
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
