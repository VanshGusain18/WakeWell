import Foundation

struct WatchValidityFlags {
    let hrReal: Bool
    let hrvReal: Bool
    let motionReal: Bool
    let respiratoryRateReal: Bool

    static let unknown = WatchValidityFlags(hrReal: false, hrvReal: false, motionReal: false, respiratoryRateReal: false)

    init(dictionary: [String: Any]?) {
        hrReal = dictionary?["hrReal"] as? Bool ?? false
        hrvReal = dictionary?["hrvReal"] as? Bool ?? false
        motionReal = dictionary?["motionReal"] as? Bool ?? false
        respiratoryRateReal = dictionary?["respiratoryRateReal"] as? Bool ?? false
    }

    private init(hrReal: Bool, hrvReal: Bool, motionReal: Bool, respiratoryRateReal: Bool) {
        self.hrReal = hrReal
        self.hrvReal = hrvReal
        self.motionReal = motionReal
        self.respiratoryRateReal = respiratoryRateReal
    }
}

struct WatchPayloadSample {
    let timestamp: Date
    let heartRate: Double
    let hrv: Double?
    let motion: Double
    let respiratoryRate: Double?
    let validityFlags: WatchValidityFlags
    let hrvUnavailableReason: String?
}

struct ValidatedVitalsSample {
    let timestamp: Date
    let heartRate: Double
    let hrv: Double?
    let motion: Double
    let respiratoryRate: Double?
    let validityFlags: WatchValidityFlags
}

final class DataIntegrityValidator {
    static let shared = DataIntegrityValidator()

    private var previousHeartRate: (value: Double, timestamp: Date)?

    private init() {}

    func validate(_ sample: WatchPayloadSample) -> ValidatedVitalsSample? {
        guard sample.validityFlags.hrReal else {
            return nil
        }

        guard sample.heartRate >= 30 && sample.heartRate <= 220 else {
            return nil
        }

        if let previousHeartRate {
            let elapsed = max(sample.timestamp.timeIntervalSince(previousHeartRate.timestamp), 0.001)
            let bpmPerSecond = abs(sample.heartRate - previousHeartRate.value) / elapsed
            if bpmPerSecond > 40 {
                return nil
            }
        }
        previousHeartRate = (sample.heartRate, sample.timestamp)

        let validHRV: Double?
        if let hrv = sample.hrv {
            guard hrv > 0 && hrv < 200 else {
                validHRV = nil
                return ValidatedVitalsSample(
                    timestamp: sample.timestamp,
                    heartRate: sample.heartRate,
                    hrv: validHRV,
                    motion: sample.motion,
                    respiratoryRate: sample.respiratoryRate,
                    validityFlags: sample.validityFlags
                )
            }
            validHRV = hrv
        } else {
            validHRV = nil
        }

        guard sample.motion >= 0 && sample.motion <= 1 else {
            return nil
        }

        if let respiratoryRate = sample.respiratoryRate,
           (respiratoryRate < 4 || respiratoryRate > 60) {
            return nil
        }

        if sample.motion > 0.7 && sample.heartRate < 45 {
        }

        return ValidatedVitalsSample(
            timestamp: sample.timestamp,
            heartRate: sample.heartRate,
            hrv: validHRV,
            motion: sample.motion,
            respiratoryRate: sample.respiratoryRate,
            validityFlags: sample.validityFlags
        )
    }
}
