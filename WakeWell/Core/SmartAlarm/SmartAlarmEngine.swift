import Foundation

final class SmartAlarmEngine {

    static let shared = SmartAlarmEngine()

    private var hasTriggered = false
    private var wakeConfidence: Double = 0
    private var consecutiveHighScoreCount = 0
    private let requiredConsecutiveCount = 3
    private let evaluationWindowSize = 5
    private let minimumSampleCount = 3
    private let wakeConfidenceThreshold = 0.75
    private var lastKnownAverages: (avgHR: Double, avgHRV: Double, avgMotion: Double)?

    private(set) var lastTriggerResult: TriggerResult?

    // MARK: - Public

    func reset() {
        hasTriggered = false
        wakeConfidence = 0
        consecutiveHighScoreCount = 0
        lastKnownAverages = nil
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
        let timeToAlarm = wakeTime.timeIntervalSince(now)

        if timeToAlarm <= 0 {
            let vitals = latestVitalsWindow(limit: evaluationWindowSize)
            let averages = resolveAverages(from: vitals)

            lastTriggerResult = TriggerResult(
                timestamp: now,
                finalScore: 1.0,
                avgHR: averages.avgHR,
                avgHRV: averages.avgHRV,
                avgMotion: averages.avgMotion,
                reason: "fallback"
            )

            hasTriggered = true
            wakeConfidence = 1
            consecutiveHighScoreCount = 0
            triggerAlarm(
                baseScore: 1.0,
                finalScore: 1.0,
                motionSpike: false,
                hrTrend: false,
                wakeConfidence: wakeConfidence,
                reason: "fallback"
            )
            return true
        }

        guard now >= windowStart && now <= wakeTime else {
            print("⏳ Outside wake window")
            return false
        }

        let recent = latestVitalsWindow(limit: evaluationWindowSize)
        let isUsingFallbackAverages = recent.count < minimumSampleCount
        let averages = resolveAverages(from: recent)

        if isUsingFallbackAverages {
            print("⚠️ Not enough vitals, using last known averages")
        }

        let avgHR = averages.avgHR
        let avgHRV = averages.avgHRV
        let avgMotion = averages.avgMotion

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
        let isStrongScore = finalScore > 0.7

        let hasWakeSignal = motionSpike || hrTrend || isStrongScore

        if hasWakeSignal {
            consecutiveHighScoreCount += 1
        } else {
            consecutiveHighScoreCount = 0
        }

        updateWakeConfidence(
            motionSpike: motionSpike,
            hrTrend: hrTrend,
            consecutiveCount: consecutiveHighScoreCount,
            timeToAlarm: timeToAlarm
        )

        let reason = triggerReason(motionSpike: motionSpike, hrTrend: hrTrend)
        let finalDecision = wakeConfidence >= wakeConfidenceThreshold ? "trigger" : "wait"
        let loggedReason = finalDecision == "trigger" ? reason : "not_ready"
        printEvaluationLog(
            baseScore: baseScore,
            finalScore: finalScore,
            avgHR: avgHR,
            avgHRV: avgHRV,
            avgMotion: avgMotion,
            motionSpike: motionSpike,
            hrTrend: hrTrend,
            isStrongScore: isStrongScore,
            consecutiveCount: consecutiveHighScoreCount,
            wakeConfidence: wakeConfidence,
            finalDecision: finalDecision,
            reason: loggedReason
        )

        if wakeConfidence >= wakeConfidenceThreshold {
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
                wakeConfidence: wakeConfidence,
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
        wakeConfidence: Double,
        reason: String
    ) {
        if let result = lastTriggerResult {
            print("⏰ WAKE UP TRIGGERED")
            print("🔥 Base Score:", formatted(baseScore))
            print("📈 Final Score:", formatted(finalScore))
            print("🏃 Motion Spike:", motionSpike)
            print("❤️ HR Trend:", hrTrend)
            print("💤 Wake Confidence:", formatted(wakeConfidence))
            print("📊 Consecutive Count:", requiredConsecutiveCount)
            print("🧠 Trigger Reason:", reason)
            print("✅ Final Decision: trigger")
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

    private func resolveAverages(from vitals: [WatchVitalsModel]) -> (avgHR: Double, avgHRV: Double, avgMotion: Double) {
        if vitals.count >= minimumSampleCount {
            let averages = makeAverages(from: vitals)
            lastKnownAverages = averages
            return averages
        }

        if let lastKnownAverages {
            return lastKnownAverages
        }

        let averages = makeAverages(from: vitals)
        lastKnownAverages = averages
        return averages
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

    private func updateWakeConfidence(
        motionSpike: Bool,
        hrTrend: Bool,
        consecutiveCount: Int,
        timeToAlarm: TimeInterval
    ) {
        if motionSpike && hrTrend {
            wakeConfidence += 0.2
        } else if motionSpike || hrTrend {
            wakeConfidence += 0.12
        } else {
            wakeConfidence -= 0.05
        }

        if consecutiveCount >= requiredConsecutiveCount {
            wakeConfidence += 0.2
        }

        if timeToAlarm < 15 * 60 {
            wakeConfidence += 0.1
        }

        wakeConfidence = clamp(wakeConfidence, minValue: 0, maxValue: 1)
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
        isStrongScore: Bool,
        consecutiveCount: Int,
        wakeConfidence: Double,
        finalDecision: String,
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
        print("💪 Strong Score (>0.7):", isStrongScore)
        print("🔁 Consecutive Count:", consecutiveCount)
        print("💤 Wake Confidence:", formatted(wakeConfidence))
        print("🧾 Final Decision:", finalDecision)
        print("🧠 Trigger Reason:", reason)
    }

    private func clamp(_ value: Double, minValue: Double, maxValue: Double) -> Double {
        Swift.max(minValue, Swift.min(maxValue, value))
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%.3f", value)
    }
}
