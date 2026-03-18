//
//  ActivityDeckViewController.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

import UIKit

class ActivityDeckViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(ActivityCardViewCell.self, forCellWithReuseIdentifier: "cell")
        
        setupLayout()
    }
    
    func setupLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let width = view.frame.width * 0.7
        let height = view.frame.height * 0.5
        
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = 20
        
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shuffledActivities.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ActivityCardViewCell
        
        let activity = shuffledActivities[indexPath.item]
        
        cell.titleLabel.text = activity.title
        cell.categoryLabel.text = activity.category
        cell.imageView.image = UIImage(named: activity.imageName)
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let itemWidth = layout.itemSize.width
        let inset = (view.frame.width - itemWidth) / 2
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = shuffledActivities[indexPath.item]
        print("Selected: \(selected.title)")
    }
    
    @IBAction func shuffleTapped() {
        shuffledActivities.shuffle()
        collectionView.reloadData()
        performShuffleAnimation()
    }
    func performShuffleAnimation() {
        
        guard shuffledActivities.count > 0 else { return }
        
        let totalSpins = 1
        var delay: Double = 0.1
        
        for _ in 0..<totalSpins {
            
            let randomIndex = Int.random(in: 0..<shuffledActivities.count)
            let indexPath = IndexPath(item: randomIndex, section: 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.collectionView.scrollToItem(at: indexPath,
                                                 at: .centeredHorizontally,
                                                 animated: true)
            }
            
//            delay += 0.1 + (Double(i) * 0.02)
            delay += 0.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            let finalIndex = Int.random(in: 0..<shuffledActivities.count)
            let finalPath = IndexPath(item: finalIndex, section: 0)
            
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                
                self.collectionView.scrollToItem(at: finalPath,
                                                 at: .centeredHorizontally,
                                                 animated: false)
            })
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    @IBAction func chooseTapped(_ sender: UIButton) {
        
        print("Choose tapped")
        let index = getCenteredIndex()
        print("Index:", index)
        let selectedActivity = shuffledActivities[index]
        openDetail(activity: selectedActivity)
    }
    func getCenteredIndex() -> Int {
        let centerPoint = CGPoint(
            x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
            y: collectionView.bounds.height / 2
        )
        
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            return indexPath.item
        }
        
        return 0
    }
    func openDetail(activity: Activity) {
        let storyboard = UIStoryboard(name: "Rise", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ActivityDetailViewController") as! ActivityDetailViewController
        
        vc.activity = activity
        vc.modalTransitionStyle = .flipHorizontal
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
