import Foundation

class HomeViewModel {

    private let provider = HomeDataProvider.shared

    let sleepDebtViewModel: SleepDebtViewModel

    private var allCards: [HomeCardModel] = []
    private(set) var showMetricsCard: Bool = false

    var cards: [HomeCardModel] {
        if showMetricsCard {
            return allCards
        } else {
            return allCards.filter {
                if case .metrics = $0 { return false }
                return true
            }
        }
    }

    var cardCount: Int { cards.count }

    init() {
        let sleepDebtModel = provider.getSleepDebt()
        sleepDebtViewModel = SleepDebtViewModel(model: sleepDebtModel)

        allCards = [
            .riseRitual(provider.getRiseRitual()),
            .sleepRing(provider.getSleepRing()),   // consecutive — FlowLayout places side-by-side
            .alarm(provider.getAlarm()),            //
            .metrics(provider.getMetrics()),
            .groggyNotes(groggy: provider.getGroggy(), notes: provider.getNote()),
            .sounds
        ]

        if sleepDebtViewModel.shouldShowCard() {
            allCards.insert(.sleepDebt(sleepDebtModel), at: 0)
        }
    }

    func removeRiseRitualCard() {
        allCards.removeAll { if case .riseRitual = $0 { return true }; return false }
    }

    func removeSleepDebtCard() {
        allCards.removeAll { if case .sleepDebt = $0 { return true }; return false }
    }

    func toggleMetricsCard() {
        showMetricsCard.toggle()
    }
}
