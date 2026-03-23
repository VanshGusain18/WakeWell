import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        registerCells()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }

    private func registerCells() {
        collectionView.register(
            UINib(nibName: "AlarmCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "alarm_cell"
        )

        collectionView.register(
            UINib(nibName: "SleepRingCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "sleep_ring_cell"
        )

        collectionView.register(
            UINib(nibName: "SleepMetricsGridCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "sleep_metrics_cell"
        )
        collectionView.register(
            UINib(nibName: "GroggySliderCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "groggy_slider_cell"
        )
        collectionView.register(
            UINib(nibName: "MorningNotesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "morning_notes_cell"
        )
        collectionView.register(
            UINib(nibName: "SleepSoundsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "sleep_sounds_cell"
        )
    }
}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.cardCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let card = viewModel.cards[indexPath.item]

        switch card {

        case .alarm(let model):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "alarm_cell",
                for: indexPath
            ) as! AlarmCollectionViewCell

            let vm = AlarmViewModel(model: model)
            cell.configure(with: vm)
            return cell

        case .sleepRing(let model):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_ring_cell",
                for: indexPath
            ) as! SleepRingCollectionViewCell

            let vm = SleepRingViewModel(model: model)
            cell.configure(with: vm)
            return cell

        case .metrics(let model):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_metrics_cell",
                for: indexPath
            ) as! SleepMetricsGridCollectionViewCell

            let vm = SleepMetricsViewModel(model: model)
            cell.configure(with: vm)
            return cell

        case .groggy(let model):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "groggy_slider_cell",
                for: indexPath
            ) as! GroggySliderCollectionViewCell

            let vm = GroggySliderViewModel(model: model)
            cell.configure(with: vm)
            return cell

        case .notes(let model):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "morning_notes_cell",
                for: indexPath
            ) as! MorningNotesCollectionViewCell

            let vm = MorningNotesViewModel(model: model)
            cell.configure(with: vm)
            return cell

        case .sounds:

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_sounds_cell",
                for: indexPath
            ) as! SleepSoundsCollectionViewCell

            let vm = SleepSoundsViewModel()
            cell.configure(with: vm)

            return cell
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 32
        let card = viewModel.cards[indexPath.item]

        switch card {

        case .alarm:
            return CGSize(width: width, height: 120)

        case .sleepRing:
            return CGSize(width: width, height: 230)

        case .metrics:
            return CGSize(width: width, height: 200)

        case .groggy:
            return CGSize(width: width, height: 140)

        case .notes:
            return CGSize(width: width, height: 160)

        case .sounds:
            return CGSize(width: width, height: 70)
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

        default:
            break
        }
    }
}
