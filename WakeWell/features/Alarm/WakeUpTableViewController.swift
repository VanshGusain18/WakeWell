//
//  WakeUpTableViewController.swift
//  WakeWell
//
//  Created by geu on 09/02/26.
//

import UIKit

protocol WakeUpDelegate: AnyObject {
    func didSelectWakeTime(_ time: String)
    func didUpdateSmartAlarm(wakeTime: Date, windowMinutes: Int, isSmartEnabled: Bool)
}


class WakeUpTableViewController: UITableViewController {
    
    weak var delegate: WakeUpDelegate?
    
    @IBOutlet weak var smartAlarmSwitch: UISwitch!
    @IBOutlet weak var timeWindowCell: UITableViewCell!
    @IBOutlet weak var alarmToneCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeWindowButton: UIButton!
    @IBOutlet weak var selectedSoundLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSmartRows(isEnabled: smartAlarmSwitch.isOn)
        setupTimeWindowMenu()
        self.clearsSelectionOnViewWillAppear = false
        if let savedDate = UserDefaults.standard.object(forKey: "UserWakeTime") as? Date {
            datePicker.date = savedDate
        }
        let isSmartOn = UserDefaults.standard.bool(forKey: "IsSmartEnabled")
        smartAlarmSwitch.isOn = isSmartOn
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showSounds",
//           let destinationVC = segue.destination as? SoundTableViewController {
//            destinationVC.delegate = self
//            destinationVC.isSelectionMode = true // This triggers the new logic
//        }
//    }
//    func openSoundSelection() {
//        if let soundVC = self.storyboard?.instantiateViewController(withIdentifier: "sound") as? SoundTableViewController {
//            soundVC.delegate = self
//            soundVC.isSelectionMode = true
//            self.navigationController?.presentingViewController?.present(soundVC, animated: true)
//        
//        }
//    }
    
    func didSelectAlarmSound(_ sound: Sound) {
            selectedSoundLabel.text = sound.title
            
            UserDefaults.standard.set(sound.fileName, forKey: "SelectedAlarmTone")
        }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 3
        }
        return 0
    }
       
        @IBAction func smartAlarmToggled(_ sender: UISwitch) {
            updateSmartRows(isEnabled: sender.isOn)
        }

    private func updateSmartRows(isEnabled: Bool) {
        UIView.animate(withDuration: 0.5) {
            [self.timeWindowCell, self.alarmToneCell].forEach { cell in
                cell?.isUserInteractionEnabled = isEnabled
                cell?.contentView.alpha = isEnabled ? 1.0 : 0.5
            }
        }
    }
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let selectedTime = datePicker.date
        let isSmartEnabled = smartAlarmSwitch.isOn
        
        // 1. Get the window duration from the button title (e.g., "30 mins")
        let windowTitle = timeWindowButton.title(for: .normal) ?? "15 mins"
        let windowMinutes = Int(windowTitle.components(separatedBy: " ").first ?? "15") ?? 15
        
        if isSmartEnabled {
            // 2. Calculate the "Earliest" time
            let earliestTime = selectedTime.addingTimeInterval(TimeInterval(-windowMinutes * 60))
            
            // 3. Create the confirmation message
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            
            let message = """
            Your Smart Alarm is set!
            
            Window starts: \(timeFormatter.string(from: earliestTime))
            Latest wake up: \(timeFormatter.string(from: selectedTime))
            
            We will wake you when you are in light sleep during this \(windowMinutes)-minute window.
            """
            
            // 4. Show the Alert
            let alert = UIAlertController(title: "Confirm Smart Alarm", message: message, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                self.finalizeSave(date: selectedTime, isSmart: isSmartEnabled)
            }
            
            let editAction = UIAlertAction(title: "Edit", style: .cancel, handler: nil)
            
            alert.addAction(confirmAction)
            alert.addAction(editAction)
            
            present(alert, animated: true)
            
        } else {
            // If smart alarm is off, just save normally
            finalizeSave(date: selectedTime, isSmart: isSmartEnabled)
        }
    }

    // Helper function to handle the actual saving
    private func finalizeSave(date: Date, isSmart: Bool) {
        UserDefaults.standard.set(date, forKey: "UserWakeTime")
        UserDefaults.standard.set(isSmart, forKey: "IsSmartEnabled")
        
        let timeString = formatTime(date)
        delegate?.didSelectWakeTime(timeString)
        dismiss(animated: true)
    }
    
    func setupTimeWindowMenu() {
        let options = ["15 mins", "30 mins", "45 mins"]
        
        let menuChildren = options.map { title in
            UIAction(title: title, handler: { [weak self] action in
                self?.timeWindowButton.setTitle(title, for: .normal)
                print("User selected \(title)")
            })
        }
        
        timeWindowButton.menu = UIMenu(title: "Select Time Window", children: menuChildren)
        timeWindowButton.showsMenuAsPrimaryAction = true
        timeWindowButton.changesSelectionAsPrimaryAction = true
    }
}
