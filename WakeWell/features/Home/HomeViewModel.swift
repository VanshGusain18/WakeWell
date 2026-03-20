import Foundation

class HomeViewModel {

    private let provider = HomeDataProvider.shared

    let cards: [HomeCardModel]

    init() {

        cards = [
            .alarm(provider.getAlarm()),
            .sleepRing(provider.getSleepRing()),
            .metrics(provider.getMetrics()),
            .groggy(provider.getGroggy()),
            .notes(provider.getNote()),
            .sounds
        ]
    }

    var cardCount: Int {
        return cards.count
    }
}
