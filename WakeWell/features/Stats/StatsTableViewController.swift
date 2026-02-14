import UIKit

class StatsTableViewController: UITableViewController {
    

    @IBOutlet weak var timeRangeSegment: UISegmentedControl!
    private var sleepStats: SleepStats?
    private var metrics: [SleepMetric] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        loadSleepData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = 48
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
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Week")
        case 1:
            print("Month")
        case 2:
            print("Year")
        default:
            break
        }
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

        switch metric {

        case .duration:
            let vc = DurationDetailsViewController(metricType: metric)
            navigationController?.pushViewController(vc, animated: true)

        case .efficiency:
            let vc = EfficiencyDetailsViewController()
            navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }



}
