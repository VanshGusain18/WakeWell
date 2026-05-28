//
//  HapticPickerViewController.swift
//  SetSail
//
//  Fully programmatic — no XIB, no Storyboard.
//

import UIKit

protocol HapticPickerDelegate: AnyObject {
    func didSelectHaptic(_ name: String)
}

final class HapticPickerViewController: UITableViewController {

    // MARK: - Public config
    var selectedHapticLabel: String = SoundSelection.default.haptic
    weak var delegate: HapticPickerDelegate?

    // MARK: - Data
    private let haptics: [String] = [
        "None (Default)",
        "Gentle",
        "Alert",
        "Heartbeat",
        "Rapid"
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Haptic"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = WakeWellTheme.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
    }

    // MARK: - DataSource

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int { haptics.count }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? { "HAPTIC PATTERN" }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor      = WakeWellTheme.cardBackground
        cell.textLabel?.text      = haptics[indexPath.row]
        cell.textLabel?.textColor = WakeWellTheme.labelPrimary
        cell.tintColor            = WakeWellTheme.accentPurple
        cell.selectionStyle       = .none
        cell.accessoryType        = haptics[indexPath.row] == selectedHapticLabel ? .checkmark : .none
        return cell
    }

    // MARK: - Delegate

    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let h = view as? UITableViewHeaderFooterView else { return }
        h.textLabel?.textColor = WakeWellTheme.labelSecondary
        h.textLabel?.font      = .systemFont(ofSize: 12, weight: .semibold)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        UISelectionFeedbackGenerator().selectionChanged()
        selectedHapticLabel = haptics[indexPath.row]
        delegate?.didSelectHaptic(selectedHapticLabel)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
