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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSmartRows(isEnabled: smartAlarmSwitch.isOn)
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
        func didSelectTime(_ time: String)
    }
    weak var delegate: DatePickerDelegate?

    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
            let timeString = formatTime(datePicker.date)
            delegate?.didSelectTime(timeString)
            dismiss(animated: true)
    }
    
//    var isTimeWindowCell = false
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 1 && indexPath.row == 1 { // Adjust index as needed
//            isTimeWindowCell.toggle()
//            
//            tableView.beginUpdates()
//            tableView.endUpdates()
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        // Check if this is the row containing the Picker
//        if indexPath.section == 1 && indexPath.row == 2 {
//            return isTimeWindowCell ? 216 : 0
//        }
//        return UITableView.automaticDimension
//    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
