// MyRitualsViewController.swift — SetSail
// Shows the user's saved custom rituals.
// They can add new ones or delete existing ones.
// Built-in activities are shown below as read-only inspiration.

import UIKit

class MyRitualsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // Custom activities = those whose IDs start with a UUID (not "ritual_X")
    private var customActivities: [Activity] {
        activities.filter { !$0.id.hasPrefix("ritual_") }
    }
    private var builtInActivities: [Activity] {
        activities.filter { $0.id.hasPrefix("ritual_") }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Rituals"
        view.backgroundColor = WakeWellTheme.background

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem?.tintColor = WakeWellTheme.accentGold

        tableView.delegate              = self
        tableView.dataSource            = self
        tableView.backgroundColor       = WakeWellTheme.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadActivities()
        tableView.reloadData()
    }

    // MARK: - TableView

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0
            ? max(customActivities.count, 1)   // show placeholder row if empty
            : builtInActivities.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "My Custom Rituals" : "Built-in Activities"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = WakeWellTheme.cardBackground

        if indexPath.section == 0 {
            if customActivities.isEmpty {
                var cfg = cell.defaultContentConfiguration()
                cfg.text                 = "No custom rituals yet"
                cfg.textProperties.color = WakeWellTheme.labelTertiary
                cell.contentConfiguration = cfg
                cell.selectionStyle = .none
            } else {
                let a = customActivities[indexPath.row]
                var cfg = cell.defaultContentConfiguration()
                cfg.text                          = a.title
                cfg.textProperties.color          = WakeWellTheme.labelPrimary
                cfg.secondaryText                 = a.category
                cfg.secondaryTextProperties.color = WakeWellTheme.labelSecondary
                cell.contentConfiguration         = cfg
                cell.accessoryType                = .disclosureIndicator
            }
        } else {
            let a = builtInActivities[indexPath.row]
            var cfg = cell.defaultContentConfiguration()
            cfg.text                          = a.title
            cfg.textProperties.color          = WakeWellTheme.labelPrimary
            cfg.secondaryText                 = a.category
            cfg.secondaryTextProperties.color = WakeWellTheme.labelSecondary
            cell.contentConfiguration         = cfg
            cell.accessoryType                = .none
            cell.selectionStyle               = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 0 && !customActivities.isEmpty
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let toDelete = customActivities[indexPath.row]
        activities.removeAll { $0.id == toDelete.id }
        saveActivities()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add

    @objc private func addTapped() {
        let vc = AddCustomRitualViewController()
        vc.onSave = { [weak self] in
            self?.tableView.reloadData()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}
