//
//  DurationTableViewController.swift
//  SetSail
//
//  Created by geu on 23/03/26.
//

import UIKit

class DurationTableViewController: BaseMetricTableViewController {

    private var data: [DurationData] = []

    override func loadData(for range: StatsTimeRange) {
        data = SleepDurationAnalyzer.getData(for: range)
    }

    override func infoHeight(for range: StatsTimeRange) -> CGFloat { 200 }

    override func buildCell(for section: SectionType, range: StatsTimeRange,
                            tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch section {
        case .header:
            let cell = dequeueHeader(tableView, indexPath: indexPath)
            cell.configure(
                title: "Duration",
                description: "Measures the total time you spend asleep each \(range.title.lowercased())."
            )
            return cell

        case .trend:
            let cell = dequeueLineChart(tableView, indexPath: indexPath)
            let chartData = SleepDurationAnalyzer.trendChartData(from: data)
            cell.configure(title: chartData.title,
                           dataSets: chartData.dataSets,
                           xAxisLabels: chartData.xAxisLabels)
            return cell

        case .fragmentation:
            let cell = dequeueBarChart(tableView, indexPath: indexPath)
            let chartData = SleepDurationAnalyzer.durationBarChartData(from: data)
            cell.configure(title: chartData.title,
                           dataSets: chartData.dataSets,
                           xAxisLabels: chartData.xAxisLabels)
            return cell

        case .info:
            let cell = dequeueInfo(tableView, indexPath: indexPath)
            cell.configure(title: "About Sleep Duration",
                           description: SleepDurationAnalyzer.durationInfo())
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
