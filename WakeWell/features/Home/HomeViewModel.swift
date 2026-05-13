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
        rebuildCards()

        updateSleepDebtCard(with: provider.getSleepDebt())
    }

    func refreshDynamicContent() {
        allCards = allCards.map { card in
            switch card {
            case .sleepRing:
                return .sleepRing(provider.getSleepRing())
            case .alarm:
                return .alarm(provider.getAlarm())
            case .metrics:
                return .metrics(provider.getMetrics())
            case .groggyNotes:
                return .groggyNotes(groggy: provider.getGroggy(), notes: provider.getNote())
            case .sleepDebt:
                return .sleepDebt(provider.getSleepDebt())
            case .riseRitual, .liveVitals, .sounds:
                return card
            }
        }
    }

    func saveGroggyValue(_ value: Float) {
        provider.saveGroggy(value)
    }

    func saveMorningNote(_ text: String) {
        provider.saveMorningNote(text)
    }

    func finalizeTodayJournal(groggyValue: Float, morningNote: String) {
        provider.finalizeTodayJournal(groggyValue: groggyValue, morningNote: morningNote)
    }

    func removeRiseRitualCard() {
        allCards.removeAll { if case .riseRitual = $0 { return true }; return false }
    }

    func removeSleepDebtCard() {
        allCards.removeAll { if case .sleepDebt = $0 { return true }; return false }
    }

    func reloadSleepDebtFromHealthKit() {
        refreshDynamicContent()
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

    private func rebuildCards() {
        allCards = [
            .riseRitual(provider.getRiseRitual()),
            .sleepRing(provider.getSleepRing()),
            .alarm(provider.getAlarm()),
            .liveVitals,
            .metrics(provider.getMetrics()),
            .groggyNotes(groggy: provider.getGroggy(), notes: provider.getNote()),
            .sounds
        ]
    }
}
