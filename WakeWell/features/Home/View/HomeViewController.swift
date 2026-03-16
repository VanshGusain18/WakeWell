import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = HomeViewModel()
    
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

        case .alarm(let alarmVM):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "alarm_cell",
                for: indexPath
            ) as! AlarmCollectionViewCell

            cell.configure(with: alarmVM)
            return cell

        case .sleepRing(let ringVM):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_ring_cell",
                for: indexPath
            ) as! SleepRingCollectionViewCell

            cell.configure(with: ringVM)
            return cell

        case .metrics(let vm):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_metrics_cell",
                for: indexPath
            ) as! SleepMetricsGridCollectionViewCell

            cell.configure(with: vm)
            return cell

        case .groggy(let vm):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "groggy_slider_cell",
                for: indexPath
            ) as! GroggySliderCollectionViewCell

            cell.configure(with: vm)
            return cell

        case .notes(let vm):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "morning_notes_cell",
                for: indexPath
            ) as! MorningNotesCollectionViewCell

            cell.configure(with: vm)
            return cell

        case .sounds(let vm):

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_sounds_cell",
                for: indexPath
            ) as! SleepSoundsCollectionViewCell

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

        switch indexPath.item {

        case 0:
            return CGSize(width: width, height: 120)

        case 1:
            return CGSize(width: width, height: 230)

        case 2:
            return CGSize(width: width, height: 200)
        
        case 3:
            return CGSize(width: width, height: 140)
            
        case 4:
            return CGSize(width: width, height: 160)
            
        default:
            return CGSize(width: width, height: 70)
        }
    }
}
