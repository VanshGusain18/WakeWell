import Foundation

struct VitalData {
    let timestamp: Date
    let heartRate: Double
    let hrv: Double
    let motion: Double
    let respiratoryRate: Double
    let wristTemp: Double?
    let oxygenSaturation: Double?
    let phase: String

    var watchVitalsModel: WatchVitalsModel {
        WatchVitalsModel(
            timestamp: timestamp,
            heartRate: heartRate,
            hrv: hrv,
            motion: motion,
            respiratoryRate: respiratoryRate,
            wristTemp: wristTemp,
            oxygenSaturation: oxygenSaturation
        )
    }
}

protocol VitalDataProvider: AnyObject {
    var onData: ((VitalData) -> Void)? { get set }
    func start()
    func stop()
}

final class MockWatchProvider: VitalDataProvider {

    private enum SimulationPhase: String {
        case deep = "Deep Sleep"
        case light = "Light Sleep"
        case wake = "Wake Transition"
    }

    private struct PhaseProfile {
        let motionRange: ClosedRange<Double>
        let heartRateRange: ClosedRange<Double>
        let hrvRange: ClosedRange<Double>
        let respiratoryRateRange: ClosedRange<Double>
    }

    var onData: ((VitalData) -> Void)?

    private var timer: Timer?
    private var sampleIndex = 0
    private var previousSample: VitalData?

    private let sampleInterval: TimeInterval = 5
    private let deepSleepSampleCount = 8
    private let lightSleepSampleCount = 8
    private let wakeTransitionSampleCount = 10

    private let deepSleepProfile = PhaseProfile(
        motionRange: 0.10...0.30,
        heartRateRange: 54...60,
        hrvRange: 62...78,
        respiratoryRateRange: 12...14
    )

    private let lightSleepProfile = PhaseProfile(
        motionRange: 0.30...0.60,
        heartRateRange: 60...68,
        hrvRange: 48...62,
        respiratoryRateRange: 13...16
    )

    private let wakeTransitionProfile = PhaseProfile(
        motionRange: 0.70...1.00,
        heartRateRange: 68...86,
        hrvRange: 28...46,
        respiratoryRateRange: 15...19
    )

    func start() {
        stop()
        sampleIndex = 0
        previousSample = nil

        timer = Timer.scheduledTimer(withTimeInterval: sampleInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            let sample = makeNextSample()
            onData?(sample)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        sampleIndex = 0
        previousSample = nil
    }

    private func makeNextSample() -> VitalData {
        let phase = currentPhase(for: sampleIndex)
        let progress = phaseProgress(for: sampleIndex, phase: phase)
        let profile = profile(for: phase)

        let targetMotion = interpolate(
            range: profile.motionRange,
            progress: progress,
            jitter: phase == .wake ? 0.03 : 0.02
        )
        let targetHeartRate = interpolate(
            range: profile.heartRateRange,
            progress: progress,
            jitter: phase == .deep ? 0.6 : 1.1
        )
        let targetHRV = interpolate(
            range: profile.hrvRange,
            progress: progress,
            jitter: 1.4
        )
        let targetRespiratoryRate = interpolate(
            range: profile.respiratoryRateRange,
            progress: progress,
            jitter: 0.3
        )

        let sample = VitalData(
            timestamp: Date(),
            heartRate: smooth(next: targetHeartRate, previous: previousSample?.heartRate, alpha: 0.45),
            hrv: smooth(next: targetHRV, previous: previousSample?.hrv, alpha: 0.38),
            motion: smooth(next: targetMotion, previous: previousSample?.motion, alpha: 0.55),
            respiratoryRate: smooth(next: targetRespiratoryRate, previous: previousSample?.respiratoryRate, alpha: 0.30),
            wristTemp: 36.4 + Double.random(in: -0.2...0.3),
            oxygenSaturation: 97.0 + Double.random(in: -1.0...1.0),
            phase: phase.rawValue
        )

        previousSample = sample
        sampleIndex += 1
        return sample
    }

    private func currentPhase(for index: Int) -> SimulationPhase {
        if index < deepSleepSampleCount {
            return .deep
        }

        if index < deepSleepSampleCount + lightSleepSampleCount {
            return .light
        }

        return .wake
    }

    private func phaseProgress(for index: Int, phase: SimulationPhase) -> Double {
        switch phase {
        case .deep:
            return normalizedProgress(index: index, count: deepSleepSampleCount)
        case .light:
            return normalizedProgress(index: index - deepSleepSampleCount, count: lightSleepSampleCount)
        case .wake:
            return normalizedProgress(
                index: index - deepSleepSampleCount - lightSleepSampleCount,
                count: wakeTransitionSampleCount
            )
        }
    }

    private func normalizedProgress(index: Int, count: Int) -> Double {
        guard count > 1 else { return 1 }
        let clampedIndex = max(0, min(index, count - 1))
        return Double(clampedIndex) / Double(count - 1)
    }

    private func profile(for phase: SimulationPhase) -> PhaseProfile {
        switch phase {
        case .deep:
            return deepSleepProfile
        case .light:
            return lightSleepProfile
        case .wake:
            return wakeTransitionProfile
        }
    }

    private func interpolate(range: ClosedRange<Double>, progress: Double, jitter: Double) -> Double {
        let baseValue = range.lowerBound + (range.upperBound - range.lowerBound) * progress
        let jitterValue = Double.random(in: -jitter...jitter)
        let value = baseValue + jitterValue
        return min(range.upperBound, max(range.lowerBound, value))
    }

    private func smooth(next: Double, previous: Double?, alpha: Double) -> Double {
        guard let previous else { return next }
        return previous + alpha * (next - previous)
    }
}

final class RealWatchProvider: VitalDataProvider {
    var onData: ((VitalData) -> Void)?
    private var timer: Timer?

    func start() {
        stop()
        HealthKitManager.shared.startWatchWorkoutSessionForLiveStreaming()

        // Demo-level "real watch" mode: poll the newest HealthKit HR/HRV values on iPhone.
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self else { return }

            HealthKitManager.shared.fetchLatestHeartRate { heartRate in
                HealthKitManager.shared.fetchLatestHRV { hrv in
                    let sample = VitalData(
                        timestamp: Date(),
                        heartRate: heartRate ?? 0,
                        hrv: hrv ?? 0,
                        motion: 0,
                        respiratoryRate: 0,
                        wristTemp: nil,
                        oxygenSaturation: nil,
                        phase: "Live Watch"
                    )
                    self.onData?(sample)
                }
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
