//
//  ActivityInstructionViewController.swift
//  WakeWell
//

import UIKit

final class ActivityInstructionViewController: RoutineActivityViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let continueButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = "Step \(currentIndex + 1)/\(routineQueue.count)"
        setupTableView()
        setupContinueButton()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 110, right: 0)
        tableView.register(
            UINib(nibName: ActivityTextBlockCell.identifier, bundle: nil),
            forCellReuseIdentifier: ActivityTextBlockCell.identifier
        )
        tableView.register(
            UINib(nibName: ActivityStepListCell.identifier, bundle: nil),
            forCellReuseIdentifier: ActivityStepListCell.identifier
        )

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupContinueButton() {
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        continueButton.backgroundColor = .systemBlue
        continueButton.layer.cornerRadius = 16
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        view.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    @objc private func continueTapped() {
        navigateToNextActivity()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activity else { return UITableViewCell() }

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ActivityTextBlockCell.identifier,
                for: indexPath
            ) as! ActivityTextBlockCell
            let detail = activity.activityType == .informational
                ? "\(activity.description)\n\nTake this one at your own pace."
                : "\(activity.description)\n\nSuggested format: move through the steps carefully, then continue when you are done."
            cell.configure(sectionTitle: "Overview", body: detail)
            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ActivityStepListCell.identifier,
            for: indexPath
        ) as! ActivityStepListCell
        cell.configure(sectionTitle: "How To Do It", steps: activity.steps)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        180
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let activity else { return nil }

        let container = UIView()
        let card = UIView()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()

        container.backgroundColor = .clear
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.secondarySystemBackground
        card.layer.cornerRadius = 24

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = activity.title
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = activity.activityType == .informational ? "Self-paced activity" : "Step-based activity"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        subtitleLabel.textColor = .secondaryLabel

        container.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -24)
        ])

        return container
    }
}
