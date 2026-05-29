import Foundation

enum AlarmState: String {
    case idle
    case monitoring
    case triggered
}

struct SmartAlarmDebugSnapshot {
    let currentHR: Double
    let currentHRV: Double
    let currentMotion: Double
    let avgHR: Double
    let avgHRV: Double
    let avgMotion: Double
    let confidence: Double
    let score: Double
    let threshold: Double
    let motionIncreasingCount: Int
    let currentPhase: String
    let alarmState: AlarmState
    let decisionReason: String
    let timeToAlarm: String

    static let empty = SmartAlarmDebugSnapshot(
        currentHR: 0,
        currentHRV: 0,
        currentMotion: 0,
        avgHR: 0,
        avgHRV: 0,
        avgMotion: 0,
        confidence: 0,
        score: 0,
        threshold: 0.70,
        motionIncreasingCount: 0,
        currentPhase: "idle",
        alarmState: .idle,
        decisionReason: "waiting_for_alarm",
        timeToAlarm: "--"
    )
}

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
    private let requiredMotionIncreaseCount = 5
    private let triggerWakeWindow: TimeInterval = 15 * 60
    private let safetyTriggerWindow: TimeInterval = 5 * 60
    private let cooldownDuration: TimeInterval = 10 * 60

    private let optimalTriggerThreshold = 0.70
    private let earlySafeTriggerThreshold = 0.55
    private let minimumTriggerScore = 0.65
    private let confidenceSmoothingFactor = 0.45

    private let motionSpikeThreshold = 0.55
    private let motionDeltaThreshold = 0.07
    private let motionSpikeRatioThreshold = 1.25
    private let hrStepIncreaseThreshold = 0.45
    private let hrTotalIncreaseThreshold = 2.0

    // MARK: - State

    private var hasTriggered = false
    private var wakeConfidence: Double = 0
    private var consecutiveHighScoreCount = 0
    private var motionIncreasingCount = 0
    private var lastTriggerTime: Date?
    private var lastKnownAverages: VitalAverages?
    private var latestLiveInput = InputSnapshot.zero
    private var currentPhaseLabel = "idle"

    private var lastMotionValues: [Double] = []
    private var lastHRValues: [Double] = []
    private var lastHRVValues: [Double] = []

    private(set) var alarmState: AlarmState = .idle
    private(set) var debugSnapshot = SmartAlarmDebugSnapshot.empty
    private(set) var lastTriggerResult: TriggerResult?

    // MARK: - Public

    func beginMonitoring() {
        transitionState(to: .monitoring)
    }

    func recordCurrentInput(heartRate: Double, hrv: Double?, motion: Double, phase: String) {
        latestLiveInput = InputSnapshot(
            motion: motion,
            hr: heartRate,
            hrv: hrv
        )
        currentPhaseLabel = phase
    }

    func process(vital data: VitalData) -> WakeDecision {
        recordCurrentInput(
            heartRate: data.heartRate,
            hrv: data.hrv,
            motion: data.motion,
            phase: data.phase
        )
        return evaluateWakeOpportunity()
    }

    func reset() {
        hasTriggered = false
        wakeConfidence = 0
        consecutiveHighScoreCount = 0
        motionIncreasingCount = 0
        lastTriggerTime = nil
        lastKnownAverages = nil
        latestLiveInput = .zero
        currentPhaseLabel = "idle"
        lastMotionValues = []
        lastHRValues = []
        lastHRVValues = []
        debugSnapshot = .empty
        lastTriggerResult = nil
        transitionState(to: .idle)
        publishDebugSnapshot(debugSnapshot)
    }

    func evaluateWakeOpportunity() -> WakeDecision {
        let now = Date()

        if let connectionDecision = watchConnectionDecision() {
            return connectionDecision
        }

        if let cooldownDecision = cooldownDecision(at: now) {
            logDecision(
                averages: VitalAverages.zero,
                score: ScoreBreakdown.zero,
                signals: SignalState.none,
                analysis: TrendAnalysis.zero,
                components: .zero,
                triggerEvaluation: TriggerEvaluation(
                    shouldTrigger: false,
                    type: .none,
                    thresholdUsed: optimalTriggerThreshold,
                    reason: "cooldown_active"
                ),
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
                components: .zero,
                triggerEvaluation: TriggerEvaluation(
                    shouldTrigger: false,
                    type: .none,
                    thresholdUsed: optimalTriggerThreshold,
                    reason: "already_triggered"
                ),
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
                components: .zero,
                triggerEvaluation: TriggerEvaluation(
                    shouldTrigger: false,
                    type: .none,
                    thresholdUsed: optimalTriggerThreshold,
                    reason: "no_alarm_set"
                ),
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

        guard hasContinuousSignalWindow(vitals) else {
            freezeSignalState()
            let decision = noDecision(reason: "stale_watch_data")
            return decision
        }

        guard vitals.count >= minimumRequiredSamples else {
            consecutiveHighScoreCount = 0
            motionIncreasingCount = 0
            wakeConfidence = max(0, wakeConfidence - 0.04)

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
                components: .zero,
                triggerEvaluation: TriggerEvaluation(
                    shouldTrigger: false,
                    type: .none,
                    thresholdUsed: optimalTriggerThreshold,
                    reason: "warming_up"
                ),
                timeToAlarm: timeToAlarm,
                decision: decision
            )
            return decision
        }

        let smoothedVitals = smoothedSeries(from: vitals)
        let scoringRawVitals = Array(vitals.suffix(scoringWindowSize))
        let scoringSmoothedVitals = Array(smoothedVitals.suffix(scoringWindowSize))

        let input = latestInput(from: scoringRawVitals)
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
        let components = buildConfidenceComponents(
            score: score,
            signals: signals,
            analysis: analysis,
            timeToAlarm: timeToAlarm,
            withinWakeWindow: withinWakeWindow
        )
        wakeConfidence = updateConfidence(using: components)

        let triggerEvaluation = evaluateTrigger(
            score: score,
            signals: signals,
            analysis: analysis,
            remainingTimeToAlarm: timeToAlarm,
            withinWakeWindow: withinWakeWindow
        )
        let shouldTrigger = safeTriggerAllowed(triggerEvaluation)

        let reason = shouldTrigger ? triggerEvaluation.reason : decisionReason(
            score: score,
            signals: signals,
            analysis: analysis,
            withinWakeWindow: withinWakeWindow
        )

        let decision = WakeDecision(
            shouldTrigger: shouldTrigger,
            confidence: wakeConfidence,
            reason: reason
        )

        logInput(input)
        logSignalWindow()
        logTrendAnalysis(analysis)
        logDecision(
            averages: averages,
            score: score,
            signals: signals,
            analysis: analysis,
            components: components,
            triggerEvaluation: triggerEvaluation,
            timeToAlarm: timeToAlarm,
            decision: decision
        )

        if shouldTrigger {
            hasTriggered = true
            lastTriggerTime = now
            transitionState(to: .triggered)

            lastTriggerResult = TriggerResult(
                timestamp: now,
                finalScore: score.finalScore,
                avgHR: averages.avgHR,
                avgHRV: averages.avgHRV,
                avgMotion: averages.avgMotion,
                reason: shouldTrigger ? triggerEvaluation.reason : "safe_trigger_blocked"
            )

            logTriggerPath(triggerEvaluation, confidence: wakeConfidence)
            logTriggered(
                reason: triggerEvaluation.reason,
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

    private func hasContinuousSignalWindow(_ vitals: [WatchVitalsModel]) -> Bool {
        guard let latest = vitals.last else { return false }
        guard Date().timeIntervalSince(latest.timestamp) <= 20 else { return false }
        guard vitals.count >= minimumRequiredSamples else { return true }

        let gaps = zip(vitals.dropFirst(), vitals).map {
            $0.0.timestamp.timeIntervalSince($0.1.timestamp)
        }

        return gaps.allSatisfy { $0 <= 20 }
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

    private func latestInput(from vitals: [WatchVitalsModel]) -> InputSnapshot {
        if latestLiveInput != .zero {
            return latestLiveInput
        }

        guard let latest = vitals.last else { return .zero }

        return InputSnapshot(
            motion: latest.motion,
            hr: latest.heartRate,
            hrv: latest.hrv
        )
    }

    private func resolveAverages(from vitals: [WatchVitalsModel]) -> VitalAverages {
        if !vitals.isEmpty {
            let validHRVValues = vitals.compactMap(\.hrv).filter { $0 > 0 }
            if validHRVValues.isEmpty {
            }

            let averages = VitalAverages(
                avgHR: average(for: vitals.map(\.heartRate)),
                avgHRV: validHRVValues.isEmpty ? nil : average(for: validHRVValues),
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
        if let avgHRV = averages.avgHRV {
            appendWindowValue(&lastHRVValues, value: avgHRV)
        }
    }

    private func analyzeTrends(rawVitals: [WatchVitalsModel], smoothedVitals: [WatchVitalsModel]) -> TrendAnalysis {
        let motionDelta = calculateMotionDelta(rawVitals: rawVitals, smoothedVitals: smoothedVitals)
        let hrDelta = calculateHRDelta(smoothedVitals: smoothedVitals)
        let hrTrend = isHRIncreasing(smoothedVitals)
        let motionSpike = isMotionSpikeDetected(motionDelta)
        let motionIncreasing = isMotionIncreasing(smoothedVitals)
        updateMotionIncreasingCount(isIncreasing: motionIncreasing)

        return TrendAnalysis(
            hrTrend: hrTrend,
            motionSpike: motionSpike,
            motionIncreasing: motionIncreasing,
            motionDelta: motionDelta.rawDelta,
            hrDelta: hrDelta
        )
    }

    private func computeScore(from averages: VitalAverages, signals: SignalState) -> ScoreBreakdown {
        let hrScore = normalize(averages.avgHR, minValue: 50, maxValue: 100)
        let motionScore = normalize(averages.avgMotion, minValue: 0.05, maxValue: 0.5)

        var baseScore =
            0.62 * hrScore +
            0.38 * motionScore

        if let avgHRV = averages.avgHRV, avgHRV > 0 {
            let hrvScore = normalize(avgHRV, minValue: 20, maxValue: 80)
            baseScore += 0.05 * (1 - hrvScore)
        } else {
        }

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

    private func buildConfidenceComponents(
        score: ScoreBreakdown,
        signals: SignalState,
        analysis: TrendAnalysis,
        timeToAlarm: TimeInterval,
        withinWakeWindow: Bool
    ) -> ConfidenceComponents {
        let baseScore = clamp((score.finalScore - 0.20) * 1.45, minValue: 0, maxValue: 0.58)
        var trendBonus = signals.hrTrend ? 0.28 : 0
        if signals.hrTrend && analysis.motionIncreasing {
            trendBonus += 0.10
        }
        let spikeBonus = signals.motionSpike ? 0.22 : 0
        let consecutiveBonus = min(Double(consecutiveHighScoreCount) * 0.08, 0.24)
        let motionIncreaseBonus = min(Double(motionIncreasingCount) * 0.035, 0.16)
        let hrvTransitionBonus: Double = 0
        let wakeWindowBonus = withinWakeWindow ? 0.05 : 0
        let timePressureBonus = timeToAlarm <= safetyTriggerWindow ? 0.05 : 0
        let targetConfidence = clamp(
            baseScore +
                trendBonus +
                spikeBonus +
                consecutiveBonus +
                motionIncreaseBonus +
                hrvTransitionBonus +
                wakeWindowBonus +
                timePressureBonus,
            minValue: 0,
            maxValue: 1
        )

        return ConfidenceComponents(
            baseScore: baseScore,
            trendBonus: trendBonus,
            spikeBonus: spikeBonus,
            consecutiveBonus: consecutiveBonus,
            motionIncreaseBonus: motionIncreaseBonus,
            hrvTransitionBonus: hrvTransitionBonus,
            wakeWindowBonus: wakeWindowBonus,
            timePressureBonus: timePressureBonus,
            targetConfidence: targetConfidence
        )
    }

    private func updateConfidence(using components: ConfidenceComponents) -> Double {
        let nextValue = wakeConfidence + (components.targetConfidence - wakeConfidence) * confidenceSmoothingFactor
        return clamp(nextValue, minValue: 0, maxValue: 1)
    }

    private func evaluateTrigger(
        score: ScoreBreakdown,
        signals: SignalState,
        analysis: TrendAnalysis,
        remainingTimeToAlarm: TimeInterval,
        withinWakeWindow: Bool
    ) -> TriggerEvaluation {
        guard withinWakeWindow else {
            return TriggerEvaluation(
                shouldTrigger: false,
                type: .none,
                thresholdUsed: optimalTriggerThreshold,
                reason: "outside_wake_window"
            )
        }

        if wakeConfidence >= optimalTriggerThreshold {
            return TriggerEvaluation(
                shouldTrigger: true,
                type: .optimal,
                thresholdUsed: optimalTriggerThreshold,
                reason: "confidence_reached_optimal_threshold"
            )
        }

        if motionIncreasingCount >= requiredMotionIncreaseCount &&
            wakeConfidence >= earlySafeTriggerThreshold &&
            remainingTimeToAlarm <= safetyTriggerWindow {
            return TriggerEvaluation(
                shouldTrigger: true,
                type: .earlySafe,
                thresholdUsed: earlySafeTriggerThreshold,
                reason: "motion_trend_confirmed_near_alarm"
            )
        }

        let thresholdUsed = remainingTimeToAlarm <= safetyTriggerWindow
            ? earlySafeTriggerThreshold
            : optimalTriggerThreshold
        let reason: String

        if wakeConfidence < thresholdUsed {
            reason = "confidence_below_threshold"
        } else if motionIncreasingCount < requiredMotionIncreaseCount && remainingTimeToAlarm <= safetyTriggerWindow {
            reason = "insufficient_motion_trend_for_early_safe"
        } else if !signals.hrTrend && !analysis.motionIncreasing {
            reason = "awaiting_wake_trends"
        } else {
            reason = "not_ready"
        }

        return TriggerEvaluation(
            shouldTrigger: false,
            type: .none,
            thresholdUsed: thresholdUsed,
            reason: reason
        )
    }

    // MARK: - Signal Analysis

    private func calculateMotionDelta(
        rawVitals: [WatchVitalsModel],
        smoothedVitals: [WatchVitalsModel]
    ) -> MotionDelta {
        guard rawVitals.count >= 5, smoothedVitals.count >= 5 else {
            return .zero
        }

        let rawWindow = Array(rawVitals.suffix(5))
        let smoothedWindow = Array(smoothedVitals.suffix(5))

        let rawBaseline = average(for: Array(rawWindow.prefix(3)).map(\.motion))
        let smoothedBaseline = average(for: Array(smoothedWindow.prefix(3)).map(\.motion))
        let latestRawMotion = average(for: Array(rawWindow.suffix(2)).map(\.motion))
        let latestSmoothedMotion = average(for: Array(smoothedWindow.suffix(2)).map(\.motion))
        let motionRatio = smoothedBaseline > 0 ? latestSmoothedMotion / smoothedBaseline : 0

        return MotionDelta(
            rawDelta: latestRawMotion - rawBaseline,
            smoothedDelta: latestSmoothedMotion - smoothedBaseline,
            latestMotion: latestSmoothedMotion,
            motionRatio: motionRatio
        )
    }

    private func calculateHRDelta(smoothedVitals: [WatchVitalsModel]) -> Double {
        guard smoothedVitals.count >= 5 else { return 0 }
        let window = Array(smoothedVitals.suffix(5))
        return window.last!.heartRate - window.first!.heartRate
    }

    private func isHRIncreasing(_ vitals: [WatchVitalsModel]) -> Bool {
        guard vitals.count >= 5 else { return false }

        let window = Array(vitals.suffix(5))
        let steps = zip(window.dropFirst(), window).map { $0.0.heartRate - $0.1.heartRate }
        let positiveSteps = steps.filter { $0 >= hrStepIncreaseThreshold }.count
        let totalIncrease = window.last!.heartRate - window.first!.heartRate

        return positiveSteps >= 3 && totalIncrease >= hrTotalIncreaseThreshold
    }

    private func isMotionIncreasing(_ vitals: [WatchVitalsModel]) -> Bool {
        guard vitals.count >= 2 else { return false }

        let latest = vitals[vitals.count - 1].motion
        let previous = vitals[vitals.count - 2].motion
        return latest > previous
    }

    private func isMotionSpikeDetected(_ motionDelta: MotionDelta) -> Bool {
        motionDelta.latestMotion >= motionSpikeThreshold &&
            motionDelta.rawDelta >= motionDeltaThreshold &&
            motionDelta.smoothedDelta >= motionDeltaThreshold * 0.6 &&
            motionDelta.motionRatio >= motionSpikeRatioThreshold
    }

    private func updateMotionIncreasingCount(isIncreasing: Bool) {
        if isIncreasing {
            motionIncreasingCount += 1
        } else {
            motionIncreasingCount = 0
        }
    }

    // MARK: - Decision Helpers

    private func watchConnectionDecision() -> WakeDecision? {
        let monitor = WatchConnectionMonitor.shared

        guard monitor.state == .connected else {
            if monitor.state == .disconnected {
            } else {
            }
            freezeSignalState()
            return noDecision(reason: monitor.state == .disconnected ? "watch_disconnected" : "waiting_for_watch_data")
        }

        guard !monitor.isStaleData else {
            freezeSignalState()
            return noDecision(reason: "stale_watch_data")
        }

        return nil
    }

    private func noDecision(reason: String) -> WakeDecision {
        let decision = WakeDecision(
            shouldTrigger: false,
            confidence: wakeConfidence,
            reason: reason
        )

        debugSnapshot = SmartAlarmDebugSnapshot(
            currentHR: latestLiveInput.hr,
            currentHRV: latestLiveInput.hrv ?? 0,
            currentMotion: latestLiveInput.motion,
            avgHR: lastKnownAverages?.avgHR ?? 0,
            avgHRV: lastKnownAverages?.avgHRV ?? 0,
            avgMotion: lastKnownAverages?.avgMotion ?? 0,
            confidence: wakeConfidence,
            score: debugSnapshot.score,
            threshold: optimalTriggerThreshold,
            motionIncreasingCount: motionIncreasingCount,
            currentPhase: currentPhaseLabel,
            alarmState: alarmState,
            decisionReason: reason,
            timeToAlarm: remainingTimeToAlarm(from: Date()).map(formattedMinutes) ?? "--"
        )
        publishDebugSnapshot(debugSnapshot)
        return decision
    }

    private func freezeSignalState() {
        consecutiveHighScoreCount = 0
        motionIncreasingCount = 0
        wakeConfidence = max(0, wakeConfidence - 0.02)
    }

    private func safeTriggerAllowed(_ evaluation: TriggerEvaluation) -> Bool {
        guard evaluation.shouldTrigger else { return false }

        let monitor = WatchConnectionMonitor.shared
        let dataFresh = !monitor.isStaleData
        let watchConnected = monitor.state == .connected
        let confidencePassed = wakeConfidence > evaluation.thresholdUsed

        if confidencePassed && dataFresh && watchConnected {
            return true
        }

        return false
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
        transitionState(to: .triggered)

        lastTriggerResult = TriggerResult(
            timestamp: now,
            finalScore: 1.0,
            avgHR: averages.avgHR,
            avgHRV: averages.avgHRV,
            avgMotion: averages.avgMotion,
            reason: "fallback"
        )

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
            components: .zero,
            triggerEvaluation: TriggerEvaluation(
                shouldTrigger: true,
                type: .fallback,
                thresholdUsed: 1.0,
                reason: "alarm_time_reached"
            ),
            timeToAlarm: timeToAlarm,
            decision: decision
        )

        return decision
    }

    private func decisionReason(
        score: ScoreBreakdown,
        signals: SignalState,
        analysis: TrendAnalysis,
        withinWakeWindow: Bool
    ) -> String {
        if !withinWakeWindow {
            return "outside_wake_window"
        }

        if wakeConfidence >= optimalTriggerThreshold {
            return "confidence_reached_optimal_threshold"
        }

        if motionIncreasingCount >= requiredMotionIncreaseCount &&
            wakeConfidence >= earlySafeTriggerThreshold {
            return "motion_trend_confirmed_near_alarm"
        }

        if signals.hrTrend && !analysis.motionIncreasing {
            return "awaiting_motion_rise"
        }

        if score.finalScore <= minimumTriggerScore {
            return "score_below_threshold"
        }

        if !signals.hrTrend && !analysis.motionIncreasing {
            return "awaiting_wake_trends"
        }

        if motionIncreasingCount < requiredMotionIncreaseCount {
            return "building_motion_trend"
        }

        if wakeConfidence < earlySafeTriggerThreshold {
            return "building_confidence"
        }

        return "not_ready"
    }

    // MARK: - Logging

    private func logInput(_ input: InputSnapshot) {
    }

    private func logSignalWindow() {

    }

    private func logTrendAnalysis(_ analysis: TrendAnalysis) {
    }

    private func logDecision(
        averages: VitalAverages,
        score: ScoreBreakdown,
        signals: SignalState,
        analysis: TrendAnalysis,
        components: ConfidenceComponents,
        triggerEvaluation: TriggerEvaluation,
        timeToAlarm: TimeInterval,
        decision: WakeDecision
    ) {


        let snapshot = SmartAlarmDebugSnapshot(
            currentHR: latestLiveInput.hr,
            currentHRV: latestLiveInput.hrv ?? 0,
            currentMotion: latestLiveInput.motion,
            avgHR: averages.avgHR,
            avgHRV: averages.avgHRV ?? 0,
            avgMotion: averages.avgMotion,
            confidence: decision.confidence,
            score: score.finalScore,
            threshold: triggerEvaluation.thresholdUsed,
            motionIncreasingCount: motionIncreasingCount,
            currentPhase: currentPhaseLabel,
            alarmState: alarmState,
            decisionReason: decision.reason,
            timeToAlarm: formattedMinutes(timeToAlarm)
        )
        debugSnapshot = snapshot
        publishDebugSnapshot(snapshot)
    }

    private func logTriggerPath(_ evaluation: TriggerEvaluation, confidence: Double) {
        guard evaluation.type != .none else { return }
    }

    private func logTriggered(
        reason: String,
        confidence: Double,
        score: Double,
        timeToAlarm: TimeInterval,
        usedFallback: Bool
    ) {
    }

    private func transitionState(to newState: AlarmState) {
        guard alarmState != newState else { return }
        alarmState = newState
        debugSnapshot = SmartAlarmDebugSnapshot(
            currentHR: debugSnapshot.currentHR,
            currentHRV: debugSnapshot.currentHRV,
            currentMotion: debugSnapshot.currentMotion,
            avgHR: debugSnapshot.avgHR,
            avgHRV: debugSnapshot.avgHRV,
            avgMotion: debugSnapshot.avgMotion,
            confidence: debugSnapshot.confidence,
            score: debugSnapshot.score,
            threshold: debugSnapshot.threshold,
            motionIncreasingCount: debugSnapshot.motionIncreasingCount,
            currentPhase: debugSnapshot.currentPhase,
            alarmState: newState,
            decisionReason: debugSnapshot.decisionReason,
            timeToAlarm: debugSnapshot.timeToAlarm
        )
        publishDebugSnapshot(debugSnapshot)
    }

    private func publishDebugSnapshot(_ snapshot: SmartAlarmDebugSnapshot) {
        NotificationCenter.default.post(name: .smartAlarmDebugDidUpdate, object: snapshot)
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

    private func formattedOptional(_ value: Double?) -> String {
        guard let value, value > 0 else { return "--" }
        return formatted(value)
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
    let avgHRV: Double?
    let avgMotion: Double

    static let zero = VitalAverages(avgHR: 0, avgHRV: nil, avgMotion: 0)
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
    let motionRatio: Double

    static let zero = MotionDelta(rawDelta: 0, smoothedDelta: 0, latestMotion: 0, motionRatio: 0)
}

private struct TrendAnalysis {
    let hrTrend: Bool
    let motionSpike: Bool
    let motionIncreasing: Bool
    let motionDelta: Double
    let hrDelta: Double

    static let zero = TrendAnalysis(
        hrTrend: false,
        motionSpike: false,
        motionIncreasing: false,
        motionDelta: 0,
        hrDelta: 0
    )
}

private struct InputSnapshot: Equatable {
    let motion: Double
    let hr: Double
    let hrv: Double?

    static let zero = InputSnapshot(motion: 0, hr: 0, hrv: nil)
}

private struct ConfidenceComponents {
    let baseScore: Double
    let trendBonus: Double
    let spikeBonus: Double
    let consecutiveBonus: Double
    let motionIncreaseBonus: Double
    let hrvTransitionBonus: Double
    let wakeWindowBonus: Double
    let timePressureBonus: Double
    let targetConfidence: Double

    static let zero = ConfidenceComponents(
        baseScore: 0,
        trendBonus: 0,
        spikeBonus: 0,
        consecutiveBonus: 0,
        motionIncreaseBonus: 0,
        hrvTransitionBonus: 0,
        wakeWindowBonus: 0,
        timePressureBonus: 0,
        targetConfidence: 0
    )
}

private struct TriggerEvaluation {
    let shouldTrigger: Bool
    let type: TriggerType
    let thresholdUsed: Double
    let reason: String
}

private enum TriggerType: String {
    case none = "NONE"
    case optimal = "OPTIMAL"
    case earlyOverride = "EARLY_OVERRIDE"
    case earlySafe = "EARLY_SAFE"
    case fallback = "FALLBACK"
}

extension Notification.Name {
    static let smartAlarmDebugDidUpdate = Notification.Name("wakewell.smartAlarmDebugDidUpdate")
}
