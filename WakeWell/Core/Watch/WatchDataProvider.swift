import Foundation

struct VitalData {
    let timestamp: Date
    let heartRate: Double
    let hrv: Double?
    let motion: Double
    let respiratoryRate: Double?
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
