//
//  ViewController.swift
//  riseRitual
//
//  Created by geu on 28/01/26.
//

import UIKit

class RiseRitualViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var RiseRitualCollectionView: UICollectionView!
    
    var ritualsData = RitualsData()
    var mindfulnessActivities: [Ritual] = []
    var physicalActivities: [Ritual] = []
    var nutritionActivities: [Ritual] = []
    var productivityActivities: [Ritual] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rise Ritual"
        print(ritualsData.rituals(for: .mindfulness))
        
        mindfulnessActivities = ritualsData.rituals(for: .mindfulness)
        physicalActivities = ritualsData.rituals(for: .physical)
        nutritionActivities = ritualsData.rituals(for: .nutrition)
        productivityActivities = ritualsData.rituals(for: .productivity)
        registerCells()
        
        RiseRitualCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        RiseRitualCollectionView.dataSource = self
        RiseRitualCollectionView.delegate = self
        RiseRitualCollectionView.reloadData()
    }

    func registerCells() {
        //mindfulness cell
        RiseRitualCollectionView.register(UINib(nibName: "ActivitiesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "mindfulness_cell")
        RiseRitualCollectionView.register(UINib(nibName: "ActivitiesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "physical_cell")
        RiseRitualCollectionView.register(UINib(nibName: "ActivitiesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "nutrition_cell")
        RiseRitualCollectionView.register(UINib(nibName: "ActivitiesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "productivity_cell")
        RiseRitualCollectionView.register(UINib(nibName: "SectionHeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "header_view")
    }

}
extension RiseRitualViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return mindfulnessActivities.count
        }
        if section == 1 {
            return physicalActivities.count
        }
        if section == 2 {
            return nutritionActivities.count
        }
        if section == 3 {
            return productivityActivities.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var headerView: SectionHeaderView!
        
        if kind == "header" {
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header_view", for: indexPath) as? SectionHeaderView
            if indexPath.section == 0 {
                //headerView.headerLabel.textAlignment = .center
                headerView.configure(withTitle: "Mindfulnesss")
            } else if indexPath.section == 1 {
                headerView.configure(withTitle: "Physical")
            } else if indexPath.section == 2 {
                headerView.configure(withTitle: "Nutrition")
            }
            else if indexPath.section == 3 {
                headerView.configure(withTitle: "Productivity")
            }
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mindfulness_cell", for: indexPath) as! ActivitiesCollectionViewCell
            let mindfullnessActivity = mindfulnessActivities[indexPath.row]
            cell.configure(ritual: mindfullnessActivity)
            cell.imageView.layer.cornerRadius = 10
            return cell
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "physical_cell", for: indexPath) as! ActivitiesCollectionViewCell
            let physicalActivity = physicalActivities[indexPath.row]
            cell.configure(ritual: physicalActivity)
            cell.imageView.layer.cornerRadius = 10
            return cell
        }
        else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nutrition_cell", for: indexPath) as! ActivitiesCollectionViewCell
            let nutritionActivity = nutritionActivities[indexPath.row]
            cell.configure(ritual: nutritionActivity)
            cell.imageView.layer.cornerRadius = 10
            return cell
        }
        else if indexPath.section == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productivity_cell", for: indexPath) as! ActivitiesCollectionViewCell
            let productivityActivity = productivityActivities[indexPath.row]
            cell.configure(ritual: productivityActivity)
            cell.imageView.layer.cornerRadius = 10
            return cell
        }
        return UICollectionViewCell()
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .topLeading)
            
            if sectionIndex == 0 {
                let section = self.generateSectionForMindfulness()
                section.boundarySupplementaryItems = [header]
                return section
            }
            if sectionIndex == 1 {
                let section = self.generateSectionForPhysical()
                section.boundarySupplementaryItems = [header]
                return section
            }
            if sectionIndex == 2 {
                let section = self.generateSectionForNutrition()
                section.boundarySupplementaryItems = [header]
                return section
            }
            if sectionIndex == 3 {
                let section = self.generateSectionForProductivity()
                section.boundarySupplementaryItems = [header]
                return section
            }
            return self.generateSectionForMindfulness()
        }
        return layout
    }
    
    // MARK: - Compositional Layout Sections

    func generateSquareSection() -> NSCollectionLayoutSection {
        //Define Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        //  Define group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.66),
            heightDimension: .fractionalWidth(0.66)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // Define Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered // Centers the main item
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            let containerWidth = environment.container.contentSize.width
            let centerX = offset.x + (containerWidth / 2.0)

            items.forEach { item in
             
                guard item.representedElementCategory == .cell else { return }

                let distanceFromCenter = abs(item.center.x - centerX)
                let minScale: CGFloat = 0.92
                let maxScale: CGFloat = 1.0
                let scale = max(maxScale - (distanceFromCenter / containerWidth), minScale)
                 item.transform = CGAffineTransform(scaleX: scale, y: scale)
                item.alpha = (scale == 1.0) ? 1.0 : 0.9
            }
        }

        return section
    }
    func generateSectionForMindfulness() -> NSCollectionLayoutSection { return generateSquareSection() }
    func generateSectionForPhysical() -> NSCollectionLayoutSection { return generateSquareSection() }
    func generateSectionForNutrition() -> NSCollectionLayoutSection { return generateSquareSection() }
    func generateSectionForProductivity() -> NSCollectionLayoutSection { return generateSquareSection() }
    
}
extension RiseRitualViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRitual: Ritual
        
        switch indexPath.section {
        case 0:
            selectedRitual = mindfulnessActivities[indexPath.row]
        case 1:
            selectedRitual = physicalActivities[indexPath.row]
        case 2:
            selectedRitual = nutritionActivities[indexPath.row]
        case 3:
            selectedRitual = productivityActivities[indexPath.row]
        default:
            return
        }
        
        //  Initializing Detail ViewController
        let detailVC = RitualDetailViewController(nibName: "RitualDetailViewController", bundle: nil)
        
        // Pass the data
        detailVC.ritual = selectedRitual
        detailVC.modalPresentationStyle = .overFullScreen
        detailVC.modalTransitionStyle = .crossDissolve
            
        self.present(detailVC, animated: true)
        //self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
