import UIKit

class StatsTableViewController: UITableViewController {
    
    private var sleepStats: SleepStats?
    private var metrics: [SleepMetric] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        setupSegmentControl()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        loadSleepData()
    }
    
    // MARK: - Load Data
    
    private func loadSleepData() {
        let stats = SleepStats(
            duration: 8.2,
            efficiency: 87,
            architecture: 4.0,
            consistency: 3.5,
            calmness: 4.2,
            continuity: 3.9
        )
        
        self.sleepStats = stats
        self.metrics = SleepStatsMapper.mapToMetrics(from: stats)
        tableView.reloadData()
    }
    
    // MARK: - Cell Registration
    
    private func registerCells() {
        tableView.register(
            UINib(nibName: "SleepScoreChartCell", bundle: nil),
            forCellReuseIdentifier: "SleepScoreChartCell"
        )
        
        tableView.register(
            UINib(nibName: "StatsMetricCardCell", bundle: nil),
            forCellReuseIdentifier: "StatsMetricCardCell"
        )
    }
    
    // MARK: - Segment Control
    
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
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 { return 1 }
        
        return Int(ceil(Double(metrics.count) / 2.0))
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // SECTION 0 → Chart Cell
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SleepScoreChartCell",
                for: indexPath
            ) as! SleepScoreChartCell
            
            cell.configureForWeek()
            return cell
        }
        
        // SECTION 1 → Metric Cards
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "StatsMetricCardCell",
            for: indexPath
        ) as? StatsMetricCardCell else {
            return UITableViewCell()
        }
        
        let leftIndex = indexPath.row * 2
        let rightIndex = leftIndex + 1
        
        let leftMetric = metrics[leftIndex]
        let rightMetric = rightIndex < metrics.count ? metrics[rightIndex] : nil
        
        cell.configure(
            leftTitle: leftMetric.type.title,
            leftValue: leftMetric.displayValue,
            rightTitle: rightMetric?.type.title,
            rightValue: rightMetric?.displayValue,
            leftAction: { [weak self] in
                self?.handleTap(type: leftMetric.type)
            },
            rightAction: rightMetric != nil ? { [weak self] in
                self?.handleTap(type: rightMetric!.type)
            } : nil
        )
        
        return cell
    }
    
    // MARK: - Row Height
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 260 : 120
    }
    
    // MARK: - Metric Tap Handler
    
    private func handleTap(type: SleepMetricType) {
        switch type {
        case .duration:
            openDurationScreen()
        case .efficiency:
            openEfficiencyScreen()
        case .architecture:
            openArchitectureScreen()
        case .continuity:
            openContinuityScreen()
        case .calmness:
            openCalmnessScreen()
        case .consistency:
            openConsistencyScreen()
        }
    }
    
    // MARK: - Navigation
    
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
