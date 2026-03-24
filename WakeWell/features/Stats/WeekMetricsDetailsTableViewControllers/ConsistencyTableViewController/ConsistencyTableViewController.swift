//
//  ConsistencyTableViewController.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

//
//  ConsistencyDetailTableViewController.swift
//  WakeWell
//

import UIKit

class ConsistencyTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none

        // Register cells
        tableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderTableViewCell")
        tableView.register(UINib(nibName: "LineChartTableViewCell", bundle: nil), forCellReuseIdentifier: "LineChartTableViewCell")
        tableView.register(UINib(nibName: "BarChartTableViewCell", bundle: nil), forCellReuseIdentifier: "BarChartTableViewCell")
        tableView.register(UINib(nibName: "infoTableViewCell", bundle: nil), forCellReuseIdentifier: "infoTableViewCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch SectionType(rawValue: indexPath.section)! {
            case .header:
            return 100
        case .trend:
            return 300
        case .fragmentation:
            return 300
        case .info:
            return 220
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let weeklyData = SleepConsistencyAnalyzer.getWeeklyConsistency()

        switch SectionType(rawValue: indexPath.section)! {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell

            cell.configure(
                title: "Consistency",
                description: "Sleep Consistency Tracks sleep regularity."
            )

            return cell
        case .trend:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartTableViewCell", for: indexPath) as! LineChartTableViewCell
            let chartData = SleepConsistencyAnalyzer.trendChartData(from: weeklyData)
            cell.configure(title: chartData.title, dataSets: chartData.dataSets, xAxisLabels: chartData.xAxisLabels)
            return cell

        case .fragmentation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BarChartTableViewCell", for: indexPath) as! BarChartTableViewCell
            let chartData = SleepConsistencyAnalyzer.timingChartData(from: weeklyData)
            cell.configure(title: chartData.title, dataSets: chartData.dataSets, xAxisLabels: chartData.xAxisLabels)
            return cell

        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoTableViewCell", for: indexPath) as! infoTableViewCell
            cell.configure(title: "About Sleep Consistency", description: SleepConsistencyAnalyzer.consistencyInfo())
            return cell
        }
    }

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
