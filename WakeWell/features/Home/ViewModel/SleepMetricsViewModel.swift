import Foundation

struct SleepMetricsViewModel {

    let durationTitle: String
    let durationScore: String
    let durationTrend: String

    init(model: SleepMetricsModel) {
        durationTitle = "Duration"
        durationScore = model.duration
        durationTrend = "↑ 15m"
    }
}
