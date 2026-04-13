//
//  BaseMetricTableViewController.swift
//  WakeWell
//
//  Created by geu on 25/03/26.
//

import UIKit

class BaseMetricTableViewController: UITableViewController {
    
    var timeRange: StatsTimeRange = .week
    
    func buildCell(for section: SectionType, range: StatsTimeRange,
                   tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclasses must override buildCell(for:range:tableView:indexPath:)")
    }
    
    func infoHeight(for range: StatsTimeRange) -> CGFloat { 220 }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle  = .none
        registerCells()
        loadData(for: timeRange)
    }
    
    func update(range: StatsTimeRange) {
        timeRange = range
        loadData(for: range)
        tableView.reloadData()
    }
    
    func loadData(for range: StatsTimeRange) {}
    
    private func registerCells() {
        ["HeaderTableViewCell",
         "LineChartTableViewCell",
         "BarChartTableViewCell",
         "infoTableViewCell"].forEach { name in
            tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        SectionType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch SectionType(rawValue: indexPath.section)! {
        case .header:        return 100
        case .trend:         return 300
        case .fragmentation: return 300
        case .info:          return infoHeight(for: timeRange)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        return buildCell(for: section, range: timeRange, tableView: tableView, indexPath: indexPath)
    }
    
    func dequeueHeader(_ tableView: UITableView, indexPath: IndexPath) -> HeaderTableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell
    }
    
    func dequeueLineChart(_ tableView: UITableView, indexPath: IndexPath) -> LineChartTableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "LineChartTableViewCell", for: indexPath) as! LineChartTableViewCell
    }
    
    func dequeueBarChart(_ tableView: UITableView, indexPath: IndexPath) -> BarChartTableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "BarChartTableViewCell", for: indexPath) as! BarChartTableViewCell
    }
    
    func dequeueInfo(_ tableView: UITableView, indexPath: IndexPath) -> infoTableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "infoTableViewCell", for: indexPath) as! infoTableViewCell
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
