//
//  SoundPickerViewController.swift
//  WakeWell
//
//  Created by geu on 16/03/26.
//

import UIKit
import AVFoundation

protocol SoundPickerDelegate: AnyObject {
    func didSelectSound(_ name: String, haptic: String)
}
class SoundPickerViewController: UITableViewController, HapticPickerDelegate {
    
    let sounds = ["Early Riser", "Birdsong", "Chimes", "Ocean", "Rain"]
    
    var selectedSoundName: String = "Early Riser"
    var selectedHaptic: String = "None (Default) "
    var selectedIndexPath: IndexPath?  // to select the sleecetd row
    weak var delegate: SoundPickerDelegate? // making the delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let index = sounds.firstIndex(of: selectedSoundName) {
            selectedIndexPath = IndexPath(row: index, section: 0)
        }
    }
    
    // calling the haptic delegate
    func didSelectHaptic(_ name: String) {
        selectedHaptic = name
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HapticPickerViewController {
            vc.delegate = self
            vc.selectedHapticLabel = selectedHaptic
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath == selectedIndexPath {
            cell.detailTextLabel?.text = selectedHaptic
            cell.accessoryType = .checkmark
        } else {
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        UISelectionFeedbackGenerator().selectionChanged()
        selectedIndexPath = indexPath
        let cell = tableView.cellForRow(at: indexPath)

        if let soundName = cell?.textLabel?.text {
            selectedSoundName = soundName
            delegate?.didSelectSound(soundName, haptic: selectedHaptic) // sending the name back
        }
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

