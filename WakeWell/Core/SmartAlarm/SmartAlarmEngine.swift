import Foundation

final class SmartAlarmEngine {

    static let shared = SmartAlarmEngine()

    // MARK: - Tunable Constants

    private let DEBUG_MODE = true

    private let minimumRequiredSamples = 8
    private let analysisWindowSize = 12
    private let scoringWindowSize = 5
    private let requiredConsecutiveCount = 3
    private let triggerWakeWindow: TimeInterval = 15 * 60
    private let cooldownDuration: TimeInterval = 10 * 60

    private let wakeConfidenceThreshold = 0.75
    private let minimumTriggerScore = 0.65
    private let confidenceSmoothingFactor = 0.45

    private let motionSpikeThreshold = 0.42
    private let motionDeltaThreshold = 0.12
    private let hrStepIncreaseThreshold = 1.2
    private let hrTotalIncreaseThreshold = 3.5

    // MARK: - State

    private var hasTriggered = false
    private var wakeConfidence: Double = 0
    private var consecutiveHighScoreCount = 0
    private var lastTriggerTime: Date?
    private var lastKnownAverages: (avgHR: Double, avgHRV: Double, avgMotion: Double)?

    private(set) var lastTriggerResult: TriggerResult?

    // MARK: - Public

    func reset() {
        hasTriggered = false
        wakeConfidence = 0
        consecutiveHighScoreCount = 0
        lastTriggerTime = nil
        lastKnownAverages = nil
        lastTriggerResult = nil
        print("🔄 Engine reset")
    }

    func evaluateWakeOpportunity() -> Bool {
        let now = Date()
        let cooldown = cooldownStatus(at: now)

        if cooldown.isActive {
            print("🧊 Cooldown active: \(cooldown.description)")
            return false
        }

        if hasTriggered {
            print("🧊 Engine frozen: trigger already completed")
            return false
        }

        guard let wakeTime = AlarmManager.shared.getWakeTime() else {
            print("⛔ No alarm set")
            return false
        }

        let timeToAlarm = wakeTime.timeIntervalSince(now)
        let withinWakeWindow = timeToAlarm <= triggerWakeWindow

        print("🛠️ SmartAlarm v2 DEBUG")

        if timeToAlarm <= 0 {
            let vitals = latestVitalsWindow(limit: analysisWindowSize)
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
            lastTriggerTime = now
            wakeConfidence = 1
            consecutiveHighScoreCount = 0

            triggerAlarm(
                baseScore: 1.0,
                finalScore: 1.0,
                motionSpike: false,
                hrTrend: false,
                wakeConfidence: wakeConfidence,
                timeToAlarm: timeToAlarm,
                cooldownStatus: cooldown.description,
                triggerEligibility: true,
                reason: "fallback"
            )
            return true
        }

        if DEBUG_MODE && timeToAlarm < 240 {
            let vitals = latestVitalsWindow(limit: analysisWindowSize)
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
            lastTriggerTime = now
            wakeConfidence = 1
            consecutiveHighScoreCount = 0

            print("🧪 FORCE TRIGGER ACTIVE")
            print("🚨 SHOULD TRIGGER:", true)

            triggerAlarm(
                baseScore: 1.0,
                finalScore: 1.0,
                motionSpike: true,
                hrTrend: true,
                wakeConfidence: wakeConfidence,
                timeToAlarm: timeToAlarm,
                cooldownStatus: cooldown.description,
                triggerEligibility: true,
                reason: "fallback"
            )
            return true
        }

        let allRecentVitals = latestVitalsWindow(limit: analysisWindowSize)

        guard allRecentVitals.count >= minimumRequiredSamples else {
            consecutiveHighScoreCount = 0
            wakeConfidence = applyConfidenceDelta(-0.04)

            printEvaluationLog(
                baseScore: 0,
                finalScore: 0,
                avgHR: 0,
                avgHRV: 0,
                avgMotion: 0,
                motionSpike: false,
                hrTrend: false,
                isStrongScore: false,
                consecutiveCount: consecutiveHighScoreCount,
                wakeConfidence: wakeConfidence,
                timeToAlarm: timeToAlarm,
                cooldownStatus: cooldown.description,
                triggerEligibility: false,
                finalDecision: "wait",
                reason: "warming_up"
            )
            return false
        }

        let scoringVitals = Array(allRecentVitals.suffix(scoringWindowSize))
        let smoothedVitals = smoothedSeries(from: allRecentVitals)
        let smoothedScoringVitals = Array(smoothedVitals.suffix(scoringWindowSize))
        let averages = resolveAverages(from: smoothedScoringVitals)

        let avgHR = DEBUG_MODE ? 85 : averages.avgHR
        let avgHRV = DEBUG_MODE ? 40 : averages.avgHRV
        let avgMotion = DEBUG_MODE ? 0.8 : averages.avgMotion

        let hrScore = normalize(avgHR, minValue: 50, maxValue: 100)
        let hrvScore = normalize(avgHRV, minValue: 20, maxValue: 80)
        let motionScore = normalize(avgMotion, minValue: 0.05, maxValue: 0.5)

        let baseScore =
            0.42 * hrScore +
            0.33 * (1 - hrvScore) +
            0.25 * motionScore

        let motionSpike = detectMotionSpike(rawData: scoringVitals, smoothedData: smoothedScoringVitals)
        let hrTrend = detectHRTrend(smoothedScoringVitals)

        let motionBoost = motionSpike ? 0.05 : 0
        let hrBoost = hrTrend ? 0.08 : 0
        let finalScore = clamp(baseScore + motionBoost + hrBoost, minValue: 0, maxValue: 1)
        let strongScoreThreshold = DEBUG_MODE ? 0.5 : 0.7
        let isStrongScore = finalScore > strongScoreThreshold

        let hasStrongSignal = motionSpike && (hrTrend || finalScore > minimumTriggerScore)

        if hasStrongSignal {
            consecutiveHighScoreCount += 1
        } else {
            consecutiveHighScoreCount = 0
        }

        let rawConfidenceDelta = confidenceDelta(
            motionSpike: motionSpike,
            hrTrend: hrTrend,
            finalScore: finalScore,
            withinWakeWindow: withinWakeWindow,
            consecutiveCount: consecutiveHighScoreCount
        )
        wakeConfidence = applyConfidenceDelta(rawConfidenceDelta)

        if DEBUG_MODE && finalScore > 0.5 && avgMotion > 0.3 {
            wakeConfidence = max(wakeConfidence, wakeConfidenceThreshold)
        }

        let isEligibleToTrigger =
            !cooldown.isActive &&
            (
                (
                    withinWakeWindow &&
                    motionSpike &&
                    (hrTrend || finalScore > minimumTriggerScore) &&
                    consecutiveHighScoreCount >= requiredConsecutiveCount &&
                    wakeConfidence >= wakeConfidenceThreshold
                ) ||
                (
                    DEBUG_MODE &&
                    finalScore > 0.5 &&
                    avgMotion > 0.3
                )
            )

        let finalDecision = isEligibleToTrigger ? "trigger" : "wait"
        let reason = evaluationReason(
            motionSpike: motionSpike,
            hrTrend: hrTrend,
            finalScore: finalScore,
            consecutiveCount: consecutiveHighScoreCount,
            withinWakeWindow: withinWakeWindow,
            triggerEligibility: isEligibleToTrigger
        )

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
            timeToAlarm: timeToAlarm,
            cooldownStatus: cooldown.description,
            triggerEligibility: isEligibleToTrigger,
            finalDecision: finalDecision,
            reason: reason
        )

        print("🚨 SHOULD TRIGGER:", isEligibleToTrigger)

        if !isEligibleToTrigger {
            print(
                "❌ Trigger blocked:",
                "strongScore=\(isStrongScore)",
                "motionSpike=\(motionSpike)",
                "hrTrend=\(hrTrend)",
                "consecutiveCount=\(consecutiveHighScoreCount)"
            )
        }

        if isEligibleToTrigger {
            hasTriggered = true
            lastTriggerTime = now
            consecutiveHighScoreCount = 0

            lastTriggerResult = TriggerResult(
                timestamp: now,
                finalScore: finalScore,
                avgHR: avgHR,
                avgHRV: avgHRV,
                avgMotion: avgMotion,
                reason: triggerReason(motionSpike: motionSpike, hrTrend: hrTrend)
            )

            triggerAlarm(
                baseScore: baseScore,
                finalScore: finalScore,
                motionSpike: motionSpike,
                hrTrend: hrTrend,
                wakeConfidence: wakeConfidence,
                timeToAlarm: timeToAlarm,
                cooldownStatus: cooldown.description,
                triggerEligibility: isEligibleToTrigger,
                reason: triggerReason(motionSpike: motionSpike, hrTrend: hrTrend)
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
        timeToAlarm: TimeInterval,
        cooldownStatus: String,
        triggerEligibility: Bool,
        reason: String
    ) {
        if let result = lastTriggerResult {
            NotificationManager.shared.triggerImmediateAlarm()
            print("⏰ WAKE UP TRIGGERED")
            print("🔥 Base Score:", formatted(baseScore))
            print("📈 Final Score:", formatted(finalScore))
            print("🏃 Motion Spike:", motionSpike)
            print("❤️ HR Trend:", hrTrend)
            print("💤 Wake Confidence:", formatted(wakeConfidence))
            print("⏳ Time To Alarm:", formattedMinutes(timeToAlarm))
            print("🧊 Cooldown Status:", cooldownStatus)
            print("✅ Trigger Eligibility:", triggerEligibility)
            print("📊 Consecutive Count:", requiredConsecutiveCount)
            print("🧠 Trigger Reason:", reason)
            print("✅ Final Decision: trigger")
            print("🕒 Trigger Timestamp:", result.timestamp)
            print("❤️ HR:", formatted(result.avgHR))
            print("💓 HRV:", formatted(result.avgHRV))
            print("🏃 Motion:", formatted(result.avgMotion))
        } else {
            print("⏰ WAKE UP TRIGGERED (no data)")
        }
    }

    private func latestVitalsWindow(limit: Int) -> [WatchVitalsModel] {
        DatabaseManager.shared
            .fetchRecentVitals(limit: limit)
            .sorted { $0.timestamp < $1.timestamp }
    }

    private func smoothedSeries(from vitals: [WatchVitalsModel]) -> [WatchVitalsModel] {
        guard !vitals.isEmpty else { return [] }

        var smoothed: [WatchVitalsModel] = []
        var previousHR = vitals[0].heartRate
        var previousMotion = vitals[0].motion

        for index in vitals.indices {
            let hrWindow = vitals[max(0, index - 2)...index].map(\.heartRate)
            let motionWindow = vitals[max(0, index - 2)...index].map(\.motion)

            let movingAverageHR = average(for: hrWindow)
            let movingAverageMotion = average(for: motionWindow)

            let smoothedHR = lowPass(current: movingAverageHR, previous: previousHR, alpha: 0.45)
            let smoothedMotion = lowPass(current: movingAverageMotion, previous: previousMotion, alpha: 0.35)

            previousHR = smoothedHR
            previousMotion = smoothedMotion

            smoothed.append(
                WatchVitalsModel(
                    timestamp: vitals[index].timestamp,
                    heartRate: smoothedHR,
                    hrv: vitals[index].hrv,
                    motion: smoothedMotion,
                    respiratoryRate: vitals[index].respiratoryRate,
                    wristTemp: vitals[index].wristTemp,
                    oxygenSaturation: vitals[index].oxygenSaturation
                )
            )
        }

        return smoothed
    }

    private func resolveAverages(from vitals: [WatchVitalsModel]) -> (avgHR: Double, avgHRV: Double, avgMotion: Double) {
        if !vitals.isEmpty {
            let averages = makeAverages(from: vitals)
            lastKnownAverages = averages
            return averages
        }

        return lastKnownAverages ?? (0, 0, 0)
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

    private func detectMotionSpike(rawData: [WatchVitalsModel], smoothedData: [WatchVitalsModel]) -> Bool {
        guard rawData.count >= 3, smoothedData.count >= 3 else { return false }

        let rawLastThree = Array(rawData.suffix(3))
        let smoothedLastThree = Array(smoothedData.suffix(3))

        let rawBaseline = average(for: [rawLastThree[0].motion, rawLastThree[1].motion])
        let smoothedBaseline = average(for: [smoothedLastThree[0].motion, smoothedLastThree[1].motion])
        let latestRawMotion = rawLastThree[2].motion
        let latestSmoothedMotion = smoothedLastThree[2].motion

        let rawDelta = latestRawMotion - rawBaseline
        let smoothedDelta = latestSmoothedMotion - smoothedBaseline

        return latestSmoothedMotion >= motionSpikeThreshold &&
            rawDelta >= motionDeltaThreshold &&
            smoothedDelta >= motionDeltaThreshold * 0.6
    }

    private func detectHRTrend(_ data: [WatchVitalsModel]) -> Bool {
        guard data.count >= 3 else { return false }

        let lastThree = Array(data.suffix(3))
        let firstIncrease = lastThree[1].heartRate - lastThree[0].heartRate
        let secondIncrease = lastThree[2].heartRate - lastThree[1].heartRate
        let totalIncrease = lastThree[2].heartRate - lastThree[0].heartRate

        return firstIncrease >= hrStepIncreaseThreshold &&
            secondIncrease >= hrStepIncreaseThreshold &&
            totalIncrease >= hrTotalIncreaseThreshold
    }

    private func confidenceDelta(
        motionSpike: Bool,
        hrTrend: Bool,
        finalScore: Double,
        withinWakeWindow: Bool,
        consecutiveCount: Int
    ) -> Double {
        var delta = -0.04

        if motionSpike && hrTrend {
            delta = 0.18
        } else if motionSpike && finalScore > minimumTriggerScore {
            delta = 0.12
        } else if hrTrend && finalScore > 0.58 {
            delta = 0.08
        } else if finalScore > 0.62 {
            delta = 0.04
        }

        if consecutiveCount >= requiredConsecutiveCount {
            delta += 0.06
        }

        if withinWakeWindow {
            delta += 0.03
        }

        return delta
    }

    private func applyConfidenceDelta(_ delta: Double) -> Double {
        let nextValue = wakeConfidence + (delta * confidenceSmoothingFactor)
        return clamp(nextValue, minValue: 0, maxValue: 1)
    }

    private func cooldownStatus(at now: Date) -> (isActive: Bool, description: String) {
        guard let lastTriggerTime else {
            return (false, "inactive")
        }

        let elapsed = now.timeIntervalSince(lastTriggerTime)

        guard elapsed < cooldownDuration else {
            return (false, "inactive")
        }

        let remaining = cooldownDuration - elapsed
        return (true, "active (\(formattedMinutes(remaining)) remaining)")
    }

    private func evaluationReason(
        motionSpike: Bool,
        hrTrend: Bool,
        finalScore: Double,
        consecutiveCount: Int,
        withinWakeWindow: Bool,
        triggerEligibility: Bool
    ) -> String {
        if triggerEligibility {
            return triggerReason(motionSpike: motionSpike, hrTrend: hrTrend)
        }

        if !withinWakeWindow {
            return "outside_wake_window"
        }

        if !motionSpike {
            return "awaiting_motion_confirmation"
        }

        if !(hrTrend || finalScore > minimumTriggerScore) {
            return "awaiting_multi_signal_confirmation"
        }

        if consecutiveCount < requiredConsecutiveCount {
            return "awaiting_consecutive_validation"
        }

        return "building_confidence"
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
        timeToAlarm: TimeInterval,
        cooldownStatus: String,
        triggerEligibility: Bool,
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
        print("⏳ Time To Alarm:", formattedMinutes(timeToAlarm))
        print("🧊 Cooldown Status:", cooldownStatus)
        print("✅ Trigger Eligibility:", triggerEligibility)
        print("🧾 Final Decision:", finalDecision)
        print("🧠 Trigger Reason:", reason)
    }

    private func average(for values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private func normalize(_ value: Double, minValue: Double, maxValue: Double) -> Double {
        let normalized = (value - minValue) / (maxValue - minValue)
        return clamp(normalized, minValue: 0, maxValue: 1)
    }

    private func lowPass(current: Double, previous: Double, alpha: Double) -> Double {
        previous + alpha * (current - previous)
    }

    private func clamp(_ value: Double, minValue: Double, maxValue: Double) -> Double {
        Swift.max(minValue, Swift.min(maxValue, value))
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%.3f", value)
    }

    private func formattedMinutes(_ timeInterval: TimeInterval) -> String {
        String(format: "%.1f min", timeInterval / 60)
    }
}
