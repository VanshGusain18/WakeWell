//
//  HapticPickerViewController.swift
//  WakeWell
//
//  Created by geu on 16/03/26.
//

import UIKit

protocol HapticPickerDelegate: AnyObject {
    func didSelectHaptic(_ name: String)
}

class HapticPickerViewController: UITableViewController {
    
    weak var delegate: HapticPickerDelegate?
    var selectedHapticLabel: String = "None (Default)" // default this will be shown
    var selectedIndexPath: IndexPath?
    
    // Official iOS Haptic Patterns
    let standardHaptics = ["Accent", "Alert", "Heartbeat", "Quick", "Rapid", "S.O.S.", "Staccato", "Symphony"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let index = standardHaptics.firstIndex(of: selectedHapticLabel) {
            selectedIndexPath = IndexPath(row: index, section: 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        standardHaptics.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = standardHaptics[indexPath.row]
        
        cell.accessoryType = .checkmark 
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UISelectionFeedbackGenerator().selectionChanged()
        selectedIndexPath = indexPath
        selectedHapticLabel = standardHaptics[indexPath.row]
        
        delegate?.didSelectHaptic(selectedHapticLabel)
        tableView.reloadData()
        
        // Return to options after a brief delay to show the checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
