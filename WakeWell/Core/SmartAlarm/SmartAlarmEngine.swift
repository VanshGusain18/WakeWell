import Foundation

struct WakeDecision {
    let shouldTrigger: Bool
    let confidence: Double
    let reason: String
}

final class SmartAlarmEngine {

    static let shared = SmartAlarmEngine()

    // MARK: - Tunable Constants

    private let minimumRequiredSamples = 8
    private let analysisWindowSize = 10
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
    private var lastKnownAverages: VitalAverages?

    private var lastMotionValues: [Double] = []
    private var lastHRValues: [Double] = []
    private var lastHRVValues: [Double] = []

    private(set) var lastTriggerResult: TriggerResult?

    // MARK: - Public

    func reset() {
        hasTriggered = false
        wakeConfidence = 0
        consecutiveHighScoreCount = 0
        lastTriggerTime = nil
        lastKnownAverages = nil
        lastMotionValues = []
        lastHRValues = []
        lastHRVValues = []
        lastTriggerResult = nil
        print("[SmartAlarm] engine reset")
    }

    func evaluateWakeOpportunity() -> WakeDecision {
        let now = Date()

        if let cooldownDecision = cooldownDecision(at: now) {
            logDecision(
                averages: VitalAverages.zero,
                score: ScoreBreakdown.zero,
                signals: SignalState.none,
                analysis: TrendAnalysis.zero,
                timeToAlarm: remainingTimeToAlarm(from: now) ?? 0,
                decision: cooldownDecision
            )
            return cooldownDecision
        }

        if hasTriggered {
            let decision = WakeDecision(
                shouldTrigger: false,
                confidence: wakeConfidence,
                reason: "already_triggered"
            )

            logDecision(
                averages: lastKnownAverages ?? .zero,
                score: .zero,
                signals: .none,
                analysis: .zero,
                timeToAlarm: remainingTimeToAlarm(from: now) ?? 0,
                decision: decision
            )
            return decision
        }

        guard let wakeTime = AlarmManager.shared.getWakeTime() else {
            let decision = WakeDecision(
                shouldTrigger: false,
                confidence: wakeConfidence,
                reason: "no_alarm_set"
            )

            logDecision(
                averages: lastKnownAverages ?? .zero,
                score: .zero,
                signals: .none,
                analysis: .zero,
                timeToAlarm: 0,
                decision: decision
            )
            return decision
        }

        let timeToAlarm = wakeTime.timeIntervalSince(now)

        if timeToAlarm <= 0 {
            return makeFallbackDecision(at: now, timeToAlarm: timeToAlarm)
        }

        let vitals = fetchRecentVitals()

        guard vitals.count >= minimumRequiredSamples else {
            consecutiveHighScoreCount = 0
            wakeConfidence = applyConfidenceDelta(-0.04)

            let decision = WakeDecision(
                shouldTrigger: false,
                confidence: wakeConfidence,
                reason: "warming_up"
            )

            logDecision(
                averages: .zero,
                score: .zero,
                signals: .none,
                analysis: .zero,
                timeToAlarm: timeToAlarm,
                decision: decision
            )
            return decision
        }

        let smoothedVitals = smoothedSeries(from: vitals)
        let scoringRawVitals = Array(vitals.suffix(scoringWindowSize))
        let scoringSmoothedVitals = Array(smoothedVitals.suffix(scoringWindowSize))

        let averages = resolveAverages(from: scoringSmoothedVitals)
        updateSignalWindows(with: averages)

        let analysis = analyzeTrends(rawVitals: scoringRawVitals, smoothedVitals: scoringSmoothedVitals)
        let signals = SignalState(
            motionSpike: analysis.motionSpike,
            hrTrend: analysis.hrTrend
        )
        let score = computeScore(from: averages, signals: signals)

        updateConsecutiveCount(using: score, signals: signals)

        let withinWakeWindow = timeToAlarm <= triggerWakeWindow
        wakeConfidence = updateConfidence(
            with: score,
            signals: signals,
            withinWakeWindow: withinWakeWindow
        )

        let shouldTrigger = shouldTrigger(
            score: score,
            signals: signals,
            withinWakeWindow: withinWakeWindow
        )

        let reason = shouldTrigger ? "smart_detection" : decisionReason(
            score: score,
            signals: signals,
            withinWakeWindow: withinWakeWindow
        )

        let decision = WakeDecision(
            shouldTrigger: shouldTrigger,
            confidence: wakeConfidence,
            reason: reason
        )

        logSignalWindow()
        logTrendAnalysis(analysis)
        logDecision(
            averages: averages,
            score: score,
            signals: signals,
            analysis: analysis,
            timeToAlarm: timeToAlarm,
            decision: decision
        )

        if shouldTrigger {
            hasTriggered = true
            lastTriggerTime = now

            lastTriggerResult = TriggerResult(
                timestamp: now,
                finalScore: score.finalScore,
                avgHR: averages.avgHR,
                avgHRV: averages.avgHRV,
                avgMotion: averages.avgMotion,
                reason: "smart_detection"
            )

            logTriggered(
                reason: "smart_detection",
                confidence: wakeConfidence,
                score: score.finalScore,
                timeToAlarm: timeToAlarm,
                usedFallback: false
            )
        }

        return decision
    }

    // MARK: - Evaluation Pipeline

    private func fetchRecentVitals() -> [WatchVitalsModel] {
        DatabaseManager.shared
            .fetchRecentVitals(limit: analysisWindowSize)
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

    private func resolveAverages(from vitals: [WatchVitalsModel]) -> VitalAverages {
        if !vitals.isEmpty {
            let averages = VitalAverages(
                avgHR: average(for: vitals.map(\.heartRate)),
                avgHRV: average(for: vitals.map(\.hrv)),
                avgMotion: average(for: vitals.map(\.motion))
            )
            lastKnownAverages = averages
            return averages
        }

        return lastKnownAverages ?? .zero
    }

    private func updateSignalWindows(with averages: VitalAverages) {
        appendWindowValue(&lastMotionValues, value: averages.avgMotion)
        appendWindowValue(&lastHRValues, value: averages.avgHR)
        appendWindowValue(&lastHRVValues, value: averages.avgHRV)
    }

    private func analyzeTrends(rawVitals: [WatchVitalsModel], smoothedVitals: [WatchVitalsModel]) -> TrendAnalysis {
        let motionDelta = calculateMotionDelta(rawVitals: rawVitals, smoothedVitals: smoothedVitals)
        let hrDelta = calculateHRDelta(smoothedVitals: smoothedVitals)

        return TrendAnalysis(
            hrTrend: hrDelta >= hrTotalIncreaseThreshold && isHRIncreasing(smoothedVitals),
            motionSpike: motionDelta.latestMotion >= motionSpikeThreshold &&
                motionDelta.rawDelta >= motionDeltaThreshold &&
                motionDelta.smoothedDelta >= motionDeltaThreshold * 0.6,
            motionDelta: motionDelta.rawDelta,
            hrDelta: hrDelta
        )
    }

    private func computeScore(from averages: VitalAverages, signals: SignalState) -> ScoreBreakdown {
        let hrScore = normalize(averages.avgHR, minValue: 50, maxValue: 100)
        let hrvScore = normalize(averages.avgHRV, minValue: 20, maxValue: 80)
        let motionScore = normalize(averages.avgMotion, minValue: 0.05, maxValue: 0.5)

        let baseScore =
            0.42 * hrScore +
            0.33 * (1 - hrvScore) +
            0.25 * motionScore

        let motionBoost = signals.motionSpike ? 0.05 : 0
        let hrBoost = signals.hrTrend ? 0.08 : 0
        let finalScore = clamp(baseScore + motionBoost + hrBoost, minValue: 0, maxValue: 1)

        return ScoreBreakdown(
            baseScore: baseScore,
            finalScore: finalScore
        )
    }

    private func updateConsecutiveCount(using score: ScoreBreakdown, signals: SignalState) {
        let hasStrongSignal = signals.motionSpike && (signals.hrTrend || score.finalScore > minimumTriggerScore)

        if hasStrongSignal {
            consecutiveHighScoreCount += 1
        } else {
            consecutiveHighScoreCount = 0
        }
    }

    private func updateConfidence(
        with score: ScoreBreakdown,
        signals: SignalState,
        withinWakeWindow: Bool
    ) -> Double {
        let delta = confidenceDelta(
            score: score,
            signals: signals,
            withinWakeWindow: withinWakeWindow,
            consecutiveCount: consecutiveHighScoreCount
        )

        return applyConfidenceDelta(delta)
    }

    private func shouldTrigger(
        score: ScoreBreakdown,
        signals: SignalState,
        withinWakeWindow: Bool
    ) -> Bool {
        withinWakeWindow &&
            signals.motionSpike &&
            signals.hrTrend &&
            consecutiveHighScoreCount >= requiredConsecutiveCount &&
            wakeConfidence >= wakeConfidenceThreshold
    }

    // MARK: - Signal Analysis

    private func calculateMotionDelta(
        rawVitals: [WatchVitalsModel],
        smoothedVitals: [WatchVitalsModel]
    ) -> MotionDelta {
        guard rawVitals.count >= 3, smoothedVitals.count >= 3 else {
            return .zero
        }

        let rawLastThree = Array(rawVitals.suffix(3))
        let smoothedLastThree = Array(smoothedVitals.suffix(3))

        let rawBaseline = average(for: [rawLastThree[0].motion, rawLastThree[1].motion])
        let smoothedBaseline = average(for: [smoothedLastThree[0].motion, smoothedLastThree[1].motion])
        let latestRawMotion = rawLastThree[2].motion
        let latestSmoothedMotion = smoothedLastThree[2].motion

        return MotionDelta(
            rawDelta: latestRawMotion - rawBaseline,
            smoothedDelta: latestSmoothedMotion - smoothedBaseline,
            latestMotion: latestSmoothedMotion
        )
    }

    private func calculateHRDelta(smoothedVitals: [WatchVitalsModel]) -> Double {
        guard smoothedVitals.count >= 3 else { return 0 }
        let lastThree = Array(smoothedVitals.suffix(3))
        return lastThree[2].heartRate - lastThree[0].heartRate
    }

    private func isHRIncreasing(_ vitals: [WatchVitalsModel]) -> Bool {
        guard vitals.count >= 3 else { return false }
        let lastThree = Array(vitals.suffix(3))
        let firstIncrease = lastThree[1].heartRate - lastThree[0].heartRate
        let secondIncrease = lastThree[2].heartRate - lastThree[1].heartRate

        return firstIncrease >= hrStepIncreaseThreshold &&
            secondIncrease >= hrStepIncreaseThreshold
    }

    // MARK: - Decision Helpers

    private func confidenceDelta(
        score: ScoreBreakdown,
        signals: SignalState,
        withinWakeWindow: Bool,
        consecutiveCount: Int
    ) -> Double {
        var delta = -0.04

        if signals.motionSpike && signals.hrTrend {
            delta = 0.18
        } else if signals.motionSpike && score.finalScore > minimumTriggerScore {
            delta = 0.10
        } else if signals.hrTrend && score.finalScore > 0.58 {
            delta = 0.08
        } else if score.finalScore > 0.62 {
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

    private func cooldownDecision(at now: Date) -> WakeDecision? {
        guard let lastTriggerTime else { return nil }

        let elapsed = now.timeIntervalSince(lastTriggerTime)
        guard elapsed < cooldownDuration else { return nil }

        return WakeDecision(
            shouldTrigger: false,
            confidence: wakeConfidence,
            reason: "cooldown_active"
        )
    }

    private func makeFallbackDecision(at now: Date, timeToAlarm: TimeInterval) -> WakeDecision {
        let averages = resolveAverages(from: fetchRecentVitals())

        hasTriggered = true
        lastTriggerTime = now
        wakeConfidence = 1
        consecutiveHighScoreCount = 0

        lastTriggerResult = TriggerResult(
            timestamp: now,
            finalScore: 1.0,
            avgHR: averages.avgHR,
            avgHRV: averages.avgHRV,
            avgMotion: averages.avgMotion,
            reason: "fallback"
        )

        print("⚠️ FALLBACK TRIGGER USED")
        logTriggered(
            reason: "fallback",
            confidence: wakeConfidence,
            score: 1.0,
            timeToAlarm: timeToAlarm,
            usedFallback: true
        )

        let decision = WakeDecision(
            shouldTrigger: true,
            confidence: wakeConfidence,
            reason: "fallback"
        )

        logDecision(
            averages: averages,
            score: ScoreBreakdown(baseScore: 1.0, finalScore: 1.0),
            signals: .none,
            analysis: .zero,
            timeToAlarm: timeToAlarm,
            decision: decision
        )

        return decision
    }

    private func decisionReason(
        score: ScoreBreakdown,
        signals: SignalState,
        withinWakeWindow: Bool
    ) -> String {
        if !withinWakeWindow {
            return "outside_wake_window"
        }

        if !signals.motionSpike {
            return "awaiting_motion_confirmation"
        }

        if !signals.hrTrend {
            return "awaiting_hr_confirmation"
        }

        if score.finalScore <= minimumTriggerScore {
            return "score_below_threshold"
        }

        if consecutiveHighScoreCount < requiredConsecutiveCount {
            return "awaiting_consecutive_validation"
        }

        if wakeConfidence < wakeConfidenceThreshold {
            return "building_confidence"
        }

        return "not_ready"
    }

    // MARK: - Logging

    private func logSignalWindow() {
        print("📊 SIGNAL WINDOW:")
        print("- Motion: \(formattedWindow(lastMotionValues))")
        print("- HR: \(formattedWindow(lastHRValues))")
        print("- HRV: \(formattedWindow(lastHRVValues))")
    }

    private func logTrendAnalysis(_ analysis: TrendAnalysis) {
        print("""
          📈 TREND ANALYSIS:
          
          * HR increasing: \(analysis.hrTrend)
          * motion spike detected: \(analysis.motionSpike)
          * motion delta: \(formatted(analysis.motionDelta))
          * HR delta: \(formatted(analysis.hrDelta))
          """)
    }

    private func logDecision(
        averages: VitalAverages,
        score: ScoreBreakdown,
        signals: SignalState,
        analysis: TrendAnalysis,
        timeToAlarm: TimeInterval,
        decision: WakeDecision
    ) {
        print("[SmartAlarm]")
        print("- avgHR:", formatted(averages.avgHR))
        print("- avgHRV:", formatted(averages.avgHRV))
        print("- avgMotion:", formatted(averages.avgMotion))
        print("- score:", formatted(score.finalScore))
        print("- confidence:", formatted(decision.confidence))
        print("- reason:", decision.reason)
        print("- decision:", decision.shouldTrigger ? "trigger" : "wait")

        print("""
          DECISION CHECK:
          * score: \(formatted(score.finalScore))
          * confidence: \(formatted(decision.confidence))
          * threshold: \(formatted(wakeConfidenceThreshold))
          * motionSpike: \(signals.motionSpike)
          * hrTrend: \(signals.hrTrend)
          * consecutiveCount: \(consecutiveHighScoreCount)
          * shouldTrigger: \(decision.shouldTrigger)
          """)
    }

    private func logTriggered(
        reason: String,
        confidence: Double,
        score: Double,
        timeToAlarm: TimeInterval,
        usedFallback: Bool
    ) {
        print("""
          🚨 TRIGGERED:
          
          * reason: \(reason)
          * confidence: \(formatted(confidence))
          * score: \(formatted(score))
          * timeToAlarm: \(formattedMinutes(timeToAlarm))
          * usedFallback: \(usedFallback)
          """)
    }

    // MARK: - Utilities

    private func remainingTimeToAlarm(from now: Date) -> TimeInterval? {
        guard let wakeTime = AlarmManager.shared.getWakeTime() else { return nil }
        return wakeTime.timeIntervalSince(now)
    }

    private func appendWindowValue(_ values: inout [Double], value: Double) {
        values.append(value)
        if values.count > analysisWindowSize {
            values.removeFirst()
        }
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

    private func formattedWindow(_ values: [Double]) -> String {
        values.map { formatted($0) }.joined(separator: ", ")
    }
}

private struct VitalAverages {
    let avgHR: Double
    let avgHRV: Double
    let avgMotion: Double

    static let zero = VitalAverages(avgHR: 0, avgHRV: 0, avgMotion: 0)
}

private struct SignalState {
    let motionSpike: Bool
    let hrTrend: Bool

    static let none = SignalState(motionSpike: false, hrTrend: false)
}

private struct ScoreBreakdown {
    let baseScore: Double
    let finalScore: Double

    static let zero = ScoreBreakdown(baseScore: 0, finalScore: 0)
}

private struct MotionDelta {
    let rawDelta: Double
    let smoothedDelta: Double
    let latestMotion: Double

    static let zero = MotionDelta(rawDelta: 0, smoothedDelta: 0, latestMotion: 0)
}

private struct TrendAnalysis {
    let hrTrend: Bool
    let motionSpike: Bool
    let motionDelta: Double
    let hrDelta: Double

    static let zero = TrendAnalysis(hrTrend: false, motionSpike: false, motionDelta: 0, hrDelta: 0)
}
