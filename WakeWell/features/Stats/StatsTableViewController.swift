// statstable view controller file
import UIKit

class StatsTableViewController: UITableViewController {

    
    @IBOutlet weak var outerView: UIView!
    
    @IBOutlet weak var timeRangeSegment: UISegmentedControl!
    private var currentRange: StatsTimeRange = .week
    private var metrics: [SleepMetric] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        tableView.separatorStyle = .none
        prefetchAllRanges()
        registerCells()
        loadSleepData()
        outerView.backgroundColor = WakeWellTheme.background
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = 48
    }

    // MARK: - Theme

    private func applyTheme() {
        view.backgroundColor      = WakeWellTheme.background
        tableView.backgroundColor = WakeWellTheme.background
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple

        timeRangeSegment?.selectedSegmentTintColor = WakeWellTheme.accentPurple
        timeRangeSegment?.backgroundColor          = WakeWellTheme.purpleTint
        timeRangeSegment?.setTitleTextAttributes(
            [.foregroundColor: UIColor.white,
             .font: UIFont.systemFont(ofSize: 13, weight: .semibold)], for: .selected)
        timeRangeSegment?.setTitleTextAttributes(
            [.foregroundColor: WakeWellTheme.shadowColor], for: .normal)
    }

    private func previousRange(for range: StatsTimeRange) -> StatsTimeRange? {
        switch range {
        case .week:  return .month
        case .month: return .year
        case .year:  return nil
        }
    }

    private func loadSleepData() {
        let currentRecords = HealthKitSleepRepository.shared.records(for: currentRange)
        guard !currentRecords.isEmpty else {
            metrics = []
            tableView.reloadData()
            return
        }

        let currentStats = SleepStatsAggregator.aggregate(for: currentRange)

        let previousStats: SleepStats?
        if let prevRange = previousRange(for: currentRange) {
            previousStats = SleepStatsAggregator.aggregate(for: prevRange)
        } else {
            previousStats = nil
        }

        metrics = SleepStatsMapper.mapToMetrics(from: currentStats,
                                                 previousStats: previousStats)
        tableView.reloadData()
    }

    private func registerCells() {
        tableView.register(UINib(nibName: "SleepScoreChartCell",  bundle: nil),
                           forCellReuseIdentifier: "SleepScoreChartCell")
        tableView.register(UINib(nibName: "StatsMetricCardCell", bundle: nil),
                           forCellReuseIdentifier: "StatsMetricCardCell")
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        guard let range = StatsTimeRange(rawValue: sender.selectedSegmentIndex) else { return }
        currentRange = range
        loadSleepData()
    }

    // MARK: - TableView

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : Int(ceil(Double(metrics.count) / 2.0))
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

        let li = indexPath.row * 2
        let ri = li + 1
        let lm = metrics[li]
        let rm = ri < metrics.count ? metrics[ri] : nil

        let rightAction: (() -> Void)? = rm.map { metric in
            { [weak self] in self?.openMetricScreen(metric.type) }
        }

        cell.configure(
            leftTitle:  lm.type.title,
            leftValue:  lm.displayValue,
            leftTrend:  lm.trendPercent,
            rightTitle: rm?.type.title,
            rightValue: rm?.displayValue,
            rightTrend: rm?.trendPercent ?? 0,
            leftAction:  { [weak self] in self?.openMetricScreen(lm.type) },
            rightAction: rightAction
        )
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 260 : 120
    }

    // MARK: - Navigation

    private func openMetricScreen(_ metric: SleepMetricType) {
        let vc = makeViewController(for: metric)
        vc.timeRange = currentRange
        present(vc, animated: true)
    }

    private func prefetchAllRanges() {
        let group = DispatchGroup()
        for range in StatsTimeRange.allCases {
            group.enter()
            HealthKitSleepRepository.shared.prefetch(for: range) { group.leave() }
        }
        group.notify(queue: .main) { [weak self] in self?.tableView.reloadData() }
    }

    func didChangeRange(_ range: StatsTimeRange) {
        HealthKitSleepRepository.shared.prefetch(for: range) { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func makeViewController(for metric: SleepMetricType) -> BaseMetricTableViewController {
        switch metric {
        case .duration:     return DurationTableViewController()
        case .efficiency:   return EfficiencyTableViewController()
        case .continuity:   return ContinuityTableViewController()
        case .calmness:     return CalmnessTableViewController()
        case .architecture: return ArchitectureTableViewController()
        case .consistency:  return ConsistencyTableViewController()
        }
    }
}
