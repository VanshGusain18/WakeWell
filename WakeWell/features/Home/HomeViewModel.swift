import Foundation

class HomeViewModel {

    private let provider = HomeDataProvider.shared
    
    let sleepDebtViewModel: SleepDebtViewModel
    
    private var allCards: [HomeCardModel] = []
    private(set) var showMetricsCard: Bool = false   // Controls visibility of metrics card

    var cards: [HomeCardModel] {
        if showMetricsCard {
            return allCards
        } else {
            // Remove metrics card when collapsed
            return allCards.filter {
                if case .metrics = $0 { return false }
                return true
            }
        }
    }

    var cardCount: Int {
        return cards.count
    }

    init() {

        let sleepDebtModel = provider.getSleepDebt()
        sleepDebtViewModel = SleepDebtViewModel(model: sleepDebtModel)

        
        allCards = [
            .alarm(provider.getAlarm()),
            .sleepRing(provider.getSleepRing()),
            .metrics(provider.getMetrics()),
            .groggy(provider.getGroggy()),
            .notes(provider.getNote()),
            .sounds
        ]
        if sleepDebtViewModel.shouldShowCard() {
            allCards.insert(.sleepDebt(sleepDebtModel), at: 0)
        }
        
        
    }
    func removeSleepDebtCard() {

        allCards.removeAll {
            if case .sleepDebt = $0 { return true }
            return false
        }
    }

    // Call this when user taps the chevron
    func toggleMetricsCard() {
        showMetricsCard.toggle()
    }
}
