import Foundation

struct SleepSessionModel {
    let id: Int
    let startTime: Date
    let endTime: Date?
    let alarmTime: Date
    let triggerTime: Date?
    let triggerReason: String?
    let confidence: Double?
    let createdAt: Date
}
