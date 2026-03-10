import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
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
    }
}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.item {

        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "alarm_cell",
                for: indexPath
            ) as! AlarmCollectionViewCell

            let model = AlarmModel(time: Date().addingTimeInterval(3600 * 8))
            let viewModel = AlarmViewModel(model: model)

            cell.configure(with: viewModel)
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_ring_cell",
                for: indexPath
            ) as! SleepRingCollectionViewCell

            let model = SleepRingModel(score: 82, subtitle: "Good sleep")
            let viewModel = SleepRingViewModel(model: model)

            cell.configure(with: viewModel)
            return cell

        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_metrics_cell",
                for: indexPath
            ) as! SleepMetricsGridCollectionViewCell

            return cell
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 32

        switch indexPath.item {

        case 0:
            return CGSize(width: width, height: 120)

        case 1:
            return CGSize(width: width, height: 230)

        default:
            return CGSize(width: width, height: 200)
        }
    }
}
