import Foundation

final class SmartAlarmEngine {

    static let shared = SmartAlarmEngine()

    private var hasTriggered = false

    // ✅ NEW: consecutive validation
    private var consecutiveHighScoreCount = 0
    private let requiredConsecutiveCount = 3
    private(set) var lastTriggerResult: TriggerResult?
    
    // MARK: - Public

    func reset() {
        hasTriggered = false
        consecutiveHighScoreCount = 0
        print("🔄 Engine reset")
    }

    func evaluateWakeOpportunity() -> Bool {

        guard let wakeTime = AlarmManager.shared.getWakeTime() else {
            print("⛔ No alarm set")
            return false
        }

        let now = Date()
        let windowStart = wakeTime.addingTimeInterval(-30 * 60)

        if now >= wakeTime && !hasTriggered {
            print("⏰ Fallback wake (exact alarm time)")
            hasTriggered = true
            triggerAlarm()
            return true
        }
        
        guard now >= windowStart && now <= wakeTime else {
            print("⏳ Outside wake window")
            return false
        }

        let vitals = DatabaseManager.shared.fetchRecentVitals(limit: 20)
        let windowSize = min(5, vitals.count)

        guard windowSize >= 3 else {
            print("⚠️ Not enough vitals")
            return false
        }

        let recent = vitals
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(windowSize)

        let avgHR = recent.map { $0.heartRate }.reduce(0, +) / Double(recent.count)
        let avgHRV = recent.map { $0.hrv }.reduce(0, +) / Double(recent.count)
        let avgMotion = recent.map { $0.motion }.reduce(0, +) / Double(recent.count)

        let hrScore = normalize(avgHR, minValue: 50, maxValue: 100)
        let hrvScore = normalize(avgHRV, minValue: 20, maxValue: 80)
        let motionScore = avgMotion

        let baseScore =
            0.4 * hrScore +
            0.3 * (1 - hrvScore) +
            0.3 * motionScore

        let trendBoost = detectHRTrend(recent)
        let finalScore = baseScore + trendBoost

        let isMotionHigh = avgMotion > 0.4
        let isHRRising = trendBoost > 0

        print("🔥 Base Score:", baseScore)
        print("📈 Final Score:", finalScore)

        // ✅ CONDITION CHECK
        let isStrongSignal = finalScore > 0.48 && (isMotionHigh || isHRRising)

        if isStrongSignal {
            consecutiveHighScoreCount += 1
            print("📊 Consecutive Count:", consecutiveHighScoreCount)
        } else {
            consecutiveHighScoreCount = 0
        }

        // ✅ FINAL TRIGGER CONDITION
        if consecutiveHighScoreCount >= requiredConsecutiveCount && !hasTriggered {

            hasTriggered = true

            let reason: String
            if isMotionHigh && isHRRising {
                reason = "motion + hr_rising"
            } else if isMotionHigh {
                reason = "motion"
            } else if isHRRising {
                reason = "hr_rising"
            } else {
                reason = "score_only"
            }

            lastTriggerResult = TriggerResult(
                timestamp: Date(),
                finalScore: finalScore,
                avgHR: avgHR,
                avgHRV: avgHRV,
                avgMotion: avgMotion,
                reason: reason
            )

            triggerAlarm()
            return true
        }

        return false
    }

    // MARK: - Private

    private func triggerAlarm() {

        if let result = lastTriggerResult {
            print("⏰ WAKE UP TRIGGERED")
            print("📊 Reason:", result.reason)
            print("📈 Score:", result.finalScore)
            print("❤️ HR:", result.avgHR)
            print("💓 HRV:", result.avgHRV)
            print("🏃 Motion:", result.avgMotion)
        } else {
            print("⏰ WAKE UP TRIGGERED (no data)")
        }
    }

    private func normalize(_ value: Double, minValue: Double, maxValue: Double) -> Double {
        let normalized = (value - minValue) / (maxValue - minValue)
        return Swift.max(0, Swift.min(1, normalized))
    }

    private func detectHRTrend(_ data: ArraySlice<WatchVitalsModel>) -> Double {

        let values = data.map { $0.heartRate }
        guard values.count >= 3 else { return 0 }

        let isRising = values.last! > values.first!
        return isRising ? 0.05 : 0
    }
}
