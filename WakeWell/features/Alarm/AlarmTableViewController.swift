//
//  AlarmTableViewController.swift
//  WakeWell
//
//  Created by geu on 07/02/26.
//

import UIKit

class AlarmTableViewController: UITableViewController, WakeUpDelegate, BedTimeDelegate {
    
    @IBOutlet weak var wakeTimeLabel: UILabel!
    @IBOutlet weak var bedTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didUpdateSmartAlarm(wakeTime: Date, windowMinutes: Int, isSmartEnabled: Bool) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        wakeTimeLabel.text = formatter.string(from: wakeTime)
        print("Smart Alarm updated: \(isSmartEnabled), Window: \(windowMinutes) mins")
        testSmartAlarmTrigger()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Helper to find the VC whether it's in a Nav Controller or not
            let destinationVC = (segue.destination as? UINavigationController)?.topViewController ?? segue.destination

            if let wakeVC = destinationVC as? WakeUpTableViewController {
                wakeVC.delegate = self // Now matches WakeUpDelegate
            } else if let bedVC = destinationVC as? BedTimeTableViewController {
                bedVC.delegate = self // Now matches BedTimeDelegate
            }
        }
    
    func didSelectWakeTime(_ time: String) {
        print("Data Recieved: \(time)")
        wakeTimeLabel.text = time
    }
    
    func didSelectBedTime(_ time: String) {
        print("Data Recieved: \(time)")
        bedTimeLabel.text = time
    }
    
    struct SmartAlarmEngine {
        func shouldTriggerAlarm(userTargetTime: Date, windowMinutes: Int, currentStage: String) -> Bool {
            let windowStart = userTargetTime.addingTimeInterval(Double(-windowMinutes * 60))
            let now = Date()
            let isInsideWindow = now >= windowStart && now <= userTargetTime
            let isLightSleep = (currentStage == "asleepCore" || currentStage == "asleepREM")
            
            return isInsideWindow && isLightSleep
        }
    }
    
    func testSmartAlarmTrigger() {
        // Hardcoded "Target" (e.g., 7:00 AM today)
        let calendar = Calendar.current
        let targetTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
        
        // Simulated "Current" Time (e.g., 6:40 AM - inside the window)
        let currentTime = calendar.date(bySettingHour: 6, minute: 40, second: 0, of: Date())!
        
        // Mock Data Stage (Shallow Sleep)
        let mockStage = "asleepCore"
        
        let engine = SmartAlarmEngine()
        let willRing = engine.shouldTriggerAlarm(userTargetTime: targetTime, windowMinutes: 30, currentStage: mockStage)
        
        print("Testing Smart Alarm: \(willRing ? "⏰ RINGS NOW (Perfect Sleep Phase)" : "💤 STAY SILENT")")
    }
}


