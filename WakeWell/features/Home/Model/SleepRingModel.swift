import Foundation

struct SleepRingModel {
    let score: Int?
    let subtitle: String
}

extension SleepRingModel {

    static func subtitle(for stats: SleepStats, score: Double?) -> String {
        if stats.duration < 55 {
            return "Short sleep"
        }

        if stats.continuity < 45 || stats.calmness < 45 {
            return "Restless night"
        }

        if let score {
            switch score {
            case 90...:
                return "Excellent sleep"
            case 82..<90 where stats.duration >= 75 && stats.continuity >= 75:
                return "Deep rest"
            case 75..<82:
                return "Good sleep"
            case 65..<75:
                return "Steady sleep"
            default:
                break
            }
        }

        if stats.efficiency < 60 {
            return "Light sleep"
        }

        return "Good sleep"
    }
}
