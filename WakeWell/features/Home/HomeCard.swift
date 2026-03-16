import Foundation

enum HomeCard {
    case alarm(AlarmViewModel)
    case sleepRing(SleepRingViewModel)
    case metrics(SleepMetricsViewModel)
    case groggy(GroggySliderViewModel)
    case notes(MorningNotesViewModel)
    case sounds(SleepSoundsViewModel)
}
