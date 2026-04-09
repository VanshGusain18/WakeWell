import Foundation

struct RiseRitualCardModel {
    let title: String
    let eyebrowText: String
    let message: String
    let symbolName: String
    let primaryActionTitle: String
    let secondaryActionTitle: String
}

struct PostSleepCheckInModel {
    let groggy: GroggyModel
    let note: MorningNoteModel
}

struct HomeDashboardSnapshot {
    let alarm: AlarmModel
    let sleepDebt: SleepDebtModel
    let riseRitual: RiseRitualCardModel
    let sleepRing: SleepRingModel
    let metrics: SleepMetricsModel
    let postSleepCheckIn: PostSleepCheckInModel
}
