//
//  HapticPickerViewController.swift
//  WakeWell
//
//  Created by geu on 16/03/26.
//

import UIKit

protocol HapticPickerDelegate: AnyObject {
    func didSelectHaptic(_ name: String)
}

class HapticPickerViewController: UITableViewController {

    weak var delegate: HapticPickerDelegate?
    var selectedHapticLabel: String = "None (Default)"
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        configureBackButton()
    }

    private func applyTheme() {
        view.backgroundColor = WakeWellTheme.background
        tableView.backgroundColor = WakeWellTheme.background
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
        navigationItem.largeTitleDisplayMode = .never
    }

    private func configureBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    @objc private func backTapped() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.textColor = WakeWellTheme.labelPrimary
        cell.backgroundColor = WakeWellTheme.cardBackground
        cell.contentView.backgroundColor = WakeWellTheme.cardBackground
        cell.tintColor = WakeWellTheme.accentPurple
        let cellTitle = cell.textLabel?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let selectedTitle = selectedHapticLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.accessoryType = cellTitle == selectedTitle ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView,
                            forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = WakeWellTheme.background
        header.textLabel?.textColor = WakeWellTheme.labelSecondary
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UISelectionFeedbackGenerator().selectionChanged()
        guard let selectedName = tableView.cellForRow(at: indexPath)?.textLabel?.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !selectedName.isEmpty else { return }
        selectedHapticLabel = selectedName
        
        delegate?.didSelectHaptic(selectedHapticLabel)
        tableView.reloadData()
        
        // Return to options after a brief delay to show the checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.backTapped()
        }
    }
}
