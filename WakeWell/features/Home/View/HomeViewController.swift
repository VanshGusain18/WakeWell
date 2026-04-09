import UIKit

final class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel = HomeViewModel()
    private let cardInset: CGFloat = 16
    private let cardSpacing: CGFloat = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        registerCells()
        bindViewModel()
        viewModel.loadHealthKitData()
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.alwaysBounceVertical = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = cardSpacing
            layout.sectionInset = UIEdgeInsets(top: 16, left: cardInset, bottom: 24, right: cardInset)
        }
    }
    
    private func registerCells() {
        collectionView.register(
            UINib(nibName: SleepDebtViewCardCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: SleepDebtViewCardCell.identifier
        )
        collectionView.register(
            AlarmCollectionViewCell.self,
            forCellWithReuseIdentifier: AlarmCollectionViewCell.identifier
        )
        collectionView.register(
            SleepRingCollectionViewCell.self,
            forCellWithReuseIdentifier: SleepRingCollectionViewCell.identifier
        )
        collectionView.register(
            UINib(nibName: "SleepMetricsGridCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "sleep_metrics_cell"
        )
        collectionView.register(
            PostSleepCheckInCollectionViewCell.self,
            forCellWithReuseIdentifier: PostSleepCheckInCollectionViewCell.identifier
        )
        collectionView.register(
            UINib(nibName: "SleepSoundsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "sleep_sounds_cell"
        )
        collectionView.register(
            RiseRitualCollectionViewCell.self,
            forCellWithReuseIdentifier: RiseRitualCollectionViewCell.identifier
        )
    }
    
    private func bindViewModel() {
        viewModel.onCardsUpdated = { [weak self] in
            guard let self else { return }
            UIView.transition(with: self.collectionView, duration: 0.25, options: .transitionCrossDissolve) {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func dismissCard(kind: HomeCardKind, using cell: UICollectionViewCell?) {
        guard let cell, let indexPath = collectionView.indexPath(for: cell) else { return }
        
        viewModel.dismissCard(kind: kind)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    private func toggleMetricsCardAnimated() {
        let wasExpanded = viewModel.showMetricsCard
        let metricsIndexBefore = viewModel.indexOfVisibleCard(kind: .metrics)
        
        viewModel.toggleMetricsCard()
        
        let metricsIndexAfter = viewModel.indexOfVisibleCard(kind: .metrics)
        collectionView.performBatchUpdates {
            if wasExpanded, let item = metricsIndexBefore {
                collectionView.deleteItems(at: [IndexPath(item: item, section: 0)])
            } else if let item = metricsIndexAfter {
                collectionView.insertItems(at: [IndexPath(item: item, section: 0)])
            }
        }
        
        if let sleepRingIndex = viewModel.indexOfVisibleCard(kind: .sleepRing),
           let sleepRingCell = collectionView.cellForItem(at: IndexPath(item: sleepRingIndex, section: 0)) as? SleepRingCollectionViewCell {
            sleepRingCell.setExpanded(viewModel.showMetricsCard, animated: true)
        }
    }
    
    private func openRiseTab(startRoutine: Bool) {
        if let tabBarController, let controllers = tabBarController.viewControllers {
            for (index, controller) in controllers.enumerated() {
                let navigationController = controller as? UINavigationController
                let deck = (navigationController?.viewControllers.first as? ActivityDeckViewController)
                    ?? (controller as? ActivityDeckViewController)
                
                guard let deck else { continue }
                
                deck.startRoutineOnAppear = startRoutine
                let wasSelected = tabBarController.selectedIndex == index
                tabBarController.selectedIndex = index
                
                if startRoutine && wasSelected {
                    deck.startRoutineTapped()
                }
                return
            }
        }
        
        let storyboard = UIStoryboard(name: "Rise", bundle: nil)
        guard let deck = storyboard.instantiateViewController(
            withIdentifier: "ActivityDeckViewController"
        ) as? ActivityDeckViewController else {
            return
        }
        
        deck.startRoutineOnAppear = startRoutine
        if let navigationController {
            navigationController.pushViewController(deck, animated: true)
        } else {
            present(UINavigationController(rootViewController: deck), animated: true)
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.cardCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = viewModel.cards[indexPath.item]
        
        switch card {
        case .sleepDebt(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SleepDebtViewCardCell.identifier,
                for: indexPath
            ) as! SleepDebtViewCardCell
            cell.configure(with: SleepDebtViewModel(model: model))
            cell.onDismissRequested = { [weak self] cell in
                self?.dismissCard(kind: .sleepDebt, using: cell)
            }
            return cell
            
        case .riseRitual(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RiseRitualCollectionViewCell.identifier,
                for: indexPath
            ) as! RiseRitualCollectionViewCell
            cell.configure(with: model)
            cell.onDismissRequested = { [weak self] cell in
                self?.dismissCard(kind: .riseRitual, using: cell)
            }
            cell.onStartTapped = { [weak self] in
                self?.openRiseTab(startRoutine: true)
            }
            cell.onViewRiseTapped = { [weak self] in
                self?.openRiseTab(startRoutine: false)
            }
            return cell
            
        case .alarm(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlarmCollectionViewCell.identifier,
                for: indexPath
            ) as! AlarmCollectionViewCell
            cell.configure(with: AlarmViewModel(model: model))
            return cell
            
        case .sleepRing(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SleepRingCollectionViewCell.identifier,
                for: indexPath
            ) as! SleepRingCollectionViewCell
            cell.configure(with: SleepRingViewModel(model: model), isExpanded: viewModel.showMetricsCard)
            cell.onChevronTapped = { [weak self] in
                self?.toggleMetricsCardAnimated()
            }
            return cell
            
        case .metrics(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_metrics_cell",
                for: indexPath
            ) as! SleepMetricsGridCollectionViewCell
            cell.configure(with: SleepMetricsViewModel(model: model))
            return cell
            
        case .postSleepCheckIn(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostSleepCheckInCollectionViewCell.identifier,
                for: indexPath
            ) as! PostSleepCheckInCollectionViewCell
            cell.configure(with: model)
            return cell
            
        case .sounds:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_sounds_cell",
                for: indexPath
            ) as! SleepSoundsCollectionViewCell
            cell.configure(with: SleepSoundsViewModel())
            return cell
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let card = viewModel.cards[indexPath.item]
        let fullWidth = collectionView.bounds.width - (cardInset * 2)
        let halfWidth = (fullWidth - cardSpacing) / 2
        
        switch card {
        case .sleepDebt:
            return CGSize(width: fullWidth, height: 60)
        case .riseRitual:
            return CGSize(width: fullWidth, height: 220)
        case .alarm, .sleepRing:
            return CGSize(width: halfWidth, height: halfWidth)
        case .metrics:
            return CGSize(width: fullWidth, height: 200)
        case .postSleepCheckIn:
            return CGSize(width: fullWidth, height: 310)
        case .sounds:
            return CGSize(width: fullWidth, height: 60)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = viewModel.cards[indexPath.item]
        
        switch card {
        case .alarm:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "alarm")
            vc.modalPresentationStyle = .automatic
            present(vc, animated: true)
            
        case .sounds:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "sound")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard case .metrics = viewModel.cards[indexPath.item] else { return }
        
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: -12)
        
        UIView.animate(
            withDuration: 0.34,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.24,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }
}
