import Foundation

struct SleepSessionModel {

    let id: Int

    let bedtimeStart: Date
    let wakeTime: Date

    let coreMinutes: Int
    let deepMinutes: Int
    let remMinutes: Int
    let awakeMinutes: Int
    let asleepMinutes: Int
    let inBedMinutes: Int

    let efficiency: Double
    let awakeningCount: Int
    let longestBlock: Int
    let restlessnessScore: Double

    let avgHR: Int
    let hrv: Double
    let respiratoryRate: Double
    let wristTemp: Double
    let oxygenSaturation: Double

    let triggerReason: String
    let movementAtWake: Double
}
