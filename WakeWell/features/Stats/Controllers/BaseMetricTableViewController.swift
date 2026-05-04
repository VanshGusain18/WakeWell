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
        view.backgroundColor             = WakeWellTheme.background
        tableView.backgroundColor        = WakeWellTheme.background
        tableView.separatorStyle         = .none
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
        registerCells()
        loadData(for: timeRange)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Force background every time screen appears (fixes modal presentation resetting it)
        view.backgroundColor      = WakeWellTheme.background
        tableView.backgroundColor = WakeWellTheme.background
    }

    func update(range: StatsTimeRange) {
        timeRange = range; loadData(for: range); tableView.reloadData()
    }

    func loadData(for range: StatsTimeRange) {}

    private func registerCells() {
        ["HeaderTableViewCell", "LineChartTableViewCell",
         "BarChartTableViewCell", "infoTableViewCell"].forEach {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { SectionType.allCases.count }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch SectionType(rawValue: indexPath.section)! {
        case .header:        return 100
        case .trend:         return 300
        case .fragmentation: return 300
        case .info:          return infoHeight(for: timeRange)
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        let cell = buildCell(for: section, range: timeRange,
                             tableView: tableView, indexPath: indexPath)
        // Ensure every cell's background matches the screen — not white
        cell.backgroundColor        = WakeWellTheme.background
        cell.contentView.backgroundColor = .clear
        return cell
    }

    // Convenience dequeue helpers (unchanged)
    func dequeueHeader(_ tv: UITableView, indexPath: IndexPath) -> HeaderTableViewCell {
        tv.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell
    }
    func dequeueLineChart(_ tv: UITableView, indexPath: IndexPath) -> LineChartTableViewCell {
        tv.dequeueReusableCell(withIdentifier: "LineChartTableViewCell", for: indexPath) as! LineChartTableViewCell
    }
    func dequeueBarChart(_ tv: UITableView, indexPath: IndexPath) -> BarChartTableViewCell {
        tv.dequeueReusableCell(withIdentifier: "BarChartTableViewCell", for: indexPath) as! BarChartTableViewCell
    }
    func dequeueInfo(_ tv: UITableView, indexPath: IndexPath) -> infoTableViewCell {
        tv.dequeueReusableCell(withIdentifier: "infoTableViewCell", for: indexPath) as! infoTableViewCell
    }
}
