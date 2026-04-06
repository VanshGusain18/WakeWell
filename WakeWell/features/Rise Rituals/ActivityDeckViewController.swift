//
//  ActivityDeckViewController.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

import UIKit

class ActivityDeckViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewToggle: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func toggleChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            collectionView.isHidden = false
            tableView.isHidden = true
        } else {
            collectionView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true   // start with cards
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(ActivityCardViewCell.self, forCellWithReuseIdentifier: "cell")
        setupLayout()
//        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
//        navigationItem.rightBarButtonItem = refreshButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadActivities()
        shuffledActivities = activities.shuffled()
        collectionView.reloadData()
        tableView.reloadData()
    }
    // layout for the card where 
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count   // NOT shuffled
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)

        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.title
        cell.detailTextLabel?.text = activity.category

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           
            activities.remove(at: indexPath.row)
            saveActivities()
            tableView.deleteRows(at: [indexPath], with: .fade)
            shuffledActivities = activities.shuffled()
            collectionView.reloadData()
        }
    }
    // choosing of the card and showing it in the new screen
    @IBAction func chooseTapped(_ sender: UIButton) {
        print("Choose tapped") //just to check
        let index = getCenteredIndex()
        print("Index:", index) // just to check
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
    
    @IBAction func addTapped() {
        let storyboard = UIStoryboard(name: "Rise", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "AddActivityViewController") as! AddActivityViewController
        vc.delegate = self
        present(vc, animated: true)
    }
    
//    @objc func refreshData() {
//        loadActivities()
//        shuffledActivities = activities.shuffled()
//        
//        // Add a small haptic pop so the user feels the refresh
//        UISelectionFeedbackGenerator().selectionChanged()
//        
//        collectionView.reloadData()
//        tableView.reloadData()
//        
//        print("Data refreshed: \(activities.count) activities found.")
//    }
    
    func loadActivities() {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.data(forKey: "activities") { // to show the saved chnages by the user.
            do {
                activities = try decoder.decode([Activity].self, from: data)
            } catch {
                print("Error loading activities:", error)
            }
        }
    }
    func saveActivities() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(activities)
            UserDefaults.standard.set(data, forKey: "activities")
        } catch {
            print("Error saving after deletion: \(error)")
        }
    }
}
extension ActivityDeckViewController: AddActivityDelegate {
    func didSaveNewActivity() {
        loadActivities()
        shuffledActivities = activities.shuffled()
        
        collectionView.reloadData()
        tableView.reloadData()
    }
}
