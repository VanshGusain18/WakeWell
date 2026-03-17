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
            duration: "7h 45m",
            consistency: "Good",
            efficiency: "92%"
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
