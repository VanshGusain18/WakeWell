import Foundation

enum HomeCardModel {
    case sleepDebt(SleepDebtModel)
    case riseRitual(RiseRitualCardModel)
    case alarm(AlarmModel)
    case sleepRing(SleepRingModel)
    case metrics(SleepMetricsModel)
    case postSleepCheckIn(PostSleepCheckInModel)
    case sounds
}

enum HomeCardKind: Hashable {
    case sleepDebt
    case riseRitual
    case alarm
    case sleepRing
    case metrics
    case postSleepCheckIn
    case sounds
}

extension HomeCardModel {
    var kind: HomeCardKind {
        switch self {
        case .sleepDebt:
            return .sleepDebt
        case .riseRitual:
            return .riseRitual
        case .alarm:
            return .alarm
        case .sleepRing:
            return .sleepRing
        case .metrics:
            return .metrics
        case .postSleepCheckIn:
            return .postSleepCheckIn
        case .sounds:
            return .sounds
        }
    }
}
