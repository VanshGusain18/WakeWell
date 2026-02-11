//
//  StatsTableViewController.swift
//  WakeWell
//
//  Created by geu on 10/02/26.
//

import UIKit


class StatsTableViewController: UITableViewController {
    var selectedSegmentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SleepScoreChartCell", bundle: nil), forCellReuseIdentifier: "SleepScoreChartCell")
        setupSegmentControl()
        tableView.register(UINib(nibName: "StatsMetricRowCell", bundle: nil), forCellReuseIdentifier: "StatsMetricRowCell")
        registerCells()

        tableView.separatorStyle = .none
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
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
        tableView.reloadData()
    }

    // MARK: - TableView DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        switch section {
        case 0:
            return 1        // Sleep Score chart
        case 1:
            return 3        // 6 cards (2 per row)
        default:
            return 0
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

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
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "StatsMetricRowCell",
            for: indexPath
        ) as! StatsMetricRowCell

        switch indexPath.row {
        case 0:
            cell.configure(
                left: ("Duration", "7h 45m"),
                right: ("Efficiency", "82%")
            )
        case 1:
            cell.configure(
                left: ("Architecture", "Good"),
                right: ("Continuity", "Stable")
            )
        case 2:
            cell.configure(
                left: ("Calmness", "High"),
                right: ("Consistency", "78%")
            )
        default:
            break
        }

        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        if indexPath.section == 0 {
            return 260
        } else {
            return 110
        }
    }
}

    // MARK: - Actions
