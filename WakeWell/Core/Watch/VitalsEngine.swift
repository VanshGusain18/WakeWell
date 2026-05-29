import Foundation

final class VitalsEngine {
    static let shared = VitalsEngine()

    private let heartRateWindowSize = 5
    private var heartRateWindow: [Double] = []
    private var baselineHeartRate: Double?
    private var baselineHRV: Double?
    private var baselineMotion: Double?

    private init() {}

    func process(_ sample: ValidatedVitalsSample) -> VitalData {
        heartRateWindow.append(sample.heartRate)
        if heartRateWindow.count > heartRateWindowSize {
            heartRateWindow.removeFirst()
        }

        let smoothedHeartRate = heartRateWindow.reduce(0, +) / Double(heartRateWindow.count)
        updateBaselines(sample: sample, smoothedHeartRate: smoothedHeartRate)

        return VitalData(
            timestamp: sample.timestamp,
            heartRate: smoothedHeartRate,
            hrv: sample.hrv,
            motion: sample.motion,
            respiratoryRate: sample.respiratoryRate,
            wristTemp: nil,
            oxygenSaturation: nil,
            phase: sample.motion < 0.45 ? "Light Sleep" : "Wake Transition"
        )
    }

    private func updateBaselines(sample: ValidatedVitalsSample, smoothedHeartRate: Double) {
        baselineHeartRate = blend(current: baselineHeartRate, next: smoothedHeartRate)
        if let hrv = sample.hrv {
            baselineHRV = blend(current: baselineHRV, next: hrv)
        }
        baselineMotion = blend(current: baselineMotion, next: sample.motion)
    }

    private func blend(current: Double?, next: Double) -> Double {
        guard let current else { return next }
        return current * 0.92 + next * 0.08
    }
}
