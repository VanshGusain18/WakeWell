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
    }
}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == 0 {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "alarm_cell",
                for: indexPath
            ) as! AlarmCollectionViewCell

            let model = AlarmModel(time: Date().addingTimeInterval(3600 * 8))
            let viewModel = AlarmViewModel(model: model)

            cell.configure(with: viewModel)
            return cell
        }

        else {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_ring_cell",
                for: indexPath
            ) as! SleepRingCollectionViewCell

            let model = SleepRingModel(score: 82, subtitle: "Great sleep")
            let viewModel = SleepRingViewModel(model: model)

            cell.configure(with: viewModel)
            return cell
        }
    }

}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 32

        if indexPath.item == 0 {
            return CGSize(width: width, height: 120)
        } else {
            return CGSize(width: width, height: 230)
        }
    }
}

