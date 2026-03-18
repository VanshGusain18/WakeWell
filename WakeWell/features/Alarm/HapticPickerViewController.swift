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
    var selectedHapticLabel: String = "None (Default)"
    
    // Official iOS Haptic Patterns
    let standardHaptics = ["Accent", "Alert", "Heartbeat", "Quick", "Rapid", "S.O.S.", "Staccato", "Symphony"]

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UISelectionFeedbackGenerator().selectionChanged()
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                tableView.cellForRow(at: IndexPath(row: row, section: section))?.accessoryType = .none
            }
        }
        
        let cell = tableView.cellForRow(at: indexPath)
//        cell?.accessoryType = .checkmark
        
        if let hapticName = cell?.textLabel?.text {
            selectedHapticLabel = hapticName
            delegate?.didSelectHaptic(hapticName)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Return to options after a brief delay to show the checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
