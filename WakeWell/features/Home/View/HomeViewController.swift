import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

        private let viewModel = HomeViewModel()

        // MARK: - Lifecycle
    private var isAnimatingMetrics = false
    
        override func viewDidLoad() {
            super.viewDidLoad()
            collectionView.delegate   = self
            collectionView.dataSource = self
            collectionView.allowsSelection = true
            registerCells()

            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.estimatedItemSize = .zero
                layout.minimumLineSpacing = 16
                layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            }
        }

        // MARK: - Cell registration

        private func registerCells() {
            collectionView.register(
                UINib(nibName: SleepDebtViewCardCell.identifier, bundle: nil),
                forCellWithReuseIdentifier: SleepDebtViewCardCell.identifier
            )
            collectionView.register(
                UINib(nibName: RiseRitualCollectionViewCell.identifier, bundle: nil),
                forCellWithReuseIdentifier: RiseRitualCollectionViewCell.identifier
            )
            collectionView.register(
                UINib(nibName: SleepRingAlarmPairCell.identifier, bundle: nil),
                forCellWithReuseIdentifier: SleepRingAlarmPairCell.identifier
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

    // MARK: - UICollectionViewDataSource

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

            // ── Sleep debt alert ───────────────────────────────────────────────
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
                
                // ── Rise ritual ────────────────────────────────────────────────────
                
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

            // ── Sleep ring + alarm (side-by-side) ─────────────────────────────
            case .sleepRingWithAlarm(let ringModel, let alarmModel):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SleepRingAlarmPairCell.identifier,
                    for: indexPath
                ) as! SleepRingAlarmPairCell

                cell.configure(ring: ringModel, alarm: alarmModel)

                cell.onChevronTapped = { [weak self] in
                    guard let self else { return }
                    if self.isAnimatingMetrics { return }
                    self.isAnimatingMetrics = true

                    let shouldExpand = !self.viewModel.showMetricsCard
                    self.viewModel.toggleMetricsCard()
                    cell.animateChevron(expanded: shouldExpand)
                    guard let currentIndex = self.viewModel.cards.firstIndex(where: {
                        if case .sleepRingWithAlarm = $0 { return true }
                        return false
                    }) else {
                        self.isAnimatingMetrics = false
                        return
                    }
                    self.collectionView.performBatchUpdates {
                        if shouldExpand {
                            let insertIndex = currentIndex + 1
                            self.collectionView.insertItems(at: [IndexPath(item: insertIndex, section: 0)])
                        } else {
                            let deleteIndex = currentIndex + 1
                            self.collectionView.deleteItems(at: [IndexPath(item: deleteIndex, section: 0)])
                        }
                    } completion: { _ in
                        self.isAnimatingMetrics = false
                    }
                }

                cell.onAlarmTapped = { [weak self] in
                    guard let self else { return }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "alarm")
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

    // MARK: - UICollectionViewDelegateFlowLayout

    extension HomeViewController: UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {

            let width = collectionView.bounds.width - 32
            let card  = viewModel.cards[indexPath.item]

            switch card {
            case .sleepDebt:             return CGSize(width: width, height: 60)
            case .riseRitual:            return CGSize(width: width, height: 200)
            case .sleepRingWithAlarm:    return CGSize(width: width, height: 200)
            case .metrics:               return CGSize(width: width, height: 200)
            case .groggyNotes:           return CGSize(width: width, height: 280)
            case .sounds:                return CGSize(width: width, height: 60)
            }
        }
    }

    // MARK: - UICollectionViewDelegate

    extension HomeViewController: UICollectionViewDelegate {

        func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {

            let card = viewModel.cards[indexPath.item]
            switch card {
            case .sounds:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "sound")
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            default:
                break
            }
        }
    }
