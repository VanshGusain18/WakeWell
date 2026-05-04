import Foundation

struct TriggerResult {

    let timestamp: Date

    let finalScore: Double
    let avgHR: Double
    let avgHRV: Double?
    let avgMotion: Double

    let reason: String
}
