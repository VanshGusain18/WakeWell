import UIKit
import SwiftUI

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = HomeViewModel()
    private let demoButton = UIButton(type: .system)
    private let liveVitalsController = UIHostingController(rootView: LiveVitalsPanel())

    // MARK: - Lifecycle
    private var isAnimatingMetrics = false

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate        = self
        collectionView.dataSource      = self
        collectionView.allowsSelection = true
        registerCells()
        configureLiveVitalsPanel()
        configureDemoButton()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize       = .zero
            layout.minimumLineSpacing      = 16
            layout.minimumInteritemSpacing = 8   // horizontal gap between the two half-width cards
            layout.sectionInset            = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }

        // Reload the alarm card whenever the user saves a new time in AlarmOptionViewController.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAlarmCard),
            name: .alarmTimeDidChange,
            object: nil
        )
    }

    @objc private func reloadAlarmCard() {
        guard let alarmIndex = viewModel.cards.firstIndex(where: {
            if case .alarm = $0 { return true }
            return false
        }) else { return }
        collectionView.reloadItems(at: [IndexPath(item: alarmIndex, section: 0)])
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    private func configureDemoButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Open Smart Alarm Debug"
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)

        demoButton.configuration = configuration
        demoButton.translatesAutoresizingMaskIntoConstraints = false
        demoButton.addTarget(self, action: #selector(openSmartDebugTapped), for: .touchUpInside)

        view.addSubview(demoButton)

        NSLayoutConstraint.activate([
            demoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            demoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            demoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            demoButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])

        collectionView.contentInset.bottom = 100
        collectionView.verticalScrollIndicatorInsets.bottom = 100
    }

    private func configureLiveVitalsPanel() {
        addChild(liveVitalsController)
        liveVitalsController.view.translatesAutoresizingMaskIntoConstraints = false
        liveVitalsController.view.backgroundColor = .clear

        view.addSubview(liveVitalsController.view)

        NSLayoutConstraint.activate([
            liveVitalsController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            liveVitalsController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            liveVitalsController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])

        liveVitalsController.didMove(toParent: self)

        collectionView.contentInset.top = 132
        collectionView.verticalScrollIndicatorInsets.top = 132
    }

    @objc private func openSmartDebugTapped() {
        WatchDataManager.shared.startDebugSession()

        let debugView = SmartDebugView()
        let controller = UIHostingController(rootView: debugView)

        if let navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            let wrapped = UINavigationController(rootViewController: controller)
            present(wrapped, animated: true)
        }
    }
}

private struct LiveVitalsPanel: View {
    @ObservedObject private var connection = AppConnectionState.shared
    @ObservedObject private var vitals = LiveVitalsViewModel.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(statusText)
                    .font(.headline)
                Spacer()
                Text(lastUpdateText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                metric(title: "Heart Rate", value: "\(Int(vitals.heartRate.rounded()))", unit: "BPM")
                metric(title: "Motion", value: String(format: "%.3f", vitals.motion), unit: "")
                metric(title: "HRV", value: String(format: "%.1f", vitals.hrv), unit: "ms")
            }

            HStack {
                Text("HR: HealthKit")
                Spacer()
                Text("HRV: \(vitals.hrvStatus)")
                Spacer()
                Text("Motion: CoreMotion")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Text("Alert: \(vitals.alertStatus)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 5)
    }

    private var statusText: String {
        switch connection.state {
        case .waitingForWatch:
            return "🟡 Waiting for Apple Watch..."
        case .liveWatch:
            return "🟢 Live Watch Connected"
        }
    }

    private var lastUpdateText: String {
        guard let lastUpdated = vitals.lastUpdated else {
            return "Last update: --"
        }

        return "Last update: \(Self.timeFormatter.string(from: lastUpdated))"
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()

    private func metric(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.headline.monospacedDigit())
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

            // ── Start Ritual → switch to Rise tab (index 2) and trigger startRoutineTapped ──
            cell.onStartRitual = { [weak self] in
                guard let self else { return }
                self.tabBarController?.selectedIndex = 2
                // Give the tab a tick to finish appearing, then fire the routine
                DispatchQueue.main.async {
                    if let nav  = self.tabBarController?.selectedViewController as? UINavigationController,
                       let deck = nav.topViewController as? ActivityDeckViewController {
                        deck.startRoutineTapped()
                    }
                }
            }

            // ── View Rise Tab → just switch to the Rise tab ──────────────────
            cell.onViewRiseTab = { [weak self] in
                self?.tabBarController?.selectedIndex = 2
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

        case .alarm:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlarmCollectionViewCell.identifier,
                for: indexPath
            ) as! AlarmCollectionViewCell
            // Always pull the latest saved time — the model baked into allCards at init
            // may be stale if the user set an alarm during this session.
            let freshTime  = UserDefaults.standard.object(forKey: "wakewell.savedAlarmTime") as? Date
            let freshModel = AlarmModel(time: freshTime)
            cell.configure(with: AlarmViewModel(model: freshModel))
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
