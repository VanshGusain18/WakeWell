import UIKit

class StatsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        setupSegmentControl()
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    }
    
    // MARK: - Cell Registration
    private func registerCells() {
        tableView.register(UINib(nibName:"SleepScoreChartCell", bundle: nil),forCellReuseIdentifier:"SleepScoreChartCell" )
        
        tableView.register(UINib(nibName:"StatsMetricCardCell", bundle: nil),forCellReuseIdentifier: "StatsMetricCardCell")
    }
    
    private func setupSegmentControl() {
        let segment = UISegmentedControl(items: ["Week", "Month", "Year"])
        segment.selectedSegmentIndex = 0
        segment.frame = CGRect(x: 16, y: 8, width: view.frame.width - 32, height: 32)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 48))
        headerView.addSubview(segment)
        tableView.tableHeaderView = headerView
        
        segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 6 // 1 chart row, 6 metric rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        // SECTION 0 — Sleep Score Chart
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SleepScoreChartCell",
                for: indexPath
            ) as! SleepScoreChartCell
            cell.configureForWeek()
            return cell
        }
        
        // SECTION 1 — Metric Cards
        let metrics: [(title: String, value: String)] = [
            ("Duration", "7h 45m"),
            ("Efficiency", "82%"),
            ("Architecture", "Good"),
            ("Continuity", "Stable"),
            ("Calmness", "High"),
            ("Consistency", "78%")
        ]
        
        let metric = metrics[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsMetricCardCell", for: indexPath) as! StatsMetricCardCell
        

        // Assign onTap closures for each card
        switch metric.title {
        case "Duration":
            cell.configure(title: metric.title, value: metric.value, onTap: { [weak self] in
                self?.openDurationScreen()
            })
        case "Efficiency":
            cell.configure(title: metric.title, value: metric.value, onTap: { [weak self] in
                self?.openEfficiencyScreen()
            })
        case "Architecture":
            cell.configure(title: metric.title, value: metric.value, onTap: { [weak self] in
                self?.openArchitectureScreen()
            })
        case "Continuity":
            cell.configure(title: metric.title, value: metric.value, onTap: { [weak self] in
                self?.openContinuityScreen()
            })
        case "Calmness":
            cell.configure(title: metric.title, value: metric.value, onTap: { [weak self] in
                self?.openCalmnessScreen()
            })
        case "Consistency":
            cell.configure(title: metric.title, value: metric.value, onTap: { [weak self] in
                self?.openConsistencyScreen()
            })
        default:
            cell.configure(title: metric.title, value: metric.value, onTap: nil)
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 260 : 120
    }
    
    // MARK: - Navigation / Actions
    private func openDurationScreen() {
        let vc = DurationDetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openEfficiencyScreen() {
        let vc = EfficiencyDetailsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openArchitectureScreen() {
        let vc = ArchitectureDetailsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openContinuityScreen() {
        let vc = ContinuityDetailsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openCalmnessScreen() {
        let vc = CalmnessDetailsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openConsistencyScreen() {
        let vc = ConsistencyDetailsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
