import Foundation

final class SmartAlarmEngine {

    static let shared = SmartAlarmEngine()

    private var hasTriggered = false
    private var consecutiveHighScoreCount = 0
    private let requiredConsecutiveCount = 3
    private let evaluationWindowSize = 5
    private let minimumSampleCount = 3
    private let triggerThreshold = 0.56

    private(set) var lastTriggerResult: TriggerResult?

    // MARK: - Public

    func reset() {
        hasTriggered = false
        consecutiveHighScoreCount = 0
        lastTriggerResult = nil
        print("🔄 Engine reset")
    }

    func evaluateWakeOpportunity() -> Bool {
        if hasTriggered {
            print("🧊 Engine frozen: trigger already completed")
            return false
        }

        guard let wakeTime = AlarmManager.shared.getWakeTime() else {
            print("⛔ No alarm set")
            return false
        }

        let now = Date()
        let windowStart = wakeTime.addingTimeInterval(-30 * 60)

        if now >= wakeTime {
            let vitals = latestVitalsWindow(limit: evaluationWindowSize)
            let averages = makeAverages(from: vitals)

            lastTriggerResult = TriggerResult(
                timestamp: now,
                finalScore: 1.0,
                avgHR: averages.avgHR,
                avgHRV: averages.avgHRV,
                avgMotion: averages.avgMotion,
                reason: "fallback"
            )

            hasTriggered = true
            consecutiveHighScoreCount = 0
            triggerAlarm(
                baseScore: 1.0,
                finalScore: 1.0,
                motionSpike: false,
                hrTrend: false,
                reason: "fallback"
            )
            return true
        }

        guard now >= windowStart && now <= wakeTime else {
            print("⏳ Outside wake window")
            return false
        }

        let recent = latestVitalsWindow(limit: evaluationWindowSize)

        guard recent.count >= minimumSampleCount else {
            print("⚠️ Not enough vitals")
            return false
        }

        let avgHR = average(for: recent.map(\.heartRate))
        let avgHRV = average(for: recent.map(\.hrv))
        let avgMotion = average(for: recent.map(\.motion))

        let hrScore = normalize(avgHR, minValue: 50, maxValue: 100)
        let hrvScore = normalize(avgHRV, minValue: 20, maxValue: 80)
        let motionBaselineScore = normalize(avgMotion, minValue: 0.05, maxValue: 0.6)

        let baseScore =
            0.4 * hrScore +
            0.3 * (1 - hrvScore) +
            0.3 * motionBaselineScore

        let motionSpike = detectMotionSpike(recent)
        let hrTrend = detectHRTrend(recent)

        let motionBoost = motionSpike ? 0.08 : 0
        let hrBoost = hrTrend ? 0.08 : 0
        let finalScore = baseScore + motionBoost + hrBoost

        let isStrongSignal = finalScore >= triggerThreshold && (motionSpike || hrTrend)

        if isStrongSignal {
            consecutiveHighScoreCount += 1
        } else {
            consecutiveHighScoreCount = 0
        }

        let reason = triggerReason(motionSpike: motionSpike, hrTrend: hrTrend)
        let loggedReason = isStrongSignal ? reason : "not_ready"
        printEvaluationLog(
            baseScore: baseScore,
            finalScore: finalScore,
            avgHR: avgHR,
            avgHRV: avgHRV,
            avgMotion: avgMotion,
            motionSpike: motionSpike,
            hrTrend: hrTrend,
            consecutiveCount: consecutiveHighScoreCount,
            reason: loggedReason
        )

        if consecutiveHighScoreCount >= requiredConsecutiveCount {
            hasTriggered = true
            consecutiveHighScoreCount = 0

            lastTriggerResult = TriggerResult(
                timestamp: now,
                finalScore: finalScore,
                avgHR: avgHR,
                avgHRV: avgHRV,
                avgMotion: avgMotion,
                reason: reason
            )

            triggerAlarm(
                baseScore: baseScore,
                finalScore: finalScore,
                motionSpike: motionSpike,
                hrTrend: hrTrend,
                reason: reason
            )
            return true
        }

        return false
    }

    // MARK: - Private

    private func triggerAlarm(
        baseScore: Double,
        finalScore: Double,
        motionSpike: Bool,
        hrTrend: Bool,
        reason: String
    ) {
        if let result = lastTriggerResult {
            print("⏰ WAKE UP TRIGGERED")
            print("🔥 Base Score:", formatted(baseScore))
            print("📈 Final Score:", formatted(finalScore))
            print("🏃 Motion Spike:", motionSpike)
            print("❤️ HR Trend:", hrTrend)
            print("📊 Consecutive Count:", requiredConsecutiveCount)
            print("🧠 Trigger Reason:", reason)
            print("🕒 Trigger Timestamp:", result.timestamp)
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

    private func latestVitalsWindow(limit: Int) -> [WatchVitalsModel] {
        DatabaseManager.shared
            .fetchRecentVitals(limit: limit)
            .sorted { $0.timestamp < $1.timestamp }
    }

    private func makeAverages(from vitals: [WatchVitalsModel]) -> (avgHR: Double, avgHRV: Double, avgMotion: Double) {
        guard !vitals.isEmpty else {
            return (0, 0, 0)
        }

        return (
            avgHR: average(for: vitals.map(\.heartRate)),
            avgHRV: average(for: vitals.map(\.hrv)),
            avgMotion: average(for: vitals.map(\.motion))
        )
    }

    private func average(for values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private func detectMotionSpike(_ data: [WatchVitalsModel]) -> Bool {
        guard data.count >= 3 else { return false }

        let lastThree = Array(data.suffix(3))
        let latestMotion = lastThree[2].motion
        let baselineMotion = average(for: [lastThree[0].motion, lastThree[1].motion])
        let delta = latestMotion - baselineMotion

        return latestMotion >= 0.45 && delta >= 0.18
    }

    private func detectHRTrend(_ data: [WatchVitalsModel]) -> Bool {
        guard data.count >= 3 else { return false }

        let lastThree = Array(data.suffix(3))
        let first = lastThree[0].heartRate
        let second = lastThree[1].heartRate
        let third = lastThree[2].heartRate

        let firstIncrease = second - first
        let secondIncrease = third - second
        let totalIncrease = third - first

        return firstIncrease >= 1.5 &&
            secondIncrease >= 1.5 &&
            totalIncrease >= 4.0
    }

    private func triggerReason(motionSpike: Bool, hrTrend: Bool) -> String {
        if motionSpike && hrTrend {
            return "both"
        }

        if motionSpike {
            return "motion"
        }

        if hrTrend {
            return "hr_rising"
        }

        return "fallback"
    }

    private func printEvaluationLog(
        baseScore: Double,
        finalScore: Double,
        avgHR: Double,
        avgHRV: Double,
        avgMotion: Double,
        motionSpike: Bool,
        hrTrend: Bool,
        consecutiveCount: Int,
        reason: String
    ) {
        print("🧪 SmartAlarm Evaluation")
        print("🔥 Base Score:", formatted(baseScore))
        print("📈 Final Score:", formatted(finalScore))
        print("❤️ Avg HR:", formatted(avgHR))
        print("💓 Avg HRV:", formatted(avgHRV))
        print("🏃 Avg Motion:", formatted(avgMotion))
        print("⚡ Motion Spike:", motionSpike)
        print("📈 HR Trend:", hrTrend)
        print("🔁 Consecutive Count:", consecutiveCount)
        print("🧠 Trigger Reason:", reason)
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%.3f", value)
    }
}
