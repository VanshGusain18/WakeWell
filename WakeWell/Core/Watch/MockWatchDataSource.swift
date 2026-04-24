import Foundation

final class MockWatchDataSource: WatchDataSource {

    private enum SleepPhase: String {
        case deepSleep = "deep_sleep"
        case lightSleep = "light_sleep"
        case wakeTransition = "wake_transition"
    }

    private struct PhaseProfile {
        let motionRange: ClosedRange<Double>
        let heartRateRange: ClosedRange<Double>
        let hrvRange: ClosedRange<Double>
        let respiratoryRateRange: ClosedRange<Double>
    }

    private var timer: Timer?
    private var sampleIndex = 0
    private var previousSample: WatchVitalsModel?

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

    func startStreaming(completion: @escaping (WatchVitalsModel) -> Void) {
        sampleIndex = 0
        previousSample = nil

        timer = Timer.scheduledTimer(withTimeInterval: sampleInterval, repeats: true) { _ in
            let sample = self.makeNextSample()
            completion(sample)
        }
    }

    func stopStreaming() {
        timer?.invalidate()
        timer = nil
        sampleIndex = 0
        previousSample = nil
    }

    private func makeNextSample() -> WatchVitalsModel {
        let phase = currentPhase(for: sampleIndex)
        let progress = phaseProgress(for: sampleIndex, phase: phase)
        let phaseProfile = profile(for: phase)

        let targetMotion = interpolate(
            range: phaseProfile.motionRange,
            progress: progress,
            jitter: phase == .wakeTransition ? 0.03 : 0.02
        )
        let targetHeartRate = interpolate(
            range: phaseProfile.heartRateRange,
            progress: progress,
            jitter: phase == .deepSleep ? 0.6 : 1.1
        )
        let targetHRV = interpolate(
            range: phaseProfile.hrvRange,
            progress: progress,
            jitter: 1.4
        )
        let targetRespiratoryRate = interpolate(
            range: phaseProfile.respiratoryRateRange,
            progress: progress,
            jitter: 0.3
        )

        let previous = previousSample
        let sample = WatchVitalsModel(
            timestamp: Date(),
            heartRate: smooth(next: targetHeartRate, previous: previous?.heartRate, alpha: 0.45),
            hrv: smooth(next: targetHRV, previous: previous?.hrv, alpha: 0.38),
            motion: smooth(next: targetMotion, previous: previous?.motion, alpha: 0.55),
            respiratoryRate: smooth(next: targetRespiratoryRate, previous: previous?.respiratoryRate, alpha: 0.30),
            wristTemp: 36.4 + Double.random(in: -0.2...0.3),
            oxygenSaturation: 97.0 + Double.random(in: -1.0...1.0)
        )

        previousSample = sample
        sampleIndex += 1

        print("[WakeSimulation] phase:", phase.rawValue, "sample:", sampleIndex)
        print("[WakeSimulation] motion:", String(format: "%.3f", sample.motion),
              "hr:", String(format: "%.3f", sample.heartRate),
              "hrv:", String(format: "%.3f", sample.hrv))

        return sample
    }

    private func currentPhase(for index: Int) -> SleepPhase {
        if index < deepSleepSampleCount {
            return .deepSleep
        }

        if index < deepSleepSampleCount + lightSleepSampleCount {
            return .lightSleep
        }

        return .wakeTransition
    }

    private func phaseProgress(for index: Int, phase: SleepPhase) -> Double {
        switch phase {
        case .deepSleep:
            return normalizedProgress(index: index, count: deepSleepSampleCount)
        case .lightSleep:
            return normalizedProgress(index: index - deepSleepSampleCount, count: lightSleepSampleCount)
        case .wakeTransition:
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

    private func profile(for phase: SleepPhase) -> PhaseProfile {
        switch phase {
        case .deepSleep:
            return deepSleepProfile
        case .lightSleep:
            return lightSleepProfile
        case .wakeTransition:
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
