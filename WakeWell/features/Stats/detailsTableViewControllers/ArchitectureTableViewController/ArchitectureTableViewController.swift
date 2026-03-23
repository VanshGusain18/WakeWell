//
//  ArchitectureTableViewController.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

//
// SleepArchitectureDetailTableViewController.swift
//

//
// SleepArchitectureDetailTableViewController.swift
//

import UIKit

class ArchitectureTableViewController: UITableViewController {

    private enum SectionType: Int, CaseIterable {
        case trend, distribution, info
    }

    private var weeklyData: [SleepArchitectureData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        loadData()
    }

    private func setupTable() {
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none

        tableView.register(UINib(nibName: "LineChartTableViewCell", bundle: nil), forCellReuseIdentifier: "LineChartTableViewCell")
        tableView.register(UINib(nibName: "BarChartTableViewCell", bundle: nil), forCellReuseIdentifier: "BarChartTableViewCell")
        tableView.register(UINib(nibName: "infoTableViewCell", bundle: nil), forCellReuseIdentifier: "infoTableViewCell")
    }

    private func loadData() {
        weeklyData = SleepArchitectureAnalyzer.getWeeklyArchitecture()
        tableView.reloadData()
    }

    // MARK: - Table DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch SectionType(rawValue: indexPath.section)! {
        case .trend, .distribution:
            return 250
        case .info:
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SectionType(rawValue: indexPath.section)! {
        case .trend:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartTableViewCell", for: indexPath) as! LineChartTableViewCell
            let chartData = SleepArchitectureAnalyzer.trendChartData(from: weeklyData)
            cell.configure(title: chartData.title, dataSets: chartData.dataSets, xAxisLabels: chartData.xAxisLabels)
            return cell

        case .distribution:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BarChartTableViewCell", for: indexPath) as! BarChartTableViewCell
            let chartData = SleepArchitectureAnalyzer.distributionChartData(from: weeklyData)
            cell.configure(title: chartData.title, dataSets: chartData.dataSets, xAxisLabels: chartData.xAxisLabels)
            return cell

        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoTableViewCell", for: indexPath) as! infoTableViewCell
            cell.configure(title: "Sleep Architecture Info", description: SleepArchitectureAnalyzer.architectureInfo())
            return cell
        }
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
