//
//  AddActivityViewController.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

import UIKit

protocol AddActivityDelegate: AnyObject {
    func didSaveNewActivity()
}

class AddActivityViewController: UITableViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var categoryFields: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var stepsTextView: UITextView!
    @IBOutlet weak var durationField: UIButton!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    
    weak var delegate: AddActivityDelegate?
    
    let categories = ["Mindfulness", "Physical", "Productivity", "Nutrition", "Custom"]
    let durations = [30, 60, 120, 300, 600, 900]

    var selectedCategory = "Custom"
    var selectedDuration: Int?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(saveTapped)
        )
        setupMenus()
        categoryFields.contentHorizontalAlignment = .right
        durationField.contentHorizontalAlignment = .right

        categoryFields.setTitleColor(.systemGray, for: .normal)
        durationField.setTitleColor(.systemGray, for: .normal)
    }
    
    func setupMenus() {
        let categoryActions = categories.map { category in
            UIAction(title: category) { _ in
                self.selectedCategory = category
                self.categoryFields.setTitle(category, for: .normal)
            }
        }
        categoryFields.menu = UIMenu(title: "Select Category", children: categoryActions)
        categoryFields.showsMenuAsPrimaryAction = true
        
        let durationActions = durations.map { duration in
            UIAction(title: "\(duration / 60) min") { _ in
                self.selectedDuration = duration
                self.durationField.setTitle("\(duration / 60) min", for: .normal)
            }
        }
        
        durationField.menu = UIMenu(title: "Select Duration", children: durationActions)
        durationField.showsMenuAsPrimaryAction = true
    }
    
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let title = titleField.text, !title.isEmpty else { return }
        
        let stepsArray = stepsTextView.text
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        let duration = selectedDuration
        
        let newActivity = Activity(
            id: UUID().uuidString,
            title: title,
            description: descriptionTextView.text ?? "",
            duration: duration,
            category: selectedCategory,
            imageName: "ritual_1", // for now
            activityType: selectedType(),
            steps: stepsArray
        )
        
        activities.append(newActivity)
        saveActivities()
        
        delegate?.didSaveNewActivity()
        
        dismiss(animated: true)
    }

    func selectedType() -> ActivityType {
        switch typeSegment.selectedSegmentIndex {
        case 0: return .timerBased
        case 1: return .stepBased
        default: return .informational
        }
    }
    func saveActivities() {
        let encoder = JSONEncoder()  // to save the activitiies which have been added by the user.
        
        do {
            let data = try encoder.encode(activities)
            UserDefaults.standard.set(data, forKey: "activities")
        } catch {
            print("Error saving activities:", error)
        }
    }
}
