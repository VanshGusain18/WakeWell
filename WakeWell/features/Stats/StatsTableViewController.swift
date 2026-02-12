import UIKit

class StatsTableViewController: UITableViewController {

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

        // SECTION 0 — Sleep Score Chart
        if indexPath.section == 0 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SleepScoreChartCell",
                for: indexPath
            ) as! SleepScoreChartCell

            cell.configureForWeek()   // your existing method

            return cell
        }

        // SECTION 1 — Metric Cards
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
                    self?.openDurationScreen()
                },
                onRightTap: nil   // not clickable
            )

        case 1:
            cell.configure(
                left: ("Architecture", "Good"),
                right: ("Continuity", "Stable"),
                onLeftTap: nil,
                onRightTap: nil
            )

        case 2:
            cell.configure(
                left: ("Calmness", "High"),
                right: ("Consistency", "78%"),
                onLeftTap: nil,
                onRightTap: nil
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

    // MARK: - Navigation

    private func openDurationScreen() {
        let vc = DurationDetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
