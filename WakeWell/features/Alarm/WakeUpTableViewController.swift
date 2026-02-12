//
//  WakeUpTableViewController.swift
//  WakeWell
//
//  Created by geu on 09/02/26.
//

import UIKit

class WakeUpTableViewController: UITableViewController {

    @IBOutlet weak var smartAlarmSwitch: UISwitch!
    @IBOutlet weak var timeWindowCell: UITableViewCell!
    @IBOutlet weak var alarmToneCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeWindowButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSmartRows(isEnabled: smartAlarmSwitch.isOn)
        setupTimeWindowMenu()
        self.clearsSelectionOnViewWillAppear = false
    }

    // MARK: - Table view data source

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
    protocol DatePickerDelegate: AnyObject {
        func didSelectWakeTime(_ time: String)
    }
    weak var delegate: DatePickerDelegate?

    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
            let timeString = formatTime(datePicker.date)
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
