import Foundation

class HomeViewModel {

    let alarmViewModel: AlarmViewModel
    let sleepRingViewModel: SleepRingViewModel
    let metricsViewModel: SleepMetricsViewModel
    let groggyViewModel: GroggySliderViewModel
    let notesViewModel: MorningNotesViewModel
    let soundsViewModel: SleepSoundsViewModel
    
    let cards: [HomeCard]

    init() {

        let alarmModel = AlarmModel(
            time: Date().addingTimeInterval(3600 * 8)
        )
        alarmViewModel = AlarmViewModel(model: alarmModel)

        let sleepRingModel = SleepRingModel(
            score: 82,
            subtitle: "Good sleep"
        )
        sleepRingViewModel = SleepRingViewModel(model: sleepRingModel)
        metricsViewModel = SleepMetricsViewModel()
        groggyViewModel = GroggySliderViewModel()
        notesViewModel = MorningNotesViewModel()
        soundsViewModel = SleepSoundsViewModel()
        
        cards = [
            .alarm(alarmViewModel),
            .sleepRing(sleepRingViewModel),
            .metrics(metricsViewModel),
            .groggy(groggyViewModel),
            .notes(notesViewModel),
            .sounds(soundsViewModel)
        ]
    }

    var cardCount: Int {
        return cards.count
    }
}
