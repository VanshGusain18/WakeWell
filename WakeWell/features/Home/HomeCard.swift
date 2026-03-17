import Foundation

enum HomeCardModel {
    case alarm(AlarmModel)
    case sleepRing(SleepRingModel)
    case metrics(SleepMetricsModel)
    case groggy(GroggyModel)
    case notes(MorningNoteModel)
    case sounds(SleepSoundModel)
}
