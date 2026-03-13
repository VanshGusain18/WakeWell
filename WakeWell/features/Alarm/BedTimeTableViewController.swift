//
//  BedTimeTableViewController.swift
//  WakeWell
//
//  Created by geu on 10/02/26.
//

import UIKit

protocol BedTimeDelegate: AnyObject {
    func didSelectBedTime(_ time: String)
}

class BedTimeTableViewController: UITableViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedDate = UserDefaults.standard.object(forKey: "UserWakeTime") as? Date {
                datePicker.date = savedDate
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    weak var delegate: BedTimeDelegate?

    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let selectedBedTime = datePicker.date
        
        // 1. Fetch the already saved Wake Time to calculate total sleep
        let savedWakeDate = UserDefaults.standard.object(forKey: "UserWakeTime") as? Date
        
        // 2. Format times for the alert
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let bedTimeString = formatter.string(from: selectedBedTime)
        
        var message = "Your wind-down reminder is set for \(bedTimeString)."
        
        // 3. Optional: Add a "Sleep Duration" calculation if Wake Time exists
        if let wakeDate = savedWakeDate {
            // Simple logic to calculate hours between (handles overnight)
            var components = Calendar.current.dateComponents([.hour, .minute], from: selectedBedTime, to: wakeDate)
            if components.hour ?? 0 < 0 { components.hour? += 24 }
            
            message += "\n\nThis gives you about \(components.hour ?? 0)h \(components.minute ?? 0)m of sleep before your morning rituals."
        }

        // 4. Show the Alert
        let alert = UIAlertController(title: "Confirm Bedtime", message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            self.finalizeBedTimeSave(date: selectedBedTime)
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(editAction)
        
        present(alert, animated: true)
    }

    private func finalizeBedTimeSave(date: Date) {
        // Save to permanent storage
        UserDefaults.standard.set(date, forKey: "UserBedTime")
        
        let timeString = formatTime(date)
        delegate?.didSelectBedTime(timeString)
        dismiss(animated: true)
    }

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
