import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = HomeViewModel()

    // MARK: - Lifecycle
    private var isAnimatingMetrics = false

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate        = self
        collectionView.dataSource      = self
        collectionView.allowsSelection = true
        registerCells()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize       = .zero
            layout.minimumLineSpacing      = 16
            layout.minimumInteritemSpacing = 8   // horizontal gap between the two half-width cards
            layout.sectionInset            = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }

    private func registerCells() {
        collectionView.register(
            UINib(nibName: SleepDebtViewCardCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: SleepDebtViewCardCell.identifier
        )
        collectionView.register(
            UINib(nibName: RiseRitualCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: RiseRitualCollectionViewCell.identifier
        )
        // Individual cells registered directly — no wrapper pair cell needed.
        collectionView.register(
            UINib(nibName: SleepRingCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: SleepRingCollectionViewCell.identifier
        )
        collectionView.register(
            UINib(nibName: AlarmCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: AlarmCollectionViewCell.identifier
        )
        collectionView.register(
            UINib(nibName: "SleepMetricsGridCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "sleep_metrics_cell"
        )
        collectionView.register(
            UINib(nibName: GroggyNotesCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: GroggyNotesCollectionViewCell.identifier
        )
        collectionView.register(
            UINib(nibName: "SleepSoundsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "sleep_sounds_cell"
        )
    }
}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.cardCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let card = viewModel.cards[indexPath.item]

        switch card {
            
        case .sleepDebt(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SleepDebtViewCardCell.identifier,
                for: indexPath
            ) as! SleepDebtViewCardCell
            cell.configure(with: SleepDebtViewModel(model: model))
            cell.onClose = { [weak self] in
                guard let self else { return }
                self.viewModel.removeSleepDebtCard()
                self.collectionView.performBatchUpdates {
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
            return cell
            
        case .riseRitual(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RiseRitualCollectionViewCell.identifier,
                for: indexPath
            ) as! RiseRitualCollectionViewCell
            cell.configure(with: RiseRitualViewModel(model: model))
            cell.onClose = { [weak self] in
                guard let self else { return }
                guard let currentIndex = self.viewModel.cards.firstIndex(where: {
                    if case .riseRitual = $0 { return true }
                    return false
                }) else { return }
                self.viewModel.removeRiseRitualCard()
                self.collectionView.performBatchUpdates {
                    self.collectionView.deleteItems(at: [IndexPath(item: currentIndex, section: 0)])
                }
            }
            return cell

        case .sleepRing(let ringModel):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SleepRingCollectionViewCell.identifier,
                for: indexPath
            ) as! SleepRingCollectionViewCell
            cell.configure(with: SleepRingViewModel(model: ringModel))
            cell.onChevronTapped = { [weak self] in
                guard let self, !self.isAnimatingMetrics else { return }
                self.isAnimatingMetrics = true

                let shouldExpand = !self.viewModel.showMetricsCard
                self.viewModel.toggleMetricsCard()
                cell.animateChevron(expanded: shouldExpand)
                
                guard let ringIndex = self.viewModel.cards.firstIndex(where: {
                    if case .sleepRing = $0 { return true }
                    return false
                }) else { self.isAnimatingMetrics = false; return }

                self.collectionView.performBatchUpdates {
                    let metricsIndex = IndexPath(item: ringIndex + 2, section: 0)
                    if shouldExpand {
                        self.collectionView.insertItems(at: [metricsIndex])
                    } else {
                        self.collectionView.deleteItems(at: [metricsIndex])
                    }
                } completion: { _ in self.isAnimatingMetrics = false }
            }
            return cell

        case .alarm(let alarmModel):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlarmCollectionViewCell.identifier,
                for: indexPath
            ) as! AlarmCollectionViewCell
            cell.configure(with: AlarmViewModel(model: alarmModel))
            cell.onTapped = { [weak self] in
                guard let self else { return }
                let vc = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "alarm")
                vc.modalPresentationStyle = .automatic
                self.present(vc, animated: true)
            }
            return cell

        case .metrics(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_metrics_cell",
                for: indexPath
            ) as! SleepMetricsGridCollectionViewCell
            cell.configure(with: SleepMetricsViewModel(model: model))
            return cell

        case .groggyNotes(let groggyModel, let notesModel):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GroggyNotesCollectionViewCell.identifier,
                for: indexPath
            ) as! GroggyNotesCollectionViewCell
            cell.configure(
                groggy: GroggySliderViewModel(model: groggyModel),
                notes:  MorningNotesViewModel(model: notesModel)
            )
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

        let fullWidth = collectionView.bounds.width - 32
        let halfWidth = (fullWidth - 8) / 2

        switch viewModel.cards[indexPath.item] {
        case .sleepDebt:    return CGSize(width: fullWidth, height: 60)
        case .riseRitual:   return CGSize(width: fullWidth, height: 200)
        case .sleepRing:    return CGSize(width: halfWidth, height: 200)
        case .alarm:        return CGSize(width: halfWidth, height: 200)
        case .metrics:      return CGSize(width: fullWidth, height: 200)
        case .groggyNotes:  return CGSize(width: fullWidth, height: 280)
        case .sounds:       return CGSize(width: fullWidth, height: 60)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard case .sounds = viewModel.cards[indexPath.item] else { return }
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "sound")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
