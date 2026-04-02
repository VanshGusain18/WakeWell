//
//  AlarmOptionViewController.swift
//  WakeWell
//
//  Created by geu on 16/03/26.
//


import UIKit

class AlarmOptionViewController: UITableViewController, SoundPickerDelegate{
    
    @IBOutlet weak var wakeUpToggle: UISwitch!
    @IBOutlet weak var bedTimeToggle: UISwitch!
    @IBOutlet weak var buttonWindow: UIButton!
    @IBOutlet weak var selectedSoundLabel: UILabel!
    @IBOutlet weak var selectedSoundLabel2: UILabel!
    
    @IBOutlet weak var timePicker: CircularTimePicker!
    @IBOutlet weak var bedtimeLabel: UILabel!
    @IBOutlet weak var wakeupLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var doneTapped: UIBarButtonItem!
    
    private let wakeUpOptionRows = [1, 2, 3]
    private let bedtimeOptionRows = [1, 2]
    var selectedWindow = "30 min"
    var activeSection: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = true
        buttonWindow.setTitle(selectedWindow, for: .normal)
        setupSmartAlarmMenu()
        timePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
    }
    
    // the changing of the picker
    @IBAction func pickerChanged(_ sender: CircularTimePicker) {
        _ = angleToTimeString(timePicker.startAngle)
        _ = angleToTimeString(timePicker.endAngle)
        
        bedtimeLabel.text = timePicker.formatTime(timePicker.bedtime)
        wakeupLabel.text = timePicker.formatTime(timePicker.wakeUp)
        
        // Calculate Duration
        let diff = Calendar.current.dateComponents([.hour, .minute], from: timePicker.bedtime, to: timePicker.wakeUp)
        // if wakeup is next day
        var hours = diff.hour ?? 0
        if hours < 0 { hours += 24 }
        
        durationLabel.text = "\(hours) hr"
    }
    
    private func angleToTimeString(_ angle: CGFloat) -> String {
        return "10:30 PM"
    }
    
    // setting up the alarm window menu
    func setupSmartAlarmMenu() {
        let options = ["15 min", "30 min", "45 min"]
        
        let menuActions = options.map { title in
            let isOn = (title == selectedWindow)
            
            return UIAction(title: title, state: isOn ? .on : .off) { [weak self] action in
                self?.buttonWindow.setTitle(title, for: .normal)
                self?.selectedWindow = title
                self?.setupSmartAlarmMenu()
            }
        }
        buttonWindow.menu = UIMenu(title: "Select Window",options: .singleSelection,children: menuActions)
        buttonWindow.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func toggleChanged(_ sender: UISwitch) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SoundPickerViewController {
            destinationVC.delegate = self
            
            if let indexPath = tableView.indexPathForSelectedRow {
                activeSection = indexPath.section
                
                if activeSection == 1 {
                    destinationVC.selectedSoundName = selectedSoundLabel.text ?? ""
                } else {
                    destinationVC.selectedSoundName = selectedSoundLabel2.text ?? ""
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Section 0 is the time picker
        if indexPath.section == 0 {
            return 454
        }
        
        // Section 1: Wake Up
        if indexPath.section == 1 && wakeUpOptionRows.contains(indexPath.row) {
            return wakeUpToggle.isOn ? UITableView.automaticDimension : 0
        }
        
        // Section 2: Bedtime
        if indexPath.section == 2 && bedtimeOptionRows.contains(indexPath.row) {
            return bedTimeToggle.isOn ? UITableView.automaticDimension : 0
        }
        
        return UITableView.automaticDimension
    }
    
    // to handle the toggles of the bed time and wake time
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && wakeUpOptionRows.contains(indexPath.row) {
            cell.isHidden = !wakeUpToggle.isOn
            cell.clipsToBounds = true
        } else if indexPath.section == 2 && bedtimeOptionRows.contains(indexPath.row) {
            cell.isHidden = !bedTimeToggle.isOn
            cell.clipsToBounds = true
        } else {
            cell.isHidden = false
        }
    }
    
    func didSelectSound(_ name: String, haptic: String) {
        if activeSection == 1 {
            selectedSoundLabel.text = "\(name) • \(haptic)"
        } else {
            selectedSoundLabel2.text = "\(name) • \(haptic)"
        }
        tableView.reloadData()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Alarm Set",
            message: "Your alarm for the selected time has been saved.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Optional: Dismiss this screen or navigate back after the user hits OK
             self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
