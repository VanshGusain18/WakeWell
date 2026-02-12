import UIKit

class StatsTableViewController: UITableViewController {

    // MARK: - Metric Enum

    enum SelectedMetric {
        case sleepScore
        case duration
        case efficiency
        case architecture
        case continuity
        case calmness
        case consistency
    }

    var selectedMetric: SelectedMetric = .sleepScore
    var selectedSegmentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        setupSegmentControl()

        tableView.separatorStyle = .none
    }

    // MARK: - Cell Registration

    private func registerCells() {

        tableView.register(
            UINib(nibName: "SleepScoreChartCell", bundle: nil),
            forCellReuseIdentifier: "SleepScoreChartCell"
        )

        tableView.register(
            StatsMetricRowCell.self,
            forCellReuseIdentifier: "StatsMetricRowCell"
        )
    }

    // MARK: - Segment Control

    private func setupSegmentControl() {

        let segment = UISegmentedControl(items: ["Week", "Month", "Year"])
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        segment.frame = CGRect(
            x: 16,
            y: 8,
            width: view.frame.width - 32,
            height: 32
        )

        let headerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: 48
            )
        )

        headerView.addSubview(segment)
        tableView.tableHeaderView = headerView
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        reloadChart()
    }

    // MARK: - TableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 3
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // SECTION 0 → Chart
        if indexPath.section == 0 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SleepScoreChartCell",
                for: indexPath
            ) as! SleepScoreChartCell

            switch selectedMetric {

            case .sleepScore:
                cell.configureForSleepScore()

            case .duration:
                cell.configureForDuration()

            case .efficiency:
                cell.configureForEfficiency()

            case .architecture:
                cell.configureForArchitecture()

            case .continuity:
                cell.configureForContinuity()

            case .calmness:
                cell.configureForCalmness()

            case .consistency:
                cell.configureForConsistency()
            }

            return cell
        }

        // SECTION 1 → Metric Cards

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "StatsMetricRowCell",
            for: indexPath
        ) as! StatsMetricRowCell

        switch indexPath.row {

        case 0:
            cell.configure(
                left: ("Duration", "7h 45m"),
                right: ("Efficiency", "82%"),
                onLeftTap: { [weak self] in
                    self?.selectedMetric = .duration
                    self?.reloadChart()
                },
                onRightTap: { [weak self] in
                    self?.selectedMetric = .efficiency
                    self?.reloadChart()
                }
            )

        case 1:
            cell.configure(
                left: ("Architecture", "Good"),
                right: ("Continuity", "Stable"),
                onLeftTap: { [weak self] in
                    self?.selectedMetric = .architecture
                    self?.reloadChart()
                },
                onRightTap: { [weak self] in
                    self?.selectedMetric = .continuity
                    self?.reloadChart()
                }
            )

        case 2:
            cell.configure(
                left: ("Calmness", "High"),
                right: ("Consistency", "78%"),
                onLeftTap: { [weak self] in
                    self?.selectedMetric = .calmness
                    self?.reloadChart()
                },
                onRightTap: { [weak self] in
                    self?.selectedMetric = .consistency
                    self?.reloadChart()
                }
            )

        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 260 : 110
    }

    // MARK: - Reload Chart

    private func reloadChart() {
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}
