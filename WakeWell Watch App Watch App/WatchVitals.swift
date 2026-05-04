import Foundation

struct WatchVitals {
    let heartRate: Double
    let hrv: Double?
    let motion: Double
    let respiratoryRate: Double?
    let timestamp: Date
    let hrvUnavailableReason: String?

    var payload: [String: Any] {
        var payload: [String: Any] = [
            "heartRate": heartRate,
            "motion": motion,
            "timestamp": timestamp.timeIntervalSince1970,
            "validityFlags": [
                "hrReal": true,
                "hrvReal": hrv != nil,
                "motionReal": true,
                "respiratoryRateReal": respiratoryRate != nil
            ]
        ]

        if let hrv {
            payload["hrv"] = hrv
        } else if let hrvUnavailableReason {
            payload["hrvUnavailableReason"] = hrvUnavailableReason
        }

        if let respiratoryRate {
            payload["respiratoryRate"] = respiratoryRate
        }

        return payload
    }
}
