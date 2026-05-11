import Foundation

enum HomeCardModel {
    case sleepDebt(SleepDebtModel)
    case sleepRing(SleepRingModel)
    case alarm(AlarmModel)               
    case liveVitals
    case metrics(SleepMetricsModel)
    case groggyNotes(groggy: GroggyModel, notes: MorningNoteModel)
    case sounds
}
