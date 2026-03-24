import Foundation

class HomeViewModel {

    private let provider = HomeDataProvider.shared
    
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
        allCards = [
            .alarm(provider.getAlarm()),
            .sleepRing(provider.getSleepRing()),
            .metrics(provider.getMetrics()),   // Always keep it in allCards
            .groggy(provider.getGroggy()),
            .notes(provider.getNote()),
            .sounds
        ]
    }

    // Call this when user taps the chevron
    func toggleMetricsCard() {
        showMetricsCard.toggle()
    }
}
