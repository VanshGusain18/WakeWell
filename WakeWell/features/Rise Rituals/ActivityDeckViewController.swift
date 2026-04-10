//
//  ActivityDeckViewController.swift
//  WakeWell
//

import UIKit

class ActivityDeckViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!

    var selectedActivityIDs: Set<String> = ["ritual_1", "ritual_3"]
    private let maximumActivitiesInRoutine = 5

    /// How many explore activities to show before "Show More"
    private let explorePreviewCount = 4
    private var isExploreExpanded = false

    enum Section: Int, CaseIterable {
        case morning
        case explore
    }


    var selectedActivities: [Activity] {
        activities.filter { selectedActivityIDs.contains($0.id) }
    }

    var allActivities: [Activity] { activities }

    // Activities shown in the Explore grid (limited or all)
    var exploreActivities: [Activity] {
        isExploreExpanded ? activities : Array(activities.prefix(explorePreviewCount))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false

        // Cells
        collectionView.register(ActivityCardViewCell.self,
                                forCellWithReuseIdentifier: "cell")
        collectionView.register(AddActivityCardCell.self,
                                forCellWithReuseIdentifier: AddActivityCardCell.identifier)

        // Supplementary
        collectionView.register(RitualHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: RitualHeaderView.identifier)
        collectionView.register(RoutineFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: RoutineFooterView.identifier)
        collectionView.register(ShowMoreFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ShowMoreFooterView.identifier)

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadActivities()
        shuffledActivities = activities.shuffled()
        collectionView.reloadData()
    }

    // to setup the layout of morning view an dexplore grid view

    func setupLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self, let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {

            case .morning:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .fractionalHeight(1.0))
                )
                item.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(0.85),
                                      heightDimension: .fractionalHeight(0.55)),
                    subitems: [item]
                )

                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .groupPagingCentered

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .absolute(60)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .absolute(80)),
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                sectionLayout.boundarySupplementaryItems = [header, footer]
                sectionLayout.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)
                return sectionLayout

            case .explore:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(0.5),
                                      heightDimension: .fractionalHeight(1.0))
                )
                item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .absolute(160)),
                    subitems: [item]
                )

                let sectionLayout = NSCollectionLayoutSection(group: group)

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .absolute(50)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                // Show More footer (hidden when expanded)
                let showMoreFooter = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .absolute(self.isExploreExpanded ? 0 : 52)),
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )

                sectionLayout.boundarySupplementaryItems = [header, showMoreFooter]
                return sectionLayout
            }
        }

        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    //  DataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .morning:
            // selectedActivities + 1 "Add" card at the end
            return selectedActivities.count + 1
        case .explore:
            return exploreActivities.count
        case .none:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = Section(rawValue: indexPath.section)!

        switch section {
        case .morning:
            // Last item is always the "Add" card
            if indexPath.item == selectedActivities.count {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AddActivityCardCell.identifier, for: indexPath)
                return cell
            }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "cell", for: indexPath) as! ActivityCardViewCell
            let activity = selectedActivities[indexPath.item]
            cell.configure(with: activity, isExplore: false)
            cell.menuProvider = { [weak self] in
                self?.makeOptionsMenu(for: activity)
            }
            cell.alpha = 1.0
            return cell

        case .explore:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "cell", for: indexPath) as! ActivityCardViewCell
            let activity = exploreActivities[indexPath.item]
            let isSelected = selectedActivityIDs.contains(activity.id)
            cell.configure(with: activity, isExplore: true)
            cell.menuProvider = { [weak self] in
                self?.makeOptionsMenu(for: activity)
            }
            cell.alpha = isSelected ? 1.0 : 0.6
            return cell
        }
    }


    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let section = Section(rawValue: indexPath.section)!

        switch section {
        case .morning:
            // Tapped the "Add" card → show picker sheet
            if indexPath.item == selectedActivities.count {
                presentAddActivityPicker()
            }

        case .explore:
            return
        }
    }


    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let section = Section(rawValue: indexPath.section)!

        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RitualHeaderView.identifier,
                for: indexPath) as! RitualHeaderView
            header.titleLabel.text = (section == .morning) ? "Your Morning Routine" : "Explore Activities"
            return header

        } else { // footer
            switch section {
            case .morning:
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RoutineFooterView.identifier,
                    for: indexPath) as! RoutineFooterView
                footer.startAction = { [weak self] in self?.startRoutineTapped() }
                return footer

            case .explore:
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ShowMoreFooterView.identifier,
                    for: indexPath) as! ShowMoreFooterView
                footer.isHidden = isExploreExpanded
                footer.onShowMore = { [weak self] in
                    guard let self else { return }
                    self.isExploreExpanded = true
                    self.setupLayout()          // rebuild layout to collapse footer height
                    self.collectionView.reloadSections(IndexSet(integer: Section.explore.rawValue))
                }
                return footer
            }
        }
    }


    // Presents a sheet listing all activities with checkmarks so the user can
    // add/remove items from the Morning Routine directly from this screen.
    
    private func presentAddActivityPicker() {
        let sheet = AddToMorningSheetViewController()
        sheet.allActivities       = allActivities
        sheet.selectedActivityIDs = selectedActivityIDs
        sheet.maximumSelections   = maximumActivitiesInRoutine
        sheet.onSelectionLimitReached = { [weak self] in
            self?.showSelectionLimitAlert()
        }
        sheet.onDone = { [weak self] updatedIDs in
            self?.selectedActivityIDs = updatedIDs
            self?.collectionView.reloadData()
        }
        let nav = UINavigationController(rootViewController: sheet)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    //  Activity Details

    private func makeOptionsMenu(for activity: Activity) -> UIMenu {
        let isInRoutine = selectedActivityIDs.contains(activity.id)

        let primaryAction: UIAction
        if isInRoutine {
            primaryAction = UIAction(
                title: "Remove Routine",
                image: UIImage(systemName: "minus.circle")
            ) { [weak self] _ in
                self?.selectedActivityIDs.remove(activity.id)
                self?.collectionView.reloadData()
            }
        } else {
            primaryAction = UIAction(
                title: "Add to Routine",
                image: UIImage(systemName: "plus.circle")
            ) { [weak self] _ in
                guard let self else { return }
                guard self.selectedActivityIDs.count < self.maximumActivitiesInRoutine else {
                    self.showSelectionLimitAlert()
                    return
                }
                self.selectedActivityIDs.insert(activity.id)
                self.collectionView.reloadData()
            }
        }

        let cancelAction = UIAction(
            title: "Cancel",
            image: UIImage(systemName: "xmark")
        ) { _ in }

        return UIMenu(title: "", options: .displayInline, children: [primaryAction, cancelAction])
    }

    private func showSelectionLimitAlert() {
        let alert = UIAlertController(
            title: "Routine Full",
            message: "You can add up to 5 activities to your morning ritual.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Start Routine

    @IBAction func startRoutineTapped() {
        guard !selectedActivities.isEmpty else { return }

        let vc = ActivityRunnerFactory.makeViewController(
            for: selectedActivities[0],
            routineQueue: selectedActivities,
            currentIndex: 0
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - loadActivities (global helper, unchanged)

func loadActivities() {
    let decoder = JSONDecoder()
    if let data = UserDefaults.standard.data(forKey: "activities") {
        do {
            activities = try decoder.decode([Activity].self, from: data)
        } catch {
            print("Error loading activities:", error)
        }
    }
}

//  AddActivityDelegate

extension ActivityDeckViewController: AddActivityDelegate {
    func didSaveNewActivity() {
        loadActivities()
        shuffledActivities = activities.shuffled()
        collectionView.reloadData()
    }
}
