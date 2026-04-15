import Foundation

struct WatchVitalsModel {

    let timestamp: Date

    let heartRate: Double
    let hrv: Double

    let motion: Double
    let respiratoryRate: Double

    let wristTemp: Double?
    let oxygenSaturation: Double?
}
