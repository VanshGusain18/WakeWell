// statstable view controller file
import UIKit
class StatsTableViewController: UITableViewController {
    
    @IBOutlet weak var timeRangeSegment: UISegmentedControl!
    private var currentRange: StatsTimeRange = .week
    private var metrics: [SleepMetric] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        prefetchAllRanges()
        registerCells()
        loadSleepData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = 48
    }

    private func loadSleepData() {
        let rawStats = SleepStatsAggregator.aggregate(for: currentRange)
        let rounded = SleepStats(
            duration:     rawStats.duration.rounded(),
            efficiency:   rawStats.efficiency.rounded(),
            architecture: rawStats.architecture.rounded(),
            consistency:  rawStats.consistency.rounded(),
            calmness:     rawStats.calmness.rounded(),
            continuity:   rawStats.continuity.rounded()
        )
        metrics = SleepStatsMapper.mapToMetrics(from: rounded)
        tableView.reloadData()
    }

    private func registerCells() {
        tableView.register(UINib(nibName: "SleepScoreChartCell",  bundle: nil), forCellReuseIdentifier: "SleepScoreChartCell")
        tableView.register(UINib(nibName: "StatsMetricCardCell", bundle: nil), forCellReuseIdentifier: "StatsMetricCardCell")
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        guard let range = StatsTimeRange(rawValue: sender.selectedSegmentIndex) else { return }
        currentRange = range
        loadSleepData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : Int(ceil(Double(metrics.count) / 2.0))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SleepScoreChartCell", for: indexPath) as! SleepScoreChartCell
            cell.configure(for: currentRange)
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "StatsMetricCardCell", for: indexPath) as? StatsMetricCardCell else {
            return UITableViewCell()
        }

        let leftIndex  = indexPath.row * 2
        let rightIndex = leftIndex + 1
        let leftMetric  = metrics[leftIndex]
        let rightMetric = rightIndex < metrics.count ? metrics[rightIndex] : nil

        cell.configure(
            leftTitle:  leftMetric.type.title,
            leftValue:  leftMetric.displayValue,
            rightTitle: rightMetric?.type.title,
            rightValue: rightMetric?.displayValue,
            leftAction: { [weak self] in
                self?.openMetricScreen(leftMetric.type)
            },
            rightAction: rightMetric != nil ? { [weak self] in
                self?.openMetricScreen(rightMetric!.type)
            } : nil
        )
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 260 : 120
    }

    // MARK: - Navigation
    private func openMetricScreen(_ metric: SleepMetricType) {
        let vc = makeViewController(for: metric)
        vc.timeRange = currentRange
        present(vc, animated: true)
    }
    private func prefetchAllRanges() {
        let ranges: [StatsTimeRange] = [.week, .month, .year]
        let group = DispatchGroup()

        for range in ranges {
            group.enter()
            HealthKitSleepRepository.shared.prefetch(for: range) {
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            // All ranges cached — reload whichever table is currently visible
            self?.tableView.reloadData()
        }
    }
    func didChangeRange(_ range: StatsTimeRange) {
        HealthKitSleepRepository.shared.prefetch(for: range) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    private func makeViewController(for metric: SleepMetricType) -> BaseMetricTableViewController {
        switch metric {
        case .duration:
            return DurationTableViewController()
        case .efficiency:
            return EfficiencyTableViewController()
        case .continuity:
            return ContinuityTableViewController()
        case .calmness:
            return CalmnessTableViewController()
        case .architecture:
            return ArchitectureTableViewController()
        case .consistency:
            return ConsistencyTableViewController()
        }
    }
}



    
