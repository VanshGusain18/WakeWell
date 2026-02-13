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
    
    
    private func loadSleepData() {

        let rawStats = SleepStatsAggregator.aggregate()

        let roundedStats = SleepStats(
            duration: round(rawStats.duration),
            efficiency: round(rawStats.efficiency),
            architecture: round(rawStats.architecture),
            consistency: round(rawStats.consistency),
            calmness: round(rawStats.calmness),
            continuity: round(rawStats.continuity)
        )

        self.sleepStats = roundedStats
        self.metrics = SleepStatsMapper.mapToMetrics(from: roundedStats)

        tableView.reloadData()
    }



    
    
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
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SleepScoreChartCell",
                for: indexPath
            ) as! SleepScoreChartCell
            
            cell.configureForWeek()
            return cell
        }
        
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
    
    
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 260 : 120
    }
    
    
    private func handleTap(type: SleepMetricType) {
        openMetricScreen(type)
    }
    
    
    private func openMetricScreen(_ metric: SleepMetricType) {
        let vc = BaseMetricChartViewController(metricType: metric)
        navigationController?.pushViewController(vc, animated: true)
    }
}
