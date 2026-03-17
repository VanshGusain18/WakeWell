import Foundation

class HomeViewModel {

    let cards: [HomeCardModel]

    init() {

        let alarmModel = AlarmModel(
            time: Date().addingTimeInterval(3600 * 8)
        )

        let sleepRingModel = SleepRingModel(
            score: 82,
            subtitle: "Good sleep"
        )

        let metricsModel = SleepMetricsModel(
            sleepScore: 78,
            metrics: [
                SleepMetricItem(title: "Duration", score: 16, maxScore: 20, trendPercent: 5),
                SleepMetricItem(title: "Efficiency", score: 12, maxScore: 15, trendPercent: 3),
                SleepMetricItem(title: "Architecture", score: 18, maxScore: 25, trendPercent: -2),
                SleepMetricItem(title: "Continuity", score: 13, maxScore: 15, trendPercent: 1),
                SleepMetricItem(title: "Calmness", score: 11, maxScore: 15, trendPercent: -4),
                SleepMetricItem(title: "Consistency", score: 8, maxScore: 10, trendPercent: 2)
            ]
        )

        let groggyModel = GroggyModel(value: 5)

        let notesModel = MorningNoteModel(
            text: "",
            date: Date()
        )

        let soundsModel = SleepSoundModel(
            title: "Sleep Sounds"
        )

        cards = [
            .alarm(alarmModel),
            .sleepRing(sleepRingModel),
            .metrics(metricsModel),
            .groggy(groggyModel),
            .notes(notesModel),
            .sounds(soundsModel)
        ]
    }

    var cardCount: Int {
        return cards.count
    }
}
