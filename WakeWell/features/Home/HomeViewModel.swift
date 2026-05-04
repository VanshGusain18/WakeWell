import Foundation

final class HomeViewModel {

    private let provider = HomeDataProvider.shared

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
        allCards = [
            .riseRitual(provider.getRiseRitual()),
            .sleepRing(provider.getSleepRing()),  
            .alarm(provider.getAlarm()),
            .liveVitals,
            .metrics(provider.getMetrics()),
            .groggyNotes(groggy: provider.getGroggy(), notes: provider.getNote()),
            .sounds
        ]

        updateSleepDebtCard(with: provider.getSleepDebt())
    }

    func removeRiseRitualCard() {
        allCards.removeAll { if case .riseRitual = $0 { return true }; return false }
    }

    func removeSleepDebtCard() {
        allCards.removeAll { if case .sleepDebt = $0 { return true }; return false }
    }

    func reloadSleepDebtFromHealthKit() {
        updateSleepDebtCard(with: provider.getSleepDebt())
    }

    func toggleMetricsCard() {
        showMetricsCard.toggle()
    }

    private func updateSleepDebtCard(with model: SleepDebtModel) {
        removeSleepDebtCard()

        let sleepDebtViewModel = SleepDebtViewModel(model: model)
        guard sleepDebtViewModel.shouldShowCard() else { return }

        let insertIndex = allCards.firstIndex {
            if case .riseRitual = $0 { return true }
            return false
        }.map { $0 + 1 } ?? 0
        allCards.insert(.sleepDebt(model), at: insertIndex)
    }
}
