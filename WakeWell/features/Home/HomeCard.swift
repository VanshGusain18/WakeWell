import Foundation

enum HomeCardModel {
    case sleepDebt(SleepDebtModel)
    case riseRitual(RiseRitualModel)
    case sleepRingWithAlarm(ring: SleepRingModel, alarm: AlarmModel)
    case metrics(SleepMetricsModel)
    case groggyNotes(groggy: GroggyModel, notes: MorningNoteModel)  
    case sounds
}
