import Foundation

final class SmartAlarmEngine {

    static let shared = SmartAlarmEngine()

    private var hasTriggered = false

    func evaluateWakeOpportunity() -> Bool {
        
        print("hello")
        let vitals = DatabaseManager.shared.fetchRecentVitals(limit: 20)
        print("Vitals count:", vitals.count)
        
        let windowSize = min(5, vitals.count)
        guard windowSize > 0 else { return false }

        let recent = vitals.sorted { $0.timestamp > $1.timestamp }.prefix(windowSize)

        let avgHR = recent.map { $0.heartRate }.reduce(0, +) / Double(recent.count)
        let avgHRV = recent.map { $0.hrv }.reduce(0, +) / Double(recent.count)
        let avgMotion = recent.map { $0.motion }.reduce(0, +) / Double(recent.count)
        print(avgHR, avgHRV, avgMotion)
        let hrScore = normalize(avgHR, minValue: 50, maxValue: 100)
        let hrvScore = normalize(avgHRV, minValue: 20, maxValue: 80)
        let motionScore = avgMotion

        let wakeScore =
            0.4 * hrScore +
            0.3 * (1 - hrvScore) +
            0.3 * motionScore

        print("🔥🔥🔥 SCORE:", wakeScore)

        if wakeScore > 0.5 && !hasTriggered {
            hasTriggered = true
            triggerAlarm()
            return true
        }

        return false
    }

    private func triggerAlarm() {
        print("⏰ WAKE UP TRIGGERED")
    }

    private func normalize(_ value: Double, minValue: Double, maxValue: Double) -> Double {
        let normalized = (value - minValue) / (maxValue - minValue)
        return Swift.max(0, Swift.min(1, normalized))
    }
}
