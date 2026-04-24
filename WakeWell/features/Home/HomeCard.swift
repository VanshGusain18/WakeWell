import Foundation

enum HomeCardModel {
    case sleepDebt(SleepDebtModel)
    case riseRitual(RiseRitualModel)
    case sleepRing(SleepRingModel)
    case alarm(AlarmModel)               
    case metrics(SleepMetricsModel)
    case groggyNotes(groggy: GroggyModel, notes: MorningNoteModel)
    case sounds
}
