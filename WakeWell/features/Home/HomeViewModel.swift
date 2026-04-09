import Foundation

final class HomeViewModel {
    
    private let provider = HomeDataProvider.shared
    private let repository = HomeSleepRepository.shared
    
    private var snapshot: HomeDashboardSnapshot
    private var allCards: [HomeCardModel] = []
    private var dismissedCardKinds: Set<HomeCardKind> = []
    
    private(set) var showMetricsCard = false
    
    var onCardsUpdated: (() -> Void)?
    
    var cards: [HomeCardModel] {
        allCards.filter { showMetricsCard || $0.kind != .metrics }
    }
    
    var cardCount: Int {
        cards.count
    }
    
    init() {
        snapshot = provider.fallbackSnapshot()
        rebuildCards()
    }
    
    func loadHealthKitData() {
        repository.fetchSnapshot { [weak self] snapshot in
            guard let self else { return }
            self.snapshot = snapshot
            self.rebuildCards()
            DispatchQueue.main.async {
                self.onCardsUpdated?()
            }
        }
    }
    
    func dismissCard(kind: HomeCardKind) {
        dismissedCardKinds.insert(kind)
        rebuildCards()
    }
    
    func toggleMetricsCard() {
        showMetricsCard.toggle()
    }
    
    func indexOfVisibleCard(kind: HomeCardKind) -> Int? {
        cards.firstIndex { $0.kind == kind }
    }
    
    private func rebuildCards() {
        var updatedCards: [HomeCardModel] = []
        
        if !snapshot.sleepDebt.sleepHistory.isEmpty,
           SleepDebtViewModel(model: snapshot.sleepDebt).shouldShowCard(),
           !dismissedCardKinds.contains(.sleepDebt) {
            updatedCards.append(.sleepDebt(snapshot.sleepDebt))
        }
        
        if !dismissedCardKinds.contains(.riseRitual) {
            updatedCards.append(.riseRitual(snapshot.riseRitual))
        }
        
        updatedCards.append(.alarm(snapshot.alarm))
        updatedCards.append(.sleepRing(snapshot.sleepRing))
        updatedCards.append(.metrics(snapshot.metrics))
        updatedCards.append(.postSleepCheckIn(snapshot.postSleepCheckIn))
        updatedCards.append(.sounds)
        
        allCards = updatedCards.filter { !dismissedCardKinds.contains($0.kind) }
    }
}
