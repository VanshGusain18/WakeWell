//
//  EfficiencyTableViewController.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

import DGCharts
import UIKit

class EfficiencyTableViewController: UITableViewController {

    enum SectionType: Int, CaseIterable {
        case header
        case trend
        case breakdown
        case info
    }

    var efficiencyData: [EfficiencyData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        loadData()
    }

    // MARK: - Setup

    private func registerCells() {
        tableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderTableViewCell")
        tableView.register(UINib(nibName: "LineChartTableViewCell", bundle: nil), forCellReuseIdentifier: "LineChartTableViewCell")
        tableView.register(UINib(nibName: "BarChartTableViewCell", bundle: nil), forCellReuseIdentifier: "BarChartTableViewCell")
        tableView.register(UINib(nibName: "infoTableViewCell", bundle: nil), forCellReuseIdentifier: "infoTableViewCell")
    }

    private func loadData() {
        efficiencyData = EfficiencyModel.getWeeklyEfficiency()
        tableView.reloadData()
    }

    // MARK: - Table Structure

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // MARK: - Cell Builder

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = SectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {

        // MARK: - HEADER
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell

            cell.configure(
                title: "Efficiency",
                description: "Sleep efficiency measures how much of your time in bed is actually spent sleeping."
            )

            return cell

        // MARK: - TREND (Efficiency Score)
        case .trend:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartTableViewCell", for: indexPath) as! LineChartTableViewCell

            let chartData = EfficiencyModel.trendChartData(from: efficiencyData)

            cell.configure(
                title: chartData.title,
                dataSets: chartData.dataSets,
                xAxisLabels: chartData.xAxisLabels
            )

            return cell

        // MARK: - BREAKDOWN (Double Bar)
        case .breakdown:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BarChartTableViewCell", for: indexPath) as! BarChartTableViewCell

            let chartData = EfficiencyModel.breakdownChartData(from: efficiencyData)

            cell.configure(
                title: chartData.title,
                dataSets: chartData.dataSets,
                xAxisLabels: chartData.xAxisLabels
            )

            return cell

        // MARK: - INFO
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoTableViewCell", for: indexPath) as! infoTableViewCell

            cell.configure(
                title: "About Sleep Efficiency",
                description: EfficiencyModel.durationInfo()
            )

            return cell
        }
    }

    // MARK: - Heights

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch SectionType(rawValue: indexPath.section)! {
        case .header:
            return 150
        case .info:
            return 200
        default:
            return 350
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
