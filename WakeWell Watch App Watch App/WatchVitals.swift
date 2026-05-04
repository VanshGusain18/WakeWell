import Foundation

struct WatchVitals {
    let heartRate: Double
    let hrv: Double?
    let motion: Double
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
                "motionReal": true
            ]
        ]

        if let hrv {
            payload["hrv"] = hrv
        } else if let hrvUnavailableReason {
            payload["hrvUnavailableReason"] = hrvUnavailableReason
        }

        return payload
    }
}
