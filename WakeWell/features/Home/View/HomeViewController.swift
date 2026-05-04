import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = HomeViewModel()

    // MARK: - Lifecycle
    private var isAnimatingMetrics = false

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        collectionView.delegate        = self
        collectionView.dataSource      = self
        collectionView.allowsSelection = true
        registerCells()
        addProfileButton()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize       = .zero
            layout.minimumLineSpacing      = 16
            layout.minimumInteritemSpacing = 8
            layout.sectionInset            = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAlarmCard),
            name: .alarmTimeDidChange,
            object: nil
        )

        refreshSleepDebtFromHealthKit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    @objc private func reloadAlarmCard() {
        guard let alarmIndex = viewModel.cards.firstIndex(where: {
            if case .alarm = $0 { return true }
            return false
        }) else { return }
        collectionView.reloadItems(at: [IndexPath(item: alarmIndex, section: 0)])
    }

    private func refreshSleepDebtFromHealthKit() {
        HealthKitSleepRepository.shared.prefetch(for: .week) { [weak self] in
            guard let self else { return }
            self.viewModel.reloadSleepDebtFromHealthKit()
            self.collectionView.reloadData()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Theme

    private func applyTheme() {
        view.backgroundColor = WakeWellTheme.background
        collectionView.backgroundColor = WakeWellTheme.background
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
    }

    // MARK: - Profile Button

    private func addProfileButton() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        btn.setImage(UIImage(systemName: "person.crop.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = WakeWellTheme.accentGold
        btn.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }

    @objc private func profileButtonTapped() {
        let profileVC = ProfileTableViewController(style: .plain)
        let nav = UINavigationController(rootViewController: profileVC)
        nav.modalPresentationStyle = .pageSheet
        if #available(iOS 16.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents               = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 24
            }
        }
        present(nav, animated: true)
    }

    // MARK: - Helpers

    private var groggyNotesIndexPath: IndexPath? {
        guard let index = viewModel.cards.firstIndex(where: {
            if case .groggyNotes = $0 { return true }
            return false
        }) else { return nil }
        return IndexPath(item: index, section: 0)
    }

    private func updateKeyboardInsets(bottom: CGFloat) {
        collectionView.contentInset.bottom        = bottom
        collectionView.scrollIndicatorInsets.bottom = bottom
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        updateKeyboardInsets(bottom: frame.height + 24)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        updateKeyboardInsets(bottom: 0)
    }

    private func focusGroggyNotesCard() {
        guard let indexPath = groggyNotesIndexPath else { return }
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }

    // MARK: - Cell Registration

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
            LiveVitalsCollectionViewCell.self,
            forCellWithReuseIdentifier: LiveVitalsCollectionViewCell.identifier
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
            cell.onStartRitual = { [weak self] in
                guard let self else { return }
                WatchConnectivityReceiver.shared.startRiseRitualOnWatch()

                let alert = UIAlertController(
                    title: "Opening on Apple Watch",
                    message: "WakeWell sent Rise Ritual to your watch.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
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
                let metricsIndex: Int?
                if shouldExpand {
                    self.viewModel.toggleMetricsCard()
                    metricsIndex = self.viewModel.cards.firstIndex {
                        if case .metrics = $0 { return true }
                        return false
                    }
                } else {
                    metricsIndex = self.viewModel.cards.firstIndex {
                        if case .metrics = $0 { return true }
                        return false
                    }
                    self.viewModel.toggleMetricsCard()
                }
                cell.animateChevron(expanded: shouldExpand)

                guard let metricsIndex else {
                    self.collectionView.reloadData()
                    self.isAnimatingMetrics = false
                    return
                }

                self.collectionView.performBatchUpdates {
                    let indexPath = IndexPath(item: metricsIndex, section: 0)
                    if shouldExpand {
                        self.collectionView.insertItems(at: [indexPath])
                    } else {
                        self.collectionView.deleteItems(at: [indexPath])
                    }
                } completion: { _ in self.isAnimatingMetrics = false }
            }
            return cell

        case .alarm:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlarmCollectionViewCell.identifier,
                for: indexPath
            ) as! AlarmCollectionViewCell
            let freshTime  = UserDefaults.standard.object(forKey: "wakewell.savedAlarmTime") as? Date
            let freshModel = AlarmModel(time: freshTime)
            cell.configure(with: HomeAlarmViewModel(model: freshModel))
            cell.onTapped = { [weak self] in
                guard let self else { return }
                let vc  = AlarmOptionViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .pageSheet
                self.present(nav, animated: true)
            }
            return cell

        case .metrics(let model):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_metrics_cell",
                for: indexPath
            ) as! SleepMetricsGridCollectionViewCell
            cell.configure(with: SleepMetricsViewModel(model: model))
            return cell

        case .liveVitals:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LiveVitalsCollectionViewCell.identifier,
                for: indexPath
            ) as! LiveVitalsCollectionViewCell
            cell.configure()
            return cell

        case .groggyNotes(let groggyModel, let notesModel):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GroggyNotesCollectionViewCell.identifier,
                for: indexPath
            ) as! GroggyNotesCollectionViewCell
            cell.onBeginEditing = { [weak self] in
                self?.focusGroggyNotesCard()
            }
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

        let fullWidth = collectionView.bounds.width - 32
        let halfWidth = (fullWidth - 8) / 2

        switch viewModel.cards[indexPath.item] {
        case .sleepDebt:    return CGSize(width: fullWidth, height: 60)
        case .riseRitual:   return CGSize(width: fullWidth, height: 92)
        case .sleepRing:    return CGSize(width: halfWidth, height: 200)
        case .alarm:        return CGSize(width: halfWidth, height: 200)
        case .liveVitals:   return CGSize(width: fullWidth, height: 190)
        case .metrics:      return CGSize(width: fullWidth, height: 200)
        case .groggyNotes:  return CGSize(width: fullWidth, height: 250)
        case .sounds:       return CGSize(width: fullWidth, height: 60)
        }
    }
}

// MARK: - UICollectionViewDelegate

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
