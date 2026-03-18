//
//  SoundPickerViewController.swift
//  WakeWell
//
//  Created by geu on 16/03/26.
//

import UIKit
import AVFoundation

protocol SoundPickerDelegate: AnyObject {
    func didSelectSound(_ name: String)
}
class SoundPickerViewController: UITableViewController {
    
    var selectedSoundName: String = "Early Riser"
    weak var delegate: SoundPickerDelegate?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
  
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            tableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
  
        if let soundName = cell?.textLabel?.text {
            selectedSoundName = soundName
            delegate?.didSelectSound(soundName) // Send the name back
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

