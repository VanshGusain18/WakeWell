import Foundation

enum HomeCardModel {
    case sleepDebt(SleepDebtModel)
    case riseRitual(RiseRitualModel)
    case sleepRing(SleepRingModel)       // left half-width card
    case alarm(AlarmModel)               // right half-width card
    case metrics(SleepMetricsModel)
    case groggyNotes(groggy: GroggyModel, notes: MorningNoteModel)
    case sounds
}
